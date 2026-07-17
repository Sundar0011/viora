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

// Store the last group ID
String? _lastGroupId;

Future fetchSpecificGroupWithStatusRealtime(String groupId) async {
  final supabase = Supabase.instance.client;

  // Remember the group ID for automatic calls
  _lastGroupId = groupId;

  Future<void> fetchGroupDetails() async {
    try {
      final response =
          await supabase.rpc('get_specific_group_with_user_status', params: {
        'p_group_id': _lastGroupId!, // Use stored group ID
      }).select();
      if (response == null || response is! List || response.isEmpty) {
        print('⚠️ [Group Detail] No data or bad RPC response');
        return;
      }
      final data = response.first;
      FFAppState().update(() {
        FFAppState().AsSpecificGroupDetails = data;
      });
      print('✅ Specific group ($_lastGroupId) updated');
    } catch (e) {
      print('❌ Error fetching specific group: $e');
    }
  }

  // Initial fetch
  await fetchGroupDetails();
  final tables = ['group', 'group_members', 'group_user_status', 'group_admin'];
  for (final table in tables) {
    final channelId =
        'group-detail-realtime:$table:$groupId'; // unique ID per group
    final channel = supabase.channel(channelId);
    channel
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: table,
          callback: (payload) async {
            print('🔄 [Group Detail] Change in $table. Refetching...');
            await fetchGroupDetails(); // Now uses _lastGroupId automatically
          },
        )
        .subscribe();
    print('📡 Subscribed to group detail realtime changes for $table');
  }
}
