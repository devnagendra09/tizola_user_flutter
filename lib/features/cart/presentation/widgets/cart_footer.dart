import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Android `viewFooter` — address block + proceed to checkout strip.
class CartFooter extends StatelessWidget {
  const CartFooter({
    super.key,
    required this.payableAmount,
    required this.isBusy,
    required this.onCheckout,
    this.deliveryAddress,
    this.showAddAddressButton = false,
    this.onAddAddress,
    this.onChangeAddress,
    this.hideAddress = false,
  });

  final String payableAmount;
  final bool isBusy;
  final VoidCallback onCheckout;
  final String? deliveryAddress;
  final bool showAddAddressButton;
  final VoidCallback? onAddAddress;
  final VoidCallback? onChangeAddress;
  final bool hideAddress;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showAddAddressButton && onAddAddress != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(15, 5, 15, 5),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isBusy ? null : onAddAddress,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.brand,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text(
                  'Add Delivery Address',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
        if (!hideAddress && !showAddAddressButton)
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: AppColors.brandLite,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Delivering to',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                          color: AppColors.obText,
                        ),
                      ),
                    ),
                    if (onChangeAddress != null)
                      TextButton(
                        onPressed: isBusy ? null : onChangeAddress,
                        style: TextButton.styleFrom(
                          backgroundColor: AppColors.error,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 4,
                          ),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text('Change'),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  deliveryAddress ?? 'Add delivery address',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
        Material(
          color: AppColors.secondaryBrand,
          child: InkWell(
            onTap: isBusy ? null : onCheckout,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'PROCEED TO PAYMENT',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          payableAmount,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isBusy)
                    const SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  else
                    Row(
                      children: [
                        Icon(Icons.arrow_forward_sharp,color: AppColors.white,size: 30,),
                      //  SizedBox(width: 15,),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 18.0),
                          child: const Icon(
                            Icons.shopping_cart_outlined,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),

                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
