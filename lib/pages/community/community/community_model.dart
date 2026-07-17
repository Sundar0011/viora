import '/auth/supabase_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/backend/supabase/supabase.dart';
import '/components/comp_no_data_found_widget.dart';
import '/components/comp_share_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/pages/business/comp_business_contact/comp_business_contact_widget.dart';
import '/pages/components/comp_navbar/comp_navbar_widget.dart';
import '/pages/home/comp_loading/comp_loading_widget.dart';
import 'dart:ui';
import '/custom_code/actions/index.dart' as actions;
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';
import 'community_widget.dart' show CommunityWidget;
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class CommunityModel extends FlutterFlowModel<CommunityWidget> {
  ///  Local state fields for this page.

  String switchBtn = 'groups';

  String? option = '';

  String? switchOpt;

  ///  State fields for stateful widgets in this page.

  Completer<List<EventAttendingRow>>? requestCompleter1;
  Completer<List<EventPageRow>>? requestCompleter4;
  Completer<List<EventPageRow>>? requestCompleter2;
  Completer<List<EventPageRow>>? requestCompleter3;
  // Stores action output result for [Backend Call - API (UpdateTotalGroupMembers)] action in Join widget.
  ApiCallResponse? apiResultd2p;
  // Stores action output result for [Backend Call - API (UpdateTotalGroupMembers)] action in Invited widget.
  ApiCallResponse? apiResultd2pp;
  // Stores action output result for [Backend Call - API (UpdateTotalGroupMembers)] action in Join widget.
  ApiCallResponse? apiResultd2p5;
  // Stores action output result for [Backend Call - API (UpdateTotalGroupMembers)] action in Invited widget.
  ApiCallResponse? apiResultd2ppCopy;
  // Stores action output result for [Backend Call - API (UpdateEventAttendeeCount)] action in Attend widget.
  ApiCallResponse? apiResultrykop;
  // Stores action output result for [Backend Call - API (UpdateEventAttendeeCount)] action in invited widget.
  ApiCallResponse? apiResultrykui;
  // Stores action output result for [Backend Call - API (UpdateEventAttendeeCount)] action in Attending widget.
  ApiCallResponse? apiResultrykyy;
  // Stores action output result for [Backend Call - API (UpdateEventAttendeeCount)] action in Attend widget.
  ApiCallResponse? apiResultrykmlk;
  // Stores action output result for [Backend Call - API (UpdateEventAttendeeCount)] action in invited widget.
  ApiCallResponse? apiResultryklop;
  // Stores action output result for [Backend Call - API (UpdateEventAttendeeCount)] action in Attending widget.
  ApiCallResponse? apiResultrykkl;
  // Stores action output result for [Backend Call - API (UpdateEventAttendeeCount)] action in Attend widget.
  ApiCallResponse? apiResultryklop67;
  // Stores action output result for [Backend Call - API (UpdateEventAttendeeCount)] action in invited widget.
  ApiCallResponse? apiResultryklop78;
  // Stores action output result for [Backend Call - API (UpdateEventAttendeeCount)] action in Attending widget.
  ApiCallResponse? apiResultryklop09;
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

  /// Additional helper methods.
  Future waitForRequestCompleted1({
    double minWait = 0,
    double maxWait = double.infinity,
  }) async {
    final stopwatch = Stopwatch()..start();
    while (true) {
      await Future.delayed(Duration(milliseconds: 50));
      final timeElapsed = stopwatch.elapsedMilliseconds;
      final requestComplete = requestCompleter1?.isCompleted ?? false;
      if (timeElapsed > maxWait || (requestComplete && timeElapsed > minWait)) {
        break;
      }
    }
  }

  Future waitForRequestCompleted4({
    double minWait = 0,
    double maxWait = double.infinity,
  }) async {
    final stopwatch = Stopwatch()..start();
    while (true) {
      await Future.delayed(Duration(milliseconds: 50));
      final timeElapsed = stopwatch.elapsedMilliseconds;
      final requestComplete = requestCompleter4?.isCompleted ?? false;
      if (timeElapsed > maxWait || (requestComplete && timeElapsed > minWait)) {
        break;
      }
    }
  }

  Future waitForRequestCompleted2({
    double minWait = 0,
    double maxWait = double.infinity,
  }) async {
    final stopwatch = Stopwatch()..start();
    while (true) {
      await Future.delayed(Duration(milliseconds: 50));
      final timeElapsed = stopwatch.elapsedMilliseconds;
      final requestComplete = requestCompleter2?.isCompleted ?? false;
      if (timeElapsed > maxWait || (requestComplete && timeElapsed > minWait)) {
        break;
      }
    }
  }

  Future waitForRequestCompleted3({
    double minWait = 0,
    double maxWait = double.infinity,
  }) async {
    final stopwatch = Stopwatch()..start();
    while (true) {
      await Future.delayed(Duration(milliseconds: 50));
      final timeElapsed = stopwatch.elapsedMilliseconds;
      final requestComplete = requestCompleter3?.isCompleted ?? false;
      if (timeElapsed > maxWait || (requestComplete && timeElapsed > minWait)) {
        break;
      }
    }
  }
}
