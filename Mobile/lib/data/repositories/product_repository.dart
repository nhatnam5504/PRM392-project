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
          products = products
              .where((p) => p.categoryId == cid)
              .toList();
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
            products = products
                .where((p) => p.categoryId == cid)
                .toList();
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
            .where(
                (p) => p.categoryId == categoryId)
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
        return DummyData.products
            .where((p) => p.isHot || p.isNew)
            .toList();
      }
      rethrow;
    }
  }

  Future<List<ProductModel>> getFlashSaleProducts() async {
    // BE doesn't have flash sale; reuse active products.
    try {
      final products = await getActiveProducts();
      return products
          .where((p) => p.isOnSale)
          .toList();
    } catch (e) {
      if (_useDummyData) {
        await Future.delayed(
          const Duration(milliseconds: 400),
        );
        return DummyData.products
            .where((p) => p.isOnSale)
            .toList();
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
      return products
          .map((p) => p.name)
          .take(5)
          .toList();
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
    final formData = FormData.fromMap({
      'name': name,
      'description': description,
      'price': price,
      'stockQuantity': stockQuantity,
      'active': active,
      'versionId': versionId,
      'brandId': brandId,
      'categoryId': categoryId,
      if (imagePath != null)
        'img': await MultipartFile.fromFile(imagePath),
    });
    final response = await _dio.post(
      ApiConstants.products,
      data: formData,
      options: Options(
        contentType: 'multipart/form-data',
      ),
    );
    return ProductModel.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  /// PUT /api/products/product (multipart)
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
    final map = <String, dynamic>{'id': id};
    if (name != null) map['name'] = name;
    if (description != null) map['description'] = description;
    if (price != null) map['price'] = price;
    if (stockQuantity != null) map['stockQuantity'] = stockQuantity;
    if (active != null) map['active'] = active;
    if (versionId != null) map['versionId'] = versionId;
    if (brandId != null) map['brandId'] = brandId;
    if (categoryId != null) map['categoryId'] = categoryId;
    if (imagePath != null) {
      map['img'] = await MultipartFile.fromFile(imagePath);
    }
    final formData = FormData.fromMap(map);
    final response = await _dio.put(
      ApiConstants.products,
      data: formData,
      options: Options(
        contentType: 'multipart/form-data',
      ),
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
