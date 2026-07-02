import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/pages/users_page.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../categories/presentation/pages/categories_page.dart';
import '../../../clients/presentation/pages/clients_page.dart';
import '../../../reports/presentation/pages/reports_page.dart';

/// Menu "Mas": accesos a clientes, reportes y cierre de sesion.
class MorePage extends StatelessWidget {
  const MorePage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;
    final isAdmin = user?.role.canViewReports ?? false;

    return Scaffold(
      appBar: AppBar(title: const Text('Mas')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: AppColors.primarySoft,
                  child: Text(
                    (user?.name.isNotEmpty ?? false)
                        ? user!.name[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.name ?? 'Usuario',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        user?.email ?? '',
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        user?.role.label ?? '',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _MenuTile(
            icon: Icons.people_alt_rounded,
            title: 'Clientes',
            subtitle: 'Gestiona la cartera de clientes',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ClientsPage()),
            ),
          ),
          const SizedBox(height: 12),
          _MenuTile(
            icon: Icons.category_rounded,
            title: 'Categorias',
            subtitle: 'Gestiona las categorias de productos',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const CategoriesPage()),
            ),
          ),
          const SizedBox(height: 12),
          _MenuTile(
            icon: Icons.people_rounded,
            title: 'Usuarios',
            subtitle: isAdmin
                ? 'Crea y consulta usuarios del sistema'
                : 'Solo disponible para administradores',
            enabled: isAdmin,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const UsersPage()),
            ),
          ),
          const SizedBox(height: 12),
          _MenuTile(
            icon: Icons.bar_chart_rounded,
            title: 'Reportes',
            subtitle: isAdmin
                ? 'Ventas, inventario e historial'
                : 'Solo disponible para administradores',
            enabled: isAdmin,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ReportsPage()),
            ),
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () => auth.logout(),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.danger,
              minimumSize: const Size.fromHeight(52),
              side: const BorderSide(color: AppColors.danger),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            icon: const Icon(Icons.logout_rounded),
            label: const Text('Cerrar sesion'),
          ),
        ],
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.enabled = true,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: Card(
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          leading: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary),
          ),
          title: Text(
            title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 12.5),
          ),
          trailing: const Icon(Icons.chevron_right_rounded,
              color: AppColors.textMuted),
          onTap: enabled ? onTap : null,
        ),
      ),
    );
  }
}
