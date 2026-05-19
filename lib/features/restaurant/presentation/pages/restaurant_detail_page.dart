 import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/navigation/cart_navigation.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/network_image_box.dart';
import '../../../../injection_container.dart';
import '../../../catalog/domain/enums/restaurant_food_filter.dart';
import '../../domain/entities/menu_entity.dart';
import '../cubit/restaurant_detail_cubit.dart';
import '../cubit/restaurant_detail_state.dart';
import '../widgets/addons_selection_sheet.dart';
import '../widgets/cart_summary_bar.dart';
import '../widgets/menu_item_tile.dart';
import '../widgets/recommended_dish_card.dart';

class RestaurantDetailPage extends StatelessWidget {
  const RestaurantDetailPage({
    super.key,
    required this.seoUrl,
    this.fallbackName,
  });

  final String seoUrl;
  final String? fallbackName;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<RestaurantDetailCubit>(
        param1: seoUrl,
        param2: fallbackName,
      )..loadInitial(),
      child: const _RestaurantDetailView(),
    );
  }
}

class _RestaurantDetailView extends StatefulWidget {
  const _RestaurantDetailView();

  @override
  State<_RestaurantDetailView> createState() => _RestaurantDetailViewState();
}

class _RestaurantDetailViewState extends State<_RestaurantDetailView> {
  final _searchController = TextEditingController();
  final _categoryScrollController = ScrollController();
  final _menuScrollController = ScrollController();
  final _sectionKeys = <GlobalKey>[];

  @override
  void dispose() {
    _searchController.dispose();
    _categoryScrollController.dispose();
    _menuScrollController.dispose();
    super.dispose();
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
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          alignment: 0.05,
        );
      }
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

  void _openRecommendedViewAll(
    BuildContext context,
    RestaurantDetailState state,
    List<MenuItemEntity> items,
  ) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final height = MediaQuery.sizeOf(sheetContext).height * 0.75;
        return SizedBox(
          height: height,
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Recommended',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(sheetContext),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 24),
                    itemCount: items.length,
                    itemBuilder: (_, i) {
                      final item = items[i];
                      return MenuItemTile(
                        item: item,
                        isBusy: state.isCartUpdating,
                        onAdd: () => _onAddItem(context, item),
                        onIncrement: () => _onIncrementItem(context, item),
                        onDecrement: () => context
                            .read<RestaurantDetailCubit>()
                            .decrementItem(item),
                      );
                    },
                  ),
                ),
              ],
            ),
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
            child: _RecommendedSection(
              items: cat.items,
              isBusy: state.isCartUpdating,
              onViewAll: () =>
                  _openRecommendedViewAll(context, state, cat.items),
              onAdd: (item) => _onAddItem(context, item),
              onIncrement: (item) => _onIncrementItem(context, item),
              onDecrement: (item) =>
                  context.read<RestaurantDetailCubit>().decrementItem(item),
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
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  cat.name,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ...cat.items.map(
                (item) => MenuItemTile(
                  item: item,
                  isBusy: state.isCartUpdating,
                  onAdd: () => _onAddItem(context, item),
                  onIncrement: () => _onIncrementItem(context, item),
                  onDecrement: () => context
                      .read<RestaurantDetailCubit>()
                      .decrementItem(item),
                ),
              ),
              const Divider(height: 1),
            ],
          ),
        ),
      );
    }

    slivers.add(const SliverToBoxAdapter(child: SizedBox(height: 24)));
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
        title: const Text('Different restaurant'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, 'cancel'),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, 'clear'),
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
          prev.errorMessage != curr.errorMessage,
      listener: (context, state) {
        if (state.cartConflict != null) {
          _showCartConflictDialog(context, state.cartConflict!.message);
        } else if (state.errorMessage != null &&
            state.errorMessage!.isNotEmpty) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage!)),
          );
          context.read<RestaurantDetailCubit>().clearError();
        }
      },
      builder: (context, state) {
        _syncSectionKeys(state.displayCategories.length);

        return Scaffold(
          appBar: AppBar(
            title: Text(state.title),
            backgroundColor: AppColors.brand,
            foregroundColor: Colors.white,
            actions: [
              if (state.detail != null)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: state.detail!.isOpen
                            ? Colors.green.shade700
                            : Colors.red.shade700,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        state.detail!.isOpened ?? 'Closed',
                        style: const TextStyle(fontSize: 11, color: Colors.white),
                      ),
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
                ),
              ),
            ],
          ),
          body: _buildBody(context, state),
          bottomNavigationBar: CartSummaryBar(
            summary: state.cartSummary,
            isLoading: state.isCartUpdating,
            onTap: () => openCart(context),
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, RestaurantDetailState state) {
    if (state.status == RestaurantDetailStatus.loading &&
        state.displayCategories.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.brand),
      );
    }

    if (state.status == RestaurantDetailStatus.failure &&
        state.displayCategories.isEmpty) {
      return Center(

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(state.errorMessage ?? 'Failed to load menu'),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () =>
                  context.read<RestaurantDetailCubit>().loadInitial(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        if (state.banners.isNotEmpty)
          SizedBox(
            height: 120,
            child: PageView.builder(
              itemCount: state.banners.length,
              itemBuilder: (_, i) => Padding(
                padding: const EdgeInsets.all(12),
                child: NetworkImageBox(
                  url: state.banners[i].image,
                  height: 120,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search menu',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: state.searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        context.read<RestaurantDetailCubit>().setSearchQuery('');
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
            ),
            onChanged: (value) =>
                context.read<RestaurantDetailCubit>().setSearchQuery(value),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Row(
            children: [
              _FoodChip(
                label: 'Veg',
                selected: state.foodFilter == RestaurantFoodFilter.veg,
                color: Colors.green,
                onTap: () => context.read<RestaurantDetailCubit>().setFoodFilter(
                      state.foodFilter == RestaurantFoodFilter.veg
                          ? RestaurantFoodFilter.all
                          : RestaurantFoodFilter.veg,
                    ),
              ),
              const SizedBox(width: 8),
              _FoodChip(
                label: 'Non Veg',
                selected: state.foodFilter == RestaurantFoodFilter.nonVeg,
                color: Colors.red,
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
          SizedBox(
            height: 44,
            child: ListView.builder(
              controller: _categoryScrollController,
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: state.displayCategories.length,
              itemBuilder: (_, index) {
                final category = state.displayCategories[index];
                final selected = state.selectedCategoryIndex == index;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(category.name),
                    selected: selected,
                    selectedColor: AppColors.brandLite,
                    onSelected: (_) => _scrollToCategory(index),
                  ),
                );
              },
            ),
          ),
        Expanded(
          child: state.displayCategories.isEmpty
              ? const Center(child: Text('No menu items found'))
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

class _RecommendedSection extends StatelessWidget {
  const _RecommendedSection({
    required this.items,
    required this.isBusy,
    required this.onViewAll,
    required this.onAdd,
    required this.onIncrement,
    required this.onDecrement,
  });

  final List<MenuItemEntity> items;
  final bool isBusy;
  final VoidCallback onViewAll;
  final void Function(MenuItemEntity item) onAdd;
  final void Function(MenuItemEntity item) onIncrement;
  final void Function(MenuItemEntity item) onDecrement;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 12, 8),
          child: Row(
            children: [
              const Text(
                'Recommended',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: onViewAll,
                child: const Text('View all'),
              ),
            ],
          ),
        ),
        SizedBox(
          height: MediaQuery.sizeOf(context).height*0.27,
          //height: 200,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: items.length,
            separatorBuilder: (_, index) => const SizedBox(width: 10),
            itemBuilder: (_, index) {
              final item = items[index];
              return RecommendedDishCard(
                item: item,
                isBusy: isBusy,
                onAdd: () => onAdd(item),
                onIncrement: () => onIncrement(item),
                onDecrement: () => onDecrement(item),
              );
            },
          ),
        ),
        const Divider(height: 1),
      ],
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
          border: Border.all(color: selected ? color : Colors.grey.shade300),
          borderRadius: BorderRadius.circular(13),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: selected ? color : Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
