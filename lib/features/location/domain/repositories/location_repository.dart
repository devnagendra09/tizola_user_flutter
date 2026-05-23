import '../../../../core/utils/result.dart';
import '../entities/delivery_location_entity.dart';
import '../entities/place_prediction_entity.dart';

abstract class LocationRepository {
  bool get hasSavedCoordinates;

  DeliveryLocationEntity? get savedDeliveryLocation;

  Future<Result<DeliveryLocationEntity>> resolveNearbyDeliveryLocation();

  Future<Result<List<DeliveryLocationEntity>>> fetchSavedAddresses();

  Future<Result<List<PlacePredictionEntity>>> searchPlacePredictions(
    String query,
  );

  Future<Result<DeliveryLocationEntity>> resolvePlaceDetails(String placeId);

  Future<Result<DeliveryLocationEntity>> resolveCurrentLocation();

  Future<Result<DeliveryLocationEntity>> reverseGeocode({
    required double latitude,
    required double longitude,
  });

  Future<Result<void>> selectDeliveryLocation(DeliveryLocationEntity location);

  Future<Result<void>> persistDeliveryLocation({
    required double latitude,
    required double longitude,
    required String address,
    required String city,
    required String doorNo,
    required String landmark,
    required String addressDescription,
    required String addressType,
    String? addressTypeText,
    String? id,
  });

  Future<Result<void>> deleteAddress(String id);
}
