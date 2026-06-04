import 'package:equatable/equatable.dart';

class RestaurantReviewEntity extends Equatable {
  const RestaurantReviewEntity({
    required this.customerName,
    required this.feedback,
    required this.rating,
  });

  final String customerName;
  final String feedback;
  final double rating;

  @override
  List<Object?> get props => [customerName, feedback, rating];
}
