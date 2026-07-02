import '../../domain/entities/category.dart';
import '../../domain/repositories/category_repository.dart';
import '../datasources/category_remote_data_source.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  CategoryRepositoryImpl(this._dataSource);

  final CategoryRemoteDataSource _dataSource;

  @override
  Future<List<Category>> getCategories() => _dataSource.getCategories();

  @override
  Future<Category> addCategory(Category category) =>
      _dataSource.addCategory(category);

  @override
  Future<Category> updateCategory(Category category) =>
      _dataSource.updateCategory(category);

  @override
  Future<void> deleteCategory(String id) => _dataSource.deleteCategory(id);
}
