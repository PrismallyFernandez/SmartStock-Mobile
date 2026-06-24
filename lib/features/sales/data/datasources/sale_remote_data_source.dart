import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/firestore_collections.dart';
import '../../../../core/error/exceptions.dart';
import '../../../inventory/domain/entities/inventory_entry.dart';
import '../../domain/entities/sale.dart';
import '../models/sale_model.dart';

/// Fuente de datos de ventas sobre Cloud Firestore.
///
/// [registerSale] usa una transaccion para garantizar la consistencia entre
/// ventas, productos e inventario (atomicidad real en Firestore).
abstract class SaleRemoteDataSource {
  Future<List<Sale>> getSales();
  Future<Sale> registerSale(Sale sale);
}

class SaleRemoteDataSourceImpl implements SaleRemoteDataSource {
  SaleRemoteDataSourceImpl(this._firestore);

  final FirebaseFirestore _firestore;

  @override
  Future<List<Sale>> getSales() async {
    final snap = await _firestore
        .collection(FirestoreCollections.sales)
        .orderBy('date', descending: true)
        .get();
    return snap.docs.map((d) => SaleModel.fromMap(d.id, d.data())).toList();
  }

  @override
  Future<Sale> registerSale(Sale sale) async {
    if (sale.items.isEmpty) {
      throw BusinessRuleException('La venta no tiene productos.');
    }

    final products = _firestore.collection(FirestoreCollections.products);
    final saleRef = _firestore.collection(FirestoreCollections.sales).doc();
    final entries = _firestore.collection(FirestoreCollections.inventoryEntries);

    await _firestore.runTransaction((txn) async {
      // 1. Leer todos los productos involucrados (las lecturas van primero).
      final snapshots = <String, DocumentSnapshot<Map<String, dynamic>>>{};
      for (final item in sale.items) {
        final ref = products.doc(item.productId);
        final snap = await txn.get(ref);
        if (!snap.exists) {
          throw NotFoundException('Producto no encontrado: ${item.productName}');
        }
        snapshots[item.productId] = snap;
      }

      // 2. Validar stock suficiente (regla de negocio).
      for (final item in sale.items) {
        final stock = (snapshots[item.productId]!.data()!['stock'] as num).toInt();
        if (stock < item.quantity) {
          throw BusinessRuleException(
            'Stock insuficiente de "${item.productName}". '
            'Disponible: $stock, solicitado: ${item.quantity}.',
          );
        }
      }

      // 3. Descontar stock y registrar movimiento de inventario por linea.
      for (final item in sale.items) {
        final stock = (snapshots[item.productId]!.data()!['stock'] as num).toInt();
        txn.update(products.doc(item.productId), {
          'stock': stock - item.quantity,
        });

        final entry = InventoryEntry(
          id: '${saleRef.id}-${item.productId}',
          productId: item.productId,
          productName: item.productName,
          quantity: item.quantity,
          type: MovementType.venta,
          date: sale.date,
          note: 'Venta ${saleRef.id.substring(0, 6).toUpperCase()}',
        );
        txn.set(entries.doc(entry.id), {
          'productId': entry.productId,
          'productName': entry.productName,
          'quantity': entry.quantity,
          'type': entry.type.name,
          'date': Timestamp.fromDate(entry.date),
          'note': entry.note,
        });
      }

      // 4. Guardar la venta.
      txn.set(saleRef, SaleModel.toMap(sale));
    });

    return Sale(
      id: saleRef.id,
      date: sale.date,
      items: sale.items,
      clientId: sale.clientId,
      clientName: sale.clientName,
      sellerId: sale.sellerId,
      sellerName: sale.sellerName,
    );
  }
}
