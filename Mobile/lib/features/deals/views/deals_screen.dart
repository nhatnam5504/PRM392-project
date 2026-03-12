import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/format_price.dart';
import '../../../data/models/product_model.dart';
import '../../../data/models/promotion_model.dart';
import '../view_models/deals_view_model.dart';

class DealsScreen extends StatefulWidget {
  const DealsScreen({super.key});

  @override
  State<DealsScreen> createState() =>
      _DealsScreenState();
}

class _DealsScreenState extends State<DealsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        final vm = context.read<DealsViewModel>();
        if (vm.promotions.isEmpty) {
          vm.loadDeals();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ưu đãi & Khuyến mãi'),
      ),
      body: Consumer<DealsViewModel>(
        builder: (context, vm, _) {
          if (vm.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            );
          }

          if (vm.errorMessage != null) {
            return _buildError(vm);
          }

          if (vm.promotions.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.local_offer_outlined,
                    size: 64,
                    color: AppColors.textHint,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Chưa có ưu đãi nào',
                    style: AppTextStyles.bodyLg,
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: vm.loadDeals,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Money promotions
                if (vm.moneyPromotions
                    .isNotEmpty) ...[
                  _buildSectionHeader(
                    Icons.money_off,
                    'Giảm giá trực tiếp',
                    AppColors.success,
                  ),
                  const SizedBox(height: 12),
                  ...vm.moneyPromotions.map(
                    (p) => _buildMoneyCard(p),
                  ),
                  const SizedBox(height: 24),
                ],

                // Percentage promotions
                if (vm.percentagePromotions
                    .isNotEmpty) ...[
                  _buildSectionHeader(
                    Icons.percent,
                    'Giảm theo phần trăm',
                    AppColors.accent,
                  ),
                  const SizedBox(height: 12),
                  ...vm.percentagePromotions.map(
                    (p) =>
                        _buildPercentageCard(p),
                  ),
                  const SizedBox(height: 24),
                ],

                // BOGO promotions
                if (vm.bogoPromotions
                    .isNotEmpty) ...[
                  _buildSectionHeader(
                    Icons.card_giftcard,
                    'Mua 1 Tặng 1',
                    AppColors.primary,
                  ),
                  const SizedBox(height: 12),
                  ...vm.bogoPromotions.map(
                    (p) => _buildBogoCard(
                      p,
                      vm.bogoProducts[p.id] ?? [],
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildError(DealsViewModel vm) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            Text(
              vm.errorMessage!,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMd.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: vm.loadDeals,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(12),
                ),
              ),
              child: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    IconData icon,
    String title,
    Color color,
  ) {
    return Row(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(width: 8),
        Text(
          title,
          style: AppTextStyles.headingSm.copyWith(
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildPromoStatusBadge(
    PromotionModel promo,
  ) {
    if (promo.isExpired) {
      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 4,
        ),
        decoration: BoxDecoration(
          color: AppColors.textHint
              .withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          'Đã hết hạn',
          style: AppTextStyles.labelSm.copyWith(
            color: AppColors.textHint,
          ),
        ),
      );
    }
    if (promo.quantity <= 0) {
      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 4,
        ),
        decoration: BoxDecoration(
          color: AppColors.error
              .withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          'Đã hết lượt',
          style: AppTextStyles.labelSm.copyWith(
            color: AppColors.error,
          ),
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: AppColors.success
            .withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        'Còn ${promo.quantity} lượt',
        style: AppTextStyles.labelSm.copyWith(
          color: AppColors.success,
        ),
      ),
    );
  }

  Widget _buildDateRange(PromotionModel promo) {
    final fmt = DateFormat('dd/MM/yyyy');
    return Row(
      children: [
        const Icon(
          Icons.calendar_today_outlined,
          size: 14,
          color: AppColors.textHint,
        ),
        const SizedBox(width: 4),
        Text(
          '${fmt.format(promo.startDate)} - '
          '${fmt.format(promo.endDate)}',
          style: AppTextStyles.bodySm,
        ),
      ],
    );
  }

  Widget _buildMoneyCard(PromotionModel promo) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: promo.isActive
              ? AppColors.success
                  .withValues(alpha: 0.3)
              : AppColors.border,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.success,
                  borderRadius:
                      BorderRadius.circular(8),
                ),
                child: Text(
                  '-${formatVND(promo.discountValue)}',
                  style: AppTextStyles.labelBold
                      .copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  promo.description,
                  style: AppTextStyles.headingSm,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildCodeChip(promo.code),
          const SizedBox(height: 8),
          if (promo.minOrderAmount > 0) ...[
            Text(
              'Đơn tối thiểu: '
              '${formatVND(promo.minOrderAmount)}',
              style: AppTextStyles.bodySm,
            ),
            const SizedBox(height: 4),
          ],
          Row(
            children: [
              Expanded(
                child: _buildDateRange(promo),
              ),
              _buildPromoStatusBadge(promo),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPercentageCard(
    PromotionModel promo,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: promo.isActive
              ? AppColors.accent
                  .withValues(alpha: 0.3)
              : AppColors.border,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius:
                      BorderRadius.circular(8),
                ),
                child: Text(
                  '-${promo.discountValue.toInt()}%',
                  style: AppTextStyles.labelBold
                      .copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  promo.description,
                  style: AppTextStyles.headingSm,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildCodeChip(promo.code),
          const SizedBox(height: 8),
          if (promo.maxDiscountValue > 0) ...[
            Text(
              'Giảm tối đa: '
              '${formatVND(promo.maxDiscountValue)}',
              style: AppTextStyles.bodySm,
            ),
            const SizedBox(height: 4),
          ],
          if (promo.minOrderAmount > 0) ...[
            Text(
              'Đơn tối thiểu: '
              '${formatVND(promo.minOrderAmount)}',
              style: AppTextStyles.bodySm,
            ),
            const SizedBox(height: 4),
          ],
          Row(
            children: [
              Expanded(
                child: _buildDateRange(promo),
              ),
              _buildPromoStatusBadge(promo),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBogoCard(
    PromotionModel promo,
    List<ProductModel> products,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: promo.isActive
              ? AppColors.primary
                  .withValues(alpha: 0.3)
              : AppColors.border,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius:
                      BorderRadius.circular(8),
                ),
                child: Text(
                  'BOGO',
                  style: AppTextStyles.labelBold
                      .copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  promo.description,
                  style: AppTextStyles.headingSm,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildCodeChip(promo.code),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildDateRange(promo),
              ),
              _buildPromoStatusBadge(promo),
            ],
          ),
          if (products.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Divider(
              color: AppColors.divider,
              height: 1,
            ),
            const SizedBox(height: 12),
            Text(
              'Sản phẩm áp dụng:',
              style: AppTextStyles.labelBold
                  .copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            ...products.map(
              (product) =>
                  _buildBogoProductItem(product),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBogoProductItem(
    ProductModel product,
  ) {
    return GestureDetector(
      onTap: () {
        context.push('/products/${product.id}');
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.primaryLight
              .withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius:
                  BorderRadius.circular(8),
              child: product.imageUrls.isNotEmpty
                  ? Image.network(
                      product.imageUrls.first,
                      width: 56,
                      height: 56,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (_, __, ___) =>
                              _buildPlaceholder(),
                    )
                  : _buildPlaceholder(),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow:
                        TextOverflow.ellipsis,
                    style: AppTextStyles.bodyMd
                        .copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formatVND(product.price),
                    style: AppTextStyles.priceSm,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius:
                    BorderRadius.circular(6),
              ),
              child: Text(
                'Mua 1\nTặng 1',
                textAlign: TextAlign.center,
                style: AppTextStyles.labelSm
                    .copyWith(
                  color: Colors.white,
                  height: 1.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(
        Icons.image_outlined,
        color: AppColors.textHint,
        size: 24,
      ),
    );
  }

  Widget _buildCodeChip(String code) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: AppColors.inputBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.border,
          style: BorderStyle.solid,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.confirmation_number_outlined,
            size: 16,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 6),
          Text(
            code,
            style: AppTextStyles.labelBold.copyWith(
              color: AppColors.textPrimary,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
