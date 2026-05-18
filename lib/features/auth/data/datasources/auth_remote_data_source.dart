import 'dart:convert';

import '../../../../core/errors/failures.dart';
import '../../../../core/network/api_client.dart';
import '../models/user_model.dart';

class OtpSendResponse {
  const OtpSendResponse({required this.success, this.message});
  final bool success;
  final String? message;
}

class OtpVerifyResponse {
  const OtpVerifyResponse({
    required this.success,
    this.message,
    this.type,
    this.user,
    this.accessToken,
    this.mobile,
  });

  final bool success;
  final String? message;
  final String? type;
  final UserModel? user;
  final String? accessToken;
  final String? mobile;
}

abstract class AuthRemoteDataSource {
  Future<OtpSendResponse> sendOtp({
    required String mobile,
    required String countryId,
  });

  Future<OtpVerifyResponse> verifyOtp({
    required String mobile,
    required String otp,
    required String countryId,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<OtpSendResponse> sendOtp({
    required String mobile,
    required String countryId,
  }) async {
    try {
      final response = await _apiClient.post('login_with_mobile', {
        'mobile': mobile,
        'country_id': countryId,
      });
      return _parseSendResponse(response.body);
    } catch (_) {
      throw const NetworkFailure();
    }
  }

  @override
  Future<OtpVerifyResponse> verifyOtp({
    required String mobile,
    required String otp,
    required String countryId,
  }) async {
    try {
      final response = await _apiClient.post('login_with_mobile/verify_otp', {
        'mobile': mobile,
        'otp': otp,
        'country_id': countryId,
      });
      return _parseVerifyResponse(response.body, mobile);
    } catch (_) {
      throw const NetworkFailure();
    }
  }

  OtpSendResponse _parseSendResponse(String body) {
    final json = _decode(body);
    final errCode = json['err_code']?.toString() ?? '';
    if (errCode.toLowerCase() == 'valid') {
      return const OtpSendResponse(success: true);
    }
    return OtpSendResponse(
      success: false,
      message: json['message']?.toString() ?? 'Something went wrong',
    );
  }

  OtpVerifyResponse _parseVerifyResponse(String body, String mobile) {
    final json = _decode(body);
    final errCode = json['err_code']?.toString() ?? '';
    if (errCode.toLowerCase() != 'valid') {
      return OtpVerifyResponse(
        success: false,
        message: json['message']?.toString() ?? 'Invalid OTP',
      );
    }

    final type = json['type']?.toString() ?? '';
    if (type.toLowerCase() == 'details_not_found') {
      return OtpVerifyResponse(
        success: true,
        type: type,
        accessToken: json['access_token']?.toString(),
        mobile: json['mobile']?.toString() ?? mobile,
      );
    }

    if (type.toLowerCase() == 'details_found') {
      final details = json['user_details'] as Map<String, dynamic>?;
      if (details != null) {
        return OtpVerifyResponse(
          success: true,
          type: type,
          user: UserModel.fromJson(details),
        );
      }
    }

    return OtpVerifyResponse(success: true, type: type);
  }

  Map<String, dynamic> _decode(String body) {
    try {
      return jsonDecode(body) as Map<String, dynamic>;
    } catch (_) {
      throw const NetworkFailure();
    }
  }
}
