import 'package:flutter/material.dart';

import '../../features/catalog/domain/entities/cuisine_entity.dart';
import '../../features/restaurant/presentation/pages/restaurant_list_page.dart';
import '../../injection_container.dart';
import '../data/cuisine_filter_store.dart';

void openCuisineRestaurants(BuildContext context, CuisineEntity cuisine) {
  sl<CuisineFilterStore>().toggleCuisine(cuisine.id);
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => RestaurantListPage(title: cuisine.name),
    ),
  );
}
