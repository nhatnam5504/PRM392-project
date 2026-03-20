import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/format_price.dart';
import '../../../data/models/user_order_model.dart';
import '../view_models/order_feedback_view_model.dart';
import '../view_models/order_view_model.dart';

class OrderDetailScreen extends StatelessWidget {
  final int orderId;
  const OrderDetailScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<OrderViewModel>();
    final order = vm.getOrderById(orderId);

    if (order == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20),
            onPressed: () => context.pop(),
          ),
          title: Text('Chi tiết đơn hàng', style: AppTextStyles.headingMd),
          centerTitle: true,
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.search_off_rounded, size: 64, color: AppColors.textHint.withValues(alpha: 0.5)),
              const SizedBox(height: 16),
              Text('Không tìm thấy đơn hàng.', style: AppTextStyles.bodyMd.copyWith(color: AppColors.textSecondary)),
            ],
          ),
        ),
      );
    }

    return ChangeNotifierProvider(
      create: (_) => OrderFeedbackViewModel()..initialize(order),
      child: Consumer<OrderFeedbackViewModel>(
        builder: (context, feedbackVm, _) {
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20),
                onPressed: () => context.pop(),
              ),
              title: Text('#${_shortCode(order.orderCode)}', style: AppTextStyles.headingMd),
              centerTitle: true,
            ),
            body: feedbackVm.isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : ListView(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
                    children: [
                      // Status Section
                      _SectionCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Trạng thái đơn hàng', style: AppTextStyles.labelBold.copyWith(color: AppColors.textSecondary, fontSize: 11, letterSpacing: 0.5)),
                                _StatusChip(status: order.status),
                              ],
                            ),
                            const SizedBox(height: 16),
                            _InfoRow(icon: Icons.calendar_today_rounded, label: 'Ngày đặt', value: order.formattedDate),
                            const SizedBox(height: 12),
                            _InfoRow(icon: Icons.receipt_long_rounded, label: 'Mã vận đơn', value: order.orderCode),
                            const SizedBox(height: 12),
                            _InfoRow(icon: Icons.person_rounded, label: 'Người nhận', value: order.userName),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Products Section
                      _SectionCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('SẢN PHẨM (${order.orderDetails.length})', style: AppTextStyles.labelBold.copyWith(color: AppColors.textSecondary, fontSize: 11, letterSpacing: 0.8)),
                            const SizedBox(height: 16),
                            ...order.orderDetails.map((item) => _DetailItemRow(item: item, order: order)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Payment Summary Section
                      _SectionCard(
                        child: Column(
                          children: [
                            _SummaryRow('Tạm tính', formatVND(order.basePrice)),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Divider(height: 1, color: AppColors.surfaceDark),
                            ),
                            _SummaryRow('Tổng cộng', formatVND(order.totalPrice), isBold: true),
                          ],
                        ),
                      ),
                    ],
                  ),
          );
        },
      ),
    );
  }

  String _shortCode(String code) {
    if (code.length > 8) return code.substring(0, 8).toUpperCase();
    return code.toUpperCase();
  }
}

// ────────────────────────────────────────────────
// Redesigned Components
// ────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final Widget child;
  const _SectionCard({required this.child});

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
      child: child,
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 12),
        Text('$label: ', style: AppTextStyles.bodyMd.copyWith(color: AppColors.textSecondary)),
        Expanded(child: Text(value, style: AppTextStyles.labelBold, maxLines: 1, overflow: TextOverflow.ellipsis)),
      ],
    );
  }
}

class _DetailItemRow extends StatelessWidget {
  final UserOrderDetailModel item;
  final UserOrderModel order;

  const _DetailItemRow({required this.item, required this.order});

  @override
  Widget build(BuildContext context) {
    final feedbackVm = context.watch<OrderFeedbackViewModel>();
    final canReview = feedbackVm.canReviewItem(order, item);
    final isSubmitted = feedbackVm.hasSubmitted(item.orderDetailId);
    final feedback = feedbackVm.getFeedback(item.orderDetailId);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 20),
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
                  child: Container(
                    width: 72, height: 72,
                    color: AppColors.surfaceDark,
                    child: item.imgUrl.isNotEmpty
                        ? Image.network(item.imgUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.image_outlined, color: AppColors.textHint, size: 24))
                        : const Icon(Icons.image_outlined, color: AppColors.textHint, size: 24),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.productName, maxLines: 2, overflow: TextOverflow.ellipsis, style: AppTextStyles.labelBold.copyWith(height: 1.2)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text('SL: ${item.quantity}', style: AppTextStyles.bodySm.copyWith(color: AppColors.textSecondary)),
                        if (item.isGift)
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                            child: Text('Quà tặng', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.success)),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(item.isGift ? 'Miễn phí' : formatVND(item.subtotal), style: AppTextStyles.labelBold.copyWith(color: item.isGift ? AppColors.success : AppColors.primary)),
                  ],
                ),
              ),
              if (canReview && !isSubmitted)
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: TextButton(
                    onPressed: () => _showRatingDialog(context, feedbackVm),
                    style: TextButton.styleFrom(
                      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text('Đánh giá', style: AppTextStyles.labelBold.copyWith(color: AppColors.primary, fontSize: 11)),
                  ),
                ),
            ],
          ),
        ),
        if (isSubmitted && feedback != null)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 24),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceDark.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildRatingStars(feedback.rating),
                    Text(DateFormat('dd/MM/yyyy').format(feedback.date), style: AppTextStyles.caption.copyWith(fontSize: 10)),
                  ],
                ),
                if (feedback.comment.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(feedback.comment, style: AppTextStyles.bodySm.copyWith(fontStyle: FontStyle.italic, color: AppColors.textPrimary)),
                ],
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildRatingStars(int rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        5,
        (index) => Icon(
          index < rating ? Icons.star_rounded : Icons.star_outline_rounded,
          size: 16,
          color: index < rating ? Colors.amber : AppColors.textHint,
        ),
      ),
    );
  }

  void _showRatingDialog(BuildContext context, OrderFeedbackViewModel vm) {
    showDialog(
      context: context,
      builder: (ctx) => _RatingDialog(
        item: item,
        onSubmitted: (rating, comment) async {
          final success = await vm.submitFeedback(item: item, rating: rating, comment: comment);
          if (success && context.mounted) {
            Navigator.pop(ctx);
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cảm ơn bạn đã đánh giá!')));
          } else if (context.mounted && vm.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(vm.errorMessage!)));
          }
        },
      ),
    );
  }
}

class _RatingDialog extends StatefulWidget {
  final UserOrderDetailModel item;
  final Function(int rating, String comment) onSubmitted;
  const _RatingDialog({required this.item, required this.onSubmitted});

  @override
  State<_RatingDialog> createState() => _RatingDialogState();
}

class _RatingDialogState extends State<_RatingDialog> {
  int _rating = 5;
  final TextEditingController _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('Đánh giá sản phẩm', style: AppTextStyles.headingSm),
            const SizedBox(height: 12),
            Text(widget.item.productName, textAlign: TextAlign.center, style: AppTextStyles.bodyMd.copyWith(color: AppColors.textSecondary), maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) => IconButton(
                onPressed: () => setState(() => _rating = index + 1),
                icon: Icon(index < _rating ? Icons.star_rounded : Icons.star_outline_rounded, size: 40, color: index < _rating ? Colors.amber : Colors.grey[300]),
              )),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _commentController,
              maxLines: 3,
              style: AppTextStyles.bodyMd,
              decoration: InputDecoration(
                hintText: 'Nhận xét của bạn về sản phẩm...',
                hintStyle: AppTextStyles.bodyMd.copyWith(color: AppColors.textHint),
                filled: true,
                fillColor: AppColors.surfaceDark,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextButton(onPressed: () => Navigator.pop(context), child: Text('Hủy', style: AppTextStyles.labelBold.copyWith(color: AppColors.textHint))),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => widget.onSubmitted(_rating, _commentController.text),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    child: const Text('GỬI ĐÁNH GIÁ'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: _color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
      child: Text(_label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: _color)),
    );
  }

  String get _label {
    switch (status.toUpperCase()) {
      case 'PENDING': return 'Chờ xử lý';
      case 'PAID': return 'Đã thanh toán';
      case 'CANCELED': return 'Đã hủy';
      case 'CONFIRMED': return 'Đã xác nhận';
      case 'SHIPPING': return 'Đang giao';
      case 'DELIVERED': return 'Đã giao';
      default: return status;
    }
  }

  Color get _color {
    switch (status.toUpperCase()) {
      case 'PENDING': return AppColors.accent;
      case 'PAID': return AppColors.success;
      case 'CANCELED': return AppColors.error;
      case 'CONFIRMED': return const Color(0xFF3B82F6);
      case 'SHIPPING': return AppColors.primary;
      case 'DELIVERED': return AppColors.success;
      default: return AppColors.textSecondary;
    }
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;

  const _SummaryRow(this.label, this.value, {this.isBold = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: isBold ? AppTextStyles.labelBold : AppTextStyles.bodyMd.copyWith(color: AppColors.textSecondary)),
        Text(value, style: isBold ? AppTextStyles.priceMd.copyWith(color: AppColors.primary, fontSize: 18) : AppTextStyles.labelBold),
      ],
    );
  }
}
