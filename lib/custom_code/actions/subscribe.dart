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

Future<void> subscribe(String table, Future Function() callbackAction) async {
  freshRealtimeChannel(SupaFlow.client, 'public:$table')
      .onPostgresChanges(
    event: PostgresChangeEvent.all,
    schema: 'public',
    table: table,
    callback: (payload) async {
      appLog("Real-time update received:");
      appLog("  Type: ${payload.eventType}");
      appLog("  Table: ${payload.table}");
      appLog("  New: ${payload.newRecord}");

      // 🔁 Directly refresh DB request here
      await callbackAction(); // this should already have "Refresh Database Request"
    },
  )
      .subscribe((status, error) {
    appLog('Status: $status');
    if (error != null) appLog('Error: $error');
  });
}
