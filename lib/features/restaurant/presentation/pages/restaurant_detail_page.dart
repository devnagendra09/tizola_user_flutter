import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/navigation/cart_navigation.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_loading_shimmers.dart';
import '../../../../core/widgets/mobile_api_empty_view.dart';
import '../../../../core/widgets/network_image_box.dart';
import '../../../../core/widgets/veg_filter_chip.dart';
import '../../../../injection_container.dart';
import '../../../catalog/domain/enums/restaurant_food_filter.dart';
import '../../domain/entities/menu_entity.dart';
import '../cubit/restaurant_detail_cubit.dart';
import '../cubit/restaurant_detail_state.dart';
import '../widgets/addons_selection_sheet.dart';
import '../widgets/cart_summary_bar.dart';
import '../widgets/menu_item_tile.dart';
import '../widgets/recommended_dish_card.dart';

///  Bounded height for horizontal recommended [ListView] (see Android `item_food_list_recommened`).
const double _kRecommendedStripHeight = 212;

class RestaurantDetailPage extends StatelessWidget {
  const RestaurantDetailPage({
    super.key,
    required this.seoUrl,
    this.fallbackName,
    this.sharedItemId,
  });

  final String seoUrl;
  final String? fallbackName;

  /// Item id from`https://tizola.in/share/{seoUrl}/{itemId}` (Android `SHARED_ITEM_ID`).
  final String? sharedItemId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<RestaurantDetailCubit>(
        param1: seoUrl,
        param2: fallbackName,
      )..loadInitial(),
      child: _RestaurantDetailView(sharedItemId: sharedItemId),
    );
  }
}

class _RestaurantDetailView extends StatefulWidget {
  const _RestaurantDetailView({this.sharedItemId});

  final String? sharedItemId;

  @override
  State<_RestaurantDetailView> createState() => _RestaurantDetailViewState();
}

class _RestaurantDetailViewState extends State<_RestaurantDetailView> {
  final _categoryScrollController = ScrollController();
  final _menuScrollController = ScrollController();
  final _sectionKeys = <GlobalKey>[];
  final _itemKeys = <String, GlobalKey>{};
  bool _sharedItemScrollDone = false;

  @override
  void dispose() {
    _categoryScrollController.dispose();
    _menuScrollController.dispose();
    super.dispose();
  }

  Future<void> _openCartAndSync(BuildContext context) async {
    await openCart(context);
    if (!context.mounted) return;
    await context.read<RestaurantDetailCubit>().syncAfterCartScreen();
  }

  void _syncSectionKeys(int count) {
    while (_sectionKeys.length < count) {
      _sectionKeys.add(GlobalKey());
    }
    if (_sectionKeys.length > count) {
      _sectionKeys.removeRange(count, _sectionKeys.length);
    }
  }

  void _scrollToCategory(int index) {
    context.read<RestaurantDetailCubit>().selectCategory(index);
    if (index < _sectionKeys.length) {
      final target = _sectionKeys[index].currentContext;
      if (target != null) {
        Scrollable.ensureVisible(
          target,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOutCubic,
          alignment: 0.05,
        );
      }
    }
  }

  void _maybeScrollToSharedItem(RestaurantDetailState state) {
    final itemId = widget.sharedItemId;
    if (itemId == null || itemId.isEmpty || _sharedItemScrollDone) return;
    if (state.status != RestaurantDetailStatus.loaded) return;
    if (state.displayCategories.isEmpty) return;

    for (var i = 0; i < state.displayCategories.length; i++) {
      final category = state.displayCategories[i];
      final match = category.items.any((item) => item.id == itemId);
      if (!match) continue;

      _sharedItemScrollDone = true;
      context.read<RestaurantDetailCubit>().selectCategory(i);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final target = _itemKeys[itemId]?.currentContext;
        if (target != null) {
          Scrollable.ensureVisible(
            target,
            duration: const Duration(milliseconds: 450),
            curve: Curves.easeInOutCubic,
            alignment: 0.1,
          );
        }
      });
      return;
    }
  }

  Future<void> _onAddItem(BuildContext context, MenuItemEntity item) async {
    final cubit = context.read<RestaurantDetailCubit>();
    if (item.hasCustomizations) {
      final selection = await showAddonsSelectionSheet(context, item);
      if (!context.mounted || selection == null) return;
      await cubit.addItem(
        item,
        optionId: selection.optionId,
        addonIds: selection.addonIds,
      );
      return;
    }
    await cubit.addItem(item);
  }

  Future<void> _onIncrementItem(
      BuildContext context,
      MenuItemEntity item,
      ) async {
    final cubit = context.read<RestaurantDetailCubit>();
    if (item.hasCustomizations) {
      final action = await showCustomizationRepeatDialog(context, item.name);
      if (!context.mounted || action == null) return;
      if (action == CustomizationRepeatAction.cancel) return;
      if (action == CustomizationRepeatAction.repeat) {
        await cubit.incrementItem(item);
        return;
      }
      final selection = await showAddonsSelectionSheet(context, item);
      if (!context.mounted || selection == null) return;
      await cubit.addItem(
        item,
        optionId: selection.optionId,
        addonIds: selection.addonIds,
      );
      return;
    }
    await cubit.incrementItem(item);
  }

  String _restaurantShareName(RestaurantDetailState state) =>
      state.detail?.name ?? state.fallbackName ?? state.title;

  MenuItemEntity? _menuItemById(RestaurantDetailState state, String itemId) {
    for (final category in state.displayCategories) {
      for (final item in category.items) {
        if (item.id == itemId) return item;
      }
    }
    return null;
  }

  void _openRecommendedViewAll(
      BuildContext context,
      RestaurantDetailState state ,
      List<MenuItemEntity> items,
      ) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final height = MediaQuery.sizeOf(sheetContext).height * 0.75;
        return Container(
          height: height,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(20, 16, 16, 8),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Recommended Dishes',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        onPressed: () => Navigator.pop(sheetContext),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, thickness: 1),
              Expanded(
                child: BlocBuilder<RestaurantDetailCubit, RestaurantDetailState>(
                  builder: (context, liveState) {
                    return ListView.builder(
                      padding: const EdgeInsets.only(bottom: 24),
                      itemCount: items.length,
                      itemBuilder: (_, i) {
                        final item =
                            _menuItemById(liveState, items[i].id) ?? items[i];
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: MenuItemTile(
                            item: item,
                            isPending: liveState.isItemCartPending(item.id),
                            onAdd: () => _onAddItem(context, item),
                            onIncrement: () => _onIncrementItem(context, item),
                            onDecrement: () => context
                                .read<RestaurantDetailCubit>()
                                .decrementItem(item),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _buildMenuSlivers(
      BuildContext context,
      RestaurantDetailState state,
      ) {
    final cats = state.displayCategories;
    final slivers = <Widget>[];
    var usedRecommendedStrip = false;

    for (var i = 0; i < cats.length; i++) {
      final cat = cats[i];
      if (cat.id == 'recommended' &&
          cat.items.isNotEmpty &&
          !usedRecommendedStrip) {
        usedRecommendedStrip = true;
        slivers.add(
          SliverToBoxAdapter(
            key: _sectionKeys[i],
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              child: _RecommendedSection(
                items: cat.items,
                isItemPending: state.isItemCartPending,
                onViewAll: () =>
                    _openRecommendedViewAll(context, state, cat.items),
                onAdd: (item) => _onAddItem(context, item),
                onIncrement: (item) => _onIncrementItem(context, item),
                onDecrement: (item) =>
                    context.read<RestaurantDetailCubit>().decrementItem(item),
              ),
            ),
          ),
        );
        continue;
      }
      if (cat.id == 'recommended') {
        continue;
      }

      slivers.add(
        SliverToBoxAdapter(
          key: _sectionKeys[i],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                child: Row(
                  children: [
                    Container(
                      width: 4,
                      height: 20,
                      decoration: BoxDecoration(
                        color: AppColors.brand,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      cat.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),
              ),
              ...cat.items.map(
                (item) {
                  final itemKey =
                      _itemKeys.putIfAbsent(item.id, GlobalKey.new);
                  return Padding(
                    key: itemKey,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    child: MenuItemTile(
                      item: item,
                      isPending: state.isItemCartPending(item.id),
                      shareSeoUrl: state.seoUrl,
                      restaurantName: _restaurantShareName(state),
                      onAdd: () => _onAddItem(context, item),
                      onIncrement: () => _onIncrementItem(context, item),
                      onDecrement: () => context
                          .read<RestaurantDetailCubit>()
                          .decrementItem(item),
                    ),
                  );
                },
              ),
              const Divider(height: 1, thickness: 0.5, indent: 16, endIndent: 16),
            ],
          ),
        ),
      );
    }

    slivers.add(const SliverToBoxAdapter(child: SizedBox(height: 32)));
    return slivers;
  }

  Future<void> _showCartConflictDialog(
      BuildContext context,
      String message,
      ) async {
    final cubit = context.read<RestaurantDetailCubit>();
    final action = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Different restaurant'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, 'cancel'),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, 'clear'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.brand,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Clear cart'),
          ),
        ],
      ),
    );

    if (!context.mounted) return;
    cubit.dismissCartConflict();
    if (action == 'clear') {
      await cubit.clearCartAndReload();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RestaurantDetailCubit, RestaurantDetailState>(
      listenWhen: (prev, curr) =>
          prev.cartConflict != curr.cartConflict ||
          prev.errorMessage != curr.errorMessage ||
          prev.status != curr.status ||
          prev.displayCategories != curr.displayCategories,
      listener: (context, state) {
        _maybeScrollToSharedItem(state);
        if (state.cartConflict != null) {
          _showCartConflictDialog(context, state.cartConflict!.message);
        } else if (state.errorMessage != null &&
            state.errorMessage!.isNotEmpty) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              backgroundColor: Colors.red.shade700,
            ),
          );
          context.read<RestaurantDetailCubit>().clearError();
        }
      },
      builder: (context, state) {
        _syncSectionKeys(state.displayCategories.length);
        if (widget.sharedItemId != null &&
            widget.sharedItemId!.isNotEmpty &&
            state.status == RestaurantDetailStatus.loaded) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _maybeScrollToSharedItem(state);
          });
        }

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            elevation: 0,
            title: Text(
              state.title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                letterSpacing: -0.3,
              ),
            ),
            backgroundColor: AppColors.brand,
            foregroundColor: Colors.white,
            centerTitle: false,
            actions: [
              if (state.detail != null)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: state.detail!.isOpen
                          ? Colors.green.shade400
                          : Colors.red.shade400,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          state.detail!.isOpen ? Icons.circle : Icons.cancel,
                          size: 8,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          state.detail!.isOpened ?? 'Closed',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              IconButton(
                onPressed: () =>
                    context.read<RestaurantDetailCubit>().toggleFavourite(),
                icon: Icon(
                  state.detail?.isFavourite == true
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ],
          ),
          body: _buildBody(context, state),
          bottomNavigationBar: CartSummaryBar(
            summary: state.cartSummary,
            isLoading: state.isClearingCart,
            onTap: () => _openCartAndSync(context),
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, RestaurantDetailState state) {
    if (state.status == RestaurantDetailStatus.loading &&
        state.displayCategories.isEmpty) {
      return const RestaurantDetailShimmer();
    }

    if (state.status == RestaurantDetailStatus.failure &&
        state.displayCategories.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.restaurant_menu_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              state.errorMessage ?? 'Failed to load menu',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () =>
                  context.read<RestaurantDetailCubit>().loadInitial(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.brand,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        if (state.banners.isNotEmpty)
          Container(
            height: 120,
            margin: const EdgeInsets.only(top: 12),
            child: PageView.builder(
              itemCount: state.banners.length,
              itemBuilder: (_, i) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: NetworkImageBox(
                    url: state.banners[i].image,
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
        const _RestaurantMenuSearchBar(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              VegFilterChip(
                isVeg: true,
                selected: state.foodFilter == RestaurantFoodFilter.veg,
                onTap: () => context.read<RestaurantDetailCubit>().setFoodFilter(
                  state.foodFilter == RestaurantFoodFilter.veg
                      ? RestaurantFoodFilter.all
                      : RestaurantFoodFilter.veg,
                ),
              ),
              const SizedBox(width: 10),
              VegFilterChip(
                isVeg: false,
                selected: state.foodFilter == RestaurantFoodFilter.nonVeg,
                onTap: () => context.read<RestaurantDetailCubit>().setFoodFilter(
                  state.foodFilter == RestaurantFoodFilter.nonVeg
                      ? RestaurantFoodFilter.all
                      : RestaurantFoodFilter.nonVeg,
                ),
              ),
            ],
          ),
        ),
        if (state.displayCategories.isNotEmpty)
          Container(
            height: 48,
            margin: const EdgeInsets.only(top: 4, bottom: 8),
            child: ListView.builder(
              controller: _categoryScrollController,
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: state.displayCategories.length,
              itemBuilder: (_, index) {
                final category = state.displayCategories[index];
                final selected = state.selectedCategoryIndex == index;
                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: FilterChip(
                    label: Text(category.name),
                    selected: selected,
                    showCheckmark: false,
                    selectedColor: AppColors.brandLite,
                    backgroundColor: Colors.grey.shade100,
                    labelStyle: TextStyle(
                      color: selected ? AppColors.brand : Colors.black87,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                      fontSize: 14,
                    ),
                    shape: StadiumBorder(
                      side: BorderSide(
                        color: selected ? AppColors.brand : Colors.transparent,
                        width: 1,
                      ),
                    ),
                    onSelected: (_) => _scrollToCategory(index),
                  ),
                );
              },
            ),
          ),
        Expanded(
          child: state.displayCategories.isEmpty
              ? const MobileApiEmptyView(
                  message: 'No menu items found',
                )
              : RefreshIndicator(
            color: AppColors.brand,
            onRefresh: () =>
                context.read<RestaurantDetailCubit>().reloadMenu(),
            child: CustomScrollView(
              controller: _menuScrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: _buildMenuSlivers(context, state),
            ),
          ),
        ),
      ],
    );
  }
}

/// Isolated search bar so typing does not rebuild the whole menu body (jank).
/// Clears focus when the query is emptied so the focus ring / border resets.
class _RestaurantMenuSearchBar extends StatefulWidget {
  const _RestaurantMenuSearchBar();

  @override
  State<_RestaurantMenuSearchBar> createState() =>
      _RestaurantMenuSearchBarState();
}

class _RestaurantMenuSearchBarState extends State<_RestaurantMenuSearchBar> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChanged);
    _controller.addListener(_onTextChanged);
  }

  void _onFocusChanged() {
    setState(() {});
  }

  void _onTextChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.removeListener(_onTextChanged);
    _focusNode.removeListener(_onFocusChanged);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  bool get _focused => _focusNode.hasFocus;

  void _applySearch(String value) {
    if (!mounted) return;
    context.read<RestaurantDetailCubit>().setSearchQuery(value);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(_focused ? 20 : 28),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOutCubic,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(_focused ? 20 : 28),
            boxShadow: [
              BoxShadow(
                color: _focused
                    ? AppColors.brand.withValues(alpha: 0.15)
                    : Colors.black.withValues(alpha: 0.06),
                blurRadius: _focused ? 16 : 8,
                offset: Offset(0, _focused ? 4 : 2),
              ),
            ],
            border: Border.all(
              color: _focused
                  ? AppColors.brand.withValues(alpha: 0.25)
                  : Colors.grey.shade200,
              width: _focused ? 1.4 : 1,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              onTapOutside: (_) => _focusNode.unfocus(),
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: 'Search menu...',
                hintStyle: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: _focused ? AppColors.brand : Colors.grey.shade500,
                  size: 20,
                ),
                suffixIcon: _controller.text.isNotEmpty
                    ? GestureDetector(
                        onTap: () {
                          _debounce?.cancel();
                          _controller.clear();
                          _applySearch('');
                          _focusNode.unfocus();
                        },
                        child: Container(
                          margin: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            size: 16,
                            color: Colors.grey,
                          ),
                        ),
                      )
                    : null,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                isDense: true,
              ),
              onChanged: (value) {
                _debounce?.cancel();
                if (value.isEmpty) {
                  _applySearch('');
                  _focusNode.unfocus();
                  return;
                }
                _debounce = Timer(
                  const Duration(milliseconds: 400),
                  () => _applySearch(value),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _RecommendedSection extends StatelessWidget {
  const _RecommendedSection({
    required this.items,
    required this.isItemPending,
    required this.onViewAll,
    required this.onAdd,
    required this.onIncrement,
    required this.onDecrement,
  });

  final List<MenuItemEntity> items;
  final bool Function(String itemId) isItemPending;
  final VoidCallback onViewAll;
  final void Function(MenuItemEntity item) onAdd;
  final void Function(MenuItemEntity item) onIncrement;
  final void Function(MenuItemEntity item) onDecrement;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: AppColors.brand,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Recommended for you',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.3,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: onViewAll,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.brand,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                ),
                child: const Text(
                  'View all',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: _kRecommendedStripHeight,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: items.length,
            separatorBuilder: (_, index) => const SizedBox(width: 12),
            itemBuilder: (_, index) {
              final item = items[index];
              return Align(
                alignment: Alignment.topCenter,
                child: RecommendedDishCard(
                  item: item,
                  isPending: isItemPending(item.id),
                  onAdd: () => onAdd(item),
                  onIncrement: () => onIncrement(item),
                  onDecrement: () => onDecrement(item),
                ),
              );
            },
          ),
        ),
        const Divider(height: 1, thickness: 0.5, indent: 16, endIndent: 16),
      ],
    );
  }
}
