import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../auth/domain/repositories/auth_repository.dart';
import 'account_state.dart';

class AccountCubit extends Cubit<AccountState> {
  AccountCubit(this._repository) : super(const AccountState());

  final AuthRepository _repository;

  Future<void> loadProfile() async {
    final result = await _repository.getSession();
    if (result.isSuccess && result.data!.user != null) {
      emit(
        state.copyWith(
          status: AccountStatus.loaded,
          user: result.data!.user,
        ),
      );
    } else {
      emit(state.copyWith(status: AccountStatus.loaded));
    }
  }

  Future<void> logout() async {
    final result = await _repository.logout();
    if (result.isSuccess) {
      emit(state.copyWith(status: AccountStatus.loggedOut));
    } else {
      emit(
        state.copyWith(
          status: AccountStatus.failure,
          errorMessage: result.failure?.message,
        ),
      );
    }
  }
}
