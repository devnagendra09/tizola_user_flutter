import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/delivery_location_entity.dart';
import '../../domain/repositories/location_repository.dart';
import 'location_info_state.dart';

class LocationInfoCubit extends Cubit<LocationInfoState> {
  LocationInfoCubit(this._repository) : super(const LocationInfoState());

  final LocationRepository _repository;

  Future<void> load() async {
    emit(state.copyWith(status: LocationInfoStatus.loading));

    final addressesResult = await _repository.fetchSavedAddresses();
    final current = _repository.savedDeliveryLocation;

    DeliveryLocationEntity? draft = current;
    var addressType = current?.addressType ?? 'Home';
    var showOther = addressType == 'Other';
    var showEdit = current?.id != null;

    emit(
      state.copyWith(
        status: LocationInfoStatus.loaded,
        savedAddresses: addressesResult.data ?? [],
        draft: draft,
        addressType: addressType,
        showOtherLabel: showOther,
        showEditButton: showEdit,
        clearMessage: true,
      ),
    );
  }

  void applyDraft(DeliveryLocationEntity location) {
    emit(
      state.copyWith(
        draft: location,
        addressType: location.addressType,
        showOtherLabel: location.addressType == 'Other',
        showEditButton: location.id != null,
        clearMessage: true,
      ),
    );
  }

  void setAddressType(String type) {
    emit(
      state.copyWith(
        addressType: type,
        showOtherLabel: type == 'Other',
      ),
    );
  }

  void prepareNewAddress() {
    final draft = state.draft;
    emit(
      state.copyWith(
        draft: DeliveryLocationEntity(
          latitude: draft?.latitude ?? 0,
          longitude: draft?.longitude ?? 0,
          address: draft?.address ?? '',
          addressType: state.addressType,
          city: draft?.city,
        ),
        showEditButton: false,
        clearMessage: true,
      ),
    );
  }

  Future<void> useCurrentLocation() async {
    emit(state.copyWith(status: LocationInfoStatus.loading, clearMessage: true));
    final result = await _repository.resolveCurrentLocation();
    if (result.isSuccess) {
      final loc = result.data!.copyWith(
        addressType: 'Current Location',
        id: null,
      );
      emit(
        state.copyWith(
          status: LocationInfoStatus.loaded,
          draft: loc,
          addressType: loc.addressType,
          showEditButton: false,
        ),
      );
    } else {
      emit(
        state.copyWith(
          status: LocationInfoStatus.loaded,
          errorMessage: result.failure?.message,
        ),
      );
    }
  }

  Future<bool> selectSavedAddress(DeliveryLocationEntity location) async {
    final result = await _repository.selectDeliveryLocation(location);
    return result.isSuccess;
  }

  Future<bool> saveAddress({
    required String doorNo,
    required String landmark,
    required String addressDescription,
    required String addressType,
    String? addressTypeText,
    bool isNew = false,
  }) async {
    final draft = state.draft;
    if (draft == null || draft.address.isEmpty) {
      emit(state.copyWith(message: 'Please search for a location'));
      return false;
    }
    if (landmark.trim().length < 2) {
      emit(state.copyWith(message: 'Please add address / landmark'));
      return false;
    }

    emit(state.copyWith(status: LocationInfoStatus.saving, clearMessage: true));

    final result = await _repository.persistDeliveryLocation(
      latitude: draft.latitude,
      longitude: draft.longitude,
      address: draft.address,
      city: draft.city ?? '—',
      doorNo: doorNo,
      landmark: landmark,
      addressDescription: addressDescription,
      addressType: addressType,
      addressTypeText: addressTypeText,
      id: isNew ? null : draft.id,
    );

    if (result.isSuccess) {
      await load();
      emit(
        state.copyWith(
          status: LocationInfoStatus.loaded,
          message: 'Address saved',
        ),
      );
      return true;
    }

    emit(
      state.copyWith(
        status: LocationInfoStatus.loaded,
        errorMessage: result.failure?.message,
      ),
    );
    return false;
  }

  Future<void> deleteAddress(String id) async {
    emit(state.copyWith(status: LocationInfoStatus.loading));
    final result = await _repository.deleteAddress(id);
    if (result.isSuccess) {
      await load();
    } else {
      emit(
        state.copyWith(
          status: LocationInfoStatus.loaded,
          errorMessage: result.failure?.message,
        ),
      );
    }
  }
}
