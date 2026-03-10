import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../screens/home_screen.dart';
import '../screens/category_screen.dart';
import '../screens/cart_screen.dart';
import '../widgets/bottom_nav_bar.dart';

/// Màn hình chính chứa thanh điều hướng dưới (Bottom Navigation)
/// Quản lý việc chuyển đổi giữa các tab: Trang chủ, Danh mục, Giỏ hàng, Tài khoản
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  // Tab đang được chọn (mặc định là Trang chủ)
  int _currentIndex = 0;

  // Danh sách các màn hình tương ứng với mỗi tab
  final List<Widget> _screens = [
    const HomeScreen(),
    const CategoryScreen(categoryId: 'sac-du-phong'),
    const CartScreen(),
    _buildAccountPlaceholder(),
  ];

  /// Xử lý khi người dùng nhấn vào tab
  void _onTabSelected(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        // Dùng IndexedStack để giữ trạng thái các tab khi chuyển đổi
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTabSelected,
        cartBadgeCount: 2, // Số lượng sản phẩm mẫu trong giỏ
      ),
    );
  }

  /// Tạo màn hình tài khoản tạm (chưa có API)
  static Widget _buildAccountPlaceholder() {
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_outline, size: 80, color: AppColors.textHint),
            SizedBox(height: 16),
            Text(
              'Tài khoản',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Tính năng đang phát triển',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
