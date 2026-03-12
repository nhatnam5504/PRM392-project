import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../data/models/promotion_model.dart';
import '../../../data/models/product_model.dart';
import '../../../data/repositories/promotion_repository.dart';

class DealsViewModel extends ChangeNotifier {
  final PromotionRepository _promoRepo;

  DealsViewModel({
    PromotionRepository? promoRepo,
  }) : _promoRepo =
            promoRepo ?? PromotionRepository();

  List<PromotionModel> _promotions = [];
  // Maps promotion id -> list of BOGO products
  final Map<int, List<ProductModel>>
      _bogoProducts = {};
  bool _isLoading = false;
  String? _errorMessage;

  List<PromotionModel> get promotions =>
      _promotions;
  Map<int, List<ProductModel>>
      get bogoProducts => _bogoProducts;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<PromotionModel> get moneyPromotions =>
      _promotions
          .where(
            (p) => p.type == PromotionType.money,
          )
          .toList();

  List<PromotionModel> get percentagePromotions =>
      _promotions
          .where(
            (p) =>
                p.type ==
                PromotionType.percentage,
          )
          .toList();

  List<PromotionModel> get bogoPromotions =>
      _promotions
          .where(
            (p) => p.type == PromotionType.bogo,
          )
          .toList();

  Future<void> loadDeals() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _promotions =
          await _promoRepo.getPromotions();
      debugPrint(
        '[DealsVM] Loaded ${_promotions.length} '
        'promotions',
      );

      // Load BOGO product details
      for (final promo in bogoPromotions) {
        if (promo.applicableProductIds != null &&
            promo
                .applicableProductIds!.isNotEmpty) {
          final products =
              await _promoRepo.getBogoProducts(
            promo.applicableProductIds!,
          );
          _bogoProducts[promo.id] = products;
        }
      }
    } catch (e, st) {
      debugPrint('[DealsVM] Error: $e');
      debugPrint('[DealsVM] StackTrace: $st');
      _errorMessage =
          'Không thể tải khuyến mãi. '
          'Vui lòng thử lại.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
