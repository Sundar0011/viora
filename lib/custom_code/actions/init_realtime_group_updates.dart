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

Future initRealtimeGroupUpdates() async {
  final client = Supabase.instance.client;
  final currentUserId = client.auth.currentUser?.id;

  if (currentUserId == null) {
    print('❌ No authenticated user found');
    return;
  }

  print('🔧 Current user ID: $currentUserId');

  // Helper function to safely convert values to int
  int toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.round();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  // Get default user status for a group
  String getDefaultUserStatusForGroup(Map<String, dynamic> group) {
    final groupType = group['e_group_type'] ?? 'open';
    return groupType == 'private' ? 'request' : 'join';
  }

  // Calculate user status based on group_user_status data
  String calculateUserStatus(
      Map<String, dynamic>? statusData, Map<String, dynamic> existingGroup) {
    if (statusData == null) {
      return getDefaultUserStatusForGroup(existingGroup);
    }

    final isMember = statusData['is_member'] ?? false;
    final isRequested = statusData['is_requested'] ?? false;
    final isInvited = statusData['is_invited'] ?? false;

    // Preserve admin status if it was already set
    final currentStatus = existingGroup['user_status'] ?? 'join';
    if (currentStatus == 'admin' && isMember) {
      return 'admin';
    }

    if (isMember) {
      return 'joined';
    } else if (isRequested) {
      return 'requested';
    } else if (isInvited) {
      return 'invite';
    } else {
      return getDefaultUserStatusForGroup(existingGroup);
    }
  }

  // Use a unique channel name to avoid conflicts with other subscriptions
  final channel = client.channel('group_updates_realtime_feed');

  // Subscribe to group table changes
  channel
      .onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'group',
        callback: (payload) {
          try {
            final eventType = payload.eventType;
            final newRow = payload.newRecord;
            final oldRow = payload.oldRecord;

            print('📡 Realtime Event Type: ${eventType} on table: group');
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

            final groupId = newRow?['id'] ?? oldRow?['id'];

            FFAppState().update(() {
              final groups =
                  List<Map<String, dynamic>>.from(FFAppState().AsGroupList);

              if (eventType == PostgresChangeEvent.insert ||
                  eventType == PostgresChangeEvent.update) {
                print(
                    '🔄 Processing ${eventType.name.toUpperCase()} for group ID: $groupId');

                final existingIndex =
                    groups.indexWhere((g) => g['group_id'] == groupId);

                if (existingIndex != -1) {
                  // Group found in app state - perform smart merge
                  final existingGroup =
                      Map<String, dynamic>.from(groups[existingIndex]);

                  // Update basic group fields
                  for (final key in newRow.keys) {
                    final newValue = newRow[key];

                    // Skip null values to preserve existing enriched data
                    if (newValue == null) {
                      print('⏭️ Skipping null value for key: $key');
                      continue;
                    }

                    // Map database fields to app state fields
                    switch (key) {
                      case 'id':
                        existingGroup['group_id'] = newValue;
                        break;
                      case 'name':
                      case 'description':
                      case 'profile_picture':
                      case 'created_at':
                        existingGroup[key] = newValue;
                        break;
                      case 'total_members':
                        // Don't overwrite positive counts with 0 (prevents race conditions)
                        final existingCount = toInt(existingGroup[key]);
                        final newCount = toInt(newValue);
                        if (newCount == 0 && existingCount > 0) {
                          print(
                              '⏭️ Preserving existing total_members: $existingCount (new was 0)');
                          continue;
                        }
                        existingGroup[key] = newCount;
                        break;
                      case 'e_group_type':
                        existingGroup['e_group_type'] = newValue.toString();
                        break;
                      case 'e_discoverability':
                        existingGroup['e_discoverability'] =
                            newValue.toString();
                        break;
                    }
                  }

                  groups[existingIndex] = existingGroup;
                  print('✅ Merged data for existing group: $groupId');
                } else {
                  // Group not found in app state - ignore the update
                  print(
                      '⏭️ Group $groupId not found in app state, ignoring ${eventType.name.toUpperCase()}');
                }
              } else if (eventType == PostgresChangeEvent.delete) {
                // Delete the entire group
                print('🗑️ Deleting group with ID: $groupId');

                final existingIndex =
                    groups.indexWhere((g) => g['group_id'] == groupId);

                if (existingIndex != -1) {
                  groups.removeAt(existingIndex);
                  print('✅ Deleted group: $groupId');
                } else {
                  print('⚠️ Group $groupId not found for deletion');
                }
              }

              FFAppState().AsGroupList = groups;
              print('✅ Updated AsGroupList with ${groups.length} groups');
            });
          } catch (e) {
            print('❌ Error in group table callback: $e');
          }
        },
      )
      .subscribe();

  // Subscribe to group_user_status table changes
  channel
      .onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'group_user_status',
        callback: (payload) {
          try {
            final eventType = payload.eventType;
            final newRow = payload.newRecord;
            final oldRow = payload.oldRecord;

            print(
                '📡 Realtime Event Type: ${eventType} on table: group_user_status');

            // Only process if this affects the current user
            final affectedUserId = newRow?['user_id'] ?? oldRow?['user_id'];
            if (affectedUserId != currentUserId) {
              print('⏭️ Event not for current user, ignoring');
              return;
            }

            final groupId = newRow?['group_id'] ?? oldRow?['group_id'];
            if (groupId == null) {
              print('❌ No group_id found in payload');
              return;
            }

            print('🔄 Processing user status change for group: $groupId');

            FFAppState().update(() {
              final groups =
                  List<Map<String, dynamic>>.from(FFAppState().AsGroupList);
              final existingIndex =
                  groups.indexWhere((g) => g['group_id'] == groupId);

              if (existingIndex != -1) {
                final existingGroup =
                    Map<String, dynamic>.from(groups[existingIndex]);

                if (eventType == PostgresChangeEvent.delete) {
                  // User status removed - reset to default
                  existingGroup['user_status'] =
                      getDefaultUserStatusForGroup(existingGroup);
                } else {
                  // Recalculate user_status based on the new data
                  final newUserStatus =
                      calculateUserStatus(newRow, existingGroup);
                  existingGroup['user_status'] = newUserStatus;
                }

                groups[existingIndex] = existingGroup;
                print('✅ Updated user_status for group: $groupId');
              } else {
                print('⚠️ Group $groupId not found in app state');
              }

              FFAppState().AsGroupList = groups;
            });
          } catch (e) {
            print('❌ Error in group_user_status callback: $e');
          }
        },
      )
      .subscribe();

  // Subscribe to group_members_invite table changes
  channel
      .onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'group_members_invite',
        callback: (payload) {
          try {
            final eventType = payload.eventType;
            final newRow = payload.newRecord;
            final oldRow = payload.oldRecord;

            print(
                '📡 Realtime Event Type: ${eventType} on table: group_members_invite');

            // Only process if this affects the current user
            final invitedUserId =
                newRow?['invited_user'] ?? oldRow?['invited_user'];
            if (invitedUserId != currentUserId) {
              print('⏭️ Invite event not for current user, ignoring');
              return;
            }

            final groupId = newRow?['group_id'] ?? oldRow?['group_id'];
            if (groupId == null) {
              print('❌ No group_id found in invite payload');
              return;
            }

            print('🔄 Processing invite change for group: $groupId');

            FFAppState().update(() {
              final groups =
                  List<Map<String, dynamic>>.from(FFAppState().AsGroupList);
              final existingIndex =
                  groups.indexWhere((g) => g['group_id'] == groupId);

              if (existingIndex != -1) {
                final existingGroup =
                    Map<String, dynamic>.from(groups[existingIndex]);

                if (eventType == PostgresChangeEvent.insert) {
                  // New invite received
                  existingGroup['user_status'] = 'invite';
                  existingGroup['invited_by_user_id'] = newRow['invited_by'];
                  // Clear other invite fields that would need separate lookup
                  existingGroup['invited_by_name'] = null;
                  existingGroup['invited_by_profile_picture'] = null;
                  print(
                      '✅ Updated group with new invite from: ${newRow['invited_by']}');
                } else if (eventType == PostgresChangeEvent.update) {
                  // Invite status updated (e.g., accepted)
                  final isMember = newRow['is_member'] ?? false;
                  if (isMember) {
                    existingGroup['user_status'] = 'joined';
                    existingGroup['invited_by_user_id'] = null;
                    existingGroup['invited_by_name'] = null;
                    existingGroup['invited_by_profile_picture'] = null;
                    print('✅ Invite accepted, user now joined group: $groupId');
                  }
                } else if (eventType == PostgresChangeEvent.delete) {
                  // Invite withdrawn or processed
                  existingGroup['user_status'] =
                      getDefaultUserStatusForGroup(existingGroup);
                  existingGroup['invited_by_user_id'] = null;
                  existingGroup['invited_by_name'] = null;
                  existingGroup['invited_by_profile_picture'] = null;
                  print('✅ Invite removed for group: $groupId');
                }

                groups[existingIndex] = existingGroup;
                print('✅ Updated invite status for group: $groupId');
              } else {
                print('⚠️ Group $groupId not found in app state');
              }

              FFAppState().AsGroupList = groups;
            });
          } catch (e) {
            print('❌ Error in group_members_invite callback: $e');
          }
        },
      )
      .subscribe();

  print(
      '🎧 Realtime subscription initialized for group tables with channel: group_updates_realtime_feed');
}
