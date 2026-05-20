import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/navigation/categories_navigation.dart';
import '../../../../core/navigation/cuisine_navigation.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_loading_shimmers.dart';
import '../../../../core/widgets/mobile_api_empty_view.dart';
import '../../../../core/widgets/network_image_box.dart';
import '../../../../core/widgets/veg_filter_chip.dart';
import '../../../../injection_container.dart';
import '../../../catalog/domain/entities/cuisine_entity.dart';
import '../../../catalog/domain/enums/restaurant_food_filter.dart';
import '../../../main/presentation/cubit/main_cubit.dart';
import '../../../main/presentation/cubit/main_state.dart';
import '../cubit/home_cubit.dart';
import '../cubit/home_state.dart';
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
            prev.deliveryLocation != null,

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

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        /// LOADING
        if (state.status == HomeStatus.loading && state.restaurants.isEmpty) {
          return Scaffold(
            backgroundColor: const Color(0xFFFFFAF7),
            body: SafeArea(
              child: SingleChildScrollView(
                child: RestaurantListShimmer(itemCount: 8),
              ),
            ),
          );
        }

        /// ERROR
        if (state.status == HomeStatus.failure && state.restaurants.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(state.errorMessage ?? 'Failed to load'),

                const SizedBox(height: 12),

                ElevatedButton(
                  onPressed: () {
                    context.read<HomeCubit>().loadHome();
                  },

                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        return Scaffold(
            backgroundColor: const Color(0xFFFFFAF7),
            body: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFFFFBF8),
                    Color(0xFFFFFBF8),
                    Color(0xFFFFFBF8),
                  ],
                ),
              ),

            child: RefreshIndicator(
              color: AppColors.brand,

              onRefresh: () {
                return context.read<HomeCubit>().refresh();
              },

              child: CustomScrollView(
                controller: _scrollController,

                slivers: [
                  /// SPACE
                  const SliverToBoxAdapter(child: SizedBox(height: 5)),

                  /// OFFER BANNER
                  if (state.notificationMessage != null &&
                      state.notificationMessage!.isNotEmpty)
                    SliverToBoxAdapter(
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),

                        padding: const EdgeInsets.all(10),

                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF66a4eb), Color(0xFFbfcdde)],
                          ),
                          borderRadius: BorderRadius.circular(20),

                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 12,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),

                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),

                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.3),

                                shape: BoxShape.circle,
                              ),

                              child: const Icon(
                                Icons.local_offer,
                                color: AppColors.brand,
                              ),
                            ),

                            const SizedBox(width: 12),

                            Expanded(
                              child: Text(
                                state.notificationMessage!,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,

                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SliverToBoxAdapter(child: SizedBox(height: 5)),

                  ///  COUPON BANNERS
                  if (state.couponBanners.isNotEmpty)
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: 190,

                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,

                          padding: const EdgeInsets.only(left: 16),

                          itemCount: state.couponBanners.length,

                          itemBuilder: (_, i) {
                            final banner = state.couponBanners[i];

                            return Container(
                              width: MediaQuery.of(context).size.width * 0.88,

                              margin: const EdgeInsets.only(right: 14, bottom: 8),

                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(24),

                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.08),

                                    blurRadius: 14,

                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),

                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(24),

                                child: NetworkImageBox(
                                  url: banner.promotionImage,

                                  fit: BoxFit.cover,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                  /// TITLE
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(18, 18, 18, 10),

                      child: Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Categories',
                            //  'What would you like to eat?',
                              style: TextStyle(
                                fontSize: 20,

                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                          GestureDetector(
                            onTap: () {
                              openCategoriesScreen(context);
                            },

                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 4,
                              ),

                              decoration: BoxDecoration(
                                color: AppColors.brand.withOpacity(0.1),

                                borderRadius: BorderRadius.circular(14),
                              ),

                              child: const Row(
                                children: [
                                  Text(
                                    'View all',

                                    style: TextStyle(
                                      color: AppColors.brand,
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),

                                  SizedBox(width: 4),

                                  Icon(
                                    Icons.arrow_forward_ios,

                                    size: 12,

                                    color: AppColors.brand,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  /// CATEGORIES
                  if (state.cuisines.isNotEmpty)
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: 125,

                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,

                          padding: const EdgeInsets.only(left: 16, right: 4),

                          itemCount: state.cuisines.length,

                          itemBuilder: (_, i) {
                            final cuisine = state.cuisines[i];

                            return _CuisineChip(cuisine: cuisine);
                          },
                        ),
                      ),
                    ),

                  /// SLIDER
                  if (state.sliders.isNotEmpty)
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: 180,

                        child: PageView.builder(
                          controller: PageController(viewportFraction: 0.92),

                          itemCount: state.sliders.length,

                          itemBuilder: (_, i) {
                            final slider = state.sliders[i];

                            return Padding(
                              padding: const EdgeInsets.only(
                                right: 10,
                                left: 4,
                                top: 10,
                                bottom: 10,
                              ),

                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(26),

                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.08),

                                      blurRadius: 14,

                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),

                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(26),

                                  child: NetworkImageBox(
                                    url: slider.image,

                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                  /// FILTERS
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 18, 16, 12),

                      child: Row(
                        children: [
                          VegFilterChip(
                            isVeg: true,
                            selected:
                                state.foodFilter == RestaurantFoodFilter.veg,
                            onTap: () {
                              context.read<HomeCubit>().setFoodFilter(
                                state.foodFilter == RestaurantFoodFilter.veg
                                    ? RestaurantFoodFilter.all
                                    : RestaurantFoodFilter.veg,
                              );
                            },
                          ),

                          const SizedBox(width: 10),

                          VegFilterChip(
                            isVeg: false,
                            selected:
                                state.foodFilter == RestaurantFoodFilter.nonVeg,
                            onTap: () {
                              context.read<HomeCubit>().setFoodFilter(
                                state.foodFilter == RestaurantFoodFilter.nonVeg
                                    ? RestaurantFoodFilter.all
                                    : RestaurantFoodFilter.nonVeg,
                              );
                            },
                          ),

                          const Spacer(),

                          Container(
                            padding: const EdgeInsets.all(10),

                            decoration: BoxDecoration(
                              color: AppColors.brandLite.withOpacity(0.9),

                              borderRadius: BorderRadius.circular(14),

                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),

                                  blurRadius: 10,
                                ),
                              ],
                            ),

                            child: const Icon(
                              Icons.tune,
                              size: 17,
                              color: AppColors.brand,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  /// RESTAURANTS
                  if (state.restaurants.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: MobileApiEmptyView(
                        message: state.emptyMessage?.trim().isNotEmpty == true
                            ? state.emptyMessage!.trim()
                            : 'No restaurants found in your area',
                      ),
                    )
                  else
                    SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        return RestaurantCard(
                            restaurant: state.restaurants[index]);
                      }, childCount: state.restaurants.length),
                    ),

                  /// LOAD MORE
                  if (state.isLoadingMore)
                    const SliverToBoxAdapter(
                      child: ListFooterShimmer(),
                    ),

                  const SliverToBoxAdapter(child: SizedBox(height: 30)),
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
  const _CuisineChip({required this.cuisine});

  final CuisineEntity cuisine;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        openCuisineRestaurants(context, cuisine);
      },

      child: Container(
        width: 90,

        margin: const EdgeInsets.only(right: 14),

        child: Column(
          children: [
            /// IMAGE
            Container(
              height: 72,
              width: 72,

              decoration: BoxDecoration(
                shape: BoxShape.circle,

                border: Border.all(
                  color: AppColors.brand.withOpacity(0.15),
                  width: 2,
                ),

                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),

                    blurRadius: 12,

                    offset: const Offset(0, 4),
                  ),
                ],
              ),

              child: ClipOval(
                child: NetworkImageBox(url: cuisine.image, fit: BoxFit.cover),
              ),
            ),

            const SizedBox(height: 10),

            /// NAME
            Text(
              cuisine.name,

              textAlign: TextAlign.center,

              maxLines: 2,

              overflow: TextOverflow.ellipsis,

              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

