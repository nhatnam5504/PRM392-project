import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

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
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.pop(),
              ),
              title: const Text('Xác nhận thanh toán'),
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SummaryCard(
                      total: widget.args.totalAmount,
                      payable: vm.payableTotal,
                      discount: vm.discountPreview,
                    ),
                    const SizedBox(height: 12),
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
                        padding: EdgeInsets.only(top: 16),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            bottomNavigationBar: Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                border: Border(
                  top: BorderSide(color: AppColors.borderLight),
                ),
              ),
              child: SizedBox(
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
                              final launched = await launchUrl(
                                uri,
                                mode: LaunchMode.externalApplication,
                              );
                              if (launched && mounted) {
                                // Sau khi mở URL thanh toán, xóa giỏ hàng và đưa người dùng về trang chủ
                                await Provider.of<CartViewModel>(context, listen: false).clearCart();
                                if (mounted) {
                                  context.go('/');
                                }
                              } else if (!launched && mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Không thể chuyển đến trang thanh toán.'),
                                  ),
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
                                  vm.errorMessage ?? 'Không thể chuyển đến trang thanh toán.',
                                ),
                              ),
                            );
                          }
                        },
                  child: Text('Thanh toán — ${formatVND(vm.payableTotal)}'),
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
            'Tổng đơn hàng',
            style: AppTextStyles.bodySm.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          _PriceRow(label: 'Tạm tính', value: formatVND(total)),
          if (discount > 0)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: _PriceRow(
                label: 'Giảm giá dự kiến',
                value: '-${formatVND(discount)}',
                color: AppColors.success,
              ),
            ),
          const SizedBox(height: 8),
          const Divider(color: AppColors.divider),
          const SizedBox(height: 8),
          _PriceRow(
            label: 'Số tiền phải thanh toán',
            value: formatVND(payable),
            isBold: true,
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
            'Mã giảm giá',
            style: AppTextStyles.labelSm.copyWith(
              color: AppColors.textSecondary,
              letterSpacing: 0.6,
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
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: AppColors.primary,
                        width: 1.2,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                height: 44,
                child: ElevatedButton(
                  onPressed: isLoading ? null : onApply,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(100, 44),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Áp dụng'),
                ),
              ),
            ],
          ),
          if (errorText != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                errorText!,
                style: AppTextStyles.bodySm.copyWith(
                  color: AppColors.error,
                ),
              ),
            ),
          if (appliedCode != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Áp dụng: $appliedCode',
                        style: AppTextStyles.bodyMd.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      TextButton(
                        onPressed: isLoading ? null : onClear,
                        style: TextButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                        ),
                        child: const Text('Bỏ mã'),
                      ),
                    ],
                  ),
                  if (appliedPromotion?.description != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        appliedPromotion!.description,
                        style: AppTextStyles.bodySm.copyWith(
                          color: AppColors.textSecondary,
                          fontStyle: FontStyle.italic,
                        ),
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

class _PriceRow extends StatelessWidget {
  const _PriceRow({
    required this.label,
    required this.value,
    this.color,
    this.isBold = false,
  });

  final String label;
  final String value;
  final Color? color;
  final bool isBold;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: (isBold ? AppTextStyles.headingSm : AppTextStyles.bodyMd).copyWith(
            color: color ?? AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: (isBold ? AppTextStyles.priceLg : AppTextStyles.labelBold).copyWith(
            color: color,
          ),
        ),
      ],
    );
  }
}

