import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/navigation/search_navigation.dart';
import '../../../restaurant/presentation/pages/restaurant_detail_page.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/system_ui_styles.dart';
import '../../../../core/cache/hive_local_cache.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/search_suggestion_entity.dart';
import '../cubit/search_cubit.dart';
import '../cubit/search_state.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<SearchCubit>(),
      child: const _SearchView(),
    );
  }
}

class _SearchView extends StatefulWidget {
  const _SearchView();

  @override
  State<_SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<_SearchView> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  List<String> _recentSearches = const [];

  @override
  void initState() {
    super.initState();
    _recentSearches = sl<HiveLocalCache>().readRecentSearches();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  void _reloadRecent() {
    setState(() {
      _recentSearches = sl<HiveLocalCache>().readRecentSearches();
    });
  }

  void _searchRecent(String term) {
    _controller.text = term;
    context.read<SearchCubit>().onQueryChanged(term);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSuggestionTap(SearchSuggestionEntity item) {
    sl<HiveLocalCache>().addRecentSearch(item.restaurantName);
    _reloadRecent();

    if (item.isDish) {
      openSearchResultsScreen(context, searchKey: item.restaurantName);
      return;
    }

    final seoUrl = item.seoUrl;
    if (seoUrl == null || seoUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Restaurant link unavailable')),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => RestaurantDetailPage(
          seoUrl: seoUrl,
          fallbackName: item.restaurantName,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppSystemUi.lightScreen,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 0,
          surfaceTintColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Search',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                onChanged: context.read<SearchCubit>().onQueryChanged,
                decoration: InputDecoration(
                  hintText: 'Search restaurants, cuisines, dishes...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: BlocBuilder<SearchCubit, SearchState>(
                    buildWhen: (p, c) => p.query != c.query,
                    builder: (context, state) {
                      if (state.query.isEmpty) return const SizedBox.shrink();
                      return IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          _controller.clear();
                          context.read<SearchCubit>().clearQuery();
                        },
                      );
                    },
                  ),
                  filled: true,
                  fillColor: AppColors.grey,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            Expanded(
              child: BlocBuilder<SearchCubit, SearchState>(
                builder: (context, state) {
                  if (state.status == SearchStatus.loading) {
                    return const Center(
                      child: CircularProgressIndicator(color: AppColors.brand),
                    );
                  }

                  if (state.status == SearchStatus.failure) {
                    return Center(
                      child: Text(
                        state.errorMessage ?? 'Search failed',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    );
                  }

                  if (state.query.trim().isEmpty) {
                    if (_recentSearches.isEmpty) {
                      return Center(
                        child: Text(
                          'Type to search restaurants or dishes',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      );
                    }
                    return ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: [
                        Text(
                          'Recent searches',
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ..._recentSearches.map(
                          (term) => ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(Icons.history),
                            title: Text(term),
                            onTap: () => _searchRecent(term),
                          ),
                        ),
                      ],
                    );
                  }

                  if (state.showEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              AppAssets.noSearchItemFound,
                              width: 220,
                              height: 190,
                              fit: BoxFit.contain,
                            ),
                            SizedBox(height: 20),
                            Text(
                              'Nothing matched with your query. search again..!!',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: state.suggestions.length,
                    separatorBuilder: (_, index) => Divider(
                      height: 1,
                      indent: 72,
                      color: Colors.grey.shade200,
                    ),
                    itemBuilder: (context, index) {
                      final item = state.suggestions[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: item.isDish
                              ? AppColors.brandLite
                              : Colors.grey.shade100,
                          child: Icon(
                            item.isDish
                                ? Icons.restaurant_menu
                                : Icons.storefront_outlined,
                            color: AppColors.brand,
                          ),
                        ),
                        title: Text(
                          item.restaurantName,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: item.isDish
                            ? const Text('Dish')
                            : (item.address != null && item.address!.isNotEmpty
                                ? Text(
                                    item.address!,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  )
                                : null),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => _onSuggestionTap(item),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
