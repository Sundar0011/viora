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

import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

Future<bool> userLocation() async {
  try {
    // Request location permission
    final permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return false;
    }

    // Get current position
    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    final latitude = position.latitude;
    final longitude = position.longitude;

    FFAppState().update(() {
      FFAppState().AsLatitude = latitude;
      FFAppState().AsLongitude = longitude;
    });

    // ✅ Reverse geocode to get address info
    final placemarks = await placemarkFromCoordinates(latitude, longitude);

    if (placemarks.isNotEmpty) {
      final place = placemarks.first;

      final name = place.name ?? '';
      final subLocality = place.subLocality ?? '';
      final locality = place.locality ?? '';
      final state = place.administrativeArea ?? '';
      final postalCode = place.postalCode ?? '';
      final country = place.country ?? '';

      FFAppState().update(() {
        FFAppState().AsAddress = '$name, $subLocality, $locality, $state';
        FFAppState().AsCity = locality;
        FFAppState().AsFlat = name;
        FFAppState().AsPostalCode = postalCode;
        FFAppState().AsCountry = country;
      });
    }

    return true;
  } catch (e) {
    print('Error in userLocation(): $e');
    return false;
  }
}
