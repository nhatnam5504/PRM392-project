import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/category.dart';

/// Dữ liệu mẫu cho ứng dụng TechGear
/// Sẽ được thay thế bằng API thật sau này
class SampleData {
  /// Danh sách danh mục nổi bật hiển thị trên trang chủ
  static List<Category> categories = [
    Category(id: 'op-lung', name: 'Ốp lưng', icon: Icons.phone_android),
    Category(id: 'tai-nghe', name: 'Tai nghe', icon: Icons.headphones),
    Category(
      id: 'sac-du-phong',
      name: 'Sạc dự phòng',
      icon: Icons.battery_charging_full,
    ),
    Category(id: 'cap-sac', name: 'Cáp sạc', icon: Icons.cable),
    Category(id: 'dong-ho', name: 'Đồng hồ', icon: Icons.watch),
    Category(id: 'loa', name: 'Loa', icon: Icons.speaker),
  ];

  /// Bộ lọc dung lượng cho danh mục sạc dự phòng
  static List<String> capacityFilters = [
    'Tất cả',
    '10000mAh',
    '20000mAh',
    '26000mAh',
  ];

  /// Bộ lọc thương hiệu
  static List<String> brandFilters = [
    'Tất cả',
    'Anker',
    'Baseus',
    'Samsung',
    'Xiaomi',
  ];

  /// Danh sách sản phẩm sạc dự phòng mẫu
  static List<Product> products = [
    Product(
      id: 'p1',
      name: 'Sạc dự phòng MagGo 3-in-1',
      brand: 'Anker',
      categoryId: 'sac-du-phong',
      description:
          'Sạc dự phòng MagGo 3-in-1 tích hợp công nghệ sạc nhanh MagSafe, '
          'hỗ trợ sạc không dây cho iPhone, AirPods và Apple Watch cùng lúc. '
          'Thiết kế nhỏ gọn, dễ dàng mang theo bên mình.',
      price: 850000,
      originalPrice: 1200000,
      imageUrl: 'https://picsum.photos/seed/powerbank1/400/400',
      rating: 4.8,
      reviewCount: 234,
      tags: ['HOT'],
      capacity: '10000mAh',
    ),
    Product(
      id: 'p2',
      name: '100W GaN Pro Power Bank',
      brand: 'Anker',
      categoryId: 'sac-du-phong',
      description:
          'Sạc dự phòng GaN Pro 100W công nghệ Fast Charge, '
          'hỗ trợ sạc nhanh laptop, tablet và điện thoại. '
          'Dung lượng lớn 20000mAh, phù hợp cho chuyến đi dài ngày.',
      price: 1450000,
      originalPrice: 1800000,
      imageUrl: 'https://picsum.photos/seed/powerbank2/400/400',
      rating: 4.6,
      reviewCount: 189,
      tags: ['NEW'],
      capacity: '20000mAh',
    ),
    Product(
      id: 'p3',
      name: 'Samsung EB-P5200 Power Bank',
      brand: 'Samsung',
      categoryId: 'sac-du-phong',
      description:
          'Sạc dự phòng Samsung EB-P5200 với dung lượng 20000mAh, '
          'hỗ trợ sạc nhanh 25W, hai cổng USB-C và USB-A. '
          'Thiết kế sang trọng, chất lượng đảm bảo từ Samsung.',
      price: 990000,
      imageUrl: 'https://picsum.photos/seed/powerbank3/400/400',
      rating: 4.5,
      reviewCount: 156,
      tags: [],
      capacity: '20000mAh',
    ),
    Product(
      id: 'p4',
      name: 'Anker PowerCore Elite 26K',
      brand: 'Anker',
      categoryId: 'sac-du-phong',
      description:
          'Sạc dự phòng Anker PowerCore Elite với dung lượng khủng 26000mAh, '
          'hỗ trợ PowerIQ 3.0 và Power Delivery, sạc nhanh cho mọi thiết bị. '
          'Có màn hình LED hiển thị pin.',
      price: 2150000,
      originalPrice: 2500000,
      imageUrl: 'https://picsum.photos/seed/powerbank4/400/400',
      rating: 4.9,
      reviewCount: 312,
      tags: ['HOT'],
      capacity: '26000mAh',
    ),
    Product(
      id: 'p5',
      name: 'Baseus Bipow 10000mAh',
      brand: 'Baseus',
      categoryId: 'sac-du-phong',
      description:
          'Sạc dự phòng Baseus Bipow nhỏ gọn 10000mAh, '
          'hỗ trợ sạc nhanh 20W PD, cổng USB-C và Lightning. '
          'Thiết kế mỏng nhẹ, dễ bỏ túi.',
      price: 450000,
      originalPrice: 600000,
      imageUrl: 'https://picsum.photos/seed/powerbank5/400/400',
      rating: 4.4,
      reviewCount: 98,
      tags: [],
      capacity: '10000mAh',
    ),
    Product(
      id: 'p6',
      name: 'Xiaomi Mi Power Bank 3',
      brand: 'Xiaomi',
      categoryId: 'sac-du-phong',
      description:
          'Sạc dự phòng Xiaomi Mi Power Bank 3 dung lượng 20000mAh, '
          'hỗ trợ sạc nhanh 50W, 3 cổng sạc đồng thời. '
          'Vỏ nhôm cao cấp, bền bỉ theo thời gian.',
      price: 750000,
      imageUrl: 'https://picsum.photos/seed/powerbank6/400/400',
      rating: 4.7,
      reviewCount: 445,
      tags: ['NEW'],
      capacity: '20000mAh',
    ),
    Product(
      id: 'p7',
      name: 'Tai nghe Bluetooth AirPods Pro 2',
      brand: 'Apple',
      categoryId: 'tai-nghe',
      description:
          'Tai nghe Apple AirPods Pro 2 với chip H2, chống ồn chủ động, '
          'chất âm Hi-Fi, thời lượng pin lên đến 30 giờ với hộp sạc.',
      price: 5990000,
      originalPrice: 6790000,
      imageUrl: 'https://picsum.photos/seed/airpods/400/400',
      rating: 4.9,
      reviewCount: 567,
      tags: ['HOT'],
    ),
    Product(
      id: 'p8',
      name: 'Cáp sạc USB-C to Lightning',
      brand: 'Anker',
      categoryId: 'cap-sac',
      description:
          'Cáp sạc Anker USB-C to Lightning chứng nhận MFi, '
          'hỗ trợ sạc nhanh PD 30W, dây bện nylon bền bỉ dài 1.8m.',
      price: 350000,
      imageUrl: 'https://picsum.photos/seed/cable1/400/400',
      rating: 4.6,
      reviewCount: 203,
      tags: [],
    ),
  ];

  /// Lấy sản phẩm theo danh mục
  static List<Product> getProductsByCategory(String categoryId) {
    return products.where((p) => p.categoryId == categoryId).toList();
  }

  /// Lấy sản phẩm nổi bật (có tag HOT hoặc NEW)
  static List<Product> getFeaturedProducts() {
    return products.where((p) => p.tags.isNotEmpty).toList();
  }
}
