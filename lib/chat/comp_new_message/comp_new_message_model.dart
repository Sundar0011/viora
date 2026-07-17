import '/auth/supabase_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/pages/home/comp_loading/comp_loading_widget.dart';
import 'dart:math';
import 'dart:ui';
import '/custom_code/actions/index.dart' as actions;
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';
import 'comp_new_message_widget.dart' show CompNewMessageWidget;
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class CompNewMessageModel extends FlutterFlowModel<CompNewMessageWidget> {
  ///  Local state fields for this component.

  List<dynamic> profileList = [];
  void addToProfileList(dynamic item) => profileList.add(item);
  void removeFromProfileList(dynamic item) => profileList.remove(item);
  void removeAtIndexFromProfileList(int index) => profileList.removeAt(index);
  void insertAtIndexInProfileList(int index, dynamic item) =>
      profileList.insert(index, item);
  void updateProfileListAtIndex(int index, Function(dynamic) updateFn) =>
      profileList[index] = updateFn(profileList[index]);

  bool show = false;

  ///  State fields for stateful widgets in this component.

  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode;
  TextEditingController? textController;
  String? Function(BuildContext, String?)? textControllerValidator;
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
}
