import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../products/domain/entities/product.dart';
import '../../../products/presentation/providers/product_provider.dart';
import '../../domain/entities/inventory_entry.dart';
import '../providers/inventory_provider.dart';

/// Inventario: historial de movimientos y alertas de bajo stock (RF-08 a RF-10).
class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InventoryProvider>().load();
      context.read<ProductProvider>().load();
    });
  }

  bool get _canManage =>
      context.read<AuthProvider>().user?.role.canManageInventory ?? false;

  Future<void> _openEntryForm() async {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const _StockEntryForm(),
    );
    if (saved == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Entrada de inventario registrada')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Inventario'),
          bottom: const TabBar(
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            tabs: [
              Tab(text: 'Movimientos'),
              Tab(text: 'Bajo stock'),
            ],
          ),
        ),
        floatingActionButton: _canManage
            ? FloatingActionButton.extended(
                heroTag: 'inventory_fab',
                onPressed: _openEntryForm,
                icon: const Icon(Icons.add_box_rounded),
                label: const Text('Entrada'),
              )
            : null,
        body: Consumer<InventoryProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading && provider.entries.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
            return TabBarView(
              children: [
                _MovementsTab(entries: provider.entries),
                _LowStockTab(products: provider.lowStock),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _MovementsTab extends StatelessWidget {
  const _MovementsTab({required this.entries});

  final List<InventoryEntry> entries;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return const EmptyState(
        icon: Icons.swap_vert_rounded,
        title: 'Sin movimientos',
        message: 'Las entradas y salidas apareceran aqui.',
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
      itemCount: entries.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final e = entries[index];
        final isEntry = e.type == MovementType.entrada;
        final color = isEntry ? AppColors.success : AppColors.primary;
        return Card(
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            leading: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(
                isEntry
                    ? Icons.arrow_downward_rounded
                    : Icons.arrow_upward_rounded,
                color: color,
              ),
            ),
            title: Text(
              e.productName,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            subtitle: Text(
              '${e.type.label}  ·  ${Formatters.dateTime(e.date)}',
              style: const TextStyle(color: AppColors.textMuted, fontSize: 12.5),
            ),
            trailing: Text(
              '${isEntry ? '+' : '-'}${e.quantity}',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _LowStockTab extends StatelessWidget {
  const _LowStockTab({required this.products});

  final List<Product> products;

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return const EmptyState(
        icon: Icons.check_circle_outline_rounded,
        title: 'Todo en orden',
        message: 'No hay productos con bajo inventario.',
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
      itemCount: products.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final p = products[index];
        return Card(
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            leading: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(11),
              ),
              child: const Icon(Icons.warning_amber_rounded,
                  color: AppColors.warning),
            ),
            title: Text(
              p.name,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            subtitle: Text(
              'Umbral: ${p.lowStockThreshold}',
              style: const TextStyle(color: AppColors.textMuted, fontSize: 12.5),
            ),
            trailing: Text(
              'Quedan ${p.stock}',
              style: const TextStyle(
                color: AppColors.warning,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Formulario para registrar una entrada de inventario (RF-10).
class _StockEntryForm extends StatefulWidget {
  const _StockEntryForm();

  @override
  State<_StockEntryForm> createState() => _StockEntryFormState();
}

class _StockEntryFormState extends State<_StockEntryForm> {
  final _formKey = GlobalKey<FormState>();
  final _quantity = TextEditingController();
  final _note = TextEditingController();
  Product? _product;
  bool _saving = false;

  @override
  void dispose() {
    _quantity.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _product == null) {
      if (_product == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Selecciona un producto')),
        );
      }
      return;
    }
    setState(() => _saving = true);
    final error = await context.read<InventoryProvider>().registerEntry(
          productId: _product!.id,
          quantity: int.parse(_quantity.text),
          note: _note.text.trim(),
        );
    if (!mounted) return;
    setState(() => _saving = false);
    if (error == null) {
      context.read<ProductProvider>().load();
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final products = context.watch<ProductProvider>().products;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottomInset),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Entrada de inventario',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<Product>(
              initialValue: _product,
              isExpanded: true,
              dropdownColor: AppColors.surfaceElevated,
              decoration: const InputDecoration(labelText: 'Producto'),
              items: products
                  .map((p) => DropdownMenuItem(
                        value: p,
                        child: Text('${p.name}  (stock: ${p.stock})'),
                      ))
                  .toList(),
              onChanged: (p) => setState(() => _product = p),
              validator: (v) => v == null ? 'Selecciona un producto' : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _quantity,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Cantidad a ingresar'),
              validator: (v) {
                final n = int.tryParse(v ?? '');
                if (n == null) return 'Cantidad invalida';
                if (n <= 0) return 'Debe ser mayor a cero';
                return null;
              },
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _note,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Nota (opcional)',
                hintText: 'Ej. Compra a proveedor',
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                          strokeWidth: 2.4, color: Colors.white),
                    )
                  : const Text('Registrar entrada'),
            ),
          ],
        ),
      ),
    );
  }
}
