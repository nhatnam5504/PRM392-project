/// Maps to BE ProductService's Brand entity.
///
/// BE fields: id, name, description, logoUrl
class BrandModel {
  final int id;
  final String name;
  final String description;
  final String? logoUrl;

  const BrandModel({
    required this.id,
    required this.name,
    this.description = '',
    this.logoUrl,
  });

  factory BrandModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return BrandModel(
      id: json['id'] as int,
      name: json['name'] as String,
      description:
          json['description'] as String? ?? '',
      logoUrl: json['logoUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'logoUrl': logoUrl,
    };
  }
}
