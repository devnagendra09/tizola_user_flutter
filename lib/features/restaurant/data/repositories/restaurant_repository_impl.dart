import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/menu_entity.dart';
import '../../domain/entities/restaurant_about_entity.dart';
import '../../domain/entities/restaurant_detail_entities.dart';
import '../../domain/entities/restaurant_review_entity.dart';
import '../../domain/repositories/restaurant_repository.dart';
import '../datasources/restaurant_remote_data_source.dart';
import '../../../catalog/domain/enums/restaurant_food_filter.dart';

class RestaurantRepositoryImpl implements RestaurantRepository {
  RestaurantRepositoryImpl(this._remote);

  final RestaurantRemoteDataSource _remote;

  @override
  Future<Result<RestaurantDetailEntity>> getRestaurantDetail({
    required String seoUrl,
  }) async {
    try {
      final data = await _remote.getRestaurantDetail(seoUrl: seoUrl);
      return Result.success(data);
    } on Failure catch (e) {
      return Result.failure(e);
    } catch (_) {
      return Result.failure(const NetworkFailure());
    }
  }

  @override
  Future<Result<List<StoreBannerEntity>>> getStoreBanners({
    required String seoUrl,
  }) async {
    try {
      final data = await _remote.getStoreBanners(seoUrl: seoUrl);
      return Result.success(data);
    } on Failure catch (e) {
      return Result.failure(e);
    } catch (_) {
      return Result.failure(const NetworkFailure());
    }
  }

  @override
  Future<Result<List<MenuCategoryEntity>>> getMenu({
    required String seoUrl,
    RestaurantFoodFilter foodFilter = RestaurantFoodFilter.all,
  }) async {
    try {
      final data = await _remote.getMenu(
        seoUrl: seoUrl,
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
  Future<Result<CartSummaryEntity>> getCartSummary() async {
    try {
      final data = await _remote.getCartSummary();
      return Result.success(data);
    } on Failure catch (e) {
      return Result.failure(e);
    } catch (_) {
      return Result.failure(const NetworkFailure());
    }
  }

  @override
  Future<Result<CartMutationResult>> addToCart({
    required String restaurantId,
    required String foodItemId,
    String? optionId,
    List<String> addonIds = const [],
  }) async {
    try {
      final data = await _remote.addToCart(
        restaurantId: restaurantId,
        foodItemId: foodItemId,
        optionId: optionId,
        addonIds: addonIds,
      );
      return Result.success(data);
    } on Failure catch (e) {
      return Result.failure(e);
    } catch (_) {
      return Result.failure(const NetworkFailure());
    }
  }

  @override
  Future<Result<CartMutationResult>> updateCartQuantity({
    required String tempCartItemId,
    required int quantity,
  }) async {
    try {
      final data = await _remote.updateCartQuantity(
        tempCartItemId: tempCartItemId,
        quantity: quantity,
      );
      return Result.success(data);
    } on Failure catch (e) {
      return Result.failure(e);
    } catch (_) {
      return Result.failure(const NetworkFailure());
    }
  }

  @override
  Future<Result<void>> removeFromCart({required String tempCartItemId}) async {
    try {
      await _remote.removeFromCart(tempCartItemId: tempCartItemId);
      return Result.success(null);
    } on Failure catch (e) {
      return Result.failure(e);
    } catch (_) {
      return Result.failure(const NetworkFailure());
    }
  }

  @override
  Future<Result<void>> clearCart() async {
    try {
      await _remote.clearCart();
      return Result.success(null);
    } on Failure catch (e) {
      return Result.failure(e);
    } catch (_) {
      return Result.failure(const NetworkFailure());
    }
  }

  @override
  Future<Result<void>> toggleFavourite({required String seoUrl}) async {
    try {
      await _remote.toggleFavourite(seoUrl: seoUrl);
      return Result.success(null);
    } on Failure catch (e) {
      return Result.failure(e);
    } catch (_) {
      return Result.failure(const NetworkFailure());
    }
  }

  @override
  Future<Result<RestaurantAboutEntity>> getAbout({required String seoUrl}) async {
    try {
      final data = await _remote.getAbout(seoUrl: seoUrl);
      return Result.success(data);
    } on Failure catch (e) {
      return Result.failure(e);
    } catch (_) {
      return Result.failure(const NetworkFailure());
    }
  }

  @override
  Future<Result<({List<RestaurantReviewEntity> items, int totalPages})>>
      getReviews({
    required String seoUrl,
    required int page,
  }) async {
    try {
      final data = await _remote.getReviews(seoUrl: seoUrl, page: page);
      return Result.success(data);
    } on Failure catch (e) {
      return Result.failure(e);
    } catch (_) {
      return Result.failure(const NetworkFailure());
    }
  }
}
