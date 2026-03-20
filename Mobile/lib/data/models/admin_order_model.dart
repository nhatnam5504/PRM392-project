class AdminOrderDetailItem {
  final int orderDetailId;
  final int productId;
  final String productName;
  final String? imgUrl;
  final int quantity;
  final double subtotal;
  final String? type;

  const AdminOrderDetailItem({
    required this.orderDetailId,
    required this.productId,
    required this.productName,
    this.imgUrl,
    required this.quantity,
    required this.subtotal,
    this.type,
  });

  bool get isGift => type == 'gift';

  factory AdminOrderDetailItem.fromJson(Map<String, dynamic> json) {
    return AdminOrderDetailItem(
      orderDetailId: json['orderDetailId'] as int,
      productId: json['productId'] as int,
      productName: json['productName'] as String? ?? '',
      imgUrl: json['imgUrl'] as String?,
      quantity: json['quantity'] as int? ?? 1,
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0,
      type: json['type'] as String?,
    );
  }
}

class AdminOrderInfo {
  final String recipientName;
  final String phoneNumber;
  final String address;

  const AdminOrderInfo({
    required this.recipientName,
    required this.phoneNumber,
    required this.address,
  });

  factory AdminOrderInfo.fromJson(Map<String, dynamic> json) {
    return AdminOrderInfo(
      recipientName: json['recipientName'] as String? ?? '',
      phoneNumber: json['phoneNumber'] as String? ?? '',
      address: json['address'] as String? ?? '',
    );
  }

  bool get isEmpty =>
      recipientName.trim().isEmpty &&
      phoneNumber.trim().isEmpty &&
      address.trim().isEmpty;
}

class AdminOrderModel {
  final int id;
  final String? orderCode;
  final String userName;
  final String orderDate;
  final String status;
  final double totalPrice;
  final double basePrice;
  final String? note;
  final List<AdminOrderDetailItem> orderDetails;
  final List<AdminOrderInfo> orderInfo;

  const AdminOrderModel({
    required this.id,
    this.orderCode,
    required this.userName,
    required this.orderDate,
    required this.status,
    required this.totalPrice,
    required this.basePrice,
    this.note,
    required this.orderDetails,
    required this.orderInfo,
  });

  String get shortCode {
    final code = orderCode ?? '';
    if (code.length > 8) return '#${code.substring(0, 8).toUpperCase()}';
    if (code.isNotEmpty) return '#${code.toUpperCase()}';
    return '#${id.toString()}';
  }

  String get formattedDate {
    try {
      final dt = DateTime.parse(orderDate).toLocal();
      final h = dt.hour.toString().padLeft(2, '0');
      final m = dt.minute.toString().padLeft(2, '0');
      return '${dt.day}/${dt.month}/${dt.year}  $h:$m';
    } catch (_) {
      return orderDate;
    }
  }

  factory AdminOrderModel.fromJson(Map<String, dynamic> json) {
    final details = (json['orderDetails'] as List<dynamic>? ?? [])
        .map((e) => AdminOrderDetailItem.fromJson(e as Map<String, dynamic>))
        .toList();

    final info = (json['orderInfo'] as List<dynamic>? ?? [])
        .map((e) => AdminOrderInfo.fromJson(e as Map<String, dynamic>))
        .toList();

    return AdminOrderModel(
      id: json['id'] as int,
      orderCode: json['orderCode'] as String?,
      userName: json['userName'] as String? ?? 'Khách hàng',
      orderDate: json['orderDate'] as String? ?? '',
      status: json['status'] as String? ?? 'UNKNOWN',
      totalPrice: (json['totalPrice'] as num?)?.toDouble() ?? 0,
      basePrice: (json['basePrice'] as num?)?.toDouble() ?? 0,
      note: json['note'] as String?,
      orderDetails: details,
      orderInfo: info,
    );
  }
}
