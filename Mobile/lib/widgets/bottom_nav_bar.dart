import 'package:flutter/material.dart';
import '../config/app_colors.dart';

/// Widget thanh điều hướng dưới cùng (Bottom Navigation Bar)
/// Dùng chung cho các màn hình chính: Trang chủ, Danh mục, Giỏ hàng, Tài khoản
class BottomNavBar extends StatelessWidget {
  final int currentIndex; // Tab đang được chọn
  final ValueChanged<int> onTap; // Callback khi chuyển tab
  final int cartBadgeCount; // Số lượng sản phẩm trong giỏ (hiện badge)

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.cartBadgeCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      backgroundColor: AppColors.white,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textHint,
      selectedFontSize: 12,
      unselectedFontSize: 12,
      elevation: 8,
      items: [
        // Tab Trang chủ
        const BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Trang chủ',
        ),
        // Tab Danh mục
        const BottomNavigationBarItem(
          icon: Icon(Icons.category_outlined),
          activeIcon: Icon(Icons.category),
          label: 'Danh mục',
        ),
        // Tab Giỏ hàng (có badge số lượng)
        BottomNavigationBarItem(
          icon: _buildCartIcon(false),
          activeIcon: _buildCartIcon(true),
          label: 'Giỏ hàng',
        ),
        // Tab Tài khoản
        const BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: 'Tài khoản',
        ),
      ],
    );
  }

  /// Xây dựng icon giỏ hàng có badge hiển thị số lượng
  Widget _buildCartIcon(bool isActive) {
    return Badge(
      isLabelVisible: cartBadgeCount > 0,
      label: Text(
        '$cartBadgeCount',
        style: const TextStyle(color: AppColors.white, fontSize: 10),
      ),
      backgroundColor: AppColors.accent,
      child: Icon(
        isActive ? Icons.shopping_cart : Icons.shopping_cart_outlined,
      ),
    );
  }
}
