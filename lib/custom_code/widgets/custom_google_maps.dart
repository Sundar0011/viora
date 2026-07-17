// Automatic FlutterFlow imports
import '/backend/schema/enums/enums.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom widgets
import '/custom_code/actions/index.dart'; // Imports custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'package:google_maps_flutter/google_maps_flutter.dart' as gmap;

class CustomGoogleMaps extends StatefulWidget {
  const CustomGoogleMaps({
    super.key,
    this.width,
    this.height,
    required this.latLng,
  });

  final double? width;
  final double? height;
  final LatLng latLng;

  @override
  State<CustomGoogleMaps> createState() => _CustomGoogleMapsState();
}

class _CustomGoogleMapsState extends State<CustomGoogleMaps> {
  late gmap.GoogleMapController _mapController;
  final Set<gmap.Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _markers.add(
      gmap.Marker(
        markerId: const gmap.MarkerId('center_marker'),
        position: gmap.LatLng(widget.latLng.latitude, widget.latLng.longitude),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width ?? double.infinity,
      height: widget.height ?? 300,
      child: gmap.GoogleMap(
        initialCameraPosition: gmap.CameraPosition(
          target: gmap.LatLng(widget.latLng.latitude, widget.latLng.longitude),
          zoom: 14,
        ),
        markers: _markers,
        onMapCreated: (controller) {
          _mapController = controller;
        },
        myLocationEnabled: false,
        myLocationButtonEnabled: false, // ❌ Remove 'locate me' icon
        zoomControlsEnabled: false, // ❌ Remove + / - zoom buttons
        scrollGesturesEnabled: false,
        zoomGesturesEnabled: false,
        rotateGesturesEnabled: false,
        tiltGesturesEnabled: false,
      ),
    );
  }
}
