import '../entities/sale.dart';

/// Contrato del modulo de ventas (RF-11 a RF-13).
abstract class SaleRepository {
  Future<List<Sale>> getSales();

  /// Registra una venta. La implementacion debe, de forma atomica:
  /// 1. Verificar que cada producto tenga stock suficiente
  ///    (regla: no se permite vender con stock insuficiente).
  /// 2. Descontar el stock automaticamente (RF-08).
  /// 3. Registrar el movimiento de inventario correspondiente.
  ///
  /// Lanza [BusinessRuleException] si algun producto no tiene stock.
  Future<Sale> registerSale(Sale sale);

  /// Actualiza campos editables de una venta (cliente y fecha).
  Future<void> updateSale(Sale sale);

  /// Elimina una venta y revierte el stock descontado, atomico.
  Future<void> deleteSale(String id);

  /// Ventas dentro de un rango de fechas (ambos inclusive).
  Future<List<Sale>> getSalesByDateRange(DateTime start, DateTime end);
}
