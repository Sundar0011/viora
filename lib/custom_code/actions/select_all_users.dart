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

import '/custom_code/widgets/index.dart'; // Imports other custom widgets
import '/custom_code/actions/index.dart'; // Imports custom actions

Future selectAllUsers() async {
  // Get the matchedUsers JSON from app state
  final matchedUsers = FFAppState().matchedUsers;

  // Create a list to store all user IDs
  List<String> allUserIds = [];

  // Extract user_id from each object in the JSON array
  if (matchedUsers != null && matchedUsers is List) {
    for (var user in matchedUsers) {
      if (user is Map<String, dynamic> && user.containsKey('user_id')) {
        String userId = user['user_id'].toString();
        if (userId.isNotEmpty && !allUserIds.contains(userId)) {
          allUserIds.add(userId);
        }
      }
    }
  }

  // Update the userIds app state with all user IDs
  FFAppState().update(() {
    // Clear existing userIds and add all user IDs from matchedUsers
    FFAppState().userIds.clear();
    FFAppState().userIds.addAll(allUserIds);
  });
}
