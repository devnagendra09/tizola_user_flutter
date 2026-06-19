import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/data/restaurant_filter_store.dart';
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
import 'home_filter_sheet.dart';
import 'home_promo_carousel.dart';
import 'home_top_hero.dart';
import 'home_service_highlights.dart';
import 'restaurant_card.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    sl<HomeCubit>().loadHomeIfNeeded();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocListener<MainCubit, MainState>(
      listenWhen: (prev, curr) =>
          prev.deliveryLocation != curr.deliveryLocation &&
          curr.deliveryLocation != null,
      listener: (context, state) {
        final home = context.read<HomeCubit>();
        home.invalidateCache().then((_) => home.loadHome(force: true));
      },
      child: const _HomeView(),
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
          return Scaffold(
            backgroundColor: const Color(0xFFFAFAFA),
            body: SafeArea(
              top: false,
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: HomeTopHero(
                      location: mainState.deliveryLocation,
                      onLocationTap: () => _openChangeLocation(context),
                      cartItemCount: mainState.cartItemCount,
                    ),
                  ),
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(0, 8, 0, 24),
                      child: RestaurantListShimmer(itemCount: 6),
                    ),
                  ),
                ],
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
                    onPressed: () =>
                        context.read<HomeCubit>().loadHome(force: true),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: const Color(0xFFFAFAFA),
          body: Stack(
            children: [
              RefreshIndicator(
                color: AppColors.brand,
                onRefresh: () => context.read<HomeCubit>().refresh(),
                child: CustomScrollView(
                  controller: _scrollController,
                  slivers: [
                    SliverToBoxAdapter(
                      child: HomeTopHero(
                        location: mainState.deliveryLocation,
                        onLocationTap: () => _openChangeLocation(context),
                        cartItemCount: mainState.cartItemCount,
                      ),
                    ),
                    if (state.notificationMessage != null &&
                        state.notificationMessage!.isNotEmpty)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 2),
                          child: Material(
                            color: AppColors.brand.withAlpha(80),
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.all(9),
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
                                        fontSize: 12,
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
                      child: Transform.translate(
                        offset: const Offset(0, -12),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: HomeCouponBannerCarousel(
                            banners: state.couponBanners,
                          ),
                        ),
                      ),
                    ),
                    if (state.cuisines.isNotEmpty) ...[
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                          child: Row(
                            children: [
                              const Expanded(
                                child: Text(
                                  'Categories',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
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
                            itemBuilder: (_, i) => _CuisineChip(
                              cuisine: state.cuisines[i],
                              index: i,
                            ),
                          ),
                        ),
                      ),
                    ],
                    SliverToBoxAdapter(
                      child: HomeSliderCarousel(sliders: state.sliders),
                    ),
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.only(top: 5, bottom: 5),
                        child: HomeServiceHighlights(),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 2,top: 2),
                        child: HomeFilterChipsRow(
                          foodFilter: state.foodFilter,
                          hasActiveFilters: state.hasRestaurantFilters,
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
                          onFilterTap: () async {
                            final applied = await showHomeFilterSheet(
                              context,
                              store: sl<RestaurantFilterStore>(),
                              cuisines: state.cuisines,
                            );
                            if (!context.mounted || !applied) return;
                            await context
                                .read<HomeCubit>()
                                .applyStoredFilters();
                          },
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(16, 4, 16, 5),
                        child: Text(
                          'Recommended for you',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    if (state.isReloadingRestaurants)
                      const SliverToBoxAdapter(
                        child: RestaurantListShimmer(itemCount: 4),
                      )
                    else if (state.restaurants.isEmpty)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: MobileApiEmptyView(
                          assetPath: AppAssets.noRestaurantFound,
                          imageType: 'png',
                          message:
                          state.emptyMessage?.trim().isNotEmpty == true
                              ?
                          state.emptyMessage!.trim()
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
              if (state.customerCarePhone?.trim().isNotEmpty == true ||
                  state.customerCareWhatsapp?.trim().isNotEmpty == true)
                Positioned(
                  right: 16,
                  bottom: 24,
                  child: SafeArea(
                    top: false,
                    child: HomeSupportFloatingButtons(
                      phone: state.customerCarePhone,
                      whatsApp: state.customerCareWhatsapp,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class HomeSupportFloatingButtons extends StatelessWidget {
  const HomeSupportFloatingButtons({super.key, this.phone, this.whatsApp});

  final String? phone;
  final String? whatsApp;

  Future<void> _launchCall(BuildContext context) async {
    final trimmedPhone = phone?.trim();
    if (trimmedPhone == null || trimmedPhone.isEmpty) return;

    final uri = Uri.parse('tel:$trimmedPhone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
      return;
    }

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Unable to open call support')),
    );
  }

  Future<void> _launchWhatsApp(BuildContext context) async {
    final trimmedWhatsApp = whatsApp?.trim();
    if (trimmedWhatsApp == null || trimmedWhatsApp.isEmpty) return;

    final digits = trimmedWhatsApp.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return;

    final uri = Uri.parse('https://wa.me/$digits');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      return;
    }

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Unable to open WhatsApp support')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (whatsApp?.trim().isNotEmpty == true)
          _SupportFloatingButton(
            animationStyle: _SupportAnimationStyle.chat,
            icon: Icons.chat,
            backgroundColor: const Color(0xFF25D366),
            tooltip: 'Chat support',
            onTap: () => _launchWhatsApp(context),
          ),
        if (whatsApp?.trim().isNotEmpty == true && phone?.trim().isNotEmpty == true)
          const SizedBox(height: 12),
        if (phone?.trim().isNotEmpty == true)
          _SupportFloatingButton(
            animationStyle: _SupportAnimationStyle.call,
            icon: Icons.call,
            backgroundColor: AppColors.brand,
            tooltip: 'Call support',
            onTap: () => _launchCall(context),
          ),
      ],
    );
  }
}

enum _SupportAnimationStyle { call, chat }

class _SupportFloatingButton extends StatefulWidget {
  const _SupportFloatingButton({
    required this.animationStyle,
    required this.icon,
    required this.backgroundColor,
    required this.tooltip,
    required this.onTap,
  });

  final _SupportAnimationStyle animationStyle;
  final IconData icon;
  final Color backgroundColor;
  final String tooltip;
  final VoidCallback onTap;

  @override
  State<_SupportFloatingButton> createState() => _SupportFloatingButtonState();
}

class _SupportFloatingButtonState extends State<_SupportFloatingButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: Duration(
      milliseconds: widget.animationStyle == _SupportAnimationStyle.call
          ? 1000
          : 1300,
    ),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final animationValue = Curves.easeInOut.transform(_controller.value);
        final pulseScale = 1 + (animationValue * 0.22);
        final buttonScale = 1 + (animationValue * 0.05);
        final iconRotation =
            widget.animationStyle == _SupportAnimationStyle.call
            ? (animationValue - 0.5) * 0.18
            : 0.0;
        final iconOffsetY = widget.animationStyle == _SupportAnimationStyle.chat
            ? -2 * animationValue
            : 0.0;

        return Tooltip(
          message: widget.tooltip,
          child: SizedBox(
            width: 40,
            height: 40,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Transform.scale(
                  scale: pulseScale,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: widget.backgroundColor.withValues(alpha: 0.16),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Transform.scale(
                  scale: buttonScale,
                  child: Material(
                    color: widget.backgroundColor,
                    elevation: 10,
                    shadowColor: Colors.black.withValues(alpha: 0.18),
                    shape: const CircleBorder(),
                    child: InkWell(
                      onTap: widget.onTap,
                      customBorder: const CircleBorder(),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Transform.translate(
                          offset: Offset(0, iconOffsetY),
                          child: Transform.rotate(
                            angle: iconRotation,
                            child: Icon(
                              widget.icon,
                              color: Colors.white,
                              size: 15,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
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
    Color(0xFF66BB6A),
    Color(0xFFFF9800),
    Color(0xFF4CAF50),
    Color(0xFF2196F3),
    Color(0xFF9C27B0),
    Color(0xFFFFC107),
  ];

  @override
  Widget build(BuildContext context) {
    final bg = _bgColors[index % _bgColors.length];

    final gradientColors = [
      Color.lerp(bg, Colors.white, 0.70)!,
      Color.lerp(bg, Colors.white, 0.88)!,
      Colors.white,
    ];

    return GestureDetector(
      onTap: () => openCuisineRestaurants(context, cuisine),
      child: SizedBox(
        width: 80,
        child: Column(
          children: [
            /// CATEGORY CARD
            Container(
              height: 60,
              width: 60,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: gradientColors,
                ),

                borderRadius: BorderRadius.circular(20),

                border: Border.all(color: bg.withValues(alpha: 0.15)),

                boxShadow: [
                  BoxShadow(
                    color: bg.withValues(alpha: 0.18),
                    blurRadius: 5,
                    offset: const Offset(1, 2),
                  ),
                ],
              ),

              child: ClipOval(
                //   borderRadius: BorderRadius.circular(14),
                child: NetworkImageBox(url: cuisine.image, fit: BoxFit.cover),
              ),
            ),

            const SizedBox(height: 8),

            /// TITLE
            Text(
              cuisine.name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
