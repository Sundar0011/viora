import '/auth/supabase_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/components/comp_no_data_found_widget.dart';
import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/pages/components/comp_navbar/comp_navbar_widget.dart';
import '/pages/sale/comp_category_filter/comp_category_filter_widget.dart';
import '/pages/sale/comp_create_listing/comp_create_listing_widget.dart';
import '/pages/sale/comp_kms_filter/comp_kms_filter_widget.dart';
import '/pages/sale/comp_sales_sort/comp_sales_sort_widget.dart';
import 'dart:math';
import 'dart:ui';
import '/custom_code/actions/index.dart' as actions;
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';
import 'sale_widget.dart' show SaleWidget;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class SaleModel extends FlutterFlowModel<SaleWidget> {
  ///  Local state fields for this page.

  String? switchOption = 'all';

  String? switchTouch;

  String opt = 'all';

  List<dynamic> salesListing = [];
  void addToSalesListing(dynamic item) => salesListing.add(item);
  void removeFromSalesListing(dynamic item) => salesListing.remove(item);
  void removeAtIndexFromSalesListing(int index) => salesListing.removeAt(index);
  void insertAtIndexInSalesListing(int index, dynamic item) =>
      salesListing.insert(index, item);
  void updateSalesListingAtIndex(int index, Function(dynamic) updateFn) =>
      salesListing[index] = updateFn(salesListing[index]);

  bool show = false;

  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Custom Action - getSaleHomePage] action in Sale widget.
  List<dynamic>? customActionOutput;
  // Stores action output result for [Backend Call - API (GetSalesData)] action in Sale widget.
  ApiCallResponse? salesDataOnload;
  // Stores action output result for [Custom Action - getSaleHomePage] action in Container widget.
  List<dynamic>? customActionOutput1;
  // Stores action output result for [Custom Action - getSaleHomePage] action in Container widget.
  List<dynamic>? customActionOutput2;
  // Model for Comp_No_Data_Found component.
  late CompNoDataFoundModel compNoDataFoundModel1;
  // Model for Comp_No_Data_Found component.
  late CompNoDataFoundModel compNoDataFoundModel2;
  // Stores action output result for [Backend Call - API (GetSalesData)] action in Container widget.
  ApiCallResponse? salesDataAll;
  // Stores action output result for [Backend Call - API (GetSalesData)] action in Container widget.
  ApiCallResponse? salesDataSelling;
  // Stores action output result for [Backend Call - API (GetSalesData)] action in Container widget.
  ApiCallResponse? salesDataSold;
  // Model for Comp_No_Data_Found component.
  late CompNoDataFoundModel compNoDataFoundModel3;
  // Model for Comp_No_Data_Found component.
  late CompNoDataFoundModel compNoDataFoundModel4;
  // Model for Comp_No_Data_Found component.
  late CompNoDataFoundModel compNoDataFoundModel5;
  // Model for Comp_Navbar component.
  late CompNavbarModel compNavbarModel;

  @override
  void initState(BuildContext context) {
    compNoDataFoundModel1 = createModel(context, () => CompNoDataFoundModel());
    compNoDataFoundModel2 = createModel(context, () => CompNoDataFoundModel());
    compNoDataFoundModel3 = createModel(context, () => CompNoDataFoundModel());
    compNoDataFoundModel4 = createModel(context, () => CompNoDataFoundModel());
    compNoDataFoundModel5 = createModel(context, () => CompNoDataFoundModel());
    compNavbarModel = createModel(context, () => CompNavbarModel());
  }

  @override
  void dispose() {
    compNoDataFoundModel1.dispose();
    compNoDataFoundModel2.dispose();
    compNoDataFoundModel3.dispose();
    compNoDataFoundModel4.dispose();
    compNoDataFoundModel5.dispose();
    compNavbarModel.dispose();
  }
}
