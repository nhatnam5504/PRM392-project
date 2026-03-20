import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/format_price.dart';
import '../../../data/models/product_model.dart';
import '../../../features/product/view_models/product_view_model.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  Timer? _debounce;
  List<ProductModel> _results = [];
  bool _isSearching = false;
  bool _hasSearched = false;

  @override
  void dispose() {
    _controller.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    if (query.trim().isEmpty) {
      setState(() {
        _results = [];
        _hasSearched = false;
        _isSearching = false;
      });
      return;
    }
    setState(() => _isSearching = true);
    _debounce = Timer(const Duration(milliseconds: 400), () {
      _performSearch(query.trim());
    });
  }

  Future<void> _performSearch(String query) async {
    try {
      final vm = context.read<ProductViewModel>();
      // Load all products and filter client-side
      await vm.loadProducts(refresh: true, search: query);
      if (mounted) {
        setState(() {
          _results = vm.products;
          _isSearching = false;
          _hasSearched = true;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isSearching = false;
          _hasSearched = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20),
          onPressed: () => context.pop(),
        ),
        titleSpacing: 0,
        title: Container(
          margin: const EdgeInsets.only(right: 20),
          height: 46,
          decoration: BoxDecoration(
            color: AppColors.surfaceDark.withOpacity(0.5),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.surfaceDark),
          ),
          child: TextField(
            controller: _controller,
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Tìm kiếm sản phẩm...',
              hintStyle: AppTextStyles.bodyMd.copyWith(color: AppColors.textHint, fontSize: 14),
              prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textHint, size: 20),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 11),
              suffixIcon: _controller.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close_rounded, size: 18, color: AppColors.textSecondary),
                      onPressed: () {
                        _controller.clear();
                        _onSearchChanged('');
                      },
                    )
                  : null,
            ),
            style: AppTextStyles.bodyMd.copyWith(fontWeight: FontWeight.w600),
            onChanged: _onSearchChanged,
            onSubmitted: (q) {
              if (q.trim().isNotEmpty) _performSearch(q.trim());
            },
          ),
        ),
      ),
      body: _isSearching
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 3))
          : !_hasSearched
              ? _buildSuggestions()
              : _results.isEmpty
                  ? _buildEmptyState()
                  : _buildSearchResults(),
    );
  }

  Widget _buildSuggestions() {
    final popular = ['Pin sạc dự phòng', 'Ốp lưng iPhone', 'Cáp sạc Type-C', 'Tai nghe Bluetooth', 'Loa Marshall'];
    
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.trending_up_rounded, color: AppColors.primary, size: 20),
              const SizedBox(width: 10),
              Text('Gợi ý tìm kiếm', style: AppTextStyles.labelBold.copyWith(fontSize: 15, fontWeight: FontWeight.w900)),
            ],
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: popular.map((term) => GestureDetector(
              onTap: () {
                _controller.text = term;
                _onSearchChanged(term);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.surfaceDark),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2)),
                  ],
                ),
                child: Text(term, style: AppTextStyles.bodySm.copyWith(fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _results.length,
      itemBuilder: (context, index) {
        final product = _results[index];
        return _SearchResultItem(product: product);
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surfaceDark.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.search_off_rounded, size: 64, color: AppColors.textHint.withOpacity(0.5)),
          ),
          const SizedBox(height: 24),
          Text(
            'Không tìm thấy kết quả',
            style: AppTextStyles.headingSm.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Text(
            'Thử tìm kiếm với từ khóa khác xem sao!',
            style: AppTextStyles.bodySm.copyWith(color: AppColors.textHint),
          ),
        ],
      ),
    );
  }
}

class _SearchResultItem extends StatelessWidget {
  final ProductModel product;

  const _SearchResultItem({required this.product});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/products/${product.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.surfaceDark.withOpacity(0.5)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Image
            Hero(
              tag: 'product_image_${product.id}',
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  width: 90,
                  height: 90,
                  color: AppColors.surfaceDark.withOpacity(0.3),
                  child: product.imageUrls.isNotEmpty
                      ? Image.network(
                          product.imageUrls.first,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => const Icon(Icons.image_outlined, color: AppColors.textHint),
                        )
                      : const Icon(Icons.image_outlined, color: AppColors.textHint),
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      product.brandName.toUpperCase(),
                      style: AppTextStyles.labelBold.copyWith(color: AppColors.primary, fontSize: 9, letterSpacing: 1),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product.name,
                    style: AppTextStyles.labelBold.copyWith(fontSize: 15, fontWeight: FontWeight.w800, height: 1.2),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Text(
                        formatVND(product.price),
                        style: AppTextStyles.priceMd.copyWith(color: AppColors.primary, fontWeight: FontWeight.w900),
                      ),
                      if (product.isOnSale) ...[
                        const SizedBox(width: 8),
                        Text(
                          formatVND(product.originalPrice!),
                          style: AppTextStyles.caption.copyWith(
                            decoration: TextDecoration.lineThrough,
                            color: AppColors.textHint,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textHint, size: 24),
          ],
        ),
      ),
    );
  }
}
