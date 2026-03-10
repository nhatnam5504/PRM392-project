/// Maps to BE UserService's RetrieveAccountResponse + Account entity.
///
/// BE fields: email, password (hashed), fullName, roleName, allPermissions
/// Extra fields (id, phone, avatarUrl, membership*) are kept for UI compat.
class UserModel {
  final int id;
  final String name; // maps from BE "fullName"
  final String email;
  final String? phone;
  final String? avatarUrl;
  final String role; // maps from BE "roleName"
  final bool isActive; // from BE "isActive"
  final List<String> permissions; // maps from BE "allPermissions"
  final int membershipPoints;
  final String membershipTier;
  final DateTime createdAt;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.avatarUrl,
    this.role = 'USER',
    this.isActive = true,
    this.permissions = const [],
    this.membershipPoints = 0,
    this.membershipTier = 'bronze',
    required this.createdAt,
  });

  /// Parse from BE RetrieveAccountResponse JSON.
  /// BE returns: {email, password, fullName, roleName, allPermissions}
  /// We also handle the enriched version that includes id.
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: (json['fullName'] ?? json['name'] ?? '') as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      role: (json['roleName'] ?? json['role'] ?? 'USER') as String,
      isActive: json['isActive'] as bool? ?? json['active'] as bool? ?? true,
      permissions: (json['allPermissions'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      membershipPoints: json['membershipPoints'] as int? ?? 0,
      membershipTier: json['membershipTier'] as String? ?? 'bronze',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': name,
      'email': email,
      'phone': phone,
      'avatarUrl': avatarUrl,
      'roleName': role,
      'isActive': isActive,
      'allPermissions': permissions,
      'membershipPoints': membershipPoints,
      'membershipTier': membershipTier,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Convert to BE CreateAccountRequest format.
  Map<String, dynamic> toCreateAccountRequest({
    required String password,
    required int roleId,
  }) {
    return {
      'email': email,
      'password': password,
      'fullName': name,
      'roleId': roleId,
      'customPermissions': permissions,
    };
  }

  UserModel copyWith({
    int? id,
    String? name,
    String? email,
    String? phone,
    String? avatarUrl,
    String? role,
    bool? isActive,
    List<String>? permissions,
    int? membershipPoints,
    String? membershipTier,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      permissions: permissions ?? this.permissions,
      membershipPoints: membershipPoints ?? this.membershipPoints,
      membershipTier: membershipTier ?? this.membershipTier,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
