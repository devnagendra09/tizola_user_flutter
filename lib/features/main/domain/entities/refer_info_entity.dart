import 'package:equatable/equatable.dart';

class ReferInfoEntity extends Equatable {
  const ReferInfoEntity({
    this.walletAmount = '0',
    this.totalEarnings = '0',
    this.totalReferrals = '0',
    this.referralCode = '',
    this.description = '',
  });

  final String walletAmount;
  final String totalEarnings;
  final String totalReferrals;
  final String referralCode;
  final String description;

  String get walletDisplay => '$walletAmount/-';
  String get earningsDisplay => '$totalEarnings/-';

  @override
  List<Object?> get props => [
        walletAmount,
        totalEarnings,
        totalReferrals,
        referralCode,
        description,
      ];
}
