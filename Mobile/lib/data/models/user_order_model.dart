import 'package:intl/intl.dart';

/// Matches GET /api/orders/user/{userId} response
class UserOrderModel {
  final int id;
  final String orderCode;
  final DateTime orderDate;
  final String status;
  final double basePrice;
  final double totalPrice;
  final String userName;
  final List<UserOrderDetailModel> orderDetails;

  const UserOrderModel({
    required this.id,
    required this.orderCode,
    required this.orderDate,
    required this.status,
    required this.basePrice,
    required this.totalPrice,
    required this.userName,
    required this.orderDetails,
  });

  factory UserOrderModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return UserOrderModel(
      id: json['id'] as int,
      orderCode: json['orderCode'] as String,
      orderDate: DateTime.parse(
        json['orderDate'] as String,
      ),
      status: (json['status'] as String)
          .toUpperCase(),
      basePrice:
          (json['basePrice'] as num).toDouble(),
      totalPrice:
          (json['totalPrice'] as num).toDouble(),
      userName: json['userName'] as String? ?? '',
      orderDetails:
          (json['orderDetails'] as List<dynamic>)
              .map(
                (e) =>
                    UserOrderDetailModel.fromJson(
                  e as Map<String, dynamic>,
                ),
              )
              .toList(),
    );
  }

  /// Only items with type == 'buy'
  List<UserOrderDetailModel> get buyItems =>
      orderDetails
          .where((d) => d.type == 'buy')
          .toList();

  /// Only items with type == 'gift'
  List<UserOrderDetailModel> get giftItems =>
      orderDetails
          .where((d) => d.type == 'gift')
          .toList();

  int get totalItemCount => orderDetails
      .where((d) => d.type == 'buy')
      .fold(0, (sum, d) => sum + d.quantity);

  String get formattedDate {
    final formatter =
        DateFormat('dd/MM/yyyy HH:mm');
    return formatter.format(orderDate.toLocal());
  }
}

class UserOrderDetailModel {
  final int productId;
  final String productName;
  final String imgUrl;
  final int quantity;
  final double subtotal;
  final String type; // 'buy' or 'gift'

  const UserOrderDetailModel({
    required this.productId,
    required this.productName,
    required this.imgUrl,
    required this.quantity,
    required this.subtotal,
    required this.type,
  });

  factory UserOrderDetailModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return UserOrderDetailModel(
      productId: json['productId'] as int,
      productName:
          json['productName'] as String,
      imgUrl: json['imgUrl'] as String? ?? '',
      quantity: json['quantity'] as int,
      subtotal:
          (json['subtotal'] as num).toDouble(),
      type: json['type'] as String? ?? 'buy',
    );
  }

  bool get isGift => type == 'gift';
}

