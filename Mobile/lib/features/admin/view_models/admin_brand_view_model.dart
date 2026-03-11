import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../../data/models/brand_model.dart';
import '../../../data/repositories/brand_repository.dart';

class AdminBrandViewModel extends ChangeNotifier {
  final BrandRepository _brandRepo;

  AdminBrandViewModel({BrandRepository? brandRepo})
      : _brandRepo = brandRepo ?? BrandRepository();

  List<BrandModel> _brands = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<BrandModel> get brands => _brands;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadBrands() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _brands = await _brandRepo.getBrands();
    } catch (e, st) {
      debugPrint('loadBrands error: $e\n$st');
      _errorMessage = 'Lỗi tải thương hiệu: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createBrand({
    required String name,
    required String description,
    String? logoPath,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final brand = await _brandRepo.createBrand(
        name: name,
        description: description,
        logoPath: logoPath,
      );
      _brands = [brand, ..._brands];
      return true;
    } catch (e) {
      _errorMessage = 'Lỗi tạo thương hiệu: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateBrand({
    required int id,
    required String name,
    required String description,
    String? logoUrl,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final updated = await _brandRepo.updateBrand(
        id: id,
        name: name,
        description: description,
        logoUrl: logoUrl,
      );
      final idx = _brands.indexWhere((b) => b.id == id);
      if (idx != -1) _brands[idx] = updated;
      return true;
    } catch (e) {
      _errorMessage = 'Lỗi cập nhật thương hiệu: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteBrand(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _brandRepo.deleteBrand(id);
      _brands.removeWhere((b) => b.id == id);
      return true;
    } catch (e) {
      _errorMessage = 'Không thể xoá thương hiệu.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
