import 'dart:convert';

import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../../core/constants/app_constants.dart';
import '../dummy_data.dart';
import '../models/product_model.dart';
import '../services/api_service.dart';

class ProductRepository {
  final Dio _dio = ApiService().client;
  bool _useDummyData = false;

  Future<List<ProductModel>> getProducts({
    int page = 1,
    int pageSize = AppConstants.pageSize,
    String? categoryId,
    String? search,
    String? sortBy,
    List<String>? brands,
    double? minPrice,
    double? maxPrice,
    List<String>? features,
  }) async {
    try {
      final response = await _dio.get(
        ApiConstants.products,
      );
      final list = (response.data as List)
          .map((json) => ProductModel.fromJson(
                json as Map<String, dynamic>,
              ))
          .toList();

      var products = list;

      // Client-side filtering
      if (search != null && search.isNotEmpty) {
        products = products
            .where(
              (p) => p.name.toLowerCase().contains(
                    search.toLowerCase(),
                  ),
            )
            .toList();
      }
      if (categoryId != null) {
        final cid = int.tryParse(categoryId);
        if (cid != null) {
          products = products.where((p) => p.categoryId == cid).toList();
        }
      }
      return products;
    } catch (e) {
      if (_useDummyData) {
        await Future.delayed(
          const Duration(milliseconds: 600),
        );
        var products = DummyData.products;
        if (search != null && search.isNotEmpty) {
          products = products
              .where(
                (p) => p.name.toLowerCase().contains(
                      search.toLowerCase(),
                    ),
              )
              .toList();
        }
        if (categoryId != null) {
          final cid = int.tryParse(categoryId);
          if (cid != null) {
            products = products.where((p) => p.categoryId == cid).toList();
          }
        }
        return products;
      }
      rethrow;
    }
  }

  Future<ProductModel> getProductById(
    int id,
  ) async {
    try {
      final response = await _dio.get(
        '${ApiConstants.productById}/$id',
      );
      return ProductModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    } catch (e) {
      if (_useDummyData) {
        await Future.delayed(
          const Duration(milliseconds: 400),
        );
        return DummyData.products.firstWhere(
          (p) => p.id == id,
        );
      }
      rethrow;
    }
  }

  Future<List<ProductModel>> getActiveProducts() async {
    try {
      final response = await _dio.get(
        ApiConstants.activeProducts,
      );
      return (response.data as List)
          .map((json) => ProductModel.fromJson(
                json as Map<String, dynamic>,
              ))
          .toList();
    } catch (e) {
      if (_useDummyData) {
        await Future.delayed(
          const Duration(milliseconds: 400),
        );
        return DummyData.products;
      }
      rethrow;
    }
  }

  Future<List<ProductModel>> getProductsByBrand(
    int brandId,
  ) async {
    try {
      final response = await _dio.get(
        '${ApiConstants.productsByBrand}/$brandId',
      );
      return (response.data as List)
          .map((json) => ProductModel.fromJson(
                json as Map<String, dynamic>,
              ))
          .toList();
    } catch (e) {
      if (_useDummyData) {
        await Future.delayed(
          const Duration(milliseconds: 400),
        );
        return DummyData.products;
      }
      rethrow;
    }
  }

  Future<List<ProductModel>> getProductsByCategory(
    int categoryId,
  ) async {
    try {
      final response = await _dio.get(
        '${ApiConstants.productsByCategory}/$categoryId',
      );
      return (response.data as List)
          .map((json) => ProductModel.fromJson(
                json as Map<String, dynamic>,
              ))
          .toList();
    } catch (e) {
      if (_useDummyData) {
        await Future.delayed(
          const Duration(milliseconds: 400),
        );
        return DummyData.products
            .where((p) => p.categoryId == categoryId)
            .toList();
      }
      rethrow;
    }
  }

  Future<List<ProductModel>> getFeaturedProducts() async {
    // BE doesn't have a "featured" endpoint,
    // so use active products and filter.
    try {
      final products = await getActiveProducts();
      return products.take(10).toList();
    } catch (e) {
      if (_useDummyData) {
        await Future.delayed(
          const Duration(milliseconds: 400),
        );
        return DummyData.products.where((p) => p.isHot || p.isNew).toList();
      }
      rethrow;
    }
  }

  Future<List<ProductModel>> getFlashSaleProducts() async {
    // BE doesn't have flash sale; reuse active products.
    try {
      final products = await getActiveProducts();
      return products.where((p) => p.isOnSale).toList();
    } catch (e) {
      if (_useDummyData) {
        await Future.delayed(
          const Duration(milliseconds: 400),
        );
        return DummyData.products.where((p) => p.isOnSale).toList();
      }
      rethrow;
    }
  }

  Future<List<ProductModel>> searchProducts(
    String query,
  ) async {
    try {
      final products = await getProducts(
        search: query,
      );
      return products;
    } catch (e) {
      if (_useDummyData) {
        await Future.delayed(
          const Duration(milliseconds: 300),
        );
        return DummyData.products
            .where(
              (p) => p.name.toLowerCase().contains(
                    query.toLowerCase(),
                  ),
            )
            .toList();
      }
      rethrow;
    }
  }

  Future<List<String>> searchSuggestions(
    String query,
  ) async {
    try {
      final products = await searchProducts(query);
      return products.map((p) => p.name).take(5).toList();
    } catch (e) {
      if (_useDummyData) {
        await Future.delayed(
          const Duration(milliseconds: 200),
        );
        return DummyData.products
            .where(
              (p) => p.name.toLowerCase().contains(
                    query.toLowerCase(),
                  ),
            )
            .map((p) => p.name)
            .take(5)
            .toList();
      }
      rethrow;
    }
  }

  /// POST /api/products/product (multipart)
  /// Server uses @RequestPart("product") + @RequestPart("img")
  /// → JSON part 'product' + file part 'img'.
  Future<ProductModel> createProduct({
    required String name,
    required String description,
    required int price,
    required int stockQuantity,
    required bool active,
    required int versionId,
    required int brandId,
    required int categoryId,
    required bool type,
    String? imagePath,
  }) async {
    final formData = FormData();
    formData.files.add(MapEntry(
      'product',
      MultipartFile.fromString(
        jsonEncode({
          'name': name,
          'description': description,
          'price': price,
          'stockQuantity': stockQuantity,
          'active': active,
          'versionId': versionId,
          'brandId': brandId,
          'categoryId': categoryId,
          'type': type,
        }),
        contentType: DioMediaType('application', 'json'),
      ),
    ));
    if (imagePath != null) {
      formData.files.add(MapEntry(
        'img',
        await MultipartFile.fromFile(imagePath),
      ));
    }
    final response = await _dio.post(
      ApiConstants.products,
      data: formData,
    );
    return ProductModel.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  /// PUT /api/products/product (multipart)
  /// Server uses @RequestPart("product") + @RequestPart("img", optional)
  /// → JSON part 'product' + optional file part 'img'.
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
    bool? type,
    String? imagePath,
  }) async {
    final productData = <String, dynamic>{'id': id};
    if (name != null) productData['name'] = name;
    if (description != null) productData['description'] = description;
    if (price != null) productData['price'] = price;
    if (stockQuantity != null) productData['stockQuantity'] = stockQuantity;
    if (active != null) productData['active'] = active;
    if (versionId != null) productData['versionId'] = versionId;
    if (brandId != null) productData['brandId'] = brandId;
    if (categoryId != null) productData['categoryId'] = categoryId;
    if (type != null) productData['type'] = type;
    final formData = FormData();
    formData.files.add(MapEntry(
      'product',
      MultipartFile.fromString(
        jsonEncode(productData),
        contentType: DioMediaType('application', 'json'),
      ),
    ));
    if (imagePath != null) {
      formData.files.add(MapEntry(
        'img',
        await MultipartFile.fromFile(imagePath),
      ));
    }
    final response = await _dio.put(
      ApiConstants.products,
      data: formData,
    );
    return ProductModel.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  /// DELETE /api/products/product/{id}
  Future<void> deleteProduct(int id) async {
    await _dio.delete(
      '${ApiConstants.products}/$id',
    );
  }
}
