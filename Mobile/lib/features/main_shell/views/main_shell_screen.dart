import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';

class MainShellScreen extends StatefulWidget {
  final Widget child;

  const MainShellScreen({
    super.key,
    required this.child,
  });

  @override
  State<MainShellScreen> createState() =>
      _MainShellScreenState();
}

class _MainShellScreenState
    extends State<MainShellScreen> {
  int _currentIndex = 0;

  static const _tabs = [
    '/',
    '/shop',
    '/deals',
    '/cart',
    '/profile',
  ];

  int _locationToIndex(String location) {
    if (location.startsWith('/profile')) return 4;
    if (location.startsWith('/cart')) return 3;
    if (location.startsWith('/deals')) return 2;
    if (location.startsWith('/shop')) return 1;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final selectedIndex = _locationToIndex(location);

    return Scaffold(
      extendBody: true,
      body: widget.child,
      bottomNavigationBar: Container(
        height: 76,
        margin: const EdgeInsets.fromLTRB(28, 0, 28, 28),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.05),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.2),
            width: 1.5,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: BottomNavigationBar(
            currentIndex: selectedIndex,
            onTap: (index) {
              if (index != selectedIndex) {
                context.go(_tabs[index]);
              }
            },
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.transparent,
            elevation: 0,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: AppColors.textSecondary.withValues(alpha: 0.5),
            selectedFontSize: 0,
            unselectedFontSize: 0,
            showSelectedLabels: false,
            showUnselectedLabels: false,
            items: [
              _buildNavItem(Icons.home_outlined, Icons.home_rounded, 'Trang chủ', selectedIndex == 0),
              _buildNavItem(Icons.storefront_outlined, Icons.storefront_rounded, 'Cửa hàng', selectedIndex == 1),
              _buildNavItem(Icons.local_offer_outlined, Icons.local_offer_rounded, 'Ưu đãi', selectedIndex == 2),
              _buildNavItem(Icons.shopping_cart_outlined, Icons.shopping_cart_rounded, 'Giỏ hàng', selectedIndex == 3),
              _buildNavItem(Icons.person_outline_rounded, Icons.person_rounded, 'Tài khoản', selectedIndex == 4),
            ],
          ),
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem(IconData icon, IconData activeIcon, String label, bool isSelected) {
    return BottomNavigationBarItem(
      icon: SizedBox(
        height: 26,
        child: Stack(
          alignment: Alignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isSelected ? activeIcon : icon,
                size: 22,
                color: isSelected ? AppColors.primary : AppColors.textSecondary.withValues(alpha: 0.5),
              ),
            ),
            if (isSelected)
              Positioned(
                bottom: 0,
                child: Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
      label: '',
    );
  }
}
