import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/api_constants.dart';
import '../../core/constants/app_constants.dart';
import '../models/user_order_model.dart';
import '../services/api_service.dart';

class OrderRepository {
  final Dio _dio = ApiService().client;

  Future<int?> _getSavedUserId() async {
    final prefs =
        await SharedPreferences.getInstance();
    return prefs.getInt(AppConstants.prefUserId);
  }

  /// GET /api/orders/user/{userId}
  Future<List<UserOrderModel>> getUserOrders() async {
    final userId = await _getSavedUserId();
    if (userId == null) {
      throw Exception(
        'Chưa đăng nhập. Vui lòng đăng nhập lại.',
      );
    }

    final response = await _dio.get(
      ApiConstants.userOrders(userId),
    );

    final list = response.data as List<dynamic>;
    return list
        .map(
          (json) => UserOrderModel.fromJson(
            json as Map<String, dynamic>,
          ),
        )
        .toList();
  }
}
