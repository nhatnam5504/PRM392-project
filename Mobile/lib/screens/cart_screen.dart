import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../config/app_text_styles.dart';
import '../config/app_routes.dart';
import '../models/cart_item.dart';
import '../models/product.dart';
import '../data/sample_data.dart';
import '../widgets/cart_item_widget.dart';

/// Màn hình giỏ hàng
/// Hiển thị danh sách sản phẩm trong giỏ, mã giảm giá,
/// tổng tiền và nút thanh toán
class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  // Controller cho ô nhập mã giảm giá
  final TextEditingController _couponController = TextEditingController();

  // Danh sách sản phẩm trong giỏ hàng (dữ liệu mẫu)
  late List<CartItem> _cartItems;

  // Giá trị giảm giá (mặc định 250.000đ)
  double _discount = 250000;

  // Trạng thái đã áp dụng mã giảm giá chưa
  bool _couponApplied = false;

  @override
  void initState() {
    super.initState();
    // Khởi tạo giỏ hàng mẫu với 2 sản phẩm đầu tiên
    _cartItems = [
      CartItem(product: SampleData.products[0], quantity: 1),
      CartItem(product: SampleData.products[1], quantity: 2),
    ];
  }

  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
  }

  /// Tính tạm tính (chưa trừ giảm giá)
  double get _subtotal {
    return _cartItems.fold(0, (sum, item) => sum + item.totalPrice);
  }

  /// Tính tổng tiền (đã trừ giảm giá)
  double get _total {
    final total = _subtotal - _discount;
    return total > 0 ? total : 0;
  }

  /// Tăng số lượng sản phẩm
  void _increaseQuantity(int index) {
    setState(() {
      _cartItems[index].quantity++;
    });
  }

  /// Giảm số lượng sản phẩm (xóa nếu về 0)
  void _decreaseQuantity(int index) {
    setState(() {
      if (_cartItems[index].quantity > 1) {
        _cartItems[index].quantity--;
      } else {
        _cartItems.removeAt(index);
      }
    });
  }

  /// Xóa toàn bộ giỏ hàng
  void _clearCart() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa giỏ hàng'),
        content: const Text('Bạn có chắc muốn xóa tất cả sản phẩm?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _cartItems.clear();
              });
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text(
              'Xóa hết',
              style: TextStyle(color: AppColors.white),
            ),
          ),
        ],
      ),
    );
  }

  /// Áp dụng mã giảm giá
  void _applyCoupon() {
    if (_couponController.text.isNotEmpty) {
      setState(() {
        _couponApplied = true;
        _discount = 250000; // Giả lập áp dụng mã giảm 250.000đ
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Áp dụng mã giảm giá thành công!'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  /// Xử lý thanh toán
  void _handleCheckout() {
    // Chuyển đến màn hình đặt hàng thành công
    Navigator.pushNamed(context, AppRoutes.orderSuccess, arguments: _total);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0.5,
        title: const Text(
          'Giỏ hàng của bạn',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        actions: [
          // Nút xóa hết
          if (_cartItems.isNotEmpty)
            TextButton(
              onPressed: _clearCart,
              child: const Text(
                'Xóa hết',
                style: TextStyle(color: AppColors.error),
              ),
            ),
        ],
      ),
      body: _cartItems.isEmpty
          ? _buildEmptyCart()
          : Column(
              children: [
                // Danh sách sản phẩm trong giỏ
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    itemCount: _cartItems.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AppSpacing.md),
                    itemBuilder: (context, index) {
                      return CartItemWidget(
                        cartItem: _cartItems[index],
                        onIncrease: () => _increaseQuantity(index),
                        onDecrease: () => _decreaseQuantity(index),
                        onRemove: () {
                          setState(() {
                            _cartItems.removeAt(index);
                          });
                        },
                      );
                    },
                  ),
                ),

                // Phần thanh toán (mã giảm giá + tổng tiền + nút)
                _buildCheckoutSection(),
              ],
            ),
    );
  }

  /// Hiển thị khi giỏ hàng trống
  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 80,
            color: AppColors.textHint,
          ),
          const SizedBox(height: AppSpacing.md),
          Text('Giỏ hàng trống', style: AppTextStyles.title),
          const SizedBox(height: AppSpacing.sm),
          Text('Hãy thêm sản phẩm vào giỏ hàng', style: AppTextStyles.caption),
          const SizedBox(height: AppSpacing.lg),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
            ),
            child: const Text('Tiếp tục mua sắm'),
          ),
        ],
      ),
    );
  }

  /// Xây dựng phần thanh toán bên dưới
  Widget _buildCheckoutSection() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Ô nhập mã giảm giá
          _buildCouponSection(),

          const SizedBox(height: AppSpacing.md),
          const Divider(color: AppColors.border),
          const SizedBox(height: AppSpacing.sm),

          // Tạm tính
          _buildPriceRow('Tạm tính', _subtotal),
          const SizedBox(height: AppSpacing.sm),

          // Giảm giá
          _buildPriceRow('Giảm giá', -_discount, isDiscount: true),
          const SizedBox(height: AppSpacing.sm),

          const Divider(color: AppColors.border),
          const SizedBox(height: AppSpacing.sm),

          // Tổng cộng
          _buildPriceRow('Tổng cộng', _total, isTotal: true),

          const SizedBox(height: AppSpacing.md),

          // Nút tiến hành thanh toán
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _handleCheckout,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                elevation: 2,
              ),
              child: const Text(
                'Tiến hành thanh toán',
                style: AppTextStyles.button,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Xây dựng phần nhập mã giảm giá
  Widget _buildCouponSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mã Giảm Giá',
          style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            // Ô nhập mã
            Expanded(
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: TextField(
                  controller: _couponController,
                  style: AppTextStyles.body,
                  decoration: InputDecoration(
                    hintText: 'Nhập mã giảm giá',
                    hintStyle: AppTextStyles.caption,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            // Nút áp dụng
            SizedBox(
              height: 44,
              child: ElevatedButton(
                onPressed: _applyCoupon,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                ),
                child: const Text('Áp dụng'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Xây dựng một dòng hiển thị giá (nhãn + giá trị)
  Widget _buildPriceRow(
    String label,
    double amount, {
    bool isTotal = false,
    bool isDiscount = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: isTotal ? AppTextStyles.title : AppTextStyles.body),
        Text(
          '${isDiscount ? "-" : ""}${_formatPrice(amount.abs())}',
          style: isTotal
              ? AppTextStyles.price.copyWith(fontSize: 18)
              : isDiscount
              ? AppTextStyles.body.copyWith(color: AppColors.success)
              : AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  /// Format giá tiền theo định dạng VNĐ
  String _formatPrice(double price) {
    final formatted = price
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]}.',
        );
    return '${formatted}đ';
  }
}
