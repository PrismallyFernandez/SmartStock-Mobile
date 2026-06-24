import '../../domain/entities/app_user.dart';

/// Modelo de datos de usuario: traduce de/hacia el formato de la fuente de
/// datos (mapas tipo JSON / documentos Firestore) y la entidad de dominio.
class UserModel extends AppUser {
  const UserModel({
    required super.id,
    required super.name,
    required super.email,
    required super.role,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as String,
      name: map['name'] as String,
      email: map['email'] as String,
      role: UserRole.values.firstWhere(
        (r) => r.name == map['role'],
        orElse: () => UserRole.vendedor,
      ),
    );
  }

  factory UserModel.fromEntity(AppUser user) => UserModel(
    id: user.id,
    name: user.name,
    email: user.email,
    role: user.role,
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'email': email,
    'role': role.name,
  };
}
