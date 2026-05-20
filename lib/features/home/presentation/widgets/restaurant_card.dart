import 'package:flutter/material.dart';

import '../../../../core/navigation/restaurant_navigation.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/food_type_indicator.dart';
import '../../../../core/widgets/network_image_box.dart';
import '../../../catalog/domain/entities/restaurant_entity.dart';

/// Restaurant list row matching Android `item_product.xml` / `ProductAdapter`.
class RestaurantCard extends StatelessWidget {
  const RestaurantCard({
    super.key,
    required this.restaurant,
    this.onTap,
  });

  final RestaurantEntity restaurant;
  final VoidCallback? onTap;

  static const double _imageSize = 90;

  @override
  Widget build(BuildContext context) {
    final rating = restaurant.rating;
    final showRating = rating != null && rating > 0;
    final openTime = restaurant.formattedOpenTime;
    final closeTime = restaurant.formattedCloseTime;
    final estimate = restaurant.estimateTime;
    final hasEstimate =
        estimate != null && estimate.isNotEmpty && !estimate.contains('null');
    final offer = restaurant.offer;
    final hasOffer =
        offer != null && offer.isNotEmpty && offer.toLowerCase() != 'null';

    return Card(
      margin: const EdgeInsets.fromLTRB(10, 5, 10, 5),
      elevation: 3,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap ?? () => openRestaurantDetail(context, restaurant),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(5),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _RestaurantImage(restaurant: restaurant),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  restaurant.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.brand,
                                  ),
                                ),
                              ),
                              if (showRating) ...[
                                const SizedBox(width: 10),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.brand,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                  child: Text(
                                    rating.toString(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          if (restaurant.cuisineTypes != null &&
                              restaurant.cuisineTypes!.isNotEmpty &&
                              restaurant.cuisineTypes!.toLowerCase() !=
                                  'null') ...[
                            const SizedBox(height: 2),
                            Text(
                              restaurant.cuisineTypes!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.descriptionText,
                              ),
                            ),
                          ],
                          if (hasOffer) ...[
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: AppColors.brand,
                                  radius: 8,
                                  child: Icon(
                                    Icons.percent_rounded,
                                    color: Colors.white,
                                    size: 10,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Expanded(
                                  child: Text(
                                    offer,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.offerText,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                          if (hasEstimate) ...[
                            const SizedBox(height: 5),
                            Row(
                              children: [
                                Icon(
                                  Icons.access_time,
                                  size: 14,
                                  color: Colors.grey.shade800,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  estimate,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey.shade900,
                                  ),
                                ),
                              ],
                            ),
                          ],
                          if (openTime != null || closeTime != null) ...[
                            const SizedBox(height: 5),
                            Wrap(
                              spacing: 5,
                              runSpacing: 2,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                if (openTime != null)
                                  Text(
                                    'Open : $openTime',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.vegGreen,
                                    ),
                                  ),
                                if (closeTime != null)
                                  Text(
                                    'Close : $closeTime',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.error,
                                    ),
                                  ),
                              ],
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
                child: ColoredBox(color: AppColors.closedOverlay),
              ),
          ],
        ),
      ),
    );
  }
}

class _RestaurantImage extends StatelessWidget {
  const _RestaurantImage({required this.restaurant});

  final RestaurantEntity restaurant;

  @override
  Widget build(BuildContext context) {
    Widget image = NetworkImageBox(
      url: restaurant.imageUrl,
      width: RestaurantCard._imageSize,
      height: RestaurantCard._imageSize,
      borderRadius: BorderRadius.circular(5),
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
      width: RestaurantCard._imageSize + 10,
      height: RestaurantCard._imageSize + 10,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Padding(
            padding: const EdgeInsets.all(5),
            child: image,
          ),
          // if (restaurant.isExclusive)
          //   Positioned(
          //     top: 8,
          //     left: 0,
          //     child: Container(
          //       padding: const EdgeInsets.only(
          //         left: 10,
          //         right: 10,
          //         top: 2,
          //         bottom: 2,
          //       ),
          //       decoration: BoxDecoration(
          //         color: AppColors.brand,
          //         borderRadius: const BorderRadius.only(
          //           topRight: Radius.circular(4),
          //           bottomRight: Radius.circular(4),
          //         ),
          //       ),
          //       child: const Text(
          //         'Exclusive',
          //         style: TextStyle(
          //           color: Colors.white,
          //           fontSize: 10,
          //           fontWeight: FontWeight.bold,
          //         ),
          //       ),
          //     ),
          //   ),
          Positioned(
            right: 7,
            bottom: 7,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (restaurant.showNonVegBadge)
                  const Padding(
                    padding: EdgeInsets.only(right: 2),
                    child: FoodTypeIndicator(isVeg: false, size: 15),
                  ),
                if (restaurant.showVegBadge)
                  const FoodTypeIndicator(isVeg: true, size: 15),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
