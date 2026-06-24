import '../entities/product.dart';

/// Contrato del catalogo de productos (RF-04 a RF-07).
abstract class ProductRepository {
  Future<List<Product>> getProducts();

  /// Registra un producto nuevo. Lanza [BusinessRuleException] si el codigo
  /// ya existe (regla: codigo unico de producto).
  Future<Product> addProduct(Product product);

  Future<Product> updateProduct(Product product);

  Future<void> deleteProduct(String id);
}
