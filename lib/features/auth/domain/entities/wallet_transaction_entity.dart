import 'package:equatable/equatable.dart';

class WalletTransactionEntity extends Equatable {
  const WalletTransactionEntity({
    this.id = '',
    this.type = '',
    this.amount = '',
    this.comment = '',
    this.transactionId = '',
    this.createdAt = '',
  });

  final String id;
  final String type;
  final String amount;
  final String comment;
  final String transactionId;
  final String createdAt;

  bool get isCredit => type.toLowerCase() == 'credit';
  bool get isDebit => type.toLowerCase() == 'debit';

  factory WalletTransactionEntity.fromJson(Map<String, dynamic> json) {
    return WalletTransactionEntity(
      id: json['id']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      amount: json['amount']?.toString() ?? '',
      comment: json['comment']?.toString() ?? '',
      transactionId: json['transaction_id']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
    );
  }

  @override
  List<Object?> get props => [
        id,
        type,
        amount,
        comment,
        transactionId,
        createdAt,
      ];
}

class WalletTransactionsResult extends Equatable {
  const WalletTransactionsResult({
    this.transactions = const [],
    this.walletAmount = '0',
    this.totalPages = 1,
    this.emptyMessage = '',
  });

  final List<WalletTransactionEntity> transactions;
  final String walletAmount;
  final int totalPages;
  final String emptyMessage;

  String get walletDisplay => '$walletAmount/-';

  @override
  List<Object?> get props => [
        transactions,
        walletAmount,
        totalPages,
        emptyMessage,
      ];
}
