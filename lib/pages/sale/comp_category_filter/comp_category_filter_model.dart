import '/auth/supabase_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/custom_code/actions/index.dart' as actions;
import 'comp_category_filter_widget.dart' show CompCategoryFilterWidget;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class CompCategoryFilterModel
    extends FlutterFlowModel<CompCategoryFilterWidget> {
  ///  State fields for stateful widgets in this component.

  // Stores action output result for [Custom Action - getSaleHomePage] action in Allcategories_Container widget.
  List<dynamic>? customActionOutput;
  // Stores action output result for [Backend Call - API (GetAllSearch)] action in Allcategories_Container widget.
  ApiCallResponse? allCategoriesFilter;
  // Stores action output result for [Custom Action - getSaleHomePage] action in Appliances_Container widget.
  List<dynamic>? customActionOutput1;
  // Stores action output result for [Backend Call - API (GetAllSearch)] action in Appliances_Container widget.
  ApiCallResponse? categoriesFilter;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
