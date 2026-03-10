import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../models/role_model.dart';
import '../services/api_service.dart';

class RoleRepository {
  final Dio _dio = ApiService().client;

  /// GET /api/users/roles
  Future<List<RoleModel>> getRoles() async {
    final response = await _dio.get(
      ApiConstants.roles,
    );
    return (response.data as List)
        .map((json) => RoleModel.fromJson(
              json as Map<String, dynamic>,
            ))
        .toList();
  }

  /// POST /api/users/roles
  Future<void> createRole({
    required String name,
    required String description,
    required List<String> permissions,
  }) async {
    await _dio.post(
      ApiConstants.roles,
      data: {
        'name': name,
        'description': description,
        'permissions': permissions,
      },
    );
  }

  /// PUT /api/users/roles/{roleId}
  Future<void> updateRole({
    required int roleId,
    required String name,
    required String description,
    required List<String> permissions,
  }) async {
    await _dio.put(
      '${ApiConstants.roles}/$roleId',
      data: {
        'name': name,
        'description': description,
        'permissions': permissions,
      },
    );
  }

  /// DELETE /api/users/roles/{roleId}
  Future<void> deleteRole(int roleId) async {
    await _dio.delete(
      '${ApiConstants.roles}/$roleId',
    );
  }

  /// GET /api/users/roles/permissions
  Future<List<String>> getAllPermissions() async {
    final response = await _dio.get(
      ApiConstants.permissions,
    );
    return (response.data as List)
        .map((e) => e as String)
        .toList();
  }
}
