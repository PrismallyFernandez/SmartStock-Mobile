import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../clients/domain/entities/client.dart';
import '../../../clients/presentation/providers/client_provider.dart';
import '../../../products/domain/entities/product.dart';
import '../../../products/presentation/providers/product_provider.dart';
import '../../domain/entities/sale.dart';
import '../providers/sale_provider.dart';
import 'sale_receipt_sheet.dart';

/// Registro de una nueva venta (RF-11, RF-12).
class NewSalePage extends StatefulWidget {
  const NewSalePage({super.key});

  @override
  State<NewSalePage> createState() => _NewSalePageState();
}

class _NewSalePageState extends State<NewSalePage> {
  /// Cantidades seleccionadas por producto (id -> cantidad).
  final Map<String, int> _cart = {};
  Client? _selectedClient;
  bool _registering = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().load();
      context.read<ClientProvider>().load();
    });
  }

  double _total(List<Product> products) {
    double total = 0;
    for (final p in products) {
      total += p.price * (_cart[p.id] ?? 0);
    }
    return total;
  }

  int get _itemCount => _cart.values.fold(0, (a, b) => a + b);

  void _increment(Product p) {
    final current = _cart[p.id] ?? 0;
    if (current >= p.stock) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Solo hay ${p.stock} de "${p.name}"')),
      );
      return;
    }
    setState(() => _cart[p.id] = current + 1);
  }

  void _decrement(Product p) {
    final current = _cart[p.id] ?? 0;
    if (current <= 0) return;
    setState(() {
      if (current - 1 == 0) {
        _cart.remove(p.id);
      } else {
        _cart[p.id] = current - 1;
      }
    });
  }

  Future<void> _register(List<Product> products) async {
    if (_cart.isEmpty) return;
    setState(() => _registering = true);

    final seller = context.read<AuthProvider>().user!;
    final items = <SaleItem>[];
    for (final p in products) {
      final qty = _cart[p.id] ?? 0;
      if (qty > 0) {
        items.add(SaleItem(
          productId: p.id,
          productName: p.name,
          unitPrice: p.price,
          quantity: qty,
        ));
      }
    }

    final result = await context.read<SaleProvider>().register(
          items: items,
          seller: seller,
          client: _selectedClient,
        );

    if (!mounted) return;
    setState(() => _registering = false);

    if (result.success) {
      // Refrescar catalogo para reflejar el stock descontado.
      await context.read<ProductProvider>().load();
      if (!mounted) return;
      await showSaleReceipt(context, result.sale!);
      if (mounted) Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.error ?? 'Error al registrar la venta')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();
    final products = productProvider.products;
    final total = _total(products);

    return Scaffold(
      appBar: AppBar(title: const Text('Nueva venta')),
      body: Column(
        children: [
          _ClientSelector(
            selected: _selectedClient,
            onChanged: (c) => setState(() => _selectedClient = c),
          ),
          const Divider(height: 1),
          Expanded(
            child: productProvider.isLoading && products.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : products.isEmpty
                    ? const EmptyState(
                        icon: Icons.inventory_2_outlined,
                        title: 'Sin productos',
                        message: 'Registra productos para poder vender.',
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                        itemCount: products.length,
                        separatorBuilder: (_, _) =>
                            const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final p = products[index];
                          return _SaleProductTile(
                            product: p,
                            quantity: _cart[p.id] ?? 0,
                            onAdd: () => _increment(p),
                            onRemove: () => _decrement(p),
                          );
                        },
                      ),
          ),
          _CheckoutBar(
            total: total,
            itemCount: _itemCount,
            busy: _registering,
            onRegister: _cart.isEmpty ? null : () => _register(products),
          ),
        ],
      ),
    );
  }
}

class _ClientSelector extends StatelessWidget {
  const _ClientSelector({required this.selected, required this.onChanged});

  final Client? selected;
  final ValueChanged<Client?> onChanged;

  @override
  Widget build(BuildContext context) {
    final clients = context.watch<ClientProvider>().clients;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: DropdownButtonFormField<Client?>(
        initialValue: selected,
        isExpanded: true,
        dropdownColor: AppColors.surfaceElevated,
        decoration: const InputDecoration(
          labelText: 'Cliente',
          prefixIcon: Icon(Icons.person_outline_rounded),
        ),
        items: [
          const DropdownMenuItem<Client?>(
            value: null,
            child: Text('Cliente general'),
          ),
          ...clients.map(
            (c) => DropdownMenuItem<Client?>(value: c, child: Text(c.name)),
          ),
        ],
        onChanged: onChanged,
      ),
    );
  }
}

class _SaleProductTile extends StatelessWidget {
  const _SaleProductTile({
    required this.product,
    required this.quantity,
    required this.onAdd,
    required this.onRemove,
  });

  final Product product;
  final int quantity;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final outOfStock = product.stock <= 0;
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${Formatters.currency(product.price)}  ·  Stock: ${product.stock}',
                    style: TextStyle(
                      color: outOfStock
                          ? AppColors.danger
                          : AppColors.textSecondary,
                      fontSize: 12.5,
                    ),
                  ),
                ],
              ),
            ),
            if (outOfStock)
              const Text('Agotado',
                  style: TextStyle(color: AppColors.danger))
            else
              _QuantityStepper(
                quantity: quantity,
                onAdd: onAdd,
                onRemove: onRemove,
              ),
          ],
        ),
      ),
    );
  }
}

class _QuantityStepper extends StatelessWidget {
  const _QuantityStepper({
    required this.quantity,
    required this.onAdd,
    required this.onRemove,
  });

  final int quantity;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StepButton(
          icon: Icons.remove_rounded,
          onTap: quantity > 0 ? onRemove : null,
        ),
        SizedBox(
          width: 32,
          child: Text(
            '$quantity',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              fontSize: 16,
            ),
          ),
        ),
        _StepButton(icon: Icons.add_rounded, onTap: onAdd),
      ],
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({required this.icon, this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: enabled ? AppColors.primarySoft : AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          size: 20,
          color: enabled ? AppColors.primary : AppColors.textMuted,
        ),
      ),
    );
  }
}

class _CheckoutBar extends StatelessWidget {
  const _CheckoutBar({
    required this.total,
    required this.itemCount,
    required this.busy,
    required this.onRegister,
  });

  final double total;
  final int itemCount;
  final bool busy;
  final VoidCallback? onRegister;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        14,
        16,
        14 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$itemCount articulo(s)',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                Formatters.currency(total),
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const Spacer(),
          SizedBox(
            width: 180,
            child: ElevatedButton.icon(
              onPressed: busy ? null : onRegister,
              icon: busy
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2.2, color: Colors.white),
                    )
                  : const Icon(Icons.point_of_sale_rounded),
              label: const Text('Registrar'),
            ),
          ),
        ],
      ),
    );
  }
}
