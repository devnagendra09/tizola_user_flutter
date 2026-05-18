import 'package:equatable/equatable.dart';

class DeliveryLocationEntity extends Equatable {
  const DeliveryLocationEntity({
    required this.latitude,
    required this.longitude,
    required this.address,
    this.addressType = 'Current Location',
    this.doorNo,
    this.landmark,
    this.addressDescription,
    this.addressTypeText,
    this.city,
    this.id,
  });

  final String? id;
  final double latitude;
  final double longitude;
  final String address;
  final String addressType;
  final String? doorNo;
  final String? landmark;
  final String? addressDescription;
  final String? addressTypeText;
  final String? city;

  String get locationTitle => '$addressType : $address';

  String get locationSubtitle {
    final parts = [
      if (doorNo != null && doorNo!.trim().isNotEmpty) doorNo!.trim(),
      if (landmark != null && landmark!.trim().isNotEmpty) landmark!.trim(),
      if (addressDescription != null && addressDescription!.trim().isNotEmpty)
        addressDescription!.trim(),
    ];
    return parts.join(' ');
  }

  DeliveryLocationEntity copyWith({
    String? id,
    double? latitude,
    double? longitude,
    String? address,
    String? addressType,
    String? doorNo,
    String? landmark,
    String? addressDescription,
    String? addressTypeText,
    String? city,
  }) {
    return DeliveryLocationEntity(
      id: id ?? this.id,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      addressType: addressType ?? this.addressType,
      doorNo: doorNo ?? this.doorNo,
      landmark: landmark ?? this.landmark,
      addressDescription: addressDescription ?? this.addressDescription,
      addressTypeText: addressTypeText ?? this.addressTypeText,
      city: city ?? this.city,
    );
  }

  @override
  List<Object?> get props => [
        id,
        latitude,
        longitude,
        address,
        addressType,
        doorNo,
        landmark,
        addressDescription,
        addressTypeText,
        city,
      ];
}
