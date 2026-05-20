import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_loading_shimmers.dart';
import '../../../../core/widgets/mobile_api_empty_view.dart';
import '../../../../core/widgets/network_image_box.dart';
import '../../../../injection_container.dart';
import '../cubit/orders_cubit.dart';
import '../cubit/orders_state.dart';

class OrdersTab extends StatelessWidget {
  const OrdersTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<OrdersCubit>()..loadOrders(tab: OrderTab.upcoming),
      child: const _OrdersTabContent(),
    );
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
    return Column(
      children: [
        Material(
          color: AppColors.brand,
          child: TabBar(
            controller: _tabController,
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: const [
              Tab(text: 'Upcoming'),
              Tab(text: 'Past'),
            ],
          ),
        ),
        const Expanded(child: _OrdersList()),
      ],
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
            message: state.selectedTab == OrderTab.upcoming
                ? 'No upcoming orders'
                : 'No past orders',
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

              final order = state.currentOrders[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: NetworkImageBox(
                    url: order.displayImage,
                    width: 56,
                    height: 56,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  title: Text(
                    order.restaurantName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text('Order #${order.refId}'),
                      if (order.serviceStatus != null)
                        Text(
                          order.serviceStatus!,
                          style: const TextStyle(
                            color: AppColors.brand,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      if (order.cartItemsText != null)
                        Text(
                          order.cartItemsText!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (order.grandTotal != null)
                        Text(
                          '₹${order.grandTotal}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      if (order.paymentStatus != null)
                        Text(
                          order.paymentStatus!,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                          ),
                        ),
                    ],
                  ),
                  isThreeLine: true,
                ),
              );
            },
          ),
        );
      },
    );
  }
}
