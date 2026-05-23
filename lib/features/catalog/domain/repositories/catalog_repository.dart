import '../../../../core/utils/result.dart';
import '../../../main/domain/entities/in_progress_order_entity.dart';
import '../entities/cuisine_entity.dart';
import '../entities/orders_page_entity.dart';
import '../../../home/domain/entities/restaurant_page_entity.dart';
import '../../../search/domain/entities/search_suggestion_entity.dart';
import '../enums/restaurant_food_filter.dart';
import '../enums/restaurant_price_option.dart';
import '../enums/restaurant_sort_option.dart';

abstract class CatalogRepository {
  Future<Result<List<CuisineEntity>>> getCuisines();
  Future<Result<List<SearchSuggestionEntity>>> searchRestaurantNames({
    required String keyword,
  });
  Future<Result<RestaurantPageEntity>> getRestaurants({
    required int page,
    RestaurantFoodFilter foodFilter = RestaurantFoodFilter.all,
    List<String> cuisineIds = const [],
    RestaurantSortOption? sortOption,
    RestaurantPriceOption? priceOption,
    bool favouritesOnly = false,
    String? searchKey,
  });
  Future<Result<OrdersPageEntity>> getOrders({
    required String type,
    required int page,
  });

  Future<Result<InProgressOrderEntity?>> checkInProgressOrder();
}
