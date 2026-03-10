import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../config/app_text_styles.dart';
import '../models/category.dart';

/// Widget hiển thị một danh mục dạng icon tròn + tên
/// Dùng trong phần "Danh mục nổi bật" trên trang chủ
class CategoryItem extends StatelessWidget {
  final Category category;
  final VoidCallback? onTap; // Callback khi nhấn vào danh mục

  const CategoryItem({super.key, required this.category, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon danh mục trong vòng tròn
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(category.icon, color: AppColors.primary, size: 28),
          ),
          const SizedBox(height: AppSpacing.xs),
          // Tên danh mục
          Text(
            category.name,
            style: AppTextStyles.caption.copyWith(
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
