import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/format_price.dart';
import '../../../data/dummy_data.dart';
import '../../../core/router/app_router.dart';
import '../../cart/view_models/cart_view_model.dart';
import '../../deals/view_models/deals_view_model.dart';
import '../view_models/checkout_view_model.dart';
import '../../../data/models/promotion_model.dart';
import 'payment_confirmation_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() =>
      _CheckoutScreenState();
}

class _CheckoutScreenState
    extends State<CheckoutScreen> {
  bool _initialized = false;
  final TextEditingController _promoController = TextEditingController();

  @override
  void dispose() {
    _promoController.dispose();
    super.dispose();
  }
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) {
      return;
    }
    _initialized = true;
    final checkoutVm =
        context.read<CheckoutViewModel>();
    final cartVm = context.read<CartViewModel>();
    final dealsVm =
        context.read<DealsViewModel>();
    _checkAvailability(checkoutVm, cartVm, dealsVm);
  }

  @override
  Widget build(BuildContext context) {
    final checkoutVm =
        context.watch<CheckoutViewModel>();
    final cartVm = context.watch<CartViewModel>();
    final dealsVm =
        context.watch<DealsViewModel>();
    final address = DummyData.addresses.first;

    final hasItems = cartVm.items.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Thanh toán'),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (cartVm.isLoading)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      if (!cartVm.isLoading) ...[
                        if (!hasItems)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Text(
                              'Giỏ hàng trống, vui lòng quay lại thêm sản phẩm.',
                              style: AppTextStyles.bodyMd.copyWith(
                                color: AppColors.error,
                              ),
                            ),
                          ),
                        if (hasItems)
                          _SectionCard(
                            title: 'SẢN PHẨM',
                            child: Column(
                              children: cartVm.items
                                  .map(
                                    (item) => Padding(
                                      padding: const EdgeInsets.only(bottom: 12),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(8),
                                            child: Image.network(
                                              item.imageUrl,
                                              width: 60,
                                              height: 60,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) => const Icon(
                                                Icons.image_outlined,
                                                size: 36,
                                                color: AppColors.border,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  item.productName,
                                                  style: AppTextStyles.bodyMd,
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  'Số lượng: ${item.quantity}',
                                                  style: AppTextStyles.bodySm.copyWith(
                                                    color: AppColors.textSecondary,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Text(
                                            formatVND(item.subtotal),
                                            style: AppTextStyles.labelBold,
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ),
                        if (hasItems) const SizedBox(height: 12),
                        // 1. Delivery address
                        _SectionCard(
                          title: 'ĐỊA CHỈ GIAO HÀNG',
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    address.recipientName,
                                    style:
                                        AppTextStyles.labelBold,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    address.phone,
                                    style:
                                        AppTextStyles.bodySm,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                address.fullAddress,
                                style: AppTextStyles.bodyMd
                                    .copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              GestureDetector(
                                onTap: () => context.push(
                                  '/checkout/addresses',
                                ),
                                child: Text(
                                  'Thay đổi',
                                  style: AppTextStyles.labelBold
                                      .copyWith(
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        // 1b. Promotion code
                        _PromoSection(
                          controller: _promoController,
                          isLoading: checkoutVm.isLoading,
                          appliedPromotion: checkoutVm.appliedPromotion,
                          onApply: () async {
                            await checkoutVm.applyPromotion(_promoController.text);
                          },
                          onClear: checkoutVm.clearPromotion,
                        ),
                        const SizedBox(height: 12),
                        // 2. Price breakdown
                        _SectionCard(
                          title: 'CHI TIẾT THANH TOÁN',
                          child: Column(
                            children: [
                              _PriceRow(
                                'Tạm tính',
                                formatVND(
                                  checkoutVm.checkResult?.basePrice ??
                                      checkoutVm.checkResult?.totalPrice ??
                                      0,
                                ),
                              ),
                              if (checkoutVm.discountPreview > 0)
                                Padding(
                                  padding:
                                      const EdgeInsets.only(top: 8),
                                  child: _PriceRow(
                                    'Giảm giá dự kiến',
                                    '-${formatVND(checkoutVm.discountPreview)}',
                                    color: AppColors.success,
                                  ),
                                ),
                              const SizedBox(height: 8),
                              const Divider(
                                color: AppColors.divider,
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment
                                        .spaceBetween,
                                children: [
                                  Text(
                                    'Tổng cộng',
                                    style:
                                        AppTextStyles.headingSm,
                                  ),
                                  Text(
                                    formatVND(
                                      checkoutVm.payableTotal,
                                    ),
                                    style: AppTextStyles.priceLg,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        if (checkoutVm.isLoading)
                          const Padding(
                            padding: EdgeInsets.only(top: 12),
                            child: Center(
                              child: CircularProgressIndicator(
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                      ],
                      if (checkoutVm.errorMessage != null &&
                          checkoutVm.checkResult == null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            checkoutVm.errorMessage!,
                            style: AppTextStyles.bodySm.copyWith(
                              color: AppColors.error,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(
            top: BorderSide(
              color: AppColors.borderLight,
            ),
          ),
        ),
        child: SizedBox(
          height: 56,
          child: ElevatedButton(
            onPressed: checkoutVm.isLoading
                ? null
                : () async {
                    final success = await _checkAvailability(
                      checkoutVm,
                      cartVm,
                      dealsVm,
                    );
                    if (!mounted || !success) {
                      return;
                    }
                    if (checkoutVm.checkResult == null) {
                      return;
                    }

                    // Call makePayment directly from Checkout page
                    final url = await checkoutVm.makePayment();
                    if (!mounted) return;
                    if (url != null) {
                      final uri = Uri.parse(url);
                      // On Android 11+ canLaunchUrl might return false without queries in manifest
                      // We try to launch anyway if it's a valid https link
                      try {
                        final launched = await launchUrl(
                          uri,
                          mode: LaunchMode.externalApplication,
                        );
                        if (launched && mounted) {
                          // Sau khi mở URL thanh toán, xóa giỏ hàng và đưa người dùng về trang chủ
                          await cartVm.clearCart();
                          if (mounted) {
                            context.go('/');
                          }
                        } else if (!launched && mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Không thể mở trang thanh toán.')),
                          );
                        }
                      } catch (e) {
                        debugPrint('Error launching URL: $e');
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Lỗi: ${e.toString()}')),
                          );
                        }
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            checkoutVm.errorMessage ??
                                'Không thể tạo liên kết thanh toán.',
                          ),
                        ),
                      );
                    }
                  },
            child: Text(
              'Đặt hàng — ${formatVND(checkoutVm.payableTotal)}',
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> _checkAvailability(
    CheckoutViewModel checkoutVm,
    CartViewModel cartVm,
    DealsViewModel dealsVm,
  ) async {
    if (cartVm.items.isEmpty && !cartVm.isLoading) {
      await cartVm.loadCart();
    }
    final bogoIds = _buildBogoProductIds(dealsVm);
    final success = await checkoutVm.checkAvailability(
      items: cartVm.items,
      bogoProductIds: bogoIds,
    );
    return success;
  }

  Set<int> _buildBogoProductIds(
    DealsViewModel dealsVm,
  ) {
    final ids = <int>{};
    for (final promo in dealsVm.bogoPromotions) {
      if (promo.isActive &&
          promo.applicableProductIds != null) {
        ids.addAll(promo.applicableProductIds!);
      }
    }
    return ids;
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.labelSm.copyWith(
              color: AppColors.textSecondary,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}


class _PriceRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;

  const _PriceRow(
    this.label,
    this.value, {
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment:
          MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyMd.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: AppTextStyles.labelBold.copyWith(
            color: color,
          ),
        ),
      ],
    );
  }
}

class _PromoSection extends StatelessWidget {
  const _PromoSection({
    required this.controller,
    required this.isLoading,
    required this.appliedPromotion,
    required this.onApply,
    required this.onClear,
  });

  final TextEditingController controller;
  final bool isLoading;
  final PromotionModel? appliedPromotion;
  final VoidCallback onApply;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'MÃ GIẢM GIÁ',
            style: AppTextStyles.labelSm.copyWith(
              color: AppColors.textSecondary,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  decoration: const InputDecoration(
                    hintText: 'Nhập mã giảm giá',
                    filled: true,
                    fillColor: AppColors.inputBackground,
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.border),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: isLoading ? null : onApply,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    minimumSize: const Size(100, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Áp dụng'),
                ),
              ),
            ],
          ),
          if (appliedPromotion != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Đã áp dụng: ${appliedPromotion!.code}',
                        style: AppTextStyles.labelBold.copyWith(
                          color: AppColors.success,
                        ),
                      ),
                      TextButton(
                        onPressed: isLoading ? null : onClear,
                        child: const Text('Bỏ mã'),
                      ),
                    ],
                  ),
                  if (appliedPromotion!.description.isNotEmpty)
                    Text(
                      appliedPromotion!.description,
                      style: AppTextStyles.bodySm.copyWith(
                        color: AppColors.textSecondary,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
