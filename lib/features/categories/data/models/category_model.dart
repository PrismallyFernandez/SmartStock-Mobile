import '../../domain/entities/category.dart';

/// Modelo de datos de categoria.
class CategoryModel extends Category {
  const CategoryModel({
    required super.id,
    required super.name,
  });

  factory CategoryModel.fromMap(String id, Map<String, dynamic> map) {
    return CategoryModel(
      id: id,
      name: map['name'] as String? ?? '',
    );
  }

  factory CategoryModel.fromEntity(Category c) => CategoryModel(
    id: c.id,
    name: c.name,
  );

  Map<String, dynamic> toMap() => {
    'name': name,
  };
}
