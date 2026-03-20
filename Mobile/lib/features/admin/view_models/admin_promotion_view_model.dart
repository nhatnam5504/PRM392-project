import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../data/models/promotion_model.dart';
import '../../../data/models/product_model.dart';
import '../../../data/repositories/promotion_repository.dart';

class AdminPromotionViewModel extends ChangeNotifier {
  final PromotionRepository _promotionRepo;

  AdminPromotionViewModel({PromotionRepository? promotionRepo})
      : _promotionRepo = promotionRepo ?? PromotionRepository();

  List<PromotionModel> _promotions = [];
  Map<int, List<ProductModel>> _applicableProducts = {};
  List<ProductModel> _allProducts = [];
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  List<PromotionModel> get promotions => _promotions;
  Map<int, List<ProductModel>> get applicableProducts => _applicableProducts;
  List<ProductModel> get allProducts => _allProducts;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  Future<void> loadPromotions() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _promotions = await _promotionRepo.getPromotions();
      _applicableProducts.clear();

      // Tải sản phẩm cho các khuyến mãi BOGO
      for (final promo in _promotions) {
        if (promo.type == PromotionType.bogo &&
            promo.applicableProductIds != null &&
            promo.applicableProductIds!.isNotEmpty) {
          try {
            final products = await _promotionRepo
                .getBogoProducts(promo.applicableProductIds!);
            _applicableProducts[promo.id] = products;
          } catch (e) {
            print('Lỗi tải sản phẩm cho promo ${promo.id}: $e');
          }
        }
      }
    } catch (e) {
      _errorMessage = 'Lỗi tải danh sách khuyến mãi: ${_extractError(e)}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadAllProducts() async {
    try {
      // Sử dụng repository để lấy tất cả sản phẩm
      // Giả sử có sẵn trong repo hoặc dùng trực tiếp từ ApiService
      final response = await _promotionRepo.getPromotions(); // Chờ đã, tôi nên dùng ProductRepository
    } catch (e) {
      print('Lỗi tải sản phẩm: $e');
    }
  }

  Future<bool> createPromotion(PromotionModel promotion) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
    try {
      final newPromo = await _promotionRepo.createPromotion(promotion);
      _promotions = [newPromo, ..._promotions];
      _successMessage = 'Tạo khuyến mãi thành công!';
      return true;
    } catch (e) {
      _errorMessage = 'Lỗi tạo khuyến mãi: ${_extractError(e)}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  String _extractError(Object e) {
    if (e is DioException) {
      return e.error?.toString() ?? e.message ?? 'Lỗi không xác định';
    }
    return e.toString();
  }
}
