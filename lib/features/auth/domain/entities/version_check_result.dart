import 'package:equatable/equatable.dart';

class VersionCheckResult extends Equatable {
  const VersionCheckResult({
    this.requiresUpdate = false,
    this.updateMessage,
  });

  final bool requiresUpdate;
  final String? updateMessage;

  @override
  List<Object?> get props => [requiresUpdate, updateMessage];
}
