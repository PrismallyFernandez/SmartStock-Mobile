import '../../../products/domain/entities/product.dart';
import '../entities/inventory_entry.dart';

/// Contrato del modulo de inventario (RF-08 a RF-10).
abstract class InventoryRepository {
  /// Historial de movimientos de inventario (entradas y salidas por venta).
  Future<List<InventoryEntry>> getEntries();

  /// Registra una entrada de inventario y aumenta el stock del producto
  /// (RF-10).
  Future<void> registerEntry({
    required String productId,
    required int quantity,
    required String note,
  });

  /// Productos por debajo de su umbral de stock (RF-09).
  Future<List<Product>> getLowStockProducts();
}
