import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../models/admin_order_model.dart';
import '../services/api_service.dart';

class AdminOrderRepository {
  final Dio _dio = ApiService().client;

  /// GET /api/orders — get all orders (admin)
  Future<List<AdminOrderModel>> getAllOrders() async {
    final response = await _dio.get('/api/orders');
    final list = response.data as List<dynamic>;
    return list
        .map((json) =>
            AdminOrderModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// PUT /api/orders/{id}/status — update order status
  Future<void> updateOrderStatus(int orderId, String status) async {
    await _dio.put(
      '/api/orders/$orderId/status',
      queryParameters: {'status': status},
    );
  }
}
