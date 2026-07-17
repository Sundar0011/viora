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

Future fetchGroupsWithStatusRealtime() async {
  final supabase = Supabase.instance.client;

  // Function to call the RPC and update app state
  Future<void> fetchGroups() async {
    try {
      final response =
          await supabase.rpc('get_groups_with_user_status').select();

      if (response != null && response is List) {
        FFAppState().update(() {
          FFAppState().AsGroupList = response;
        });
        print('✅ Group list updated from RPC.');
      } else {
        print('⚠️ Warning: Invalid response from RPC.');
      }
    } catch (error) {
      print('❌ Error calling get_groups_with_user_status RPC: $error');
    }
  }

  // Initial fetch
  await fetchGroups();

  final tables = [
    'group',
    'group_members',
    'group_user_status',
    'group_admin',
    'group_members_invite',
  ];

  for (final table in tables) {
    final channelId = 'group-list-realtime:$table'; // unique ID for list

    final channel = supabase.channel(channelId);

    channel
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: table,
          callback: (payload) async {
            print('🔄 [Group List] Change in $table. Refetching...');
            await fetchGroups();
          },
        )
        .subscribe();

    print('📡 Subscribed to group list realtime changes for $table');
  }
}
