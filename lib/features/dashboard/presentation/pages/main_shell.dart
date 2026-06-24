import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../inventory/presentation/pages/inventory_page.dart';
import '../../../products/presentation/pages/products_page.dart';
import '../../../sales/presentation/pages/sales_page.dart';
import 'home_page.dart';
import 'more_page.dart';

/// Contenedor principal con barra de navegacion inferior.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  void _goTo(int index) => setState(() => _index = index);

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomePage(onNavigate: _goTo),
      const ProductsPage(),
      const SalesPage(),
      const InventoryPage(),
      const MorePage(),
    ];

    return Scaffold(
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: _goTo,
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.primarySoft,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded, color: AppColors.primary),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined),
            selectedIcon:
                Icon(Icons.inventory_2_rounded, color: AppColors.primary),
            label: 'Productos',
          ),
          NavigationDestination(
            icon: Icon(Icons.point_of_sale_outlined),
            selectedIcon:
                Icon(Icons.point_of_sale_rounded, color: AppColors.primary),
            label: 'Ventas',
          ),
          NavigationDestination(
            icon: Icon(Icons.warehouse_outlined),
            selectedIcon:
                Icon(Icons.warehouse_rounded, color: AppColors.primary),
            label: 'Inventario',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_rounded),
            selectedIcon: Icon(Icons.menu_rounded, color: AppColors.primary),
            label: 'Mas',
          ),
        ],
      ),
    );
  }
}
