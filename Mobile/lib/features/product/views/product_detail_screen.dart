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
      if (!mounted) return;
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
          backgroundColor: Colors.white,
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8)],
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 18),
                  onPressed: () => context.pop(),
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8)],
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.share_rounded, color: AppColors.textPrimary, size: 18),
                    onPressed: () {},
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 10, right: 16),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8)],
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.favorite_rounded, color: AppColors.error, size: 18),
                    onPressed: () {},
                  ),
                ),
              ),
            ],
          ),
          body: vm.isLoading && product == null
              ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
              : vm.errorMessage != null && product == null
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.error_outline_rounded, size: 48, color: AppColors.error),
                          const SizedBox(height: 16),
                          Text(vm.errorMessage!, style: AppTextStyles.bodyMd),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: () => vm.loadProductDetail(widget.productId),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            child: const Text('Thử lại', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
                              // Image Gallery
                              _ImageGallery(imageUrls: product.imageUrls, productId: product.id),
                              
                              // Product Main Info
                              Container(
                                transform: Matrix4.translationValues(0, -32, 0),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 20,
                                      offset: Offset(0, -10),
                                    ),
                                  ],
                                ),
                                padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: AppColors.primary.withValues(alpha: 0.12),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Text(
                                            product.brandName.toUpperCase(),
                                            style: AppTextStyles.labelBold.copyWith(
                                              color: AppColors.primary, 
                                              fontSize: 10, 
                                              letterSpacing: 2,
                                            ),
                                          ),
                                        ),
                                        if (product.isOnSale)
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                            decoration: BoxDecoration(
                                              gradient: const LinearGradient(
                                                colors: [AppColors.error, Color(0xFFFF6B6B)],
                                              ),
                                              borderRadius: BorderRadius.circular(10),
                                              boxShadow: [
                                                BoxShadow(color: AppColors.error.withValues(alpha: 0.3), blurRadius: 8),
                                              ],
                                            ),
                                            child: Text(
                                              'GIẢM ${product.discountPercent.toStringAsFixed(0)}%',
                                              style: AppTextStyles.labelBold.copyWith(color: Colors.white, fontSize: 10),
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      product.name,
                                      style: AppTextStyles.headingMd.copyWith(height: 1.25, fontSize: 24, fontWeight: FontWeight.w900),
                                    ),
                                    const SizedBox(height: 20),
                                    
                                    // Rating & Price
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            if (product.isOnSale)
                                              Text(
                                                formatVND(product.originalPrice!),
                                                style: AppTextStyles.priceStrike.copyWith(fontSize: 15, color: AppColors.textHint),
                                              ),
                                            const SizedBox(height: 4),
                                            Text(
                                              formatVND(product.price),
                                              style: AppTextStyles.priceLg.copyWith(
                                                color: AppColors.primary, 
                                                fontSize: 28, 
                                                fontWeight: FontWeight.w900,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Consumer<ProductRatingViewModel>(
                                          builder: (context, ratingVm, _) {
                                            final data = ratingVm.getRating(product.id);
                                            final avg = data?.averageRating ?? 0.0;
                                            return Container(
                                              padding: const EdgeInsets.all(12),
                                              decoration: BoxDecoration(
                                                color: AppColors.surfaceDark.withValues(alpha: 0.5),
                                                borderRadius: BorderRadius.circular(16),
                                                border: Border.all(color: AppColors.surfaceDark),
                                              ),
                                              child: Column(
                                                children: [
                                                  Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      const Icon(Icons.star_rounded, color: Colors.amber, size: 24),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        avg.toStringAsFixed(1),
                                                        style: AppTextStyles.labelBold.copyWith(fontSize: 18, fontWeight: FontWeight.w900),
                                                      ),
                                                    ],
                                                  ),
                                                  Text(
                                                    '${data?.totalCount ?? 0} đánh giá',
                                                    style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.bold, fontSize: 10),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                    
                                    const SizedBox(height: 32),
                                    
                                    // Status & Stock
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: AppColors.surfaceDark.withValues(alpha: 0.3),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(color: AppColors.surfaceDark),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                                        children: [
                                          _StatusItem(
                                            icon: Icons.inventory_2_rounded,
                                            label: product.isInStock ? 'Còn hàng' : 'Hết hàng',
                                            color: product.isInStock ? AppColors.success : AppColors.error,
                                          ),
                                          Container(width: 1, height: 20, color: AppColors.borderLight),
                                          _StatusItem(
                                            icon: Icons.verified_rounded,
                                            label: 'Chính hãng',
                                            color: AppColors.primary,
                                          ),
                                          Container(width: 1, height: 20, color: AppColors.borderLight),
                                          _StatusItem(
                                            icon: Icons.local_shipping_rounded,
                                            label: 'Giao nhanh',
                                            color: const Color(0xFF6366F1), // Indigo accent
                                          ),
                                        ],
                                      ),
                                    ),
                                    
                                    const SizedBox(height: 36),
                                    
                                    // Description
                                    Row(
                                      children: [
                                        Container(
                                          width: 4,
                                          height: 18,
                                          decoration: BoxDecoration(
                                            color: AppColors.primary,
                                            borderRadius: BorderRadius.circular(2),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Text('Mô tả sản phẩm', style: AppTextStyles.headingSm.copyWith(fontWeight: FontWeight.w900)),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      product.description.isNotEmpty ? product.description : 'Chưa có mô tả chi tiết cho sản phẩm này.',
                                      style: AppTextStyles.bodyMd.copyWith(color: AppColors.textSecondary, height: 1.7, fontSize: 15),
                                    ),
                                    
                                    if (product.specifications.isNotEmpty) ...[
                                      const SizedBox(height: 36),
                                      Row(
                                        children: [
                                          Container(
                                            width: 4,
                                            height: 18,
                                            decoration: BoxDecoration(
                                              color: AppColors.primary,
                                              borderRadius: BorderRadius.circular(2),
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Text('Thông số kỹ thuật', style: AppTextStyles.headingSm.copyWith(fontWeight: FontWeight.w900)),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(20),
                                          border: Border.all(color: AppColors.surfaceDark, width: 1.5),
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(20),
                                          child: Column(
                                            children: product.specifications.entries.map((e) {
                                              final index = product.specifications.keys.toList().indexOf(e.key);
                                              return _SpecRow(
                                                label: e.key,
                                                value: e.value,
                                                isAlternate: index % 2 != 0,
                                              );
                                            }).toList(),
                                          ),
                                        ),
                                      ),
                                    ],
                                    
                                    const SizedBox(height: 40),
                                    
                                    // Feedback
                                    ProductFeedbackSection(productId: product.id),
                                    
                                    const SizedBox(height: 140),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
          bottomSheet: product == null ? null : _BottomActionBar(product: product),
        );
      },
    );
  }
}

class _StatusItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _StatusItem({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(height: 6),
        Text(label, style: AppTextStyles.caption.copyWith(color: color, fontWeight: FontWeight.w900, fontSize: 10)),
      ],
    );
  }
}

class _SpecRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isAlternate;

  const _SpecRow({required this.label, required this.value, this.isAlternate = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isAlternate ? AppColors.surfaceDark.withValues(alpha: 0.3) : Colors.transparent,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: AppTextStyles.labelMd.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: AppTextStyles.labelBold.copyWith(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomActionBar extends StatelessWidget {
  final product;
  const _BottomActionBar({required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 34),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 56,
            width: 56,
            decoration: BoxDecoration(
              color: AppColors.surfaceDark,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: IconButton(
              icon: const Icon(Icons.shopping_bag_outlined, color: AppColors.primary, size: 26),
              onPressed: () => context.push('/cart'),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: product.isInStock 
                    ? [AppColors.primary, const Color(0xFF22D3EE)] 
                    : [Colors.grey.shade400, Colors.grey.shade500],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: product.isInStock ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ] : [],
              ),
              child: ElevatedButton(
                onPressed: product.isInStock
                    ? () {
                        context.read<CartViewModel>().addItem(product);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                                const SizedBox(width: 12),
                                Expanded(child: Text('Đã thêm ${product.name} vào giỏ hàng', style: const TextStyle(fontWeight: FontWeight.bold))),
                              ],
                            ),
                            behavior: SnackBarBehavior.floating,
                            margin: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            backgroundColor: const Color(0xFF334155),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                ),
                child: Text(
                  product.isInStock ? 'THÊM VÀO GIỎ HÀNG' : 'HẾT HÀNG',
                  style: AppTextStyles.labelBold.copyWith(color: Colors.white, fontSize: 15, letterSpacing: 1),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Swipeable image gallery with modern indicators
class _ImageGallery extends StatefulWidget {
  final List<String> imageUrls;
  final int productId;

  const _ImageGallery({required this.imageUrls, required this.productId});

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
        height: 460,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.surfaceDark.withValues(alpha: 0.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image_not_supported_rounded, size: 80, color: AppColors.textHint.withValues(alpha: 0.5)),
            const SizedBox(height: 16),
            Text('Chưa có hình ảnh', style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.bold)),
          ],
        ),
      );
    }

    return SizedBox(
      height: 480,
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: widget.imageUrls.length,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => _FullScreenImageViewer(imageUrls: widget.imageUrls, initialIndex: index),
                  ),
                ),
                child: Hero(
                  tag: 'product_list_image_${widget.productId}',
                  child: Container(
                    color: AppColors.surfaceDark.withValues(alpha: 0.3),
                    child: Image.network(
                      widget.imageUrls[index],
                      fit: BoxFit.contain,
                      width: double.infinity,
                    ),
                  ),
                ),
              );
            },
          ),
          // Page Info
          Positioned(
            top: MediaQuery.of(context).padding.top + 80,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
              ),
              child: Text(
                '${_currentPage + 1} / ${widget.imageUrls.length}',
                style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w900),
              ),
            ),
          ),
          // Indicators
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(
                    widget.imageUrls.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: _currentPage == index ? 24 : 8,
                      height: 6,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: _currentPage == index ? AppColors.primary : AppColors.borderLight,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Full-screen image viewer with pinch-to-zoom
class _FullScreenImageViewer extends StatefulWidget {
  final List<String> imageUrls;
  final int initialIndex;

  const _FullScreenImageViewer({required this.imageUrls, required this.initialIndex});

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
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('${_currentPage + 1} / ${widget.imageUrls.length}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.imageUrls.length,
        onPageChanged: (index) => setState(() => _currentPage = index),
        itemBuilder: (context, index) {
          return InteractiveViewer(
            minScale: 1.0,
            maxScale: 4.0,
            child: Center(
              child: Image.network(
                widget.imageUrls[index],
                fit: BoxFit.contain,
                loadingBuilder: (_, child, prog) => prog == null ? child : const CircularProgressIndicator(color: Colors.white),
              ),
            ),
          );
        },
      ),
    );
  }
}


