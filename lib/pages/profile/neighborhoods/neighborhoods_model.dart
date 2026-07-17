import '/auth/supabase_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/components/comp_location_permission_widget.dart';
import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:math';
import 'dart:ui';
import '/custom_code/actions/index.dart' as actions;
import '/custom_code/widgets/index.dart' as custom_widgets;
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';
import 'neighborhoods_widget.dart' show NeighborhoodsWidget;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class NeighborhoodsModel extends FlutterFlowModel<NeighborhoodsWidget> {
  ///  Local state fields for this page.

  bool? showData = false;

  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Backend Call - API (GetNeighborhoodPeoples)] action in Neighborhoods widget.
  ApiCallResponse? following;
  // Stores action output result for [Backend Call - API (GetNeighborhoodPeoples)] action in Neighborhoods widget.
  ApiCallResponse? apiResulthzj;
  // Stores action output result for [Backend Call - API (AddFollow)] action in Container widget.
  ApiCallResponse? apiResult8wl;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
