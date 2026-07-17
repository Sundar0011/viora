import '/auth/supabase_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/index.dart';
import 'loading_widget.dart' show LoadingWidget;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class LoadingModel extends FlutterFlowModel<LoadingWidget> {
  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Backend Call - API (GetPostAllComments)] action in loading widget.
  ApiCallResponse? apiResultpio;
  // Stores action output result for [Backend Call - API (CheckGroupMemberShare)] action in loading widget.
  ApiCallResponse? showPost1;
  // Stores action output result for [Backend Call - Query Rows] action in loading widget.
  List<ChatUsersRow>? chat;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
