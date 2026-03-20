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
    _tabController = TabController(length: 5, vsync: this);
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
      appBar: AppBar(
        title: const Text('Quản lý Admin'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Đăng xuất',
            onPressed: () async {
              await authVm.logout();
              if (context.mounted) context.go('/login');
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textHint,
          indicatorColor: AppColors.primary,
          labelStyle: AppTextStyles.labelBold,
          tabs: const [
            Tab(icon: Icon(Icons.inventory_2), text: 'Sản phẩm'),
            Tab(icon: Icon(Icons.branding_watermark), text: 'Thương hiệu'),
            Tab(icon: Icon(Icons.category), text: 'Danh mục'),
            Tab(icon: Icon(Icons.receipt_long_rounded), text: 'Đơn hàng'),
            Tab(icon: Icon(Icons.bar_chart_rounded), text: 'Doanh thu'),
          ],
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
        ],
      ),
    );
  }
}
