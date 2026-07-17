import '/auth/supabase_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_radio_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/form_field_controller.dart';
import '/flutter_flow/upload_data.dart';
import '/pages/events/comp_select_date_time/comp_select_date_time_widget.dart';
import 'dart:ui';
import '/custom_code/actions/index.dart' as actions;
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';
import 'create_event_widget.dart' show CreateEventWidget;
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class CreateEventModel extends FlutterFlowModel<CreateEventWidget> {
  ///  Local state fields for this page.

  bool checkbox = false;

  List<String> placesList = [];
  void addToPlacesList(String item) => placesList.add(item);
  void removeFromPlacesList(String item) => placesList.remove(item);
  void removeAtIndexFromPlacesList(int index) => placesList.removeAt(index);
  void insertAtIndexInPlacesList(int index, String item) =>
      placesList.insert(index, item);
  void updatePlacesListAtIndex(int index, Function(String) updateFn) =>
      placesList[index] = updateFn(placesList[index]);

  bool showSuggestion = false;

  String? choosedPlace;

  bool showLocationError = false;

  String? startDate;

  String? endDate;

  bool showEventError = false;

  bool showStartDateError = false;

  List<int> inter = [0, 4];
  void addToInter(int item) => inter.add(item);
  void removeFromInter(int item) => inter.remove(item);
  void removeAtIndexFromInter(int index) => inter.removeAt(index);
  void insertAtIndexInInter(int index, int item) => inter.insert(index, item);
  void updateInterAtIndex(int index, Function(int) updateFn) =>
      inter[index] = updateFn(inter[index]);

  bool showImageError = false;

  bool showLinkError = false;

  double? latitude;

  double? logitude;

  List<String> placeId = [];
  void addToPlaceId(String item) => placeId.add(item);
  void removeFromPlaceId(String item) => placeId.remove(item);
  void removeAtIndexFromPlaceId(int index) => placeId.removeAt(index);
  void insertAtIndexInPlaceId(int index, String item) =>
      placeId.insert(index, item);
  void updatePlaceIdAtIndex(int index, Function(String) updateFn) =>
      placeId[index] = updateFn(placeId[index]);

  bool endDateError = false;

  ///  State fields for stateful widgets in this page.

  final formKey4 = GlobalKey<FormState>();
  final formKey1 = GlobalKey<FormState>();
  final formKey2 = GlobalKey<FormState>();
  final formKey3 = GlobalKey<FormState>();
  bool isDataUploading_eventImage = false;
  FFUploadedFile uploadedLocalFile_eventImage =
      FFUploadedFile(bytes: Uint8List.fromList([]), originalFilename: '');

  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode1;
  TextEditingController? textController1;
  String? Function(BuildContext, String?)? textController1Validator;
  String? _textController1Validator(BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return 'Enter Name is required';
    }

    return null;
  }

  // State field(s) for RadioButton widget.
  FormFieldController<String>? radioButtonValueController;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode2;
  TextEditingController? textController2;
  String? Function(BuildContext, String?)? textController2Validator;
  String? _textController2Validator(BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return 'Link is not valid';
    }

    if (!RegExp(kTextValidatorWebsiteRegex).hasMatch(val)) {
      return 'Link is not valid';
    }
    return null;
  }

  // Stores action output result for [Custom Action - validateMeetLink] action in TextField widget.
  bool? link2;
  // State field(s) for LocationTextField widget.
  FocusNode? locationTextFieldFocusNode;
  TextEditingController? locationTextFieldTextController;
  String? Function(BuildContext, String?)?
      locationTextFieldTextControllerValidator;
  // Stores action output result for [Backend Call - API (ShowSuggestions)] action in LocationTextField widget.
  ApiCallResponse? places;
  // Stores action output result for [Backend Call - API (GetPlaceDetails)] action in Container widget.
  ApiCallResponse? apiResult5e7;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode3;
  TextEditingController? textController4;
  String? Function(BuildContext, String?)? textController4Validator;
  String? _textController4Validator(BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return 'Description is required';
    }

    return null;
  }

  // State field(s) for Checkbox widget.
  bool? checkboxValue;
  // Stores action output result for [Validate Form] action in Button widget.
  bool? name;
  // Stores action output result for [Custom Action - validateMeetLink] action in Button widget.
  bool? link;
  // Stores action output result for [Backend Call - Insert Row] action in Button widget.
  EventPageRow? event1;
  bool isDataUploading_eventimage1 = false;
  FFUploadedFile uploadedLocalFile_eventimage1 =
      FFUploadedFile(bytes: Uint8List.fromList([]), originalFilename: '');
  String uploadedFileUrl_eventimage1 = '';

  @override
  void initState(BuildContext context) {
    textController1Validator = _textController1Validator;
    textController2Validator = _textController2Validator;
    textController4Validator = _textController4Validator;
  }

  @override
  void dispose() {
    textFieldFocusNode1?.dispose();
    textController1?.dispose();

    textFieldFocusNode2?.dispose();
    textController2?.dispose();

    locationTextFieldFocusNode?.dispose();
    locationTextFieldTextController?.dispose();

    textFieldFocusNode3?.dispose();
    textController4?.dispose();
  }

  /// Additional helper methods.
  String? get radioButtonValue => radioButtonValueController?.value;
}
