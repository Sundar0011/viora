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
import 'ending_event_widget.dart' show EndingEventWidget;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class EndingEventModel extends FlutterFlowModel<EndingEventWidget> {
  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Backend Call - API (UpdateEventAttendeeCount)] action in Attend widget.
  ApiCallResponse? apiResultrykmlk;
  // Stores action output result for [Backend Call - API (UpdateEventAttendeeCount)] action in invited widget.
  ApiCallResponse? apiResultryklop;
  // Stores action output result for [Backend Call - API (UpdateEventAttendeeCount)] action in Attending widget.
  ApiCallResponse? apiResultrykkl;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
