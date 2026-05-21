import 'package:equatable/equatable.dart';

import '../../domain/entities/search_suggestion_entity.dart';

enum SearchStatus { initial, loading, loaded, failure }

class SearchState extends Equatable {
  const SearchState({
    this.status = SearchStatus.initial,
    this.query = '',
    this.suggestions = const [],
    this.errorMessage,
  });

  final SearchStatus status;
  final String query;
  final List<SearchSuggestionEntity> suggestions;
  final String? errorMessage;

  bool get showEmpty =>
      status == SearchStatus.loaded &&
      query.trim().isNotEmpty &&
      suggestions.isEmpty;

  SearchState copyWith({
    SearchStatus? status,
    String? query,
    List<SearchSuggestionEntity>? suggestions,
    String? errorMessage,
    bool clearError = false,
  }) {
    return SearchState(
      status: status ?? this.status,
      query: query ?? this.query,
      suggestions: suggestions ?? this.suggestions,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [status, query, suggestions, errorMessage];
}
