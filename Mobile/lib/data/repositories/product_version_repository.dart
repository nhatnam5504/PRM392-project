import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../models/product_version_model.dart';
import '../services/api_service.dart';

class ProductVersionRepository {
  final Dio _dio = ApiService().client;

  /// GET /api/products/product-versions
  Future<List<ProductVersionModel>>
      getProductVersions() async {
    final response = await _dio.get(
      ApiConstants.productVersions,
    );
    return (response.data as List)
        .map((json) =>
            ProductVersionModel.fromJson(
              json as Map<String, dynamic>,
            ))
        .toList();
  }

  /// GET /api/products/product-versions/{id}
  Future<ProductVersionModel>
      getProductVersionById(int id) async {
    final response = await _dio.get(
      '${ApiConstants.productVersions}/$id',
    );
    return ProductVersionModel.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  /// POST /api/products/product-versions
  Future<ProductVersionModel> createProductVersion({
    required String versionName,
  }) async {
    final response = await _dio.post(
      ApiConstants.productVersions,
      data: {'versionName': versionName},
    );
    return ProductVersionModel.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  /// PUT /api/products/product-versions
  Future<ProductVersionModel> updateProductVersion({
    required int id,
    required String versionName,
  }) async {
    final response = await _dio.put(
      ApiConstants.productVersions,
      data: {'id': id, 'versionName': versionName},
    );
    return ProductVersionModel.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  /// DELETE /api/products/product-versions/{id}
  Future<void> deleteProductVersion(int id) async {
    await _dio.delete(
      '${ApiConstants.productVersions}/$id',
    );
  }
}
