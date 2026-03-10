import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../config/app_text_styles.dart';
import '../models/product.dart';

/// Widget card hiển thị thông tin sản phẩm trong danh sách
/// Dùng trong màn hình danh mục sản phẩm
class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap; // Callback khi nhấn vào sản phẩm

  const ProductCard({super.key, required this.product, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(AppRadius.md),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Phần ảnh sản phẩm
            _buildProductImage(),
            // Phần thông tin sản phẩm
            Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tên sản phẩm
                  Text(
                    product.name,
                    style: AppTextStyles.title.copyWith(fontSize: 14),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  // Thương hiệu
                  Text(product.brand, style: AppTextStyles.caption),
                  const SizedBox(height: AppSpacing.sm),
                  // Giá tiền
                  _buildPriceRow(),
                  const SizedBox(height: AppSpacing.xs),
                  // Đánh giá
                  _buildRatingRow(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Xây dựng phần ảnh sản phẩm với tag (NEW, HOT)
  Widget _buildProductImage() {
    return Stack(
      children: [
        // Ảnh sản phẩm
        ClipRRect(
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppRadius.md),
          ),
          child: AspectRatio(
            aspectRatio: 1,
            child: Image.network(
              product.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                // Hiển thị placeholder khi ảnh lỗi
                return Container(
                  color: AppColors.background,
                  child: const Icon(
                    Icons.image_outlined,
                    size: 48,
                    color: AppColors.textHint,
                  ),
                );
              },
            ),
          ),
        ),
        // Badge tag (NEW, HOT)
        if (product.tags.isNotEmpty)
          Positioned(
            top: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: product.tags.first == 'NEW'
                    ? AppColors.success
                    : AppColors.badge,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Text(
                product.tags.first,
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
      ],
    );
  }

  /// Xây dựng hàng hiển thị giá (giá mới + giá cũ nếu có)
  Widget _buildPriceRow() {
    return Row(
      children: [
        // Giá hiện tại
        Text(
          _formatPrice(product.price),
          style: AppTextStyles.price.copyWith(fontSize: 14),
        ),
        // Giá gốc (nếu có giảm giá)
        if (product.originalPrice != null) ...[
          const SizedBox(width: AppSpacing.sm),
          Text(
            _formatPrice(product.originalPrice!),
            style: AppTextStyles.priceOld.copyWith(fontSize: 11),
          ),
        ],
      ],
    );
  }

  /// Xây dựng hàng hiển thị đánh giá sao
  Widget _buildRatingRow() {
    return Row(
      children: [
        const Icon(Icons.star, size: 14, color: AppColors.star),
        const SizedBox(width: 2),
        Text(
          product.rating.toString(),
          style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(width: 4),
        Text('(${product.reviewCount})', style: AppTextStyles.caption),
      ],
    );
  }

  /// Format giá tiền theo định dạng VNĐ (ví dụ: 850.000đ)
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
