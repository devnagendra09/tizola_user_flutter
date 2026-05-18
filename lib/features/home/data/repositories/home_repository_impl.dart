import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/home_banner_entity.dart';
import '../../domain/repositories/home_repository.dart';
import '../datasources/home_remote_data_source.dart';

class HomeRepositoryImpl implements HomeRepository {
  HomeRepositoryImpl(this._remote);

  final HomeRemoteDataSource _remote;

  @override
  Future<Result<HomeFeedEntity>> loadHomeFeed() async {
    try {
      final results = await Future.wait([
        _remote.getNotificationMessage(),
        _remote.getCouponBanners(),
        _remote.getSliders(),
        _safeCustomerCare(),
      ]);

      return Result.success(
        HomeFeedEntity(
          notificationMessage: results[0] as String?,
          couponBanners: results[1] as List<HomeBannerEntity>,
          sliders: results[2] as List<HomeSliderEntity>,
          customerCare: results[3] as CustomerCareEntity?,
        ),
      );
    } on Failure catch (e) {
      return Result.failure(e);
    } catch (_) {
      return Result.failure(const NetworkFailure());
    }
  }

  Future<CustomerCareEntity?> _safeCustomerCare() async {
    try {
      return await _remote.getCustomerCare();
    } catch (_) {
      return null;
    }
  }
}
