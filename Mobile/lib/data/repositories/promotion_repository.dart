import 'package:dio/dio.dart';

import '../../core/constants/api_constants.dart';
import '../models/promotion_model.dart';
import '../models/product_model.dart';
import '../services/api_service.dart';

class PromotionRepository {
  final Dio _dio = ApiService().client;

  Future<List<PromotionModel>>
      getPromotions() async {
    final response = await _dio.get(
      ApiConstants.orderPromotions,
    );
    final list = response.data as List;
    return list
        .map(
          (json) => PromotionModel.fromJson(
            json as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  Future<ProductModel> getProductById(
    int id,
  ) async {
    final response = await _dio.get(
      '${ApiConstants.productById}/$id',
    );
    return ProductModel.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  Future<List<ProductModel>> getBogoProducts(
    List<int> productIds,
  ) async {
    final results = await Future.wait(
      productIds.map(
        (id) => getProductById(id),
      ),
    );
    return results;
  }

  Future<PromotionModel> createPromotion(
    PromotionModel promotion,
  ) async {
    final response = await _dio.post(
      ApiConstants.orderPromotions,
      data: promotion.toJson(),
    );
    return PromotionModel.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  Future<PromotionModel> updatePromotion(
    PromotionModel promotion,
  ) async {
    final response = await _dio.put(
      ApiConstants.orderPromotions,
      data: promotion.toJson(),
    );
    return PromotionModel.fromJson(
      response.data as Map<String, dynamic>,
    );
  }
}
