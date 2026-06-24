import '../../domain/entities/client.dart';

/// Modelo de datos de cliente (mapeo hacia/desde la fuente de datos).
class ClientModel extends Client {
  const ClientModel({
    required super.id,
    required super.name,
    required super.phone,
    required super.email,
    required super.address,
  });

  factory ClientModel.fromEntity(Client c) => ClientModel(
    id: c.id,
    name: c.name,
    phone: c.phone,
    email: c.email,
    address: c.address,
  );

  factory ClientModel.fromMap(Map<String, dynamic> map) {
    return ClientModel(
      id: map['id'] as String,
      name: map['name'] as String,
      phone: map['phone'] as String? ?? '',
      email: map['email'] as String? ?? '',
      address: map['address'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'phone': phone,
    'email': email,
    'address': address,
  };
}
