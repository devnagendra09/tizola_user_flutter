import 'package:equatable/equatable.dart';

/// Row from `available_coupons` (Android `Coupon` model).
class CouponOfferEntity extends Equatable {
  const CouponOfferEntity({
    required this.couponCode,
    required this.title,
    this.description,
    this.displayEndDate,
  });

  final String couponCode;
  final String title;
  final String? description;
  final String? displayEndDate;

  @override
  List<Object?> get props => [couponCode, title, description, displayEndDate];
}
