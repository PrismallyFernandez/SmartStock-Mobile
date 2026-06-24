import '../../../products/domain/entities/product.dart';
import '../../domain/entities/inventory_entry.dart';
import '../../domain/repositories/inventory_repository.dart';
import '../datasources/inventory_remote_data_source.dart';

class InventoryRepositoryImpl implements InventoryRepository {
  InventoryRepositoryImpl(this._dataSource);

  final InventoryRemoteDataSource _dataSource;

  @override
  Future<List<InventoryEntry>> getEntries() => _dataSource.getEntries();

  @override
  Future<void> registerEntry({
    required String productId,
    required int quantity,
    required String note,
  }) =>
      _dataSource.registerEntry(
        productId: productId,
        quantity: quantity,
        note: note,
      );

  @override
  Future<List<Product>> getLowStockProducts() =>
      _dataSource.getLowStockProducts();
}
