import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../auth/view_models/auth_view_model.dart';
import 'admin_product_list_screen.dart';
import 'admin_brand_list_screen.dart';
import 'admin_category_list_screen.dart';
import 'admin_order_list_screen.dart';
import 'admin_revenue_screen.dart';
import 'admin_promotion_list_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authVm = context.watch<AuthViewModel>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.surface,
        title: Text(
          'Quản lý TechGear',
          style: AppTextStyles.headingMd.copyWith(
            color: AppColors.primary,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: false,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.logout_rounded, color: AppColors.error, size: 22),
              tooltip: 'Đăng xuất',
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Đăng xuất'),
                    content: const Text('Bạn có chắc chắn muốn thoát?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Hủy'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: TextButton.styleFrom(foregroundColor: AppColors.error),
                        child: const Text('Đăng xuất'),
                      ),
                    ],
                  ),
                );
                if (confirm == true) {
                  await authVm.logout();
                  if (context.mounted) context.go('/login');
                }
              },
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              labelPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                color: AppColors.primary.withValues(alpha: 0.12),
              ),
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textSecondary,
              labelStyle: AppTextStyles.labelBold.copyWith(fontSize: 13),
              unselectedLabelStyle: AppTextStyles.labelMd.copyWith(fontSize: 13),
              tabs: const [
                Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.inventory_2_outlined, size: 18),
                      SizedBox(width: 8),
                      Text('Sản phẩm'),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.branding_watermark_outlined, size: 18),
                      SizedBox(width: 8),
                      Text('Nhãn hiệu'),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.category_outlined, size: 18),
                      SizedBox(width: 8),
                      Text('Danh mục'),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.receipt_long_outlined, size: 18),
                      SizedBox(width: 8),
                      Text('Đơn hàng'),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.analytics_outlined, size: 18),
                      SizedBox(width: 8),
                      Text('Doanh thu'),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.discount_outlined, size: 18),
                      SizedBox(width: 8),
                      Text('Khuyến mãi'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          AdminProductListScreen(),
          AdminBrandListScreen(),
          AdminCategoryListScreen(),
          AdminOrderListScreen(),
          AdminRevenueScreen(),
          AdminPromotionListScreen(),
        ],
      ),
    );
  }
}
