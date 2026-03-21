import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../cart/view_models/cart_view_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/format_price.dart';
import '../../../data/models/promotion_model.dart';
import '../view_models/payment_confirmation_view_model.dart';

class PaymentConfirmationArgs {
  PaymentConfirmationArgs({
    required this.orderCode,
    required this.totalAmount,
  });

  final String orderCode;
  final double totalAmount;
}

class PaymentConfirmationScreen extends StatefulWidget {
  const PaymentConfirmationScreen({super.key, required this.args});

  final PaymentConfirmationArgs args;

  @override
  State<PaymentConfirmationScreen> createState() => _PaymentConfirmationScreenState();
}

class _PaymentConfirmationScreenState extends State<PaymentConfirmationScreen> {
  final TextEditingController _promoController = TextEditingController();

  @override
  void dispose() {
    _promoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PaymentConfirmationViewModel(
        orderCode: widget.args.orderCode,
        baseAmount: widget.args.totalAmount,
      ),
      builder: (context, _) => Consumer<PaymentConfirmationViewModel>(
        builder: (context, vm, child) {
          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              centerTitle: true,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20),
                onPressed: () => context.pop(),
              ),
              title: const Text('Xác nhận thanh toán', style: AppTextStyles.headingMd),
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SummaryCard(
                      total: widget.args.totalAmount,
                      payable: vm.payableTotal,
                      discount: vm.discountPreview,
                    ),
                    const SizedBox(height: 24),
                    _PromoCard(
                      controller: _promoController,
                      isLoading: vm.isLoading,
                      errorText: vm.errorMessage,
                      appliedCode: vm.appliedPromotion?.code,
                      appliedPromotion: vm.appliedPromotion,
                      onApply: () async {
                        await vm.applyPromotion(_promoController.text);
                      },
                      onClear: vm.clearPromotion,
                    ),
                    if (vm.isLoading)
                      const Padding(
                        padding: EdgeInsets.only(top: 24),
                        child: Center(
                          child: CircularProgressIndicator(color: AppColors.primary),
                        ),
                      ),
                    const SizedBox(height: 120), // Khoảng trống cho bottom button
                  ],
                ),
              ),
            ),
            bottomNavigationBar: Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: vm.isLoading
                      ? null
                      : () async {
                          final url = await vm.makePayment();
                          if (!mounted) return;
                          if (url != null) {
                            final uri = Uri.parse(url);
                            try {
                              final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
                              if (launched && mounted) {
                                await Provider.of<CartViewModel>(context, listen: false).clearCart();
                                if (mounted) context.go('/');
                              } else if (!launched && mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Không thể chuyển đến trang thanh toán.'), behavior: SnackBarBehavior.floating),
                                );
                              }
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Lỗi: ${e.toString()}'), behavior: SnackBarBehavior.floating),
                                );
                              }
                            }
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(vm.errorMessage ?? 'Lỗi tạo link thanh toán.'), behavior: SnackBarBehavior.floating),
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: Text(
                    'THANH TOÁN — ${formatVND(vm.payableTotal)}',
                    style: AppTextStyles.labelBold.copyWith(color: Colors.white),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.total,
    required this.payable,
    required this.discount,
  });

  final double total;
  final double payable;
  final double discount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.surfaceDark, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.receipt_long_rounded, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              const Text('Tóm tắt đơn hàng', style: AppTextStyles.labelBold),
            ],
          ),
          const SizedBox(height: 20),
          _PriceRow(label: 'Tạm tính', value: formatVND(total)),
          if (discount > 0)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: _PriceRow(
                label: 'Giảm giá dự kiến',
                value: '-${formatVND(discount)}',
                color: AppColors.success,
              ),
            ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Divider(height: 1, color: AppColors.surfaceDark),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Số tiền thanh toán', style: AppTextStyles.headingSm),
              Text(
                formatVND(payable),
                style: AppTextStyles.priceLg.copyWith(color: AppColors.primary, fontSize: 24),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PromoCard extends StatelessWidget {
  const _PromoCard({
    required this.controller,
    required this.isLoading,
    required this.errorText,
    required this.appliedCode,
    this.appliedPromotion,
    required this.onApply,
    required this.onClear,
  });

  final TextEditingController controller;
  final bool isLoading;
  final String? errorText;
  final String? appliedCode;
  final PromotionModel? appliedPromotion;
  final VoidCallback onApply;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primary.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'MÃ GIẢM GIÁ',
            style: AppTextStyles.labelBold.copyWith(color: AppColors.primary, fontSize: 11, letterSpacing: 0.8),
          ),
          const SizedBox(height: 16),
          if (appliedCode == null)
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    style: AppTextStyles.bodyMd,
                    decoration: InputDecoration(
                      hintText: 'Nhập mã giảm giá',
                      hintStyle: AppTextStyles.bodyMd.copyWith(color: AppColors.textHint, fontSize: 13),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.primary, width: 1),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 100,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : onApply,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: const Text('ÁP DỤNG'),
                  ),
                ),
              ],
            )
          else
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.success.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Mã: $appliedCode', style: AppTextStyles.labelBold.copyWith(color: AppColors.success)),
                        if (appliedPromotion?.description != null)
                          Text(
                            appliedPromotion!.description,
                            style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: isLoading ? null : onClear,
                    child: const Text('BỎ MÃ', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          if (errorText != null && appliedCode == null)
            Padding(
              padding: const EdgeInsets.only(top: 12, left: 4),
              child: Text(
                errorText!,
                style: AppTextStyles.bodySm.copyWith(color: AppColors.error, fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  const _PriceRow({
    required this.label,
    required this.value,
    this.color,
  });

  final String label;
  final String value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.bodyMd.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
        Text(value, style: AppTextStyles.labelBold.copyWith(color: color ?? AppColors.textPrimary)),
      ],
    );
  }
}


