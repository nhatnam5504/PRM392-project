import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../config/app_text_styles.dart';

/// Widget ô nhập liệu tùy chỉnh dùng chung
/// Dùng trong màn hình đăng nhập, tìm kiếm, mã giảm giá,...
class CustomTextField extends StatelessWidget {
  final String hintText; // Gợi ý hiển thị khi chưa nhập
  final IconData? prefixIcon; // Icon bên trái
  final Widget? suffixIcon; // Widget bên phải (ví dụ: icon ẩn/hiện mật khẩu)
  final bool obscureText; // Ẩn nội dung (dùng cho mật khẩu)
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged; // Callback khi giá trị thay đổi
  final TextInputType? keyboardType; // Loại bàn phím

  const CustomTextField({
    super.key,
    required this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.controller,
    this.onChanged,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        obscureText: obscureText,
        keyboardType: keyboardType,
        style: AppTextStyles.body,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: AppTextStyles.subtitle.copyWith(color: AppColors.textHint),
          prefixIcon: prefixIcon != null
              ? Icon(prefixIcon, color: AppColors.textHint, size: 22)
              : null,
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md,
          ),
        ),
      ),
    );
  }
}
