import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_loading_shimmers.dart';
import '../../../../core/widgets/mobile_api_empty_view.dart';
import '../../../../injection_container.dart';
import '../../../main/presentation/cubit/main_cubit.dart';
import '../../../main/presentation/cubit/main_state.dart';
import '../cubit/orders_cubit.dart';
import '../cubit/orders_state.dart';
import 'order_list_item.dart';

class OrdersTab extends StatefulWidget {
  const OrdersTab({super.key});

  @override
  State<OrdersTab> createState() => _OrdersTabState();
}

class _OrdersTabState extends State<OrdersTab> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return const _OrdersTabContent();
  }
}

class _OrdersTabContent extends StatefulWidget {
  const _OrdersTabContent();

  @override
  State<_OrdersTabContent> createState() => _OrdersTabContentState();
}

class _OrdersTabContentState extends State<_OrdersTabContent>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging && mounted) {
        context.read<OrdersCubit>().switchTab(
              _tabController.index == 0
                  ? OrderTab.upcoming
                  : OrderTab.past,
            );
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<MainCubit, MainState>(
      listenWhen: (prev, curr) =>
          prev.currentIndex != curr.currentIndex && curr.currentIndex == 2,
      listener: (context, _) {
        context.read<OrdersCubit>().loadOrdersIfNeeded();
      },
      child: Column(
        children: [
          Material(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              indicatorColor: AppColors.brand,
              labelColor: AppColors.brand,
              unselectedLabelColor: Colors.grey,
              tabs: const [
                Tab(text: 'Upcoming'),
                Tab(text: 'Past'),
              ],
            ),
          ),
          const Expanded(child: _OrdersList()),
        ],
      ),
    );
  }
}

class _OrdersList extends StatefulWidget {
  const _OrdersList();

  @override
  State<_OrdersList> createState() => _OrdersListState();
}

class _OrdersListState extends State<_OrdersList> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 120) {
      context.read<OrdersCubit>().loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrdersCubit, OrdersState>(
      builder: (context, state) {
        if (state.status == OrdersStatus.loading &&
            state.currentOrders.isEmpty) {
          return const OrdersListShimmer(itemCount: 6);
        }

        if (state.status == OrdersStatus.failure &&
            state.currentOrders.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(state.errorMessage ?? 'Failed to load orders'),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => context.read<OrdersCubit>().loadOrders(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (state.currentOrders.isEmpty) {
          return MobileApiEmptyView(
            message: state.currentEmptyMessage?.trim().isNotEmpty == true
                ? state.currentEmptyMessage!
                : (state.selectedTab == OrderTab.upcoming
                    ? 'No upcoming orders'
                    : 'No past orders'),
          );
        }

        return RefreshIndicator(
          color: AppColors.brand,
          onRefresh: () =>
              context.read<OrdersCubit>().loadOrders(tab: state.selectedTab),
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(12),
            itemCount:
                state.currentOrders.length + (state.isLoadingMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index >= state.currentOrders.length) {
                return const ListFooterShimmer();
              }

              return OrderListItem(order: state.currentOrders[index]);
            },
          ),
        );
      },
    );
  }
}
