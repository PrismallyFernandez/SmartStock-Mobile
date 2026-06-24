import '../../../products/domain/entities/product.dart';
import '../entities/inventory_entry.dart';
import '../repositories/inventory_repository.dart';

/// Casos de uso del modulo de inventario.

class GetInventoryEntries {
  GetInventoryEntries(this._repo);
  final InventoryRepository _repo;
  Future<List<InventoryEntry>> call() => _repo.getEntries();
}

class RegisterStockEntry {
  RegisterStockEntry(this._repo);
  final InventoryRepository _repo;
  Future<void> call({
    required String productId,
    required int quantity,
    required String note,
  }) =>
      _repo.registerEntry(productId: productId, quantity: quantity, note: note);
}

class GetLowStockProducts {
  GetLowStockProducts(this._repo);
  final InventoryRepository _repo;
  Future<List<Product>> call() => _repo.getLowStockProducts();
}
