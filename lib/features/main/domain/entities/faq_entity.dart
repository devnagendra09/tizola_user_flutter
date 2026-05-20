import 'package:equatable/equatable.dart';

class FaqEntity extends Equatable {
  const FaqEntity({
    required this.question,
    required this.answer,
  });

  final String question;
  final String answer;

  @override
  List<Object?> get props => [question, answer];
}
