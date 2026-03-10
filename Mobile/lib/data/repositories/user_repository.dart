import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/api_constants.dart';
import '../../core/constants/app_constants.dart';
import '../dummy_data.dart';
import '../models/user_model.dart';
import '../models/address_model.dart';
import '../services/api_service.dart';

class UserRepository {
  final Dio _dio = ApiService().client;
  bool _useDummyData = false;

  /// Map role name to roleId based on BE data
  int _roleNameToId(String roleName) {
    switch (roleName.toUpperCase()) {
      case 'SUPER ADMIN':
        return 4;
      case 'ADMIN':
        return 3;
      case 'STAFF':
        return 2;
      case 'USER':
      default:
        return 1;
    }
  }

  /// GET /api/users — list all accounts (paginated)
  /// BE now returns Page<RetrieveAccountResponse> with 'content' array
  Future<List<UserModel>> getAllUsers({
    int page = 0,
    int size = 10,
    List<String>? roles,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'size': size,
      };
      if (roles != null && roles.isNotEmpty) {
        queryParams['roles'] = roles;
      }
      final response = await _dio.get(
        ApiConstants.users,
        queryParameters: queryParams,
      );
      final data = response.data;
      List<dynamic> usersList;
      if (data is Map<String, dynamic> && data.containsKey('content')) {
        usersList = data['content'] as List;
      } else if (data is List) {
        usersList = data;
      } else {
        return [];
      }
      return usersList
          .map((json) => UserModel.fromJson(
                json as Map<String, dynamic>,
              ))
          .toList();
    } catch (e) {
      if (_useDummyData) {
        await Future.delayed(
          const Duration(milliseconds: 400),
        );
        return [DummyData.user];
      }
      rethrow;
    }
  }

  /// GET /api/users/{id}
  /// BE now returns id in RetrieveAccountResponse.
  Future<UserModel> getProfile({int? userId}) async {
    try {
      if (userId != null && userId > 0) {
        final response = await _dio.get(
          '${ApiConstants.userById}/$userId',
        );
        final json = response.data as Map<String, dynamic>;
        return UserModel.fromJson(json);
      }
      // Fallback: use saved userId from prefs
      final prefs = await SharedPreferences.getInstance();
      final savedId = prefs.getInt(
        AppConstants.prefUserId,
      );
      if (savedId != null && savedId > 0) {
        final response = await _dio.get(
          '${ApiConstants.userById}/$savedId',
        );
        final json = response.data as Map<String, dynamic>;
        return UserModel.fromJson(json);
      }
      throw Exception('No user found');
    } catch (e) {
      if (_useDummyData) {
        await Future.delayed(
          const Duration(milliseconds: 400),
        );
        return DummyData.user;
      }
      rethrow;
    }
  }

  /// POST /api/users — create account
  Future<void> createUser({
    required String email,
    required String password,
    required String fullName,
    required int roleId,
    List<String>? customPermissions,
  }) async {
    try {
      await _dio.post(
        ApiConstants.users,
        data: {
          'email': email,
          'password': password,
          'fullName': fullName,
          'roleId': roleId,
          'customPermissions': customPermissions ?? [],
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  /// PUT /api/users/{id} — update account
  /// BE uses FULL REPLACE — must send all fields:
  /// {email, password, fullName, roleId, customPermissions}
  Future<UserModel> updateProfile({
    required int userId,
    String? name,
    String? phone,
    String? email,
    String? password,
    int? roleId,
  }) async {
    try {
      // Get current saved data for full replace
      final prefs = await SharedPreferences.getInstance();
      final currentEmail = prefs.getString(
            AppConstants.prefUserEmail,
          ) ??
          '';
      final currentPassword = prefs.getString(
            AppConstants.prefUserPassword,
          ) ??
          '';
      final currentName = prefs.getString(
            AppConstants.prefUserName,
          ) ??
          '';

      // Map role name to roleId
      final currentRole = prefs.getString(
            AppConstants.prefUserRole,
          ) ??
          'USER';
      final resolvedRoleId = roleId ?? _roleNameToId(currentRole);

      final newEmail = email ?? currentEmail;
      final newPassword = password ?? currentPassword;
      final newName = name ?? currentName;

      // Full replace request body
      final data = {
        'email': newEmail,
        'password': newPassword,
        'fullName': newName,
        'roleId': resolvedRoleId,
        'customPermissions': <String>[],
      };

      await _dio.put(
        '${ApiConstants.userById}/$userId',
        data: data,
      );

      // Update saved prefs
      await prefs.setString(
        AppConstants.prefUserEmail,
        newEmail,
      );
      if (password != null) {
        await prefs.setString(
          AppConstants.prefUserPassword,
          newPassword,
        );
      }
      await prefs.setString(
        AppConstants.prefUserName,
        newName,
      );

      // BE returns void, re-fetch profile
      return getProfile(userId: userId);
    } catch (e) {
      if (_useDummyData) {
        await Future.delayed(
          const Duration(milliseconds: 500),
        );
        return DummyData.user.copyWith(
          name: name,
          phone: phone,
          email: email,
        );
      }
      rethrow;
    }
  }

  /// DELETE /api/users/{id}
  Future<void> deleteUser(int userId) async {
    try {
      await _dio.delete(
        '${ApiConstants.userById}/$userId',
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    // BE doesn't have a dedicated change-password
    // endpoint. This is a placeholder.
    await Future.delayed(
      const Duration(milliseconds: 500),
    );
  }

  Future<List<AddressModel>> getAddresses() async {
    // BE doesn't have address endpoints.
    // Use dummy data for now.
    await Future.delayed(
      const Duration(milliseconds: 300),
    );
    return DummyData.addresses;
  }

  Future<AddressModel> addAddress(
    AddressModel address,
  ) async {
    await Future.delayed(
      const Duration(milliseconds: 500),
    );
    return address;
  }

  Future<void> deleteAddress(int addressId) async {
    await Future.delayed(
      const Duration(milliseconds: 300),
    );
  }
}
