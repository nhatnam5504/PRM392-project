/// Model đại diện cho một sản phẩm trong cửa hàng
class Product {
  final String id;
  final String name; // Tên sản phẩm
  final String brand; // Thương hiệu
  final String categoryId; // Mã danh mục
  final String description; // Mô tả sản phẩm
  final double price; // Giá bán hiện tại (VNĐ)
  final double? originalPrice; // Giá gốc (nếu có giảm giá)
  final String imageUrl; // Đường dẫn ảnh sản phẩm
  final double rating; // Đánh giá trung bình (0-5)
  final int reviewCount; // Số lượt đánh giá
  final List<String> tags; // Các tag (ví dụ: "NEW", "HOT")
  final String? capacity; // Dung lượng (ví dụ: "10000mAh")
  final bool inStock; // Còn hàng hay không

  Product({
    required this.id,
    required this.name,
    required this.brand,
    required this.categoryId,
    required this.description,
    required this.price,
    this.originalPrice,
    required this.imageUrl,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.tags = const [],
    this.capacity,
    this.inStock = true,
  });
}
