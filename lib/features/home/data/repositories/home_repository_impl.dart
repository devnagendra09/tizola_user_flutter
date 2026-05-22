import '../../../../core/errors/failures.dart';
import '../../../../core/utils/future_utils.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/home_banner_entity.dart';
import '../../domain/repositories/home_repository.dart';
import '../datasources/home_remote_data_source.dart';

class HomeRepositoryImpl implements HomeRepository {
  HomeRepositoryImpl(this._remote);

  final HomeRemoteDataSource _remote;

  static const _feedTimeout = Duration(seconds: 12);

  @override
  Future<Result<HomeFeedEntity>> loadHomeFeed() async {
    try {
      final results = await Future.wait([
        runWithTimeout(
          _remote.getNotificationMessage,
          timeout: const Duration(seconds: 8),
          fallback: null,
        ),
        runWithTimeout(
          _remote.getCouponBanners,
          timeout: _feedTimeout,
          fallback: <HomeBannerEntity>[],
        ),
        runWithTimeout(
          _remote.getSliders,
          timeout: _feedTimeout,
          fallback: <HomeSliderEntity>[],
        ),
        runWithTimeout(
          _safeCustomerCare,
          timeout: _feedTimeout,
          fallback: null,
        ),
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
