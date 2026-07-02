import '../entities/category.dart';

/// Contrato del modulo de categorias.
abstract class CategoryRepository {
  Future<List<Category>> getCategories();
  Future<Category> addCategory(Category category);
  Future<Category> updateCategory(Category category);
  Future<void> deleteCategory(String id);
}
