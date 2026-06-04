import 'package:equatable/equatable.dart';

class CountryEntity extends Equatable {
  const CountryEntity({
    required this.id,
    required this.name,
    required this.dialCode,
    this.flagUrl,
    this.currency,
    this.symbol = '₹',
  });

  final String id;
  final String name;
  final String dialCode;
  final String? flagUrl;
  final String? currency;
  final String symbol;

  @override
  List<Object?> get props => [id, name, dialCode, flagUrl, currency, symbol];
}
