import '/auth/supabase_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/pages/business/comp_delete_business/comp_delete_business_widget.dart';
import '/pages/business/comp_mismatch/comp_mismatch_widget.dart';
import '/pages/business/comp_promotion_ended/comp_promotion_ended_widget.dart';
import '/pages/business/comp_promotion_is_live/comp_promotion_is_live_widget.dart';
import '/pages/business/comp_promotion_rejected/comp_promotion_rejected_widget.dart';
import '/pages/business/comp_under_review/comp_under_review_widget.dart';
import 'dart:ui';
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';
import 'comp_three_dot_edit_business_widget.dart'
    show CompThreeDotEditBusinessWidget;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class CompThreeDotEditBusinessModel
    extends FlutterFlowModel<CompThreeDotEditBusinessWidget> {
  ///  State fields for stateful widgets in this component.

  // Stores action output result for [Backend Call - API (GetPromotionplan)] action in Comp_ThreeDot_Edit_Business widget.
  ApiCallResponse? apiResulteyq;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
