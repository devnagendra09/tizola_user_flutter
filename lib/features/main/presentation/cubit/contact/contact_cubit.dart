import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../auth/domain/repositories/auth_repository.dart';

enum ContactStatus { initial, loading, success, failure }

class ContactState {
  const ContactState({
    this.status = ContactStatus.initial,
    this.message,
    this.errorMessage,
    this.cleared = false,
  });

  final ContactStatus status;
  final String? message;
  final String? errorMessage;
  final bool cleared;
}

class ContactCubit extends Cubit<ContactState> {
  ContactCubit(this._repository) : super(const ContactState());

  final AuthRepository _repository;

  Future<void> submit({
    required String name,
    required String email,
    required String mobile,
    required String message,
    required String deviceInfo,
  }) async {
    if (name.trim().isEmpty) {
      emit(const ContactState(errorMessage: 'Enter your name'));
      return;
    }
    if (email.trim().isEmpty) {
      emit(const ContactState(errorMessage: 'Enter your email id'));
      return;
    }
    if (mobile.trim().isEmpty) {
      emit(const ContactState(errorMessage: 'Enter your mobile'));
      return;
    }
    if (message.trim().isEmpty) {
      emit(const ContactState(errorMessage: 'Enter your message'));
      return;
    }

    emit(const ContactState(status: ContactStatus.loading));

    final result = await _repository.submitContactUs(
      name: name.trim(),
      email: email.trim(),
      mobile: mobile.trim(),
      message: message.trim(),
      deviceInfo: deviceInfo,
    );

    if (result.isSuccess) {
      emit(
        const ContactState(
          status: ContactStatus.success,
          message: 'Thank you. We will get back to you soon.',
          cleared: true,
        ),
      );
      emit(const ContactState());
    } else {
      emit(
        ContactState(
          status: ContactStatus.failure,
          errorMessage: result.failure?.message ?? 'Submit failed',
        ),
      );
    }
  }
}
