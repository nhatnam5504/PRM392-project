import 'package:flutter/material.dart';
import '../../../data/models/product_model.dart';
import '../../../data/models/category_model.dart';
import '../../../data/models/brand_model.dart';
import '../../../data/repositories/product_repository.dart';
import '../../../data/repositories/category_repository.dart';
import '../../../data/repositories/brand_repository.dart';

class ProductViewModel extends ChangeNotifier {
  final ProductRepository _repository;
  final CategoryRepository _categoryRepo;
  final BrandRepository _brandRepo;

  ProductViewModel({
    ProductRepository? repository,
    CategoryRepository? categoryRepo,
    BrandRepository? brandRepo,
  })  : _repository = repository ?? ProductRepository(),
        _categoryRepo = categoryRepo ?? CategoryRepository(),
        _brandRepo = brandRepo ?? BrandRepository();

  List<ProductModel> _products = [];
  List<CategoryModel> _categories = [];
  List<BrandModel> _brands = [];
  ProductModel? _selectedProduct;
  bool _isLoading = false;
  String? _errorMessage;
  int _currentPage = 1;
  bool _hasMore = true;

  List<ProductModel> get products => _products;
  List<CategoryModel> get categories => _categories;
  List<BrandModel> get brands => _brands;
  ProductModel? get selectedProduct => _selectedProduct;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasMore => _hasMore;

  // ─── Load all products ──────────────────────────
  Future<void> loadProducts({
    String? categoryId,
    String? search,
    String? sortBy,
    bool refresh = false,
  }) async {
    if (refresh) {
      _currentPage = 1;
      _hasMore = true;
    }
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final results = await _repository.getProducts(
        page: _currentPage,
        categoryId: categoryId,
        search: search,
        sortBy: sortBy,
      );
      if (refresh) {
        _products = results;
      } else {
        _products = [..._products, ...results];
      }
      _hasMore = results.length >= 20;
      _currentPage++;
    } catch (e) {
      _errorMessage = 'Không thể tải sản phẩm. Vui lòng thử lại.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ─── Load product detail ────────────────────────
  Future<void> loadProductDetail(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _selectedProduct = await _repository.getProductById(id);
    } catch (e) {
      _errorMessage = 'Không thể tải chi tiết sản phẩm.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ─── Load by brand ──────────────────────────────
  Future<void> loadProductsByBrand(int brandId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _products = await _repository.getProductsByBrand(brandId);
    } catch (e) {
      _errorMessage = 'Không thể tải sản phẩm theo thương hiệu.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ─── Load by category ───────────────────────────
  Future<void> loadProductsByCategory(int categoryId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _products = await _repository.getProductsByCategory(categoryId);
    } catch (e) {
      _errorMessage = 'Không thể tải sản phẩm theo danh mục.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ─── Load categories ───────────────────────────
  Future<void> loadCategories() async {
    try {
      _categories = await _categoryRepo.getCategories();
      notifyListeners();
    } catch (_) {}
  }

  // ─── Load brands ───────────────────────────────
  Future<void> loadBrands() async {
    try {
      _brands = await _brandRepo.getBrands();
      notifyListeners();
    } catch (_) {}
  }

  // ─── Create product ────────────────────────────
  Future<ProductModel> createProduct({
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
    notifyListeners();
    try {
      final product = await _repository.createProduct(
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
      return product;
    } catch (e) {
      _errorMessage = 'Không thể tạo sản phẩm.';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ─── Update product ────────────────────────────
  Future<ProductModel> updateProduct({
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
    notifyListeners();
    try {
      final updated = await _repository.updateProduct(
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
      if (_selectedProduct?.id == id) {
        _selectedProduct = updated;
      }
      return updated;
    } catch (e) {
      _errorMessage = 'Không thể cập nhật sản phẩm.';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ─── Delete product ────────────────────────────
  Future<void> deleteProduct(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _repository.deleteProduct(id);
      _products.removeWhere((p) => p.id == id);
      if (_selectedProduct?.id == id) {
        _selectedProduct = null;
      }
    } catch (e) {
      _errorMessage = 'Không thể xoá sản phẩm.';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
