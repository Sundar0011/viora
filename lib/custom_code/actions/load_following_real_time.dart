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

import '/custom_code/actions/index.dart';
import '/flutter_flow/custom_functions.dart';

Future<void> loadFollowingRealTime(String searchQuery) async {
  final supabase = Supabase.instance.client;

  Future<void> fetchFollowing() async {
    final result = await supabase.rpc('get_following', params: {
      'search_query': searchQuery,
    }).select();

    if (result != null) {
      FFAppState().update(() {
        FFAppState().AsFollowingList = result;
        FFAppState().AsFollowingCount = result.length;
      });
    }
  }

  // Initial fetch
  await fetchFollowing();

  // Subscribe to real-time changes on follows and user profile
  final channel = supabase
      .channel('following_subscription')
      .onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'follows',
        callback: (_) async {
          await fetchFollowing();
        },
      )
      .onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'public_user_profile',
        callback: (_) async {
          await fetchFollowing();
        },
      );

  channel.subscribe();
}
