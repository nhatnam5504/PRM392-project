import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/format_price.dart';
import '../../../data/models/admin_order_model.dart';
import '../view_models/admin_order_view_model.dart';

class AdminOrderListScreen extends StatefulWidget {
  const AdminOrderListScreen({super.key});

  @override
  State<AdminOrderListScreen> createState() => _AdminOrderListScreenState();
}

class _AdminOrderListScreenState extends State<AdminOrderListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<AdminOrderViewModel>().loadOrders();
    });
  }

  static const _statuses = [
    ('ALL', 'Tất cả'),
    ('PENDING', 'Chờ xử lý'),
    ('PAID', 'Đã thanh toán'),
    ('CANCELED', 'Đã hủy'),
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminOrderViewModel>(
      builder: (context, vm, _) {
        return Column(
          children: [
            // ── Stats Row ──
            if (!vm.isLoading && vm.errorMessage == null)
              _buildStatsRow(vm),

            // ── Filter Chips ──
            if (!vm.isLoading && vm.errorMessage == null)
              Container(
                height: 48,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  border: Border(
                    bottom: BorderSide(color: AppColors.divider),
                  ),
                ),
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _statuses.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, i) {
                    final (val, label) = _statuses[i];
                    final isActive = vm.statusFilter == val;
                    final count = val == 'ALL'
                        ? vm.totalOrders
                        : vm.orders
                            .where((o) => o.status.toUpperCase() == val)
                            .length;
                    return GestureDetector(
                      onTap: () => vm.setStatusFilter(val),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 4),
                        decoration: BoxDecoration(
                          color: isActive
                              ? _statusColor(val)
                              : AppColors.surfaceDark,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              label,
                              style: AppTextStyles.labelMd.copyWith(
                                color:
                                    isActive ? Colors.white : AppColors.textSecondary,
                                fontWeight: isActive
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 5, vertical: 1),
                              decoration: BoxDecoration(
                                color: isActive
                                    ? Colors.white.withValues(alpha: 0.3)
                                    : AppColors.border,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '$count',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: isActive
                                      ? Colors.white
                                      : AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

            // ── List ──
            Expanded(
              child: vm.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : vm.errorMessage != null
                      ? _buildError(vm)
                      : vm.filteredOrders.isEmpty
                          ? _buildEmpty()
                          : RefreshIndicator(
                              onRefresh: vm.loadOrders,
                              child: ListView.builder(
                                padding: const EdgeInsets.all(12),
                                itemCount: vm.filteredOrders.length,
                                itemBuilder: (context, index) {
                                  return _AdminOrderCard(
                                    order: vm.filteredOrders[index],
                                  );
                                },
                              ),
                            ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatsRow(AdminOrderViewModel vm) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1A1F38), Color(0xFF2D3561)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          _StatCard(
            label: 'Tổng đơn',
            value: '${vm.totalOrders}',
            icon: Icons.receipt_long_rounded,
            color: Colors.white,
          ),
          _StatCard(
            label: 'Chờ xử lý',
            value: '${vm.pendingCount}',
            icon: Icons.pending_actions_rounded,
            color: const Color(0xFFFCD34D),
          ),
          _StatCard(
            label: 'Đã thanh toán',
            value: '${vm.paidCount}',
            icon: Icons.check_circle_rounded,
            color: const Color(0xFF34D399),
          ),
          _StatCard(
            label: 'Doanh thu',
            value: _shortMoney(vm.totalRevenue),
            icon: Icons.attach_money_rounded,
            color: const Color(0xFF60A5FA),
          ),
        ],
      ),
    );
  }

  Widget _buildError(AdminOrderViewModel vm) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 56, color: AppColors.error),
            const SizedBox(height: 12),
            Text(vm.errorMessage!,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMd
                    .copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: vm.loadOrders,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Thử lại'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inbox_rounded,
              size: 60, color: AppColors.textHint.withValues(alpha: 0.5)),
          const SizedBox(height: 12),
          Text('Không có đơn hàng nào',
              style:
                  AppTextStyles.bodyMd.copyWith(color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return const Color(0xFFF59E0B);
      case 'PAID':
        return AppColors.success;
      case 'CANCELED':
        return AppColors.error;
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

  String _shortMoney(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)}K';
    }
    return amount.toStringAsFixed(0);
  }
}

// ─────────────── Stat Card ───────────────
class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 3),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 9,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────── Order Card ───────────────
class _AdminOrderCard extends StatelessWidget {
  final AdminOrderModel order;

  const _AdminOrderCard({
    required this.order,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──
          Container(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _statusColor(order.status).withValues(alpha: 0.08),
                  Colors.transparent,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.shortCode,
                        style: AppTextStyles.labelBold.copyWith(
                          color: AppColors.textPrimary,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(Icons.person_outline,
                              size: 12, color: AppColors.textHint),
                          const SizedBox(width: 3),
                          Text(
                            order.userName,
                            style: AppTextStyles.bodySm.copyWith(
                                color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(Icons.schedule,
                              size: 12, color: AppColors.textHint),
                          const SizedBox(width: 3),
                          Text(
                            order.formattedDate,
                            style: const TextStyle(
                                fontSize: 10,
                                color: AppColors.textHint),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                _StatusBadge(status: order.status),
              ],
            ),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 14),
            child: Divider(height: 1),
          ),

          // ── Product list (max 2) ──
          if (order.orderDetails.isNotEmpty)
            ...order.orderDetails.take(2).map(
                  (item) => Padding(
                    padding: const EdgeInsets.fromLTRB(14, 8, 14, 0),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            width: 44,
                            height: 44,
                            color: AppColors.surfaceDark,
                            child: item.imgUrl != null &&
                                    item.imgUrl!.isNotEmpty
                                ? Image.network(
                                    item.imgUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) =>
                                        const Icon(Icons.image_outlined,
                                            size: 20,
                                            color: AppColors.border),
                                  )
                                : const Icon(Icons.image_outlined,
                                    size: 20, color: AppColors.border),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.productName,
                                style: AppTextStyles.bodySm.copyWith(
                                    fontWeight: FontWeight.w600),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Row(
                                children: [
                                  Text('x${item.quantity}',
                                      style: AppTextStyles.caption),
                                  if (item.isGift) ...[
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 5, vertical: 1),
                                      decoration: BoxDecoration(
                                        color: AppColors.success,
                                        borderRadius:
                                            BorderRadius.circular(4),
                                      ),
                                      child: const Text('Quà',
                                          style: TextStyle(
                                              fontSize: 9,
                                              color: Colors.white,
                                              fontWeight:
                                                  FontWeight.w700)),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                        if (!item.isGift)
                          Text(
                            formatVND(item.subtotal),
                            style: AppTextStyles.priceSm,
                          ),
                      ],
                    ),
                  ),
                ),

          if (order.orderDetails.length > 2)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 4, 14, 0),
              child: Text(
                'và ${order.orderDetails.length - 2} sản phẩm khác...',
                style: AppTextStyles.caption
                    .copyWith(color: AppColors.textHint),
              ),
            ),

          // ── Recipient Info ──
          if (order.orderInfo.isNotEmpty &&
              !order.orderInfo.first.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 0),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.surfaceDark,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.location_on_outlined,
                        size: 13, color: AppColors.textHint),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '${order.orderInfo.first.recipientName}'
                        '${order.orderInfo.first.phoneNumber.isNotEmpty ? ' · ${order.orderInfo.first.phoneNumber}' : ''}'
                        '${order.orderInfo.first.address.isNotEmpty ? '\n${order.orderInfo.first.address}' : ''}',
                        style: AppTextStyles.caption
                            .copyWith(color: AppColors.textSecondary),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          if (order.note != null && order.note!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 6, 14, 0),
              child: Row(
                children: [
                  const Icon(Icons.note_outlined,
                      size: 12, color: AppColors.textHint),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      order.note!,
                      style: AppTextStyles.caption
                          .copyWith(color: AppColors.textHint),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

          // ── Footer ──
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Tổng thanh toán',
                        style: AppTextStyles.caption
                            .copyWith(color: AppColors.textHint)),
                    Text(
                      formatVND(order.totalPrice),
                      style: AppTextStyles.priceMd,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return const Color(0xFFF59E0B);
      case 'PAID':
        return AppColors.success;
      case 'CANCELED':
        return AppColors.error;
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

// ─────────────── Status Badge ───────────────
class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _color.withValues(alpha: 0.4)),
      ),
      child: Text(
        _label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: _color,
        ),
      ),
    );
  }

  String get _label {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return '⏳ Chờ xử lý';
      case 'PAID':
        return '✅ Đã thanh toán';
      case 'CANCELED':
        return '❌ Đã hủy';
      case 'CONFIRMED':
        return '☑️ Đã xác nhận';
      case 'SHIPPING':
        return '🚚 Đang giao';
      case 'DELIVERED':
        return '📦 Đã giao';
      default:
        return status;
    }
  }

  Color get _color {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return const Color(0xFFF59E0B);
      case 'PAID':
        return AppColors.success;
      case 'CANCELED':
        return AppColors.error;
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

