import '../../domain/entities/delivery_location_entity.dart';

class DeliveryLocationMapper {
  static DeliveryLocationEntity fromApi(Map<String, dynamic> json) {
    return DeliveryLocationEntity(
      id: json['id']?.toString(),
      latitude: double.tryParse(json['latitude']?.toString() ?? '') ?? 0,
      longitude: double.tryParse(json['longitude']?.toString() ?? '') ?? 0,
      address: json['address']?.toString() ?? '',
      addressType: json['address_type']?.toString() ?? 'Home',
      doorNo: json['door_no']?.toString(),
      landmark: json['landmark']?.toString(),
      addressDescription: json['address_description']?.toString(),
      addressTypeText: json['address_type_text']?.toString(),
      city: json['city']?.toString(),
    );
  }
}
