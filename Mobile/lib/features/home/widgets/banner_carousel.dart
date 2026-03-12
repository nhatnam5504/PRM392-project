import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/format_price.dart';
import '../../../data/models/product_model.dart';

class BannerCarousel extends StatefulWidget {
  final List<ProductModel> products;
  final Duration autoPlayInterval;

  const BannerCarousel({
    super.key,
    required this.products,
    this.autoPlayInterval =
        const Duration(seconds: 4),
  });

  @override
  State<BannerCarousel> createState() =>
      _BannerCarouselState();
}

class _BannerCarouselState
    extends State<BannerCarousel> {
  late final PageController _pageController;
  int _currentPage = 0;
  Timer? _autoPlayTimer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      viewportFraction: 0.92,
    );
    _startAutoPlay();
  }

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoPlay() {
    if (widget.products.length <= 1) return;
    _autoPlayTimer?.cancel();
    _autoPlayTimer = Timer.periodic(
      widget.autoPlayInterval,
      (_) => _goToNextPage(),
    );
  }

  void _goToNextPage() {
    if (!_pageController.hasClients) return;
    final nextPage =
        (_currentPage + 1) % widget.products.length;
    _pageController.animateToPage(
      nextPage,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void _onPageChanged(int index) {
    setState(() => _currentPage = index);
    _startAutoPlay();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.products.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        SizedBox(
          height: 200,
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.products.length,
            onPageChanged: _onPageChanged,
            itemBuilder: (context, index) {
              return _ProductBannerCard(
                product: widget.products[index],
                pageController: _pageController,
                index: index,
              );
            },
          ),
        ),
        const SizedBox(height: 14),
        _DotIndicator(
          count: widget.products.length,
          currentIndex: _currentPage,
          onTap: (index) {
            _pageController.animateToPage(
              index,
              duration:
                  const Duration(milliseconds: 400),
              curve: Curves.easeInOut,
            );
          },
        ),
      ],
    );
  }
}

class _ProductBannerCard extends StatelessWidget {
  final ProductModel product;
  final PageController pageController;
  final int index;

  const _ProductBannerCard({
    required this.product,
    required this.pageController,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pageController,
      builder: (context, child) {
        double scale = 1.0;
        if (pageController
            .position.haveDimensions) {
          final page =
              pageController.page ?? 0.0;
          scale =
              (1 - ((page - index).abs() * 0.12))
                  .clamp(0.88, 1.0);
        }
        return Center(
          child: Transform.scale(
            scale: scale,
            child: child,
          ),
        );
      },
      child: _buildCard(context),
    );
  }

  Widget _buildCard(BuildContext context) {
    final imageUrl = product.imageUrls.isNotEmpty
        ? product.imageUrls.first
        : '';

    return GestureDetector(
      onTap: () {
        context.push('/products/${product.id}');
      },
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: 6,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryShadow
                  .withValues(alpha: 0.18),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Background gradient
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF0E7490),
                      Color(0xFF0891B2),
                      Color(0xFF22D3EE),
                    ],
                  ),
                ),
              ),

              // Product image (right side)
              Positioned(
                right: -10,
                top: 10,
                bottom: 10,
                width:
                    MediaQuery.of(context)
                        .size
                        .width *
                    0.42,
                child: Hero(
                  tag: 'banner_product_${product.id}',
                  child: imageUrl.isNotEmpty
                      ? Image.network(
                          imageUrl,
                          fit: BoxFit.contain,
                          errorBuilder:
                              (_, __, ___) =>
                                  _buildPlaceholderIcon(),
                          loadingBuilder: (_,
                              child,
                              loadingProgress) {
                            if (loadingProgress ==
                                null) {
                              return child;
                            }
                            return Center(
                              child:
                                  CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white
                                    .withValues(
                                  alpha: 0.5,
                                ),
                              ),
                            );
                          },
                        )
                      : _buildPlaceholderIcon(),
                ),
              ),

              // Subtle pattern overlay
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      stops: const [0.0, 0.55, 1.0],
                      colors: [
                        Colors.black
                            .withValues(alpha: 0.15),
                        Colors.transparent,
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

              // Content (left side)
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    // Badges row
                    Row(
                      children: [
                        if (product.isHot)
                          const _Badge(
                            text: '🔥 HOT',
                            color: AppColors.accent,
                          ),
                        if (product.isNew) ...[
                          if (product.isHot)
                            const SizedBox(
                              width: 6,
                            ),
                          const _Badge(
                            text: 'MỚI',
                            color:
                                AppColors.success,
                          ),
                        ],
                        if (product.isOnSale) ...[
                          if (product.isHot ||
                              product.isNew)
                            const SizedBox(
                              width: 6,
                            ),
                          _Badge(
                            text: formatDiscount(
                              product
                                  .discountPercent,
                            ),
                            color: AppColors.error,
                          ),
                        ],
                      ],
                    ),

                    const Spacer(),

                    // Brand
                    Text(
                      product.brandName
                          .toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.white
                            .withValues(alpha: 0.70),
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Product name
                    SizedBox(
                      width: MediaQuery.of(context)
                              .size
                              .width *
                          0.45,
                      child: Text(
                        product.name,
                        maxLines: 2,
                        overflow:
                            TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight:
                              FontWeight.w800,
                          color: Colors.white,
                          height: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Price row
                    Row(
                      children: [
                        Text(
                          formatVND(product.price),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight:
                                FontWeight.w800,
                            color:
                                Color(0xFFFFD700),
                          ),
                        ),
                        if (product.isOnSale) ...[
                          const SizedBox(width: 8),
                          Text(
                            formatVND(
                              product
                                  .originalPrice!,
                            ),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white
                                  .withValues(
                                alpha: 0.60,
                              ),
                              decoration:
                                  TextDecoration
                                      .lineThrough,
                              decorationColor:
                                  Colors.white
                                      .withValues(
                                alpha: 0.60,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholderIcon() {
    return Center(
      child: Icon(
        Icons.devices_rounded,
        size: 56,
        color: Colors.white.withValues(alpha: 0.3),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;
  final Color color;

  const _Badge({
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _DotIndicator extends StatelessWidget {
  final int count;
  final int currentIndex;
  final ValueChanged<int>? onTap;

  const _DotIndicator({
    required this.count,
    required this.currentIndex,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment:
          MainAxisAlignment.center,
      children: List.generate(count, (index) {
        final isActive = index == currentIndex;
        return GestureDetector(
          onTap: () => onTap?.call(index),
          child: AnimatedContainer(
            duration: const Duration(
              milliseconds: 300,
            ),
            curve: Curves.easeInOut,
            width: isActive ? 28 : 8,
            height: 8,
            margin: const EdgeInsets.symmetric(
              horizontal: 3,
            ),
            decoration: BoxDecoration(
              color: isActive
                  ? AppColors.primary
                  : AppColors.border,
              borderRadius:
                  BorderRadius.circular(4),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: AppColors.primary
                            .withValues(alpha: 0.3),
                        blurRadius: 6,
                        offset:
                            const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
          ),
        );
      }),
    );
  }
}
