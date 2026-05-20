import 'deep_link_payload.dart';

/// Parses `https://tizola.in/share/{seoUrl}/{itemId}` (see Android + SEO_URL_SHARING_GUIDE).
ShareDeepLinkPayload? parseShareDeepLink(Uri? uri) {
  if (uri == null) return null;

  final scheme = uri.scheme.toLowerCase();
  if (scheme != 'https' && scheme != 'http') return null;

  final host = uri.host.toLowerCase();
  if (host != 'tizola.in' && host != 'www.tizola.in') return null;

  final segments = uri.pathSegments;
  if (segments.isEmpty || segments.first.toLowerCase() != 'share') {
    return null;
  }
  if (segments.length < 3) return null;

  final seoUrl = segments[1].trim();
  final itemId = segments[2].trim();
  if (seoUrl.isEmpty || itemId.isEmpty) return null;

  return ShareDeepLinkPayload(
    seoUrl: seoUrl,
    itemId: itemId,
    uri: uri,
  );
}
