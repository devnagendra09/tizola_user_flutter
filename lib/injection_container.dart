import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/data/app_local_data_source.dart';
import 'core/network/api_client.dart';
import 'core/network/api_params_builder.dart';
import 'core/network/dio_factory.dart';
import 'features/auth/data/datasources/auth_local_data_source.dart';
import 'features/auth/data/datasources/auth_remote_data_source.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/presentation/cubit/login/login_cubit.dart';
import 'features/auth/presentation/cubit/otp/otp_cubit.dart';
import 'features/catalog/data/datasources/catalog_remote_data_source.dart';
import 'features/catalog/data/repositories/catalog_repository_impl.dart';
import 'features/catalog/domain/repositories/catalog_repository.dart';
import 'features/category/presentation/cubit/category_cubit.dart';
import 'features/home/data/datasources/home_remote_data_source.dart';
import 'features/home/data/repositories/home_repository_impl.dart';
import 'features/home/domain/repositories/home_repository.dart';
import 'features/home/presentation/cubit/home_cubit.dart';
import 'features/location/data/datasources/location_remote_data_source.dart';
import 'features/location/data/repositories/location_repository_impl.dart';
import 'features/location/domain/repositories/location_repository.dart';
import 'features/location/presentation/cubit/location_info_cubit.dart';
import 'features/location/presentation/cubit/location_onboarding_cubit.dart';
import 'features/location/presentation/cubit/nearby_location_cubit.dart';
import 'features/main/presentation/cubit/account/account_cubit.dart';
import 'features/main/presentation/cubit/main_cubit.dart';
import 'features/orders/presentation/cubit/orders_cubit.dart';
import 'features/splash/presentation/cubit/splash_cubit.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // --- External ---
  final prefs = await SharedPreferences.getInstance();
  sl.registerSingleton<SharedPreferences>(prefs);
  sl.registerLazySingleton<Dio>(DioFactory.create);

  // --- Core ---
  sl.registerLazySingleton<ApiClient>(() => ApiClient(sl()));
  sl.registerLazySingleton<AppLocalDataSource>(
    () => AppLocalDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<ApiParamsBuilder>(
    () => ApiParamsBuilder(sl(), sl()),
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
  sl.registerLazySingleton<LocationRepository>(
    () => LocationRepositoryImpl(sl(), sl(), sl()),
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

  // --- Cubits ---
  sl.registerFactory(() => SplashCubit(sl()));
  sl.registerFactory(() => LoginCubit(sl()));
  sl.registerFactoryParam<OtpCubit, String, void>(
    (mobile, _) => OtpCubit(sl(), mobile: mobile),
  );
  sl.registerFactory(() => MainCubit(sl(), sl()));
  sl.registerFactory(() => NearbyLocationCubit(sl()));
  sl.registerFactory(() => AccountCubit(sl()));
  sl.registerFactory(() => HomeCubit(sl(), sl()));
  sl.registerFactory(() => CategoryCubit(sl()));
  sl.registerFactory(() => OrdersCubit(sl()));
  sl.registerFactory(() => LocationOnboardingCubit(sl()));
  sl.registerFactory(() => LocationInfoCubit(sl()));
}
