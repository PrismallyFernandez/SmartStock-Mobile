import '../entities/sale.dart';
import '../repositories/sale_repository.dart';

/// Casos de uso del modulo de ventas.

class GetSales {
  GetSales(this._repo);
  final SaleRepository _repo;
  Future<List<Sale>> call() => _repo.getSales();
}

class RegisterSale {
  RegisterSale(this._repo);
  final SaleRepository _repo;
  Future<Sale> call(Sale sale) => _repo.registerSale(sale);
}
