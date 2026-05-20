import 'dart:convert';

import '../../../../core/errors/failures.dart';
import '../../../../core/network/api_client.dart';
import '../../../main/domain/entities/faq_entity.dart';
import '../../../main/domain/entities/refer_info_entity.dart';
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

  Future<String> fetchWalletBalance({required String accessToken});

  Future<ReferInfoEntity> fetchReferInfo({required String accessToken});

  Future<String> updateProfile({
    required String accessToken,
    required String name,
    required String email,
  });

  Future<List<FaqEntity>> fetchFaqs({String? accessToken});

  Future<void> logoutRemote({
    required String accessToken,
    required String sessionCartId,
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

  @override
  Future<String> fetchWalletBalance({required String accessToken}) async {
    final info = await fetchReferInfo(accessToken: accessToken);
    return info.walletDisplay;
  }

  @override
  Future<ReferInfoEntity> fetchReferInfo({required String accessToken}) async {
    try {
      final response = await _apiClient.post('customer/profile/refer_info', {
        'access_token': accessToken,
      });
      final json = _decode(response.body);
      if (json['err_code']?.toString().toLowerCase() != 'valid') {
        return const ReferInfoEntity();
      }
      final data = json['data'] as Map<String, dynamic>? ?? {};
      return ReferInfoEntity(
        walletAmount: data['current_wallet_amount']?.toString() ?? '0',
        totalEarnings: data['total_earnings']?.toString() ?? '0',
        totalReferrals: data['total_referalls']?.toString() ?? '0',
        referralCode: data['referral_code']?.toString() ?? '',
        description: data['description']?.toString() ?? '',
      );
    } catch (_) {
      return const ReferInfoEntity();
    }
  }

  @override
  Future<String> updateProfile({
    required String accessToken,
    required String name,
    required String email,
  }) async {
    final response = await _apiClient.post('customer/profile/update', {
      'access_token': accessToken,
      'customer_name': name,
      'email': email,
    });
    final json = _decode(response.body);
    if (json['err_code']?.toString().toLowerCase() != 'valid') {
      throw ServerFailure(json['message']?.toString() ?? 'Update failed');
    }
    return json['message']?.toString() ?? 'Profile updated';
  }

  @override
  Future<List<FaqEntity>> fetchFaqs({String? accessToken}) async {
    final params = <String, String>{};
    if (accessToken != null && accessToken.isNotEmpty) {
      params['access_token'] = accessToken;
    }
    final response = await _apiClient.post('faqs', params);
    final json = _decode(response.body);
    if (json['err_code']?.toString().toLowerCase() != 'valid') {
      throw ServerFailure(json['message']?.toString() ?? 'Failed to load FAQs');
    }
    final list = json['data'] as List<dynamic>? ?? [];
    return list.map((e) {
      final item = e as Map<String, dynamic>;
      return FaqEntity(
        question: item['question']?.toString() ?? '',
        answer: item['answer']?.toString() ?? '',
      );
    }).toList();
  }

  @override
  Future<void> logoutRemote({
    required String accessToken,
    required String sessionCartId,
  }) async {
    final response = await _apiClient.post('customer/logout', {
      'access_token': accessToken,
      'm_sess_cart_id': sessionCartId,
    });
    final json = _decode(response.body);
    if (json['err_code']?.toString().toLowerCase() != 'valid') {
      throw ServerFailure(json['message']?.toString() ?? 'Logout failed');
    }
  }

  Map<String, dynamic> _decode(String body) {
    try {
      return jsonDecode(body) as Map<String, dynamic>;
    } catch (_) {
      throw const NetworkFailure();
    }
  }
}
