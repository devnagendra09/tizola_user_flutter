import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../../../main/domain/entities/in_progress_order_entity.dart';
import '../../domain/entities/cuisine_entity.dart';
import '../../domain/entities/orders_page_entity.dart';
import '../../domain/repositories/catalog_repository.dart';
import '../../../search/domain/entities/search_suggestion_entity.dart';
import '../../domain/enums/restaurant_food_filter.dart';
import '../../domain/enums/restaurant_price_option.dart';
import '../../domain/enums/restaurant_sort_option.dart';
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
  Future<Result<List<SearchSuggestionEntity>>> searchRestaurantNames({
    required String keyword,
  }) async {
    try {
      final data = await _remote.searchRestaurantNames(keyword: keyword);
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
    List<String> cuisineIds = const [],
    RestaurantSortOption? sortOption,
    RestaurantPriceOption? priceOption,
    bool favouritesOnly = false,
    String? searchKey,
  }) async {
    try {
      final data = await _remote.getRestaurants(
        page: page,
        foodFilter: foodFilter,
        cuisineIds: cuisineIds,
        sortOption: sortOption,
        priceOption: priceOption,
        favouritesOnly: favouritesOnly,
        searchKey: searchKey,
      );
      return Result.success(data);
    } on Failure catch (e) {
      return Result.failure(e);
    } catch (_) {
      return Result.failure(const NetworkFailure());
    }
  }

  @override
  Future<Result<OrdersPageEntity>> getOrders({
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

  @override
  Future<Result<InProgressOrderEntity?>> checkInProgressOrder() async {
    try {
      final data = await _remote.checkInProgressOrder();
      return Result.success(data);
    } on Failure catch (e) {
      return Result.failure(e);
    } catch (_) {
      return Result.failure(const NetworkFailure());
    }
  }
}
