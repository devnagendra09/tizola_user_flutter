import 'package:flutter/material.dart';

import '../../features/category/presentation/pages/categories_page.dart';

/// Opens the full-screen categories grid (Android [PlainActivity] + [CategoriesFragment]).
void openCategoriesScreen(BuildContext context) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => const CategoriesPage(),
    ),
  );
}
