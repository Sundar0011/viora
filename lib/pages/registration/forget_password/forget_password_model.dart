import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';
import 'forget_password_widget.dart' show ForgetPasswordWidget;
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ForgetPasswordModel extends FlutterFlowModel<ForgetPasswordWidget> {
  ///  Local state fields for this page.

  bool checkBoxError = false;

  String errorMessage = 'invaild credentials';

  bool isEmail = false;

  String? validEmailError;

  String? validMobileError;

  ///  State fields for stateful widgets in this page.

  final formKey1 = GlobalKey<FormState>();
  final formKey2 = GlobalKey<FormState>();
  // State field(s) for Input-Mobile_Number widget.
  FocusNode? inputMobileNumberFocusNode;
  TextEditingController? inputMobileNumberTextController;
  String? Function(BuildContext, String?)?
      inputMobileNumberTextControllerValidator;
  String? _inputMobileNumberTextControllerValidator(
      BuildContext context, String? val) {
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

  // State field(s) for Input_Email widget.
  FocusNode? inputEmailFocusNode;
  TextEditingController? inputEmailTextController;
  String? Function(BuildContext, String?)? inputEmailTextControllerValidator;
  String? _inputEmailTextControllerValidator(
      BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return 'Email is required';
    }

    if (!RegExp(kTextValidatorEmailRegex).hasMatch(val)) {
      return 'Has to be a valid email address.';
    }
    return null;
  }

  // Stores action output result for [Backend Call - API (CheckUser)] action in Button widget.
  ApiCallResponse? isValidEmail;
  // Stores action output result for [Backend Call - API (SendOtp)] action in Button widget.
  ApiCallResponse? otpSend;
  // Stores action output result for [Backend Call - API (CheckUser)] action in Button widget.
  ApiCallResponse? isValidMobile;
  // Stores action output result for [Backend Call - API (SendOtp)] action in Button widget.
  ApiCallResponse? mobileotpSend;

  @override
  void initState(BuildContext context) {
    inputMobileNumberTextControllerValidator =
        _inputMobileNumberTextControllerValidator;
    inputEmailTextControllerValidator = _inputEmailTextControllerValidator;
  }

  @override
  void dispose() {
    inputMobileNumberFocusNode?.dispose();
    inputMobileNumberTextController?.dispose();

    inputEmailFocusNode?.dispose();
    inputEmailTextController?.dispose();
  }
}
