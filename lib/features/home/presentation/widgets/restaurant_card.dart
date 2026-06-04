import 'package:flutter/material.dart';

import '../../../../core/navigation/restaurant_navigation.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/network_image_box.dart';
import '../../../catalog/domain/entities/restaurant_entity.dart';

/// Restaurant row styled like Zomato/Swiggy home list (reference design).
class RestaurantCard extends StatelessWidget {
  const RestaurantCard({
    super.key,
    required this.restaurant,
    this.onTap,
  });

  final RestaurantEntity restaurant;
  final VoidCallback? onTap;

  static const double _imageSize = 88;
  static const double _imageWidthSize = 120;

  @override
  Widget build(BuildContext context) {
    final rating = restaurant.rating;
    final showRating = rating != null && rating > 0;
    final estimate = restaurant.estimateTime;
    final hasEstimate =
        estimate != null && estimate.isNotEmpty && !estimate.contains('null');
    final distance = restaurant.distance;
    final hasDistance =
        distance != null && distance.isNotEmpty && !distance.contains('null');
    final offer = restaurant.offer;
    final hasOffer =
        offer != null && offer.isNotEmpty && offer.toLowerCase() != 'null';

    final metaLine = <String>[
      if (restaurant.cuisineTypes != null &&
          restaurant.cuisineTypes!.isNotEmpty &&
          restaurant.cuisineTypes!.toLowerCase() != 'null')
        restaurant.cuisineTypes!,
    ].join(' • ');

    final deliveryLine = <String>[
      if (hasEstimate) estimate,
    //  if (hasDistance) distance,
    ].join(' • ');
    final distanceLine = <String>[
     // if (hasEstimate) estimate,
        if (hasDistance) distance,
    ].join(' • ');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Material(
        color: Colors.white,
        elevation: 1,
        shadowColor: Colors.blueAccent.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap ?? () => openRestaurantDetail(context, restaurant),
          borderRadius: BorderRadius.circular(14),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _RestaurantImage(
                      restaurant: restaurant,
                      showRating: showRating,
                      rating: rating,
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    restaurant.name,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                      letterSpacing: -0.2,
                                      height: 1.2,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                _OpenStatusPill(isOpen: restaurant.isOpen),
                              ],
                            ),
                            if (metaLine.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                metaLine,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                            if (deliveryLine.isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Icon(
                                    Icons.access_time,
                                    size: 14,
                                    color: Colors.grey.shade600,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    deliveryLine,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                  SizedBox(width: 5,),
                                  const SizedBox(width: 4,
                                  child: Divider(height: 10,color: Colors.grey,),
                                  ),
                                  SizedBox(width: 5,),

                                  Icon(
                                    Icons.location_on,
                                    size: 14,
                                    color: Colors.grey.shade600,
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    distanceLine,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  )
                                ],
                              ),
                            ],
                            if (hasOffer) ...[
                              const SizedBox(height: 8),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFEBEE),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.local_offer_outlined,
                                      size: 14,
                                      color: Colors.red.shade700,
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        offer,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFFC62828),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (!restaurant.isOpen)
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: ColoredBox(color: AppColors.closedOverlay),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OpenStatusPill extends StatelessWidget {
  const _OpenStatusPill({required this.isOpen});

  final bool isOpen;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isOpen ? const Color(0xFFE8F5E9) : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        isOpen ? 'OPEN' : 'CLOSED',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: isOpen ? AppColors.vegGreen : Colors.grey.shade600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _RestaurantImage extends StatelessWidget {
  const _RestaurantImage({
    required this.restaurant,
    required this.showRating,
    required this.rating,
  });

  final RestaurantEntity restaurant;
  final bool showRating;
  final double? rating;

  @override
  Widget build(BuildContext context) {
    Widget image = ClipRRect(
      borderRadius: BorderRadius.only(topLeft:Radius.circular( 10),bottomLeft: Radius.circular(10)),
      child: NetworkImageBox(
        url: restaurant.imageUrl,
        width: RestaurantCard._imageWidthSize,
        height: RestaurantCard._imageSize,
        fit: BoxFit.cover,
      ),
    );

    if (!restaurant.isOpen) {
      image = ColorFiltered(
        colorFilter: const ColorFilter.matrix(<double>[
          0.2126, 0.7152, 0.0722, 0, 0,
          0.2126, 0.7152, 0.0722, 0, 0,
          0.2126, 0.7152, 0.0722, 0, 0,
          0, 0, 0, 1, 0,
        ]),
        child: image,
      );
    }

    return SizedBox(
      width: RestaurantCard._imageWidthSize,
      height: RestaurantCard._imageSize,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          image,
          if (showRating)
            Positioned(
              top: 6,
              left: 6,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.vegGreen,
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star, color: Colors.white, size: 12),
                    const SizedBox(width: 2),
                    Text(
                      rating!.toStringAsFixed(1),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
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
