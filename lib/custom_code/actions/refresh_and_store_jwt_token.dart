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

// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the green button on the right!

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

Future<String> refreshAndStoreJwtToken() async {
  final supabase = Supabase.instance.client;
  final prefs = await SharedPreferences.getInstance();

  try {
    final session = supabase.auth.currentSession;

    if (session == null) {
      return "⚠️ No active session. User may need to log in again.";
    }

    final String? currentToken = session.accessToken;

    if (currentToken == null || currentToken.isEmpty) {
      return "⚠️ No valid access token found.";
    }

    // Decode JWT manually
    Map<String, dynamic> decodedToken = _decodeJwt(currentToken);
    int? expTimestamp = decodedToken['exp']; // UNIX timestamp (seconds)

    // Check if token is expired
    int currentTimestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    bool isTokenExpired =
        expTimestamp != null && expTimestamp <= currentTimestamp;

    // Consider refreshing token if it's expiring in the next 5 minutes
    if (expTimestamp != null && (expTimestamp - currentTimestamp > 300)) {
      return "✅ Token is still valid. No refresh needed.";
    }

    // If expired or close to expiring, refresh the session
    await supabase.auth.refreshSession();

    final newSession = supabase.auth.currentSession;

    if (newSession != null) {
      final String? newAccessToken = newSession.accessToken;
      final String? newRefreshToken = newSession.refreshToken;

      if (newAccessToken != null &&
          newRefreshToken != null &&
          newAccessToken.isNotEmpty &&
          newRefreshToken.isNotEmpty) {
        await prefs.setString('jwt_token', newAccessToken);
        await prefs.setString('refresh_token', newRefreshToken);

        return "✅ JWT token refreshed & stored successfully!";
      } else {
        return "❌ Refreshed session is invalid (empty or null tokens).";
      }
    } else {
      return "❌ Failed to refresh session (no new session).";
    }
  } catch (e) {
    return "❌ Error refreshing JWT: $e";
  }
}

/// Helper function to decode JWT without external packages
Map<String, dynamic> _decodeJwt(String token) {
  final parts = token.split('.');
  if (parts.length != 3) {
    throw Exception('Invalid JWT');
  }

  final payload = _base64UrlDecode(parts[1]);
  return json.decode(payload) as Map<String, dynamic>;
}

String _base64UrlDecode(String input) {
  String output = input.replaceAll('-', '+').replaceAll('_', '/');
  while (output.length % 4 != 0) {
    output += '=';
  }
  return utf8.decode(base64Url.decode(output));
}
