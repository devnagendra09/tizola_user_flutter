import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_loading_shimmers.dart';
import '../../../../injection_container.dart';
import '../cubit/service_order_cubit.dart';
import '../cubit/service_order_state.dart';
import '../widgets/service_order_content.dart';
import 'order_tracker_page.dart';

/// Android `OrdersActivity` + `OrderSummaryFragment` (View Details).
class OrderDetailPage extends StatelessWidget {
  const OrderDetailPage({super.key, required this.refId});

  final String refId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ServiceOrderCubit>()..load(refId),
      child: _OrderDetailView(refId: refId),
    );
  }
}

class _OrderDetailView extends StatelessWidget {
  const _OrderDetailView({required this.refId});

  final String refId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Info'),
        backgroundColor: AppColors.brand,
        foregroundColor: Colors.white,
      ),
      body: BlocBuilder<ServiceOrderCubit, ServiceOrderState>(
        builder: (context, state) {
          if (state.status == ServiceOrderStatus.loading) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: OrdersListShimmer(itemCount: 4),
            );
          }

          if (state.status == ServiceOrderStatus.failure) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.errorMessage ?? 'Failed to load order'),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () =>
                        context.read<ServiceOrderCubit>().load(refId),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final order = state.order;
          if (order == null) {
            return const Center(child: Text('Order not found'));
          }

          return RefreshIndicator(
            color: AppColors.brand,
            onRefresh: () => context.read<ServiceOrderCubit>().load(refId),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                ServiceOrderContent(
                  order: order,
                  showLiveTrackButton: order.shouldListenDriverLocation,
                  onLiveTrackTap: order.shouldListenDriverLocation
                      ? () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) =>
                                  OrderTrackerPage(refId: order.refId),
                            ),
                          );
                        }
                      : null,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
