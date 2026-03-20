import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/promotion_model.dart';
import '../../../data/models/product_model.dart';
import '../view_models/admin_promotion_view_model.dart';
import '../../../core/utils/format_price.dart';
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
          elevation: 0,
          highlightElevation: 0,
          icon: const Icon(Icons.add_rounded, color: Colors.white),
          label: Text('THÊM KHUYẾN MÃI', style: AppTextStyles.labelBold.copyWith(color: Colors.white, letterSpacing: 0.5)),
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
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded, size: 64, color: AppColors.error),
              const SizedBox(height: 16),
              Text(vm.errorMessage!, style: AppTextStyles.bodyMd, textAlign: TextAlign.center),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => vm.loadPromotions(),
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
    if (vm.promotions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.local_offer_rounded, size: 64, color: AppColors.textHint.withValues(alpha: 0.2)),
            const SizedBox(height: 16),
            Text('Chưa có khuyến mãi nào', style: AppTextStyles.headingSm.copyWith(color: AppColors.textHint)),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: () => vm.loadPromotions(),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
        itemCount: vm.promotions.length,
        itemBuilder: (context, index) {
          final promotion = vm.promotions[index];
          final List<ProductModel> products = vm.applicableProducts[promotion.id] ?? [];
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
    return formatVND(amount);
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy • HH:mm').format(date);
  }

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    String statusText;

    if (promotion.isExpired) {
      statusColor = AppColors.error;
      statusText = 'HẾT HẠN';
    } else if (promotion.isUpcoming) {
      statusColor = Colors.orange;
      statusText = 'SẮP TỚI';
    } else if (!promotion.active) {
      statusColor = AppColors.textHint;
      statusText = 'TẠM NGƯNG';
    } else if (promotion.quantity <= 0) {
      statusColor = AppColors.error;
      statusText = 'HẾT LƯỢT';
    } else {
      statusColor = AppColors.success;
      statusText = 'ĐANG CHẠY';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Code and Status
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      promotion.code,
                      style: AppTextStyles.labelBold.copyWith(
                        color: AppColors.primary,
                        letterSpacing: 1.5,
                        fontSize: 15,
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
                        const SizedBox(width: 8),
                        Text(
                          statusText,
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.w900,
                            fontSize: 10,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  _CircleIconButton(
                    icon: Icons.edit_note_rounded,
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
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                promotion.description,
                style: AppTextStyles.bodyMd.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textHeading,
                  fontSize: 16,
                ),
              ),
            ),

            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 2.8,
                children: [
                  _InfoBox(
                    label: 'LOẠI GIẢM GIÁ',
                    value: promotion.type == PromotionType.percentage ? 'PHẦN TRĂM' : 'TIỀN MẶT',
                    icon: Icons.category_rounded,
                  ),
                  _InfoBox(
                    label: 'GIÁ TRỊ GIẢM',
                    value: promotion.type == PromotionType.percentage
                        ? '${promotion.discountValue.toInt()}%'
                        : _formatCurrency(promotion.discountValue),
                    icon: Icons.local_offer_rounded,
                  ),
                  _InfoBox(
                    label: 'ĐƠN TỐI THIỂU',
                    value: _formatCurrency(promotion.minOrderAmount),
                    icon: Icons.shopping_basket_rounded,
                  ),
                  _InfoBox(
                    label: 'LƯỢT CÒN LẠI',
                    value: '${promotion.quantity}',
                    icon: Icons.confirmation_number_rounded,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: AppColors.surfaceDark.withValues(alpha: 0.5),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today_rounded, size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 10),
                  Text(
                    '${_formatDate(promotion.startDate)}  👉  ${_formatDate(promotion.endDate)}',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
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
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SẢN PHẨM ÁP DỤNG',
            style: AppTextStyles.labelBold.copyWith(
              color: AppColors.textHint,
              fontSize: 10,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 64,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: applicableProducts.length,
              itemBuilder: (context, idx) {
                final product = applicableProducts[idx];
                return Container(
                  width: 240,
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceDark.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: product.imageUrls.isNotEmpty
                            ? Image.network(
                                product.imageUrls.first,
                                width: 48,
                                height: 48,
                                fit: BoxFit.cover,
                              )
                            : Container(width: 48, height: 48, color: AppColors.surfaceDark),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              product.name,
                              style: AppTextStyles.bodySm.copyWith(fontWeight: FontWeight.w800),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'SKU: ${product.id}',
                              style: AppTextStyles.caption.copyWith(fontSize: 10),
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
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 18, color: AppColors.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(label, style: AppTextStyles.labelBold.copyWith(color: AppColors.textHint, fontSize: 9, letterSpacing: 0.5)),
              const SizedBox(height: 2),
              Text(value, style: AppTextStyles.bodySm.copyWith(fontWeight: FontWeight.w900, color: AppColors.textHeading)),
            ],
          ),
        ),
      ],
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

