import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/firestore_collections.dart';
import '../../domain/entities/category.dart';
import '../models/category_model.dart';

/// Fuente de datos de categorias sobre Cloud Firestore.
abstract class CategoryRemoteDataSource {
  Future<List<Category>> getCategories();
  Future<Category> addCategory(Category category);
  Future<Category> updateCategory(Category category);
  Future<void> deleteCategory(String id);
}

class CategoryRemoteDataSourceImpl implements CategoryRemoteDataSource {
  CategoryRemoteDataSourceImpl(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _col =>
      _firestore.collection(FirestoreCollections.categories);

  @override
  Future<List<Category>> getCategories() async {
    final snap = await _col.orderBy('name').get();
    return snap.docs
        .map((d) => CategoryModel.fromMap(d.id, d.data()))
        .toList();
  }

  @override
  Future<Category> addCategory(Category category) async {
    await _col.doc(category.id).set(CategoryModel.fromEntity(category).toMap());
    return category;
  }

  @override
  Future<Category> updateCategory(Category category) async {
    await _col.doc(category.id).set(CategoryModel.fromEntity(category).toMap());
    return category;
  }

  @override
  Future<void> deleteCategory(String id) => _col.doc(id).delete();
}
