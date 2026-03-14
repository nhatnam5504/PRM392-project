import 'package:flutter/foundation.dart';

/// Maps to BE ProductService's ProductResponse.
///
/// BE fields: id, name, description, price, quantity, reserve,
///   imgUrl, active, versionName, brandName, categoryName
///
/// Extra UI fields (slug, originalPrice, rating, isHot, etc.) are
/// derived or kept with defaults so views don't break.
class ProductModel {
  final int id;
  final String name;
  final String slug;
  final String brandName;
  final int categoryId;
  final String categoryName;
  final double price;
  final double? originalPrice;
  final double rating;
  final int reviewCount;
  final int stockQuantity; // maps from BE "quantity"
  final int reserve; // from BE
  final bool isInStock;
  final bool isHot;
  final bool isNew;
  final bool isFlashSale;
  final List<String> imageUrls; // from BE "imgUrl" (single)
  final String description;
  final Map<String, String> specifications;
  final bool active; // from BE
  final String versionName; // from BE

  const ProductModel({
    required this.id,
    required this.name,
    this.slug = '',
    required this.brandName,
    this.categoryId = 0,
    required this.categoryName,
    required this.price,
    this.originalPrice,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.stockQuantity = 0,
    this.reserve = 0,
    this.isInStock = true,
    this.isHot = false,
    this.isNew = false,
    this.isFlashSale = false,
    this.imageUrls = const [],
    this.description = '',
    this.specifications = const {},
    this.active = true,
    this.versionName = '',
  });

  bool get isOnSale => originalPrice != null && originalPrice! > price;

  double get discountPercent =>
      isOnSale ? (originalPrice! - price) / originalPrice! : 0;

  /// Parse from BE ProductResponse JSON.
  /// BE returns: {id, name, description, price, quantity, reserve,
  ///   imgUrl, active, versionName, brandName, categoryName}
  factory ProductModel.fromJson(
    Map<String, dynamic> json,
  ) {
    final quantity =
        json['quantity'] as int? ?? json['stockQuantity'] as int? ?? 0;

    // BE returns imgUrls (array) or legacy imgUrl (single string)
    List<String> resolvedImageUrls = [];
    try {
      final rawImgUrls = json['imgUrls'];
      final rawImgUrl = json['imgUrl'];

      if (rawImgUrls is List && rawImgUrls.isNotEmpty) {
        resolvedImageUrls = rawImgUrls
            .where((e) => e is String && e.isNotEmpty)
            .map((e) => e as String)
            .toList();
      } else if (rawImgUrl is String && rawImgUrl.isNotEmpty) {
        resolvedImageUrls = [rawImgUrl];
      } else if (json['imageUrls'] is List) {
        resolvedImageUrls = (json['imageUrls'] as List)
            .where((e) => e is String && e.isNotEmpty)
            .map((e) => e as String)
            .toList();
      }
    } catch (e) {
      debugPrint('Error parsing image URLs: $e for product ${json['id']}');
    }

    return ProductModel(
      id: json['id'] as int,
      name: json['name'] as String,
      slug: json['slug'] as String? ?? '',
      brandName: (json['brandName'] ?? '') as String,
      categoryId: json['categoryId'] as int? ?? 0,
      categoryName: (json['categoryName'] ?? '') as String,
      price: (json['price'] as num).toDouble(),
      originalPrice: (json['originalPrice'] as num?)?.toDouble(),
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: json['reviewCount'] as int? ?? 0,
      stockQuantity: quantity,
      reserve: json['reserve'] as int? ?? 0,
      isInStock: json['isInStock'] as bool? ?? (quantity > 0),
      isHot: json['isHot'] as bool? ?? false,
      isNew: json['isNew'] as bool? ?? false,
      isFlashSale: json['isFlashSale'] as bool? ?? false,
      imageUrls: resolvedImageUrls,
      description: json['description'] as String? ?? '',
      specifications: (json['specifications'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(k, v as String),
          ) ??
          {},
      active: json['active'] as bool? ?? true,
      versionName: json['versionName'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price.toInt(),
      'quantity': stockQuantity,
      'reserve': reserve,
      'imgUrl': imageUrls.isNotEmpty ? imageUrls.first : null,
      'active': active,
      'versionName': versionName,
      'brandName': brandName,
      'categoryName': categoryName,
    };
  }
}
