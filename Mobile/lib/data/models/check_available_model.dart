/// Request model for checking product availability
class CheckAvailableRequest {
  final int userId;
  final String status; // PENDING
  final double totalPrice;
  final double basePrice;
  final String orderCode;
  final List<OrderDetailRequest> orderDetails;
  final List<OrderInfo> orderInfo;
  final String note;

  CheckAvailableRequest({
    required this.userId,
    required this.status,
    required this.totalPrice,
    required this.basePrice,
    required this.orderCode,
    required this.orderDetails,
    required this.orderInfo,
    required this.note,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'status': status,
      'totalPrice': totalPrice,
      'basePrice': basePrice,
      'orderCode': orderCode,
      'orderDetails': orderDetails
          .map((detail) => detail.toJson())
          .toList(),
      'orderInfo': orderInfo
          .map((info) => info.toJson())
          .toList(),
      'note': note,
    };
  }
}

class OrderInfo {
  final String phoneNumber;
  final String address;
  final String recipientName;

  OrderInfo({
    required this.phoneNumber,
    required this.address,
    required this.recipientName,
  });

  Map<String, dynamic> toJson() {
    return {
      'phoneNumber': phoneNumber,
      'address': address,
      'recipientName': recipientName,
    };
  }

  factory OrderInfo.fromJson(Map<String, dynamic> json) {
    return OrderInfo(
      phoneNumber: json['phoneNumber'] as String? ?? '',
      address: json['address'] as String? ?? '',
      recipientName: json['recipientName'] as String? ?? '',
    );
  }
}

/// Order detail in check available request
class OrderDetailRequest {
  final int productId;
  final int quantity;
  final double subtotal;
  final String type; // 'buy' or 'gift'

  OrderDetailRequest({
    required this.productId,
    required this.quantity,
    required this.subtotal,
    required this.type,
  });

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'quantity': quantity,
      'subtotal': subtotal,
      'type': type,
    };
  }
}

/// Response model from check available API
class CheckAvailableResponse {
  final int userId;
  final String status;
  final double totalPrice;
  final double basePrice;
  final String orderCode;
  final List<OrderDetailResponse> orderDetails;
  final List<OrderInfo> orderInfo;
  final String note;

  CheckAvailableResponse({
    required this.userId,
    required this.status,
    required this.totalPrice,
    required this.basePrice,
    required this.orderCode,
    required this.orderDetails,
    required this.orderInfo,
    required this.note,
  });

  factory CheckAvailableResponse.fromJson(
    Map<String, dynamic> json,
  ) {
    return CheckAvailableResponse(
      userId: json['userId'] as int? ?? 0,
      status: json['status'] as String? ?? '',
      totalPrice: (json['totalPrice'] as num?)?.toDouble() ?? 0.0,
      basePrice: (json['basePrice'] as num?)?.toDouble() ?? 0.0,
      orderCode: json['orderCode'] as String? ?? '',
      orderDetails: (json['orderDetails'] as List?)
              ?.map(
                (detail) => OrderDetailResponse.fromJson(
                  detail as Map<String, dynamic>,
                ),
              )
              .toList() ??
          [],
      orderInfo: (json['orderInfo'] as List?)
              ?.map(
                (info) => OrderInfo.fromJson(
                  info as Map<String, dynamic>,
                ),
              )
              .toList() ??
          [],
      note: json['note'] as String? ?? '',
    );
  }
}

/// Order detail in check available response
class OrderDetailResponse {
  final int productId;
  final int quantity;
  final double subtotal;
  final String type;

  OrderDetailResponse({
    required this.productId,
    required this.quantity,
    required this.subtotal,
    required this.type,
  });

  factory OrderDetailResponse.fromJson(
    Map<String, dynamic> json,
  ) {
    return OrderDetailResponse(
      productId: json['productId'] as int? ?? 0,
      quantity: json['quantity'] as int? ?? 0,
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      type: json['type'] as String? ?? '',
    );
  }
}

