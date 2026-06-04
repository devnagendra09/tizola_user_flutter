import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_loading_shimmers.dart';
import '../../../../core/widgets/network_image_box.dart';
import '../../../../injection_container.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../../../auth/presentation/pages/login_page.dart';
import '../../../location/domain/repositories/location_repository.dart';
import '../../../location/presentation/pages/location_info_page.dart';
import '../../../main/presentation/cubit/main_cubit.dart';
import '../../domain/entities/cart_entity.dart';
import '../cubit/cart_cubit.dart';
import '../cubit/cart_state.dart';
import '../widgets/cart_billing_section.dart';
import '../widgets/cart_footer.dart';
import '../widgets/cart_widgets.dart';
import 'coupon_offers_page.dart';
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

  Future<void> _openCouponOffers(BuildContext context) async {
    final code = await Navigator.of(context).push<String>(
      MaterialPageRoute<String>(builder: (_) => const CouponOffersPage()),
    );
    if (!context.mounted || code == null) return;
    final cubit = context.read<CartCubit>();
    cubit.selectCouponFromOffers(code);
    await cubit.loadCart();
  }

  Future<void> _onSelfPickupToggle(BuildContext context, bool? value) async {
    final cubit = context.read<CartCubit>();
    if (value != true) {
      cubit.cancelSelfPickup();
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Self Pick Alert!'),
        content: const Text(
          'You have been selected for self-pickup, so you can collect '
          'your order at the store.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.red.shade700),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'Confirm',
              style: TextStyle(color: Colors.green.shade700),
            ),
          ),
        ],
      ),
    );

    if (!context.mounted) return;
    if (confirmed == true) {
      await cubit.confirmSelfPickup();
    }
  }

  Future<bool> _ensureLoggedIn(BuildContext context) async {
    final session = await sl<AuthRepository>().getSession();
    if (!context.mounted) return false;
    if (session.isSuccess && session.data!.isLoggedIn) return true;

    final goLogin = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Login now..!'),
        content: const Text(
          'For taking the benefit of this functionality login is mandatory. '
          'So please click on Login to proceed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.red.shade700),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Login'),
          ),
        ],
      ),
    );

    if (!context.mounted || goLogin != true) return false;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const LoginPage()),
    );
    if (!context.mounted) return false;
    final again = await sl<AuthRepository>().getSession();
    return again.isSuccess && again.data!.isLoggedIn;
  }

  Future<void> _proceedToCheckout(BuildContext context, CartState state) async {
    final blockReason = state.checkoutBlockReason;
    if (blockReason != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(blockReason)),
      );
      return;
    }

    if (!await _ensureLoggedIn(context)) return;

    final restaurantId = state.cart.restaurantId;
    if (restaurantId == null || restaurantId.isEmpty) return;

    if (!context.mounted) return;
    final result = await Navigator.of(context).push<String?>(
      MaterialPageRoute<String?>(
        builder: (_) => PaymentOptionsPage(
          restaurantId: restaurantId,
          payableAmount: state.payableAmount,
          orderType: state.paymentOrderType,
          tipAmount: state.effectiveTipAmount,
          deliveryType: state.deliveryType,
        ),
      ),
    );

    if (!context.mounted || result == null || result.isEmpty) return;
    context.read<CartCubit>().disableSelfPickupOnExit();
    sl<MainCubit>().refreshCartBadge();
    await Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => OrderSuccessPage(refId: result),
      ),
    );
  }

  Future<void> _changeAddress(BuildContext context) async {
    final previous = sl<LocationRepository>().savedDeliveryLocation;
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(builder: (_) => const LocationInfoPage()),
    );
    if (!context.mounted || changed != true) return;

    final rejection = await context
        .read<CartCubit>()
        .applyDeliveryLocationChange(previous);
    if (!context.mounted || rejection == null) return;

    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        content: Text(rejection),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Okay'),
          ),
        ],
      ),
    );
  }

  void _goHome(BuildContext context) {
    Navigator.of(context).popUntil((route) => route.isFirst);
    sl<MainCubit>().selectTab(0);
    sl<MainCubit>().refreshInProgressOrderAfterCheckout();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) {
          context.read<CartCubit>().disableSelfPickupOnExit();
        }
      },
      child: BlocConsumer<CartCubit, CartState>(
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
          final isBusy =
              state.status == CartStatus.updating ||
              state.status == CartStatus.loading;

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
                    top: false,
                    child: CartFooter(
                      payableAmount: state.payableAmount,
                      isBusy: isBusy,
                      onCheckout: () => _proceedToCheckout(context, state),
                      hideAddress: state.isSelfPickup,
                      showAddAddressButton: !state.isSelfPickup &&
                          (state.deliveryLocation?.id == null ||
                              state.deliveryLocation!.id!.isEmpty),
                      onAddAddress: () => _changeAddress(context),
                      onChangeAddress: () => _changeAddress(context),
                      deliveryAddress: state.cart.deliveryAddress ??
                          state.deliveryLocation?.locationTitle,
                    ),
                  ),
          );
        },
      ),
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
      return _EmptyCartView(onHome: () => _goHome(context));
    }

    final cart = state.cart;
    final restaurant = cart.restaurant;
    final cubit = context.read<CartCubit>();

    return RefreshIndicator(
      color: AppColors.brand,
      onRefresh: () => cubit.loadCart(),
      child: ListView(
        padding: const EdgeInsets.only(bottom: 16),
        children: [
          if (restaurant != null) _RestaurantHeader(restaurant: restaurant),
          ...cart.items.map(
            (item) => CartItemTile(
              item: item,
              isBusy: isBusy,
              onIncrement: () => cubit.incrementItem(item),
              onDecrement: () => cubit.decrementItem(item),
            ),
          ),
          const Divider(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: CartCouponSection(
              hasAppliedCoupon: state.hasAppliedCoupon,
              couponCode: cart.couponCode,
              couponMessage: cart.couponDiscountMessage,
              hasCouponDiscount: cart.hasCouponDiscount,
              onApplyTap: () => _openCouponOffers(context),
              onTryAnotherTap: () async {
                await cubit.removeCoupon(openOffersAfter: true);
                if (context.mounted) await _openCouponOffers(context);
              },
            ),
          ),
          if (!state.isSelfPickup)
            CartDeliveryTipsSection(
              tipAmounts: state.tipAmounts,
              selectedTip: state.selectedTipAmount,
              showCustomTipField: state.showCustomTipField,
              customTipInput: state.customTipInput,
              isBusy: isBusy,
              onTipSelected: cubit.selectTipAmount,
              onToggleCustomTip: cubit.toggleCustomTipField,
              onCustomTipChanged: cubit.setCustomTipInput,
              onCustomTipSubmitted: () => cubit.applyCustomTipIfValid(),
              onClearTip: () => cubit.clearTip(),
            ),
          if (state.supportsSelfPickup)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Card(
                color: AppColors.brandLite,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                child: CheckboxListTile(
                  value: state.isSelfPickup,
                  onChanged: isBusy ? null : (v) => _onSelfPickupToggle(context, v),
                  title: const Text(
                    'Do you want self pick your order?',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                      fontSize: 16,
                    ),
                  ),
                  controlAffinity: ListTileControlAffinity.leading,
                  activeColor: AppColors.brand,
                ),
              ),
            ),
          CartBillingSection(
            cart: cart,
            displayTipAmount: state.effectiveTipAmount,
          ),
        ],
      ),
    );
  }
}

class _EmptyCartView extends StatelessWidget {
  const _EmptyCartView({required this.onHome});

  final VoidCallback onHome;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(AppAssets.noCartItems),
            // Icon(
            //   Icons.shopping_cart_outlined,
            //   size: 100,
            //   color: Colors.grey.shade400,
            // ),
            const SizedBox(height: 20),
            Text(
              'Cart is empty!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'There is nothing in your cart. Start finding your favorite item!',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onHome,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.brand,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('Back to Home'),
              ),
            ),
          ],
        ),
      ),
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
            width: 80,
            height: 80,
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
                    color: AppColors.error,
                  ),
                ),
                if (restaurant.cuisineTypes != null)
                  Text(
                    restaurant.cuisineTypes!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                if (restaurant.address != null)
                  Text(
                    restaurant.address!,
                    maxLines: 2,
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
