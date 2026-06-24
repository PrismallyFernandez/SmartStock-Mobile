import 'package:equatable/equatable.dart';

/// Representa un fallo controlado en la capa de dominio/presentacion.
///
/// Las capas superiores reciben [Failure] en lugar de excepciones crudas,
/// manteniendo el dominio desacoplado de los detalles de la fuente de datos.
abstract class Failure extends Equatable {
  const Failure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

/// Fallo relacionado con la fuente de datos (local o remota).
class DataFailure extends Failure {
  const DataFailure(super.message);
}

/// Fallo por violacion de una regla de negocio.
class BusinessFailure extends Failure {
  const BusinessFailure(super.message);
}

/// Fallo de autenticacion (credenciales invalidas, sesion, etc.).
class AuthFailure extends Failure {
  const AuthFailure(super.message);
}
