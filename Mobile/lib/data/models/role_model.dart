/// Maps to BE UserService's Role entity.
///
/// BE fields: id, name, description, permissions
class RoleModel {
  final int id;
  final String name;
  final String description;
  final List<String> permissions;

  const RoleModel({
    required this.id,
    required this.name,
    this.description = '',
    this.permissions = const [],
  });

  factory RoleModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return RoleModel(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      description:
          json['description'] as String? ?? '',
      permissions:
          (json['permissions'] as List<dynamic>?)
                  ?.map((e) => e as String)
                  .toList() ??
              [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'permissions': permissions,
    };
  }
}
