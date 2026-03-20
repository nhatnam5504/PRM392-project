import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/promotion_model.dart';
import '../../../data/models/product_model.dart';
import '../view_models/admin_promotion_view_model.dart';
import 'admin_promotion_form_dialog.dart';

class AdminPromotionListScreen extends StatefulWidget {
  const AdminPromotionListScreen({super.key});

  @override
  State<AdminPromotionListScreen> createState() => _AdminPromotionListScreenState();
}

class _AdminPromotionListScreenState extends State<AdminPromotionListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<AdminPromotionViewModel>().loadPromotions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AdminPromotionViewModel>();

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => const AdminPromotionFormDialog(),
          ).then((result) {
            if (result == true) {
              vm.loadPromotions();
            }
          });
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          'Thêm mới',
          style: AppTextStyles.labelBold.copyWith(color: Colors.white),
        ),
      ),
      body: _buildBody(vm),
    );
  }

  Widget _buildBody(AdminPromotionViewModel vm) {
    if (vm.isLoading && vm.promotions.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (vm.errorMessage != null && vm.promotions.isEmpty) {
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
                onPressed: () => vm.loadPromotions(),
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      );
    }
    if (vm.promotions.isEmpty) {
      return const Center(
        child: Text('Chưa có khuyến mãi nào.', style: AppTextStyles.bodyMd),
      );
    }
    return RefreshIndicator(
      onRefresh: () => vm.loadPromotions(),
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: vm.promotions.length,
        itemBuilder: (context, index) {
          final promotion = vm.promotions[index];
          final List<ProductModel> products =
              vm.applicableProducts[promotion.id] ?? [];
          return _PromotionCard(
            promotion: promotion,
            applicableProducts: products,
          );
        },
      ),
    );
  }
}

class _PromotionCard extends StatelessWidget {
  final PromotionModel promotion;
  final List<ProductModel> applicableProducts;

  const _PromotionCard({
    required this.promotion,
    this.applicableProducts = const [],
  });

  String _formatCurrency(double amount) {
    final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
    return formatter.format(amount);
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    String statusText;

    if (promotion.isExpired) {
      statusColor = AppColors.error;
      statusText = 'Hết hạn';
    } else if (promotion.isUpcoming) {
      statusColor = Colors.orange;
      statusText = 'Sắp tới';
    } else if (!promotion.active) {
      statusColor = AppColors.textHint;
      statusText = 'Tạm ngưng';
    } else if (promotion.quantity <= 0) {
      statusColor = AppColors.error;
      statusText = 'Hết lượt';
    } else {
      statusColor = AppColors.success;
      statusText = 'Đang chạy';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    promotion.code,
                    style: AppTextStyles.labelBold.copyWith(color: AppColors.primary),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    statusText,
                    style: AppTextStyles.labelSm.copyWith(color: statusColor),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              promotion.description,
              style: AppTextStyles.bodyMd.copyWith(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    label: 'Loại',
                    value: promotion.type.name.toUpperCase(),
                    icon: Icons.category_outlined,
                  ),
                ),
                Expanded(
                  child: _buildInfoItem(
                    label: 'Giảm giá',
                    value: promotion.type == PromotionType.percentage
                        ? '${promotion.discountValue.toInt()}%'
                        : _formatCurrency(promotion.discountValue),
                    icon: Icons.discount_outlined,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    label: 'Tối thiểu',
                    value: _formatCurrency(promotion.minOrderAmount),
                    icon: Icons.shopping_bag_outlined,
                  ),
                ),
                Expanded(
                  child: _buildInfoItem(
                    label: 'Còn lại',
                    value: '${promotion.quantity}',
                    icon: Icons.confirmation_num_outlined,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.calendar_today_outlined, size: 16, color: AppColors.textHint),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${_formatDate(promotion.startDate)} - ${_formatDate(promotion.endDate)}',
                    style: AppTextStyles.bodySm.copyWith(color: AppColors.textSecondary),
                  ),
                ),
              ],
            ),
            if (promotion.type == PromotionType.bogo &&
                applicableProducts.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Sản phẩm áp dụng:',
                style: AppTextStyles.labelSm.copyWith(color: AppColors.textHint),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: applicableProducts.length,
                  itemBuilder: (context, idx) {
                    final product = applicableProducts[idx];
                    return Container(
                      width: 250,
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceDark,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: product.imageUrls.isNotEmpty
                                ? Image.network(
                                    product.imageUrls.first,
                                    width: 40,
                                    height: 40,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const Icon(
                                        Icons.image_not_supported,
                                        size: 20),
                                  )
                                : const Icon(Icons.image, size: 20),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  product.name,
                                  style: AppTextStyles.bodySm
                                      .copyWith(fontWeight: FontWeight.w600),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  'ID: ${product.id}',
                                  style: AppTextStyles.labelSm
                                      .copyWith(color: AppColors.textHint),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem({required String label, required String value, required IconData icon}) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppTextStyles.labelSm.copyWith(color: AppColors.textHint)),
            Text(value, style: AppTextStyles.bodySm.copyWith(fontWeight: FontWeight.w600)),
          ],
        ),
      ],
    );
  }
}
