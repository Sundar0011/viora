import '/auth/supabase_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/pages/registration/comp_neighbour_location/comp_neighbour_location_widget.dart';
import 'dart:ui';
import '/custom_code/actions/index.dart' as actions;
import '/index.dart';
import 'location_page_widget.dart' show LocationPageWidget;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class LocationPageModel extends FlutterFlowModel<LocationPageWidget> {
  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Custom Action - userLocation] action in Button widget.
  bool? userGiveAccess;
  // Stores action output result for [Backend Call - API (InsertUserLocation)] action in Button widget.
  ApiCallResponse? locationResult;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
