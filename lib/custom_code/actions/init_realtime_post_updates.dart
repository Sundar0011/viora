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

Future initRealtimePostUpdates() async {
  final client = Supabase.instance.client;

  // Use a unique channel name to avoid conflicts with other subscriptions
  final channel = client.channel('post_updates_realtime_feed');

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
              final posts =
                  List<Map<String, dynamic>>.from(FFAppState().AsPost);

              if (eventType == PostgresChangeEvent.insert ||
                  eventType == PostgresChangeEvent.update) {
                final postId = newRow['id'];
                print(
                    '🔄 Processing ${eventType.name.toUpperCase()} for post ID: $postId');

                final existingIndex =
                    posts.indexWhere((p) => p['id'] == postId);

                if (existingIndex != -1) {
                  // Post found in app state - perform smart merge
                  final existingPost =
                      Map<String, dynamic>.from(posts[existingIndex]);

                  // Smart merge - Update only the fields that exist in newRow
                  for (final key in newRow.keys) {
                    final newValue = newRow[key];

                    // Skip null values to preserve existing enriched data
                    if (newValue == null) {
                      print('⏭️ Skipping null value for key: $key');
                      continue;
                    }

                    // FIXED: More intelligent count field handling
                    if (_isCountField(key)) {
                      final existingCount = _toInt(existingPost[key]);
                      final newCount = _toInt(newValue);
                      final oldCount =
                          oldRow != null ? _toInt(oldRow[key]) : null;

                      print(
                          '📊 Count update for $key: existing=$existingCount, new=$newCount, old=$oldCount');

                      // Option 1: Trust the database completely (Recommended)
                      // Always use the new count from the database
                      existingPost[key] = newValue;
                      print('✅ Updated $key from $existingCount to $newCount');

                      // Option 2: More sophisticated race condition protection (Alternative)
                      // Uncomment below and comment out the above if you want more protection
                      /*
                      // Only prevent overwriting if:
                      // 1. We have old data to compare against
                      // 2. The old count matches our existing count (no race condition)
                      // 3. The change seems suspicious (going to 0 when we expect a decrease)
                      if (oldCount != null && 
                          existingCount == oldCount && 
                          newCount == 0 && 
                          existingCount > 1) {
                        print('⚠️ Suspicious count change for $key, keeping existing: $existingCount');
                      } else {
                        existingPost[key] = newValue;
                        print('✅ Updated $key from $existingCount to $newCount');
                      }
                      */
                    } else {
                      existingPost[key] = newValue;
                    }
                  }

                  posts[existingIndex] = existingPost;
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
                    posts.indexWhere((p) => p['id'] == postId);

                if (existingIndex != -1) {
                  posts.removeAt(existingIndex);
                  print('✅ Deleted post: $postId');
                } else {
                  print('⚠️ Post $postId not found for deletion');
                }
              }

              FFAppState().AsPost = posts;

              // GLOBAL STATE DEBUG
              print('🌍 === GLOBAL STATE UPDATE DEBUG ===');
              print('🌍 Total posts in FFAppState().AsPost: ${posts.length}');
              final updatedPost = posts.firstWhere(
                  (p) => p['id'] == (newRow?['id'] ?? oldRow?['id']),
                  orElse: () => {});
              if (updatedPost.isNotEmpty) {
                print('🌍 Updated post in global state:');
                updatedPost.forEach((key, value) {
                  if (_isCountField(key)) {
                    print('🌍   $key: $value (type: ${value.runtimeType})');
                  }
                });
              }
              print('🌍 === END GLOBAL STATE DEBUG ===');

              print('✅ Updated AsPost with ${posts.length} posts');
            });
          } catch (e) {
            print('❌ Error in realtime callback: $e');
          }
        },
      )
      .subscribe();

  // Realtime subscription initialized
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
