import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/cart_entity.dart';

/// Android billing block: Total Payable, expandable breakdown, wallet, payable amount.
class CartBillingSection extends StatefulWidget {
  const CartBillingSection({
    super.key,
    required this.cart,
    this.displayTipAmount,
    this.usedWalletAmount = 0,
    this.isWalletUsed = false,
  });

  final CartEntity cart;
  final String? displayTipAmount;
  final double usedWalletAmount;
  final bool isWalletUsed;

  @override
  State<CartBillingSection> createState() => _CartBillingSectionState();
}

class _CartBillingSectionState extends State<CartBillingSection> {
  bool _breakdownExpanded = true;
  bool _taxesExpanded = false;

  @override
  Widget build(BuildContext context) {
    final cart = widget.cart;
    final displayTip = widget.displayTipAmount;

    final originalTotal = double.tryParse(cart.grandTotal ?? cart.subTotal ?? '0') ?? 0;
    final finalPayable = (originalTotal - widget.usedWalletAmount).clamp(0, double.infinity);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Billing',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.obText,
            ),
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: () {
              setState(() => _breakdownExpanded = !_breakdownExpanded);
            },
            borderRadius: BorderRadius.circular(4),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Total Payable',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: AppColors.brand,
                      ),
                    ),
                  ),
                  Text(
                    '₹ ${cart.grandTotal ?? cart.subTotal ?? '0'}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: AppColors.brand,
                    ),
                  ),
                  Icon(
                    _breakdownExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: AppColors.brand,
                  ),
                ],
              ),
            ),
          ),
          if (_breakdownExpanded) ...[
            const SizedBox(height: 4),
            _BillRow(label: 'Sub total', value: cart.subTotal),
            if (_hasValue(cart.appliedDiscountAmount))
              _BillRow(label: 'Discount', value: cart.appliedDiscountAmount),
            if (_hasValue(cart.appliedDeliveryCharge))
              _BillRow(
                label: 'Delivery charges',
                value: cart.appliedDeliveryCharge,
                prefixPlus: true,
              ),
            if (_hasValue(displayTip))
              _BillRow(
                label: 'Delivery tips',
                value: displayTip,
                prefixPlus: true,
              ),
            if (cart.taxes.isNotEmpty || _hasValue(cart.appliedTaxAmount))
              Column(
                children: [
                  InkWell(
                    onTap: cart.taxes.length > 1
                        ? () => setState(() => _taxesExpanded = !_taxesExpanded)
                        : null,
                    child: _BillRow(
                      label: 'Applied taxes',
                      value: cart.appliedTaxAmount,
                      prefixPlus: true,
                      trailing: cart.taxes.length > 1
                          ? Icon(
                              _taxesExpanded
                                  ? Icons.keyboard_arrow_up
                                  : Icons.keyboard_arrow_down,
                              size: 18,
                            )
                          : null,
                    ),
                  ),
                  if (_taxesExpanded)
                    for (final tax in cart.taxes)
                      if (_hasValue(tax.amount))
                        Padding(
                          padding: const EdgeInsets.only(left: 12),
                          child: _BillRow(
                            label: tax.name,
                            value: tax.amount,
                            prefixPlus: true,
                          ),
                        ),
                ],
              ),
          ],
          if (widget.isWalletUsed && widget.usedWalletAmount > 0)
            _BillRow(
              label: 'Wallet Balance',
              value: widget.usedWalletAmount.toStringAsFixed(2),
              prefixMinus: true,
              valueColor: Colors.green.shade700,
            ),
          if (_hasValue(cart.promotionWalletAmount)) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xD0F4F4F4),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Column(
                children: [
                  _BillRow(
                    label: 'Tizola Wallet',
                    value: cart.promotionWalletAmount,
                    valueColor: AppColors.secondaryBrand,
                    labelBold: true,
                  ),
                  _BillRow(
                    label: 'Payable Amount',
                    value: finalPayable <= 0 ? 'FREE' : finalPayable.toStringAsFixed(2),
                    labelBold: true,
                    valueColor: AppColors.secondaryBrand,
                    suffixLabel: '(Roundoff)',
                    hideCurrencyOnFree: true,
                  ),
                ],
              ),
            ),
          ] else ...[
            const SizedBox(height: 8),
            _BillRow(
              label: 'Payable Amount',
              value: finalPayable <= 0 ? 'FREE' : finalPayable.toStringAsFixed(2),
              isBold: true,
              valueColor: AppColors.secondaryBrand,
              hideCurrencyOnFree: true,
            ),
          ],
        ],
      ),
    );
  }

  bool _hasValue(String? value) =>
      value != null && value.isNotEmpty && value != '0' && value != '0.00';
}

class _BillRow extends StatelessWidget {
  const _BillRow({
    required this.label,
    required this.value,
    this.isBold = false,
    this.labelBold = false,
    this.prefixPlus = false,
    this.prefixMinus = false,
    this.valueColor,
    this.suffixLabel,
    this.trailing,
    this.hideCurrencyOnFree = false,
  });

  final String label;
  final String? value;
  final bool isBold;
  final bool labelBold;
  final bool prefixPlus;
  final bool prefixMinus;
  final Color? valueColor;
  final String? suffixLabel;
  final Widget? trailing;
  final bool hideCurrencyOnFree;

  @override
  Widget build(BuildContext context) {
    final showCurrency = !(hideCurrencyOnFree && value == 'FREE');

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: suffixLabel != null ? 6 : 1,
            child: Text(
              label,
              style: TextStyle(
                fontWeight:
                    isBold || labelBold ? FontWeight.bold : FontWeight.normal,
                fontSize: 13,
              ),
            ),
          ),
          if (suffixLabel != null)
            Expanded(
              flex: 5,
              child: Text(
                suffixLabel!,
                textAlign: TextAlign.end,
                style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
              ),
            ),
          Text(
            '${prefixPlus ? '+ ' : ''}${prefixMinus ? '- ' : ''}${showCurrency ? '₹ ' : ''}${value ?? '0'}',
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              fontSize: 13,
              color: valueColor ?? (isBold ? AppColors.brand : null),
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
