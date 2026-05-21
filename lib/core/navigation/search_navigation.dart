import 'package:flutter/material.dart';

import '../../features/search/presentation/pages/search_page.dart';
import '../../features/search/presentation/pages/search_results_page.dart';

void openSearchScreen(BuildContext context) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(builder: (_) => const SearchPage()),
  );
}

void openSearchResultsScreen(
  BuildContext context, {
  required String searchKey,
}) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => SearchResultsPage(searchKey: searchKey),
    ),
  );
}
