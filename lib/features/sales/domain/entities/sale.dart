import 'package:equatable/equatable.dart';

/// Linea de detalle de una venta.
class SaleItem extends Equatable {
  const SaleItem({
    required this.productId,
    required this.productName,
    required this.unitPrice,
    required this.quantity,
  });

  final String productId;
  final String productName;
  final double unitPrice;
  final int quantity;

  double get subtotal => unitPrice * quantity;

  @override
  List<Object?> get props => [productId, productName, unitPrice, quantity];
}

/// Venta registrada en el sistema.
class Sale extends Equatable {
  const Sale({
    required this.id,
    required this.date,
    required this.items,
    required this.clientId,
    required this.clientName,
    required this.sellerId,
    required this.sellerName,
  });

  final String id;
  final DateTime date;
  final List<SaleItem> items;
  final String? clientId;
  final String clientName;
  final String sellerId;
  final String sellerName;

  /// Total calculado automaticamente (RF-12).
  double get total => items.fold(0, (sum, item) => sum + item.subtotal);

  int get totalUnits => items.fold(0, (sum, item) => sum + item.quantity);

  @override
  List<Object?> get props => [
    id,
    date,
    items,
    clientId,
    clientName,
    sellerId,
    sellerName,
  ];
}
