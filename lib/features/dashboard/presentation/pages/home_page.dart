import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/stat_card.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../inventory/presentation/providers/inventory_provider.dart';
import '../../../products/presentation/providers/product_provider.dart';
import '../../../sales/presentation/providers/sale_provider.dart';
import '../../../sales/presentation/pages/new_sale_page.dart';

/// Pantalla principal: resumen del negocio y accesos rapidos.
class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.onNavigate});

  /// Cambia la pestana activa del shell (0=Inicio, 1=Productos, ...).
  final ValueChanged<int> onNavigate;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _refresh());
  }

  Future<void> _refresh() async {
    await Future.wait([
      context.read<SaleProvider>().load(),
      context.read<ProductProvider>().load(),
      context.read<InventoryProvider>().load(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refresh,
          color: AppColors.primary,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Hola,',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                        Text(
                          user?.name ?? 'Usuario',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          user?.role.label ?? '',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.primarySoft,
                    child: Text(
                      (user?.name.isNotEmpty ?? false)
                          ? user!.name[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Consumer3<SaleProvider, ProductProvider, InventoryProvider>(
                builder: (context, sales, products, inventory, _) {
                  return GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.35,
                    children: [
                      StatCard(
                        icon: Icons.today_rounded,
                        label: 'Ventas de hoy',
                        value: Formatters.currency(sales.todayRevenue),
                        accent: AppColors.success,
                      ),
                      StatCard(
                        icon: Icons.inventory_2_rounded,
                        label: 'Productos',
                        value: '${products.totalProducts}',
                      ),
                      StatCard(
                        icon: Icons.warning_amber_rounded,
                        label: 'Bajo stock',
                        value: '${inventory.lowStockCount}',
                        accent: AppColors.warning,
                      ),
                      StatCard(
                        icon: Icons.receipt_long_rounded,
                        label: 'Ventas totales',
                        value: '${sales.totalSales}',
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),
              const Text(
                'Acciones rapidas',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _QuickAction(
                      icon: Icons.add_shopping_cart_rounded,
                      label: 'Nueva venta',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const NewSalePage(),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _QuickAction(
                      icon: Icons.inventory_2_rounded,
                      label: 'Productos',
                      onTap: () => widget.onNavigate(1),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _QuickAction(
                      icon: Icons.add_box_rounded,
                      label: 'Inventario',
                      onTap: () => widget.onNavigate(3),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'Ventas recientes',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Consumer<SaleProvider>(
                builder: (context, sales, _) {
                  if (sales.recentSales.isEmpty) {
                    return const Card(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Text(
                          'No hay ventas recientes.',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ),
                    );
                  }
                  return Card(
                    child: Column(
                      children: [
                        for (final sale in sales.recentSales)
                          ListTile(
                            leading: const Icon(Icons.receipt_rounded,
                                color: AppColors.primary),
                            title: Text(
                              sale.clientName,
                              style:
                                  const TextStyle(color: AppColors.textPrimary),
                            ),
                            subtitle: Text(
                              Formatters.dateTime(sale.date),
                              style: const TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 12,
                              ),
                            ),
                            trailing: Text(
                              Formatters.currency(sale.total),
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: 26),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
