/// Maps to BE ProductService's Category entity.
///
/// BE fields: id, name, description
/// Extra UI fields (slug, iconName, parentId, productCount) kept for compat.
class CategoryModel {
  final int id;
  final String name;
  final String description; // from BE
  final String slug;
  final String iconName;
  final int? parentId;
  final int productCount;

  const CategoryModel({
    required this.id,
    required this.name,
    this.description = '',
    this.slug = '',
    this.iconName = 'category',
    this.parentId,
    this.productCount = 0,
  });

  /// Parse from BE Category JSON: {id, name, description}
  factory CategoryModel.fromJson(
    Map<String, dynamic> json,
  ) {
    final name = json['name'] as String;
    return CategoryModel(
      id: json['id'] as int,
      name: name,
      description:
          json['description'] as String? ?? '',
      slug: json['slug'] as String? ??
          name
              .toLowerCase()
              .replaceAll(RegExp(r'[^a-z0-9]+'), '-'),
      iconName:
          json['iconName'] as String? ?? 'category',
      parentId: json['parentId'] as int?,
      productCount:
          json['productCount'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
    };
  }
}
