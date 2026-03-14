import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/format_price.dart';
import '../../cart/view_models/cart_view_model.dart';
import '../view_models/feedback_view_model.dart';
import '../../shared/view_models/product_rating_view_model.dart';
import '../view_models/product_view_model.dart';
import 'product_feedback_section.dart';

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
      context.read<FeedbackViewModel>().loadFeedbacks(widget.productId);
      context.read<ProductRatingViewModel>().loadRating(widget.productId);
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
                              // Image Gallery - Swipeable
                              _ImageGallery(
                                imageUrls: product.imageUrls,
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
                                    // Average rating from feedbacks
                                    Consumer<ProductRatingViewModel>(
                                      builder: (context, ratingVm, _) {
                                        final data = ratingVm
                                            .getRating(product.id);
                                        if (data == null ||
                                            data.totalCount == 0) {
                                          return const SizedBox.shrink();
                                        }
                                        final avg = data.averageRating;
                                        return Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: 8,
                                          ),
                                          child: Row(
                                            children: [
                                              ...List.generate(5, (index) {
                                                if (index < avg.floor()) {
                                                  return const Icon(
                                                    Icons.star,
                                                    size: 18,
                                                    color: AppColors.star,
                                                  );
                                                } else if (index < avg.ceil() &&
                                                    avg % 1 >= 0.5) {
                                                  return const Icon(
                                                    Icons.star_half,
                                                    size: 18,
                                                    color: AppColors.star,
                                                  );
                                                } else {
                                                  return const Icon(
                                                    Icons.star_border,
                                                    size: 18,
                                                    color: AppColors.star,
                                                  );
                                                }
                                              }),
                                              const SizedBox(width: 6),
                                              Text(
                                                avg.toStringAsFixed(1),
                                                style: AppTextStyles.labelBold
                                                    .copyWith(
                                                  color: AppColors.star,
                                                ),
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                '(${data.totalCount} đánh giá)',
                                                style: AppTextStyles.bodySm,
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
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
                                    // Feedback section
                                    ProductFeedbackSection(
                                      productId: product.id,
                                    ),
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
                            onPressed: product.isInStock
                                ? () {
                                    context
                                        .read<CartViewModel>()
                                        .addItem(product);
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Đã thêm vào giỏ hàng',
                                        ),
                                        duration: Duration(
                                          seconds: 1,
                                        ),
                                      ),
                                    );
                                  }
                                : null,
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

/// Swipeable image gallery with dot indicators
class _ImageGallery extends StatefulWidget {
  final List<String> imageUrls;

  const _ImageGallery({required this.imageUrls});

  @override
  State<_ImageGallery> createState() => _ImageGalleryState();
}

class _ImageGalleryState extends State<_ImageGallery> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.imageUrls.isEmpty) {
      return Container(
        height: 300,
        width: double.infinity,
        color: AppColors.inputBackground,
        child: const Center(
          child: Icon(
            Icons.image_outlined,
            size: 80,
            color: AppColors.border,
          ),
        ),
      );
    }

    return Column(
      children: [
        SizedBox(
          height: 300,
          child: Stack(
            children: [
              PageView.builder(
                controller: _pageController,
                itemCount: widget.imageUrls.length,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () => _showFullScreenImage(context, index),
                    child: Container(
                      color: AppColors.inputBackground,
                      child: Image.network(
                        widget.imageUrls[index],
                        fit: BoxFit.contain,
                        width: double.infinity,
                        height: 300,
                        loadingBuilder: (_, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          );
                        },
                        errorBuilder: (_, __, ___) => const Center(
                          child: Icon(
                            Icons.image_not_supported_outlined,
                            size: 60,
                            color: AppColors.border,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              // Image counter badge
              if (widget.imageUrls.length > 1)
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '${_currentPage + 1}/${widget.imageUrls.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        // Dot indicators
        if (widget.imageUrls.length > 1)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                widget.imageUrls.length,
                (index) {
                  final isActive = index == _currentPage;
                  return GestureDetector(
                    onTap: () {
                      _pageController.animateToPage(
                        index,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      width: isActive ? 24 : 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      decoration: BoxDecoration(
                        color: isActive
                            ? AppColors.primary
                            : AppColors.border,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
      ],
    );
  }

  void _showFullScreenImage(BuildContext context, int initialIndex) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _FullScreenImageViewer(
          imageUrls: widget.imageUrls,
          initialIndex: initialIndex,
        ),
      ),
    );
  }
}

/// Full-screen image viewer with pinch-to-zoom
class _FullScreenImageViewer extends StatefulWidget {
  final List<String> imageUrls;
  final int initialIndex;

  const _FullScreenImageViewer({
    required this.imageUrls,
    required this.initialIndex,
  });

  @override
  State<_FullScreenImageViewer> createState() => _FullScreenImageViewerState();
}

class _FullScreenImageViewerState extends State<_FullScreenImageViewer> {
  late PageController _pageController;
  late int _currentPage;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: widget.imageUrls.length > 1
            ? Text(
                '${_currentPage + 1} / ${widget.imageUrls.length}',
                style: const TextStyle(color: Colors.white),
              )
            : null,
        centerTitle: true,
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.imageUrls.length,
        onPageChanged: (index) {
          setState(() => _currentPage = index);
        },
        itemBuilder: (context, index) {
          return InteractiveViewer(
            minScale: 0.5,
            maxScale: 4.0,
            child: Center(
              child: Image.network(
                widget.imageUrls[index],
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.image_not_supported_outlined,
                  size: 80,
                  color: Colors.white54,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

