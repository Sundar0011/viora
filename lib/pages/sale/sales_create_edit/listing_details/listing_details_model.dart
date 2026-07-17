import '/auth/supabase_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_drop_down.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_radio_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/form_field_controller.dart';
import '/flutter_flow/upload_data.dart';
import 'dart:ui';
import '/custom_code/actions/index.dart' as actions;
import '/index.dart';
import 'listing_details_widget.dart' show ListingDetailsWidget;
import 'package:smooth_page_indicator/smooth_page_indicator.dart'
    as smooth_page_indicator;
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ListingDetailsModel extends FlutterFlowModel<ListingDetailsWidget> {
  ///  Local state fields for this page.

  String price = 'Free';

  bool categoryChoosed = false;

  bool imageSet = false;

  String? categoryid;

  bool showSuggestions = false;

  String? choosedPlace;

  List<String> placesList = [];
  void addToPlacesList(String item) => placesList.add(item);
  void removeFromPlacesList(String item) => placesList.remove(item);
  void removeAtIndexFromPlacesList(int index) => placesList.removeAt(index);
  void insertAtIndexInPlacesList(int index, String item) =>
      placesList.insert(index, item);
  void updatePlacesListAtIndex(int index, Function(String) updateFn) =>
      placesList[index] = updateFn(placesList[index]);

  bool showLocationError = false;

  double? latitude;

  double? longitude;

  List<String> placesId = [];
  void addToPlacesId(String item) => placesId.add(item);
  void removeFromPlacesId(String item) => placesId.remove(item);
  void removeAtIndexFromPlacesId(int index) => placesId.removeAt(index);
  void insertAtIndexInPlacesId(int index, String item) =>
      placesId.insert(index, item);
  void updatePlacesIdAtIndex(int index, Function(String) updateFn) =>
      placesId[index] = updateFn(placesId[index]);

  String? city;

  List<FFUploadedFile> uploadedFiles = [];
  void addToUploadedFiles(FFUploadedFile item) => uploadedFiles.add(item);
  void removeFromUploadedFiles(FFUploadedFile item) =>
      uploadedFiles.remove(item);
  void removeAtIndexFromUploadedFiles(int index) =>
      uploadedFiles.removeAt(index);
  void insertAtIndexInUploadedFiles(int index, FFUploadedFile item) =>
      uploadedFiles.insert(index, item);
  void updateUploadedFilesAtIndex(
          int index, Function(FFUploadedFile) updateFn) =>
      uploadedFiles[index] = updateFn(uploadedFiles[index]);

  ///  State fields for stateful widgets in this page.

  final formKey2 = GlobalKey<FormState>();
  final formKey1 = GlobalKey<FormState>();
  final formKey3 = GlobalKey<FormState>();
  // State field(s) for PageView widget.
  PageController? pageViewController;

  int get pageViewCurrentIndex => pageViewController != null &&
          pageViewController!.hasClients &&
          pageViewController!.page != null
      ? pageViewController!.page!.round()
      : 0;
  bool isDataUploading_uploadDataGq21 = false;
  List<FFUploadedFile> uploadedLocalFiles_uploadDataGq21 = [];

  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode1;
  TextEditingController? textController1;
  String? Function(BuildContext, String?)? textController1Validator;
  String? _textController1Validator(BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return 'Title is required';
    }

    return null;
  }

  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode2;
  TextEditingController? textFieldTextController;
  String? Function(BuildContext, String?)? textFieldTextControllerValidator;
  String? _textFieldTextControllerValidator(BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return 'Description is required';
    }

    return null;
  }

  // State field(s) for DropDown widget.
  String? dropDownValue;
  FormFieldController<String>? dropDownValueController;
  // State field(s) for RadioButton widget.
  FormFieldController<String>? radioButtonValueController;
  // State field(s) for Price_TextField widget.
  FocusNode? priceTextFieldFocusNode;
  TextEditingController? priceTextFieldTextController;
  String? Function(BuildContext, String?)?
      priceTextFieldTextControllerValidator;
  String? _priceTextFieldTextControllerValidator(
      BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return 'Selling price is required';
    }

    return null;
  }

  // State field(s) for LocationTextField widget.
  FocusNode? locationTextFieldFocusNode;
  TextEditingController? locationTextFieldTextController;
  String? Function(BuildContext, String?)?
      locationTextFieldTextControllerValidator;
  // Stores action output result for [Backend Call - API (ShowSuggestions)] action in LocationTextField widget.
  ApiCallResponse? places;
  // Stores action output result for [Backend Call - API (GetPlaceDetails)] action in Container widget.
  ApiCallResponse? placeDetails;
  // Stores action output result for [Validate Form] action in Button widget.
  bool? titleform1;
  // Stores action output result for [Validate Form] action in Button widget.
  bool? descriptionform1;
  // Stores action output result for [Backend Call - API (InsertSaleDetails)] action in Button widget.
  ApiCallResponse? insert1;
  // Stores action output result for [Validate Form] action in Button widget.
  bool? priceform1;
  // Stores action output result for [Backend Call - API (InsertSaleDetails)] action in Button widget.
  ApiCallResponse? insert2;

  @override
  void initState(BuildContext context) {
    textController1Validator = _textController1Validator;
    textFieldTextControllerValidator = _textFieldTextControllerValidator;
    priceTextFieldTextControllerValidator =
        _priceTextFieldTextControllerValidator;
  }

  @override
  void dispose() {
    textFieldFocusNode1?.dispose();
    textController1?.dispose();

    textFieldFocusNode2?.dispose();
    textFieldTextController?.dispose();

    priceTextFieldFocusNode?.dispose();
    priceTextFieldTextController?.dispose();

    locationTextFieldFocusNode?.dispose();
    locationTextFieldTextController?.dispose();
  }

  /// Additional helper methods.
  String? get radioButtonValue => radioButtonValueController?.value;
}
