import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/stat_card.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../inventory/presentation/providers/inventory_provider.dart';
import '../../../products/presentation/providers/product_provider.dart';
import '../../../sales/presentation/providers/sale_provider.dart';

/// Reportes del negocio (RF-14, RF-15, RF-16).
///
/// Regla de negocio: solo los administradores pueden visualizar reportes.
/// Esta pantalla agrega informacion ya expuesta por los providers de cada
/// modulo (ventas, productos, inventario), sin duplicar el acceso a datos.
class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SaleProvider>().load();
      context.read<ProductProvider>().load();
      context.read<InventoryProvider>().load();
    });
  }

  Future<void> _pickStart() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now().subtract(const Duration(days: 30)),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _startDate = picked);
  }

  Future<void> _pickEnd() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _endDate = picked);
  }

  Future<void> _applyFilter() async {
    if (_startDate == null || _endDate == null) return;
    final end = DateTime(_endDate!.year, _endDate!.month, _endDate!.day, 23, 59, 59);
    await context.read<SaleProvider>().loadByDateRange(_startDate!, end);
  }

  Future<void> _clearFilter() async {
    setState(() {
      _startDate = null;
      _endDate = null;
    });
    await context.read<SaleProvider>().load();
  }

  @override
  Widget build(BuildContext context) {
    final role = context.read<AuthProvider>().user?.role;
    if (role == null || !role.canViewReports) {
      return Scaffold(
        appBar: AppBar(title: const Text('Reportes')),
        body: const EmptyState(
          icon: Icons.lock_outline_rounded,
          title: 'Acceso restringido',
          message: 'Solo los administradores pueden ver los reportes.',
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Reportes')),
      body: Consumer3<SaleProvider, ProductProvider, InventoryProvider>(
        builder: (context, sales, products, inventory, _) {
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            children: [
              _DateFilterBar(
                startDate: _startDate,
                endDate: _endDate,
                onPickStart: _pickStart,
                onPickEnd: _pickEnd,
                onApply: (_startDate != null && _endDate != null) ? _applyFilter : null,
                onClear: (_startDate != null || _endDate != null) ? _clearFilter : null,
              ),
              const SizedBox(height: 24),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.35,
                children: [
                  StatCard(
                    icon: Icons.payments_rounded,
                    label: 'Ventas totales',
                    value: Formatters.currency(sales.totalRevenue),
                  ),
                  StatCard(
                    icon: Icons.today_rounded,
                    label: 'Ventas de hoy',
                    value: Formatters.currency(sales.todayRevenue),
                    accent: AppColors.success,
                  ),
                  StatCard(
                    icon: Icons.receipt_long_rounded,
                    label: 'No. de ventas',
                    value: '${sales.totalSales}',
                  ),
                  StatCard(
                    icon: Icons.inventory_rounded,
                    label: 'Valor inventario',
                    value: Formatters.currency(products.inventoryValue),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _SectionTitle('Productos mas vendidos'),
              const SizedBox(height: 12),
              _TopProducts(sales: sales),
              const SizedBox(height: 24),
              _SectionTitle('Inventario bajo (${inventory.lowStockCount})'),
              const SizedBox(height: 12),
              _LowStockReport(inventory: inventory),
            ],
          );
        },
      ),
    );
  }
}

class _DateFilterBar extends StatelessWidget {
  const _DateFilterBar({
    required this.startDate,
    required this.endDate,
    required this.onPickStart,
    required this.onPickEnd,
    required this.onApply,
    required this.onClear,
  });

  final DateTime? startDate;
  final DateTime? endDate;
  final VoidCallback onPickStart;
  final VoidCallback onPickEnd;
  final VoidCallback? onApply;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Rango de fechas',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onPickStart,
                    child: Text(
                      startDate == null
                          ? 'Desde'
                          : Formatters.date(startDate!),
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward_rounded,
                    size: 16, color: AppColors.textMuted),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: onPickEnd,
                    child: Text(
                      endDate == null ? 'Hasta' : Formatters.date(endDate!),
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: onApply,
                    child: const Text('Filtrar'),
                  ),
                ),
                if (onClear != null) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onClear,
                      child: const Text('Limpiar'),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
    );
  }
}

class _TopProducts extends StatelessWidget {
  const _TopProducts({required this.sales});

  final SaleProvider sales;

  @override
  Widget build(BuildContext context) {
    // Agregar unidades vendidas por producto a partir del historial.
    final Map<String, int> units = {};
    final Map<String, double> revenue = {};
    for (final sale in sales.sales) {
      for (final item in sale.items) {
        units[item.productName] =
            (units[item.productName] ?? 0) + item.quantity;
        revenue[item.productName] =
            (revenue[item.productName] ?? 0) + item.subtotal;
      }
    }

    if (units.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Text(
            'Aun no hay ventas registradas.',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    final ranking = units.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top = ranking.take(5).toList();
    final maxUnits = top.first.value;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            for (final entry in top) ...[
              _BarRow(
                name: entry.key,
                units: entry.value,
                revenue: revenue[entry.key] ?? 0,
                fraction: entry.value / maxUnits,
              ),
              if (entry != top.last) const SizedBox(height: 14),
            ],
          ],
        ),
      ),
    );
  }
}

class _BarRow extends StatelessWidget {
  const _BarRow({
    required this.name,
    required this.units,
    required this.revenue,
    required this.fraction,
  });

  final String name;
  final int units;
  final double revenue;
  final double fraction;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Text(
              '$units und.  ·  ${Formatters.currency(revenue)}',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: fraction.clamp(0.05, 1.0),
            minHeight: 8,
            backgroundColor: AppColors.surfaceElevated,
            valueColor:
                const AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
      ],
    );
  }
}

class _LowStockReport extends StatelessWidget {
  const _LowStockReport({required this.inventory});

  final InventoryProvider inventory;

  @override
  Widget build(BuildContext context) {
    if (inventory.lowStock.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Text(
            'No hay productos por debajo del umbral.',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }
    return Card(
      child: Column(
        children: [
          for (final p in inventory.lowStock)
            ListTile(
              dense: true,
              leading: const Icon(Icons.warning_amber_rounded,
                  color: AppColors.warning),
              title: Text(
                p.name,
                style: const TextStyle(color: AppColors.textPrimary),
              ),
              trailing: Text(
                'Stock ${p.stock} / min ${p.lowStockThreshold}',
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            ),
        ],
      ),
    );
  }
}
