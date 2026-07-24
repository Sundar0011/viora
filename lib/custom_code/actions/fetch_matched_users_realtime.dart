// Automatic FlutterFlow imports
import '/backend/schema/enums/enums.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

// FlutterFlow + Supabase Custom Actio

import '/flutter_flow/custom_functions.dart';
import '/custom_code/actions/index.dart';
import '/flutter_flow/app_log.dart';

bool _matchedUsersListenerInitialized = false;

Future<void> fetchMatchedUsersRealtime(String searchQuery) async {
  final supabase = Supabase.instance.client;
  appLog("🔍 fetchMatchedUsersRealtimeSearch('$searchQuery') called");

  try {
    final response = await supabase.rpc('get_chat', params: {
      'search_query': searchQuery,
    });

    if (response != null && response is List) {
      final results =
          response.map((r) => Map<String, dynamic>.from(r)).toList();

      FFAppState().update(() {
        FFAppState().matchedUsers = results;
      });

      appLog("✅ Matched users updated (${results.length} found)");
    } else {
      appLog("⚠️ No matched users found.");
      FFAppState().update(() {
        FFAppState().matchedUsers = [];
      });
    }
  } catch (e) {
    appLog("❌ Error fetching matched users: $e");
  }

  // Step 2: Setup real-time listener (only once)
  if (!_matchedUsersListenerInitialized) {
    _matchedUsersListenerInitialized = true;

    final subscription =
        freshRealtimeChannel(supabase, 'matched_users_search_updates');

    subscription
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'messages',
          callback: (payload) {
            appLog("📩 Realtime update in messages");
            fetchMatchedUsersRealtime(searchQuery);
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'chat',
          callback: (payload) {
            appLog("💬 Realtime update in chat");
            fetchMatchedUsersRealtime(searchQuery);
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'public_user_profile',
          callback: (payload) {
            appLog("👤 Realtime update in user profile");
            fetchMatchedUsersRealtime(searchQuery);
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'chat_users',
          callback: (payload) {
            appLog("👤 Realtime update in user profile");
            fetchMatchedUsersRealtime(searchQuery);
          },
        )
        .subscribe();

    appLog("📡 Subscribed to realtime updates for matched users + search");
  }
}
