import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/product_model.dart';
import '../view_models/admin_product_view_model.dart';

class AdminProductListScreen extends StatefulWidget {
  const AdminProductListScreen({super.key});

  @override
  State<AdminProductListScreen> createState() => _AdminProductListScreenState();
}

class _AdminProductListScreenState extends State<AdminProductListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<AdminProductViewModel>().loadProducts();
    });
  }

  Future<void> _confirmDelete(ProductModel product) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận xoá'),
        content: Text('Bạn có chắc muốn xoá "${product.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Huỷ'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Xoá'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      final vm = context.read<AdminProductViewModel>();
      final success = await vm.deleteProduct(product.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success ? 'Đã xoá sản phẩm' : (vm.errorMessage ?? 'Lỗi'),
            ),
            backgroundColor: success ? AppColors.success : AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AdminProductViewModel>();

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/admin/products/add'),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          'Thêm SP',
          style: AppTextStyles.labelBold.copyWith(color: Colors.white),
        ),
      ),
      body: _buildBody(vm),
    );
  }

  Widget _buildBody(AdminProductViewModel vm) {
    if (vm.isLoading && vm.products.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (vm.errorMessage != null && vm.products.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SelectableText(vm.errorMessage!,
                  style: AppTextStyles.bodyMd, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => vm.loadProducts(),
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      );
    }

    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border(bottom: BorderSide(color: AppColors.divider.withValues(alpha: 0.5))),
            ),
            child: TabBar(
              labelPadding: const EdgeInsets.symmetric(horizontal: 0),
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: AppColors.primary.withValues(alpha: 0.12),
              ),
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textSecondary,
              labelStyle: AppTextStyles.labelBold.copyWith(fontSize: 14),
              unselectedLabelStyle: AppTextStyles.labelMd.copyWith(fontSize: 14),
              dividerColor: Colors.transparent,
              tabs: const [
                Tab(child: Center(child: Text('📦 SẢN PHẨM'))),
                Tab(child: Center(child: Text('🛠️ DỊCH VỤ'))),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildProductList(vm, true),
                _buildProductList(vm, false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductList(AdminProductViewModel vm, bool isProduct) {
    final filteredProducts =
        vm.products.where((p) => p.type == isProduct).toList();

    if (filteredProducts.isEmpty) {
      return Center(
        child: Text(
          isProduct ? 'Chưa có sản phẩm nào.' : 'Chưa có dịch vụ nào.',
          style: AppTextStyles.bodyMd,
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => vm.loadProducts(),
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: filteredProducts.length,
        itemBuilder: (context, index) {
          final product = filteredProducts[index];
          return _ProductCard(
            product: product,
            onEdit: () => context.push('/admin/products/edit/${product.id}'),
            onDelete: () => _confirmDelete(product),
          );
        },
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ProductCard({
    required this.product,
    required this.onEdit,
    required this.onDelete,
  });

  String _formatPrice(double price) {
    final intPrice = price.toInt();
    final str = intPrice.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) buffer.write('.');
      buffer.write(str[i]);
    }
    return '${buffer}đ';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryShadow.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Product Image
              _buildImageSection(),
              // Product Info
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildStatusBadge(),
                          Text(
                            '#${product.id}',
                            style: AppTextStyles.labelSm.copyWith(
                              color: AppColors.textHint,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        product.name,
                        style: AppTextStyles.headingSm.copyWith(
                          color: AppColors.textHeading,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.tag_rounded, size: 12, color: AppColors.textHint),
                          const SizedBox(width: 4),
                          Text(
                            '${product.brandName} • ${product.categoryName}',
                            style: AppTextStyles.bodySm.copyWith(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                      const Spacer(),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _formatPrice(product.price),
                                style: AppTextStyles.priceMd.copyWith(
                                  color: AppColors.primary,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Icon(
                                    Icons.inventory_2_outlined,
                                    size: 14,
                                    color: product.stockQuantity < 10 ? AppColors.error : AppColors.textSecondary,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Kho: ${product.stockQuantity}',
                                    style: AppTextStyles.bodySm.copyWith(
                                      color: product.stockQuantity < 10 ? AppColors.error : AppColors.textSecondary,
                                      fontWeight: product.stockQuantity < 10 ? FontWeight.bold : FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          _buildActionButtons(),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Container(
      width: 130,
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          product.imageUrls.isNotEmpty
              ? Image.network(
                  product.imageUrls.first,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.image_not_supported_outlined,
                    color: AppColors.textHint,
                    size: 32,
                  ),
                )
              : const Icon(
                  Icons.inventory_2_outlined,
                  color: AppColors.textHint,
                  size: 32,
                ),
          // Gradient overlay for better look
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withValues(alpha: 0.1),
                    Colors.transparent,
                  ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge() {
    final bool isActive = product.active;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isActive 
            ? AppColors.success.withValues(alpha: 0.1) 
            : AppColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        isActive ? 'ĐANG BÁN' : 'NGỪNG BÁN',
        style: AppTextStyles.labelSm.copyWith(
          color: isActive ? AppColors.success : AppColors.error,
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _CircleIconButton(
          icon: Icons.edit_rounded,
          color: AppColors.primary,
          onTap: onEdit,
        ),
        const SizedBox(width: 8),
        _CircleIconButton(
          icon: Icons.delete_outline_rounded,
          color: AppColors.error,
          onTap: onDelete,
        ),
      ],
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _CircleIconButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.1),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(icon, color: color, size: 20),
        ),
      ),
    );
  }
}
