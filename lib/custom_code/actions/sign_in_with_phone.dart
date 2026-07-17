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

Future<String?> signInWithPhone(
  String phone,
  String password,
) async {
  // Get a reference to your Supabase client
  final supabase = Supabase.instance.client;
  try {
    await supabase.auth.signInWithPassword(
      phone: phone,
      password: password,
    );
    return null; // Sign-in successful
  } on AuthException catch (e) {
    return e.message; // Return error message if sign-in fails
  }
}
