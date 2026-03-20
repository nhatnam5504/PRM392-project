import 'package:flutter/material.dart';
import '../../../data/repositories/review_repository.dart';

class ReviewViewModel extends ChangeNotifier {
  final ReviewRepository _repository;

  ReviewViewModel({
    ReviewRepository? repository,
  }) : _repository =
            repository ?? ReviewRepository();

  bool _isLoading = false;
  String? _errorMessage;
  List<dynamic> _myReviews = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<dynamic> get myReviews => _myReviews;

  Future<void> fetchMyReviews() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _myReviews = await _repository.getMyReviews();
    } catch (e) {
      _errorMessage = 'Không thể tải đánh giá của bạn.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateReview({
    required int reviewId,
    required int rating,
    required String comment,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _repository.updateReview(
        reviewId: reviewId,
        rating: rating,
        comment: comment,
      );
      await fetchMyReviews();
      return true;
    } catch (e) {
      _errorMessage = 'Không thể cập nhật đánh giá.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteReview(int reviewId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _repository.deleteReview(reviewId);
      await fetchMyReviews();
      return true;
    } catch (e) {
      _errorMessage = 'Không thể xóa đánh giá.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> submitReview({
    required int productId,
    required int rating,
    required String comment,
    List<String>? imageUrls,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _repository.submitReview(
        productId: productId,
        rating: rating,
        comment: comment,
        imageUrls: imageUrls,
      );
      return true;
    } catch (e) {
      _errorMessage =
          'Không thể gửi đánh giá. '
          'Vui lòng thử lại.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
