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

// Custom Action: insertTagRows
// Parameters:
// - postId (String)
// - userIds (List<String>)
// Return Type: Future<bool>

Future<bool> insertTagRows(
  String postId,
  List<String> userIds,
) async {
  try {
    // Prepare data for insert
    List<Map<String, dynamic>> tagRows = [];

    for (String userId in userIds) {
      tagRows.add({
        'post_id': postId,
        'user_id': userId,
      });
    }

    // Insert all rows
    await SupaFlow.client.from('tag').insert(tagRows);

    return true;
  } catch (error) {
    appLog('Error: $error');
    return false;
  }
}
