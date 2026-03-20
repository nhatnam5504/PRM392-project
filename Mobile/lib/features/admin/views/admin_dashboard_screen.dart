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

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _selectedIndex = 3; // Mặc định mở Đơn hàng (hoặc theo ý bạn)

  final List<_NavItem> _navItems = [
    _NavItem(Icons.inventory_2_rounded, 'Sản phẩm', const AdminProductListScreen()),
    _NavItem(Icons.branding_watermark_rounded, 'Thương hiệu', const AdminBrandListScreen()),
    _NavItem(Icons.grid_view_rounded, 'Danh mục', const AdminCategoryListScreen()),
    _NavItem(Icons.local_shipping_rounded, 'Đơn hàng', const AdminOrderListScreen()),
    _NavItem(Icons.bar_chart_rounded, 'Doanh thu', const AdminRevenueScreen()),
    _NavItem(Icons.confirmation_number_rounded, 'Khuyến mãi', const AdminPromotionListScreen()),
  ];

  @override
  Widget build(BuildContext context) {
    final authVm = context.watch<AuthViewModel>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Row(
        children: [
          // Sidebar
          _buildSidebar(authVm),
          
          // Main Content
          Expanded(
            child: Column(
              children: [
                _buildTopBar(),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceDark.withValues(alpha: 0.3),
                      borderRadius: const BorderRadius.only(topLeft: Radius.circular(32)),
                    ),
                    child: IndexedStack(
                      index: _selectedIndex,
                      children: _navItems.map((item) => item.screen).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar(AuthViewModel authVm) {
    return Container(
      width: 260,
      height: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(right: BorderSide(color: AppColors.divider.withValues(alpha: 0.5))),
      ),
      child: Column(
        children: [
          const SizedBox(height: 40),
          _buildLogo(),
          const SizedBox(height: 40),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _navItems.length,
              itemBuilder: (context, index) {
                final item = _navItems[index];
                final isSelected = _selectedIndex == index;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Material(
                    color: isSelected ? AppColors.primary.withValues(alpha: 0.08) : Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                    child: InkWell(
                      onTap: () => setState(() => _selectedIndex = index),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        child: Row(
                          children: [
                            Icon(
                              item.icon,
                              size: 22,
                              color: isSelected ? AppColors.primary : AppColors.textSecondary,
                            ),
                            const SizedBox(width: 16),
                            Text(
                              item.label,
                              style: AppTextStyles.labelBold.copyWith(
                                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                                fontSize: 14,
                                letterSpacing: 0.5,
                              ),
                            ),
                            if (isSelected) ...[
                              const Spacer(),
                              Container(
                                width: 4,
                                height: 4,
                                decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          _buildLogoutButton(authVm),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return Hero(
      tag: 'app_logo_admin',
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, const Color(0xFF22D3EE)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.devices_other_rounded, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'TECHGEAR',
                style: AppTextStyles.headingSm.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                  fontSize: 18,
                ),
              ),
              Text(
                'ADMIN PANEL',
                style: AppTextStyles.labelBold.copyWith(
                  color: AppColors.textHint,
                  fontSize: 10,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Row(
        children: [
          Text(
            _navItems[_selectedIndex].label.toUpperCase(),
            style: AppTextStyles.headingSm.copyWith(
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
              color: AppColors.textHeading,
            ),
          ),
          const Spacer(),
          // Profile placeholder
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.surfaceDark.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 14,
                  backgroundColor: AppColors.primary,
                  child: Icon(Icons.person_rounded, size: 16, color: Colors.white),
                ),
                const SizedBox(width: 10),
                Text(
                  'Administrator',
                  style: AppTextStyles.labelBold.copyWith(fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(AuthViewModel authVm) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: TextButton(
        onPressed: () async {
          final confirm = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: const Text('Đăng xuất?', style: AppTextStyles.headingSm),
              content: const Text('Bạn có chắc chắn muốn thoát hệ thống không?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text('HUỶ', style: TextStyle(color: AppColors.textSecondary)),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('ĐĂNG XUẤT'),
                ),
              ],
            ),
          );
          if (confirm == true) {
            await authVm.logout();
            if (mounted) context.go('/login');
          }
        },
        style: TextButton.styleFrom(
          foregroundColor: AppColors.error,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout_rounded, size: 20),
            SizedBox(width: 12),
            Text('ĐĂNG XUẤT', style: AppTextStyles.labelBold),
          ],
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  final Widget screen;

  _NavItem(this.icon, this.label, this.screen);
}
