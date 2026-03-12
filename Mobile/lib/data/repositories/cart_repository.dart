import 'dart:convert';

import 'package:hive/hive.dart';

import '../../core/constants/app_constants.dart';
import '../models/cart_item_model.dart';
import '../models/product_model.dart';

class CartRepository {
  Box get _box => Hive.box(AppConstants.cartBoxName);

  Future<List<CartItemModel>> getCartItems() async {
    final items = <CartItemModel>[];
    for (final key in _box.keys) {
      final raw = _box.get(key);
      if (raw != null) {
        final map = Map<String, dynamic>.from(
          jsonDecode(raw as String)
              as Map<dynamic, dynamic>,
        );
        items.add(CartItemModel.fromJson(map));
      }
    }
    return items;
  }

  Future<void> addItem(ProductModel product) async {
    final key = product.id.toString();
    final existing = _box.get(key);

    if (existing != null) {
      final map = Map<String, dynamic>.from(
        jsonDecode(existing as String)
            as Map<dynamic, dynamic>,
      );
      final item = CartItemModel.fromJson(map);
      final updated = item.copyWith(
        quantity: item.quantity + 1,
      );
      await _box.put(
        key,
        jsonEncode(updated.toJson()),
      );
    } else {
      final item = CartItemModel(
        productId: product.id,
        productName: product.name,
        brandName: product.brandName,
        imageUrl: product.imageUrls.isNotEmpty
            ? product.imageUrls.first
            : '',
        price: product.price,
        originalPrice: product.originalPrice,
        quantity: 1,
        maxQuantity: product.stockQuantity,
      );
      await _box.put(
        key,
        jsonEncode(item.toJson()),
      );
    }
  }

  Future<void> updateQuantity(
    int productId,
    int quantity,
  ) async {
    final key = productId.toString();
    if (quantity <= 0) {
      await _box.delete(key);
      return;
    }
    final existing = _box.get(key);
    if (existing != null) {
      final map = Map<String, dynamic>.from(
        jsonDecode(existing as String)
            as Map<dynamic, dynamic>,
      );
      final item = CartItemModel.fromJson(map);
      final updated =
          item.copyWith(quantity: quantity);
      await _box.put(
        key,
        jsonEncode(updated.toJson()),
      );
    }
  }

  Future<void> removeItem(int productId) async {
    await _box.delete(productId.toString());
  }

  Future<void> clearCart() async {
    await _box.clear();
  }

  int get itemCount {
    int count = 0;
    for (final key in _box.keys) {
      final raw = _box.get(key);
      if (raw != null) {
        final map = Map<String, dynamic>.from(
          jsonDecode(raw as String)
              as Map<dynamic, dynamic>,
        );
        count +=
            (map['quantity'] as int? ?? 0);
      }
    }
    return count;
  }
}
