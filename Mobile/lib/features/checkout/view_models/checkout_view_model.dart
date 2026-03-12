import 'package:flutter/material.dart';

class CheckoutViewModel extends ChangeNotifier {
  int? _selectedAddressId;
  String _paymentMethod = 'cod';
  bool _isLoading = false;
  String? _errorMessage;
  int? _placedOrderId;

  int? get selectedAddressId => _selectedAddressId;
  String get paymentMethod => _paymentMethod;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int? get placedOrderId => _placedOrderId;

  void setAddressId(int addressId) {
    _selectedAddressId = addressId;
    notifyListeners();
  }

  void setPaymentMethod(String method) {
    _paymentMethod = method;
    notifyListeners();
  }

  Future<bool> placeOrder() async {
    if (_selectedAddressId == null) {
      _errorMessage =
          'Vui lòng chọn địa chỉ giao hàng.';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      // TODO: Integrate real order placement API
      await Future.delayed(
        const Duration(milliseconds: 1000),
      );
      _placedOrderId = 1;
      return true;
    } catch (e) {
      _errorMessage =
          'Không thể đặt hàng. '
          'Vui lòng thử lại.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
