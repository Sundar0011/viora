import '/auth/supabase_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/pages/group/comp_confirm_admin_role/comp_confirm_admin_role_widget.dart';
import '/pages/group/comp_revoke_admin/comp_revoke_admin_widget.dart';
import 'dart:ui';
import 'comp_assign_admin_widget.dart' show CompAssignAdminWidget;
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class CompAssignAdminModel extends FlutterFlowModel<CompAssignAdminWidget> {
  ///  Local state fields for this component.

  bool show = false;

  ///  State fields for stateful widgets in this component.

  // Stores action output result for [Backend Call - API (GroupMembers)] action in Comp_Assign_Admin widget.
  ApiCallResponse? memData1;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode;
  TextEditingController? textController;
  String? Function(BuildContext, String?)? textControllerValidator;
  // Stores action output result for [Backend Call - API (GroupMembers)] action in TextField widget.
  ApiCallResponse? memReacord2;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    textFieldFocusNode?.dispose();
    textController?.dispose();
  }
}
