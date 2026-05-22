/// Runs [action] and returns [fallback] on timeout or any error.
Future<T> runWithTimeout<T>(
  Future<T> Function() action, {
  required Duration timeout,
  required T fallback,
}) async {
  try {
    return await action().timeout(timeout);
  } catch (_) {
    return fallback;
  }
}
