import '/auth/supabase_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/custom_code/actions/index.dart' as actions;
import '/index.dart';
import 'comp_location_permission_widget.dart' show CompLocationPermissionWidget;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class CompLocationPermissionModel
    extends FlutterFlowModel<CompLocationPermissionWidget> {
  ///  State fields for stateful widgets in this component.

  // Stores action output result for [Custom Action - userLocation] action in Button widget.
  bool? userGiveAccess;
  // Stores action output result for [Backend Call - API (InsertUserLocation)] action in Button widget.
  ApiCallResponse? locationResult;
  // Stores action output result for [Backend Call - API (GetNeighborhoodPeoples)] action in Button widget.
  ApiCallResponse? following;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
