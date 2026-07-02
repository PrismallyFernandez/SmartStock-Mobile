import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../clients/domain/entities/client.dart';
import '../../../clients/presentation/providers/client_provider.dart';
import '../../domain/entities/sale.dart';
import '../providers/sale_provider.dart';
import 'new_sale_page.dart';
import 'sale_receipt_sheet.dart';

/// Historial de ventas (RF-16) y acceso a registrar una nueva venta.
class SalesPage extends StatefulWidget {
  const SalesPage({super.key});

  @override
  State<SalesPage> createState() => _SalesPageState();
}

class _SalesPageState extends State<SalesPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SaleProvider>().load();
      context.read<ClientProvider>().load();
    });
  }

  Future<void> _newSale() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const NewSalePage()),
    );
    if (mounted) context.read<SaleProvider>().load();
  }

  Future<void> _confirmDelete(Sale sale) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Eliminar venta'),
        content: const Text(
          'La venta se eliminara y el stock de los productos sera restaurado. '
          'Esta accion no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      final error = await context.read<SaleProvider>().deleteSale(sale.id);
      if (!mounted) return;
      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Venta eliminada correctamente')),
        );
      }
    }
  }

  Future<void> _editSale(Sale sale) async {
    final clients = context.read<ClientProvider>().clients;
    Client? selectedClient;
    if (sale.clientId != null) {
      try {
        selectedClient = clients.firstWhere((c) => c.id == sale.clientId);
      } catch (_) {
        selectedClient = null;
      }
    }
    DateTime selectedDate = sale.date;

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setStateDialog) {
            return AlertDialog(
              backgroundColor: AppColors.surface,
              title: const Text('Editar venta'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<Client?>(
                    initialValue: selectedClient,
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'Cliente'),
                    items: [
                      const DropdownMenuItem<Client?>(
                        value: null,
                        child: Text('Cliente general'),
                      ),
                      ...clients.map(
                        (c) => DropdownMenuItem<Client?>(
                          value: c,
                          child: Text(c.name),
                        ),
                      ),
                    ],
                    onChanged: (c) => setStateDialog(() => selectedClient = c),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Fecha'),
                    subtitle: Text(Formatters.dateTime(selectedDate)),
                    trailing: const Icon(Icons.calendar_today_rounded,
                        color: AppColors.primary),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: ctx,
                        initialDate: selectedDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) {
                        setStateDialog(() => selectedDate = picked);
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('Guardar'),
                ),
              ],
            );
          },
        );
      },
    );

    if (ok == true && mounted) {
      final updated = Sale(
        id: sale.id,
        date: selectedDate,
        items: sale.items,
        clientId: selectedClient?.id,
        clientName: selectedClient?.name ?? 'Cliente general',
        sellerId: sale.sellerId,
        sellerName: sale.sellerName,
      );
      final error = await context.read<SaleProvider>().updateSale(updated);
      if (!mounted) return;
      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Venta actualizada correctamente')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final canEdit = context.read<AuthProvider>().user?.role.canViewReports ?? false;

    return Scaffold(
      appBar: AppBar(title: const Text('Ventas')),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'sales_fab',
        onPressed: _newSale,
        icon: const Icon(Icons.add_shopping_cart_rounded),
        label: const Text('Vender'),
      ),
      body: Consumer<SaleProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.sales.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.sales.isEmpty) {
            return const EmptyState(
              icon: Icons.receipt_long_outlined,
              title: 'Sin ventas',
              message: 'Las ventas registradas apareceran aqui.',
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
            itemCount: provider.sales.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final sale = provider.sales[index];
              return _SaleCard(
                sale: sale,
                canEdit: canEdit,
                onTap: () => showSaleReceipt(context, sale),
                onEdit: () => _editSale(sale),
                onDelete: () => _confirmDelete(sale),
              );
            },
          );
        },
      ),
    );
  }
}

class _SaleCard extends StatelessWidget {
  const _SaleCard({
    required this.sale,
    required this.canEdit,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  final Sale sale;
  final bool canEdit;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.receipt_long_rounded,
                    color: AppColors.primary),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sale.clientName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${Formatters.dateTime(sale.date)}  ·  ${sale.totalUnits} und.',
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                Formatters.currency(sale.total),
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
              if (canEdit)
                PopupMenuButton<String>(
                  color: AppColors.surfaceElevated,
                  icon: const Icon(Icons.more_vert_rounded,
                      color: AppColors.textSecondary),
                  onSelected: (value) {
                    if (value == 'edit') onEdit();
                    if (value == 'delete') onDelete();
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'edit', child: Text('Editar')),
                    PopupMenuItem(value: 'delete', child: Text('Eliminar')),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
