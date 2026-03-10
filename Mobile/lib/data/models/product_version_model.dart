/// Maps to BE ProductService's ProductVersion entity.
///
/// BE fields: id, versionName
class ProductVersionModel {
  final int id;
  final String versionName;

  const ProductVersionModel({
    required this.id,
    required this.versionName,
  });

  factory ProductVersionModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return ProductVersionModel(
      id: json['id'] as int,
      versionName:
          json['versionName'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'versionName': versionName,
    };
  }
}
