import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/format_price.dart';
import '../../../data/models/product_model.dart';
import '../../../data/models/category_model.dart';
import '../view_models/product_view_model.dart';
import '../../shared/view_models/product_rating_view_model.dart';

class ProductListScreen extends StatefulWidget {
  final bool? initialType;

  const ProductListScreen({super.key, this.initialType});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  int? _selectedCategoryId;
  int? _selectedBrandId;
  final _searchController = TextEditingController();
  String _searchQuery = '';
  Timer? _debounce;
  bool _showSearch = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final vm = context.read<ProductViewModel>();
      final ratingVm = context.read<ProductRatingViewModel>();
      vm.loadProducts(refresh: true).then((_) {
        if (!mounted) return;
        final ids = vm.products.map((p) => p.id).toList();
        if (ids.isNotEmpty) ratingVm.loadRatingsForProducts(ids);
      });
      vm.loadCategories();
      vm.loadBrands();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      setState(() => _searchQuery = query.trim());
      _applyFilters();
    });
  }

  void _applyFilters() {
    final vm = context.read<ProductViewModel>();
    if (_selectedCategoryId != null) {
      vm.loadProductsByCategory(_selectedCategoryId!);
    } else if (_selectedBrandId != null) {
      vm.loadProductsByBrand(_selectedBrandId!);
    } else {
      vm.loadProducts(
          refresh: true, search: _searchQuery.isNotEmpty ? _searchQuery : null);
    }
  }

  List<ProductModel> _filterLocally(List<ProductModel> products) {
    if (_searchQuery.isEmpty) return products;
    final q = _searchQuery.toLowerCase();
    return products
        .where((p) =>
            p.name.toLowerCase().contains(q) ||
            p.brandName.toLowerCase().contains(q) ||
            p.categoryName.toLowerCase().contains(q) ||
            p.description.toLowerCase().contains(q))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductViewModel>(
      builder: (context, vm, _) {
        final products = _filterLocally(vm.products);
        final initialIdx = widget.initialType == false ? 1 : 0;

        return DefaultTabController(
          length: 2,
          initialIndex: initialIdx,
          child: Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              centerTitle: true,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20),
                onPressed: () => context.pop(),
              ),
              title: _showSearch
                  ? Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceDark,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        controller: _searchController,
                        autofocus: true,
                        decoration: InputDecoration(
                          hintText: 'Tìm sản phẩm...',
                          hintStyle: AppTextStyles.bodyMd.copyWith(color: AppColors.textHint, fontSize: 13),
                          prefixIcon: const Icon(Icons.search_rounded, size: 20, color: AppColors.primary),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                        style: AppTextStyles.bodyMd,
                        onChanged: _onSearchChanged,
                      ),
                    )
                  : Text(
                      'Cửa hàng',
                      style: AppTextStyles.headingSm.copyWith(fontWeight: FontWeight.w800),
                    ),
              actions: [
                IconButton(
                  icon: Icon(_showSearch ? Icons.close_rounded : Icons.search_rounded, color: AppColors.textPrimary),
                  onPressed: () {
                    setState(() {
                      _showSearch = !_showSearch;
                      if (!_showSearch) {
                        _searchController.clear();
                        _searchQuery = '';
                        _applyFilters();
                      }
                    });
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.shopping_bag_outlined, color: AppColors.textPrimary),
                  onPressed: () => context.push('/cart'),
                ),
              ],
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(50),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceDark,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TabBar(
                    indicator: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    labelColor: AppColors.primary,
                    unselectedLabelColor: AppColors.textSecondary,
                    labelStyle: AppTextStyles.labelBold.copyWith(fontSize: 13),
                    unselectedLabelStyle: AppTextStyles.labelMd.copyWith(fontSize: 13),
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent,
                    tabs: const [
                      Tab(text: 'SẢN PHẨM'),
                      Tab(text: 'DỊCH VỤ'),
                    ],
                  ),
                ),
              ),
            ),
            body: Column(
              children: [
                // Filter section
                Container(
                  color: Colors.white,
                  child: Column(
                    children: [
                      // Category selection
                      if (vm.categories.isNotEmpty)
                        SizedBox(
                          height: 54,
                          child: ListView.separated(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            scrollDirection: Axis.horizontal,
                            itemCount: vm.categories.length + 1,
                            separatorBuilder: (_, __) => const SizedBox(width: 8),
                            itemBuilder: (context, index) {
                              if (index == 0) {
                                return _FilterChip(
                                  label: 'Tất cả',
                                  isActive: _selectedCategoryId == null && _selectedBrandId == null,
                                  onTap: () {
                                    setState(() {
                                      _selectedCategoryId = null;
                                      _selectedBrandId = null;
                                    });
                                    _applyFilters();
                                  },
                                );
                              }
                              final cat = vm.categories[index - 1];
                              return _FilterChip(
                                label: cat.name,
                                isActive: _selectedCategoryId == cat.id,
                                onTap: () {
                                  setState(() {
                                    _selectedCategoryId = cat.id;
                                    _selectedBrandId = null;
                                  });
                                  vm.loadProductsByCategory(cat.id);
                                },
                              );
                            },
                          ),
                        ),
                      // Brand selection
                      if (vm.brands.isNotEmpty)
                        SizedBox(
                          height: 54,
                          child: ListView.separated(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                            scrollDirection: Axis.horizontal,
                            itemCount: vm.brands.length,
                            separatorBuilder: (_, __) => const SizedBox(width: 8),
                            itemBuilder: (context, index) {
                              final brand = vm.brands[index];
                              return _FilterChip(
                                label: brand.name,
                                isActive: _selectedBrandId == brand.id,
                                onTap: () {
                                  setState(() {
                                    _selectedBrandId = brand.id;
                                    _selectedCategoryId = null;
                                  });
                                  vm.loadProductsByBrand(brand.id);
                                },
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                ),
                // Results info
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Row(
                    children: [
                      Text(
                        'Kết quả',
                        style: AppTextStyles.labelBold.copyWith(color: AppColors.textHeading),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${products.length}',
                          style: AppTextStyles.labelBold.copyWith(color: AppColors.primary, fontSize: 11),
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.tune_rounded, size: 18, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text('Sắp xếp', style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                // Product grid
                Expanded(
                  child: TabBarView(
                    children: [
                      _buildProductGrid(vm, products.where((p) => p.type).toList(), true),
                      _buildProductGrid(vm, products.where((p) => !p.type).toList(), false),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProductGrid(ProductViewModel vm, List<ProductModel> products, bool isProduct) {
    if (vm.isLoading && products.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }
    if (products.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surfaceDark,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.search_off_rounded, size: 40, color: AppColors.textHint),
            ),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isNotEmpty ? 'Không tìm thấy "${_searchQuery}"' : 'Trống',
              style: AppTextStyles.bodyLg.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async {
        _applyFilters();
        final ratingVm = context.read<ProductRatingViewModel>();
        final vm = context.read<ProductViewModel>();
        final ids = vm.products.map((p) => p.id).toList();
        if (ids.isNotEmpty) {
          ratingVm.loadRatingsForProducts(ids);
        }
      },
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.58,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return _ProductGridCard(product: product);
        },
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback? onTap;

  const _FilterChip({
    required this.label,
    this.isActive = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : AppColors.surfaceDark,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isActive ? AppColors.primary : Colors.transparent,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            label,
            style: AppTextStyles.labelMd.copyWith(
              color: isActive ? Colors.white : AppColors.textSecondary,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }
}

class _ProductGridCard extends StatelessWidget {
  final ProductModel product;

  const _ProductGridCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/products/${product.id}'),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.surfaceDark, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Area
            Stack(
              children: [
                Container(
                  height: 160,
                  width: double.infinity,
                  margin: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceDark.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Hero(
                      tag: 'product_list_image_${product.id}',
                      child: product.imageUrls.isNotEmpty
                          ? Image.network(
                              product.imageUrls.first,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported_rounded, color: AppColors.textHint),
                            )
                          : const Icon(Icons.image_not_supported_rounded, color: AppColors.textHint),
                    ),
                  ),
                ),
                // Badges
                if (product.isHot || product.isNew)
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: (product.isHot ? AppColors.error : AppColors.primary).withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        product.isHot ? 'HOT' : 'NEW',
                        style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w900),
                      ),
                    ),
                  ),
                // Quick Action
                Positioned(
                  bottom: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 3)],
                    ),
                    child: const Icon(Icons.add_shopping_cart_rounded, size: 14, color: AppColors.primary),
                  ),
                ),
              ],
            ),
            // Info Area
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          product.brandName.toUpperCase(),
                          style: AppTextStyles.labelBold.copyWith(
                            color: AppColors.primary,
                            fontSize: 8,
                            letterSpacing: 1,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star_rounded, color: Colors.amber, size: 12),
                          const SizedBox(width: 2),
                          Consumer<ProductRatingViewModel>(
                            builder: (context, ratingVm, _) {
                              final data = ratingVm.getRating(product.id);
                              final rating = data?.averageRating ?? 0.0;
                              return Text(
                                rating > 0 ? rating.toStringAsFixed(1) : '-',
                                style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.bold, fontSize: 9),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    product.name,
                    style: AppTextStyles.labelBold.copyWith(
                      color: AppColors.textHeading,
                      fontSize: 13,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  // Price Area
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              formatVND(product.price),
                              style: AppTextStyles.priceMd.copyWith(color: AppColors.primary, fontSize: 15, fontWeight: FontWeight.w900),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (product.isOnSale) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                              decoration: BoxDecoration(
                                color: AppColors.error.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '-${product.discountPercent.toStringAsFixed(0)}%',
                                style: AppTextStyles.caption.copyWith(color: AppColors.error, fontWeight: FontWeight.bold, fontSize: 8),
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (product.isOnSale)
                        Text(
                          formatVND(product.originalPrice!),
                          style: AppTextStyles.caption.copyWith(decoration: TextDecoration.lineThrough, fontSize: 9, color: AppColors.textHint),
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

