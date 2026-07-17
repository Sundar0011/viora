import '/auth/supabase_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/backend/supabase/supabase.dart';
import '/components/comp_no_data_found_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/pages/group/comp_no_groups_available/comp_no_groups_available_widget.dart';
import 'dart:ui';
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';
import 'my_group_widget.dart' show MyGroupWidget;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class MyGroupModel extends FlutterFlowModel<MyGroupWidget> {
  ///  Local state fields for this page.

  String? currentBtn;

  bool showListView = true;

  String noDataComponentName = 'none';

  ///  State fields for stateful widgets in this page.

  // Model for Comp_No_Data_Found component.
  late CompNoDataFoundModel compNoDataFoundModel1;
  // Model for Comp_No_Data_Found component.
  late CompNoDataFoundModel compNoDataFoundModel2;
  // Stores action output result for [Backend Call - API (UpdateTotalGroupMembers)] action in Join widget.
  ApiCallResponse? apiResultd2pnmb;
  // Stores action output result for [Backend Call - API (UpdateTotalGroupMembers)] action in Invited widget.
  ApiCallResponse? apiResultd2ppzxx;
  // Stores action output result for [Backend Call - API (UpdateTotalGroupMembers)] action in Join widget.
  ApiCallResponse? apiResultd2pq11;
  // Stores action output result for [Backend Call - API (UpdateTotalGroupMembers)] action in Invited widget.
  ApiCallResponse? apiResultd2ppCopyCopyCopyCopy;
  // Stores action output result for [Backend Call - API (UpdateTotalGroupMembers)] action in Join widget.
  ApiCallResponse? apiResultd2pxxxz;
  // Stores action output result for [Backend Call - API (UpdateTotalGroupMembers)] action in Invited widget.
  ApiCallResponse? apiResultd2ppCopyCopyCopy;
  // Stores action output result for [Backend Call - API (UpdateTotalGroupMembers)] action in Join widget.
  ApiCallResponse? apiResultd2pCopy;
  // Stores action output result for [Backend Call - API (UpdateTotalGroupMembers)] action in Invited widget.
  ApiCallResponse? apiResultd2ppCopyCopy;
  // Stores action output result for [Backend Call - API (UpdateTotalGroupMembers)] action in Join widget.
  ApiCallResponse? apiResultd2p;
  // Stores action output result for [Backend Call - API (UpdateTotalGroupMembers)] action in Invited widget.
  ApiCallResponse? apiResultd2ppCopy;

  @override
  void initState(BuildContext context) {
    compNoDataFoundModel1 = createModel(context, () => CompNoDataFoundModel());
    compNoDataFoundModel2 = createModel(context, () => CompNoDataFoundModel());
  }

  @override
  void dispose() {
    compNoDataFoundModel1.dispose();
    compNoDataFoundModel2.dispose();
  }
}
