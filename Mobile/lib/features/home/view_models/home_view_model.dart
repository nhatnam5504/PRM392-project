import 'package:flutter/material.dart';
import '../../../data/models/banner_model.dart';
import '../../../data/models/category_model.dart';
import '../../../data/models/product_model.dart';
import '../../../data/repositories/banner_repository.dart';
import '../../../data/repositories/category_repository.dart';
import '../../../data/repositories/product_repository.dart';
import '../../../data/repositories/promotion_repository.dart';
import '../../../data/models/promotion_model.dart';

class HomeViewModel extends ChangeNotifier {
  final BannerRepository _bannerRepo;
  final CategoryRepository _categoryRepo;
  final ProductRepository _productRepo;
  final PromotionRepository _promotionRepo;

  HomeViewModel({
    BannerRepository? bannerRepo,
    CategoryRepository? categoryRepo,
    ProductRepository? productRepo,
    PromotionRepository? promotionRepo,
  })  : _bannerRepo =
            bannerRepo ?? BannerRepository(),
        _categoryRepo =
            categoryRepo ?? CategoryRepository(),
        _productRepo =
            productRepo ?? ProductRepository(),
        _promotionRepo =
            promotionRepo ?? PromotionRepository();

  List<BannerModel> _banners = [];
  List<CategoryModel> _categories = [];
  List<ProductModel> _featuredProducts = [];
  List<ProductModel> _featuredServices = [];
  List<ProductModel> _bogoProducts = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<BannerModel> get banners => _banners;
  List<CategoryModel> get categories => _categories;
  List<ProductModel> get featuredProducts =>
      _featuredProducts;
  List<ProductModel> get featuredServices =>
      _featuredServices;
  List<ProductModel> get bogoProducts =>
      _bogoProducts;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadHomeData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final results = await Future.wait([
        _bannerRepo.getBanners(),
        _categoryRepo.getFeaturedCategories(),
        _productRepo.getFeaturedProducts(),
        _productRepo.getFlashSaleProducts(),
      ]);
      _banners =
          results[0] as List<BannerModel>;
      _categories =
          results[1] as List<CategoryModel>;
      final allFeatured =
          results[2] as List<ProductModel>;
      _featuredProducts = allFeatured.where((p) => p.type).toList();
      _featuredServices = allFeatured.where((p) => !p.type).toList();

      // Fetch BOGO products
      final promotions = await _promotionRepo.getPromotions();
      final bogoPromo = promotions.firstWhere(
        (p) => p.type == PromotionType.bogo && p.isActive,
        orElse: () => promotions.firstWhere((p) => p.type == PromotionType.bogo,
            orElse: () => throw Exception('No BOGO promo')),
      );

      if (bogoPromo.applicableProductIds != null &&
          bogoPromo.applicableProductIds!.isNotEmpty) {
        _bogoProducts = await _promotionRepo
            .getBogoProducts(bogoPromo.applicableProductIds!);
      } else {
        _bogoProducts = [];
      }
    } catch (e) {
      _errorMessage = 'Không thể tải dữ liệu. Vui lòng thử lại.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
