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

// FlutterFlow Custom Action: manageGroupsRealtime
// Action Name: manageGroupsRealtime
// Return Type: JSON
// Parameters: communityId (int), actionType (String)

import 'package:supabase_flutter/supabase_flutter.dart';

// Global state management
class GroupsStateManager {
  static List<Map<String, dynamic>> _groupsList = [];
  static List<RealtimeChannel> _subscriptions = [];
  static bool _isInitialized = false;

  // Initialize groups and setup realtime
  static Future<List<Map<String, dynamic>>> initializeGroups(
      int communityId) async {
    print('🚀 [GROUPS] Initializing groups for community: $communityId');

    try {
      print(
          '📞 [GROUPS] Calling RPC function: get_all_groups_with_user_status');

      // Fetch initial data
      final response = await Supabase.instance.client
          .rpc('get_all_groups_with_user_status', params: {
        'p_community_id': communityId,
      });

      print('📥 [GROUPS] RPC Response received: ${response?.runtimeType}');

      if (response != null) {
        _groupsList = List<Map<String, dynamic>>.from(response);
        print(
            '✅ [GROUPS] Groups loaded successfully: ${_groupsList.length} groups');

        // Log first few groups for debugging
        if (_groupsList.isNotEmpty) {
          print('📋 [GROUPS] First group sample:');
          print('   - ID: ${_groupsList[0]['group_id']}');
          print('   - Name: ${_groupsList[0]['group_name']}');
          print('   - Status: ${_groupsList[0]['user_status']}');
          print('   - Members: ${_groupsList[0]['total_members']}');
        }

        // Setup realtime if not already done
        if (!_isInitialized) {
          print('🔄 [GROUPS] Setting up realtime subscriptions...');
          await _setupRealtime(communityId);
          _isInitialized = true;
          print('✅ [GROUPS] Realtime setup completed');
        } else {
          print('ℹ️ [GROUPS] Realtime already initialized');
        }
      } else {
        print('❌ [GROUPS] No response from RPC function');
      }

      return _groupsList;
    } catch (e) {
      print('💥 [GROUPS] Error initializing groups: $e');
      print('📍 [GROUPS] Error type: ${e.runtimeType}');
      return [];
    }
  }

  // Setup realtime subscriptions
  static Future<void> _setupRealtime(int communityId) async {
    print('🔄 [REALTIME] Starting realtime setup for community: $communityId');

    await _cleanup();

    try {
      print('📡 [REALTIME] Creating group changes channel...');

      // Subscribe to group changes
      final groupChannel = Supabase.instance.client
          .channel('groups_realtime_$communityId')
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'group',
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'community_id',
              value: communityId,
            ),
            callback: (payload) {
              print(
                  '📬 [REALTIME] Group change received: ${payload.eventType}');
              _handleGroupChange(payload, communityId);
            },
          )
          .subscribe();

      print('📡 [REALTIME] Creating status changes channel...');

      // Subscribe to user status changes
      final statusChannel = Supabase.instance.client
          .channel('status_realtime_$communityId')
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'group_user_status',
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'community_id',
              value: communityId,
            ),
            callback: (payload) {
              print(
                  '📬 [REALTIME] Status change received: ${payload.eventType}');
              _handleStatusChange(payload, communityId);
            },
          )
          .subscribe();

      print('📡 [REALTIME] Creating admin changes channel...');

      // Subscribe to admin changes
      final adminChannel = Supabase.instance.client
          .channel('admin_realtime_$communityId')
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'group_admin',
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'community_id',
              value: communityId,
            ),
            callback: (payload) {
              print(
                  '📬 [REALTIME] Admin change received: ${payload.eventType}');
              _handleAdminChange(payload, communityId);
            },
          )
          .subscribe();

      _subscriptions = [groupChannel, statusChannel, adminChannel];
      print('✅ [REALTIME] All channels subscribed successfully');
      print('📊 [REALTIME] Total subscriptions: ${_subscriptions.length}');
    } catch (e) {
      print('💥 [REALTIME] Error setting up realtime: $e');
      print('📍 [REALTIME] Error type: ${e.runtimeType}');
    }
  }

  // Handle group table changes
  static Future<void> _handleGroupChange(
      PostgresChangePayload payload, int communityId) async {
    print('🔄 [GROUP_CHANGE] Processing group change...');
    print('   - Event: ${payload.eventType}');
    print('   - New Record: ${payload.newRecord != null}');
    print('   - Old Record: ${payload.oldRecord != null}');

    try {
      final eventType = payload.eventType;

      switch (eventType) {
        case PostgresChangeEvent.insert:
          if (payload.newRecord != null) {
            final groupId = payload.newRecord!['id'];
            print('➕ [GROUP_CHANGE] New group inserted: $groupId');
            await _refreshSingleGroup(groupId, communityId, isNew: true);
          }
          break;
        case PostgresChangeEvent.update:
          if (payload.newRecord != null) {
            final groupId = payload.newRecord!['id'];
            print('✏️ [GROUP_CHANGE] Group updated: $groupId');
            await _refreshSingleGroup(groupId, communityId);
          }
          break;
        case PostgresChangeEvent.delete:
          if (payload.oldRecord != null) {
            final groupId = payload.oldRecord!['id'];
            print('🗑️ [GROUP_CHANGE] Group deleted: $groupId');
            _removeGroup(groupId);
          }
          break;
        default:
          print('❓ [GROUP_CHANGE] Unhandled event type: $eventType');
          break;
      }
    } catch (e) {
      print('💥 [GROUP_CHANGE] Error handling group change: $e');
      print('📍 [GROUP_CHANGE] Error type: ${e.runtimeType}');
    }
  }

  // Handle status changes
  static Future<void> _handleStatusChange(
      PostgresChangePayload payload, int communityId) async {
    print('🔄 [STATUS_CHANGE] Processing status change...');
    print('   - Event: ${payload.eventType}');

    try {
      final groupId =
          payload.newRecord?['group_id'] ?? payload.oldRecord?['group_id'];
      final userId =
          payload.newRecord?['user_id'] ?? payload.oldRecord?['user_id'];

      print('👤 [STATUS_CHANGE] User: $userId, Group: $groupId');

      if (groupId != null) {
        print('🔄 [STATUS_CHANGE] Refreshing group: $groupId');
        await _refreshSingleGroup(groupId, communityId);
      } else {
        print('❌ [STATUS_CHANGE] No group ID found in payload');
      }
    } catch (e) {
      print('💥 [STATUS_CHANGE] Error handling status change: $e');
      print('📍 [STATUS_CHANGE] Error type: ${e.runtimeType}');
    }
  }

  // Handle admin changes
  static Future<void> _handleAdminChange(
      PostgresChangePayload payload, int communityId) async {
    print('🔄 [ADMIN_CHANGE] Processing admin change...');
    print('   - Event: ${payload.eventType}');

    try {
      final groupId =
          payload.newRecord?['group_id'] ?? payload.oldRecord?['group_id'];
      final userId =
          payload.newRecord?['user_id'] ?? payload.oldRecord?['user_id'];

      print('👑 [ADMIN_CHANGE] User: $userId, Group: $groupId');

      if (groupId != null) {
        print('🔄 [ADMIN_CHANGE] Refreshing group: $groupId');
        await _refreshSingleGroup(groupId, communityId);
      } else {
        print('❌ [ADMIN_CHANGE] No group ID found in payload');
      }
    } catch (e) {
      print('💥 [ADMIN_CHANGE] Error handling admin change: $e');
      print('📍 [ADMIN_CHANGE] Error type: ${e.runtimeType}');
    }
  }

  // Refresh single group data
  static Future<void> _refreshSingleGroup(String groupId, int communityId,
      {bool isNew = false}) async {
    print('🔄 [REFRESH] Refreshing group: $groupId (isNew: $isNew)');

    try {
      print('📞 [REFRESH] Calling RPC to get updated data...');

      final response = await Supabase.instance.client
          .rpc('get_all_groups_with_user_status', params: {
        'p_community_id': communityId,
      });

      if (response != null) {
        final allGroups = List<Map<String, dynamic>>.from(response);
        print('📥 [REFRESH] Got ${allGroups.length} groups from RPC');

        final updatedGroup = allGroups.firstWhere(
          (g) => g['group_id'] == groupId,
          orElse: () => <String, dynamic>{},
        );

        if (updatedGroup.isNotEmpty) {
          print('✅ [REFRESH] Found updated group data');
          print('   - Name: ${updatedGroup['group_name']}');
          print('   - Status: ${updatedGroup['user_status']}');
          print('   - Members: ${updatedGroup['total_members']}');

          if (isNew) {
            print('➕ [REFRESH] Adding new group to list');
            _groupsList.insert(0, updatedGroup);
          } else {
            final index =
                _groupsList.indexWhere((g) => g['group_id'] == groupId);
            if (index != -1) {
              print('✏️ [REFRESH] Updating existing group at index: $index');
              _groupsList[index] = updatedGroup;
            } else {
              print(
                  '❓ [REFRESH] Group not found in current list, adding as new');
              _groupsList.insert(0, updatedGroup);
            }
          }

          print('📊 [REFRESH] Current groups count: ${_groupsList.length}');
          _updateAppState();
        } else {
          print('❌ [REFRESH] Updated group not found in response');
        }
      } else {
        print('❌ [REFRESH] No response from RPC function');
      }
    } catch (e) {
      print('💥 [REFRESH] Error refreshing single group: $e');
      print('📍 [REFRESH] Error type: ${e.runtimeType}');
    }
  }

  // Remove group from list
  static void _removeGroup(String groupId) {
    print('🗑️ [REMOVE] Removing group: $groupId');
    final initialCount = _groupsList.length;
    _groupsList.removeWhere((g) => g['group_id'] == groupId);
    final finalCount = _groupsList.length;
    print('📊 [REMOVE] Groups count: $initialCount → $finalCount');
    _updateAppState();
  }

  // Update app state (this will trigger UI refresh)
  static void _updateAppState() {
    print('🔄 [STATE] Updating app state...');
    print('📊 [STATE] Current groups: ${_groupsList.length}');

    // Log current group names for debugging
    if (_groupsList.isNotEmpty) {
      print('📋 [STATE] Current groups:');
      for (int i = 0; i < _groupsList.length && i < 5; i++) {
        print(
            '   ${i + 1}. ${_groupsList[i]['group_name']} (${_groupsList[i]['user_status']})');
      }
      if (_groupsList.length > 5) {
        print('   ... and ${_groupsList.length - 5} more');
      }
    }

    print('✅ [STATE] App state updated');
  }

  // Get current groups
  static List<Map<String, dynamic>> getCurrentGroups() {
    print('📖 [GET] Getting current groups: ${_groupsList.length} groups');
    return _groupsList;
  }

  // Cleanup subscriptions
  static Future<void> _cleanup() async {
    print('🧹 [CLEANUP] Starting cleanup...');
    print('📊 [CLEANUP] Current subscriptions: ${_subscriptions.length}');

    try {
      for (int i = 0; i < _subscriptions.length; i++) {
        print(
            '🔌 [CLEANUP] Unsubscribing channel ${i + 1}/${_subscriptions.length}');
        await _subscriptions[i].unsubscribe();
      }
      _subscriptions.clear();
      _isInitialized = false;
      print('✅ [CLEANUP] Cleanup completed');
    } catch (e) {
      print('💥 [CLEANUP] Error during cleanup: $e');
      print('📍 [CLEANUP] Error type: ${e.runtimeType}');
    }
  }
}

// Main action function for FlutterFlow
Future<dynamic> manageGroupsRealtime(int communityId, String actionType) async {
  print('🎯 [MAIN] Action called: $actionType for community: $communityId');

  try {
    switch (actionType.toLowerCase()) {
      case 'initialize':
        print('🚀 [MAIN] Initializing groups...');
        final groups = await GroupsStateManager.initializeGroups(communityId);
        print('✅ [MAIN] Initialize completed: ${groups.length} groups');
        return groups;

      case 'get_current':
        print('📖 [MAIN] Getting current groups...');
        final groups = GroupsStateManager.getCurrentGroups();
        print('✅ [MAIN] Get current completed: ${groups.length} groups');
        return groups;

      case 'cleanup':
        print('🧹 [MAIN] Cleaning up...');
        await GroupsStateManager._cleanup();
        print('✅ [MAIN] Cleanup completed');
        return <Map<String, dynamic>>[];

      default:
        print('❓ [MAIN] Unknown action, defaulting to initialize...');
        final groups = await GroupsStateManager.initializeGroups(communityId);
        print('✅ [MAIN] Default initialize completed: ${groups.length} groups');
        return groups;
    }
  } catch (e) {
    print('💥 [MAIN] Error in manageGroupsRealtime: $e');
    print('📍 [MAIN] Error type: ${e.runtimeType}');
    print('🔍 [MAIN] Stack trace: ${StackTrace.current}');
    return <Map<String, dynamic>>[];
  }
}
