enum PromotionType { money, percentage, bogo }

class PromotionModel {
  final int id;
  final String code;
  final String description;
  final PromotionType type;
  final double discountValue;
  final double maxDiscountValue;
  final double minOrderAmount;
  final DateTime startDate;
  final DateTime endDate;
  final bool active;
  final int quantity;
  final List<int>? applicableProductIds;

  const PromotionModel({
    required this.id,
    required this.code,
    required this.description,
    required this.type,
    required this.discountValue,
    this.maxDiscountValue = 0,
    this.minOrderAmount = 0,
    required this.startDate,
    required this.endDate,
    this.active = true,
    this.quantity = 0,
    this.applicableProductIds,
  });

  bool get isExpired => DateTime.now().isAfter(endDate);

  bool get isUpcoming => DateTime.now().isBefore(startDate);

  bool get isActive =>
      active && !isExpired && !isUpcoming && quantity > 0;

  factory PromotionModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return PromotionModel(
      id: json['id'] as int,
      code: json['code'] as String? ?? '',
      description:
          json['description'] as String? ?? '',
      type: _parseType(json['type'] as String?),
      discountValue:
          (json['discountValue'] as num?)
                  ?.toDouble() ??
              0,
      maxDiscountValue:
          (json['maxDiscountValue'] as num?)
                  ?.toDouble() ??
              0,
      minOrderAmount:
          (json['minOrderAmount'] as num?)
                  ?.toDouble() ??
              0,
      startDate: DateTime.parse(
        json['startDate'] as String,
      ),
      endDate: DateTime.parse(
        json['endDate'] as String,
      ),
      active: json['active'] as bool? ?? true,
      quantity: json['quantity'] as int? ?? 0,
      applicableProductIds:
          (json['applicableProductIds'] as List?)
              ?.map((e) => e as int)
              .toList(),
    );
  }

  static PromotionType _parseType(String? type) {
    switch (type?.toUpperCase()) {
      case 'MONEY':
        return PromotionType.money;
      case 'PERCENTAGE':
        return PromotionType.percentage;
      case 'BOGO':
        return PromotionType.bogo;
      default:
        return PromotionType.money;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'description': description,
      'type': type.name.toUpperCase(),
      'discountValue': discountValue,
      'maxDiscountValue': maxDiscountValue,
      'minOrderAmount': minOrderAmount,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'active': active,
      'quantity': quantity,
      'applicableProductIds': applicableProductIds,
    };
  }
}
