import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/cuisine_entity.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/repositories/catalog_repository.dart';
import '../../domain/enums/restaurant_food_filter.dart';
import '../datasources/catalog_remote_data_source.dart';
import '../../../home/domain/entities/restaurant_page_entity.dart';

class CatalogRepositoryImpl implements CatalogRepository {
  CatalogRepositoryImpl(this._remote);

  final CatalogRemoteDataSource _remote;

  @override
  Future<Result<List<CuisineEntity>>> getCuisines() async {
    try {
      final data = await _remote.getCuisines();
      return Result.success(data);
    } on Failure catch (e) {
      return Result.failure(e);
    } catch (_) {
      return Result.failure(const NetworkFailure());
    }
  }

  @override
  Future<Result<RestaurantPageEntity>> getRestaurants({
    required int page,
    RestaurantFoodFilter foodFilter = RestaurantFoodFilter.all,
  }) async {
    try {
      final data = await _remote.getRestaurants(
        page: page,
        foodFilter: foodFilter,
      );
      return Result.success(data);
    } on Failure catch (e) {
      return Result.failure(e);
    } catch (_) {
      return Result.failure(const NetworkFailure());
    }
  }

  @override
  Future<Result<({List<OrderEntity> orders, int totalPages})>> getOrders({
    required String type,
    required int page,
  }) async {
    try {
      final data = await _remote.getOrders(type: type, page: page);
      return Result.success(data);
    } on Failure catch (e) {
      return Result.failure(e);
    } catch (_) {
      return Result.failure(const NetworkFailure());
    }
  }
}
