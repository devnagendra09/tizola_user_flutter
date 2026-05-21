import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/network_image_box.dart';
import '../../domain/entities/cart_entity.dart';

/// Android `item_gateway.xml` — selectable payment method row.
class PaymentGatewayTile extends StatelessWidget {
  const PaymentGatewayTile({
    super.key,
    required this.option,
    required this.selected,
    required this.onTap,
  });

  final PaymentOptionEntity option;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      child: Stack(
        children: [
          InkWell(
            onTap: option.enabled ? onTap : null,
            borderRadius: BorderRadius.circular(5),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Icon(
                    selected
                        ? Icons.radio_button_checked
                        : Icons.radio_button_off,
                    color: selected ? AppColors.brand : Colors.grey,
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 50,
                    height: 30,
                    child: (option.imageUrl ?? '').isNotEmpty
                        ? NetworkImageBox(
                            url: option.imageUrl,
                            width: 50,
                            height: 30,
                            borderRadius: BorderRadius.circular(4),
                          )
                        : Icon(
                            option.isCod
                                ? Icons.payments_outlined
                                : Icons.credit_card,
                            color: AppColors.brand,
                          ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      option.label,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (!option.enabled)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
