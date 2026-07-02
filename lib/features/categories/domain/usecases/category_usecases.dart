import '../entities/category.dart';
import '../repositories/category_repository.dart';

/// Casos de uso del modulo de categorias.

class GetCategories {
  GetCategories(this._repo);
  final CategoryRepository _repo;
  Future<List<Category>> call() => _repo.getCategories();
}

class AddCategory {
  AddCategory(this._repo);
  final CategoryRepository _repo;
  Future<Category> call(Category category) => _repo.addCategory(category);
}

class UpdateCategory {
  UpdateCategory(this._repo);
  final CategoryRepository _repo;
  Future<Category> call(Category category) => _repo.updateCategory(category);
}

class DeleteCategory {
  DeleteCategory(this._repo);
  final CategoryRepository _repo;
  Future<void> call(String id) => _repo.deleteCategory(id);
}
