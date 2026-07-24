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

Future fetchUserLocations() async {
  try {
    final data = await Supabase.instance.client
        .from('user_locations')
        .select('id, place')
        .order('id');

    // Print the data to verify
    appLog('Fetched user_locations: $data');

    FFAppState().userLocationsList = data;
  } catch (error) {
    appLog('Error fetching user_locations: $error');
  }
}
