// Excepciones lanzadas por la capa de datos.
// Los repositorios las capturan y las traducen a `Failure` para el dominio.

/// La fuente de datos no encontro el recurso solicitado.
class NotFoundException implements Exception {
  NotFoundException(this.message);
  final String message;
}

/// Las credenciales proporcionadas no son validas.
class InvalidCredentialsException implements Exception {
  InvalidCredentialsException(this.message);
  final String message;
}

/// Se violo una regla de negocio en la capa de datos
/// (por ejemplo, codigo de producto duplicado o stock insuficiente).
class BusinessRuleException implements Exception {
  BusinessRuleException(this.message);
  final String message;
}
