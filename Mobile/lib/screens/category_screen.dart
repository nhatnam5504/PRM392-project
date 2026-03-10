import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../config/app_text_styles.dart';
import '../data/sample_data.dart';
import '../models/product.dart';
import '../widgets/product_card.dart';

/// Màn hình danh mục sản phẩm
/// Hiển thị danh sách sản phẩm theo danh mục, có bộ lọc (dung lượng, thương hiệu)
class CategoryScreen extends StatefulWidget {
  final String categoryId; // Mã danh mục cần hiển thị

  const CategoryScreen({super.key, required this.categoryId});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  // Bộ lọc đang được chọn
  String _selectedCapacity = 'Tất cả';
  String _selectedBrand = 'Tất cả';

  /// Lấy danh sách sản phẩm đã được lọc
  List<Product> get _filteredProducts {
    List<Product> products = SampleData.getProductsByCategory(
      widget.categoryId,
    );

    // Lọc theo dung lượng
    if (_selectedCapacity != 'Tất cả') {
      products = products
          .where((p) => p.capacity == _selectedCapacity)
          .toList();
    }

    // Lọc theo thương hiệu
    if (_selectedBrand != 'Tất cả') {
      products = products.where((p) => p.brand == _selectedBrand).toList();
    }

    return products;
  }

  /// Lấy tên danh mục để hiển thị trên AppBar
  String get _categoryName {
    final category = SampleData.categories.firstWhere(
      (c) => c.id == widget.categoryId,
      orElse: () => SampleData.categories.first,
    );
    return category.name;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0.5,
        title: Row(
          children: [
            // Logo nhỏ
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(
                Icons.devices,
                color: AppColors.white,
                size: 16,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            const Text(
              'TECHGEAR',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        actions: [
          // Icon giỏ hàng
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, '/cart');
            },
            icon: const Icon(Icons.shopping_cart_outlined),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tiêu đề danh mục + số sản phẩm
          _buildCategoryHeader(),

          // Bộ lọc sản phẩm
          _buildFilters(),

          const SizedBox(height: AppSpacing.sm),

          // Danh sách sản phẩm dạng lưới
          _buildProductGrid(),
        ],
      ),
    );
  }

  /// Xây dựng tiêu đề danh mục
  Widget _buildCategoryHeader() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      color: AppColors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Tên danh mục
          Text('Danh Mục $_categoryName', style: AppTextStyles.sectionTitle),
          // Số lượng sản phẩm
          Text(
            '${_filteredProducts.length} sản phẩm',
            style: AppTextStyles.caption,
          ),
        ],
      ),
    );
  }

  /// Xây dựng phần bộ lọc (FilterChip)
  Widget _buildFilters() {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hàng lọc theo dung lượng
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Text(
              'Bộ lọc',
              style: AppTextStyles.caption.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          // Chip lọc dung lượng
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              itemCount:
                  SampleData.capacityFilters.length +
                  SampleData.brandFilters.length -
                  1, // -1 vì "Tất cả" chỉ hiển thị 1 lần
              itemBuilder: (context, index) {
                String filter;
                bool isSelected;

                if (index < SampleData.capacityFilters.length) {
                  // Chip dung lượng
                  filter = SampleData.capacityFilters[index];
                  isSelected = filter == _selectedCapacity;
                } else {
                  // Chip thương hiệu (bỏ qua "Tất cả")
                  final brandIndex =
                      index - SampleData.capacityFilters.length + 1;
                  filter = SampleData.brandFilters[brandIndex];
                  isSelected = filter == _selectedBrand;
                }

                return Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.sm),
                  child: FilterChip(
                    label: Text(filter),
                    selected: isSelected,
                    onSelected: (_) {
                      setState(() {
                        if (index < SampleData.capacityFilters.length) {
                          // Cập nhật bộ lọc dung lượng
                          _selectedCapacity = filter;
                        } else {
                          // Cập nhật bộ lọc thương hiệu
                          _selectedBrand = filter;
                        }
                      });
                    },
                    backgroundColor: AppColors.white,
                    selectedColor: AppColors.primary.withOpacity(0.15),
                    checkmarkColor: AppColors.primary,
                    labelStyle: TextStyle(
                      fontSize: 12,
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textSecondary,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.full),
                      side: BorderSide(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.border,
                      ),
                    ),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Xây dựng lưới sản phẩm 2 cột
  Widget _buildProductGrid() {
    final products = _filteredProducts;

    if (products.isEmpty) {
      // Hiển thị khi không có sản phẩm nào
      return Expanded(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search_off, size: 64, color: AppColors.textHint),
              const SizedBox(height: AppSpacing.md),
              Text('Không tìm thấy sản phẩm', style: AppTextStyles.subtitle),
              const SizedBox(height: AppSpacing.sm),
              Text('Thử thay đổi bộ lọc', style: AppTextStyles.caption),
            ],
          ),
        ),
      );
    }

    return Expanded(
      child: GridView.builder(
        padding: const EdgeInsets.all(AppSpacing.md),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.62,
          crossAxisSpacing: AppSpacing.md,
          mainAxisSpacing: AppSpacing.md,
        ),
        itemCount: products.length,
        itemBuilder: (context, index) {
          return ProductCard(
            product: products[index],
            onTap: () {
              // TODO: Chuyển đến trang chi tiết sản phẩm
              _showProductDetail(products[index]);
            },
          );
        },
      ),
    );
  }

  /// Hiển thị bottom sheet chi tiết sản phẩm (tạm thời)
  void _showProductDetail(Product product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          maxChildSize: 0.9,
          minChildSize: 0.5,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Thanh kéo
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  // Ảnh sản phẩm
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    child: Image.network(
                      product.imageUrl,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  // Tên sản phẩm
                  Text(product.name, style: AppTextStyles.heading),
                  const SizedBox(height: AppSpacing.sm),
                  // Thương hiệu
                  Text(
                    'Thương hiệu: ${product.brand}',
                    style: AppTextStyles.subtitle,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  // Giá
                  Row(
                    children: [
                      Text(
                        _formatPrice(product.price),
                        style: AppTextStyles.price.copyWith(fontSize: 22),
                      ),
                      if (product.originalPrice != null) ...[
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          _formatPrice(product.originalPrice!),
                          style: AppTextStyles.priceOld,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  // Mô tả
                  Text(
                    'Mô tả sản phẩm',
                    style: AppTextStyles.sectionTitle.copyWith(fontSize: 16),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    product.description,
                    style: AppTextStyles.body.copyWith(height: 1.5),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  // Nút thêm vào giỏ hàng
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Đã thêm ${product.name} vào giỏ hàng',
                            ),
                            backgroundColor: AppColors.success,
                          ),
                        );
                      },
                      icon: const Icon(Icons.shopping_cart),
                      label: const Text(
                        'Thêm vào giỏ hàng',
                        style: AppTextStyles.button,
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  /// Format giá tiền theo định dạng VNĐ
  String _formatPrice(double price) {
    final formatted = price
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]}.',
        );
    return '${formatted}đ';
  }
}
