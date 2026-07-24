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
import '/flutter_flow/app_log.dart';

// Global state management
class GroupsStateManager {
  static List<Map<String, dynamic>> _groupsList = [];
  static List<RealtimeChannel> _subscriptions = [];
  static bool _isInitialized = false;

  // Initialize groups and setup realtime
  static Future<List<Map<String, dynamic>>> initializeGroups(
      int communityId) async {
    appLog('🚀 [GROUPS] Initializing groups for community: $communityId');

    try {
      appLog(
          '📞 [GROUPS] Calling RPC function: get_all_groups_with_user_status');

      // Fetch initial data
      final response = await Supabase.instance.client
          .rpc('get_all_groups_with_user_status', params: {
        'p_community_id': communityId,
      });

      appLog('📥 [GROUPS] RPC Response received: ${response?.runtimeType}');

      if (response != null) {
        _groupsList = List<Map<String, dynamic>>.from(response);
        appLog(
            '✅ [GROUPS] Groups loaded successfully: ${_groupsList.length} groups');

        // Log first few groups for debugging
        if (_groupsList.isNotEmpty) {
          appLog('📋 [GROUPS] First group sample:');
          appLog('   - ID: ${_groupsList[0]['group_id']}');
          appLog('   - Name: ${_groupsList[0]['group_name']}');
          appLog('   - Status: ${_groupsList[0]['user_status']}');
          appLog('   - Members: ${_groupsList[0]['total_members']}');
        }

        // Setup realtime if not already done
        if (!_isInitialized) {
          appLog('🔄 [GROUPS] Setting up realtime subscriptions...');
          await _setupRealtime(communityId);
          _isInitialized = true;
          appLog('✅ [GROUPS] Realtime setup completed');
        } else {
          appLog('ℹ️ [GROUPS] Realtime already initialized');
        }
      } else {
        appLog('❌ [GROUPS] No response from RPC function');
      }

      return _groupsList;
    } catch (e) {
      appLog('💥 [GROUPS] Error initializing groups: $e');
      appLog('📍 [GROUPS] Error type: ${e.runtimeType}');
      return [];
    }
  }

  // Setup realtime subscriptions
  static Future<void> _setupRealtime(int communityId) async {
    appLog('🔄 [REALTIME] Starting realtime setup for community: $communityId');

    await _cleanup();

    try {
      appLog('📡 [REALTIME] Creating group changes channel...');

      // Subscribe to group changes
      final groupChannel = freshRealtimeChannel(
              Supabase.instance.client, 'groups_realtime_$communityId')
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
              appLog(
                  '📬 [REALTIME] Group change received: ${payload.eventType}');
              _handleGroupChange(payload, communityId);
            },
          )
          .subscribe();

      appLog('📡 [REALTIME] Creating status changes channel...');

      // Subscribe to user status changes
      final statusChannel = freshRealtimeChannel(
              Supabase.instance.client, 'status_realtime_$communityId')
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
              appLog(
                  '📬 [REALTIME] Status change received: ${payload.eventType}');
              _handleStatusChange(payload, communityId);
            },
          )
          .subscribe();

      appLog('📡 [REALTIME] Creating admin changes channel...');

      // Subscribe to admin changes
      final adminChannel = freshRealtimeChannel(
              Supabase.instance.client, 'admin_realtime_$communityId')
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
              appLog(
                  '📬 [REALTIME] Admin change received: ${payload.eventType}');
              _handleAdminChange(payload, communityId);
            },
          )
          .subscribe();

      _subscriptions = [groupChannel, statusChannel, adminChannel];
      appLog('✅ [REALTIME] All channels subscribed successfully');
      appLog('📊 [REALTIME] Total subscriptions: ${_subscriptions.length}');
    } catch (e) {
      appLog('💥 [REALTIME] Error setting up realtime: $e');
      appLog('📍 [REALTIME] Error type: ${e.runtimeType}');
    }
  }

  // Handle group table changes
  static Future<void> _handleGroupChange(
      PostgresChangePayload payload, int communityId) async {
    appLog('🔄 [GROUP_CHANGE] Processing group change...');
    appLog('   - Event: ${payload.eventType}');
    appLog('   - New Record: ${payload.newRecord != null}');
    appLog('   - Old Record: ${payload.oldRecord != null}');

    try {
      final eventType = payload.eventType;

      switch (eventType) {
        case PostgresChangeEvent.insert:
          if (payload.newRecord != null) {
            final groupId = payload.newRecord!['id'];
            appLog('➕ [GROUP_CHANGE] New group inserted: $groupId');
            await _refreshSingleGroup(groupId, communityId, isNew: true);
          }
          break;
        case PostgresChangeEvent.update:
          if (payload.newRecord != null) {
            final groupId = payload.newRecord!['id'];
            appLog('✏️ [GROUP_CHANGE] Group updated: $groupId');
            await _refreshSingleGroup(groupId, communityId);
          }
          break;
        case PostgresChangeEvent.delete:
          if (payload.oldRecord != null) {
            final groupId = payload.oldRecord!['id'];
            appLog('🗑️ [GROUP_CHANGE] Group deleted: $groupId');
            _removeGroup(groupId);
          }
          break;
        default:
          appLog('❓ [GROUP_CHANGE] Unhandled event type: $eventType');
          break;
      }
    } catch (e) {
      appLog('💥 [GROUP_CHANGE] Error handling group change: $e');
      appLog('📍 [GROUP_CHANGE] Error type: ${e.runtimeType}');
    }
  }

  // Handle status changes
  static Future<void> _handleStatusChange(
      PostgresChangePayload payload, int communityId) async {
    appLog('🔄 [STATUS_CHANGE] Processing status change...');
    appLog('   - Event: ${payload.eventType}');

    try {
      final groupId =
          payload.newRecord?['group_id'] ?? payload.oldRecord?['group_id'];
      final userId =
          payload.newRecord?['user_id'] ?? payload.oldRecord?['user_id'];

      appLog('👤 [STATUS_CHANGE] User: $userId, Group: $groupId');

      if (groupId != null) {
        appLog('🔄 [STATUS_CHANGE] Refreshing group: $groupId');
        await _refreshSingleGroup(groupId, communityId);
      } else {
        appLog('❌ [STATUS_CHANGE] No group ID found in payload');
      }
    } catch (e) {
      appLog('💥 [STATUS_CHANGE] Error handling status change: $e');
      appLog('📍 [STATUS_CHANGE] Error type: ${e.runtimeType}');
    }
  }

  // Handle admin changes
  static Future<void> _handleAdminChange(
      PostgresChangePayload payload, int communityId) async {
    appLog('🔄 [ADMIN_CHANGE] Processing admin change...');
    appLog('   - Event: ${payload.eventType}');

    try {
      final groupId =
          payload.newRecord?['group_id'] ?? payload.oldRecord?['group_id'];
      final userId =
          payload.newRecord?['user_id'] ?? payload.oldRecord?['user_id'];

      appLog('👑 [ADMIN_CHANGE] User: $userId, Group: $groupId');

      if (groupId != null) {
        appLog('🔄 [ADMIN_CHANGE] Refreshing group: $groupId');
        await _refreshSingleGroup(groupId, communityId);
      } else {
        appLog('❌ [ADMIN_CHANGE] No group ID found in payload');
      }
    } catch (e) {
      appLog('💥 [ADMIN_CHANGE] Error handling admin change: $e');
      appLog('📍 [ADMIN_CHANGE] Error type: ${e.runtimeType}');
    }
  }

  // Refresh single group data
  static Future<void> _refreshSingleGroup(String groupId, int communityId,
      {bool isNew = false}) async {
    appLog('🔄 [REFRESH] Refreshing group: $groupId (isNew: $isNew)');

    try {
      appLog('📞 [REFRESH] Calling RPC to get updated data...');

      final response = await Supabase.instance.client
          .rpc('get_all_groups_with_user_status', params: {
        'p_community_id': communityId,
      });

      if (response != null) {
        final allGroups = List<Map<String, dynamic>>.from(response);
        appLog('📥 [REFRESH] Got ${allGroups.length} groups from RPC');

        final updatedGroup = allGroups.firstWhere(
          (g) => g['group_id'] == groupId,
          orElse: () => <String, dynamic>{},
        );

        if (updatedGroup.isNotEmpty) {
          appLog('✅ [REFRESH] Found updated group data');
          appLog('   - Name: ${updatedGroup['group_name']}');
          appLog('   - Status: ${updatedGroup['user_status']}');
          appLog('   - Members: ${updatedGroup['total_members']}');

          if (isNew) {
            appLog('➕ [REFRESH] Adding new group to list');
            _groupsList.insert(0, updatedGroup);
          } else {
            final index =
                _groupsList.indexWhere((g) => g['group_id'] == groupId);
            if (index != -1) {
              appLog('✏️ [REFRESH] Updating existing group at index: $index');
              _groupsList[index] = updatedGroup;
            } else {
              appLog(
                  '❓ [REFRESH] Group not found in current list, adding as new');
              _groupsList.insert(0, updatedGroup);
            }
          }

          appLog('📊 [REFRESH] Current groups count: ${_groupsList.length}');
          _updateAppState();
        } else {
          appLog('❌ [REFRESH] Updated group not found in response');
        }
      } else {
        appLog('❌ [REFRESH] No response from RPC function');
      }
    } catch (e) {
      appLog('💥 [REFRESH] Error refreshing single group: $e');
      appLog('📍 [REFRESH] Error type: ${e.runtimeType}');
    }
  }

  // Remove group from list
  static void _removeGroup(String groupId) {
    appLog('🗑️ [REMOVE] Removing group: $groupId');
    final initialCount = _groupsList.length;
    _groupsList.removeWhere((g) => g['group_id'] == groupId);
    final finalCount = _groupsList.length;
    appLog('📊 [REMOVE] Groups count: $initialCount → $finalCount');
    _updateAppState();
  }

  // Update app state (this will trigger UI refresh)
  static void _updateAppState() {
    appLog('🔄 [STATE] Updating app state...');
    appLog('📊 [STATE] Current groups: ${_groupsList.length}');

    // Log current group names for debugging
    if (_groupsList.isNotEmpty) {
      appLog('📋 [STATE] Current groups:');
      for (int i = 0; i < _groupsList.length && i < 5; i++) {
        appLog(
            '   ${i + 1}. ${_groupsList[i]['group_name']} (${_groupsList[i]['user_status']})');
      }
      if (_groupsList.length > 5) {
        appLog('   ... and ${_groupsList.length - 5} more');
      }
    }

    appLog('✅ [STATE] App state updated');
  }

  // Get current groups
  static List<Map<String, dynamic>> getCurrentGroups() {
    appLog('📖 [GET] Getting current groups: ${_groupsList.length} groups');
    return _groupsList;
  }

  // Cleanup subscriptions
  static Future<void> _cleanup() async {
    appLog('🧹 [CLEANUP] Starting cleanup...');
    appLog('📊 [CLEANUP] Current subscriptions: ${_subscriptions.length}');

    try {
      for (int i = 0; i < _subscriptions.length; i++) {
        appLog(
            '🔌 [CLEANUP] Unsubscribing channel ${i + 1}/${_subscriptions.length}');
        await _subscriptions[i].unsubscribe();
      }
      _subscriptions.clear();
      _isInitialized = false;
      appLog('✅ [CLEANUP] Cleanup completed');
    } catch (e) {
      appLog('💥 [CLEANUP] Error during cleanup: $e');
      appLog('📍 [CLEANUP] Error type: ${e.runtimeType}');
    }
  }
}

// Main action function for FlutterFlow
Future<dynamic> manageGroupsRealtime(int communityId, String actionType) async {
  appLog('🎯 [MAIN] Action called: $actionType for community: $communityId');

  try {
    switch (actionType.toLowerCase()) {
      case 'initialize':
        appLog('🚀 [MAIN] Initializing groups...');
        final groups = await GroupsStateManager.initializeGroups(communityId);
        appLog('✅ [MAIN] Initialize completed: ${groups.length} groups');
        return groups;

      case 'get_current':
        appLog('📖 [MAIN] Getting current groups...');
        final groups = GroupsStateManager.getCurrentGroups();
        appLog('✅ [MAIN] Get current completed: ${groups.length} groups');
        return groups;

      case 'cleanup':
        appLog('🧹 [MAIN] Cleaning up...');
        await GroupsStateManager._cleanup();
        appLog('✅ [MAIN] Cleanup completed');
        return <Map<String, dynamic>>[];

      default:
        appLog('❓ [MAIN] Unknown action, defaulting to initialize...');
        final groups = await GroupsStateManager.initializeGroups(communityId);
        appLog(
            '✅ [MAIN] Default initialize completed: ${groups.length} groups');
        return groups;
    }
  } catch (e) {
    appLog('💥 [MAIN] Error in manageGroupsRealtime: $e');
    appLog('📍 [MAIN] Error type: ${e.runtimeType}');
    appLog('🔍 [MAIN] Stack trace: ${StackTrace.current}');
    return <Map<String, dynamic>>[];
  }
}
