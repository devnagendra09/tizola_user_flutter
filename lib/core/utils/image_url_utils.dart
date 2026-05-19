/// Normalizes API image paths to absolute URLs (many responses use relative paths).
String? resolvePublicImageUrl(String? raw) {
  if (raw == null) return null;
  final t = raw.trim();
  if (t.isEmpty || t == 'null') return null;
  final lower = t.toLowerCase();
  if (lower.startsWith('http://') || lower.startsWith('https://')) return t;
  if (t.startsWith('//')) return 'https:$t';
  if (t.startsWith('/')) return 'https://tizola.in$t';
  return 'https://tizola.in/$t';
}
