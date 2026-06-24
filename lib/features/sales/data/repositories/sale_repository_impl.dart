import '../../domain/entities/sale.dart';
import '../../domain/repositories/sale_repository.dart';
import '../datasources/sale_remote_data_source.dart';

class SaleRepositoryImpl implements SaleRepository {
  SaleRepositoryImpl(this._dataSource);

  final SaleRemoteDataSource _dataSource;

  @override
  Future<List<Sale>> getSales() => _dataSource.getSales();

  @override
  Future<Sale> registerSale(Sale sale) => _dataSource.registerSale(sale);
}
