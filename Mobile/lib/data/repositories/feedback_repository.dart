import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/api_constants.dart';
import '../../core/constants/app_constants.dart';
import '../models/feedback_model.dart';
import '../models/order_detail_feedback_model.dart';
import '../services/api_service.dart';

class FeedbackRepository {
  final Dio _dio = ApiService().client;

  Future<List<FeedbackModel>> getFeedbacksByProduct(
    int productId,
  ) async {
    final response = await _dio.get(
      '${ApiConstants.productFeedbacks}/$productId',
    );
    final list = response.data as List;
    return list
        .map(
          (json) => FeedbackModel.fromJson(
            json as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  Future<OrderDetailFeedbackModel?> getFeedbackByOrderDetail(
    int orderDetailId,
  ) async {
    try {
      final response = await _dio.get(
        '${ApiConstants.feedbackByOrderDetail}/$orderDetailId',
      );
      if (response.data == null) return null;
      return OrderDetailFeedbackModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 404) {
        return null;
      }
      rethrow;
    }
  }

  Future<void> submitOrderFeedback({
    required int productId,
    required int rating,
    required String comment,
    required int orderDetailId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt(AppConstants.prefUserId);

    if (userId == null) {
      throw Exception('Bạn cần đăng nhập để thực hiện đánh giá.');
    }

    await _dio.post(
      ApiConstants.submitFeedback,
      data: {
        'userId': userId,
        'productId': productId,
        'rating': rating,
        'comment': comment,
        'orderDetailId': orderDetailId,
      },
    );
  }
}

