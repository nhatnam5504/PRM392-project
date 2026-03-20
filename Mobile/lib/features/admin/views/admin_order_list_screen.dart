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

  Widget _buildStatsRow(AdminOrderViewModel vm) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          _StatCard(
            label: 'Tổng đơn',
            value: '${vm.totalOrders}',
            icon: Icons.receipt_long_rounded,
            color: AppColors.primary,
          ),
          _StatCard(
            label: 'Chờ xử lý',
            value: '${vm.pendingCount}',
            icon: Icons.pending_actions_rounded,
            color: const Color(0xFFF59E0B),
          ),
          _StatCard(
            label: 'Đã thanh toán',
            value: '${vm.paidCount}',
            icon: Icons.check_circle_rounded,
            color: AppColors.success,
          ),
          _StatCard(
            label: 'Đã hủy',
            value: '${vm.canceledCount}',
            icon: Icons.cancel_rounded,
            color: AppColors.error,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminOrderViewModel>(
      builder: (context, vm, _) {
        return Column(
          children: [
            if (!vm.isLoading && vm.errorMessage == null) _buildStatsRow(vm),
            
            // Filter Chips
            if (!vm.isLoading && vm.errorMessage == null)
              Container(
                height: 56,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.background,
                ),
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: _statuses.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (context, i) {
                    final (val, label) = _statuses[i];
                    final isActive = vm.statusFilter == val;
                    return GestureDetector(
                      onTap: () => vm.setStatusFilter(val),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        decoration: BoxDecoration(
                          color: isActive ? AppColors.primary.withValues(alpha: 0.15) : AppColors.surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isActive ? AppColors.primary.withValues(alpha: 0.3) : AppColors.border.withValues(alpha: 0.5),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          label,
                          style: AppTextStyles.labelMd.copyWith(
                            color: isActive ? AppColors.primary : AppColors.textSecondary,
                            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                          ),
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
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.15), width: 1),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: AppTextStyles.labelBold.copyWith(
                color: AppColors.textHeading,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
                fontSize: 10,
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
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            order.shortCode,
                            style: AppTextStyles.labelBold.copyWith(
                              color: AppColors.textHeading,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(width: 8),
                          _StatusBadge(status: order.status),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.person_outline_rounded, size: 14, color: AppColors.textSecondary),
                          const SizedBox(width: 6),
                          Text(
                            order.userName,
                            style: AppTextStyles.bodySm.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.access_time_rounded, size: 14, color: AppColors.textHint),
                          const SizedBox(width: 6),
                          Text(
                            order.formattedDate,
                            style: AppTextStyles.caption.copyWith(color: AppColors.textHint),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Tổng thanh toán', style: AppTextStyles.caption),
                    Text(
                      formatVND(order.totalPrice),
                      style: AppTextStyles.priceMd.copyWith(fontSize: 18),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const Divider(height: 1, indent: 16, endIndent: 16, color: AppColors.divider),
          
          // Products
          if (order.orderDetails.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                children: order.orderDetails.take(2).map(
                  (item) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            width: 48,
                            height: 48,
                            color: AppColors.surfaceDark,
                            child: item.imgUrl != null && item.imgUrl!.isNotEmpty
                                ? Image.network(
                                    item.imgUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const Icon(Icons.image_outlined, color: AppColors.textHint),
                                  )
                                : const Icon(Icons.image_outlined, color: AppColors.textHint),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.productName,
                                style: AppTextStyles.bodySm.copyWith(fontWeight: FontWeight.w600),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Text('x${item.quantity}', style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.bold)),
                                  if (item.isGift) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                      decoration: BoxDecoration(
                                        color: AppColors.success.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
                                      ),
                                      child: Text(
                                        'QUÀ TẶNG',
                                        style: AppTextStyles.labelSm.copyWith(color: AppColors.success, fontSize: 8),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                        if (!item.isGift)
                          Text(formatVND(item.subtotal), style: AppTextStyles.labelBold),
                      ],
                    ),
                  ),
                ).toList(),
              ),
            ),

          if (order.orderDetails.length > 2)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Text(
                'và ${order.orderDetails.length - 2} sản phẩm khác...',
                style: AppTextStyles.caption.copyWith(fontStyle: FontStyle.italic),
              ),
            ),

          // Customer Info (Address)
          if (order.orderInfo.isNotEmpty && !order.orderInfo.first.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceDark.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.local_shipping_outlined, size: 16, color: AppColors.primary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '${order.orderInfo.first.recipientName} • ${order.orderInfo.first.phoneNumber}\n${order.orderInfo.first.address}',
                        style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary, height: 1.4),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
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

