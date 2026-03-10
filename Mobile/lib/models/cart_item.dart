import 'product.dart';

/// Model đại diện cho một sản phẩm trong giỏ hàng
class CartItem {
  final Product product; // Sản phẩm
  int quantity; // Số lượng

  CartItem({required this.product, this.quantity = 1});

  /// Tính tổng tiền cho sản phẩm này (giá x số lượng)
  double get totalPrice => product.price * quantity;
}
