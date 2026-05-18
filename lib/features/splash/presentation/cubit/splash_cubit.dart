import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import 'splash_state.dart';

class SplashCubit extends Cubit<SplashState> {
  SplashCubit(this._authRepository) : super(const SplashState());

  final AuthRepository _authRepository;

  Future<void> checkSession() async {
    emit(state.copyWith(status: SplashStatus.loading));

    await Future<void>.delayed(
      const Duration(milliseconds: AppConstants.splashDelayMs),
    );

    final result = await _authRepository.getSession();

    if (result.isSuccess && result.data!.isLoggedIn) {
      // Android: splash GPS → NearByLocationActivity (animated finder).
      emit(state.copyWith(status: SplashStatus.navigateToNearby));
    } else if (result.isFailure) {
      emit(state.copyWith(status: SplashStatus.navigateToLogin));
    } else {
      emit(state.copyWith(status: SplashStatus.navigateToLogin));
    }
  }
}
