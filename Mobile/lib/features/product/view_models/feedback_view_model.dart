import 'package:flutter/foundation.dart';

import '../../../data/models/feedback_model.dart';
import '../../../data/repositories/feedback_repository.dart';

class FeedbackViewModel extends ChangeNotifier {
  final FeedbackRepository _feedbackRepo;

  FeedbackViewModel({
    FeedbackRepository? feedbackRepo,
  }) : _feedbackRepo =
            feedbackRepo ?? FeedbackRepository();

  List<FeedbackModel> _feedbacks = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<FeedbackModel> get feedbacks => _feedbacks;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  double get averageRating {
    if (_feedbacks.isEmpty) {
      return 0;
    }
    final total = _feedbacks.fold<int>(
      0,
      (sum, f) => sum + f.rating,
    );
    return total / _feedbacks.length;
  }

  int get totalFeedbacks => _feedbacks.length;

  Future<void> loadFeedbacks(int productId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _feedbacks =
          await _feedbackRepo.getFeedbacksByProduct(
        productId,
      );
      debugPrint(
        '[FeedbackVM] Loaded ${_feedbacks.length} '
        'feedbacks for product $productId',
      );
    } catch (e) {
      debugPrint('[FeedbackVM] Error: $e');
      _errorMessage =
          'Không thể tải đánh giá. '
          'Vui lòng thử lại.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

