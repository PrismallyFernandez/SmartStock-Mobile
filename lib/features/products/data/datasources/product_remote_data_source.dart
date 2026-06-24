import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/firestore_collections.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/product.dart';
import '../models/product_model.dart';

/// Fuente de datos de productos sobre Cloud Firestore (coleccion `products`).
abstract class ProductRemoteDataSource {
  Future<List<Product>> getProducts();
  Future<Product> addProduct(Product product);
  Future<Product> updateProduct(Product product);
  Future<void> deleteProduct(String id);
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  ProductRemoteDataSourceImpl(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _col =>
      _firestore.collection(FirestoreCollections.products);

  @override
  Future<List<Product>> getProducts() async {
    final snap = await _col.orderBy('name').get();
    return snap.docs
        .map((d) => ProductModel.fromMap({'id': d.id, ...d.data()}))
        .toList();
  }

  @override
  Future<Product> addProduct(Product product) async {
    await _ensureUniqueCode(product.code);
    await _col.doc(product.id).set(ProductModel.fromEntity(product).toMap());
    return product;
  }

  @override
  Future<Product> updateProduct(Product product) async {
    await _ensureUniqueCode(product.code, exceptId: product.id);
    await _col.doc(product.id).set(ProductModel.fromEntity(product).toMap());
    return product;
  }

  @override
  Future<void> deleteProduct(String id) => _col.doc(id).delete();

  /// Regla de negocio: el codigo de producto debe ser unico.
  Future<void> _ensureUniqueCode(String code, {String? exceptId}) async {
    final query = await _col.where('code', isEqualTo: code).get();
    final clash = query.docs.any((d) => d.id != exceptId);
    if (clash) {
      throw BusinessRuleException(
        'Ya existe un producto con el codigo "$code".',
      );
    }
  }
}
