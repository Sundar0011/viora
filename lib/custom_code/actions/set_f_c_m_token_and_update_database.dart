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

Future<String> setFCMTokenAndUpdateDatabase(String anonKey) async {
  try {
    // Initialize Firebase
    await Firebase.initializeApp();

    FirebaseMessaging messaging = FirebaseMessaging.instance;

    // Request permission for notifications
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

    // Get FCM Token
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

      return 'success';
    } else {
      return '❌ RPC call failed: ${response.statusCode} → ${response.body}';
    }
  } catch (e) {
    FFAppState().fcmToken = "";
    return '❌ Error: ${e.toString()}';
  }
}

// Alternative simple function that only gets FCM token (if you want to keep it separate)
Future setFCMTokenOnly() async {
  try {
    await Firebase.initializeApp();

    FirebaseMessaging messaging = FirebaseMessaging.instance;
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      String? fcmToken = await messaging.getToken();
      FFAppState().fcmToken = fcmToken ?? "";

      // Listen for token refresh
      messaging.onTokenRefresh.listen((newToken) {
        FFAppState().fcmToken = newToken;
        // You can call the update function here if needed
      });
    } else {
      FFAppState().fcmToken = "";
    }
  } catch (e) {
    FFAppState().fcmToken = "Error: ${e.toString()}";
  }
}
