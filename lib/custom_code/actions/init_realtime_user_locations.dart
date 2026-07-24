// Automatic FlutterFlow imports
import '/backend/schema/enums/enums.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
import '/flutter_flow/app_log.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

Future initRealtimeUserLocations() async {
  final client = Supabase.instance.client;

  final channel = freshRealtimeChannel(client, 'public:user_locations');

  channel
      .onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'user_locations',
        callback: (payload) {
          // ✅ Debug logs
          appLog('Realtime event: ${payload.eventType}');
          appLog('New record: ${payload.newRecord}');
          appLog('Old record: ${payload.oldRecord}');

          final eventType = payload.eventType;
          final newRow = payload.newRecord;
          final oldRow = payload.oldRecord;

          List<dynamic> currentList = FFAppState().userLocationsList.toList();

          if (eventType == 'INSERT') {
            currentList
                .insert(0, {'id': newRow['id'], 'place': newRow['place']});
          } else if (eventType == 'UPDATE') {
            final index =
                currentList.indexWhere((row) => row['id'] == newRow['id']);
            if (index != -1) {
              // Replace the entire row with the updated row
              currentList[index] = {
                'id': newRow['id'],
                'place': newRow['place'],
              };
            } else {
              // In case the row wasn't found, insert it
              currentList.add({
                'id': newRow['id'],
                'place': newRow['place'],
              });
            }
          }

          appLog('Updated userLocationsList: $currentList');
          FFAppState().update(() {
            List<dynamic> currentList = FFAppState().userLocationsList.toList();

            // Remove any existing row with the same id
            currentList.removeWhere((row) => row['id'] == newRow['id']);

            // Add the new row
            currentList.add({
              'id': newRow['id'],
              'place': newRow['place'],
            });

            FFAppState().userLocationsList = currentList;

            appLog(
                '✅ Final userLocationsList: ${FFAppState().userLocationsList}');
          });
        },
      )
      .subscribe();
}
