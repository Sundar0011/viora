import '/auth/supabase_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_timer.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/custom_code/actions/index.dart' as actions;
import '/custom_code/widgets/index.dart' as custom_widgets;
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'verify_page_widget.dart' show VerifyPageWidget;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class VerifyPageModel extends FlutterFlowModel<VerifyPageWidget> {
  ///  Local state fields for this page.

  bool pinCodeError = false;

  String errorMessage = 'Field is requird';

  bool timerOn = true;

  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Backend Call - API (SendOtp)] action in Text widget.
  ApiCallResponse? apiResultr3q1;
  // Stores action output result for [Backend Call - API (SendOtp)] action in Text widget.
  ApiCallResponse? apiResultr3q;
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
  ApiCallResponse? apiResulth;
  // Stores action output result for [Backend Call - Insert Row] action in Button widget.
  UserRow? userTable;
  // Stores action output result for [Backend Call - Insert Row] action in Button widget.
  UserRolesRow? userRole;
  // Stores action output result for [Backend Call - Insert Row] action in Button widget.
  PublicUserProfileRow? publicProfile;
  // Stores action output result for [Backend Call - API (InsertUserLocation)] action in Button widget.
  ApiCallResponse? locationResult;
  // Stores action output result for [Backend Call - API (VerifiOtp)] action in Button widget.
  ApiCallResponse? apiResulthvx;
  // Stores action output result for [Backend Call - API (PhoneSignup)] action in Button widget.
  ApiCallResponse? phoneSignUp;
  // Stores action output result for [Custom Action - signInWithPhone] action in Button widget.
  String? phoneLogin;
  // Stores action output result for [Backend Call - Insert Row] action in Button widget.
  UserRow? user;
  // Stores action output result for [Backend Call - Insert Row] action in Button widget.
  UserRolesRow? role;
  // Stores action output result for [Backend Call - Insert Row] action in Button widget.
  PublicUserProfileRow? profile;
  // Stores action output result for [Backend Call - API (InsertUserLocation)] action in Button widget.
  ApiCallResponse? locationResult3;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    timerController.dispose();
  }
}
