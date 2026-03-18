import '../models/check_available_model.dart';
import '../models/cart_item_model.dart';

/// Helper class to build order details from cart items
class OrderDetailBuilder {
  /// Build order details for check available request
  /// Separates bought items from gift items
  static List<OrderDetailRequest> buildFromCartItems(
    List<CartItemModel> items, {
    Map<int, bool>? giftProductIds,
  }) {
    final details = <OrderDetailRequest>[];
    giftProductIds ??= {};

    for (final item in items) {
      final isGift = giftProductIds[item.productId] ?? false;

      // If it's a gift, add subtotal as 0
      if (isGift) {
        details.add(
          OrderDetailRequest(
            productId: item.productId,
            quantity: item.quantity,
            subtotal: 0,
            type: 'gift',
          ),
        );
      } else {
        // Regular buy item
        details.add(
          OrderDetailRequest(
            productId: item.productId,
            quantity: item.quantity,
            subtotal: (item.price * item.quantity).toDouble(),
            type: 'buy',
          ),
        );
      }
    }

    return details;
  }

  /// Calculate total price (excluding gift items)
  static double calculateTotalPrice(
    List<OrderDetailRequest> details,
  ) {
    return details
        .where((d) => d.type == 'buy')
        .fold(
          0.0,
          (sum, item) => sum + item.subtotal,
        );
  }

  /// Calculate base price (including gift items)
  static double calculateBasePrice(
    List<OrderDetailRequest> details,
  ) {
    return details.fold(
      0.0,
      (sum, item) => sum + item.subtotal,
    );
  }
}

