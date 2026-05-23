import 'package:flutter/material.dart';

import '../../../../core/data/restaurant_filter_store.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../catalog/domain/entities/cuisine_entity.dart';
import '../../../catalog/domain/enums/restaurant_price_option.dart';
import '../../../catalog/domain/enums/restaurant_sort_option.dart';

/// Android `FilterFragment` — Sort, Price, Category with Reset / Save.
Future<bool> showHomeFilterSheet(
  BuildContext context, {
  required RestaurantFilterStore store,
  required List<CuisineEntity> cuisines,
}) async {
  final applied = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => _HomeFilterSheet(
      store: store,
      cuisines: cuisines,
    ),
  );
  return applied == true;
}

class _HomeFilterSheet extends StatefulWidget {
  const _HomeFilterSheet({
    required this.store,
    required this.cuisines,
  });

  final RestaurantFilterStore store;
  final List<CuisineEntity> cuisines;

  @override
  State<_HomeFilterSheet> createState() => _HomeFilterSheetState();
}

class _HomeFilterSheetState extends State<_HomeFilterSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  RestaurantSortOption? _sort;
  RestaurantPriceOption? _price;
  late Set<String> _cuisineIds;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _sort = widget.store.sortOption;
    _price = widget.store.priceOption;
    _cuisineIds = widget.store.cuisineIds.toSet();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    await widget.store.saveAll(
      sort: _sort,
      price: _price,
      cuisines: _cuisineIds.toList(),
    );
    if (mounted) Navigator.pop(context, true);
  }

  Future<void> _reset() async {
    await widget.store.clearAll();
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height * 0.75;

    return Padding(
      padding: EdgeInsets.only(top: MediaQuery.paddingOf(context).top + 48),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        child: Material(
          color: Colors.white,
          child: SizedBox(
            height: height,
            child: Column(
              children: [
                Container(
                  color: AppColors.brand,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 14),
                          child: Text(
                            'Filter',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context, false),
                        icon: const Icon(Icons.close, color: Colors.white),
                      ),
                    ],
                  ),
                ),
                TabBar(
                  controller: _tabController,
                  labelColor: AppColors.brand,
                  unselectedLabelColor: Colors.grey.shade600,
                  indicatorColor: AppColors.brand,
                  tabs: const [
                    Tab(text: 'Sort'),
                    Tab(text: 'Price'),
                    Tab(text: 'Category'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _SortTab(
                        selected: _sort,
                        onSelected: (v) => setState(() => _sort = v),
                      ),
                      _PriceTab(
                        selected: _price,
                        onSelected: (v) => setState(() => _price = v),
                      ),
                      _CategoryTab(
                        cuisines: widget.cuisines,
                        selectedIds: _cuisineIds,
                        onToggle: (id) {
                          setState(() {
                            if (_cuisineIds.contains(id)) {
                              _cuisineIds.remove(id);
                            } else {
                              _cuisineIds.add(id);
                            }
                          });
                        },
                      ),
                    ],
                  ),
                ),
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _reset,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.brand,
                              side: const BorderSide(color: AppColors.brand),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Text('Reset'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton(
                            onPressed: _save,
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.brand,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Text('Save'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SortTab extends StatelessWidget {
  const _SortTab({required this.selected, required this.onSelected});

  final RestaurantSortOption? selected;
  final ValueChanged<RestaurantSortOption?> onSelected;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: RestaurantSortOption.values.map((option) {
        final isSelected = selected == option;
        return _FilterOptionTile(
          title: option.label,
          icon: option.icon,
          isSelected: isSelected,
          multiSelect: false,
          onTap: () => onSelected(isSelected ? null : option),
        );
      }).toList(),
    );
  }
}

class _PriceTab extends StatelessWidget {
  const _PriceTab({required this.selected, required this.onSelected});

  final RestaurantPriceOption? selected;
  final ValueChanged<RestaurantPriceOption?> onSelected;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: RestaurantPriceOption.values.map((option) {
        final isSelected = selected == option;
        return _FilterOptionTile(
          title: option.label,
          icon: option.icon,
          isSelected: isSelected,
          multiSelect: false,
          onTap: () => onSelected(isSelected ? null : option),
        );
      }).toList(),
    );
  }
}

class _CategoryTab extends StatelessWidget {
  const _CategoryTab({
    required this.cuisines,
    required this.selectedIds,
    required this.onToggle,
  });

  final List<CuisineEntity> cuisines;
  final Set<String> selectedIds;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    if (cuisines.isEmpty) {
      return const Center(child: Text('No categories available'));
    }

    return ListView.builder(
      itemCount: cuisines.length,
      itemBuilder: (_, index) {
        final cuisine = cuisines[index];
        final isSelected = selectedIds.contains(cuisine.id);
        return _FilterOptionTile(
          title: cuisine.name,
          icon: Icons.restaurant_menu_outlined,
          isSelected: isSelected,
          multiSelect: true,
          onTap: () => onToggle(cuisine.id),
        );
      },
    );
  }
}

class _FilterOptionTile extends StatelessWidget {
  const _FilterOptionTile({
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.multiSelect,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final bool isSelected;
  final bool multiSelect;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? AppColors.brand : Colors.grey.shade600,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          color: isSelected ? AppColors.brand : Colors.black87,
        ),
      ),
      trailing: Icon(
        multiSelect
            ? (isSelected
                ? Icons.check_box
                : Icons.check_box_outline_blank)
            : (isSelected ? Icons.radio_button_checked : Icons.radio_button_off),
        color: isSelected ? AppColors.brand : Colors.grey,
      ),
      onTap: onTap,
    );
  }
}
