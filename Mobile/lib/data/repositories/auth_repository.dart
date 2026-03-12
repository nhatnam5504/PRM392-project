import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/api_constants.dart';
import '../../core/constants/app_constants.dart';
import '../dummy_data.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';

class AuthRepository {
  final Dio _dio = ApiService().client;
  bool _useDummyData = false;

  /// Login via POST /api/users/auth/login
  /// BE returns LoginResponse: {token, type, message, role, ttl, expiresIn}
  /// Then fetch user profile using the token.
  Future<UserModel> login(
    String identifier,
    String password,
  ) async {
    try {
      // Step 1: Authenticate via POST /api/users/auth/login
      final loginResponse = await _dio.post(
        ApiConstants.authLogin,
        data: {
          'email': identifier,
          'password': password,
        },
      );
      final loginData = loginResponse.data as Map<String, dynamic>;

      final token = loginData['token'] as String;
      final role = loginData['role'] as String? ?? 'USER';

      // Save token immediately so subsequent requests are authenticated
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        AppConstants.prefAuthToken,
        token,
      );

      // Step 2: Fetch all users to find the logged-in user by email
      // (GET /api/users now returns Page with 'content' array)
      final usersResponse = await _dio.get(
        ApiConstants.users,
        queryParameters: {'size': 100},
      );
      final usersData = usersResponse.data;
      List<dynamic> usersList;
      if (usersData is Map<String, dynamic> &&
          usersData.containsKey('content')) {
        usersList = usersData['content'] as List;
      } else if (usersData is List) {
        usersList = usersData;
      } else {
        throw Exception('Unexpected users response format');
      }

      Map<String, dynamic>? userJson;
      for (final item in usersList) {
        final json = item as Map<String, dynamic>;
        if ((json['email'] as String).toLowerCase() ==
            identifier.toLowerCase()) {
          userJson = json;
          break;
        }
      }

      if (userJson == null) {
        throw Exception(
          'Đăng nhập thành công nhưng không tìm thấy thông tin tài khoản',
        );
      }

      final user = UserModel.fromJson(userJson);

      // Save session
      await prefs.setBool(
        AppConstants.prefIsLoggedIn,
        true,
      );
      await prefs.setInt(
        AppConstants.prefUserId,
        user.id,
      );
      await prefs.setString(
        AppConstants.prefUserName,
        user.name,
      );
      await prefs.setString(
        AppConstants.prefUserEmail,
        user.email,
      );
      await prefs.setString(
        AppConstants.prefUserPassword,
        password,
      );
      await prefs.setString(
        AppConstants.prefUserRole,
        role,
      );
      return user;
    } catch (e) {
      if (e is DioException) {
        final msg = e.error?.toString() ?? e.message ?? 'Lỗi không xác định';
        throw Exception(msg);
      }
      if (_useDummyData) {
        await Future.delayed(
          const Duration(milliseconds: 800),
        );
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(
          AppConstants.prefIsLoggedIn,
          true,
        );
        await prefs.setString(
          AppConstants.prefAuthToken,
          'dummy_token_123',
        );
        await prefs.setInt(
          AppConstants.prefUserId,
          DummyData.user.id,
        );
        await prefs.setString(
          AppConstants.prefUserName,
          DummyData.user.name,
        );
        return DummyData.user;
      }
      rethrow;
    }
  }

  /// Register by creating account via POST /api/users
  Future<UserModel> register({
    required String name,
    required String phone,
    required String email,
    required String password,
  }) async {
    try {
      await _dio.post(
        ApiConstants.users,
        data: {
          'email': email,
          'password': password,
          'fullName': name,
          'roleId': 1, // default USER role
          'customPermissions': [],
        },
      );

      // After creating, login to get the user data
      return login(email, password);
    } catch (e) {
      if (_useDummyData) {
        await Future.delayed(
          const Duration(milliseconds: 800),
        );
        return DummyData.user;
      }
      rethrow;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.prefAuthToken);
    await prefs.remove(AppConstants.prefUserId);
    await prefs.remove(AppConstants.prefUserName);
    await prefs.remove(AppConstants.prefUserEmail);
    await prefs.remove(AppConstants.prefUserPassword);
    await prefs.remove(AppConstants.prefUserRole);
    await prefs.setBool(
      AppConstants.prefIsLoggedIn,
      false,
    );
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(
          AppConstants.prefIsLoggedIn,
        ) ??
        false;
  }

  Future<void> forgotPassword(
    String emailOrPhone,
  ) async {
    await Future.delayed(
      const Duration(milliseconds: 500),
    );
  }

  Future<bool> verifyOtp(String otp) async {
    await Future.delayed(
      const Duration(milliseconds: 500),
    );
    return otp == '123456';
  }

  Future<void> resetPassword(
    String newPassword,
  ) async {
    await Future.delayed(
      const Duration(milliseconds: 500),
    );
  }
}
