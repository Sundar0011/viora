import '/auth/supabase_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_timer.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/custom_code/widgets/index.dart' as custom_widgets;
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';
import 'comp_verify_widget.dart' show CompVerifyWidget;
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class CompVerifyModel extends FlutterFlowModel<CompVerifyWidget> {
  ///  Local state fields for this component.

  bool timerOn = true;

  String? errorMessage;

  bool showError = false;

  ///  State fields for stateful widgets in this component.

  // Stores action output result for [Backend Call - API (SendOtp)] action in Comp_verify widget.
  ApiCallResponse? apiResultr3q1Copy12;
  // Stores action output result for [Backend Call - API (SendOtp)] action in Comp_verify widget.
  ApiCallResponse? mobileOtpCopy34;
  // Stores action output result for [Backend Call - API (SendOtp)] action in Text widget.
  ApiCallResponse? apiResultr3q1;
  // Stores action output result for [Backend Call - API (SendOtp)] action in Text widget.
  ApiCallResponse? mobileOtp;
  // State field(s) for Timer widget.
  final timerInitialTimeMs = 30000;
  int timerMilliseconds = 30000;
  String timerValue = StopWatchTimer.getDisplayTime(
    30000,
    hours: false,
    minute: false,
    milliSecond: false,
  );
  FlutterFlowTimerController timerController =
      FlutterFlowTimerController(StopWatchTimer(mode: StopWatchMode.countDown));

  // Stores action output result for [Backend Call - API (VerifiOtp)] action in Button widget.
  ApiCallResponse? apiResulth23;
  // Stores action output result for [Backend Call - API (VerifiOtp)] action in Button widget.
  ApiCallResponse? apiResulthvx234;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    timerController.dispose();
  }
}
