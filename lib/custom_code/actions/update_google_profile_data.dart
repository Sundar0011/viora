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

/// Set your action name, define your arguments and return parameter, and then
/// add the boilerplate code using the green button on the right!
Future updateGoogleProfileData() async {
  try {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    if (user != null) {
      // Get user metadata from Google OAuth
      final userMetadata = user.userMetadata;

      // Extract profile picture URL
      final profilePictureUrl =
          userMetadata?['avatar_url'] ?? userMetadata?['picture'] ?? '';

      // Extract full name and split into first/last name
      final fullName =
          userMetadata?['full_name'] ?? userMetadata?['name'] ?? '';

      // Extract first and last name from Google profile
      final firstName = userMetadata?['given_name'] ?? '';
      final lastName = userMetadata?['family_name'] ?? '';

      // Fallback: If given_name/family_name not available, split full_name
      String finalFirstName = firstName;
      String finalLastName = lastName;

      if (firstName.isEmpty && lastName.isEmpty && fullName.isNotEmpty) {
        final nameParts = fullName.split(' ');
        finalFirstName = nameParts.isNotEmpty ? nameParts.first : '';
        finalLastName =
            nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';
      }

      // Update FlutterFlow App State
      FFAppState().update(() {
        FFAppState().AsFirstName = finalFirstName;
        FFAppState().AsLastName = finalLastName;
        FFAppState().AsProfilePicture = profilePictureUrl;
      });

      // Debug prints
      print('Google profile data updated successfully:');
      print('First Name: $finalFirstName');
      print('Last Name: $finalLastName');
      print('Profile Picture: $profilePictureUrl');
    } else {
      print('Error: No user is currently logged in.');
    }
  } catch (error) {
    print('Error updating Google profile data: $error');
    // Optionally show error to user
    // ScaffoldMessenger.of(context).showSnackBar(
    //   SnackBar(content: Text('Failed to update profile: $error')),
    // );
  }
}
