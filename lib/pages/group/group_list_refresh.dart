// group_list_refresh.dart
// Shared pull-to-refresh data reload for the group list screens
// (My Groups, Explore Groups, Nearest Groups). All three render the same
// `FFAppState().AsGroupList` snapshot, which is otherwise only populated once —
// by `actions.fetchGroupsWithStatusRealtime()` on the Community screen — so a
// pull gesture needs a fetch-only path that does NOT re-subscribe the realtime
// channels (re-subscribing on every pull would duplicate them and multiply the
// refetch callbacks). Implements ui-review 2026-07-21 §2.7.
import 'package:flutter/material.dart';

import '/backend/supabase/supabase.dart';
import '/flutter_flow/app_log.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';

/// Re-runs the `get_groups_with_user_status` RPC and republishes the result into
/// `FFAppState().AsGroupList`. Throws on failure so the caller can surface it.
Future<void> refreshGroupList() async {
  try {
    final dynamic response =
        await SupaFlow.client.rpc('get_groups_with_user_status').select();

    if (response is List) {
      FFAppState().update(() {
        FFAppState().AsGroupList = response;
      });
      return;
    }
    throw StateError(
        'get_groups_with_user_status returned ${response.runtimeType}');
  } catch (error, stackTrace) {
    // Never swallow silently (CLAUDE.md §5) — log for devs, rethrow for the UI.
    appLogError(error, stackTrace);
    rethrow;
  }
}

/// Re-runs the `get_specific_group_with_user_status` RPC for one group and
/// republishes it into `FFAppState().AsSpecificGroupDetails`. Fetch only — the
/// realtime subscription is owned by the page's on-load action. Throws on
/// failure so the caller can show the error state.
Future<void> refreshGroupDetails(String groupId) async {
  try {
    final dynamic response = await SupaFlow.client.rpc(
      'get_specific_group_with_user_status',
      params: <String, dynamic>{'p_group_id': groupId},
    ).select();

    if (response is List && response.isNotEmpty) {
      FFAppState().update(() {
        FFAppState().AsSpecificGroupDetails = response.first;
      });
      return;
    }
    throw StateError('get_specific_group_with_user_status returned no row');
  } catch (error, stackTrace) {
    appLogError(error, stackTrace);
    rethrow;
  }
}

/// `RefreshIndicator.onRefresh` handler: reloads the list and, if the fetch
/// fails, tells the user instead of leaving the spinner to end silently.
Future<void> handleGroupListRefresh(BuildContext context) async {
  try {
    await refreshGroupList();
  } catch (_) {
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Could not refresh groups. Check your connection and try again.',
          style: TextStyle(color: FlutterFlowTheme.of(context).primaryText),
        ),
        backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
      ),
    );
  }
}
