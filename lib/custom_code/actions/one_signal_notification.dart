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

import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<String> oneSignalNotification(
    String oneSignalAppId, String anonKey) async {
  if (oneSignalAppId.isEmpty) {
    return '❌ OneSignal App ID is empty.';
  }

  if (anonKey.isEmpty) {
    return '❌ Anon Key is empty.';
  }

  try {
    // Init OneSignal
    OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
    OneSignal.initialize(oneSignalAppId);

    // Request permission
    await OneSignal.Notifications.requestPermission(true);
    await Future.delayed(Duration(seconds: 2)); // Increased delay

    // Get player ID
    final pushSub = await OneSignal.User.pushSubscription;
    final playerId = pushSub.id;

    if (playerId == null || playerId.isEmpty) {
      return '❌ Player ID is null or empty';
    }

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
        'https://wgcqstmmkcdjnnpuvspr.supabase.co/rest/v1/rpc/upsert_user_device');

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $jwt',
        'apikey': anonKey, // Use the passed anonKey parameter
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'p_device_id': deviceId, 'p_player_id': playerId}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return 'success';
    } else {
      return '❌ RPC call failed: ${response.statusCode} → ${response.body}';
    }
  } catch (e) {
    return '❌ Error: ${e.toString()}';
  }
}
