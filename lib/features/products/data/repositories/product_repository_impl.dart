import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_remote_data_source.dart';

class ProductRepositoryImpl implements ProductRepository {
  ProductRepositoryImpl(this._dataSource);

  final ProductRemoteDataSource _dataSource;

  @override
  Future<List<Product>> getProducts() => _dataSource.getProducts();

  @override
  Future<Product> addProduct(Product product) =>
      _dataSource.addProduct(product);

  @override
  Future<Product> updateProduct(Product product) =>
      _dataSource.updateProduct(product);

  @override
  Future<void> deleteProduct(String id) => _dataSource.deleteProduct(id);
}
