import '../../../../core/utils/result.dart';
import '../entities/menu_entity.dart';
import '../entities/restaurant_detail_entities.dart';
import '../../../catalog/domain/enums/restaurant_food_filter.dart';

abstract class RestaurantRepository {
  Future<Result<RestaurantDetailEntity>> getRestaurantDetail({
    required String seoUrl,
  });

  Future<Result<List<StoreBannerEntity>>> getStoreBanners({
    required String seoUrl,
  });

  Future<Result<List<MenuCategoryEntity>>> getMenu({
    required String seoUrl,
    RestaurantFoodFilter foodFilter = RestaurantFoodFilter.all,
  });

  Future<Result<CartSummaryEntity>> getCartSummary();

  Future<Result<CartMutationResult>> addToCart({
    required String restaurantId,
    required String foodItemId,
    String? optionId,
    List<String> addonIds = const [],
  });

  Future<Result<CartMutationResult>> updateCartQuantity({
    required String tempCartItemId,
    required int quantity,
  });

  Future<Result<void>> removeFromCart({required String tempCartItemId});

  Future<Result<void>> clearCart();

  Future<Result<void>> toggleFavourite({required String seoUrl});
}
