import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../utils/image_url_utils.dart';

class NetworkImageBox extends StatelessWidget {
  const NetworkImageBox({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  final String? url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final resolved = resolvePublicImageUrl(url);
    final child = (resolved == null || resolved.isEmpty)
        ? ColoredBox(
            color: AppColors.brandLite,
            child: Icon(
              Icons.restaurant,
              color: AppColors.brand.withValues(alpha: 0.5),
              size: (height ?? 48) * 0.5,
            ),
          )
        : CachedNetworkImage(
            imageUrl: resolved,
            width: width,
            height: height,
            fit: fit,
            placeholder: (context, url) => const ColoredBox(
              color: AppColors.brandLite,
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
            errorWidget: (context, url, error) => ColoredBox(
              color: AppColors.brandLite,
              child: Icon(
                Icons.broken_image,
                color: AppColors.brand.withValues(alpha: 0.5),
              ),
            ),
          );

    if (borderRadius != null) {
      return ClipRRect(borderRadius: borderRadius!, child: child);
    }
    return child;
  }
}
