import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/api_constants.dart';
import '../../core/constants/app_constants.dart';
import '../models/check_available_model.dart';
import '../models/promotion_model.dart';
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

  Future<CheckAvailableResponse> checkAvailable(
    CheckAvailableRequest request,
  ) async {
    final response = await _dio.post(
      ApiConstants.checkAvailable,
      data: request.toJson(),
    );
    return CheckAvailableResponse.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  Future<PromotionModel> getPromotionByCode(
    String code,
  ) async {
    final response = await _dio.get(
      '${ApiConstants.orderPromotionByCode}/$code',
    );
    return PromotionModel.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  Future<String> makePayment({
    required String orderCode,
    String? promotionCode,
  }) async {
    final response = await _dio.post(
      ApiConstants.makePayment,
      queryParameters: {
        'orderCode': orderCode,
        if (promotionCode != null && promotionCode.isNotEmpty)
          'promotionCode': promotionCode,
      },
    );

    if (response.data is String) {
      return response.data as String;
    }
    if (response.data is Map<String, dynamic>) {
      final data = response.data as Map<String, dynamic>;
      if (data['paymentUrl'] is String) {
        return data['paymentUrl'] as String;
      }
      if (data['url'] is String) {
        return data['url'] as String;
      }
    }
    throw Exception('Không lấy được liên kết thanh toán.');
  }
}
