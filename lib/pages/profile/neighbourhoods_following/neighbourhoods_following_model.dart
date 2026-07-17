import '/auth/supabase_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/components/comp_no_data_found_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/custom_code/widgets/index.dart' as custom_widgets;
import 'neighbourhoods_following_widget.dart'
    show NeighbourhoodsFollowingWidget;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class NeighbourhoodsFollowingModel
    extends FlutterFlowModel<NeighbourhoodsFollowingWidget> {
  ///  Local state fields for this page.

  bool showData = false;

  dynamic neighbourhoodUsersData;

  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Backend Call - API (GetNeighborhoodPeoples)] action in NeighbourhoodsFollowing widget.
  ApiCallResponse? userdata;
  // Stores action output result for [Backend Call - API (AddFollow)] action in Container widget.
  ApiCallResponse? apiResult8wl;
  // Stores action output result for [Backend Call - API (GetNeighborhoodPeoples)] action in Container widget.
  ApiCallResponse? usersDataunfollow;
  // Stores action output result for [Backend Call - API (AddFollow)] action in Container widget.
  ApiCallResponse? apiResult8wlCopy;
  // Stores action output result for [Backend Call - API (GetNeighborhoodPeoples)] action in Container widget.
  ApiCallResponse? follow;
  // Model for Comp_No_Data_Found component.
  late CompNoDataFoundModel compNoDataFoundModel;

  @override
  void initState(BuildContext context) {
    compNoDataFoundModel = createModel(context, () => CompNoDataFoundModel());
  }

  @override
  void dispose() {
    compNoDataFoundModel.dispose();
  }
}
