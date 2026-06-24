import 'package:equatable/equatable.dart';

/// Tipo de movimiento de inventario.
enum MovementType {
  entrada,
  venta;

  String get label => this == MovementType.entrada ? 'Entrada' : 'Venta';
}

/// Movimiento de inventario (entrada de mercancia o salida por venta).
///
/// Registra el historial que ajusta el stock de un producto (RF-10).
class InventoryEntry extends Equatable {
  const InventoryEntry({
    required this.id,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.type,
    required this.date,
    required this.note,
  });

  final String id;
  final String productId;
  final String productName;

  /// Cantidad del movimiento (positiva). El [type] indica el sentido.
  final int quantity;
  final MovementType type;
  final DateTime date;
  final String note;

  @override
  List<Object?> get props => [
    id,
    productId,
    productName,
    quantity,
    type,
    date,
    note,
  ];
}
