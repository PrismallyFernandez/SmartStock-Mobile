import 'package:equatable/equatable.dart';

/// Clases de usuario definidas en el documento de requerimientos (seccion 5).
enum UserRole {
  administrador,
  vendedor,
  encargadoInventario;

  String get label {
    switch (this) {
      case UserRole.administrador:
        return 'Administrador';
      case UserRole.vendedor:
        return 'Vendedor';
      case UserRole.encargadoInventario:
        return 'Encargado de inventario';
    }
  }

  /// Solo el administrador puede visualizar reportes (regla de negocio).
  bool get canViewReports => this == UserRole.administrador;

  /// Administrador y encargado de inventario gestionan existencias.
  bool get canManageInventory =>
      this == UserRole.administrador || this == UserRole.encargadoInventario;
}

/// Usuario del sistema.
class AppUser extends Equatable {
  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  final String id;
  final String name;
  final String email;
  final UserRole role;

  @override
  List<Object?> get props => [id, name, email, role];
}
