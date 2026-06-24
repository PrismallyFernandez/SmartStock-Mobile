import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/firestore_collections.dart';
import '../../../../core/error/exceptions.dart';
import '../../../products/data/models/product_model.dart';
import '../../../products/domain/entities/product.dart';
import '../../domain/entities/inventory_entry.dart';

/// Fuente de datos de inventario sobre Cloud Firestore.
abstract class InventoryRemoteDataSource {
  Future<List<InventoryEntry>> getEntries();
  Future<void> registerEntry({
    required String productId,
    required int quantity,
    required String note,
  });
  Future<List<Product>> getLowStockProducts();
}

class InventoryRemoteDataSourceImpl implements InventoryRemoteDataSource {
  InventoryRemoteDataSourceImpl(this._firestore);

  final FirebaseFirestore _firestore;

  @override
  Future<List<InventoryEntry>> getEntries() async {
    final snap = await _firestore
        .collection(FirestoreCollections.inventoryEntries)
        .orderBy('date', descending: true)
        .get();
    return snap.docs.map((d) => _entryFromMap(d.id, d.data())).toList();
  }

  @override
  Future<void> registerEntry({
    required String productId,
    required int quantity,
    required String note,
  }) async {
    if (quantity <= 0) {
      throw BusinessRuleException('La cantidad debe ser mayor a cero.');
    }

    final productRef =
        _firestore.collection(FirestoreCollections.products).doc(productId);
    final entryRef =
        _firestore.collection(FirestoreCollections.inventoryEntries).doc();

    await _firestore.runTransaction((txn) async {
      final snap = await txn.get(productRef);
      if (!snap.exists) throw NotFoundException('El producto no existe.');

      final data = snap.data()!;
      final stock = (data['stock'] as num).toInt();
      final productName = data['name'] as String? ?? '';

      txn.update(productRef, {'stock': stock + quantity});
      txn.set(entryRef, {
        'productId': productId,
        'productName': productName,
        'quantity': quantity,
        'type': MovementType.entrada.name,
        'date': Timestamp.fromDate(DateTime.now()),
        'note': note.isEmpty ? 'Entrada de inventario' : note,
      });
    });
  }

  @override
  Future<List<Product>> getLowStockProducts() async {
    // Firestore no permite comparar dos campos; se filtra en memoria.
    final snap =
        await _firestore.collection(FirestoreCollections.products).get();
    return snap.docs
        .map((d) => ProductModel.fromMap({'id': d.id, ...d.data()}))
        .where((p) => p.isLowStock)
        .toList();
  }

  InventoryEntry _entryFromMap(String id, Map<String, dynamic> map) {
    return InventoryEntry(
      id: id,
      productId: map['productId'] as String,
      productName: map['productName'] as String? ?? '',
      quantity: (map['quantity'] as num).toInt(),
      type: MovementType.values.firstWhere(
        (t) => t.name == map['type'],
        orElse: () => MovementType.entrada,
      ),
      date: (map['date'] as Timestamp).toDate(),
      note: map['note'] as String? ?? '',
    );
  }
}
