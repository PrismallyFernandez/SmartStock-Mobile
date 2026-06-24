import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/sale.dart';

/// Modelo de datos de venta: mapea hacia/desde documentos de Firestore.
class SaleModel {
  const SaleModel._();

  static Map<String, dynamic> toMap(Sale sale) => {
    'date': Timestamp.fromDate(sale.date),
    'clientId': sale.clientId,
    'clientName': sale.clientName,
    'sellerId': sale.sellerId,
    'sellerName': sale.sellerName,
    'total': sale.total,
    'items': sale.items
        .map((i) => {
              'productId': i.productId,
              'productName': i.productName,
              'unitPrice': i.unitPrice,
              'quantity': i.quantity,
            })
        .toList(),
  };

  static Sale fromMap(String id, Map<String, dynamic> map) {
    final items = (map['items'] as List<dynamic>? ?? [])
        .map((raw) {
          final m = raw as Map<String, dynamic>;
          return SaleItem(
            productId: m['productId'] as String,
            productName: m['productName'] as String,
            unitPrice: (m['unitPrice'] as num).toDouble(),
            quantity: (m['quantity'] as num).toInt(),
          );
        })
        .toList();

    return Sale(
      id: id,
      date: (map['date'] as Timestamp).toDate(),
      items: items,
      clientId: map['clientId'] as String?,
      clientName: map['clientName'] as String? ?? 'Cliente general',
      sellerId: map['sellerId'] as String? ?? '',
      sellerName: map['sellerName'] as String? ?? '',
    );
  }
}
