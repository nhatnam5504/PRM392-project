import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/format_price.dart';
import '../../../data/models/user_order_model.dart';
import '../view_models/order_view_model.dart';

class OrderDetailScreen extends StatelessWidget {
  final int orderId;

  const OrderDetailScreen({
    super.key,
    required this.orderId,
  });

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<OrderViewModel>();
    final order = vm.getOrderById(orderId);

    if (order == null) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
          title: const Text('Chi tiết đơn hàng'),
        ),
        body: const Center(
          child: Text(
            'Không tìm thấy đơn hàng.',
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text(
          '#${_shortCode(order.orderCode)}',
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Status + date card
          _SectionCard(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment
                          .spaceBetween,
                  children: [
                    const Text(
                      'Trạng thái',
                      style:
                          AppTextStyles.labelBold,
                    ),
                    _StatusChip(
                      status: order.status,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _InfoRow(
                  icon: Icons.calendar_today,
                  label: 'Ngày đặt',
                  value: order.formattedDate,
                ),
                const SizedBox(height: 8),
                _InfoRow(
                  icon: Icons.receipt_long,
                  label: 'Mã đơn hàng',
                  value: order.orderCode,
                ),
                const SizedBox(height: 8),
                _InfoRow(
                  icon: Icons.person_outline,
                  label: 'Người đặt',
                  value: order.userName,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Products card
          _SectionCard(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Sản phẩm'
                  ' (${order.orderDetails.length})',
                  style: AppTextStyles.labelBold,
                ),
                const SizedBox(height: 12),
                ...order.orderDetails.map(
                  (item) =>
                      _DetailItemRow(item: item),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Payment summary card
          _SectionCard(
            child: Column(
              children: [
                _SummaryRow(
                  'Tạm tính',
                  formatVND(order.basePrice),
                ),
                const SizedBox(height: 8),
                const Divider(),
                const SizedBox(height: 8),
                _SummaryRow(
                  'Tổng cộng',
                  formatVND(order.totalPrice),
                  isBold: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _shortCode(String code) {
    if (code.length > 8) {
      return code.substring(0, 8).toUpperCase();
    }
    return code.toUpperCase();
  }
}

// ─── Reusable widgets ───────────────────────────

class _SectionCard extends StatelessWidget {
  final Widget child;

  const _SectionCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius:
            BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black
                .withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
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

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: AppColors.textHint,
        ),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: AppTextStyles.bodySm.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.labelMd,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _DetailItemRow extends StatelessWidget {
  final UserOrderDetailModel item;

  const _DetailItemRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          ClipRRect(
            borderRadius:
                BorderRadius.circular(10),
            child: Container(
              width: 64,
              height: 64,
              color: AppColors.surfaceDark,
              child: item.imgUrl.isNotEmpty
                  ? Image.network(
                      item.imgUrl,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (_, __, ___) =>
                              const Icon(
                        Icons.image_outlined,
                        color: AppColors.border,
                      ),
                    )
                  : const Icon(
                      Icons.image_outlined,
                      color: AppColors.border,
                    ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  maxLines: 2,
                  overflow:
                      TextOverflow.ellipsis,
                  style:
                      AppTextStyles.labelBold,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      'SL: ${item.quantity}',
                      style:
                          AppTextStyles.bodySm,
                    ),
                    if (item.isGift) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding:
                            const EdgeInsets
                                .symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color:
                              AppColors.success,
                          borderRadius:
                              BorderRadius
                                  .circular(4),
                        ),
                        child: const Text(
                          'Quà tặng',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight:
                                FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            item.isGift
                ? 'Miễn phí'
                : formatVND(item.subtotal),
            style: item.isGift
                ? AppTextStyles.bodySm.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.w600,
                  )
                : AppTextStyles.priceSm,
          ),
        ],
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
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: _color,
        borderRadius:
            BorderRadius.circular(8),
      ),
      child: Text(
        _label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }

  String get _label {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return 'Chờ xử lý';
      case 'PAID':
        return 'Đã thanh toán';
      case 'CANCELED':
        return 'Đã hủy';
      case 'CONFIRMED':
        return 'Đã xác nhận';
      case 'SHIPPING':
        return 'Đang giao';
      case 'DELIVERED':
        return 'Đã giao';
      default:
        return status;
    }
  }

  Color get _color {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return AppColors.accent;
      case 'PAID':
        return AppColors.success;
      case 'CANCELED':
        return AppColors.outOfStock;
      case 'CONFIRMED':
        return const Color(0xFF3B82F6);
      case 'SHIPPING':
        return AppColors.primary;
      case 'DELIVERED':
        return AppColors.success;
      default:
        return AppColors.textSecondary;
    }
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;

  const _SummaryRow(
    this.label,
    this.value, {
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment:
          MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: isBold
              ? AppTextStyles.labelBold
              : AppTextStyles.bodyMd.copyWith(
                  color: AppColors.textSecondary,
                ),
        ),
        Text(
          value,
          style: isBold
              ? AppTextStyles.priceMd
              : AppTextStyles.labelBold,
        ),
      ],
    );
  }
}
