import 'package:equatable/equatable.dart';

class HomeBannerEntity extends Equatable {
  const HomeBannerEntity({
    required this.id,
    this.promotionImage,
    this.restaurantId,
    this.restaurantName,
  });

  final String id;
  final String? promotionImage;
  final String? restaurantId;
  final String? restaurantName;

  @override
  List<Object?> get props =>
      [id, promotionImage, restaurantId, restaurantName];
}

class HomeSliderEntity extends Equatable {
  const HomeSliderEntity({
    required this.id,
    this.image,
    this.redirectionUrl,
  });

  final String id;
  final String? image;
  final String? redirectionUrl;

  @override
  List<Object?> get props => [id, image, redirectionUrl];
}

class CustomerCareEntity extends Equatable {
  const CustomerCareEntity({this.phone, this.whatsapp});

  final String? phone;
  final String? whatsapp;

  @override
  List<Object?> get props => [phone, whatsapp];
}
