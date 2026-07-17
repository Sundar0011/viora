import '/auth/supabase_auth/auth_util.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/upload_data.dart';
import 'dart:ui';
import '/custom_code/actions/index.dart' as actions;
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';
import 'create_page_widget.dart' show CreatePageWidget;
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class CreatePageModel extends FlutterFlowModel<CreatePageWidget> {
  ///  Local state fields for this page.

  String? opt;

  bool checkBox = false;

  ///  State fields for stateful widgets in this page.

  final formKey5 = GlobalKey<FormState>();
  final formKey1 = GlobalKey<FormState>();
  final formKey2 = GlobalKey<FormState>();
  final formKey4 = GlobalKey<FormState>();
  final formKey3 = GlobalKey<FormState>();
  final formKey6 = GlobalKey<FormState>();
  bool isDataUploading_uploadData8rh = false;
  FFUploadedFile uploadedLocalFile_uploadData8rh =
      FFUploadedFile(bytes: Uint8List.fromList([]), originalFilename: '');

  bool isDataUploading_uploadDataProfile = false;
  FFUploadedFile uploadedLocalFile_uploadDataProfile =
      FFUploadedFile(bytes: Uint8List.fromList([]), originalFilename: '');

  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode1;
  TextEditingController? textController1;
  String? Function(BuildContext, String?)? textController1Validator;
  String? _textController1Validator(BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return 'Business Name is required';
    }

    return null;
  }

  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode2;
  TextEditingController? textController2;
  String? Function(BuildContext, String?)? textController2Validator;
  String? _textController2Validator(BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return 'Services Name is required';
    }

    return null;
  }

  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode3;
  TextEditingController? textController3;
  String? Function(BuildContext, String?)? textController3Validator;
  String? _textController3Validator(BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return 'Bio is required';
    }

    return null;
  }

  // State field(s) for Website_TextField widget.
  FocusNode? websiteTextFieldFocusNode;
  TextEditingController? websiteTextFieldTextController;
  String? Function(BuildContext, String?)?
      websiteTextFieldTextControllerValidator;
  String? _websiteTextFieldTextControllerValidator(
      BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return 'Website link is required';
    }

    if (!RegExp(kTextValidatorWebsiteRegex).hasMatch(val)) {
      return 'invalid website format';
    }
    return null;
  }

  // State field(s) for Email_TextField widget.
  FocusNode? emailTextFieldFocusNode;
  TextEditingController? emailTextFieldTextController;
  String? Function(BuildContext, String?)?
      emailTextFieldTextControllerValidator;
  String? _emailTextFieldTextControllerValidator(
      BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return 'Email is required';
    }

    if (!RegExp(kTextValidatorEmailRegex).hasMatch(val)) {
      return 'invalid email format';
    }
    return null;
  }

  // State field(s) for Phone_TextField widget.
  FocusNode? phoneTextFieldFocusNode;
  TextEditingController? phoneTextFieldTextController;
  String? Function(BuildContext, String?)?
      phoneTextFieldTextControllerValidator;
  String? _phoneTextFieldTextControllerValidator(
      BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return 'Phone number is required';
    }

    if (val.length < 10) {
      return 'minimum 10 digits required';
    }
    if (val.length > 10) {
      return 'Maximum 10 characters allowed, currently ${val.length}.';
    }

    return null;
  }

  // State field(s) for Checkbox widget.
  bool? checkboxValue;
  // Stores action output result for [Validate Form] action in Button widget.
  bool? name;
  // Stores action output result for [Validate Form] action in Button widget.
  bool? service;
  // Stores action output result for [Validate Form] action in Button widget.
  bool? bio;
  // Stores action output result for [Validate Form] action in Button widget.
  bool? website;
  // Stores action output result for [Validate Form] action in Button widget.
  bool? email;
  // Stores action output result for [Validate Form] action in Button widget.
  bool? mobile;
  // Stores action output result for [Backend Call - Insert Row] action in Button widget.
  BusinessPageRow? businessData;
  // Stores action output result for [Custom Action - uploadBusinessImages] action in Button widget.
  List<String>? uploadUrls;
  // Stores action output result for [Custom Action - uploadBusinessImages] action in Button widget.
  List<String>? uploadUrlsEdit;
  // Stores action output result for [Validate Form] action in Button widget.
  bool? mobile5;
  // Stores action output result for [Validate Form] action in Button widget.
  bool? email4;
  // Stores action output result for [Validate Form] action in Button widget.
  bool? mobile4;
  // Stores action output result for [Validate Form] action in Button widget.
  bool? website3;
  // Stores action output result for [Validate Form] action in Button widget.
  bool? email3;
  // Stores action output result for [Validate Form] action in Button widget.
  bool? mobile3;
  // Stores action output result for [Validate Form] action in Button widget.
  bool? bio2;
  // Stores action output result for [Validate Form] action in Button widget.
  bool? website2;
  // Stores action output result for [Validate Form] action in Button widget.
  bool? email2;
  // Stores action output result for [Validate Form] action in Button widget.
  bool? mobile2;
  // Stores action output result for [Validate Form] action in Button widget.
  bool? service1;
  // Stores action output result for [Validate Form] action in Button widget.
  bool? bio1;
  // Stores action output result for [Validate Form] action in Button widget.
  bool? website1;
  // Stores action output result for [Validate Form] action in Button widget.
  bool? email1;
  // Stores action output result for [Validate Form] action in Button widget.
  bool? mobile1;

  @override
  void initState(BuildContext context) {
    textController1Validator = _textController1Validator;
    textController2Validator = _textController2Validator;
    textController3Validator = _textController3Validator;
    websiteTextFieldTextControllerValidator =
        _websiteTextFieldTextControllerValidator;
    emailTextFieldTextControllerValidator =
        _emailTextFieldTextControllerValidator;
    phoneTextFieldTextControllerValidator =
        _phoneTextFieldTextControllerValidator;
  }

  @override
  void dispose() {
    textFieldFocusNode1?.dispose();
    textController1?.dispose();

    textFieldFocusNode2?.dispose();
    textController2?.dispose();

    textFieldFocusNode3?.dispose();
    textController3?.dispose();

    websiteTextFieldFocusNode?.dispose();
    websiteTextFieldTextController?.dispose();

    emailTextFieldFocusNode?.dispose();
    emailTextFieldTextController?.dispose();

    phoneTextFieldFocusNode?.dispose();
    phoneTextFieldTextController?.dispose();
  }
}
