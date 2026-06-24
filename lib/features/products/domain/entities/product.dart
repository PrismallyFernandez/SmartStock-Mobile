import 'package:equatable/equatable.dart';

/// Producto del catalogo del negocio.
class Product extends Equatable {
  const Product({
    required this.id,
    required this.code,
    required this.name,
    required this.description,
    required this.price,
    required this.cost,
    required this.stock,
    required this.lowStockThreshold,
    required this.category,
  });

  final String id;

  /// Codigo unico del producto (regla de negocio).
  final String code;
  final String name;
  final String description;
  final double price;
  final double cost;
  final int stock;

  /// Umbral por debajo del cual se considera "bajo inventario".
  final int lowStockThreshold;
  final String category;

  bool get isLowStock => stock <= lowStockThreshold;

  Product copyWith({
    String? code,
    String? name,
    String? description,
    double? price,
    double? cost,
    int? stock,
    int? lowStockThreshold,
    String? category,
  }) {
    return Product(
      id: id,
      code: code ?? this.code,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      cost: cost ?? this.cost,
      stock: stock ?? this.stock,
      lowStockThreshold: lowStockThreshold ?? this.lowStockThreshold,
      category: category ?? this.category,
    );
  }

  @override
  List<Object?> get props => [
    id,
    code,
    name,
    description,
    price,
    cost,
    stock,
    lowStockThreshold,
    category,
  ];
}
