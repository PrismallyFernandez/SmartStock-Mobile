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
  Future<void> updateSale(Sale sale);
  Future<void> deleteSale(String id);
  Future<List<Sale>> getSalesByDateRange(DateTime start, DateTime end);
}

class SaleRemoteDataSourceImpl implements SaleRemoteDataSource {
  SaleRemoteDataSourceImpl(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _salesCol =>
      _firestore.collection(FirestoreCollections.sales);

  CollectionReference<Map<String, dynamic>> get _productsCol =>
      _firestore.collection(FirestoreCollections.products);

  CollectionReference<Map<String, dynamic>> get _entriesCol =>
      _firestore.collection(FirestoreCollections.inventoryEntries);

  @override
  Future<List<Sale>> getSales() async {
    final snap = await _salesCol.orderBy('date', descending: true).get();
    return snap.docs.map((d) => SaleModel.fromMap(d.id, d.data())).toList();
  }

  @override
  Future<Sale> registerSale(Sale sale) async {
    if (sale.items.isEmpty) {
      throw BusinessRuleException('La venta no tiene productos.');
    }

    final saleRef = _salesCol.doc();

    await _firestore.runTransaction((txn) async {
      // 1. Leer todos los productos involucrados (las lecturas van primero).
      final snapshots = <String, DocumentSnapshot<Map<String, dynamic>>>{};
      for (final item in sale.items) {
        final ref = _productsCol.doc(item.productId);
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
        txn.update(_productsCol.doc(item.productId), {
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
        txn.set(_entriesCol.doc(entry.id), {
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

  @override
  Future<void> updateSale(Sale sale) async {
    await _salesCol.doc(sale.id).update({
      'clientId': sale.clientId,
      'clientName': sale.clientName,
      'date': Timestamp.fromDate(sale.date),
    });
  }

  @override
  Future<void> deleteSale(String id) async {
    await _firestore.runTransaction((txn) async {
      final saleSnap = await txn.get(_salesCol.doc(id));
      if (!saleSnap.exists) throw NotFoundException('Venta no encontrada.');

      final sale = SaleModel.fromMap(id, saleSnap.data()!);

      // Leer productos involucrados para restaurar stock.
      final productSnaps = <String, DocumentSnapshot<Map<String, dynamic>>>{};
      for (final item in sale.items) {
        final ref = _productsCol.doc(item.productId);
        productSnaps[item.productId] = await txn.get(ref);
      }

      // Restaurar stock y eliminar entradas de inventario.
      for (final item in sale.items) {
        final snap = productSnaps[item.productId];
        if (snap != null && snap.exists) {
          final stock = (snap.data()!['stock'] as num).toInt();
          txn.update(_productsCol.doc(item.productId), {
            'stock': stock + item.quantity,
          });
        }
        txn.delete(_entriesCol.doc('$id-${item.productId}'));
      }

      // Eliminar la venta.
      txn.delete(_salesCol.doc(id));
    });
  }

  @override
  Future<List<Sale>> getSalesByDateRange(DateTime start, DateTime end) async {
    final snap = await _salesCol
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(end))
        .orderBy('date', descending: true)
        .get();
    return snap.docs.map((d) => SaleModel.fromMap(d.id, d.data())).toList();
  }
}
