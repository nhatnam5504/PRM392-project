import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../data/models/promotion_model.dart';
import '../../../data/repositories/order_repository.dart';

class PaymentConfirmationViewModel extends ChangeNotifier {
  PaymentConfirmationViewModel({
    required this.orderCode,
    required this.baseAmount,
    OrderRepository? orderRepository,
  }) : _orderRepo = orderRepository ?? OrderRepository();

  final OrderRepository _orderRepo;
  final String orderCode;
  final double baseAmount;

  bool _isLoading = false;
  String? _errorMessage;
  PromotionModel? _appliedPromotion;
  double _discountPreview = 0;
  String? _paymentUrl;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  PromotionModel? get appliedPromotion => _appliedPromotion;
  double get discountPreview => _discountPreview;
  String? get paymentUrl => _paymentUrl;

  double get payableTotal {
    final payable = baseAmount - _discountPreview;
    return payable < 0 ? 0 : payable;
  }

  Future<bool> applyPromotion(String code) async {
    final trimmedCode = code.trim();
    if (trimmedCode.isEmpty) {
      _errorMessage = 'Vui lòng nhập mã giảm giá.';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final promo = await _orderRepo.getPromotionByCode(trimmedCode);
      if (!promo.isActive) {
        throw Exception(
          'Mã giảm giá không hợp lệ hoặc đã hết hạn.',
        );
      }

      final discount = _calculatePromotionDiscount(
        amount: baseAmount,
        promotion: promo,
      );
      _appliedPromotion = promo;
      _discountPreview = discount;
      return true;
    } catch (e) {
      _appliedPromotion = null;
      _discountPreview = 0;
      _errorMessage = _resolveErrorMessage(
        e,
        fallback: 'Không thể áp dụng mã giảm giá.',
      );
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearPromotion() {
    _appliedPromotion = null;
    _discountPreview = 0;
    _errorMessage = null;
    notifyListeners();
  }

  Future<String?> makePayment() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final url = await _orderRepo.makePayment(
        orderCode: orderCode,
        promotionCode: _appliedPromotion?.code,
      );
      _paymentUrl = url;
      return url;
    } catch (e) {
      _errorMessage = _resolveErrorMessage(e, fallback: 'Không thể tạo liên kết thanh toán.');
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String _resolveErrorMessage(Object e, {String? fallback}) {
    if (e is DioException) {
      final error = e.error;
      if (error is String && error.isNotEmpty) {
        return error;
      }
      final message = e.message;
      if (message != null && message.isNotEmpty) {
        return message;
      }
    }
    final value = e.toString().replaceFirst('Exception: ', '');
    if (value.isNotEmpty) {
      return value;
    }
    return fallback ?? 'Đã xảy ra lỗi. Vui lòng thử lại.';
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

