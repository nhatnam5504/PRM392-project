import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../config/app_text_styles.dart';
import '../models/cart_item.dart';

/// Widget hiển thị một sản phẩm trong giỏ hàng
/// Bao gồm ảnh, tên, giá, và nút tăng/giảm số lượng
class CartItemWidget extends StatelessWidget {
  final CartItem cartItem;
  final VoidCallback? onIncrease; // Callback tăng số lượng
  final VoidCallback? onDecrease; // Callback giảm số lượng
  final VoidCallback? onRemove; // Callback xóa sản phẩm

  const CartItemWidget({
    super.key,
    required this.cartItem,
    this.onIncrease,
    this.onDecrease,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Ảnh sản phẩm
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.sm),
            child: Image.network(
              cartItem.product.imageUrl,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 80,
                  height: 80,
                  color: AppColors.background,
                  child: const Icon(
                    Icons.image_outlined,
                    color: AppColors.textHint,
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          // Thông tin sản phẩm
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tên sản phẩm
                Text(
                  cartItem.product.name,
                  style: AppTextStyles.title.copyWith(fontSize: 14),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.xs),
                // Mô tả ngắn
                Text(
                  cartItem.product.description.length > 40
                      ? '${cartItem.product.description.substring(0, 40)}...'
                      : cartItem.product.description,
                  style: AppTextStyles.caption,
                  maxLines: 1,
                ),
                const SizedBox(height: AppSpacing.sm),
                // Giá và bộ đếm số lượng
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Giá tiền
                    Text(
                      _formatPrice(cartItem.product.price),
                      style: AppTextStyles.price,
                    ),
                    // Nút tăng/giảm số lượng
                    _buildQuantitySelector(),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Widget bộ chọn số lượng (+/-)
  Widget _buildQuantitySelector() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Nút giảm
          _buildQuantityButton(icon: Icons.remove, onTap: onDecrease),
          // Số lượng hiện tại
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              '${cartItem.quantity}',
              style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          // Nút tăng
          _buildQuantityButton(icon: Icons.add, onTap: onIncrease),
        ],
      ),
    );
  }

  /// Nút tăng hoặc giảm số lượng
  Widget _buildQuantityButton({required IconData icon, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        child: Icon(icon, size: 16, color: AppColors.textPrimary),
      ),
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
