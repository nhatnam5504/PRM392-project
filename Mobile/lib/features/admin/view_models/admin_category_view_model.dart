import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../../data/models/category_model.dart';
import '../../../data/repositories/category_repository.dart';

class AdminCategoryViewModel extends ChangeNotifier {
  final CategoryRepository _categoryRepo;

  AdminCategoryViewModel({CategoryRepository? categoryRepo})
      : _categoryRepo = categoryRepo ?? CategoryRepository();

  List<CategoryModel> _categories = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<CategoryModel> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadCategories() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _categories = await _categoryRepo.getCategories();
    } catch (e, st) {
      _errorMessage = 'Lỗi tải danh mục: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createCategory({
    required String name,
    required String description,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final category = await _categoryRepo.createCategory(
        name: name,
        description: description,
      );
      _categories = [category, ..._categories];
      return true;
    } catch (e) {
      _errorMessage = 'Lỗi tạo danh mục: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateCategory({
    required int id,
    required String name,
    required String description,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final updated = await _categoryRepo.updateCategory(
        id: id,
        name: name,
        description: description,
      );
      final idx = _categories.indexWhere((c) => c.id == id);
      if (idx != -1) _categories[idx] = updated;
      return true;
    } catch (e) {
      _errorMessage = 'Lỗi cập nhật danh mục: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteCategory(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _categoryRepo.deleteCategory(id);
      _categories.removeWhere((c) => c.id == id);
      return true;
    } catch (e) {
      _errorMessage = 'Không thể xoá danh mục.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

