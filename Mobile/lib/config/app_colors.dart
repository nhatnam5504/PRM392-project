import 'package:flutter/material.dart';

/// Bảng màu chính của ứng dụng TechGear
class AppColors {
  // Màu chính - xanh dương đậm
  static const Color primary = Color(0xFF1A237E);
  // Màu chính nhạt hơn
  static const Color primaryLight = Color(0xFF3949AB);
  // Màu nhấn - cam/đỏ cho các nút CTA
  static const Color accent = Color(0xFFFF6B35);
  // Màu nền chính
  static const Color background = Color(0xFFF5F5F5);
  // Màu nền trắng
  static const Color white = Color(0xFFFFFFFF);
  // Màu nền card
  static const Color cardBackground = Color(0xFFFFFFFF);
  // Màu chữ chính
  static const Color textPrimary = Color(0xFF212121);
  // Màu chữ phụ
  static const Color textSecondary = Color(0xFF757575);
  // Màu chữ nhạt
  static const Color textHint = Color(0xFF9E9E9E);
  // Màu xanh lá cho trạng thái thành công
  static const Color success = Color(0xFF4CAF50);
  // Màu đỏ cho lỗi/xóa
  static const Color error = Color(0xFFE53935);
  // Màu viền
  static const Color border = Color(0xFFE0E0E0);
  // Màu giá cũ (gạch ngang)
  static const Color priceOld = Color(0xFF9E9E9E);
  // Màu giá mới
  static const Color priceNew = Color(0xFFE53935);
  // Màu badge
  static const Color badge = Color(0xFFFF6B35);
  // Màu star/đánh giá
  static const Color star = Color(0xFFFFB300);
  // Gradient cho banner
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF1A237E), Color(0xFF3949AB)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
