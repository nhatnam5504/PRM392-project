import 'package:flutter/material.dart';

import '../../../data/models/user_order_model.dart';
import '../../../data/repositories/order_repository.dart';

class OrderViewModel extends ChangeNotifier {
  final OrderRepository _repository;

  OrderViewModel({
    OrderRepository? repository,
  }) : _repository =
            repository ?? OrderRepository();

  List<UserOrderModel> _orders = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<UserOrderModel> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Filtered orders by status tab
  List<UserOrderModel> filteredOrders(
    String statusFilter,
  ) {
    if (statusFilter == 'ALL') {
      return _orders;
    }
    return _orders
        .where((o) =>
            o.status.toUpperCase() ==
            statusFilter.toUpperCase())
        .toList();
  }

  Future<void> loadOrders() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _orders = await _repository.getUserOrders();
    } catch (e) {
      final msg = e
          .toString()
          .replaceFirst('Exception: ', '');
      _errorMessage = msg.contains('đăng nhập')
          ? msg
          : 'Không thể tải danh sách đơn hàng. '
              'Vui lòng thử lại.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  UserOrderModel? getOrderById(int orderId) {
    try {
      return _orders.firstWhere(
        (o) => o.id == orderId,
      );
    } catch (_) {
      return null;
    }
  }
}
