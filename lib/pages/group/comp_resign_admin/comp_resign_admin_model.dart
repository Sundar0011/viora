import '/auth/supabase_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'comp_resign_admin_widget.dart' show CompResignAdminWidget;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class CompResignAdminModel extends FlutterFlowModel<CompResignAdminWidget> {
  ///  State fields for stateful widgets in this component.

  // Stores action output result for [Backend Call - API (GroupMembers)] action in Button widget.
  ApiCallResponse? adminMembers;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
