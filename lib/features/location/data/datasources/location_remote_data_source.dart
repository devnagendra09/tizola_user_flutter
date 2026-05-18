import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_response_parser.dart';

abstract class LocationRemoteDataSource {
  Future<void> addCustomerAddress(Map<String, String> body);
  Future<List<Map<String, dynamic>>> fetchCustomerAddresses(String accessToken);
  Future<void> deleteCustomerAddress({
    required String id,
    required String accessToken,
  });
}

class LocationRemoteDataSourceImpl implements LocationRemoteDataSource {
  LocationRemoteDataSourceImpl(this._client);

  final ApiClient _client;

  @override
  Future<List<Map<String, dynamic>>> fetchCustomerAddresses(
    String accessToken,
  ) async {
    final response = await _client.post('customer/addresses', {
      'access_token': accessToken,
    });
    final json = ApiResponseParser.decodeMap(response.body);
    if (!ApiResponseParser.isValid(json)) {
      return [];
    }
    final list = json['data'] as List<dynamic>? ?? [];
    return list.map((e) => e as Map<String, dynamic>).toList();
  }

  @override
  Future<void> deleteCustomerAddress({
    required String id,
    required String accessToken,
  }) async {
    final response = await _client.post('customer/addresses/delete', {
      'id': id,
      'access_token': accessToken,
    });
    final json = ApiResponseParser.decodeMap(response.body);
    if (!ApiResponseParser.isValid(json)) {
      throw Exception(ApiResponseParser.message(json, 'Could not delete address'));
    }
  }

  @override
  Future<void> addCustomerAddress(Map<String, String> body) async {
    final response =
        await _client.post('customer/addresses/add', body);
    final json = ApiResponseParser.decodeMap(response.body);
    if (!ApiResponseParser.isValid(json)) {
      throw Exception(ApiResponseParser.message(json, 'Could not save address'));
    }
  }
}
