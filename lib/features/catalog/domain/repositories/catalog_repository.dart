import '../../../../core/utils/result.dart';
import '../entities/cuisine_entity.dart';
import '../entities/order_entity.dart';
import '../../../home/domain/entities/restaurant_page_entity.dart';
import '../enums/restaurant_food_filter.dart';

abstract class CatalogRepository {
  Future<Result<List<CuisineEntity>>> getCuisines();
  Future<Result<RestaurantPageEntity>> getRestaurants({
    required int page,
    RestaurantFoodFilter foodFilter = RestaurantFoodFilter.all,
    List<String> cuisineIds = const [],
  });
  Future<Result<({List<OrderEntity> orders, int totalPages})>> getOrders({
    required String type,
    required int page,
  });
}
