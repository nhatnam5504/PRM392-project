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
import '../../profile/view_models/profile_view_model.dart';
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
  final TextEditingController _promoController = TextEditingController();

  @override
  void dispose() {
    _promoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final checkoutVm = context.watch<CheckoutViewModel>();
    final cartVm = context.watch<CartViewModel>();
    final hasItems = cartVm.items.isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text('Xác nhận đặt hàng', style: AppTextStyles.headingMd),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: cartVm.isLoading
            ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
            : SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!hasItems)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: AppColors.error.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                        child: Text('Giỏ hàng trống, vui lòng quay lại thêm sản phẩm.', style: AppTextStyles.bodyMd.copyWith(color: AppColors.error)),
                      ),
                    if (hasItems) ...[
                      _SectionCard(
                        title: 'SẢN PHẨM ĐÃ CHỌN',
                        child: Column(
                          children: cartVm.items.map((item) => _buildOrderItem(item)).toList(),
                        ),
                      ),
                      const SizedBox(height: 20),
                      _SectionCard(
                        title: 'ĐỊA CHỈ GIAO HÀNG',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _InfoRow(icon: Icons.person_rounded, text: checkoutVm.recipientName, isBold: true),
                            const SizedBox(height: 12),
                            _InfoRow(icon: Icons.phone_android_rounded, text: checkoutVm.phoneNumber),
                            const SizedBox(height: 12),
                            _InfoRow(icon: Icons.location_on_rounded, text: checkoutVm.address),
                            if (checkoutVm.note.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              _InfoRow(icon: Icons.edit_note_rounded, text: 'Ghi chú: ${checkoutVm.note}', isItalic: true),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      _PromoSection(
                        controller: _promoController,
                        isLoading: checkoutVm.isLoading,
                        appliedPromotion: checkoutVm.appliedPromotion,
                        onApply: () async {
                          await checkoutVm.applyPromotion(_promoController.text);
                        },
                        onClear: checkoutVm.clearPromotion,
                      ),
                      const SizedBox(height: 20),
                      _SectionCard(
                        title: 'CHI TIẾT THANH TOÁN',
                        child: Column(
                          children: [
                            _PriceRow('Tạm tính', formatVND(checkoutVm.checkResult?.basePrice ?? checkoutVm.checkResult?.totalPrice ?? 0)),
                            if (checkoutVm.discountPreview > 0)
                              Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child: _PriceRow('Giảm giá', '-${formatVND(checkoutVm.discountPreview)}', color: AppColors.success),
                              ),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Divider(height: 1, color: AppColors.surfaceDark),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Tổng cộng', style: AppTextStyles.headingSm),
                                Text(formatVND(checkoutVm.payableTotal), style: AppTextStyles.priceLg.copyWith(color: AppColors.primary, fontSize: 22)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                    if (checkoutVm.errorMessage != null && checkoutVm.checkResult == null)
                      Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: Text(checkoutVm.errorMessage!, style: AppTextStyles.bodySm.copyWith(color: AppColors.error)),
                      ),
                  ],
                ),
              ),
      ),
      bottomNavigationBar: _buildBottomBar(checkoutVm, cartVm),
    );
  }

  Widget _buildOrderItem(dynamic item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.surfaceDark),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                item.imageUrl,
                width: 64,
                height: 64,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(Icons.image_outlined, size: 32, color: AppColors.textHint),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.productName, style: AppTextStyles.labelBold.copyWith(height: 1.2), maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text('Số lượng: ${item.quantity}', style: AppTextStyles.bodySm.copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(formatVND(item.subtotal), style: AppTextStyles.labelBold),
        ],
      ),
    );
  }

  Widget _buildBottomBar(CheckoutViewModel checkoutVm, CartViewModel cartVm) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: checkoutVm.isLoading
                  ? null
                  : () async {
                      final url = await checkoutVm.makePayment();
                      if (!mounted) return;
                      if (url != null) {
                        final uri = Uri.parse(url);
                        try {
                          final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
                          if (launched && mounted) {
                            await cartVm.clearCart();
                            if (mounted) context.go('/');
                          } else if (!launched && mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Không thể mở trang thanh toán.')));
                          }
                        } catch (e) {
                          if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: ${e.toString()}')));
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(checkoutVm.errorMessage ?? 'Không thể tạo liên kết thanh toán.')));
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: checkoutVm.isLoading
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Text('THÀNH TOÁN — ${formatVND(checkoutVm.payableTotal)}', style: AppTextStyles.labelBold.copyWith(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.surfaceDark, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.labelBold.copyWith(color: AppColors.textSecondary, fontSize: 11, letterSpacing: 0.8)),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool isBold;
  final bool isItalic;

  const _InfoRow({required this.icon, required this.text, this.isBold = false, this.isItalic = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.bodyMd.copyWith(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;

  const _PriceRow(this.label, this.value, {this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.bodyMd.copyWith(color: AppColors.textSecondary)),
        Text(value, style: AppTextStyles.labelBold.copyWith(color: color ?? AppColors.textPrimary)),
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('MÃ GIẢM GIÁ', style: AppTextStyles.labelBold.copyWith(color: AppColors.primary, fontSize: 11, letterSpacing: 0.8)),
          const SizedBox(height: 16),
          if (appliedPromotion == null)
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    style: AppTextStyles.bodyMd,
                    decoration: InputDecoration(
                      hintText: 'Nhập mã của bạn',
                      hintStyle: AppTextStyles.bodyMd.copyWith(color: AppColors.textHint, fontSize: 13),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : onApply,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
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
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.success.withValues(alpha: 0.3))),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Mã: ${appliedPromotion!.code}', style: AppTextStyles.labelBold.copyWith(color: AppColors.success)),
                        if (appliedPromotion!.description.isNotEmpty)
                          Text(appliedPromotion!.description, style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                  TextButton(onPressed: isLoading ? null : onClear, child: const Text('BỎ MÃ', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold))),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

