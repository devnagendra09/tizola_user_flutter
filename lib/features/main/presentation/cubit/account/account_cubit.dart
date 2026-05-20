import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../../auth/domain/repositories/auth_repository.dart';
import 'account_state.dart';

class AccountCubit extends Cubit<AccountState> {
  AccountCubit(this._repository) : super(const AccountState());

  final AuthRepository _repository;

  Future<void> loadProfile() async {
    emit(state.copyWith(status: AccountStatus.loading, clearError: true));

    final sessionResult = await _repository.getSession();
    final walletResult = await _repository.fetchWalletBalance();
    final version = await _loadAppVersion();

    final user = sessionResult.data?.user;
    emit(
      state.copyWith(
        status: AccountStatus.loaded,
        user: user,
        walletBalance: walletResult.data ?? '0/-',
        appVersion: version,
        clearError: true,
      ),
    );
  }

  Future<String> _loadAppVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      return 'App version ${info.version} (${info.buildNumber})';
    } catch (_) {
      return 'App version 1.3.3 (33)';
    }
  }

  Future<void> logout() async {
    emit(state.copyWith(status: AccountStatus.loggingOut, clearError: true));
    final result = await _repository.logout();
    if (result.isFailure) {
      emit(
        state.copyWith(
          status: AccountStatus.loaded,
          errorMessage: result.failure?.message,
        ),
      );
      return;
    }
    emit(state.copyWith(status: AccountStatus.loggedOut));
  }
}
