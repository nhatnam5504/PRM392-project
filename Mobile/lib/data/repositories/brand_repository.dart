import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../models/brand_model.dart';
import '../services/api_service.dart';

class BrandRepository {
  final Dio _dio = ApiService().client;

  /// GET /api/products/brands
  Future<List<BrandModel>> getBrands() async {
    final response = await _dio.get(
      ApiConstants.brands,
    );
    return (response.data as List)
        .map((json) => BrandModel.fromJson(
              json as Map<String, dynamic>,
            ))
        .toList();
  }

  /// GET /api/products/brands/{id}
  Future<BrandModel> getBrandById(int id) async {
    final response = await _dio.get(
      '${ApiConstants.brandById}/$id',
    );
    return BrandModel.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  /// POST /api/products/brands (multipart – logo upload)
  Future<BrandModel> createBrand({
    required String name,
    required String description,
    String? logoPath,
  }) async {
    final formData = FormData.fromMap({
      'name': name,
      'description': description,
      if (logoPath != null)
        'file': await MultipartFile.fromFile(logoPath),
    });
    final response = await _dio.post(
      ApiConstants.brands,
      data: formData,
      options: Options(
        contentType: 'multipart/form-data',
      ),
    );
    return BrandModel.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  /// PUT /api/products/brands (JSON)
  Future<BrandModel> updateBrand({
    required int id,
    required String name,
    required String description,
    String? logoUrl,
  }) async {
    final response = await _dio.put(
      ApiConstants.brands,
      data: {
        'id': id,
        'name': name,
        'description': description,
        if (logoUrl != null) 'logoUrl': logoUrl,
      },
    );
    return BrandModel.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  /// DELETE /api/products/brands/{id}
  Future<void> deleteBrand(int id) async {
    await _dio.delete(
      '${ApiConstants.brands}/$id',
    );
  }
}
