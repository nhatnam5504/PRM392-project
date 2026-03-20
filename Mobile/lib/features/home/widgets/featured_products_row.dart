import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/format_price.dart';
import '../../../data/models/product_model.dart';
import '../../shared/view_models/product_rating_view_model.dart';

class FeaturedProductsRow extends StatelessWidget {
  final List<ProductModel> products;

  const FeaturedProductsRow({
    super.key,
    required this.products,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 360,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
        ),
        itemCount: products.length,
        separatorBuilder: (_, __) =>
            const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final product = products[index];
          return _ProductCard(product: product);
        },
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final ProductModel product;

  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/products/${product.id}'),
      child: Container(
        width: 190,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.surfaceDark, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Premium Image Area
            Stack(
              children: [
                Container(
                  height: 180,
                  width: double.infinity,
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceDark.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Hero(
                      tag: 'product_image_${product.id}',
                      child: product.imageUrls.isNotEmpty
                          ? Image.network(
                              product.imageUrls.first,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported_outlined, color: AppColors.textHint, size: 32),
                            )
                          : const Icon(Icons.image_not_supported_outlined, color: AppColors.textHint, size: 32),
                    ),
                  ),
                ),
                // Badges
                if (product.isHot || product.isNew || product.isOnSale)
                  Positioned(
                    top: 16,
                    left: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (product.isHot) _PremiumBadge(text: '🔥 HOT', color: AppColors.error),
                        if (product.isNew) ...[
                          const SizedBox(height: 6),
                          _PremiumBadge(text: '✨ NEW', color: AppColors.primary),
                        ],
                      ],
                    ),
                  ),
                // Favorite Button
                Positioned(
                  top: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 5)],
                    ),
                    child: const Icon(Icons.favorite_border_rounded, size: 16, color: AppColors.textSecondary),
                  ),
                ),
              ],
            ),
            // Info Area
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        product.brandName.toUpperCase(),
                        style: AppTextStyles.labelBold.copyWith(
                          color: AppColors.primary,
                          fontSize: 9,
                          letterSpacing: 1.5,
                        ),
                      ),
                      Consumer<ProductRatingViewModel>(
                        builder: (context, ratingVm, _) {
                          final data = ratingVm.getRating(product.id);
                          final rating = data?.averageRating ?? 0.0;
                          return Row(
                            children: [
                              const Icon(Icons.star_rounded, color: Colors.amber, size: 12),
                              const SizedBox(width: 2),
                              Text(
                                rating > 0 ? rating.toStringAsFixed(1) : '-',
                                style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.bold, fontSize: 10),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 4), // Reduced from 8
                  Text(
                    product.name,
                    style: AppTextStyles.labelBold.copyWith(
                      color: AppColors.textHeading,
                      fontSize: 14, // Reduced from 15
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8), // Reduced from 12
                  // Price & Add Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (product.isOnSale)
                              Text(
                                formatVND(product.originalPrice!),
                                style: AppTextStyles.caption.copyWith(
                                  decoration: TextDecoration.lineThrough,
                                  fontSize: 10,
                                ),
                              ),
                            Text(
                              formatVND(product.price),
                              style: AppTextStyles.priceMd.copyWith(
                                color: AppColors.primary,
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Quick Add Button
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.primary, Color(0xFF22D3EE)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.add_shopping_cart_rounded, color: Colors.white, size: 18),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PremiumBadge extends StatelessWidget {
  final String text;
  final Color color;

  const _PremiumBadge({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900),
      ),
    );
  }
}
