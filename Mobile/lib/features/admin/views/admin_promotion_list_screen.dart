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
        padding: const EdgeInsets.symmetric(vertical: 16),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with Code and Status
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                    ),
                    child: Text(
                      promotion.code,
                      style: AppTextStyles.labelBold.copyWith(
                        color: AppColors.primary,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          statusText,
                          style: AppTextStyles.labelSm.copyWith(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  _CircleIconButton(
                    icon: Icons.edit_rounded,
                    color: AppColors.primary,
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => AdminPromotionFormDialog(
                          initialPromotion: promotion,
                        ),
                      ).then((result) {
                        if (result == true) {
                          context.read<AdminPromotionViewModel>().loadPromotions();
                        }
                      });
                    },
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                promotion.description,
                style: AppTextStyles.bodyMd.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textHeading,
                ),
              ),
            ),

            const SizedBox(height: 16),
            const Divider(height: 1, indent: 16, endIndent: 16, color: AppColors.divider),
            
            Padding(
              padding: const EdgeInsets.all(16),
              child: Wrap(
                runSpacing: 12,
                children: [
                  _InfoBox(
                    label: 'LOẠI',
                    value: promotion.type.name.toUpperCase(),
                    icon: Icons.category_rounded,
                  ),
                  _InfoBox(
                    label: 'GIẢM GIÁ',
                    value: promotion.type == PromotionType.percentage
                        ? '${promotion.discountValue.toInt()}%'
                        : _formatCurrency(promotion.discountValue),
                    icon: Icons.local_offer_rounded,
                  ),
                  _InfoBox(
                    label: 'TỐI THIỂU',
                    value: _formatCurrency(promotion.minOrderAmount),
                    icon: Icons.shopping_basket_rounded,
                  ),
                  _InfoBox(
                    label: 'CÒN LẠI',
                    value: '${promotion.quantity}',
                    icon: Icons.confirmation_number_rounded,
                  ),
                ],
              ),
            ),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: AppColors.surfaceDark.withValues(alpha: 0.5),
              child: Row(
                children: [
                  const Icon(Icons.date_range_rounded, size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 8),
                  Text(
                    '${_formatDate(promotion.startDate)} - ${_formatDate(promotion.endDate)}',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            if (promotion.type == PromotionType.bogo && applicableProducts.isNotEmpty)
              _buildApplicableProducts(),
          ],
        ),
      ),
    );
  }

  Widget _buildApplicableProducts() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SẢN PHẨM ÁP DỤNG',
            style: AppTextStyles.labelBold.copyWith(
              color: AppColors.textHint,
              fontSize: 10,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: applicableProducts.length,
              itemBuilder: (context, idx) {
                final product = applicableProducts[idx];
                return Container(
                  width: 220,
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: product.imageUrls.isNotEmpty
                            ? Image.network(
                                product.imageUrls.first,
                                width: 44,
                                height: 44,
                                fit: BoxFit.cover,
                              )
                            : Container(width: 44, height: 44, color: AppColors.surfaceDark),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              product.name,
                              style: AppTextStyles.bodySm.copyWith(fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              'ID: ${product.id}',
                              style: AppTextStyles.caption,
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
      ),
    );
  }
}

class _InfoBox extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _InfoBox({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: (MediaQuery.of(context).size.width - 64) / 2,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 16, color: AppColors.primary),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTextStyles.labelBold.copyWith(color: AppColors.textHint, fontSize: 9)),
                Text(value, style: AppTextStyles.bodySm.copyWith(fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _CircleIconButton({required this.icon, required this.color, required this.onTap});

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
          child: Icon(icon, color: color, size: 18),
        ),
      ),
    );
  }
}

