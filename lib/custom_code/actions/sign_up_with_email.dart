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

Future<String?> signUpWithEmail(
  String email,
  String password,
  String confirmPassword,
) async {
  // Get a reference to your Supabase client
  final supabase = Supabase.instance.client;

  if (confirmPassword == password) {
    try {
      await supabase.auth.signUp(
        email: email,
        password: password,
      );
      return null; // Success
    } on AuthException catch (e) {
      return e.message; // Return Supabase error message
    } catch (e) {
      return 'An unexpected error occurred.';
    }
  } else {
    return 'Passwords do not match. Please try again.';
  }
}
