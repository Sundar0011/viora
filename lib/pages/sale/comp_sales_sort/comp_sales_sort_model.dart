import '/auth/supabase_auth/auth_util.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/custom_code/actions/index.dart' as actions;
import 'comp_sales_sort_widget.dart' show CompSalesSortWidget;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class CompSalesSortModel extends FlutterFlowModel<CompSalesSortWidget> {
  ///  Local state fields for this component.

  String filterchoosed = 'All categories';

  ///  State fields for stateful widgets in this component.

  // Stores action output result for [Custom Action - getSaleHomePage] action in Appliances_Container widget.
  List<dynamic>? customActionOutput1;
  // Stores action output result for [Custom Action - getSaleHomePage] action in BabyKids_Container widget.
  List<dynamic>? customActionOutput3;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
