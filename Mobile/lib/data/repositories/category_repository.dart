import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../dummy_data.dart';
import '../models/category_model.dart';
import '../services/api_service.dart';

class CategoryRepository {
  final Dio _dio = ApiService().client;
  bool _useDummyData = false;

  /// GET /api/products/categories
  Future<List<CategoryModel>> getCategories() async {
    try {
      final response = await _dio.get(
        ApiConstants.categories,
      );
      return (response.data as List)
          .map((json) => CategoryModel.fromJson(
                json as Map<String, dynamic>,
              ))
          .toList();
    } catch (e) {
      if (_useDummyData) {
        await Future.delayed(
          const Duration(milliseconds: 300),
        );
        return DummyData.categories;
      }
      rethrow;
    }
  }

  /// GET /api/products/categories/{id}
  Future<CategoryModel> getCategoryById(
    int id,
  ) async {
    try {
      final response = await _dio.get(
        '${ApiConstants.categoryById}/$id',
      );
      return CategoryModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<List<CategoryModel>> getFeaturedCategories() async {
    // BE doesn't have "featured" categories,
    // return all categories.
    try {
      return await getCategories();
    } catch (e) {
      if (_useDummyData) {
        await Future.delayed(
          const Duration(milliseconds: 300),
        );
        return DummyData.featuredCategories;
      }
      rethrow;
    }
  }

  /// POST /api/products/categories
  Future<CategoryModel> createCategory({
    required String name,
    required String description,
  }) async {
    final response = await _dio.post(
      ApiConstants.categories,
      data: {'id': 0, 'name': name, 'description': description},
    );
    return CategoryModel.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  /// PUT /api/products/categories
  Future<CategoryModel> updateCategory({
    required int id,
    required String name,
    required String description,
  }) async {
    final response = await _dio.put(
      ApiConstants.categories,
      data: {'id': id, 'name': name, 'description': description},
    );
    return CategoryModel.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  /// DELETE /api/products/categories/{id}
  Future<void> deleteCategory(int id) async {
    await _dio.delete(
      '${ApiConstants.categories}/$id',
    );
  }
}
