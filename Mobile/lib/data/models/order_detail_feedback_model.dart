/// Matches GET /api/orders/feedbacks/order-detail/{orderDetailId} response
class OrderDetailFeedbackModel {
  final int id;
  final int userId;
  final int productId;
  final int rating;
  final String comment;
  final DateTime date;
  final OrderDetailFeedbackItem orderDetail;

  const OrderDetailFeedbackModel({
    required this.id,
    required this.userId,
    required this.productId,
    required this.rating,
    required this.comment,
    required this.date,
    required this.orderDetail,
  });

  factory OrderDetailFeedbackModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return OrderDetailFeedbackModel(
      id: json['id'] as int,
      userId: json['userId'] as int,
      productId: json['productId'] as int,
      rating: json['rating'] as int,
      comment: json['comment'] as String? ?? '',
      date: DateTime.parse(
        json['date'] as String,
      ),
      orderDetail: OrderDetailFeedbackItem.fromJson(
        json['orderDetail'] as Map<String, dynamic>,
      ),
    );
  }
}

class OrderDetailFeedbackItem {
  final int id;
  final int productId;
  final int quantity;
  final double subtotal;
  final String type;

  const OrderDetailFeedbackItem({
    required this.id,
    required this.productId,
    required this.quantity,
    required this.subtotal,
    required this.type,
  });

  factory OrderDetailFeedbackItem.fromJson(
    Map<String, dynamic> json,
  ) {
    return OrderDetailFeedbackItem(
      id: json['id'] as int,
      productId: json['productId'] as int,
      quantity: json['quantity'] as int,
      subtotal: (json['subtotal'] as num).toDouble(),
      type: json['type'] as String? ?? '',
    );
  }
}

