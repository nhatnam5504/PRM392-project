import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/format_price.dart';
import '../view_models/product_view_model.dart';

class ProductDetailScreen extends StatefulWidget {
  final int productId;

  const ProductDetailScreen({
    super.key,
    required this.productId,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductViewModel>().loadProductDetail(widget.productId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductViewModel>(
      builder: (context, vm, _) {
        final product = vm.selectedProduct;

        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.pop(),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.share_outlined),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.favorite_border),
                onPressed: () {},
              ),
            ],
          ),
          body: vm.isLoading && product == null
              ? const Center(child: CircularProgressIndicator())
              : vm.errorMessage != null && product == null
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(vm.errorMessage!),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: () =>
                                vm.loadProductDetail(widget.productId),
                            child: const Text('Thử lại'),
                          ),
                        ],
                      ),
                    )
                  : product == null
                      ? const Center(child: Text('Không tìm thấy sản phẩm'))
                      : SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Image
                              Container(
                                height: 300,
                                width: double.infinity,
                                color: AppColors.inputBackground,
                                child: product.imageUrls.isNotEmpty
                                    ? Image.network(
                                        product.imageUrls.first,
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        height: 300,
                                        errorBuilder: (_, __, ___) =>
                                            const Center(
                                          child: Icon(
                                            Icons.image_outlined,
                                            size: 80,
                                            color: AppColors.border,
                                          ),
                                        ),
                                      )
                                    : const Center(
                                        child: Icon(
                                          Icons.image_outlined,
                                          size: 80,
                                          color: AppColors.border,
                                        ),
                                      ),
                              ),
                              // Product info
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product.brandName,
                                      style: AppTextStyles.labelSm.copyWith(
                                        color: AppColors.primary,
                                        letterSpacing: 0.8,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      product.name,
                                      style: AppTextStyles.headingLg,
                                    ),
                                    const SizedBox(height: 8),
                                    // Version
                                    if (product.versionName.isNotEmpty)
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 8),
                                        child: Text(
                                          'Phiên bản: ${product.versionName}',
                                          style: AppTextStyles.bodySm.copyWith(
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ),
                                    // Category
                                    if (product.categoryName.isNotEmpty)
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 8),
                                        child: Text(
                                          'Danh mục: ${product.categoryName}',
                                          style: AppTextStyles.bodySm.copyWith(
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Text(
                                          formatVND(product.price),
                                          style: AppTextStyles.priceLg,
                                        ),
                                        if (product.isOnSale) ...[
                                          const SizedBox(width: 12),
                                          Text(
                                            formatVND(
                                              product.originalPrice!,
                                            ),
                                            style: AppTextStyles.priceStrike
                                                .copyWith(
                                              fontSize: 16,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: AppColors.error,
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              '-${(product.discountPercent * 100).round()}%',
                                              style: AppTextStyles.labelSm
                                                  .copyWith(
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Text(
                                          product.isInStock
                                              ? 'Còn hàng (${product.stockQuantity})'
                                              : 'Hết hàng',
                                          style:
                                              AppTextStyles.labelBold.copyWith(
                                            color: product.isInStock
                                                ? AppColors.success
                                                : AppColors.error,
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: product.active
                                                ? AppColors.success
                                                    .withOpacity(0.1)
                                                : AppColors.error
                                                    .withOpacity(0.1),
                                            borderRadius:
                                                BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            product.active
                                                ? 'Đang bán'
                                                : 'Ngừng bán',
                                            style:
                                                AppTextStyles.labelSm.copyWith(
                                              color: product.active
                                                  ? AppColors.success
                                                  : AppColors.error,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 24),
                                    // Description
                                    Text(
                                      'Mô tả sản phẩm',
                                      style: AppTextStyles.headingSm,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      product.description.isNotEmpty
                                          ? product.description
                                          : 'Chưa có mô tả',
                                      style: AppTextStyles.bodyMd,
                                    ),
                                    const SizedBox(height: 24),
                                    // Specifications
                                    if (product.specifications.isNotEmpty) ...[
                                      Text(
                                        'Thông số kỹ thuật',
                                        style: AppTextStyles.headingSm,
                                      ),
                                      const SizedBox(height: 8),
                                      ...product.specifications.entries.map(
                                        (entry) => Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: 8,
                                          ),
                                          child: Row(
                                            children: [
                                              SizedBox(
                                                width: 120,
                                                child: Text(
                                                  entry.key,
                                                  style: AppTextStyles.bodyMd
                                                      .copyWith(
                                                    color:
                                                        AppColors.textSecondary,
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: Text(
                                                  entry.value,
                                                  style: AppTextStyles.bodyMd,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                    const SizedBox(height: 80),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
          bottomNavigationBar: product == null
              ? null
              : Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: AppColors.surface,
                    border: Border(
                      top: BorderSide(
                        color: AppColors.borderLight,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.border,
                          ),
                        ),
                        child: const Icon(
                          Icons.favorite_border,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SizedBox(
                          height: 52,
                          child: ElevatedButton.icon(
                            onPressed: product.isInStock ? () {} : null,
                            icon: const Icon(
                              Icons.shopping_cart_outlined,
                            ),
                            label: Text(
                              product.isInStock
                                  ? 'Thêm vào giỏ hàng'
                                  : 'Hết hàng',
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }
}
