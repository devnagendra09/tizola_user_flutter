import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/domain/repositories/auth_repository.dart';
import '../../../location/domain/repositories/location_repository.dart';
import 'main_state.dart';

class MainCubit extends Cubit<MainState> {
  MainCubit(this._authRepository, this._locationRepository)
      : super(const MainState()) {
    loadDeliveryLocation();
  }

  final AuthRepository _authRepository;
  final LocationRepository _locationRepository;

  void loadDeliveryLocation() {
    emit(
      state.copyWith(
        deliveryLocation: _locationRepository.savedDeliveryLocation,
      ),
    );
  }

  Future<void> onTabSelected(int index) async {
    if (index == 2 || index == 3) {
      final session = await _authRepository.getSession();
      if (session.isSuccess && session.data!.isLoggedIn) {
        emit(state.copyWith(currentIndex: index, showLoginDialog: false));
      } else {
        emit(state.copyWith(showLoginDialog: true));
      }
      return;
    }
    emit(state.copyWith(currentIndex: index, showLoginDialog: false));
  }

  void dismissLoginDialog() {
    emit(state.copyWith(showLoginDialog: false));
  }
}
