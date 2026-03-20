import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../data/models/admin_order_model.dart';
import '../../../data/repositories/admin_order_repository.dart';

class AdminOrderViewModel extends ChangeNotifier {
  final AdminOrderRepository _repo;

  AdminOrderViewModel({AdminOrderRepository? repo})
      : _repo = repo ?? AdminOrderRepository();

  List<AdminOrderModel> _orders = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _statusFilter = 'ALL';

  List<AdminOrderModel> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get statusFilter => _statusFilter;

  List<AdminOrderModel> get filteredOrders {
    if (_statusFilter == 'ALL') return _orders;
    return _orders
        .where((o) => o.status.toUpperCase() == _statusFilter)
        .toList();
  }

  // Summary stats
  int get totalOrders => _orders.length;
  int get pendingCount =>
      _orders.where((o) => o.status.toUpperCase() == 'PENDING').length;
  int get paidCount =>
      _orders.where((o) => o.status.toUpperCase() == 'PAID').length;
  int get canceledCount =>
      _orders.where((o) => o.status.toUpperCase() == 'CANCELED').length;
  double get totalRevenue => _orders
      .where((o) => o.status.toUpperCase() == 'PAID')
      .fold(0, (sum, o) => sum + o.totalPrice);

  Future<void> loadOrders() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _orders = await _repo.getAllOrders();
      // Sort newest first
      _orders.sort((a, b) => b.orderDate.compareTo(a.orderDate));
    } catch (e, st) {
      _errorMessage = 'Không thể tải đơn hàng: ${e.toString()}';
      if (e is DioException) {
        _errorMessage =
            'Lỗi kết nối API: ${e.response?.statusCode ?? e.message}';
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setStatusFilter(String status) {
    _statusFilter = status;
    notifyListeners();
  }

  Future<bool> updateStatus(int orderId, String newStatus) async {
    try {
      await _repo.updateOrderStatus(orderId, newStatus);
      final idx = _orders.indexWhere((o) => o.id == orderId);
      if (idx != -1) {
        // Rebuild order with new status
        final old = _orders[idx];
        _orders[idx] = AdminOrderModel(
          id: old.id,
          orderCode: old.orderCode,
          userName: old.userName,
          orderDate: old.orderDate,
          status: newStatus,
          totalPrice: old.totalPrice,
          basePrice: old.basePrice,
          note: old.note,
          orderDetails: old.orderDetails,
          orderInfo: old.orderInfo,
        );
        notifyListeners();
      }
      return true;
    } catch (e) {
      _errorMessage = 'Cập nhật trạng thái thất bại';
      notifyListeners();
      return false;
    }
  }
}

