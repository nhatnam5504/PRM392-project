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
  const ProductListScreen({super.key});

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

        return Scaffold(
          appBar: AppBar(
            title: _showSearch
                ? TextField(
                    controller: _searchController,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: 'Tìm kiếm sản phẩm...',
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      filled: false,
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.close, size: 20),
                              onPressed: () {
                                _searchController.clear();
                                _onSearchChanged('');
                              },
                            )
                          : null,
                    ),
                    style: AppTextStyles.bodyLg,
                    onChanged: _onSearchChanged,
                  )
                : const Text('Cửa hàng'),
            actions: [
              IconButton(
                icon: Icon(_showSearch ? Icons.close : Icons.search),
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
                icon: const Icon(Icons.shopping_cart_outlined),
                onPressed: () => context.go('/cart'),
              ),
            ],
          ),
          body: Column(
            children: [
              // Category/count bar
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  border: Border(
                    bottom: BorderSide(
                      color: AppColors.divider,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _selectedCategoryId != null
                          ? (vm.categories
                                  .where((c) => c.id == _selectedCategoryId)
                                  .firstOrNull
                                  ?.name ??
                              'Tất cả')
                          : _selectedBrandId != null
                              ? (vm.brands
                                      .where((b) => b.id == _selectedBrandId)
                                      .firstOrNull
                                      ?.name ??
                                  'Tất cả')
                              : 'Tất cả sản phẩm',
                      style: AppTextStyles.labelBold,
                    ),
                    Text(
                      '${products.length} sản phẩm',
                      style: AppTextStyles.bodySm,
                    ),
                  ],
                ),
              ),
              // Category filter chips
              if (vm.categories.isNotEmpty)
                Container(
                  height: 50,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: const BoxDecoration(
                    color: AppColors.surface,
                    border: Border(
                      bottom: BorderSide(
                        color: AppColors.divider,
                      ),
                    ),
                  ),
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _FilterChip(
                        label: 'Tất cả',
                        isActive: _selectedCategoryId == null &&
                            _selectedBrandId == null,
                        onTap: () {
                          setState(() {
                            _selectedCategoryId = null;
                            _selectedBrandId = null;
                          });
                          _applyFilters();
                        },
                      ),
                      const SizedBox(width: 8),
                      ...vm.categories.map(
                        (cat) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: _FilterChip(
                            label: cat.name,
                            isActive: _selectedCategoryId == cat.id,
                            onTap: () {
                              setState(() {
                                _selectedCategoryId = cat.id;
                                _selectedBrandId = null;
                              });
                              vm.loadProductsByCategory(cat.id);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              // Brand filter chips
              if (vm.brands.isNotEmpty)
                Container(
                  height: 50,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: const BoxDecoration(
                    color: AppColors.surface,
                    border: Border(
                      bottom: BorderSide(
                        color: AppColors.divider,
                      ),
                    ),
                  ),
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      Text(
                        'Hãng: ',
                        style: AppTextStyles.labelMd.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      ...vm.brands.map(
                        (brand) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: _FilterChip(
                            label: brand.name,
                            isActive: _selectedBrandId == brand.id,
                            onTap: () {
                              setState(() {
                                _selectedBrandId = brand.id;
                                _selectedCategoryId = null;
                              });
                              vm.loadProductsByBrand(brand.id);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              // Product grid
              Expanded(
                child: vm.isLoading && products.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : vm.errorMessage != null && products.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(vm.errorMessage!),
                                const SizedBox(height: 12),
                                ElevatedButton(
                                  onPressed: () =>
                                      vm.loadProducts(refresh: true),
                                  child: const Text('Thử lại'),
                                ),
                              ],
                            ),
                          )
                        : products.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.search_off,
                                        size: 48, color: AppColors.border),
                                    const SizedBox(height: 12),
                                    Text(
                                      _searchQuery.isNotEmpty
                                          ? 'Không tìm thấy "$_searchQuery"'
                                          : 'Không có sản phẩm nào',
                                      style: AppTextStyles.bodyLg,
                                    ),
                                  ],
                                ),
                              )
                            : RefreshIndicator(
                                onRefresh: () async {
                                  _applyFilters();
                                  final ratingVm =
                                      context.read<ProductRatingViewModel>();
                                  final vm =
                                      context.read<ProductViewModel>();
                                  final ids =
                                      vm.products.map((p) => p.id).toList();
                                  if (ids.isNotEmpty) {
                                    ratingVm.loadRatingsForProducts(ids);
                                  }
                                },
                                child: GridView.builder(
                                  padding: const EdgeInsets.all(16),
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    childAspectRatio: 0.55,
                                    crossAxisSpacing: 12,
                                    mainAxisSpacing: 12,
                                  ),
                                  itemCount: products.length,
                                  itemBuilder: (context, index) {
                                    final product = products[index];
                                    return GestureDetector(
                                      onTap: () => context
                                          .push('/products/${product.id}'),
                                      child: _ProductGridCard(
                                        product: product,
                                      ),
                                    );
                                  },
                                ),
                              ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final IconData? icon;
  final VoidCallback? onTap;

  const _FilterChip({
    required this.label,
    this.isActive = false,
    this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isActive ? AppColors.primary : AppColors.border,
          ),
          boxShadow: isActive
              ? const [
                  BoxShadow(
                    color: AppColors.primaryShadow,
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16,
                color: isActive ? Colors.white : AppColors.primary,
              ),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: AppTextStyles.labelMd.copyWith(
                color: isActive ? Colors.white : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductGridCard extends StatelessWidget {
  final ProductModel product;

  const _ProductGridCard({
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
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
                        errorBuilder: (_, __, ___) => const Icon(
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'HOT',
                      style: AppTextStyles.labelSm.copyWith(
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'NEW',
                      style: AppTextStyles.labelSm.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          // Info
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
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
                  const SizedBox(height: 4),
                  Text(
                    product.name,
                    style: AppTextStyles.labelMd,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  Consumer<ProductRatingViewModel>(
                    builder: (context, ratingVm, _) {
                      final data = ratingVm.getRating(product.id);
                      final rating = data?.averageRating ?? 0.0;
                      final count = data?.totalCount ?? 0;
                      return Row(
                        children: [
                          ...List.generate(5, (i) {
                            if (i < rating.floor()) {
                              return const Icon(
                                Icons.star,
                                color: AppColors.star,
                                size: 14,
                              );
                            } else if (i < rating.ceil() &&
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
                            style: AppTextStyles.labelMd,
                          ),
                          if (count > 0) ...[
                            const SizedBox(width: 2),
                            Text(
                              '($count)',
                              style: AppTextStyles.bodySm,
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
                      style: AppTextStyles.priceStrike,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
