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

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '/flutter_flow/app_log.dart';

Future<String> checkNotificationAndStoreFCMToken(String anonKey) async {
  try {
    // Initialize Firebase
    await Firebase.initializeApp();

    FirebaseMessaging messaging = FirebaseMessaging.instance;

    // First, check current notification settings
    NotificationSettings currentSettings =
        await messaging.getNotificationSettings();

    // If notifications are not authorized, request permission
    if (currentSettings.authorizationStatus ==
        AuthorizationStatus.notDetermined) {
      NotificationSettings settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      if (settings.authorizationStatus != AuthorizationStatus.authorized) {
        FFAppState().fcmToken = "";
        return '❌ Notification permission denied';
      }
    } else if (currentSettings.authorizationStatus ==
        AuthorizationStatus.denied) {
      FFAppState().fcmToken = "";
      return '❌ Notifications are disabled. Please enable them in settings.';
    } else if (currentSettings.authorizationStatus !=
        AuthorizationStatus.authorized) {
      FFAppState().fcmToken = "";
      return '❌ Notification permission not granted';
    }

    // If we reach here, notifications are allowed - proceed to get FCM token
    String? fcmToken = await messaging.getToken();

    if (fcmToken == null || fcmToken.isEmpty) {
      return '❌ FCM Token could not be retrieved';
    }

    // Store FCM token in App State
    FFAppState().fcmToken = fcmToken;

    // Get device ID
    final deviceInfoPlugin = DeviceInfoPlugin();
    String deviceId;

    if (Platform.isAndroid) {
      final androidInfo = await deviceInfoPlugin.androidInfo;
      deviceId = androidInfo.id;
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfoPlugin.iosInfo;
      deviceId = iosInfo.identifierForVendor ?? '';
    } else {
      deviceId = 'unknown_device';
    }

    if (deviceId.isEmpty) {
      return '❌ Device ID could not be determined';
    }

    // Store device ID in App State
    FFAppState().deviceId = deviceId;

    // Get current session token (JWT)
    final session = Supabase.instance.client.auth.currentSession;
    final jwt = session?.accessToken;

    if (jwt == null) {
      return '❌ JWT token not found. User may not be logged in.';
    }

    // Call Supabase RPC function to upsert device info
    final url = Uri.parse(
        'https://hlmymmlkgirafodcnkgg.supabase.co/rest/v1/rpc/upsert_user_device_fcm');

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $jwt',
        'apikey': anonKey,
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'p_device_id': deviceId, 'p_fcm_token': fcmToken}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final responseData = jsonDecode(response.body);

      // Check if response contains an error
      if (responseData is Map && responseData.containsKey('error')) {
        return '❌ ${responseData['error']}';
      }

      // Set up token refresh listener
      messaging.onTokenRefresh.listen((newToken) {
        FFAppState().fcmToken = newToken;
        // Optionally update database with new token
        _updateTokenInBackground(newToken, deviceId, anonKey);
      });

      return '✅ Notifications enabled and FCM token stored successfully';
    } else {
      return '❌ Database update failed: ${response.statusCode} → ${response.body}';
    }
  } catch (e) {
    FFAppState().fcmToken = "";
    return '❌ Error: ${e.toString()}';
  }
}

// Helper function to update token in background when it refreshes
Future<void> _updateTokenInBackground(
    String newToken, String deviceId, String anonKey) async {
  try {
    final session = Supabase.instance.client.auth.currentSession;
    final jwt = session?.accessToken;

    if (jwt == null) return;

    final url = Uri.parse(
        'https://hlmymmlkgirafodcnkgg.supabase.co/rest/v1/rpc/upsert_user_device_fcm');

    await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $jwt',
        'apikey': anonKey,
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'p_device_id': deviceId, 'p_fcm_token': newToken}),
    );
  } catch (e) {
    // Silent fail for background updates
    appLog('Background token update failed: $e');
  }
}
