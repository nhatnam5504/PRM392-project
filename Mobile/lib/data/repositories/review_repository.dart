import '../dummy_data.dart';
import '../models/review_model.dart';

class ReviewRepository {
  bool _useDummyData = true;

  Future<List<ReviewModel>> getReviewsForProduct(
    int productId,
  ) async {
    if (_useDummyData) {
      await Future.delayed(
        const Duration(milliseconds: 400),
      );
      return DummyData.getReviewsForProduct(
        productId,
      );
    }
    throw UnimplementedError();
  }

  Future<List<ReviewModel>> getMyReviews() async {
    if (_useDummyData) {
      await Future.delayed(const Duration(milliseconds: 500));
      return []; // Return empty list or some dummy reviews
    }
    throw UnimplementedError();
  }

  Future<void> updateReview({
    required int reviewId,
    required int rating,
    required String comment,
  }) async {
    if (_useDummyData) {
      await Future.delayed(const Duration(milliseconds: 500));
    }
  }

  Future<void> deleteReview(int reviewId) async {
    if (_useDummyData) {
      await Future.delayed(const Duration(milliseconds: 500));
    }
  }

  Future<void> submitReview({
    required int productId,
    required int rating,
    required String comment,
    List<String>? imageUrls,
  }) async {
    if (_useDummyData) {
      await Future.delayed(
        const Duration(milliseconds: 800),
      );
    }
  }
}
