class PaymentPromotion {
  final int id;
  final String code;
  final String description;
  final String type;
  final double discountValue;

  const PaymentPromotion({
    required this.id,
    required this.code,
    required this.description,
    required this.type,
    required this.discountValue,
  });

  factory PaymentPromotion.fromJson(Map<String, dynamic> json) {
    return PaymentPromotion(
      id: json['id'] as int,
      code: json['code'] as String? ?? '',
      description: json['description'] as String? ?? '',
      type: json['type'] as String? ?? '',
      discountValue: (json['discountValue'] as num?)?.toDouble() ?? 0,
    );
  }
}

class PaymentModel {
  final int id;
  final String paymentMethod;
  final double amount;
  final String date; // ISO8601
  final String status; // PENDING / COMPLETED
  final String? transactionCode;
  final PaymentPromotion? promotion;
  final String orderStatus; // from order.status
  final double orderTotalPrice;

  const PaymentModel({
    required this.id,
    required this.paymentMethod,
    required this.amount,
    required this.date,
    required this.status,
    this.transactionCode,
    this.promotion,
    required this.orderStatus,
    required this.orderTotalPrice,
  });

  /// Only count revenue from completed payments
  bool get isCompleted => status.toUpperCase() == 'COMPLETED';

  DateTime get dateTime => DateTime.tryParse(date) ?? DateTime.now();

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    final order = json['order'] as Map<String, dynamic>? ?? {};
    PaymentPromotion? promo;
    if (json['promotion'] != null) {
      promo = PaymentPromotion.fromJson(
          json['promotion'] as Map<String, dynamic>);
    }
    return PaymentModel(
      id: json['id'] as int,
      paymentMethod: json['paymentMethod'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      date: json['date'] as String? ?? '',
      status: json['status'] as String? ?? '',
      transactionCode: json['transactionCode'] as String?,
      promotion: promo,
      orderStatus: order['status'] as String? ?? '',
      orderTotalPrice: (order['totalPrice'] as num?)?.toDouble() ?? 0,
    );
  }
}
