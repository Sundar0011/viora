// app_log.dart
// Debug-only logging helper for Viora/Flock.
// Replaces bare `print(...)` calls across the app so diagnostics stay visible
// during development but are stripped from release builds — bare `print` runs in
// release too, where it costs frame time on hot paths (realtime subscription
// handlers) and leaks user/session data into `adb logcat` and the Xcode Console.

import 'package:flutter/foundation.dart';

/// Logs a diagnostic message in debug builds only; a no-op in release/profile.
void appLog(Object? message) {
  if (kDebugMode) {
    debugPrint('$message');
  }
}

/// Logs a caught error (plus optional stack trace) in debug builds only.
/// Use inside `catch` blocks so the error is still surfaced to developers —
/// never swallow an error silently (CLAUDE.md §5).
void appLogError(Object? error, [StackTrace? stackTrace]) {
  if (kDebugMode) {
    debugPrint('ERROR: $error');
    if (stackTrace != null) {
      debugPrint('$stackTrace');
    }
  }
}
