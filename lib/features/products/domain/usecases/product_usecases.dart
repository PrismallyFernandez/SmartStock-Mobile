import '../entities/product.dart';
import '../repositories/product_repository.dart';

/// Casos de uso del modulo de productos (RF-04 a RF-07).
/// Se agrupan por feature; cada operacion es una clase independiente.

class GetProducts {
  GetProducts(this._repo);
  final ProductRepository _repo;
  Future<List<Product>> call() => _repo.getProducts();
}

class AddProduct {
  AddProduct(this._repo);
  final ProductRepository _repo;
  Future<Product> call(Product product) => _repo.addProduct(product);
}

class UpdateProduct {
  UpdateProduct(this._repo);
  final ProductRepository _repo;
  Future<Product> call(Product product) => _repo.updateProduct(product);
}

class DeleteProduct {
  DeleteProduct(this._repo);
  final ProductRepository _repo;
  Future<void> call(String id) => _repo.deleteProduct(id);
}
