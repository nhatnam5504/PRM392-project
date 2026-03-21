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
      body: SafeArea(
        child: Column(
          children: [
            // Header & Horizontal Navigation
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Row(
                      children: [
                        _buildLogo(),
                        const Spacer(),
                        _buildProfileMini(),
                        const SizedBox(width: 8),
                        _buildLogoutIconButton(authVm),
                      ],
                    ),
                  ),
                  _buildHorizontalNav(),
                  const SizedBox(height: 8),
                ],
              ),
            ),
            
            // Main Content
            Expanded(
              child: Container(
                color: AppColors.surfaceDark.withValues(alpha: 0.3),
                child: IndexedStack(
                  index: _selectedIndex,
                  children: _navItems.map((item) => item.screen).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileMini() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircleAvatar(
            radius: 10,
            backgroundColor: AppColors.primary,
            child: Icon(Icons.person_rounded, size: 12, color: Colors.white),
          ),
          const SizedBox(width: 6),
          Text(
            'Admin',
            style: AppTextStyles.labelBold.copyWith(fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutIconButton(AuthViewModel authVm) {
    return IconButton(
      icon: const Icon(Icons.logout_rounded, size: 20, color: AppColors.error),
      onPressed: () => _handleLogout(authVm),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
    );
  }

  Future<void> _handleLogout(AuthViewModel authVm) async {
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
  }

  Widget _buildHorizontalNav() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: List.generate(_navItems.length, (index) {
          final item = _navItems[index];
          final isSelected = _selectedIndex == index;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ChoiceChip(
              label: Text(
                item.label,
                style: AppTextStyles.labelBold.copyWith(
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) setState(() => _selectedIndex = index);
              },
              selectedColor: AppColors.primary,
              backgroundColor: Colors.transparent,
              side: BorderSide(
                color: isSelected ? AppColors.primary : AppColors.divider.withValues(alpha: 0.3),
              ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              showCheckmark: false,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildLogo() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary, const Color(0xFF22D3EE)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.devices_other_rounded, color: Colors.white, size: 18),
        ),
        const SizedBox(width: 8),
        Text(
          'TECHGEAR',
          style: AppTextStyles.headingSm.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w900,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

}

class _NavItem {
  final IconData icon;
  final String label;
  final Widget screen;

  _NavItem(this.icon, this.label, this.screen);
}
