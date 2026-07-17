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

bool _matchedUsersListenerInitialized = false;

Future<void> fetchMatchedUsersRealtime(String searchQuery) async {
  final supabase = Supabase.instance.client;
  print("🔍 fetchMatchedUsersRealtimeSearch('$searchQuery') called");

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

      print("✅ Matched users updated (${results.length} found)");
    } else {
      print("⚠️ No matched users found.");
      FFAppState().update(() {
        FFAppState().matchedUsers = [];
      });
    }
  } catch (e) {
    print("❌ Error fetching matched users: $e");
  }

  // Step 2: Setup real-time listener (only once)
  if (!_matchedUsersListenerInitialized) {
    _matchedUsersListenerInitialized = true;

    final subscription = supabase.channel('matched_users_search_updates');

    subscription
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'messages',
          callback: (payload) {
            print("📩 Realtime update in messages");
            fetchMatchedUsersRealtime(searchQuery);
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'chat',
          callback: (payload) {
            print("💬 Realtime update in chat");
            fetchMatchedUsersRealtime(searchQuery);
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'public_user_profile',
          callback: (payload) {
            print("👤 Realtime update in user profile");
            fetchMatchedUsersRealtime(searchQuery);
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'chat_users',
          callback: (payload) {
            print("👤 Realtime update in user profile");
            fetchMatchedUsersRealtime(searchQuery);
          },
        )
        .subscribe();

    print("📡 Subscribed to realtime updates for matched users + search");
  }
}
