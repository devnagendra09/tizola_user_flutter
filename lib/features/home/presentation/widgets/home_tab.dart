import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/network_image_box.dart';
import '../../../../injection_container.dart';
import '../../../catalog/domain/enums/restaurant_food_filter.dart';
import '../../../catalog/domain/entities/cuisine_entity.dart';
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
        if (state.status == HomeStatus.loading && state.restaurants.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.brand),
          );
        }

        if (state.status == HomeStatus.failure && state.restaurants.isEmpty) {
          return Center(
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
          );
        }

        return RefreshIndicator(
          color: AppColors.brand,
          onRefresh: () => context.read<HomeCubit>().refresh(),
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              if (state.notificationMessage != null &&
                  state.notificationMessage!.isNotEmpty)
                SliverToBoxAdapter(
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.all(12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.brandLite,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      state.notificationMessage!,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                ),

              if (state.couponBanners.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: SizedBox(
                      height: 140,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: state.couponBanners.length,
                        itemBuilder: (_, i) {
                          final banner = state.couponBanners[i];

                          return Container(
                            width: MediaQuery.of(context).size.width - 30,
                            margin: const EdgeInsets.only(right: 10),
                            child: Center(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: NetworkImageBox(
                                  url: banner.promotionImage,
                                  width: double.infinity,
                                  height: 140,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Categories',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(10),color: AppColors.secondaryBrand.withOpacity(0.5)),
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Text(
                            'View all',

                          //  '${state.openRestaurantCount} open',
                            style: TextStyle(color: Colors.black,fontSize: 9),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (state.cuisines.isNotEmpty)
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: state.cuisines.length,
                      itemBuilder: (_, i) =>
                          _CuisineChip(cuisine: state.cuisines[i]),
                    ),
                  ),
                ),
              if (state.sliders.isNotEmpty)
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 130,
                    child: PageView.builder(
                      itemCount: state.sliders.length,
                      itemBuilder: (_, i) {
                        final slider = state.sliders[i];
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          child: NetworkImageBox(
                            url: slider.image,
                            height: 140,
                            borderRadius: BorderRadius.circular(12),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    children: [
                      _FoodChip(
                        label: 'Veg',
                        selected: state.foodFilter == RestaurantFoodFilter.veg,
                        color: Colors.green,
                        onTap: () => context.read<HomeCubit>().setFoodFilter(
                          state.foodFilter == RestaurantFoodFilter.veg
                              ? RestaurantFoodFilter.all
                              : RestaurantFoodFilter.veg,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _FoodChip(
                        label: 'Non Veg',
                        selected:
                            state.foodFilter == RestaurantFoodFilter.nonVeg,
                        color: Colors.red,
                        onTap: () => context.read<HomeCubit>().setFoodFilter(
                          state.foodFilter == RestaurantFoodFilter.nonVeg
                              ? RestaurantFoodFilter.all
                              : RestaurantFoodFilter.nonVeg,
                        ),
                      ),
                      Spacer(),
                      CircleAvatar(child: Icon(Icons.filter_list,color: Colors.black,size: 15,),backgroundColor:  AppColors.secondaryBrand.withOpacity(0.5),radius: 15,),
                    ],
                  ),
                ),
              ),
              if (!state.isStoreAvailable)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: NetworkImageBox(
                      url: state.cityImage,
                      height: 180,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              if (state.restaurants.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Text(
                      state.emptyMessage ?? 'No restaurants found',
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (index >= state.restaurants.length) return null;
                      return RestaurantCard(
                        restaurant: state.restaurants[index],
                      );
                    },
                    childCount: state.restaurants.length,
                  ),
                ),
              if (state.isLoadingMore)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(
                      child: CircularProgressIndicator(color: AppColors.brand),
                    ),
                  ),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
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
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Column(
        children: [
          ClipOval(
            child: NetworkImageBox(
              url: cuisine.image,
              width: 56,
              height: 56,
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: 72,
            child: Text(
              cuisine.name,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 9,fontFamily: 'Schyler',fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _FoodChip extends StatelessWidget {
  const _FoodChip({
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.15) : Colors.grey.shade100,
          border: Border.all(
            color: selected ? color : Colors.grey.shade300,
          ),
          borderRadius: BorderRadius.circular(13),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: selected ? color : Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(width: 5,),
            if (selected)
              const Icon(
                Icons.highlight_remove,
                size: 16,
                color: AppColors.brand,
              ),
          ],
        ),
      ),
    );
  }
}
