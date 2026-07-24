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

Future<void> subscribeToMessagesAndMarkAsRead(
  String chatId,
  String currentUserId,
) async {
  try {
    // Get current subscriptions from App State
    Map<String, dynamic> currentSubscriptions =
        FFAppState().chatSubscriptions ?? <String, dynamic>{};

    // Cancel existing subscription if exists
    if (currentSubscriptions.containsKey(chatId)) {
      StreamSubscription? existingSubscription = currentSubscriptions[chatId];
      await existingSubscription?.cancel();
    }

    // Create new subscription
    StreamSubscription<List<Map<String, dynamic>>> newSubscription = SupaFlow
        .client
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('chat_id', chatId)
        .listen((List<Map<String, dynamic>> data) async {
          try {
            List<Map<String, dynamic>> unreadMessages = data.where((message) {
              return message['sender_id'] != currentUserId &&
                  message['is_read'] == false;
            }).toList();

            if (unreadMessages.isNotEmpty) {
              await SupaFlow.client
                  .from('messages')
                  .update({'is_read': true})
                  .eq('chat_id', chatId)
                  .neq('sender_id', currentUserId)
                  .eq('is_read', false);

              appLog('Marked ${unreadMessages.length} messages as read');
            }
          } catch (e) {
            appLog('Error processing messages: $e');
          }
        });

    // Store in App State
    currentSubscriptions[chatId] = newSubscription;
    FFAppState().update(() {
      FFAppState().chatSubscriptions = currentSubscriptions;
    });

    appLog('Successfully subscribed to chat: $chatId');
  } catch (e) {
    appLog('Error in subscription: $e');
  }
}
