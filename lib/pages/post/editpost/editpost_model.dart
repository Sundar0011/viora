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
import '/custom_code/widgets/index.dart' as custom_widgets;
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';
import 'editpost_widget.dart' show EditpostWidget;
import 'package:smooth_page_indicator/smooth_page_indicator.dart'
    as smooth_page_indicator;
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class EditpostModel extends FlutterFlowModel<EditpostWidget> {
  ///  Local state fields for this page.

  bool datapresent = false;

  List<String> images = [];
  void addToImages(String item) => images.add(item);
  void removeFromImages(String item) => images.remove(item);
  void removeAtIndexFromImages(int index) => images.removeAt(index);
  void insertAtIndexInImages(int index, String item) =>
      images.insert(index, item);
  void updateImagesAtIndex(int index, Function(String) updateFn) =>
      images[index] = updateFn(images[index]);

  int? imagesCount;

  List<String> imagesuploaded = [];
  void addToImagesuploaded(String item) => imagesuploaded.add(item);
  void removeFromImagesuploaded(String item) => imagesuploaded.remove(item);
  void removeAtIndexFromImagesuploaded(int index) =>
      imagesuploaded.removeAt(index);
  void insertAtIndexInImagesuploaded(int index, String item) =>
      imagesuploaded.insert(index, item);
  void updateImagesuploadedAtIndex(int index, Function(String) updateFn) =>
      imagesuploaded[index] = updateFn(imagesuploaded[index]);

  bool showImageIcon = false;

  List<FFUploadedFile> newuploadImages = [];
  void addToNewuploadImages(FFUploadedFile item) => newuploadImages.add(item);
  void removeFromNewuploadImages(FFUploadedFile item) =>
      newuploadImages.remove(item);
  void removeAtIndexFromNewuploadImages(int index) =>
      newuploadImages.removeAt(index);
  void insertAtIndexInNewuploadImages(int index, FFUploadedFile item) =>
      newuploadImages.insert(index, item);
  void updateNewuploadImagesAtIndex(
          int index, Function(FFUploadedFile) updateFn) =>
      newuploadImages[index] = updateFn(newuploadImages[index]);

  dynamic postData;

  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Backend Call - API (GetPostUserData)] action in Editpost widget.
  ApiCallResponse? apiResultzpx;
  bool isDataUploading_uploadDataUue = false;
  List<FFUploadedFile> uploadedLocalFiles_uploadDataUue = [];
  List<String> uploadedFileUrls_uploadDataUue = [];

  // Stores action output result for [Backend Call - API (UpdatePost)] action in Button widget.
  ApiCallResponse? updatepost;
  // State field(s) for Input_TextField widget.
  FocusNode? inputTextFieldFocusNode;
  TextEditingController? inputTextFieldTextController;
  String? Function(BuildContext, String?)?
      inputTextFieldTextControllerValidator;
  // State field(s) for PageView widget.
  PageController? pageViewController1;

  int get pageViewCurrentIndex1 => pageViewController1 != null &&
          pageViewController1!.hasClients &&
          pageViewController1!.page != null
      ? pageViewController1!.page!.round()
      : 0;
  // State field(s) for PageView widget.
  PageController? pageViewController2;

  int get pageViewCurrentIndex2 => pageViewController2 != null &&
          pageViewController2!.hasClients &&
          pageViewController2!.page != null
      ? pageViewController2!.page!.round()
      : 0;
  bool isDataUploading_uploadDataVel = false;
  List<FFUploadedFile> uploadedLocalFiles_uploadDataVel = [];

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    inputTextFieldFocusNode?.dispose();
    inputTextFieldTextController?.dispose();
  }
}
