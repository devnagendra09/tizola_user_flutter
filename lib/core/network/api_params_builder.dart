import '../constants/app_constants.dart';
import '../data/app_local_data_source.dart';
import '../../features/auth/data/datasources/auth_local_data_source.dart';

class ApiParamsBuilder {
  ApiParamsBuilder(this._appLocal, this._authLocal);

  final AppLocalDataSource _appLocal;
  final AuthLocalDataSource _authLocal;

  Map<String, String> baseParams({bool includeSource = true}) {
    final params = <String, String>{};
    if (includeSource) {
      params['source'] = AppConstants.source;
    }
    final token = _authLocal.accessToken;
    if (token != null && token.isNotEmpty) {
      params['access_token'] = token;
    }
    final lat = _appLocal.latitude;
    final lng = _appLocal.longitude;
    if (lat != null && lng != null) {
      params['latitude'] = lat;
      params['longitude'] = lng;
    }
    return params;
  }

  Map<String, String> locationOnly() {
    final params = <String, String>{};
    final lat = _appLocal.latitude;
    final lng = _appLocal.longitude;
    if (lat != null && lng != null) {
      params['latitude'] = lat;
      params['longitude'] = lng;
    }
    return params;
  }
}
