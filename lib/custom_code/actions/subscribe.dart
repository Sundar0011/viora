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

Future<void> subscribe(String table, Future Function() callbackAction) async {
  SupaFlow.client
      .channel('public:$table')
      .onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: table,
        callback: (payload) async {
          print("Real-time update received:");
          print("  Type: ${payload.eventType}");
          print("  Table: ${payload.table}");
          print("  New: ${payload.newRecord}");

          // 🔁 Directly refresh DB request here
          await callbackAction(); // this should already have "Refresh Database Request"
        },
      )
      .subscribe((status, error) {
    print('Status: $status');
    if (error != null) print('Error: $error');
  });
}
