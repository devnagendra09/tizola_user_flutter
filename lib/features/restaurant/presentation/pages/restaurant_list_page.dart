import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_loading_shimmers.dart';
import '../../../../core/widgets/mobile_api_empty_view.dart';
import '../../../../injection_container.dart';
import '../../../home/presentation/widgets/restaurant_card.dart';
import '../cubit/restaurant_list_cubit.dart';
import '../cubit/restaurant_list_state.dart';

class RestaurantListPage extends StatelessWidget {
  const RestaurantListPage({
    super.key,
    required this.title,
    this.favouritesOnly = false,
  });

  final String title;
  final bool favouritesOnly;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => RestaurantListCubit(
        sl(),
        sl(),
        favouritesOnly: favouritesOnly,
      )..loadRestaurants(),
      child: _RestaurantListView(title: title),
    );
  }
}

class _RestaurantListView extends StatefulWidget {
  const _RestaurantListView({required this.title});

  final String title;

  @override
  State<_RestaurantListView> createState() => _RestaurantListViewState();
}

class _RestaurantListViewState extends State<_RestaurantListView> {
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
        title: Text(widget.title),
        backgroundColor: AppColors.brand,
        foregroundColor: Colors.white,
        elevation: 0,
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
                  Text(state.errorMessage ?? 'Failed to load restaurants'),
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

          if (state.restaurants.isEmpty) {
            return MobileApiEmptyView(
              message: state.emptyMessage?.trim().isNotEmpty == true
                  ? state.emptyMessage!.trim()
                  : 'No restaurants found',
            );
          }

          return RefreshIndicator(
            color: AppColors.brand,
            onRefresh: () =>
                context.read<RestaurantListCubit>().loadRestaurants(),
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount:
                  state.restaurants.length + (state.isLoadingMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index >= state.restaurants.length) {
                  return const ListFooterShimmer();
                }
                return RestaurantCard(restaurant: state.restaurants[index]);
              },
            ),
          );
        },
      ),
    );
  }
}
