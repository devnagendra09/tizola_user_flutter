import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/repositories/location_repository.dart';
import 'nearby_location_state.dart';

class NearbyLocationCubit extends Cubit<NearbyLocationState> {
  NearbyLocationCubit(this._repository) : super(const NearbyLocationState());

  final LocationRepository _repository;

  Future<void> start() async {
    emit(
      state.copyWith(
        status: NearbyLocationStatus.locating,
        showAddressCard: false,
        errorMessage: null,
      ),
    );

    final result = await _repository.resolveNearbyDeliveryLocation();

    if (result.isFailure) {
      final failure = result.failure;
      if (failure is NoSavedAddressesFailure) {
        await Future<void>.delayed(const Duration(milliseconds: 1000));
        if (isClosed) return;
        emit(
          state.copyWith(
            status: NearbyLocationStatus.navigateToDeviceLocationSetup,
          ),
        );
        return;
      }
      emit(
        state.copyWith(
          status: NearbyLocationStatus.navigateToDeviceLocationSetup,
          errorMessage: failure?.message,
        ),
      );
      return;
    }

    final location = result.data!;
    emit(
      state.copyWith(
        status: NearbyLocationStatus.addressReady,
        location: location,
        showAddressCard: false,
      ),
    );

    // Pin animation phase, then reveal address (Android ~1s delay).
    await Future<void>.delayed(const Duration(milliseconds: 1000));
    if (isClosed) return;

    emit(state.copyWith(showAddressCard: true));

    // Hold address on screen then go to home (Android ~1s after reveal).
    await Future<void>.delayed(const Duration(milliseconds: 2000));
    if (isClosed) return;

    emit(state.copyWith(status: NearbyLocationStatus.navigateToMain));
  }
}
