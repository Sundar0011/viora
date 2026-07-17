import '/auth/supabase_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/backend/supabase/supabase.dart';
import '/components/comp_no_data_found_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/pages/home/comp_loading/comp_loading_widget.dart';
import 'dart:ui';
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';
import 'all_events_widget.dart' show AllEventsWidget;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class AllEventsModel extends FlutterFlowModel<AllEventsWidget> {
  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Backend Call - API (UpdateEventAttendeeCount)] action in Attend widget.
  ApiCallResponse? apiResultrykre;
  // Stores action output result for [Backend Call - API (UpdateEventAttendeeCount)] action in invited widget.
  ApiCallResponse? apiResultrykuu;
  // Stores action output result for [Backend Call - API (UpdateEventAttendeeCount)] action in Attending widget.
  ApiCallResponse? kk;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
