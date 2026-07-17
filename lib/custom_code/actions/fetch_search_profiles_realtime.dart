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

// Imports (keep as-is for FlutterFlow compatibility)
import '/flutter_flow/custom_functions.dart';
import '/custom_code/actions/index.dart';

// Realtime listener guard
bool _searchProfilesListenerInitialized = false;

Future<void> fetchSearchProfilesRealtime(String searchText) async {
  final supabase = Supabase.instance.client;
  print("🔍 fetchSearchProfilesRealtime('$searchText') called");

  try {
    final response = await supabase.rpc('search_public_user_profiles', params: {
      'search_text': searchText,
    });

    if (response != null && response is List) {
      final results =
          response.map((r) => Map<String, dynamic>.from(r)).toList();
      FFAppState().update(() {
        FFAppState().AsPublicProfile = results; // ✅ Updated app state name
      });

      print("✅ Search results updated (${results.length} users)");
    } else {
      FFAppState().update(() {
        FFAppState().AsPublicProfile = []; // ✅ Updated app state name
      });
      print("⚠️ No users found matching '$searchText'");
    }
  } catch (e) {
    print("❌ Error during search: $e");
  }

  // Optional: Real-time updates on profile changes (e.g., name updates)
  if (!_searchProfilesListenerInitialized) {
    _searchProfilesListenerInitialized = true;

    supabase
        .channel('public_user_profile_search')
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'public_user_profile',
          callback: (payload) {
            print("🔄 Profile update detected, refreshing search");
            fetchSearchProfilesRealtime(searchText);
          },
        )
        .subscribe();

    print("📡 Listening to real-time 'public_user_profile' changes");
  }
}
