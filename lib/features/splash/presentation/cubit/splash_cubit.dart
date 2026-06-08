import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/data/app_local_data_source.dart';
import '../../../../core/errors/failures.dart';
import '../../../../injection_container.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../../../location/domain/repositories/location_repository.dart';
import '../../../main/presentation/cubit/main_cubit.dart';
import 'splash_state.dart';

class SplashCubit extends Cubit<SplashState> {
  SplashCubit(
    this._authRepository,
    this._appLocal,
    this._locationRepository,
  ) : super(const SplashState());

  final AuthRepository _authRepository;
  final AppLocalDataSource _appLocal;
  final LocationRepository _locationRepository;

  Future<void> checkSession() async {
    emit(state.copyWith(status: SplashStatus.loading));

    await _appLocal.ensureDeviceId();

    await Future<void>.delayed(
      const Duration(milliseconds: AppConstants.splashDelayMs),
    );

    final versionResult = await _authRepository.checkVersion();
    if (versionResult.isFailure) {
      final failure = versionResult.failure;
      if (failure is ServerFailure) {
        emit(state.copyWith(status: SplashStatus.navigateToMaintenance));
        return;
      }
      emit(
        state.copyWith(
          status: SplashStatus.navigateToLogin,
          errorMessage: failure?.message,
        ),
      );
      return;
    }

    final version = versionResult.data!;
    if (version.requiresUpdate) {
      emit(
        state.copyWith(
          status: SplashStatus.forceUpdate,
          updateMessage: version.updateMessage,
        ),
      );
      return;
    }

    final session = await _authRepository.getSession();
    if (!session.isSuccess || session.data == null || !session.data!.isLoggedIn) {
      emit(state.copyWith(status: SplashStatus.navigateToLogin));
      return;
    }

    final restore = await _authRepository.restoreSession();
    if (restore.isFailure) {
      final failure = restore.failure;
      if (failure is ServerFailure) {
        emit(state.copyWith(status: SplashStatus.navigateToMaintenance));
        return;
      }
      emit(state.copyWith(status: SplashStatus.navigateToLogin));
      return;
    }

    final restored = restore.data!;
    if (restored.needsRegistration) {
      emit(state.copyWith(status: SplashStatus.navigateToRegister));
      return;
    }

    if (restored.requiresDeviceLocationSetup) {
      emit(state.copyWith(status: SplashStatus.navigateToDeviceLocationSetup));
      return;
    }

    if (restored.defaultLocation != null) {
      await _locationRepository.selectDeliveryLocation(restored.defaultLocation!);
      sl<MainCubit>().loadDeliveryLocation();
      // Android: default_location + GPS → NearBy; without GPS → Main.
      final useNearby = await _locationRepository.canResolveDevicePosition();
      emit(
        state.copyWith(
          status: useNearby
              ? SplashStatus.navigateToNearby
              : SplashStatus.navigateToMain,
        ),
      );
      return;
    }

    final useDeviceSetup = !await _locationRepository.canResolveDevicePosition();
    emit(
      state.copyWith(
        status: useDeviceSetup
            ? SplashStatus.navigateToDeviceLocationSetup
            : SplashStatus.navigateToNearby,
      ),
    );
  }
}
