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
    ('SHIPPING', 'Đang giao'),
    ('DELIVERED', 'Đã giao'),
  ];

  Widget _buildStatsRow(AdminOrderViewModel vm) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      decoration: const BoxDecoration(
        color: Colors.white,
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
            icon: Icons.timer_rounded,
            color: const Color(0xFFF59E0B),
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
                height: 50,
                padding: const EdgeInsets.only(bottom: 12),
                decoration: const BoxDecoration(color: Colors.white),
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
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isActive ? AppColors.primary : AppColors.surfaceDark,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: isActive ? [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.25),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ] : [],
                        ),
                        child: Text(
                          label,
                          style: AppTextStyles.labelBold.copyWith(
                            color: isActive ? Colors.white : AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

            // Line
            Container(height: 1, color: AppColors.surfaceDark),

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
                                padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
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
            const Icon(Icons.cloud_off_rounded, size: 64, color: AppColors.error),
            const SizedBox(height: 16),
            Text('Không thể tải đơn hàng', style: AppTextStyles.headingSm),
            const SizedBox(height: 8),
            Text(vm.errorMessage!,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMd.copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: vm.loadOrders,
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

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.receipt_long_rounded,
              size: 64, color: AppColors.textHint.withValues(alpha: 0.2)),
          const SizedBox(height: 16),
          Text('Chưa có đơn hàng nào',
              style: AppTextStyles.headingSm.copyWith(color: AppColors.textHint)),
          const SizedBox(height: 8),
          Text('Danh sách này hiện đang trống',
              style: AppTextStyles.bodyMd.copyWith(color: AppColors.textHint.withValues(alpha: 0.6))),
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
        margin: const EdgeInsets.symmetric(horizontal: 6),
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: color.withValues(alpha: 0.1), width: 1.5),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 14),
            Text(
              value,
              style: AppTextStyles.displaySmall.copyWith(
                color: AppColors.textHeading,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label.toUpperCase(),
              style: AppTextStyles.labelBold.copyWith(
                color: AppColors.textSecondary,
                fontSize: 9,
                letterSpacing: 0.5,
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
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(20),
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
                              fontSize: 16,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(width: 12),
                          _StatusBadge(status: order.status),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceDark,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.person_rounded, size: 12, color: AppColors.textSecondary),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            order.userName,
                            style: AppTextStyles.bodyMd.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const SizedBox(width: 24),
                          Text(
                            order.formattedDate,
                            style: AppTextStyles.caption.copyWith(color: AppColors.textHint, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('TỔNG CỘNG', style: AppTextStyles.labelBold.copyWith(color: AppColors.textHint, fontSize: 10, letterSpacing: 1)),
                    const SizedBox(height: 4),
                    Text(
                      formatVND(order.totalPrice),
                      style: AppTextStyles.priceMd.copyWith(fontSize: 20, color: AppColors.primary, fontWeight: FontWeight.w900),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          Container(height: 1, color: AppColors.surfaceDark, margin: const EdgeInsets.symmetric(horizontal: 20)),
          
          // Products
          if (order.orderDetails.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(
                children: order.orderDetails.take(2).map(
                  (item) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            width: 56,
                            height: 56,
                            color: AppColors.surfaceDark,
                            child: item.imgUrl != null && item.imgUrl!.isNotEmpty
                                ? Image.network(
                                    item.imgUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const Icon(Icons.broken_image_outlined, color: AppColors.textHint, size: 20),
                                  )
                                : const Icon(Icons.inventory_2_outlined, color: AppColors.textHint, size: 20),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.productName,
                                style: AppTextStyles.bodyMd.copyWith(fontWeight: FontWeight.bold, fontSize: 13),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.surfaceDark,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text('x${item.quantity}', style: AppTextStyles.labelBold.copyWith(fontSize: 10, color: AppColors.textPrimary)),
                                  ),
                                  if (item.isGift) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppColors.success.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        'QUÀ TẶNG',
                                        style: AppTextStyles.labelBold.copyWith(color: AppColors.success, fontSize: 9),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                        if (!item.isGift)
                          Text(formatVND(item.subtotal), style: AppTextStyles.labelBold.copyWith(fontSize: 14)),
                      ],
                    ),
                  ),
                ).toList(),
              ),
            ),

          if (order.orderDetails.length > 2)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.surfaceDark.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '+ ${order.orderDetails.length - 2} sản phẩm khác',
                  style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.bold, color: AppColors.textSecondary, fontSize: 11),
                ),
              ),
            ),

          // Customer Info (Address)
          if (order.orderInfo.isNotEmpty && !order.orderInfo.first.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceDark.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.surfaceDark),
                ),
                child: IntrinsicHeight(
                  child: Row(
                    children: [
                      Container(
                        width: 4,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.local_shipping_rounded, size: 14, color: AppColors.primary),
                                const SizedBox(width: 6),
                                Text(
                                  '${order.orderInfo.first.recipientName} • ${order.orderInfo.first.phoneNumber}',
                                  style: AppTextStyles.labelBold.copyWith(fontSize: 12),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              order.orderInfo.first.address,
                              style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary, height: 1.4),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────── Status Badge ───────────────
class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: _color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: _color.withValues(alpha: 0.4),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            _label,
            style: AppTextStyles.labelBold.copyWith(
              fontSize: 10,
              color: _color,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  String get _label {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return 'CHỜ XỬ LÝ';
      case 'PAID':
        return 'ĐÃ THANH TOÁN';
      case 'CANCELED':
        return 'ĐÃ HỦY';
      case 'CONFIRMED':
        return 'XÁC NHẬN';
      case 'SHIPPING':
        return 'ĐANG GIAO';
      case 'DELIVERED':
        return 'ĐÃ GIAO';
      default:
        return status.toUpperCase();
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

