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
      height: 330,
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
      onTap: () => context.push(
        '/products/${product.id}',
      ),
      child: Container(
        width: 173,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1A000000),
              blurRadius: 3,
              offset: Offset(0, 1),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            // Image area
            Stack(
              children: [
                Container(
                  height: 173,
                  width: double.infinity,
                  color: AppColors.inputBackground,
                  child: product.imageUrls.isNotEmpty
                      ? Image.network(
                          product.imageUrls.first,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: 173,
                          errorBuilder: (_, __, ___) =>
                              const Icon(
                            Icons.image_outlined,
                            size: 48,
                            color: AppColors.border,
                          ),
                        )
                      : const Icon(
                          Icons.image_outlined,
                          size: 48,
                          color: AppColors.border,
                        ),
                ),
                if (product.isHot)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        borderRadius:
                            BorderRadius.circular(6),
                      ),
                      child: Text(
                        'HOT',
                        style: AppTextStyles.labelSm
                            .copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                if (product.isNew && !product.isHot)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius:
                            BorderRadius.circular(6),
                      ),
                      child: Text(
                        'NEW',
                        style: AppTextStyles.labelSm
                            .copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            // Info area
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    product.brandName,
                    style: AppTextStyles.labelSm
                        .copyWith(
                      color: AppColors.primary,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.name,
                    style: AppTextStyles.labelMd,
                    maxLines: 2,
                    overflow:
                        TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Consumer<ProductRatingViewModel>(
                    builder: (context, ratingVm, _) {
                      final data = ratingVm
                          .getRating(product.id);
                      final rating =
                          data?.averageRating ?? 0.0;
                      final count =
                          data?.totalCount ?? 0;
                      return Row(
                        children: [
                          ...List.generate(5, (i) {
                            if (i < rating.floor()) {
                              return const Icon(
                                Icons.star,
                                color: AppColors.star,
                                size: 14,
                              );
                            } else if (i <
                                    rating.ceil() &&
                                rating % 1 >= 0.5) {
                              return const Icon(
                                Icons.star_half,
                                color: AppColors.star,
                                size: 14,
                              );
                            } else {
                              return const Icon(
                                Icons.star_border,
                                color: AppColors.star,
                                size: 14,
                              );
                            }
                          }),
                          const SizedBox(width: 4),
                          Text(
                            rating.toStringAsFixed(1),
                            style:
                                AppTextStyles.labelMd,
                          ),
                          if (count > 0) ...[
                            const SizedBox(width: 2),
                            Text(
                              '($count)',
                              style: AppTextStyles
                                  .bodySm,
                            ),
                          ],
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formatVND(product.price),
                    style: AppTextStyles.priceMd,
                  ),
                  if (product.isOnSale)
                    Text(
                      formatVND(
                        product.originalPrice!,
                      ),
                      style:
                          AppTextStyles.priceStrike,
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
