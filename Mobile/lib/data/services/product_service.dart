import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../models/check_available_model.dart';
import 'api_service.dart';

class ProductService {
  final Dio _dio = ApiService().client;

  /// Check product availability before creating order
  Future<CheckAvailableResponse> checkAvailable(
    CheckAvailableRequest request,
  ) async {
    try {
      final response = await _dio.post(
        ApiConstants.checkAvailable,
        data: request.toJson(),
      );

      return CheckAvailableResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      // Handle 409 Out of Stock error
      if (e.response?.statusCode == 409) {
        final errorData = e.response?.data as Map<String, dynamic>?;
        final errorMessage = errorData?['error'] as String? ??
            'Sản phẩm hết hàng. Vui lòng chọn sản phẩm khác.';
        throw Exception(errorMessage);
      }
      rethrow;
    }
  }
}

