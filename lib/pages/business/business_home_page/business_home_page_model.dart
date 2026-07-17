import '/auth/supabase_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/backend/supabase/supabase.dart';
import '/components/comp_share_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/pages/business/comp_business_contact/comp_business_contact_widget.dart';
import '/pages/business/comp_three_dot_edit_business/comp_three_dot_edit_business_widget.dart';
import '/pages/business/comp_three_dot_report_business/comp_three_dot_report_business_widget.dart';
import 'dart:ui';
import '/custom_code/actions/index.dart' as actions;
import '/custom_code/widgets/index.dart' as custom_widgets;
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';
import 'business_home_page_widget.dart' show BusinessHomePageWidget;
import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class BusinessHomePageModel extends FlutterFlowModel<BusinessHomePageWidget> {
  ///  Local state fields for this page.

  bool pageReadMore = false;

  dynamic serviceitems4;

  dynamic serviceitemsAll;

  dynamic businessDataValues;

  bool serviceView = false;

  bool showData = true;

  double? adminLat;

  double? adminLng;

  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Backend Call - API (BusinessHomepage)] action in BusinessHomePage widget.
  ApiCallResponse? businessData;
  Completer<ApiCallResponse>? apiRequestCompleter;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode;
  TextEditingController? textController;
  String? Function(BuildContext, String?)? textControllerValidator;
  // Stores action output result for [Backend Call - API (UpdateContacted)] action in Button widget.
  ApiCallResponse? apiResultasp;
  // Stores action output result for [Backend Call - API (UpdateContacted)] action in Button widget.
  ApiCallResponse? apiResulta;
  // Stores action output result for [Backend Call - API (UpdateContacted)] action in Button widget.
  ApiCallResponse? apiResultas;
  // Stores action output result for [Backend Call - API (FindCommonChat)] action in Button widget.
  ApiCallResponse? chatFound;
  // Stores action output result for [Backend Call - Insert Row] action in Button widget.
  ChatRow? chat;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    textFieldFocusNode?.dispose();
    textController?.dispose();
  }

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
