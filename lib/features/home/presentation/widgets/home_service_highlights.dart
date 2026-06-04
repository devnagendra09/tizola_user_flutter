import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class HomeServiceHighlights extends StatelessWidget {
  const HomeServiceHighlights({super.key});

  static const _items = [
    _Highlight(
      icon: Icons.local_offer_outlined,
      title: '50% OFF',
      subtitle: 'On first order',
      color: Color(0xFFFFF3E0),
      iconColor: Color(0xFFE65100),
      borderColor: Color(0xFFFFC107),
    ),
    _Highlight(
      icon: Icons.delivery_dining_outlined,
      title: 'Free Delivery',
      subtitle: 'On select stores',
      color: Color(0xFFE8F5E9),
      iconColor: AppColors.vegGreen,
      borderColor:Color(0xFF4CAF50),
    ),
    // _Highlight(
    //   icon: Icons.replay_outlined,
    //   title: 'Easy Returns',
    //   subtitle: 'Hassle-free',
    //   color: Color(0xFFE3F2FD),
    //   iconColor: AppColors.brand,
    // ),
    _Highlight(
      icon: Icons.card_giftcard_outlined,
      title: 'Best Offers',
      subtitle: 'Daily deals',
      color: Color(0xFFFCE4EC),
      iconColor: Color(0xFFC2185B),
      borderColor: Color(0xFFE91E63),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 65,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 15),
        itemCount: _items.length,
        separatorBuilder: (_, index) => const SizedBox(width: 10),
        itemBuilder: (_, i) {
          final item = _items[i];
          return Container(
            width: 120,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: item.color,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: item.borderColor ?? Colors.transparent, width: 1),
              boxShadow: [
                BoxShadow(
                  color: item.borderColor?.withValues(alpha: 0.1) ?? Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(2, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(item.icon, color: item.iconColor, size: 26),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        item.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        item.subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Highlight {
  const _Highlight({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.iconColor,
     this.borderColor,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final Color iconColor;
  final Color? borderColor;
}
