import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../../data/models/product_model.dart';
import '../../../data/models/category_model.dart';
import '../../../data/models/brand_model.dart';
import '../../../data/models/product_version_model.dart';
import '../../../data/repositories/product_repository.dart';
import '../../../data/repositories/category_repository.dart';
import '../../../data/repositories/brand_repository.dart';
import '../../../data/repositories/product_version_repository.dart';

class AdminProductViewModel extends ChangeNotifier {
  final ProductRepository _productRepo;
  final CategoryRepository _categoryRepo;
  final BrandRepository _brandRepo;
  final ProductVersionRepository _versionRepo;

  AdminProductViewModel({
    ProductRepository? productRepo,
    CategoryRepository? categoryRepo,
    BrandRepository? brandRepo,
    ProductVersionRepository? versionRepo,
  })  : _productRepo = productRepo ?? ProductRepository(),
        _categoryRepo = categoryRepo ?? CategoryRepository(),
        _brandRepo = brandRepo ?? BrandRepository(),
        _versionRepo = versionRepo ?? ProductVersionRepository();

  List<ProductModel> _products = [];
  List<CategoryModel> _categories = [];
  List<BrandModel> _brands = [];
  List<ProductVersionModel> _versions = [];
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  List<ProductModel> get products => _products;
  List<CategoryModel> get categories => _categories;
  List<BrandModel> get brands => _brands;
  List<ProductVersionModel> get versions => _versions;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  Future<void> loadProducts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _products = await _productRepo.getProducts();
    } catch (e, st) {
      debugPrint('loadProducts error: $e\n$st');
      _errorMessage = 'Lỗi tải sản phẩm: ${_extractError(e)}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadFormData() async {
    try {
      final results = await Future.wait([
        _categoryRepo.getCategories(),
        _brandRepo.getBrands(),
        _versionRepo.getProductVersions(),
      ]);
      _categories = results[0] as List<CategoryModel>;
      _brands = results[1] as List<BrandModel>;
      _versions = results[2] as List<ProductVersionModel>;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Không thể tải dữ liệu form.';
      notifyListeners();
    }
  }

  Future<bool> createProduct({
    required String name,
    required String description,
    required int price,
    required int stockQuantity,
    required bool active,
    required int versionId,
    required int brandId,
    required int categoryId,
    String? imagePath,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
    try {
      final product = await _productRepo.createProduct(
        name: name,
        description: description,
        price: price,
        stockQuantity: stockQuantity,
        active: active,
        versionId: versionId,
        brandId: brandId,
        categoryId: categoryId,
        imagePath: imagePath,
      );
      _products = [product, ..._products];
      _successMessage = 'Tạo sản phẩm thành công!';
      return true;
    } catch (e) {
      _errorMessage = 'Lỗi tạo sản phẩm: ${_extractError(e)}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateProduct({
    required int id,
    String? name,
    String? description,
    int? price,
    int? stockQuantity,
    bool? active,
    int? versionId,
    int? brandId,
    int? categoryId,
    String? imagePath,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
    try {
      final updated = await _productRepo.updateProduct(
        id: id,
        name: name,
        description: description,
        price: price,
        stockQuantity: stockQuantity,
        active: active,
        versionId: versionId,
        brandId: brandId,
        categoryId: categoryId,
        imagePath: imagePath,
      );
      final idx = _products.indexWhere((p) => p.id == id);
      if (idx != -1) {
        _products[idx] = updated;
      }
      _successMessage = 'Cập nhật sản phẩm thành công!';
      return true;
    } catch (e) {
      _errorMessage = 'Lỗi cập nhật sản phẩm: ${_extractError(e)}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteProduct(int id) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
    try {
      await _productRepo.deleteProduct(id);
      _products.removeWhere((p) => p.id == id);
      _successMessage = 'Xoá sản phẩm thành công!';
      return true;
    } catch (e) {
      _errorMessage = 'Không thể xoá sản phẩm.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String _extractError(Object e) {
    if (e is DioException)
      return e.error?.toString() ?? e.message ?? 'Lỗi không xác định';
    return e.toString();
  }

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }
}
