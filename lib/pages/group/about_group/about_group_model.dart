import '/auth/supabase_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/pages/group/comp_assign_admin/comp_assign_admin_widget.dart';
import 'dart:ui';
import '/custom_code/actions/index.dart' as actions;
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';
import 'about_group_widget.dart' show AboutGroupWidget;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class AboutGroupModel extends FlutterFlowModel<AboutGroupWidget> {
  ///  Local state fields for this page.

  String? readMore;

  String? showMoreId;

  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Backend Call - API (FindCommonChat)] action in message_To_Admin_Button widget.
  ApiCallResponse? chatFound;
  // Stores action output result for [Backend Call - Insert Row] action in message_To_Admin_Button widget.
  ChatRow? chat;
  // Stores action output result for [Backend Call - API (delete admin)] action in Revoke_Role_Button widget.
  ApiCallResponse? apiResultytyCopy;
  // Stores action output result for [Backend Call - API (delete admin)] action in Resign_Role_Button widget.
  ApiCallResponse? apiResultyty;
  // Stores action output result for [Backend Call - API (UpdateTotalGroupMembers)] action in Join widget.
  ApiCallResponse? apiResultd2p;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
