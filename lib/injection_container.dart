import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/data/app_local_data_source.dart';
import 'core/locale/app_locale_notifier.dart';
import 'core/maps/directions_service.dart';
import 'core/deeplink/deep_link_service.dart';
import 'core/deeplink/deep_link_store.dart';
import 'core/data/cuisine_filter_store.dart';
import 'core/data/restaurant_filter_store.dart';
import 'core/network/api_client.dart';
import 'core/network/api_params_builder.dart';
import 'core/network/dio_factory.dart';
import 'core/push/push_notification_service.dart';
import 'core/push/push_remote_data_source.dart';
import 'features/auth/data/datasources/auth_local_data_source.dart';
import 'features/auth/data/datasources/auth_remote_data_source.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/presentation/cubit/login/login_cubit.dart';
import 'features/auth/presentation/cubit/otp/otp_cubit.dart';
import 'features/auth/presentation/cubit/register/register_cubit.dart';
import 'features/catalog/data/datasources/catalog_remote_data_source.dart';
import 'features/catalog/data/repositories/catalog_repository_impl.dart';
import 'features/catalog/domain/repositories/catalog_repository.dart';
import 'features/cart/data/datasources/cart_remote_data_source.dart';
import 'features/cart/data/repositories/cart_repository_impl.dart';
import 'features/cart/domain/repositories/cart_repository.dart';
import 'features/cart/presentation/cubit/cart_cubit.dart';
import 'features/category/presentation/cubit/category_cubit.dart';
import 'features/home/data/datasources/home_remote_data_source.dart';
import 'features/home/data/repositories/home_repository_impl.dart';
import 'features/home/domain/repositories/home_repository.dart';
import 'features/home/presentation/cubit/home_cubit.dart';
import 'features/location/data/datasources/google_places_remote_data_source.dart';
import 'features/location/data/datasources/location_remote_data_source.dart';
import 'features/location/data/repositories/location_repository_impl.dart';
import 'features/location/domain/repositories/location_repository.dart';
import 'features/location/presentation/cubit/location_info_cubit.dart';
import 'features/location/presentation/cubit/location_onboarding_cubit.dart';
import 'features/location/presentation/cubit/nearby_location_cubit.dart';
import 'features/main/presentation/cubit/account/account_cubit.dart';
import 'features/main/presentation/cubit/main_cubit.dart';
import 'features/orders/data/datasources/orders_remote_data_source.dart';
import 'features/orders/data/repositories/orders_repository_impl.dart';
import 'features/orders/domain/repositories/orders_repository.dart';
import 'features/orders/presentation/cubit/orders_cubit.dart';
import 'features/orders/presentation/cubit/service_order_cubit.dart';
import 'features/restaurant/data/datasources/restaurant_remote_data_source.dart';
import 'features/restaurant/data/repositories/restaurant_repository_impl.dart';
import 'features/restaurant/domain/repositories/restaurant_repository.dart';
import 'features/restaurant/presentation/cubit/restaurant_detail_cubit.dart';
import 'features/restaurant/presentation/cubit/restaurant_list_cubit.dart';
import 'features/search/presentation/cubit/search_cubit.dart';
import 'features/splash/presentation/cubit/splash_cubit.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // --- External ---
  final prefs = await SharedPreferences.getInstance();
  sl.registerSingleton<SharedPreferences>(prefs);
  sl.registerLazySingleton<Dio>(DioFactory.create);

  // --- Core ---
  sl.registerLazySingleton<ApiClient>(() => ApiClient(sl()));
  sl.registerLazySingleton<DirectionsService>(() => DirectionsService());
  sl.registerLazySingleton<AppLocaleNotifier>(
    () => AppLocaleNotifier(sl()),
  );
  sl.registerLazySingleton<AppLocalDataSource>(
    () => AppLocalDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<ApiParamsBuilder>(
    () => ApiParamsBuilder(sl(), sl()),
  );
  sl.registerLazySingleton<CuisineFilterStore>(() => CuisineFilterStore());
  sl.registerLazySingleton<RestaurantFilterStore>(
    () => RestaurantFilterStore(sl()),
  );
  sl.registerLazySingleton<DeepLinkStore>(() => DeepLinkStore());
  sl.registerLazySingleton<DeepLinkService>(
    () => DeepLinkService(sl()),
  );
  sl.registerLazySingleton<PushRemoteDataSource>(
    () => PushRemoteDataSource(sl(), sl()),
  );
  sl.registerLazySingleton<PushNotificationService>(
    () => PushNotificationService(sl(), sl()),
  );

  // --- Auth data ---
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl(), sl(), sl()),
  );

  // --- Location ---
  sl.registerLazySingleton<LocationRemoteDataSource>(
    () => LocationRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<GooglePlacesRemoteDataSource>(
    GooglePlacesRemoteDataSource.new,
  );
  sl.registerLazySingleton<LocationRepository>(
    () => LocationRepositoryImpl(sl(), sl(), sl(), sl()),
  );

  // --- Catalog / Home data ---
  sl.registerLazySingleton<CatalogRemoteDataSource>(
    () => CatalogRemoteDataSourceImpl(sl(), sl(), sl()),
  );
  sl.registerLazySingleton<CatalogRepository>(
    () => CatalogRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<HomeRemoteDataSource>(
    () => HomeRemoteDataSourceImpl(sl(), sl()),
  );
  sl.registerLazySingleton<HomeRepository>(
    () => HomeRepositoryImpl(sl()),
  );

  // --- Restaurant detail / menu ---
  sl.registerLazySingleton<RestaurantRemoteDataSource>(
    () => RestaurantRemoteDataSourceImpl(sl(), sl(), sl()),
  );
  sl.registerLazySingleton<RestaurantRepository>(
    () => RestaurantRepositoryImpl(sl()),
  );

  // --- Cart ---
  sl.registerLazySingleton<CartRemoteDataSource>(
    () => CartRemoteDataSourceImpl(sl(), sl(), sl()),
  );
  sl.registerLazySingleton<CartRepository>(
    () => CartRepositoryImpl(sl()),
  );

  // --- Orders detail / tracking ---
  sl.registerLazySingleton<OrdersRemoteDataSource>(
    () => OrdersRemoteDataSourceImpl(sl(), sl()),
  );
  sl.registerLazySingleton<OrdersRepository>(
    () => OrdersRepositoryImpl(sl()),
  );

  // --- Cubits ---
  sl.registerFactory(() => SplashCubit(sl(), sl(), sl()));
  sl.registerFactory(() => LoginCubit(sl()));
  sl.registerFactory(() => RegisterCubit(sl()));
  sl.registerFactoryParam<OtpCubit, String, void>(
    (mobile, _) => OtpCubit(sl(), mobile: mobile),
  );
  sl.registerLazySingleton(() => MainCubit(sl(), sl(), sl(), sl()));
  sl.registerFactory(() => NearbyLocationCubit(sl()));
  sl.registerFactory(() => AccountCubit(sl()));
  sl.registerFactory(() => HomeCubit(sl(), sl(), sl()));
  sl.registerFactory(() => SearchCubit(sl()));
  sl.registerFactory(() => CategoryCubit(sl()));
  sl.registerFactory(() => CartCubit(sl(), sl()));
  sl.registerFactory(() => RestaurantListCubit(sl(), sl()));
  sl.registerFactoryParam<RestaurantDetailCubit, String, String?>(
    (seoUrl, fallbackName) => RestaurantDetailCubit(
      sl(),
      seoUrl: seoUrl,
      fallbackName: fallbackName,
    ),
  );
  sl.registerFactory(() => OrdersCubit(sl()));
  sl.registerFactory(() => ServiceOrderCubit(sl()));
  sl.registerFactory(() => LocationOnboardingCubit(sl()));
  sl.registerFactory(() => LocationInfoCubit(sl()));
}
