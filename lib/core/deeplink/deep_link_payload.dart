import 'package:equatable/equatable.dart';

/// Parsed deep link for shared menu items (Android `RestaurantActivity.handleDeepLink`).
class ShareDeepLinkPayload extends Equatable {
  const ShareDeepLinkPayload({
    required this.seoUrl,
    required this.itemId,
    required this.uri,
  });

  final String seoUrl;
  final String itemId;
  final Uri uri;

  @override
  List<Object?> get props => [seoUrl, itemId, uri];
}
