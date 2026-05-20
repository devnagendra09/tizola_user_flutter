import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_loading_shimmers.dart';
import '../../../../core/widgets/mobile_api_empty_view.dart';
import '../../../../core/widgets/network_image_box.dart';
import '../../../../injection_container.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../../../location/presentation/pages/location_info_page.dart';
import '../../domain/entities/cart_entity.dart';
import '../cubit/cart_cubit.dart';
import '../cubit/cart_state.dart';
import '../widgets/cart_widgets.dart';
import 'order_success_page.dart';
import 'payment_options_page.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<CartCubit>()..loadCart(),
      child: const _CartView(),
    );
  }
}

class _CartView extends StatelessWidget {
  const _CartView();

  Future<void> _proceedToCheckout(BuildContext context, CartState state) async {
    final session = await sl<AuthRepository>().getSession();
    if (!context.mounted) return;

    if (!session.isSuccess || !session.data!.isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to checkout')),
      );
      return;
    }

    final restaurantId = state.cart.restaurantId;
    if (restaurantId == null || restaurantId.isEmpty) return;

    if (!context.mounted) return;
    final result = await Navigator.of(context).push<String?>(
      MaterialPageRoute<String?>(
        builder: (_) => PaymentOptionsPage(
          restaurantId: restaurantId,
          payableAmount: state.payableAmount,
        ),
      ),
    );

    if (!context.mounted || result == null) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => OrderSuccessPage(refId: result),
      ),
    );
  }

  Future<void> _changeAddress(BuildContext context) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(builder: (_) => const LocationInfoPage()),
    );
    if (context.mounted && changed == true) {
      await context.read<CartCubit>().refreshDeliveryLocation();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CartCubit, CartState>(
      listenWhen: (prev, curr) => prev.errorMessage != curr.errorMessage,
      listener: (context, state) {
        if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage!)),
          );
          context.read<CartCubit>().clearError();
        }
      },
      builder: (context, state) {
        final isBusy = state.status == CartStatus.updating;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Cart details'),
            backgroundColor: AppColors.brand,
            foregroundColor: Colors.white,
          ),
          body: _buildBody(context, state, isBusy),
          bottomNavigationBar: state.isEmpty
              ? null
              : SafeArea(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 8,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Total',
                                style: TextStyle(fontSize: 12),
                              ),
                              Text(
                                state.payableAmount,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.brand,
                                ),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: isBusy
                              ? null
                              : () => _proceedToCheckout(context, state),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.brand,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 14,
                            ),
                          ),
                          child: isBusy
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text('Proceed to checkout'),
                        ),
                      ],
                    ),
                  ),
                ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, CartState state, bool isBusy) {
    if (state.status == CartStatus.loading && state.isEmpty) {
      return const CartPageShimmer();
    }

    if (state.status == CartStatus.failure && state.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(state.errorMessage ?? 'Failed to load cart'),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => context.read<CartCubit>().loadCart(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (state.isEmpty) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const MobileApiEmptyView(
            message: 'Your cart is empty',
            padding: EdgeInsets.symmetric(horizontal: 32),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Browse restaurants'),
          ),
        ],
      );
    }

    final cart = state.cart;
    final restaurant = cart.restaurant;

    return RefreshIndicator(
      color: AppColors.brand,
      onRefresh: () => context.read<CartCubit>().loadCart(),
      child: ListView(
        children: [
          if (restaurant != null) _RestaurantHeader(restaurant: restaurant),
          ...cart.items.map(
            (item) => CartItemTile(
              item: item,
              isBusy: isBusy,
              onIncrement: () => context.read<CartCubit>().incrementItem(item),
              onDecrement: () => context.read<CartCubit>().decrementItem(item),
            ),
          ),
          const Divider(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _CouponInput(
              initialValue: state.couponCodeInput,
              hasAppliedCoupon:
                  cart.couponCode != null && cart.couponCode!.isNotEmpty,
              isBusy: isBusy,
              onChanged: context.read<CartCubit>().setCouponCodeInput,
              onApply: () => context.read<CartCubit>().applyCoupon(),
              onRemove: () => context.read<CartCubit>().removeCoupon(),
            ),
          ),
          if (cart.couponDiscountMessage != null &&
              cart.couponDiscountMessage!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Text(
                cart.couponDiscountMessage!,
                style: TextStyle(color: Colors.green.shade700, fontSize: 12),
              ),
            ),
          CartBillingSection(cart: cart),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Delivery address',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    TextButton(
                      onPressed: () => _changeAddress(context),
                      child: const Text('Change'),
                    ),
                  ],
                ),
                Text(
                  cart.deliveryAddress ??
                      state.deliveryLocation?.locationTitle ??
                      'Add delivery address',
                  style: TextStyle(color: Colors.grey.shade700),
                ),
              ],
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

class _CouponInput extends StatefulWidget {
  const _CouponInput({
    required this.initialValue,
    required this.hasAppliedCoupon,
    required this.isBusy,
    required this.onChanged,
    required this.onApply,
    required this.onRemove,
  });

  final String initialValue;
  final bool hasAppliedCoupon;
  final bool isBusy;
  final ValueChanged<String> onChanged;
  final VoidCallback onApply;
  final VoidCallback onRemove;

  @override
  State<_CouponInput> createState() => _CouponInputState();
}

class _CouponInputState extends State<_CouponInput> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void didUpdateWidget(covariant _CouponInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue != oldWidget.initialValue &&
        widget.initialValue != _controller.text) {
      _controller.text = widget.initialValue;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            decoration: InputDecoration(
              hintText: 'Coupon code',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
            ),
            onChanged: widget.onChanged,
          ),
        ),
        const SizedBox(width: 8),
        if (widget.hasAppliedCoupon)
          TextButton(
            onPressed: widget.isBusy ? null : widget.onRemove,
            child: const Text('Remove'),
          )
        else
          TextButton(
            onPressed: widget.isBusy ? null : widget.onApply,
            child: const Text('Apply'),
          ),
      ],
    );
  }
}

class _RestaurantHeader extends StatelessWidget {
  const _RestaurantHeader({required this.restaurant});

  final CartRestaurantInfoEntity restaurant;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          NetworkImageBox(
            url: restaurant.image,
            width: 56,
            height: 56,
            borderRadius: BorderRadius.circular(8),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  restaurant.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                if (restaurant.cuisineTypes != null)
                  Text(
                    restaurant.cuisineTypes!,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                if (restaurant.address != null)
                  Text(
                    restaurant.address!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
