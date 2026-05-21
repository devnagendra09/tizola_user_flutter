import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/service_order_entity.dart';

class ServiceOrderStatusTimeline extends StatelessWidget {
  const ServiceOrderStatusTimeline({super.key, required this.items});

  final List<ServiceOrderStatusLog> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Text('No status updates yet');
    }

    return Column(
      children: [
        for (var i = 0; i < items.length; i++)
          _TimelineRow(
            item: items[i],
            isLast: i == items.length - 1,
          ),
      ],
    );
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({required this.item, required this.isLast});

  final ServiceOrderStatusLog item;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final active = item.isActive;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: active ? AppColors.brand : Colors.grey.shade400,
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: Colors.grey.shade300,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.label,
                    style: TextStyle(
                      fontWeight:
                          active ? FontWeight.w600 : FontWeight.normal,
                      color: active ? AppColors.brand : Colors.black87,
                    ),
                  ),
                  if (item.dateTime != null && item.dateTime!.isNotEmpty)
                    Text(
                      item.dateTime!,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
