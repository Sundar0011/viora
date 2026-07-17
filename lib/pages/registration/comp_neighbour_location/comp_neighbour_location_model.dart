import '/auth/supabase_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/index.dart';
import 'comp_neighbour_location_widget.dart' show CompNeighbourLocationWidget;
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class CompNeighbourLocationModel
    extends FlutterFlowModel<CompNeighbourLocationWidget> {
  ///  Local state fields for this component.

  bool showSuggestions = false;

  List<String> places = [];
  void addToPlaces(String item) => places.add(item);
  void removeFromPlaces(String item) => places.remove(item);
  void removeAtIndexFromPlaces(int index) => places.removeAt(index);
  void insertAtIndexInPlaces(int index, String item) =>
      places.insert(index, item);
  void updatePlacesAtIndex(int index, Function(String) updateFn) =>
      places[index] = updateFn(places[index]);

  List<String> placeId = [];
  void addToPlaceId(String item) => placeId.add(item);
  void removeFromPlaceId(String item) => placeId.remove(item);
  void removeAtIndexFromPlaceId(int index) => placeId.removeAt(index);
  void insertAtIndexInPlaceId(int index, String item) =>
      placeId.insert(index, item);
  void updatePlaceIdAtIndex(int index, Function(String) updateFn) =>
      placeId[index] = updateFn(placeId[index]);

  String? choosedPlace;

  String? choosedPlaceId;

  double? latitude;

  double? longitude;

  bool showAddressError = false;

  String? country;

  String? city;

  ///  State fields for stateful widgets in this component.

  final formKey1 = GlobalKey<FormState>();
  final formKey2 = GlobalKey<FormState>();
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode1;
  TextEditingController? textController1;
  String? Function(BuildContext, String?)? textController1Validator;
  // Stores action output result for [Backend Call - API (ShowSuggestions)] action in TextField widget.
  ApiCallResponse? suggestedPlaces;
  // Stores action output result for [Backend Call - API (GetPlaceDetails)] action in Container widget.
  ApiCallResponse? placeDetails;
  // State field(s) for Flat_TextField widget.
  FocusNode? flatTextFieldFocusNode;
  TextEditingController? flatTextFieldTextController;
  String? Function(BuildContext, String?)? flatTextFieldTextControllerValidator;
  // State field(s) for cityTextField widget.
  FocusNode? cityTextFieldFocusNode;
  TextEditingController? cityTextFieldTextController;
  String? Function(BuildContext, String?)? cityTextFieldTextControllerValidator;
  String? _cityTextFieldTextControllerValidator(
      BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return 'City name is required';
    }

    return null;
  }

  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode2;
  TextEditingController? textController4;
  String? Function(BuildContext, String?)? textController4Validator;
  String? _textController4Validator(BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return 'Postal code is required';
    }

    return null;
  }

  // Stores action output result for [Validate Form] action in Button widget.
  bool? city1;
  // Stores action output result for [Validate Form] action in Button widget.
  bool? postal1;
  // Stores action output result for [Backend Call - API (InsertUserLocation)] action in Button widget.
  ApiCallResponse? locationResult;
  // Stores action output result for [Validate Form] action in Button widget.
  bool? postal2;

  @override
  void initState(BuildContext context) {
    cityTextFieldTextControllerValidator =
        _cityTextFieldTextControllerValidator;
    textController4Validator = _textController4Validator;
  }

  @override
  void dispose() {
    textFieldFocusNode1?.dispose();
    textController1?.dispose();

    flatTextFieldFocusNode?.dispose();
    flatTextFieldTextController?.dispose();

    cityTextFieldFocusNode?.dispose();
    cityTextFieldTextController?.dispose();

    textFieldFocusNode2?.dispose();
    textController4?.dispose();
  }
}
