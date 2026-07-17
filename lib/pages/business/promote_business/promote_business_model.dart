import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/index.dart';
import 'promote_business_widget.dart' show PromoteBusinessWidget;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class PromoteBusinessModel extends FlutterFlowModel<PromoteBusinessWidget> {
  ///  Local state fields for this page.

  int radiobtn = 0;

  String? plan;

  int? planid;

  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Backend Call - Query Rows] action in PromoteBusiness widget.
  List<BusinessPromotePlansRow>? plans;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
