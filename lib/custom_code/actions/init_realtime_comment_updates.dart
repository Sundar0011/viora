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

Future initRealtimeCommentUpdates() async {
  final client = Supabase.instance.client;
  final channel = client.channel('public:post_comment');

  channel
      .onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'post_comment',
        callback: (payload) async {
          final eventType = payload.eventType;
          final newRow = payload.newRecord;
          final oldRow = payload.oldRecord;

          print('📡 Comment Realtime Event Type: ${eventType}');
          print('🆕 New record: $newRow');
          print('🗑 Old record: $oldRow');

          // Check if newRow is valid
          if (newRow == null || newRow['id'] == null) {
            print('❌ Invalid payload: newRow or ID is null');
            return;
          }

          final commentId = newRow['id'];
          final bool isReply = newRow['parent_comment_id'] != null;

          // Create enriched row by fetching user profile data for INSERT and UPDATE
          Map<String, dynamic> enrichedRow = Map<String, dynamic>.from(newRow);

          if (eventType == PostgresChangeEvent.insert ||
              eventType == PostgresChangeEvent.update) {
            try {
              final userId = newRow['user_id'];
              final communityId = newRow['community_id'];

              print(
                  '👤 Fetching user profile for user_id: $userId, community_id: $communityId');

              final userProfileResponse = await client
                  .from('public_user_profile')
                  .select('name, profile_picture, city')
                  .eq('id', userId)
                  .eq('community_id', communityId)
                  .single();

              print('📋 User profile response: $userProfileResponse');

              // Add user profile data to enriched row
              enrichedRow['user_name'] =
                  userProfileResponse['name'] ?? 'Unknown User';
              enrichedRow['profile_picture'] =
                  userProfileResponse['profile_picture'];
              enrichedRow['user_city'] = userProfileResponse['city'];

              print('✅ User profile data merged successfully');
              print('🔍 Enriched row: $enrichedRow');
            } catch (e) {
              print('❌ Error fetching user profile: $e');
              // Set default values if profile fetch fails
              enrichedRow['user_name'] = 'Unknown User';
              enrichedRow['profile_picture'] = null;
              enrichedRow['user_city'] = null;
            }
          }

          FFAppState().update(() {
            // Get the appropriate list based on whether it's a reply or comment
            final List<Map<String, dynamic>> comments = isReply
                ? List<Map<String, dynamic>>.from(
                    FFAppState().AsCommentReplies ?? [])
                : List<Map<String, dynamic>>.from(
                    FFAppState().AsComments ?? []);

            final existingIndex =
                comments.indexWhere((item) => item['id'] == commentId);

            if (eventType == PostgresChangeEvent.insert) {
              print(
                  '➕ Inserting new ${isReply ? 'reply' : 'comment'} with ID: $commentId');
              // Remove if already exists to avoid duplicates, then add to top
              if (existingIndex != -1) {
                comments.removeAt(existingIndex);
                print('🔄 Removed duplicate before adding to top');
              }
              // Always insert at top (index 0) for new records
              comments.insert(0, enrichedRow);
              print('✅ Added enriched comment to TOP of list');
            } else if (eventType == PostgresChangeEvent.update) {
              print(
                  '🔄 Updating ${isReply ? 'reply' : 'comment'} with ID: $commentId');
              if (existingIndex != -1) {
                final existingComment =
                    Map<String, dynamic>.from(comments[existingIndex]);

                // Update with all fields from enriched row
                for (final key in enrichedRow.keys) {
                  final newValue = enrichedRow[key];

                  // Skip null values to preserve existing data (except for explicit null profile data)
                  if (newValue != null ||
                      key == 'profile_picture' ||
                      key == 'user_city') {
                    // All count fields will update properly including decreases to 0
                    existingComment[key] = newValue;
                  }
                }

                comments[existingIndex] = existingComment;
                print('✅ Updated existing comment with enriched data');
              } else {
                // If comment not found, add it to the TOP
                comments.insert(0, enrichedRow);
                print(
                    '✅ Added new enriched comment to TOP (not found in existing list)');
              }
            } else if (eventType == PostgresChangeEvent.delete) {
              print(
                  '🗑 Deleting ${isReply ? 'reply' : 'comment'} with ID: $commentId');
              if (existingIndex != -1) {
                comments.removeAt(existingIndex);
                print('✅ Comment deleted successfully');
              }
            }

            // ✅ ENSURE LIST IS ALWAYS SORTED WITH NEWEST FIRST
            // Sort by created_at in descending order (newest first)
            comments.sort((a, b) {
              final aCreatedAt = a['created_at'];
              final bCreatedAt = b['created_at'];

              if (aCreatedAt == null && bCreatedAt == null) return 0;
              if (aCreatedAt == null) return 1;
              if (bCreatedAt == null) return -1;

              try {
                final aDate = DateTime.parse(aCreatedAt.toString());
                final bDate = DateTime.parse(bCreatedAt.toString());
                return bDate
                    .compareTo(aDate); // Descending order (newest first)
              } catch (e) {
                print('⚠️ Error parsing dates for sorting: $e');
                return 0;
              }
            });

            // Update the appropriate app state
            if (isReply) {
              FFAppState().AsCommentReplies = comments;
            } else {
              FFAppState().AsComments = comments;
            }

            print(
                '✅ Updated ${isReply ? 'AsCommentReplies' : 'AsComments'} with ${comments.length} items');
            print(
                '📊 Final comment data: ${comments.isEmpty ? 'Empty' : comments[0]}');
          });
        },
      )
      .subscribe();

  print('🎧 Realtime subscription initialized for post_comment table');
}
