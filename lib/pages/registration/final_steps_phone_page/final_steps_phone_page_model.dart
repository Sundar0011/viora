import '/backend/api_requests/api_calls.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/custom_code/actions/index.dart' as actions;
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';
import 'final_steps_phone_page_widget.dart' show FinalStepsPhonePageWidget;
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class FinalStepsPhonePageModel
    extends FlutterFlowModel<FinalStepsPhonePageWidget> {
  ///  Local state fields for this page.

  bool passwordMatchedError = false;

  bool mobileExist = false;

  ///  State fields for stateful widgets in this page.

  final formKey2 = GlobalKey<FormState>();
  final formKey3 = GlobalKey<FormState>();
  final formKey1 = GlobalKey<FormState>();
  // Stores action output result for [Custom Action - checkInternetConnect] action in FinalStepsPhonePage widget.
  bool? isOnline1;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode1;
  TextEditingController? textController1;
  String? Function(BuildContext, String?)? textController1Validator;
  String? _textController1Validator(BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return 'Mobile number is required';
    }

    if (val.length < 10) {
      return 'Enter 10 digit mobile number';
    }
    if (val.length > 11) {
      return 'Enter maximum 11 digit mobile number';
    }

    return null;
  }

  // Stores action output result for [Backend Call - API (CheckUserExist)] action in TextField widget.
  ApiCallResponse? apiResultzlj;
  // OTP BYPASS (2026-07-21): account-creation results, moved here from verify_page
  // because phone signup now completes on this page instead of after an OTP step.
  ApiCallResponse? phoneSignUp;
  String? phoneLogin;
  UserRow? user;
  UserRolesRow? role;
  PublicUserProfileRow? profile;
  ApiCallResponse? locationResult3;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode2;
  TextEditingController? textController2;
  late bool passwordVisibility1;
  String? Function(BuildContext, String?)? textController2Validator;
  String? _textController2Validator(BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return 'Password is required';
    }

    if (val.length < 6) {
      return 'Oops! Your password needs at least 6 characters.';
    }

    return null;
  }

  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode3;
  TextEditingController? textController3;
  late bool passwordVisibility2;
  String? Function(BuildContext, String?)? textController3Validator;
  String? _textController3Validator(BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return 'Password is required';
    }

    if (val.length < 6) {
      return 'Oops! Your password needs at least 6 characters.';
    }

    return null;
  }

  // Stores action output result for [Validate Form] action in Button widget.
  bool? mobile;
  // Stores action output result for [Custom Action - checkInternetConnect] action in Button widget.
  bool? isOnline13;
  // Stores action output result for [Validate Form] action in Button widget.
  bool? password1;

  @override
  void initState(BuildContext context) {
    textController1Validator = _textController1Validator;
    passwordVisibility1 = false;
    textController2Validator = _textController2Validator;
    passwordVisibility2 = false;
    textController3Validator = _textController3Validator;
  }

  @override
  void dispose() {
    textFieldFocusNode1?.dispose();
    textController1?.dispose();

    textFieldFocusNode2?.dispose();
    textController2?.dispose();

    textFieldFocusNode3?.dispose();
    textController3?.dispose();
  }
}
