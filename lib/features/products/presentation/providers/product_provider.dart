import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/error/exceptions.dart';
import '../../domain/entities/product.dart';
import '../../domain/usecases/product_usecases.dart';

/// Estado del catalogo de productos.
class ProductProvider extends ChangeNotifier {
  ProductProvider({
    required GetProducts getProducts,
    required AddProduct addProduct,
    required UpdateProduct updateProduct,
    required DeleteProduct deleteProduct,
  }) : _getProducts = getProducts,
       _addProduct = addProduct,
       _updateProduct = updateProduct,
       _deleteProduct = deleteProduct;

  final GetProducts _getProducts;
  final AddProduct _addProduct;
  final UpdateProduct _updateProduct;
  final DeleteProduct _deleteProduct;
  final _uuid = const Uuid();

  List<Product> _products = [];
  bool _isLoading = false;
  String _query = '';

  bool get isLoading => _isLoading;

  List<Product> get products {
    if (_query.isEmpty) return _products;
    final q = _query.toLowerCase();
    return _products
        .where((p) =>
            p.name.toLowerCase().contains(q) ||
            p.code.toLowerCase().contains(q) ||
            p.category.toLowerCase().contains(q))
        .toList();
  }

  List<Product> get lowStockProducts =>
      _products.where((p) => p.isLowStock).toList();

  int get totalProducts => _products.length;

  double get inventoryValue =>
      _products.fold(0, (sum, p) => sum + p.price * p.stock);

  void search(String query) {
    _query = query;
    notifyListeners();
  }

  Future<void> load() async {
    _isLoading = true;
    notifyListeners();
    _products = await _getProducts();
    _isLoading = false;
    notifyListeners();
  }

  /// Crea un producto. Devuelve null si todo bien, o un mensaje de error.
  Future<String?> create({
    required String code,
    required String name,
    required String description,
    required double price,
    required double cost,
    required int stock,
    required int lowStockThreshold,
    required String category,
  }) async {
    try {
      final product = Product(
        id: _uuid.v4(),
        code: code,
        name: name,
        description: description,
        price: price,
        cost: cost,
        stock: stock,
        lowStockThreshold: lowStockThreshold,
        category: category,
      );
      await _addProduct(product);
      await load();
      return null;
    } on BusinessRuleException catch (e) {
      return e.message;
    } catch (_) {
      return 'No se pudo guardar el producto.';
    }
  }

  Future<String?> edit(Product product) async {
    try {
      await _updateProduct(product);
      await load();
      return null;
    } on BusinessRuleException catch (e) {
      return e.message;
    } catch (_) {
      return 'No se pudo actualizar el producto.';
    }
  }

  Future<void> remove(String id) async {
    await _deleteProduct(id);
    await load();
  }
}
