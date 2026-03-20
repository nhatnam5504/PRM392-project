import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class HomeAppBar extends StatelessWidget {
  const HomeAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      child: Column(
        children: [
          Row(
            children: [
              // Premium Logo
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, Color(0xFF22D3EE)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(Icons.bolt_rounded, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      style: AppTextStyles.headingSm.copyWith(letterSpacing: -0.5, fontSize: 20),
                      children: [
                        const TextSpan(text: 'TECH', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w900)),
                        TextSpan(text: 'GEAR', style: TextStyle(color: AppColors.textHeading, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                  Text('Premium Electronics', style: AppTextStyles.caption.copyWith(fontSize: 9, letterSpacing: 1.2, color: AppColors.textSecondary)),
                ],
              ),
              const Spacer(),
              // Action Icons
              _AppBarAction(
                icon: Icons.notifications_none_rounded,
                onTap: () {},
                badge: '2',
              ),
              const SizedBox(width: 10),
              _AppBarAction(
                icon: Icons.shopping_basket_outlined,
                onTap: () => context.push('/cart'),
                badge: '3',
                isPrimary: true,
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Search bar
          GestureDetector(
            onTap: () => context.push('/search'),
            child: Container(
              height: 52,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: AppColors.surfaceDark.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.surfaceDark, width: 1.5),
              ),
              child: Row(
                children: [
                  const Icon(Icons.search_rounded, color: AppColors.primary, size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Bạn đang tìm sản phẩm gì?',
                      style: AppTextStyles.bodyMd.copyWith(color: AppColors.textHint, fontSize: 14),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 5),
                      ],
                    ),
                    child: const Icon(Icons.tune_rounded, color: AppColors.primary, size: 18),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AppBarAction extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final String? badge;
  final bool isPrimary;

  const _AppBarAction({
    required this.icon,
    required this.onTap,
    this.badge,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: isPrimary ? AppColors.primary.withValues(alpha: 0.1) : AppColors.surfaceDark.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isPrimary ? AppColors.primary.withValues(alpha: 0.2) : Colors.transparent),
        ),
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            Icon(icon, size: 22, color: isPrimary ? AppColors.primary : AppColors.textPrimary),
            if (badge != null)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
