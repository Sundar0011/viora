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

import 'dart:async';
import '/flutter_flow/app_log.dart';

Future<void> cancelMessageSubscription(String chatId) async {
  try {
    // Get current subscriptions from App State
    Map<String, dynamic> currentSubscriptions =
        FFAppState().chatSubscriptions ?? <String, dynamic>{};

    if (currentSubscriptions.containsKey(chatId)) {
      // Cancel the subscription
      StreamSubscription? subscription = currentSubscriptions[chatId];
      await subscription?.cancel();

      // Remove from map
      currentSubscriptions.remove(chatId);

      // Update App State
      FFAppState().update(() {
        FFAppState().chatSubscriptions = currentSubscriptions;
      });

      appLog('Subscription cancelled for chat: $chatId');
    } else {
      appLog('No active subscription found for chat: $chatId');
    }
  } catch (e) {
    appLog('Error cancelling subscription: $e');
  }
}
