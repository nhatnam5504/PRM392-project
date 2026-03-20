import 'package:dio/dio.dart';
import '../models/payment_model.dart';
import '../services/api_service.dart';

class AdminPaymentRepository {
  final Dio _dio = ApiService().client;

  /// GET /api/orders/payments — all payment transactions
  Future<List<PaymentModel>> getAllPayments() async {
    final response = await _dio.get('/api/orders/payments');
    final list = response.data as List<dynamic>;
    return list
        .map((json) =>
            PaymentModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
