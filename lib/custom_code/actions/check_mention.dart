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

Future<String> checkMention(String inputField) async {
  final atIndex = inputField.lastIndexOf('@');

  if (atIndex != -1) {
    final afterAt = inputField.substring(atIndex + 1);

    if (!afterAt.contains(' ')) {
      FFAppState().mentionText = afterAt;
      FFAppState().showMentionList = true;

      return 'VALID: $afterAt'; // ✅ For testing
    } else {
      FFAppState().mentionText = '';
      FFAppState().showMentionList = false;

      return 'INVALID: contains space after @'; // ❌ For testing
    }
  }

  FFAppState().mentionText = '';
  FFAppState().showMentionList = false;

  return 'NO @ found'; // ❌ For testing
}
