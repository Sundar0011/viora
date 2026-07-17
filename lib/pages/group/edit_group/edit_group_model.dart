import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_radio_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/form_field_controller.dart';
import '/flutter_flow/upload_data.dart';
import 'dart:ui';
import '/flutter_flow/custom_functions.dart' as functions;
import 'edit_group_widget.dart' show EditGroupWidget;
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class EditGroupModel extends FlutterFlowModel<EditGroupWidget> {
  ///  Local state fields for this page.

  String? groupImage;

  bool locationError = false;

  bool typeError = false;

  bool discoverability = false;

  ///  State fields for stateful widgets in this page.

  final formKey1 = GlobalKey<FormState>();
  final formKey2 = GlobalKey<FormState>();
  final formKey3 = GlobalKey<FormState>();
  bool isDataUploading_uploadDataC04 = false;
  FFUploadedFile uploadedLocalFile_uploadDataC04 =
      FFUploadedFile(bytes: Uint8List.fromList([]), originalFilename: '');

  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode1;
  TextEditingController? textController1;
  String? Function(BuildContext, String?)? textController1Validator;
  String? _textController1Validator(BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return 'Name is required';
    }

    return null;
  }

  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode2;
  TextEditingController? textController2;
  String? Function(BuildContext, String?)? textController2Validator;
  String? _textController2Validator(BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return 'description is required';
    }

    return null;
  }

  // State field(s) for Location_RadioButton widget.
  FormFieldController<String>? locationRadioButtonValueController;
  // Stores action output result for [Validate Form] action in Button widget.
  bool? groupName;
  // Stores action output result for [Validate Form] action in Button widget.
  bool? description;
  // Stores action output result for [Validate Form] action in Button widget.
  bool? location;
  // Stores action output result for [Backend Call - Update Row(s)] action in Button widget.
  List<GroupRow>? group;
  bool isDataUploading_uploadDataFc2 = false;
  FFUploadedFile uploadedLocalFile_uploadDataFc2 =
      FFUploadedFile(bytes: Uint8List.fromList([]), originalFilename: '');
  String uploadedFileUrl_uploadDataFc2 = '';

  @override
  void initState(BuildContext context) {
    textController1Validator = _textController1Validator;
    textController2Validator = _textController2Validator;
  }

  @override
  void dispose() {
    textFieldFocusNode1?.dispose();
    textController1?.dispose();

    textFieldFocusNode2?.dispose();
    textController2?.dispose();
  }

  /// Additional helper methods.
  String? get locationRadioButtonValue =>
      locationRadioButtonValueController?.value;
}
