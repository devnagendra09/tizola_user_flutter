import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/navigation/categories_navigation.dart';
import '../../../../core/navigation/cuisine_navigation.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_loading_shimmers.dart';
import '../../../../core/widgets/mobile_api_empty_view.dart';
import '../../../../core/widgets/network_image_box.dart';
import '../../../../injection_container.dart';
import '../../../catalog/domain/entities/cuisine_entity.dart';
import '../../../catalog/domain/enums/restaurant_food_filter.dart';
import '../../../location/presentation/pages/location_info_page.dart';
import '../../../main/presentation/cubit/main_cubit.dart';
import '../../../main/presentation/cubit/main_state.dart';
import '../cubit/home_cubit.dart';
import '../cubit/home_state.dart';
import 'home_filter_chips_row.dart';
import 'home_promo_carousel.dart';
import 'home_screen_header.dart';
import 'home_search_bar.dart';
import 'home_service_highlights.dart';
import 'restaurant_card.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<HomeCubit>()..loadHome(),
      child: BlocListener<MainCubit, MainState>(
        listenWhen: (prev, curr) =>
            prev.deliveryLocation != curr.deliveryLocation &&
            curr.deliveryLocation != null,
        listener: (context, state) {
          context.read<HomeCubit>().loadHome();
        },
        child: const _HomeView(),
      ),
    );
  }
}

class _HomeView extends StatefulWidget {
  const _HomeView();

  @override
  State<_HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<_HomeView> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<HomeCubit>().loadMoreRestaurants();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _openChangeLocation(BuildContext context) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(builder: (_) => const LocationInfoPage()),
    );
    if (context.mounted && changed == true) {
      context.read<MainCubit>().loadDeliveryLocation();
    }
  }

  @override
  Widget build(BuildContext context) {
    final mainState = context.watch<MainCubit>().state;

    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        if (state.status == HomeStatus.loading && state.restaurants.isEmpty) {
          return const Scaffold(
            backgroundColor: Colors.white,
            body: SafeArea(
              child: SingleChildScrollView(
                child: RestaurantListShimmer(itemCount: 6),
              ),
            ),
          );
        }

        if (state.status == HomeStatus.failure && state.restaurants.isEmpty) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.errorMessage ?? 'Failed to load'),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => context.read<HomeCubit>().loadHome(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: const Color(0xFFFAFAFA),
          body: SafeArea(
            child: RefreshIndicator(
              color: AppColors.brand,
              onRefresh: () => context.read<HomeCubit>().refresh(),
              child: CustomScrollView(
                controller: _scrollController,
                slivers: [
                  SliverToBoxAdapter(
                    child: HomeScreenHeader(
                      location: mainState.deliveryLocation,
                      onLocationTap: () => _openChangeLocation(context),
                    ),
                  ),
                  const SliverToBoxAdapter(child: HomeSearchBar()),
                  if (state.notificationMessage != null &&
                      state.notificationMessage!.isNotEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                        child: Material(
                          color: AppColors.brandLite,
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.campaign_outlined,
                                  color: AppColors.brand,
                                  size: 22,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    state.notificationMessage!,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  SliverToBoxAdapter(
                    child: HomePromoCarousel(
                      sliders: state.sliders,
                      couponBanners: state.couponBanners,
                    ),
                  ),
                  if (state.cuisines.isNotEmpty) ...[
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
                        child: Row(
                          children: [
                            const Expanded(
                              child: Text(
                                'Categories',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => openCategoriesScreen(context),
                              child: Text(
                                'View all',
                                style: TextStyle(
                                  color: AppColors.brand,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: 108,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.only(left: 16, right: 8),
                          itemCount: state.cuisines.length,
                          itemBuilder: (_, i) =>
                              _CuisineChip(cuisine: state.cuisines[i], index: i),
                        ),
                      ),
                    ),
                  ],
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.only(top: 12, bottom: 8),
                      child: HomeServiceHighlights(),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: HomeFilterChipsRow(
                        foodFilter: state.foodFilter,
                        onAllTap: () => context
                            .read<HomeCubit>()
                            .setFoodFilter(RestaurantFoodFilter.all),
                        onVegTap: () {
                          context.read<HomeCubit>().setFoodFilter(
                            state.foodFilter == RestaurantFoodFilter.veg
                                ? RestaurantFoodFilter.all
                                : RestaurantFoodFilter.veg,
                          );
                        },
                        onNonVegTap: () {
                          context.read<HomeCubit>().setFoodFilter(
                            state.foodFilter == RestaurantFoodFilter.nonVeg
                                ? RestaurantFoodFilter.all
                                : RestaurantFoodFilter.nonVeg,
                          );
                        },
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(16, 4, 16, 10),
                      child: Text(
                        'Recommended for you',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  if (state.restaurants.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: MobileApiEmptyView(
                        message: state.emptyMessage?.trim().isNotEmpty == true
                            ? state.emptyMessage!.trim()
                            : 'No restaurants found in your area ',
                      ),
                    )
                  else
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => RestaurantCard(
                          restaurant: state.restaurants[index],
                        ),
                        childCount: state.restaurants.length,
                      ),
                    ),
                  if (state.isLoadingMore)
                    const SliverToBoxAdapter(child: ListFooterShimmer()),
                  const SliverToBoxAdapter(child: SizedBox(height: 24)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CuisineChip extends StatelessWidget {
  const _CuisineChip({required this.cuisine, required this.index});

  final CuisineEntity cuisine;
  final int index;

  static const _bgColors = [
    Color(0xFFFFE4E6),
    Color(0xFFFFF3E0),
    Color(0xFFE8F5E9),
    Color(0xFFE3F2FD),
    Color(0xFFF3E5F5),
    Color(0xFFFFF9C4),
  ];

  @override
  Widget build(BuildContext context) {
    final bg = _bgColors[index % _bgColors.length];

    return GestureDetector(
      onTap: () => openCuisineRestaurants(context, cuisine),
      child: Container(
        width: 76,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          children: [
            Container(
              height: 64,
              width: 64,
              decoration: BoxDecoration(
                color: bg,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipOval(
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: NetworkImageBox(url: cuisine.image, fit: BoxFit.cover),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              cuisine.name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
