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

Future<void> loadFollowersRealTime(String searchQuery) async {
  final supabase = Supabase.instance.client;

  Future<void> fetchFollowers() async {
    final result = await supabase.rpc('get_followers', params: {
      'search_query': searchQuery,
    }).select();

    if (result != null) {
      FFAppState().update(() {
        FFAppState().followers = result;
        FFAppState().AsFollowersCount = result.length;
      });
    }
  }

  // Initial fetch
  await fetchFollowers();

  // Subscribe to real-time changes on follows and user profile
  final channel = supabase
      .channel('followers_subscription')
      .onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'follows',
        callback: (_) async {
          await fetchFollowers();
        },
      )
      .onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'public_user_profile',
        callback: (_) async {
          await fetchFollowers();
        },
      );

  channel.subscribe();
}
