import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_shimmer.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/domain/entities/wallet_add_result.dart';
import '../../../cart/data/services/razorpay_checkout_service.dart';
import '../cubit/account/account_cubit.dart';
import '../cubit/main_cubit.dart';
import '../cubit/main_state.dart';
import '../cubit/wallet/wallet_cubit.dart';

class WalletTab extends StatefulWidget {
  const WalletTab({super.key});

  @override
  State<WalletTab> createState() => _WalletTabState();
}

class _WalletTabState extends State<WalletTab> with AutomaticKeepAliveClientMixin {
  final _amountController = TextEditingController();
  final _razorpayCheckout = RazorpayCheckoutService();
  WalletAddResult? _activeCheckout;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _razorpayCheckout.attach(
      onSuccess: _onPaymentSuccess,
      onError: _onPaymentError,
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _razorpayCheckout.dispose();
    super.dispose();
  }

  void _onPaymentSuccess(PaymentSuccessResponse response) {
    final checkout = _activeCheckout;
    _activeCheckout = null;
    final cubit = context.read<WalletCubit>();
    final paymentId = response.paymentId?.trim();
    if (checkout == null || paymentId == null || paymentId.isEmpty) {
      cubit.onPaymentCancelled();
      _showMessage(context, AppLocalizations.of(context).walletPaymentFailed);
      return;
    }
    cubit.confirmPayment(
      checkout: checkout,
      paymentGatewayId: paymentId,
    );
  }

  void _onPaymentError(PaymentFailureResponse response) {
    _activeCheckout = null;
    context.read<WalletCubit>().onPaymentCancelled();
    final message = response.message?.trim();
    _showMessage(
      context,
      message != null && message.isNotEmpty
          ? message
          : AppLocalizations.of(context).walletPaymentFailed,
    );
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _openCheckout(WalletAddResult checkout) {
    try {
      _razorpayCheckout.open(checkout.checkoutInfo);
    } catch (_) {
      _activeCheckout = null;
      context.read<WalletCubit>().onPaymentCancelled();
      _showMessage(context, AppLocalizations.of(context).walletPaymentFailed);
    }
  }

  void _submitAmount(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final amount = _amountController.text.trim();
    final parsed = double.tryParse(amount);
    if (amount.isEmpty || parsed == null || parsed <= 0) {
      _showMessage(context, l10n.walletInvalidAmount);
      return;
    }
    context.read<WalletCubit>().addMoney(amount);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final l10n = AppLocalizations.of(context);

    return BlocListener<MainCubit, MainState>(
      listenWhen: (prev, curr) =>
          prev.currentIndex != curr.currentIndex && curr.currentIndex == 3,
      listener: (context, _) {
        context.read<WalletCubit>().loadBalance();
      },
      child: BlocConsumer<WalletCubit, WalletState>(
        listenWhen: (prev, curr) =>
            prev.pendingCheckout != curr.pendingCheckout ||
            prev.errorMessage != curr.errorMessage ||
            prev.successMessage != curr.successMessage,
        listener: (context, state) {
          final checkout = state.pendingCheckout;
          if (checkout != null && _activeCheckout == null) {
            _activeCheckout = checkout;
            _openCheckout(checkout);
          }
          if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
            _showMessage(context, state.errorMessage!);
          }
          if (state.successMessage != null && state.successMessage!.isNotEmpty) {
            _amountController.clear();
            _showMessage(context, state.successMessage!);
            context.read<AccountCubit>().refreshWalletBalance();
          }
        },
        builder: (context, state) {
          if (state.status == WalletStatus.initial ||
              state.status == WalletStatus.loading) {
            return const _WalletLoadingView();
          }

          final balance = state.balance.replaceAll('/-', '').trim();

          return Stack(
            children: [
              ListView(
                padding: const EdgeInsets.all(10),
                children: [
                  Card(
                    elevation: 10,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.currentWalletBalance,
                                  style: const TextStyle(
                                    color: AppColors.secondaryBrand,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Text(
                                      '₹',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      balance,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.account_balance_wallet_outlined,
                            size: 48,
                            color: AppColors.brand.withValues(alpha: 0.35),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    l10n.addMoney,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _amountController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                    ],
                    decoration: InputDecoration(
                      hintText: l10n.enterAmount,
                      contentPadding: const EdgeInsets.all(12),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                        borderSide: const BorderSide(color: AppColors.brand),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                        borderSide: const BorderSide(
                          color: AppColors.brand,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _QuickAmountButton(
                        label: '₹100',
                        onTap: () => _amountController.text = '100',
                      ),
                      const SizedBox(width: 8),
                      _QuickAmountButton(
                        label: '₹200',
                        onTap: () => _amountController.text = '200',
                      ),
                      const SizedBox(width: 8),
                      _QuickAmountButton(
                        label: '₹500',
                        onTap: () => _amountController.text = '500',
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Material(
                    color: AppColors.brand,
                    borderRadius: BorderRadius.circular(4),
                    child: InkWell(
                      onTap: state.isBusy
                          ? null
                          : () => _submitAmount(context),
                      borderRadius: BorderRadius.circular(4),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        child: Center(
                          child: Text(
                            l10n.addMoney,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              if (state.isBusy)
                ColoredBox(
                  color: Colors.black.withValues(alpha: 0.25),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(color: AppColors.brand),
                        const SizedBox(height: 8),
                        Text(
                          l10n.loading,
                          style: TextStyle(color: Colors.grey.shade700),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _QuickAmountButton extends StatelessWidget {
  const _QuickAmountButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.black87,
          side: const BorderSide(color: AppColors.brand),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        child: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

class _WalletLoadingView extends StatelessWidget {
  const _WalletLoadingView();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(10),
      children: [
        AppShimmer(
          child: Column(
            children: [
              const ShimmerBox(
                width: double.infinity,
                height: 100,
                borderRadius: 10,
              ),
              const SizedBox(height: 24),
              const ShimmerBox(width: 120, height: 18, borderRadius: 4),
              const SizedBox(height: 8),
              const ShimmerBox(width: double.infinity, height: 48, borderRadius: 4),
              const SizedBox(height: 12),
              Row(
                children: [
                  for (var i = 0; i < 3; i++) ...[
                    if (i > 0) const SizedBox(width: 8),
                    const Expanded(
                      child: ShimmerBox(
                        width: double.infinity,
                        height: 44,
                        borderRadius: 4,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 24),
              const ShimmerBox(width: double.infinity, height: 48, borderRadius: 4),
            ],
          ),
        ),
      ],
    );
  }
}
