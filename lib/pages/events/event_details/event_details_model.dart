import '/auth/supabase_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/backend/supabase/supabase.dart';
import '/components/comp_no_data_found_widget.dart';
import '/flutter_flow/flutter_flow_google_map.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/pages/events/comp_event_three_dot1/comp_event_three_dot1_widget.dart';
import '/pages/events/comp_event_three_dot2/comp_event_three_dot2_widget.dart';
import '/pages/home/comp_loading/comp_loading_widget.dart';
import 'dart:ui';
import '/custom_code/actions/index.dart' as actions;
import '/custom_code/widgets/index.dart' as custom_widgets;
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';
import 'dart:async';
import 'dart:math' as math;
import 'event_details_widget.dart' show EventDetailsWidget;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class EventDetailsModel extends FlutterFlowModel<EventDetailsWidget> {
  ///  Local state fields for this page.

  bool readMore = false;

  bool viewAllFriends = false;

  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Backend Call - API (GetFollowingUsers)] action in EventDetails widget.
  ApiCallResponse? friendsList;
  Completer<ApiCallResponse>? apiRequestCompleter;
  // Stores action output result for [Backend Call - API (UpdateEventAttendeeCount)] action in Attend widget.
  ApiCallResponse? apiResultrykqw;
  // Stores action output result for [Backend Call - API (UpdateEventAttendeeCount)] action in invited widget.
  ApiCallResponse? apiResultrykww;
  // Stores action output result for [Backend Call - API (UpdateEventAttendeeCount)] action in Attending widget.
  ApiCallResponse? apiResultrykyyt;
  // State field(s) for GoogleMap widget.
  LatLng? googleMapsCenter;
  final googleMapsController = Completer<GoogleMapController>();
  // Stores action output result for [Backend Call - API (InviteUserToEvent)] action in Button widget.
  ApiCallResponse? apiResulta7nCopy;
  // Stores action output result for [Backend Call - API (InviteUserToEvent)] action in Button widget.
  ApiCallResponse? apiResulta7n;
  // Stores action output result for [Backend Call - API (UpdateEventAttendeeCount)] action in Attend widget.
  ApiCallResponse? apiResultryklop67;
  // Stores action output result for [Backend Call - API (UpdateEventAttendeeCount)] action in invited widget.
  ApiCallResponse? apiResultryklop78;
  // Stores action output result for [Backend Call - API (UpdateEventAttendeeCount)] action in Attending widget.
  ApiCallResponse? apiResultryklop09;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}

  /// Additional helper methods.
  Future waitForApiRequestCompleted({
    double minWait = 0,
    double maxWait = double.infinity,
  }) async {
    final stopwatch = Stopwatch()..start();
    while (true) {
      await Future.delayed(Duration(milliseconds: 50));
      final timeElapsed = stopwatch.elapsedMilliseconds;
      final requestComplete = apiRequestCompleter?.isCompleted ?? false;
      if (timeElapsed > maxWait || (requestComplete && timeElapsed > minWait)) {
        break;
      }
    }
  }
}
