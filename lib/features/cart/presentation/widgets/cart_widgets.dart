import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/network_image_box.dart';
import '../../domain/entities/cart_entity.dart';

class CartItemTile extends StatelessWidget {
  const CartItemTile({
    super.key,
    required this.item,
    required this.onIncrement,
    required this.onDecrement,
    this.isBusy = false,
  });

  final CartItemEntity item;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          NetworkImageBox(
            url: item.image,
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
                  item.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                if (item.customization.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      item.customization,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                const SizedBox(height: 4),
                Text(
                  '₹${item.applicablePrice.toStringAsFixed(0)}',
                  style: const TextStyle(
                    color: AppColors.brand,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: AppColors.brand,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _QtyBtn(
                  icon: Icons.remove,
                  onTap: isBusy ? null : onDecrement,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    '${item.quantity}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _QtyBtn(
                  icon: Icons.add,
                  onTap: isBusy ? null : onIncrement,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QtyBtn extends StatelessWidget {
  const _QtyBtn({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }
}

class CartCouponSection extends StatelessWidget {
  const CartCouponSection({
    super.key,
    required this.hasAppliedCoupon,
    required this.couponCode,
    required this.couponMessage,
    required this.hasCouponDiscount,
    required this.onApplyTap,
    required this.onTryAnotherTap,
  });

  final bool hasAppliedCoupon;
  final String? couponCode;
  final String? couponMessage;
  final bool hasCouponDiscount;
  final VoidCallback onApplyTap;
  final VoidCallback onTryAnotherTap;

  @override
  Widget build(BuildContext context) {
    if (hasAppliedCoupon) {
      return InkWell(
        onTap: onTryAnotherTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.brandLite),
            borderRadius: BorderRadius.circular(8),
            color: AppColors.brandLite.withValues(alpha: 0.3),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.local_offer, color: AppColors.brand, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      couponCode ?? '',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.brand,
                      ),
                    ),
                  ),
                  Text(
                    'Try another code!',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.red.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              if (couponMessage != null && couponMessage!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    couponMessage!,
                    style: TextStyle(
                      fontSize: 12,
                      color: hasCouponDiscount
                          ? Colors.green.shade700
                          : AppColors.error,
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onApplyTap,
        icon: const Icon(Icons.local_offer_outlined),
        label: const Text('Apply Coupon Code'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.brand,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }
}

class CartDeliveryTipsSection extends StatelessWidget {
  const CartDeliveryTipsSection({
    super.key,
    required this.tipAmounts,
    required this.selectedTip,
    required this.showCustomTipField,
    required this.customTipInput,
    required this.isBusy,
    required this.onTipSelected,
    required this.onToggleCustomTip,
    required this.onCustomTipChanged,
    required this.onCustomTipSubmitted,
    this.onClearTip,
  });

  final List<String> tipAmounts;
  final String? selectedTip;
  final bool showCustomTipField;
  final String customTipInput;
  final bool isBusy;
  final ValueChanged<String?> onTipSelected;
  final ValueChanged<bool> onToggleCustomTip;
  final ValueChanged<String> onCustomTipChanged;
  final VoidCallback onCustomTipSubmitted;
  final VoidCallback? onClearTip;

  bool get _hasSelectedTip =>
      (selectedTip != null && selectedTip!.isNotEmpty) ||
      (showCustomTipField && customTipInput.trim().isNotEmpty);

  @override
  Widget build(BuildContext context) {
    if (tipAmounts.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Add tip to your hunger saviour',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      'Show your appreciation for the delivery partner',
                      style: TextStyle(fontSize: 13, color: Colors.black87),
                    ),
                  ],
                ),
              ),
              if (_hasSelectedTip && onClearTip != null)
                TextButton(
                  onPressed: isBusy ? null : onClearTip,
                  child: const Text('Remove tip'),
                ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                ...tipAmounts.map((amount) {
                  final selected = selectedTip == amount && !showCustomTipField;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text('₹$amount'),
                      selected: selected,
                      onSelected: isBusy
                          ? null
                          : (picked) => onTipSelected(picked ? amount : null),
                      selectedColor: AppColors.brandLite,
                      labelStyle: TextStyle(
                        color: selected ? AppColors.brand : null,
                        fontWeight:
                            selected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  );
                }),
                ChoiceChip(
                  label: const Text('Custom'),
                  selected: showCustomTipField,
                  onSelected: isBusy
                      ? null
                      : (v) => onToggleCustomTip(v),
                  selectedColor: AppColors.brandLite,
                ),
              ],
            ),
          ),
          if (showCustomTipField) ...[
            const SizedBox(height: 8),
            TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Enter tip amount',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.check),
                  onPressed: isBusy ? null : onCustomTipSubmitted,
                ),
              ),
              onChanged: onCustomTipChanged,
              onSubmitted: (_) => onCustomTipSubmitted(),
            ),
          ],
        ],
      ),
    );
  }
}
