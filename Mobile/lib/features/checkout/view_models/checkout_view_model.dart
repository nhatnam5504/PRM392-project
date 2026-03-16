import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/app_constants.dart';
import '../../../data/models/cart_item_model.dart';
import '../../../data/models/check_available_model.dart';
import '../../../data/models/promotion_model.dart';
import '../../../data/repositories/order_repository.dart';

class CheckoutViewModel extends ChangeNotifier {
  final OrderRepository _orderRepo;

  CheckoutViewModel({OrderRepository? orderRepo})
      : _orderRepo = orderRepo ?? OrderRepository();

  int? _selectedAddressId;
  String _paymentMethod = 'cod';
  bool _isLoading = false;
  String? _errorMessage;

  CheckAvailableResponse? _checkResult;
  PromotionModel? _appliedPromotion;
  double _discountPreview = 0;
  String? _paymentUrl;

  int? get selectedAddressId => _selectedAddressId;
  String get paymentMethod => _paymentMethod;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  CheckAvailableResponse? get checkResult => _checkResult;
  PromotionModel? get appliedPromotion => _appliedPromotion;
  double get discountPreview => _discountPreview;
  String? get paymentUrl => _paymentUrl;

  double get payableTotal {
    final total = _checkResult?.totalPrice ?? 0;
    final payable = total - _discountPreview;
    return payable < 0 ? 0 : payable;
  }

  void setAddressId(int addressId) {
    _selectedAddressId = addressId;
    notifyListeners();
  }

  void setPaymentMethod(String method) {
    _paymentMethod = method;
    notifyListeners();
  }

  Future<int?> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(AppConstants.prefUserId);
  }

  Future<bool> checkAvailability({
    required List<CartItemModel> items,
    required Set<int> bogoProductIds,
  }) async {
    final userId = await _getUserId();
    if (userId == null) {
      _errorMessage = 'Vui lòng đăng nhập trước khi đặt hàng.';
      notifyListeners();
      return false;
    }

    if (items.isEmpty) {
      _errorMessage = 'Giỏ hàng trống.';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final request = _buildCheckRequest(
        userId: userId,
        items: items,
        bogoProductIds: bogoProductIds,
      );
      _checkResult = await _orderRepo.checkAvailable(request);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> applyPromotion(String code) async {
    if (_checkResult == null) {
      _errorMessage = 'Vui lòng kiểm tra tồn kho trước.';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final promo = await _orderRepo.getPromotionByCode(code);
      final discount = _calculatePromotionDiscount(
        amount: _checkResult!.totalPrice,
        promotion: promo,
      );
      _appliedPromotion = promo;
      _discountPreview = discount;
      return true;
    } catch (e) {
      _appliedPromotion = null;
      _discountPreview = 0;
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearPromotion() {
    _appliedPromotion = null;
    _discountPreview = 0;
    notifyListeners();
  }

  Future<String?> makePayment() async {
    if (_checkResult == null || _checkResult!.orderCode.isEmpty) {
      _errorMessage = 'Vui lòng kiểm tra tồn kho trước.';
      notifyListeners();
      return null;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final url = await _orderRepo.makePayment(
        orderCode: _checkResult!.orderCode,
        promotionCode: _appliedPromotion?.code,
      );
      _paymentUrl = url;
      return url;
    } catch (e) {
      _errorMessage = e.toString();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  CheckAvailableRequest _buildCheckRequest({
    required int userId,
    required List<CartItemModel> items,
    required Set<int> bogoProductIds,
  }) {
    final orderDetails = <OrderDetailRequest>[];

    for (final item in items) {
      final isBogo = bogoProductIds.contains(item.productId);
      final subtotal = item.price * item.quantity;

      orderDetails.add(
        OrderDetailRequest(
          productId: item.productId,
          quantity: item.quantity,
          subtotal: subtotal,
          type: 'buy',
        ),
      );

      if (isBogo) {
        orderDetails.add(
          OrderDetailRequest(
            productId: item.productId,
            quantity: item.quantity,
            subtotal: 0,
            type: 'gift',
          ),
        );
      }
    }

    final basePrice = orderDetails.fold<double>(
      0,
      (sum, detail) => sum + detail.subtotal,
    );

    return CheckAvailableRequest(
      userId: userId,
      status: 'PENDING',
      totalPrice: basePrice,
      basePrice: basePrice,
      orderCode: '',
      orderDetails: orderDetails,
    );
  }

  double _calculatePromotionDiscount({
    required double amount,
    required PromotionModel promotion,
  }) {
    if (amount < promotion.minOrderAmount) {
      throw Exception(
        'Đơn hàng chưa đạt giá trị tối thiểu.',
      );
    }

    switch (promotion.type) {
      case PromotionType.money:
        final cap = promotion.maxDiscountValue > 0
            ? promotion.maxDiscountValue
            : promotion.discountValue;
        return promotion.discountValue > cap
            ? cap
            : promotion.discountValue;
      case PromotionType.percentage:
        final raw = amount * promotion.discountValue;
        final cap = promotion.maxDiscountValue > 0
            ? promotion.maxDiscountValue
            : raw;
        return raw > cap ? cap : raw;
      case PromotionType.bogo:
        return 0;
    }
  }
}
