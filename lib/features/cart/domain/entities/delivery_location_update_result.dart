import 'package:equatable/equatable.dart';

/// `cart/update_delivery_location` — Android treats `err_code: invalid` as out-of-zone.
class DeliveryLocationUpdateResult extends Equatable {
  const DeliveryLocationUpdateResult({
    required this.accepted,
    this.message,
  });

  final bool accepted;
  final String? message;

  @override
  List<Object?> get props => [accepted, message];
}
