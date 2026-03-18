import 'package:flutter/foundation.dart';

import '../../../data/models/user_order_model.dart';
import '../../../data/models/order_detail_feedback_model.dart';
import '../../../data/repositories/feedback_repository.dart';

class OrderFeedbackViewModel extends ChangeNotifier {
  final FeedbackRepository _repository;

  OrderFeedbackViewModel({
    FeedbackRepository? repository,
  }) : _repository = repository ?? FeedbackRepository();

  final Set<int> _submittedDetailIds = <int>{};
  final Map<int, bool> _submittingByDetailId = <int, bool>{};
  final Map<int, OrderDetailFeedbackModel> _feedbackByDetailId = 
      <int, OrderDetailFeedbackModel>{};

  bool _isLoading = false;
  String? _errorMessage;
  int? _currentOrderId;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  bool canReviewOrder(UserOrderModel order) {
    final normalizedStatus = order.status.toUpperCase();
    return normalizedStatus == 'PAID' ||
        normalizedStatus == 'DELIVERED' ||
        normalizedStatus == 'COMPLETED';
  }

  bool canReviewItem(
    UserOrderModel order,
    UserOrderDetailModel item,
  ) {
    return canReviewOrder(order) && !item.isGift && item.orderDetailId > 0;
  }

  bool hasSubmitted(int orderDetailId) {
    return _submittedDetailIds.contains(orderDetailId);
  }

  bool isSubmitting(int orderDetailId) {
    return _submittingByDetailId[orderDetailId] ?? false;
  }

  OrderDetailFeedbackModel? getFeedback(int orderDetailId) {
    return _feedbackByDetailId[orderDetailId];
  }

  Future<void> initialize(UserOrderModel order) async {
    if (_currentOrderId == order.id) {
      return;
    }

    _currentOrderId = order.id;
    _errorMessage = null;
    _submittedDetailIds.clear();
    _feedbackByDetailId.clear();

    final reviewableItems = order.orderDetails
        .where(
          (item) => !item.isGift && item.orderDetailId > 0,
        )
        .toList();

    if (!canReviewOrder(order) || reviewableItems.isEmpty) {
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final submittedIds = <int>{};
      for (final item in reviewableItems) {
        final feedback = await _repository.getFeedbackByOrderDetail(
          item.orderDetailId,
        );
        if (feedback != null) {
          submittedIds.add(item.orderDetailId);
          _feedbackByDetailId[item.orderDetailId] = feedback;
        }
      }

      _submittedDetailIds
        ..clear()
        ..addAll(submittedIds);
    } catch (e) {
      debugPrint(
        '[OrderFeedbackVM] Failed to load '
        'feedback state: $e',
      );
      _errorMessage = 'Không thể kiểm tra trạng thái đánh giá. '
          'Bạn vẫn có thể thử gửi lại.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> submitFeedback({
    required UserOrderDetailModel item,
    required int rating,
    required String comment,
  }) async {
    _submittingByDetailId[item.orderDetailId] = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.submitOrderFeedback(
        productId: item.productId,
        rating: rating,
        comment: comment,
        orderDetailId: item.orderDetailId,
      );
      _submittedDetailIds.add(item.orderDetailId);
      return true;
    } catch (e) {
      debugPrint(
        '[OrderFeedbackVM] Submit error: $e',
      );
      final message = e.toString().replaceFirst('Exception: ', '');
      _errorMessage = message.isNotEmpty
          ? message
          : 'Không thể gửi đánh giá. '
              'Vui lòng thử lại.';
      return false;
    } finally {
      _submittingByDetailId[item.orderDetailId] = false;
      notifyListeners();
    }
  }

  void clearError() {
    if (_errorMessage == null) {
      return;
    }
    _errorMessage = null;
    notifyListeners();
  }
}
