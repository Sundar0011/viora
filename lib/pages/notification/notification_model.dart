import '/auth/supabase_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/backend/supabase/supabase.dart';
import '/components/comp_no_data_found_widget.dart';
import '/components/comp_notification_widget.dart';
import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/pages/components/comp_navbar/comp_navbar_widget.dart';
import 'dart:math';
import 'dart:ui';
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';
import 'dart:math' as math;
import 'notification_widget.dart' show NotificationWidget;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class NotificationModel extends FlutterFlowModel<NotificationWidget> {
  ///  Local state fields for this page.

  String? opt;

  bool showData = false;

  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Backend Call - API (Notification)] action in Notification widget.
  ApiCallResponse? notificationjson;
  // Stores action output result for [Backend Call - API (Notification)] action in Notification_Container widget.
  ApiCallResponse? notificationjson1;
  // Stores action output result for [Backend Call - API (Notification)] action in Notification_Container widget.
  ApiCallResponse? notificationjson12;
  // Stores action output result for [Backend Call - API (Notification)] action in Notification_Container widget.
  ApiCallResponse? notificationjson131;
  // Stores action output result for [Backend Call - API (Notification)] action in Notification_Container widget.
  ApiCallResponse? notificationjson132;
  // Stores action output result for [Backend Call - API (Notification)] action in Notification_Container widget.
  ApiCallResponse? notificationjson1113;
  // Stores action output result for [Backend Call - API (Notification)] action in Notification_Container widget.
  ApiCallResponse? notificationjson1322;
  // Stores action output result for [Backend Call - API (Notification)] action in Notification_Container widget.
  ApiCallResponse? notificationjson1332;
  // Stores action output result for [Backend Call - API (Notification)] action in Notification_Container widget.
  ApiCallResponse? notificationjson100;
  // Stores action output result for [Backend Call - API (Notification)] action in Notification_Container widget.
  ApiCallResponse? json1;
  // Stores action output result for [Backend Call - API (Notification)] action in Notification_Container widget.
  ApiCallResponse? json5;
  // Stores action output result for [Backend Call - API (Notification)] action in Notification_Container widget.
  ApiCallResponse? json4;
  // Stores action output result for [Backend Call - API (Notification)] action in Notification_Container widget.
  ApiCallResponse? json2;
  // Stores action output result for [Backend Call - API (Notification)] action in Notification_Container widget.
  ApiCallResponse? json3;
  // Model for Comp_Navbar component.
  late CompNavbarModel compNavbarModel;

  @override
  void initState(BuildContext context) {
    compNavbarModel = createModel(context, () => CompNavbarModel());
  }

  @override
  void dispose() {
    compNavbarModel.dispose();
  }
}
