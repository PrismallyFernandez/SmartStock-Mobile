import '../../domain/entities/product.dart';

/// Modelo de datos de producto (mapeo hacia/desde la fuente de datos).
class ProductModel extends Product {
  const ProductModel({
    required super.id,
    required super.code,
    required super.name,
    required super.description,
    required super.price,
    required super.cost,
    required super.stock,
    required super.lowStockThreshold,
    required super.category,
  });

  factory ProductModel.fromEntity(Product p) => ProductModel(
    id: p.id,
    code: p.code,
    name: p.name,
    description: p.description,
    price: p.price,
    cost: p.cost,
    stock: p.stock,
    lowStockThreshold: p.lowStockThreshold,
    category: p.category,
  );

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: map['id'] as String,
      code: map['code'] as String,
      name: map['name'] as String,
      description: map['description'] as String? ?? '',
      price: (map['price'] as num).toDouble(),
      cost: (map['cost'] as num).toDouble(),
      stock: (map['stock'] as num).toInt(),
      lowStockThreshold: (map['lowStockThreshold'] as num).toInt(),
      category: map['category'] as String? ?? 'General',
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'code': code,
    'name': name,
    'description': description,
    'price': price,
    'cost': cost,
    'stock': stock,
    'lowStockThreshold': lowStockThreshold,
    'category': category,
  };
}
