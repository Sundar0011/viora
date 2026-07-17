import '/auth/supabase_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/chat/comp_manage_chat/comp_manage_chat_widget.dart';
import '/chat/comp_new_message/comp_new_message_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/custom_code/actions/index.dart' as actions;
import '/custom_code/widgets/index.dart' as custom_widgets;
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';
import 'chat_widget.dart' show ChatWidget;
import 'dart:math' as math;
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ChatModel extends FlutterFlowModel<ChatWidget> {
  ///  Local state fields for this page.

  String? opt;

  bool? selectChat = false;

  int selectedCount = 0;

  bool selectAll = false;

  bool showLoader = true;

  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Backend Call - API (GetChat)] action in Chat widget.
  ApiCallResponse? userChat22;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode;
  TextEditingController? textController;
  String? Function(BuildContext, String?)? textControllerValidator;
  // Stores action output result for [Backend Call - API (softdeletechatusers)] action in Image widget.
  ApiCallResponse? apiResultvo9;
  // Stores action output result for [Backend Call - API (GetChat)] action in Messages_ListView widget.
  ApiCallResponse? userChat2;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    textFieldFocusNode?.dispose();
    textController?.dispose();
  }
}
