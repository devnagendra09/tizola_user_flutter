import '../network/api_client.dart';
import '../network/api_params_builder.dart';
import '../network/api_response_parser.dart';

/// Android `MainActivity.updateFirebaseNotificationToken`.
class PushRemoteDataSource {
  PushRemoteDataSource(this._client, this._paramsBuilder);

  final ApiClient _client;
  final ApiParamsBuilder _paramsBuilder;

  Future<void> updatePushNotificationToken(String pushKey) async {
    final params = _paramsBuilder.baseParams();
    params['push_notification_key'] = pushKey;
    final response = await _client.post(
      'customer/update_push_notification_token',
      params,
    );
    final json = ApiResponseParser.decodeMap(response.body);
    if (!ApiResponseParser.isValid(json)) {
      return;
    }
  }
}
