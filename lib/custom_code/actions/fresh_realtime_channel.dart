// fresh_realtime_channel.dart
// Returns a realtime channel that is safe to subscribe to, even if the calling
// action runs more than once in a session.
//
// Why this exists: Supabase caches channels by name, so `client.channel('x')`
// returns the SAME instance on a second call. Subscribing to it again throws
// "tried to subscribe multiple times. 'subscribe' can only be called a single time
// per channel instance", and the follow-on failure surfaces as
// "RangeError (length): Invalid value: Only valid value is 0: 1".
//
// The loading page can legitimately run twice (the router redirects on auth state
// change while an explicit navigation is also in flight), so the realtime init
// actions must be idempotent rather than assuming a single invocation.

import '/backend/supabase/supabase.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

/// How many times each logical channel name has been handed out this session.
final Map<String, int> _channelSequence = <String, int>{};

/// The channel most recently returned for each logical name, so it can be torn
/// down when a replacement is requested.
final Map<String, RealtimeChannel> _lastChannel = <String, RealtimeChannel>{};

/// Drop-in replacement for `client.channel(name)`.
///
/// The first call returns `name` unchanged. Every later call for the same name
/// returns a channel under a NEW topic (`name#2`, `name#3`, ...), which guarantees
/// a never-subscribed instance.
///
/// Deliberately does NOT rely on awaiting `removeChannel()`: that method is async,
/// and an earlier version of this helper called it fire-and-forget then immediately
/// asked for `client.channel(name)` again - which still returned the cached,
/// already-subscribed instance and threw. Using a fresh topic removes the race
/// entirely and keeps this function synchronous, so call sites need no changes.
RealtimeChannel freshRealtimeChannel(SupabaseClient client, String name) {
  // Tear down the previous generation. Safe to fire-and-forget now, because the
  // channel we are about to create uses a different topic either way.
  final previous = _lastChannel[name];
  if (previous != null) {
    client.removeChannel(previous);
  }

  final generation = (_channelSequence[name] ?? 0) + 1;
  _channelSequence[name] = generation;

  final topic = generation == 1 ? name : '$name#$generation';
  final channel = client.channel(topic);
  _lastChannel[name] = channel;
  return channel;
}

/// Clears the registry - call on sign-out so a new session starts clean.
void resetRealtimeChannelRegistry() {
  _channelSequence.clear();
  _lastChannel.clear();
}
