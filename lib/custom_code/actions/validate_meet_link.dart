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

// Auto-generated custom action for FlutterFlow
// Custom Action Code

import 'dart:convert';
import 'dart:math' as math;

bool validateMeetLink(String inputString) {
  // Check if input is null or empty
  if (inputString.isEmpty) {
    return false;
  }

  String url = inputString.trim();

  // Define regex patterns for different meeting platforms
  List<RegExp> meetPatterns = [
    // Google Meet patterns
    RegExp(r'^https?:\/\/meet\.google\.com\/[a-z]{3}-[a-z]{4}-[a-z]{3}$',
        caseSensitive: false),
    RegExp(r'^https?:\/\/meet\.google\.com\/[a-z0-9]{10}$',
        caseSensitive: false),

    // Zoom patterns
    RegExp(r'^https?:\/\/.*\.zoom\.us\/j\/\d{9,11}(\?pwd=[\w\-_]+)?$',
        caseSensitive: false),
    RegExp(r'^https?:\/\/zoom\.us\/j\/\d{9,11}(\?pwd=[\w\-_]+)?$',
        caseSensitive: false),

    // Microsoft Teams patterns
    RegExp(
        r'^https?:\/\/teams\.microsoft\.com\/l\/meetup-join\/[^\/]+\/[^\/]+$',
        caseSensitive: false),
    RegExp(r'^https?:\/\/.*\.teams\.microsoft\.com\/.*$', caseSensitive: false),

    // Webex patterns
    RegExp(r'^https?:\/\/.*\.webex\.com\/.*$', caseSensitive: false),

    // GoToMeeting patterns
    RegExp(r'^https?:\/\/.*\.gotomeeting\.com\/.*$', caseSensitive: false),

    // Jitsi Meet patterns
    RegExp(r'^https?:\/\/meet\.jit\.si\/[a-zA-Z0-9\-_]+$',
        caseSensitive: false),
    RegExp(r'^https?:\/\/.*\.jitsi\..*\/[a-zA-Z0-9\-_]+$',
        caseSensitive: false),

    // Generic meet patterns
    RegExp(r'^https?:\/\/.*\/(meet|meeting|conference|room)\/[a-zA-Z0-9\-_]+$',
        caseSensitive: false),
  ];

  // Check if URL matches any meet pattern
  return meetPatterns.any((pattern) => pattern.hasMatch(url));
}
