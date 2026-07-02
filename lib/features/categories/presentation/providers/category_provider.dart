import 'package:flutter/foundation.dart' hide Category;
import 'package:uuid/uuid.dart';

import '../../domain/entities/category.dart';
import '../../domain/usecases/category_usecases.dart';

/// Estado del catalogo de categorias.
class CategoryProvider extends ChangeNotifier {
  CategoryProvider({
    required GetCategories getCategories,
    required AddCategory addCategory,
    required UpdateCategory updateCategory,
    required DeleteCategory deleteCategory,
  }) : _getCategories = getCategories,
       _addCategory = addCategory,
       _updateCategory = updateCategory,
       _deleteCategory = deleteCategory;

  final GetCategories _getCategories;
  final AddCategory _addCategory;
  final UpdateCategory _updateCategory;
  final DeleteCategory _deleteCategory;
  final _uuid = const Uuid();

  List<Category> _categories = [];
  bool _isLoading = false;
  String _query = '';

  List<Category> get categories {
    if (_query.isEmpty) return _categories;
    final q = _query.toLowerCase();
    return _categories.where((c) => c.name.toLowerCase().contains(q)).toList();
  }

  List<String> get categoryNames =>
      _categories.map((c) => c.name).toList();

  bool get isLoading => _isLoading;

  void search(String query) {
    _query = query;
    notifyListeners();
  }

  Future<void> load() async {
    _isLoading = true;
    notifyListeners();
    _categories = await _getCategories();
    _isLoading = false;
    notifyListeners();
  }

  Future<String?> create(String name) async {
    try {
      final category = Category(id: _uuid.v4(), name: name.trim());
      await _addCategory(category);
      await load();
      return null;
    } catch (_) {
      return 'No se pudo guardar la categoria.';
    }
  }

  Future<String?> edit(Category category) async {
    try {
      await _updateCategory(category);
      await load();
      return null;
    } catch (_) {
      return 'No se pudo actualizar la categoria.';
    }
  }

  Future<void> remove(String id) async {
    await _deleteCategory(id);
    await load();
  }
}
