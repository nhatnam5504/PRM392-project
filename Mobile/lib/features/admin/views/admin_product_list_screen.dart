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

  Future<void> _deleteProduct(ProductModel product) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc chắn muốn xóa "${product.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Hủy')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Xóa'),
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
            content: Text(success ? 'Đã xóa sản phẩm' : (vm.errorMessage ?? 'Có lỗi xảy ra')),
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
      backgroundColor: Colors.transparent,
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: () => context.push('/admin/products/add'),
          backgroundColor: AppColors.primary,
          elevation: 0,
          highlightElevation: 0,
          icon: const Icon(Icons.add_rounded, color: Colors.white),
          label: Text(
            'THÊM SẢN PHẨM',
            style: AppTextStyles.labelBold.copyWith(color: Colors.white, letterSpacing: 1),
          ),
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
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline_rounded, color: AppColors.error, size: 64),
              const SizedBox(height: 16),
              const Text('Đã có lỗi xảy ra', style: AppTextStyles.headingSm),
              const SizedBox(height: 8),
              Text(vm.errorMessage!,
                  style: AppTextStyles.bodyMd.copyWith(color: AppColors.textSecondary), textAlign: TextAlign.center),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => vm.loadProducts(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Thử lại', style: TextStyle(color: Colors.white)),
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
            margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.surfaceDark.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: TabBar(
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
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
              dividerColor: Colors.transparent,
              tabs: const [
                Tab(child: Text('📦 SẢN PHẨM')),
                Tab(child: Text('🛠️ DỊCH VỤ')),
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
    final filteredProducts = vm.products.where((p) => p.type == isProduct).toList();

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
            onDelete: () => _deleteProduct(product),
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
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildImageSection(),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
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
                              color: AppColors.textHint.withValues(alpha: 0.6),
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        product.name,
                        style: AppTextStyles.headingSm.copyWith(
                          color: AppColors.textHeading,
                          fontSize: 15,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceDark,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Icon(Icons.inventory_2_rounded, size: 10, color: AppColors.textSecondary),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            product.brandName,
                            style: AppTextStyles.bodyMd.copyWith(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            ' • ${product.categoryName}',
                            style: AppTextStyles.bodySm.copyWith(color: AppColors.textHint),
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
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    product.stockQuantity < 10 ? Icons.warning_amber_rounded : Icons.check_circle_outline_rounded,
                                    size: 14,
                                    color: product.stockQuantity < 10 ? AppColors.error : AppColors.success,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Kho: ${product.stockQuantity}',
                                    style: AppTextStyles.bodySm.copyWith(
                                      color: product.stockQuantity < 10 ? AppColors.error : AppColors.textSecondary,
                                      fontWeight: product.stockQuantity < 10 ? FontWeight.w900 : FontWeight.w600,
                                      fontSize: 12,
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
      width: 110,
      margin: const EdgeInsets.all(8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Container(color: AppColors.surfaceDark),
            product.imageUrls.isNotEmpty
                ? Image.network(
                    product.imageUrls.first,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.broken_image_outlined,
                      color: AppColors.textHint,
                      size: 24,
                    ),
                  )
                : const Icon(
                    Icons.inventory_2_outlined,
                    color: AppColors.textHint,
                    size: 24,
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    final bool isActive = product.active;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isActive 
            ? AppColors.success.withValues(alpha: 0.1) 
            : AppColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: isActive ? AppColors.success : AppColors.error,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            isActive ? 'ĐANG BÁN' : 'NGỪNG BÁN',
            style: AppTextStyles.labelSm.copyWith(
              color: isActive ? AppColors.success : AppColors.error,
              fontWeight: FontWeight.w900,
              fontSize: 9,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _CircleIconButton(
          icon: Icons.edit_note_rounded,
          color: AppColors.primary,
          onTap: onEdit,
        ),
        const SizedBox(width: 8),
        _CircleIconButton(
          icon: Icons.delete_sweep_rounded,
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
      color: color.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, color: color, size: 22),
        ),
      ),
    );
  }
}
