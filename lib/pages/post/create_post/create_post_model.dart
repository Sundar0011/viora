import '/auth/supabase_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/upload_data.dart';
import '/pages/post/comp_view_access/comp_view_access_widget.dart';
import 'dart:ui';
import '/custom_code/actions/index.dart' as actions;
import '/custom_code/widgets/index.dart' as custom_widgets;
import '/flutter_flow/custom_functions.dart' as functions;
import 'create_post_widget.dart' show CreatePostWidget;
import 'package:smooth_page_indicator/smooth_page_indicator.dart'
    as smooth_page_indicator;
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class CreatePostModel extends FlutterFlowModel<CreatePostWidget> {
  ///  Local state fields for this page.

  bool datapresent = false;

  List<FFUploadedFile> uploadedImage = [];
  void addToUploadedImage(FFUploadedFile item) => uploadedImage.add(item);
  void removeFromUploadedImage(FFUploadedFile item) =>
      uploadedImage.remove(item);
  void removeAtIndexFromUploadedImage(int index) =>
      uploadedImage.removeAt(index);
  void insertAtIndexInUploadedImage(int index, FFUploadedFile item) =>
      uploadedImage.insert(index, item);
  void updateUploadedImageAtIndex(
          int index, Function(FFUploadedFile) updateFn) =>
      uploadedImage[index] = updateFn(uploadedImage[index]);

  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Backend Call - Insert Row] action in Button widget.
  PostRow? postRow;
  bool isDataUploading_uploadDataValue2 = false;
  List<FFUploadedFile> uploadedLocalFiles_uploadDataValue2 = [];
  List<String> uploadedFileUrls_uploadDataValue2 = [];

  // Stores action output result for [Backend Call - API (InsertImageUrls)] action in Button widget.
  ApiCallResponse? kkjk;
  // Stores action output result for [Backend Call - API (GetPost)] action in Button widget.
  ApiCallResponse? post11;
  // State field(s) for Input_TextField widget.
  FocusNode? inputTextFieldFocusNode;
  TextEditingController? inputTextFieldTextController;
  String? Function(BuildContext, String?)?
      inputTextFieldTextControllerValidator;
  // State field(s) for PageView widget.
  PageController? pageViewController;

  int get pageViewCurrentIndex => pageViewController != null &&
          pageViewController!.hasClients &&
          pageViewController!.page != null
      ? pageViewController!.page!.round()
      : 0;
  bool isDataUploading_uploadDataValue = false;
  List<FFUploadedFile> uploadedLocalFiles_uploadDataValue = [];

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    inputTextFieldFocusNode?.dispose();
    inputTextFieldTextController?.dispose();
  }
}
