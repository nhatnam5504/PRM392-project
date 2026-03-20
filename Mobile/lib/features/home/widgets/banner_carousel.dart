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
          height: 220,
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
        const SizedBox(height: 16),
        _DotIndicator(
          count: widget.products.length,
          currentIndex: _currentPage,
          onTap: (index) {
            _pageController.animateToPage(
              index,
              duration: const Duration(milliseconds: 400),
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
        if (pageController.position.haveDimensions) {
          final page = pageController.page ?? 0.0;
          scale = (1 - ((page - index).abs() * 0.1)).clamp(0.9, 1.0);
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
    final imageUrl = product.imageUrls.isNotEmpty ? product.imageUrls.first : '';

    return GestureDetector(
      onTap: () => context.push('/products/${product.id}'),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.15),
              blurRadius: 25,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Rich Gradient Background
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF0F172A), // Slate 900
                      Color(0xFF1E293B), // Slate 800
                      Color(0xFF0F172A),
                    ],
                  ),
                ),
              ),

              // Decorative Elements
              Positioned(
                right: -40,
                top: -40,
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                left: -20,
                bottom: -20,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.05),
                    shape: BoxShape.circle,
                  ),
                ),
              ),

              // Product Image (Right)
              Positioned(
                right: -10,
                top: 20,
                bottom: 20,
                width: MediaQuery.of(context).size.width * 0.5,
                child: Hero(
                  tag: 'banner_product_${product.id}',
                  child: imageUrl.isNotEmpty
                      ? Image.network(
                          imageUrl,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => _buildPlaceholderIcon(),
                        )
                      : _buildPlaceholderIcon(),
                ),
              ),

              // Content (Left)
              Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Hot/New Badge
                    if (product.isHot || product.isNew)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: product.isHot 
                              ? [AppColors.error, const Color(0xFFFF6B6B)] 
                              : [AppColors.primary, const Color(0xFF22D3EE)],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: (product.isHot ? AppColors.error : AppColors.primary).withValues(alpha: 0.3),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Text(
                          product.isHot ? '🔥 SIÊU ƯU ĐÃI' : '✨ MỚI RA MẮT',
                          style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                        ),
                      ),
                    const Spacer(),
                    Text(
                      product.brandName.toUpperCase(),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.42,
                      child: Text(
                        product.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          height: 1.1,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          formatVND(product.price),
                          style: const TextStyle(
                            color: Color(0xFF22D3EE),
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        if (product.isOnSale) ...[
                          const SizedBox(width: 10),
                          Text(
                            formatVND(product.originalPrice!),
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.3),
                              fontSize: 12,
                              decoration: TextDecoration.lineThrough,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              
              // Glossy border mask effect
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.08),
                    width: 1.5,
                  ),
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
        size: 60,
        color: Colors.white.withValues(alpha: 0.2),
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
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        final isActive = index == currentIndex;
        return GestureDetector(
          onTap: () => onTap?.call(index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            width: isActive ? 24 : 8,
            height: 6,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: isActive ? AppColors.primary : AppColors.border.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(10),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
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
