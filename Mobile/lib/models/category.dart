import 'package:flutter/material.dart';

/// Model đại diện cho một danh mục sản phẩm
class Category {
  final String id;
  final String name; // Tên danh mục
  final IconData icon; // Icon hiển thị
  final String? imageUrl; // Ảnh danh mục (nếu có)

  Category({
    required this.id,
    required this.name,
    required this.icon,
    this.imageUrl,
  });
}
