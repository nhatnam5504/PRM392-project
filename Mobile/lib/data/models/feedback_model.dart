class FeedbackModel {
  final String comment;
  final DateTime date;
  final int orderDetailId;
  final int productId;
  final int rating;
  final String userName;

  const FeedbackModel({
    required this.comment,
    required this.date,
    required this.orderDetailId,
    required this.productId,
    required this.rating,
    required this.userName,
  });

  factory FeedbackModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return FeedbackModel(
      comment: json['comment'] as String? ?? '',
      date: DateTime.parse(
        json['date'] as String,
      ),
      orderDetailId:
          json['orderDetailId'] as int? ?? 0,
      productId: json['productId'] as int? ?? 0,
      rating: json['rating'] as int? ?? 0,
      userName: json['userName'] as String? ?? '',
    );
  }
}

