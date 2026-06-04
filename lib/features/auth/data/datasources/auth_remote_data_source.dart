import 'dart:convert';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/api_client.dart';
import '../../../location/domain/entities/delivery_location_entity.dart';
import '../../../main/domain/entities/faq_entity.dart';
import '../../../main/domain/entities/refer_info_entity.dart';
import '../../domain/entities/country_entity.dart';
import '../../domain/entities/pending_feedback_entity.dart';
import '../../domain/entities/session_restore_result.dart';
import '../../domain/entities/version_check_result.dart';
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

  /// Android `SplashActivity.validateApplication`.
  Future<VersionCheckResult> checkVersion({
    required String buildNumber,
    required String source,
  });

  /// Android splash `sendData` — `login_with_mobile` with `auto_login=1`.
  Future<SessionRestoreResult> restoreSession({required String mobile});

  Future<String> completeRegistration({
    required String accessToken,
    required String countryId,
    required String name,
    required String email,
    String? referralCode,
  });

  Future<void> submitContactUs({
    required String accessToken,
    required String name,
    required String email,
    required String mobile,
    required String message,
    required String deviceInfo,
  });

  Future<PendingFeedbackEntity?> fetchPendingFeedback({
    required String accessToken,
  });

  Future<void> skipOrderFeedback({
    required String accessToken,
    required String refId,
  });

  Future<List<CountryEntity>> fetchCountries();
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

  @override
  Future<VersionCheckResult> checkVersion({
    required String buildNumber,
    required String source,
  }) async {
    try {
      final response = await _apiClient.post('customer/check_version', {
        'current_version': buildNumber,
        'source': source,
      });
      if (response.statusCode >= 500) {
        throw const ServerFailure();
      }
      final json = _decode(response.body);
      // API: err_code "valid" = update required; "invalid" = already on latest (Android SplashActivity).
      final errCode = json['err_code']?.toString().toLowerCase() ?? '';
      if (errCode == 'valid') {
        return VersionCheckResult(
          requiresUpdate: true,
          updateMessage: json['message']?.toString(),
        );
      }
      return const VersionCheckResult();
    } on ServerFailure {
      rethrow;
    } catch (_) {
      throw const NetworkFailure();
    }
  }

  @override
  Future<SessionRestoreResult> restoreSession({required String mobile}) async {
    try {
      final response = await _apiClient.post('login_with_mobile', {
        'mobile': mobile,
        'auto_login': '1',
      });
      if (response.statusCode >= 500) {
        throw const ServerFailure();
      }
      return _parseSessionRestore(response.body, mobile);
    } on ServerFailure {
      rethrow;
    } catch (_) {
      throw const NetworkFailure();
    }
  }

  SessionRestoreResult _parseSessionRestore(String body, String mobile) {
    final json = _decode(body);
    if (json['err_code']?.toString().toLowerCase() != 'valid') {
      throw ServerFailure(json['message']?.toString() ?? 'Session expired');
    }

    final userDetails = json['user_details'] as Map<String, dynamic>?;
    if (userDetails == null) {
      throw const ServerFailure('Invalid session response');
    }

    final user = UserModel.fromJson(userDetails).toEntity();
    final name = user.name?.trim() ?? '';
    final email = user.email?.trim() ?? '';
    final needsRegistration = name.isEmpty && email.isEmpty;

    DeliveryLocationEntity? defaultLocation;
    if (userDetails.containsKey('default_location')) {
      final loc = userDetails['default_location'] as Map<String, dynamic>?;
      if (loc != null) {
        defaultLocation = _parseDefaultLocation(loc);
      }
    }

    return SessionRestoreResult(
      user: user.phoneNumber != null
          ? user
          : user.copyWith(phoneNumber: mobile),
      needsRegistration: needsRegistration,
      defaultLocation: defaultLocation,
    );
  }

  DeliveryLocationEntity? _parseDefaultLocation(Map<String, dynamic> loc) {
    final lat = double.tryParse(loc['latitude']?.toString() ?? '');
    final lng = double.tryParse(loc['longitude']?.toString() ?? '');
    final address = loc['address']?.toString() ?? '';
    if (lat == null || lng == null || address.isEmpty) return null;
    return DeliveryLocationEntity(
      id: loc['id']?.toString(),
      latitude: lat,
      longitude: lng,
      address: address,
      addressType:
          loc['address_type_text']?.toString() ??
          loc['address_type']?.toString() ??
          AppConstants.currentLocationLabel,
      doorNo: loc['door_no']?.toString(),
      landmark: loc['landmark']?.toString(),
      addressDescription: loc['address_description']?.toString(),
    );
  }

  @override
  Future<String> completeRegistration({
    required String accessToken,
    required String countryId,
    required String name,
    required String email,
    String? referralCode,
  }) async {
    final params = <String, String>{
      'access_token': accessToken,
      'customer_name': name,
      'email': email,
      'country_id': countryId,
    };
    if (referralCode != null && referralCode.isNotEmpty) {
      params['referral_code'] = referralCode;
    }
    final response = await _apiClient.post('customer/profile/update', params);
    final json = _decode(response.body);
    if (json['err_code']?.toString().toLowerCase() != 'valid') {
      throw ServerFailure(json['message']?.toString() ?? 'Registration failed');
    }
    return json['message']?.toString() ?? 'Profile updated';
  }

  @override
  Future<void> submitContactUs({
    required String accessToken,
    required String name,
    required String email,
    required String mobile,
    required String message,
    required String deviceInfo,
  }) async {
    final response = await _apiClient.post('contact_us/submit_data', {
      'access_token': accessToken,
      'name': name,
      'email': email,
      'mobile': mobile,
      'message': message,
      'device_info': deviceInfo,
    });
    final json = _decode(response.body);
    if (json['err_code']?.toString().toLowerCase() != 'valid') {
      throw ServerFailure(json['message']?.toString() ?? 'Submit failed');
    }
  }

  @override
  Future<PendingFeedbackEntity?> fetchPendingFeedback({
    required String accessToken,
  }) async {
    try {
      final response = await _apiClient.post(
        'customer/check_for_feedback_action',
        {'access_token': accessToken},
      );
      if (response.statusCode >= 500) {
        throw const ServerFailure();
      }
      final json = _decode(response.body);
      if (json['err_code']?.toString().toLowerCase() != 'valid') {
        return null;
      }
      final data = json['data'] as Map<String, dynamic>?;
      if (data == null) return null;
      final refId = data['ref_id']?.toString() ?? '';
      if (refId.isEmpty) return null;
      return PendingFeedbackEntity(
        refId: refId,
        restaurantName: data['restaurant_name']?.toString(),
        deliveryPersonName: data['delivery_person_name']?.toString(),
        deliveryPersonPhone: data['delivery_person_contact_number']?.toString(),
        displayImage: data['display_image']?.toString(),
        deliveryBoyImage: data['delivery_boy_image']?.toString(),
        selfPickAccepted: data['self_pick_accepted']?.toString(),
      );
    } on ServerFailure {
      rethrow;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> skipOrderFeedback({
    required String accessToken,
    required String refId,
  }) async {
    await _apiClient.post('customer/mark_as_feedback_skipped', {
      'access_token': accessToken,
      'ref_id': refId,
    });
  }

  @override
  Future<List<CountryEntity>> fetchCountries() async {
    try {
      final response = await _apiClient.post('countries', {});
      final json = _decode(response.body);
      if (json['err_code']?.toString().toLowerCase() != 'valid') {
        return [];
      }
      final list = json['data'] as List<dynamic>? ?? [];
      return list.map((entry) {
        final map = entry as Map<String, dynamic>;
        var dial = map['counry_code']?.toString() ?? '';
        if (dial.isNotEmpty && !dial.startsWith('+')) {
          dial = '+$dial';
        }
        return CountryEntity(
          id: map['id']?.toString() ?? '',
          name: map['name']?.toString() ?? '',
          dialCode: dial.isEmpty ? AppConstants.defaultDialCode : dial,
          flagUrl: map['flag_url']?.toString(),
          currency: map['currency']?.toString(),
          symbol: '₹',
        );
      }).toList();
    } catch (_) {
      return [];
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
