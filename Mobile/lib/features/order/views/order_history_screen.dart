import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/format_price.dart';
import '../../../data/models/user_order_model.dart';
import '../view_models/order_view_model.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() =>
      _OrderHistoryScreenState();
}

class _OrderHistoryScreenState
    extends State<OrderHistoryScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  static const _tabs = [
    _TabDef('Tất cả', 'ALL'),
    _TabDef('Chờ xử lý', 'PENDING'),
    _TabDef('Đã thanh toán', 'PAID'),
    _TabDef('Đã hủy', 'CANCELED'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: _tabs.length,
      vsync: this,
    );
    WidgetsBinding.instance
        .addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<OrderViewModel>().loadOrders();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Đơn hàng của tôi'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: AppColors.primary,
          unselectedLabelColor:
              AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          labelStyle: AppTextStyles.labelBold,
          unselectedLabelStyle:
              AppTextStyles.bodyMd,
          tabAlignment: TabAlignment.start,
          tabs: _tabs
              .map((t) => Tab(text: t.label))
              .toList(),
        ),
      ),
      body: Consumer<OrderViewModel>(
        builder: (context, vm, _) {
          if (vm.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (vm.errorMessage != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: AppColors.textHint,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      vm.errorMessage!,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyMd
                          .copyWith(
                        color:
                            AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: vm.loadOrders,
                      icon: const Icon(
                        Icons.refresh,
                        size: 18,
                      ),
                      label:
                          const Text('Thử lại'),
                      style:
                          ElevatedButton.styleFrom(
                        backgroundColor:
                            AppColors.primary,
                        foregroundColor:
                            Colors.white,
                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(
                            12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return TabBarView(
            controller: _tabController,
            children: _tabs.map((tab) {
              final filtered =
                  vm.filteredOrders(tab.value);
              if (filtered.isEmpty) {
                return _buildEmptyState();
              }
              return RefreshIndicator(
                onRefresh: vm.loadOrders,
                child: ListView.builder(
                  padding:
                      const EdgeInsets.all(16),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    return _OrderCard(
                      order: filtered[index],
                    );
                  },
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 64,
            color: AppColors.textHint
                .withValues(alpha: 0.5),
          ),
          const SizedBox(height: 12),
          Text(
            'Không có đơn hàng nào',
            style: AppTextStyles.bodyMd.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _TabDef {
  final String label;
  final String value;

  const _TabDef(this.label, this.value);
}

// ────────────────────────────────────────────────
// Order Card
// ────────────────────────────────────────────────
class _OrderCard extends StatelessWidget {
  final UserOrderModel order;

  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () =>
          context.push('/orders/${order.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
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
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            // Header: order code + status
            Padding(
              padding:
                  const EdgeInsets.fromLTRB(
                16, 14, 16, 0,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,
                      children: [
                        Text(
                          '#${_shortCode(order.orderCode)}',
                          style: AppTextStyles
                              .labelBold,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          order.formattedDate,
                          style: AppTextStyles
                              .caption,
                        ),
                      ],
                    ),
                  ),
                  _StatusBadge(
                    status: order.status,
                  ),
                ],
              ),
            ),

            const Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 16,
              ),
              child: Divider(height: 20),
            ),

            // Product list preview
            ...order.orderDetails
                .take(3)
                .map(
                  (item) => _OrderItemRow(
                    item: item,
                  ),
                ),

            if (order.orderDetails.length > 3)
              Padding(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 16,
                ),
                child: Text(
                  'và ${order.orderDetails.length - 3}'
                  ' sản phẩm khác',
                  style:
                      AppTextStyles.bodySm.copyWith(
                    color: AppColors.textHint,
                  ),
                ),
              ),

            // Footer: total + detail link
            Padding(
              padding:
                  const EdgeInsets.fromLTRB(
                16, 8, 16, 14,
              ),
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment
                        .spaceBetween,
                children: [
                  Text(
                    'Tổng: '
                    '${formatVND(order.totalPrice)}',
                    style: AppTextStyles.priceSm,
                  ),
                  Row(
                    mainAxisSize:
                        MainAxisSize.min,
                    children: [
                      Text(
                        'Xem chi tiết',
                        style: AppTextStyles
                            .labelMd
                            .copyWith(
                          color:
                              AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons
                            .arrow_forward_ios_rounded,
                        size: 12,
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
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

// ────────────────────────────────────────────────
// Order Item Row (with product image)
// ────────────────────────────────────────────────
class _OrderItemRow extends StatelessWidget {
  final UserOrderDetailModel item;

  const _OrderItemRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 6,
      ),
      child: Row(
        children: [
          // Product image
          ClipRRect(
            borderRadius:
                BorderRadius.circular(10),
            child: Container(
              width: 56,
              height: 56,
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

          // Product info
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                  style: AppTextStyles.labelBold,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      'x${item.quantity}',
                      style: AppTextStyles.bodySm,
                    ),
                    if (item.isGift) ...[
                      const SizedBox(width: 6),
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

          // Subtotal
          Text(
            item.isGift
                ? 'Miễn phí'
                : formatVND(item.subtotal),
            style: item.isGift
                ? AppTextStyles.bodySm.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.w600,
                  )
                : AppTextStyles.labelBold,
          ),
        ],
      ),
    );
  }
}

// ────────────────────────────────────────────────
// Status Badge
// ────────────────────────────────────────────────
class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

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
