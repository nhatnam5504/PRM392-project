import 'package:flutter/foundation.dart';

import '../../../data/repositories/feedback_repository.dart';

class ProductRatingData {
  final double averageRating;
  final int totalCount;

  const ProductRatingData({
    required this.averageRating,
    required this.totalCount,
  });
}

class ProductRatingViewModel extends ChangeNotifier {
  final FeedbackRepository _feedbackRepo;

  ProductRatingViewModel({
    FeedbackRepository? feedbackRepo,
  }) : _feedbackRepo =
            feedbackRepo ?? FeedbackRepository();

  final Map<int, ProductRatingData> _ratings = {};

  ProductRatingData? getRating(int productId) =>
      _ratings[productId];

  /// Load ratings for a list of product IDs
  Future<void> loadRatingsForProducts(
    List<int> productIds,
  ) async {
    final idsToLoad = productIds
        .where((id) => !_ratings.containsKey(id))
        .toList();

    if (idsToLoad.isEmpty) {
      return;
    }

    await Future.wait(
      idsToLoad.map((id) => _loadRating(id)),
    );
    notifyListeners();
  }

  /// Load rating for a single product
  Future<void> loadRating(int productId) async {
    await _loadRating(productId);
    notifyListeners();
  }

  Future<void> _loadRating(int productId) async {
    try {
      final feedbacks = await _feedbackRepo
          .getFeedbacksByProduct(productId);
      if (feedbacks.isEmpty) {
        _ratings[productId] =
            const ProductRatingData(
          averageRating: 0,
          totalCount: 0,
        );
      } else {
        final total = feedbacks.fold<int>(
          0,
          (sum, f) => sum + f.rating,
        );
        _ratings[productId] = ProductRatingData(
          averageRating: total / feedbacks.length,
          totalCount: feedbacks.length,
        );
      }
    } catch (e) {
      debugPrint(
        '[ProductRatingVM] Error loading '
        'rating for product $productId: $e',
      );
    }
  }
}

