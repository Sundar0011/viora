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

Future initRealtimeNeighbourhoodPostUpdates() async {
  final client = Supabase.instance.client;

  // Use a unique channel name to avoid conflicts with other subscriptions
  final channel = client.channel('neighbourhood_post_updates');

  channel
      .onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'post',
        callback: (payload) {
          try {
            final eventType = payload.eventType;
            final newRow = payload.newRecord;
            final oldRow = payload.oldRecord;

            print('📡 Realtime Event Type: ${eventType}');
            print('🆕 New record: $newRow');
            print('🗑️ Old record: $oldRow');

            // Check if newRow is valid for INSERT/UPDATE
            if (eventType != PostgresChangeEvent.delete &&
                (newRow == null || newRow['id'] == null)) {
              print('❌ Invalid payload: newRow or ID is null');
              return;
            }

            // Check if oldRow is valid for DELETE
            if (eventType == PostgresChangeEvent.delete &&
                (oldRow == null || oldRow['id'] == null)) {
              print('❌ Invalid DELETE payload: oldRow or ID is null');
              return;
            }

            FFAppState().update(() {
              final posts = List<Map<String, dynamic>>.from(
                  FFAppState().NeighbourHoodPost);

              if (eventType == PostgresChangeEvent.insert ||
                  eventType == PostgresChangeEvent.update) {
                final postId = newRow['id'];
                print(
                    '🔄 Processing ${eventType.name.toUpperCase()} for post ID: $postId');

                final existingIndex =
                    posts.indexWhere((p) => p['post_id'] == postId);

                if (existingIndex != -1) {
                  // Post found in app state - perform smart merge
                  final existingPost =
                      Map<String, dynamic>.from(posts[existingIndex]);

                  print('📋 BEFORE MERGING:');
                  print('   Post ID: $postId');
                  print('   Existing data: $existingPost');

                  // Smart merge - Update only the fields that exist in newRow
                  for (final key in newRow.keys) {
                    final newValue = newRow[key];

                    // Skip null values to preserve existing enriched data
                    if (newValue == null) {
                      print('⏭️ Skipping null value for key: $key');
                      continue;
                    }

                    // Map database field names to app state field names if needed
                    String mappedKey = key == 'id' ? 'post_id' : key;

                    // Special handling for count fields
                    if (_isCountField(mappedKey)) {
                      final existingCount = _toInt(existingPost[mappedKey]);
                      final newCount = _toInt(newValue);

                      // Don't overwrite positive counts with 0 (prevents race conditions)
                      if (newCount == 0 && existingCount > 0) {
                        print(
                            '⏭️ Preserving existing count for $mappedKey: $existingCount (new was 0)');
                        continue;
                      }
                    }

                    existingPost[mappedKey] = newValue;
                  }

                  posts[existingIndex] = existingPost;

                  print('📋 AFTER MERGING:');
                  print('   Post ID: $postId');
                  print('   Updated data: $existingPost');
                  print('✅ Merged data for existing post: $postId');
                } else {
                  // Post not found in app state - ignore the update
                  print(
                      '⏭️ Post $postId not found in app state, ignoring ${eventType.name.toUpperCase()}');
                }
              } else if (eventType == PostgresChangeEvent.delete) {
                final postId = oldRow['id'];
                print('🗑️ Deleting post with ID: $postId');

                final existingIndex =
                    posts.indexWhere((p) => p['post_id'] == postId);

                if (existingIndex != -1) {
                  posts.removeAt(existingIndex);
                  print('✅ Deleted post: $postId');
                } else {
                  print('⚠️ Post $postId not found for deletion');
                }
              }

              FFAppState().NeighbourHoodPost = posts;
              print('✅ Updated NeighbourHoodPost with ${posts.length} posts');
            });

            // 🔥 CRITICAL: Force UI to rebuild after state change
            // This ensures all widgets listening to FFAppState get updated
            WidgetsBinding.instance.addPostFrameCallback((_) {
              // Trigger a rebuild of widgets that depend on this app state
              FFAppState().notifyListeners();
            });

            print('🔄 UI refresh triggered');
          } catch (e) {
            print('❌ Error in realtime callback: $e');
          }
        },
      )
      .subscribe();

  print(
      '🎧 Realtime subscription initialized for post table with channel: neighbourhood_post_updates');
}

// Helper function to check if a field is a count field
bool _isCountField(String key) {
  return key == 'likes_count' ||
      key == 'comment_count' ||
      key == 'share_count' ||
      key == 'views_count' ||
      key.endsWith('_count');
}

// Helper function to safely convert values to int
int _toInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is double) return value.round();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}
