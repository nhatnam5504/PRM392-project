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
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<_TabDef> _tabs = const [
    _TabDef('Đang xử lý', 'PROCESSING'),
    _TabDef('Đã thanh toán', 'PAID'),
    _TabDef('Đã hủy', 'CANCELED'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderViewModel>().loadOrders();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _shortCode(String code) {
    if (code.length > 8) return code.substring(0, 8).toUpperCase();
    return code.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Text('Đơn hàng của tôi', style: AppTextStyles.headingMd),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.surfaceDark,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              dividerColor: Colors.transparent,
              indicator: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textSecondary,
              labelStyle: AppTextStyles.labelBold.copyWith(fontSize: 13),
              unselectedLabelStyle: AppTextStyles.bodyMd.copyWith(fontSize: 13),
              tabs: _tabs.map((t) => Tab(text: t.label)).toList(),
            ),
          ),
        ),
      ),
      body: Consumer<OrderViewModel>(
        builder: (context, vm, _) {
          if (vm.isLoading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          if (vm.errorMessage != null) {
            return _buildErrorState(vm);
          }

          return TabBarView(
            controller: _tabController,
            children: _tabs.map((tab) {
              final filtered = vm.filteredOrders(tab.value);
              if (filtered.isEmpty) return _buildEmptyState();
              
              return RefreshIndicator(
                onRefresh: vm.loadOrders,
                color: AppColors.primary,
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) => _OrderCard(order: filtered[index]),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }

  Widget _buildErrorState(OrderViewModel vm) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded, size: 64, color: AppColors.error),
            const SizedBox(height: 16),
            Text('Đã có lỗi xảy ra', style: AppTextStyles.headingSm),
            const SizedBox(height: 8),
            Text(vm.errorMessage!, textAlign: TextAlign.center, style: AppTextStyles.bodyMd.copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: 24),
            SizedBox(
              width: 150,
              height: 45,
              child: ElevatedButton(
                onPressed: vm.loadOrders,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('THỬ LẠI'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: AppColors.surfaceDark, shape: BoxShape.circle),
            child: Icon(Icons.inventory_2_outlined, size: 48, color: AppColors.textHint.withValues(alpha: 0.5)),
          ),
          const SizedBox(height: 20),
          Text('Chưa có đơn hàng nào', style: AppTextStyles.labelBold.copyWith(color: AppColors.textSecondary)),
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

class _OrderCard extends StatelessWidget {
  final UserOrderModel order;
  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/orders/${order.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.surfaceDark, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.local_shipping_outlined, color: AppColors.primary, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('#${_shortCode(order.orderCode)}', style: AppTextStyles.labelBold),
                        Text(order.formattedDate, style: AppTextStyles.caption.copyWith(fontSize: 11)),
                      ],
                    ),
                  ),
                  _StatusBadge(status: order.status),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.surfaceDark),
            const SizedBox(height: 8),
            ...order.orderDetails.take(2).map((item) => _OrderItemRow(item: item)),
            if (order.orderDetails.length > 2)
              Padding(
                padding: const EdgeInsets.only(left: 76, bottom: 8),
                child: Text('và ${order.orderDetails.length - 2} sản phẩm khác...', style: AppTextStyles.caption.copyWith(fontStyle: FontStyle.italic)),
              ),
            const Divider(height: 1, color: AppColors.surfaceDark),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Tổng thanh toán', style: AppTextStyles.caption),
                      Text(formatVND(order.totalPrice), style: AppTextStyles.labelBold.copyWith(color: AppColors.primary, fontSize: 16)),
                    ],
                  ),
                  Row(
                    children: [
                      if (['PAID', 'DELIVERED', 'COMPLETED'].contains(order.status.toUpperCase()))
                        Container(
                          margin: const EdgeInsets.only(right: 8),
                          child: TextButton(
                            onPressed: () => context.push('/orders/${order.id}'),
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.amber.withValues(alpha: 0.1),
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: Text('Đánh giá', style: AppTextStyles.labelBold.copyWith(color: Colors.amber[800], fontSize: 12)),
                          ),
                        ),
                      Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textHint.withValues(alpha: 0.5)),
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
    if (code.length > 8) return code.substring(0, 8).toUpperCase();
    return code.toUpperCase();
  }
}

class _OrderItemRow extends StatelessWidget {
  final UserOrderDetailModel item;
  const _OrderItemRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: 48, height: 48,
              color: AppColors.surfaceDark,
              child: item.imgUrl.isNotEmpty
                  ? Image.network(item.imgUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.image_outlined, color: AppColors.textHint, size: 20))
                  : const Icon(Icons.image_outlined, color: AppColors.textHint, size: 20),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.productName, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTextStyles.labelBold.copyWith(fontSize: 13)),
                Text('Số lượng: ${item.quantity}', style: AppTextStyles.caption),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(item.isGift ? 'Quà tặng' : formatVND(item.subtotal), style: AppTextStyles.labelBold.copyWith(fontSize: 13, color: item.isGift ? AppColors.success : AppColors.textPrimary)),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: _color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
      child: Text(_label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: _color)),
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
