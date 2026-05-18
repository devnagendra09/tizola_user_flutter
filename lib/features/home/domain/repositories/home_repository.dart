import '../../../../core/utils/result.dart';
import '../entities/home_banner_entity.dart';

class HomeFeedEntity {
  const HomeFeedEntity({
    this.notificationMessage,
    this.couponBanners = const [],
    this.sliders = const [],
    this.customerCare,
  });

  final String? notificationMessage;
  final List<HomeBannerEntity> couponBanners;
  final List<HomeSliderEntity> sliders;
  final CustomerCareEntity? customerCare;
}

abstract class HomeRepository {
  Future<Result<HomeFeedEntity>> loadHomeFeed();
}
