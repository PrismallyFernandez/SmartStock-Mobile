import 'package:equatable/equatable.dart';

/// Cliente del negocio.
class Client extends Equatable {
  const Client({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.address,
  });

  final String id;
  final String name;
  final String phone;
  final String email;
  final String address;

  Client copyWith({
    String? name,
    String? phone,
    String? email,
    String? address,
  }) {
    return Client(
      id: id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
    );
  }

  @override
  List<Object?> get props => [id, name, phone, email, address];
}
