import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/push/push_order_refresh_listener.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_loading_shimmers.dart';
import '../../../../injection_container.dart';
import '../../../main/presentation/cubit/main_cubit.dart';
import '../cubit/service_order_cubit.dart';
import '../cubit/service_order_state.dart';
import '../widgets/order_cancel_bar.dart';
import '../widgets/order_support_sheet.dart';
import '../widgets/service_order_content.dart';
import 'order_tracker_page.dart';

/// Android `OrdersActivity` + `OrderSummaryFragment`.
class OrderDetailPage extends StatelessWidget {
  const OrderDetailPage({super.key, required this.refId});

  final String refId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ServiceOrderCubit>()..load(refId),
      child: Builder(
        builder: (context) => PushOrderRefreshListener(
          refId: refId,
          onRefresh: () => context
              .read<ServiceOrderCubit>()
              .load(refId, showLoading: false),
          child: _OrderDetailView(refId: refId),
        ),
      ),
    );
  }
}

class _OrderDetailView extends StatelessWidget {
  const _OrderDetailView({required this.refId});

  final String refId;

  Future<void> _cancelOrder(BuildContext context, ServiceOrderCubit cubit) async {
    final reason = await showOrderCancelReasonDialog(context);
    if (reason == null || !context.mounted) return;

    final error = await cubit.cancelOrder(refId: refId, reason: reason);
    if (!context.mounted) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      sl<MainCubit>().refreshInProgressOrder();
      if (!context.mounted) return;
      final messenger = ScaffoldMessenger.maybeOf(context);
      if (messenger == null) return;
      if (error != null) {
        messenger.showSnackBar(SnackBar(content: Text(error)));
      } else {
        messenger.showSnackBar(
          const SnackBar(content: Text('Order cancelled')),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        title: Text('#$refId'),
        backgroundColor: AppColors.brand,
        foregroundColor: Colors.white,
        actions: [
          BlocBuilder<ServiceOrderCubit, ServiceOrderState>(
            builder: (context, state) {
              final order = state.order;
              if (order == null) return const SizedBox.shrink();
              return Row(
                children: [
                  TextButton(
                    onPressed: () {
                      final phone = order.customerCareNumber;
                      if (phone != null && phone.isNotEmpty) {
                        launchUrl(Uri.parse('tel:$phone'));
                      }
                    },
                    child: const Text(
                      'Help',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  TextButton(
                    onPressed: () => showOrderSupportSheet(
                      context,
                      phone: order.customerCareNumber,
                      whatsApp: order.customerCareWhatsApp,
                      orderId: order.refId,
                    ),
                    child: const Text(
                      'Support',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
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

          final cubit = context.read<ServiceOrderCubit>();

          return Column(
            children: [
              Expanded(
                child: RefreshIndicator(
                  color: AppColors.brand,
                  onRefresh: () => cubit.load(refId),
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      ServiceOrderContent(order: order),
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 8,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (order.canCancelOrder)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: OrderCancelBar(
                          key: ValueKey('cancel-${order.refId}'),
                          initialSeconds: order.remainingSeconds!,
                          onCancelPressed: () => _cancelOrder(context, cubit),
                        ),
                      ),
                    if (order.canShowTrackOrder)
                      OutlinedButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) =>
                                  OrderTrackerPage(refId: order.refId),
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.brand,
                          side: const BorderSide(color: AppColors.brand),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text('Track your order'),
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
