/// Model đại diện cho một đơn hàng đã đặt
class Order {
  final String id; // Mã đơn hàng (ví dụ: #TG-9948210)
  final String customerName; // Tên khách hàng
  final String address; // Địa chỉ giao hàng
  final String estimatedDelivery; // Ngày giao hàng dự kiến
  final double totalAmount; // Tổng tiền đơn hàng
  final String status; // Trạng thái đơn hàng

  Order({
    required this.id,
    required this.customerName,
    required this.address,
    required this.estimatedDelivery,
    required this.totalAmount,
    this.status = 'Đang xử lý',
  });
}
