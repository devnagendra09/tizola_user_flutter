import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_loading_shimmers.dart';
import '../../../../core/widgets/mobile_api_empty_view.dart';
import '../../../../injection_container.dart';
import '../../../home/presentation/widgets/restaurant_card.dart';
import '../../../restaurant/presentation/cubit/restaurant_list_cubit.dart';
import '../../../restaurant/presentation/cubit/restaurant_list_state.dart';

/// Dish search results (Android `SearchResultFragment` + `restaurants/mobile` + `search_key`).
class SearchResultsPage extends StatelessWidget {
  const SearchResultsPage({required this.searchKey, super.key});

  final String searchKey;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => RestaurantListCubit(
        sl(),
        sl(),
        searchKey: searchKey,
      )..loadRestaurants(),
      child: _SearchResultsView(searchKey: searchKey),
    );
  }
}

class _SearchResultsView extends StatefulWidget {
  const _SearchResultsView({required this.searchKey});

  final String searchKey;

  @override
  State<_SearchResultsView> createState() => _SearchResultsViewState();
}

class _SearchResultsViewState extends State<_SearchResultsView> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<RestaurantListCubit>().loadMoreRestaurants();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search results'),
        backgroundColor: AppColors.brand,
        foregroundColor: Colors.white,
      ),
      body: BlocBuilder<RestaurantListCubit, RestaurantListState>(
        builder: (context, state) {
          if (state.status == RestaurantListStatus.loading &&
              state.restaurants.isEmpty) {
            return const RestaurantListShimmer(itemCount: 8);
          }

          if (state.status == RestaurantListStatus.failure &&
              state.restaurants.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.errorMessage ?? 'Failed to load'),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () =>
                        context.read<RestaurantListCubit>().loadRestaurants(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Text(
                  '${state.restaurants.length} result(s) found for "${widget.searchKey}"',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
                ),
              ),
              Expanded(
                child: state.restaurants.isEmpty
                    ? MobileApiEmptyView(
                        message: state.emptyMessage ??
                            'Nothing matched with your query. search again..!!',
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        itemCount: state.restaurants.length +
                            (state.isLoadingMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index >= state.restaurants.length) {
                            return const Padding(
                              padding: EdgeInsets.all(16),
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: AppColors.brand,
                                ),
                              ),
                            );
                          }
                          return RestaurantCard(
                            restaurant: state.restaurants[index],
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
