import 'package:dio/dio.dart';

import '../../core/constants/api_constants.dart';
import '../models/feedback_model.dart';
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
}

