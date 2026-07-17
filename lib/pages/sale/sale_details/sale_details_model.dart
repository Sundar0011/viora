import '/auth/supabase_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/pages/home/comp_loading/comp_loading_widget.dart';
import '/pages/sale/comp_sold_delete/comp_sold_delete_widget.dart';
import '/pages/sale/comp_three_dot_report_sale/comp_three_dot_report_sale_widget.dart';
import 'dart:ui';
import '/custom_code/widgets/index.dart' as custom_widgets;
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';
import 'dart:async';
import 'dart:math' as math;
import 'package:smooth_page_indicator/smooth_page_indicator.dart'
    as smooth_page_indicator;
import 'sale_details_widget.dart' show SaleDetailsWidget;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class SaleDetailsModel extends FlutterFlowModel<SaleDetailsWidget> {
  ///  Local state fields for this page.

  dynamic saleData;

  bool readMore = false;

  bool showData = false;

  double? adminLat;

  double? adminLng;

  dynamic sales;

  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Backend Call - API (GetSalesDetails)] action in SaleDetails widget.
  ApiCallResponse? apiResultgxl;
  // Stores action output result for [Backend Call - API (GetSaleHomePageSales)] action in SaleDetails widget.
  ApiCallResponse? saleDetails;
  // State field(s) for PageView widget.
  PageController? pageViewController;

  int get pageViewCurrentIndex => pageViewController != null &&
          pageViewController!.hasClients &&
          pageViewController!.page != null
      ? pageViewController!.page!.round()
      : 0;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode;
  TextEditingController? textController;
  String? Function(BuildContext, String?)? textControllerValidator;
  // Stores action output result for [Backend Call - API (FindCommonChat)] action in Button widget.
  ApiCallResponse? chatFoundSale;
  // Stores action output result for [Backend Call - API (RestoreChatUser)] action in Button widget.
  ApiCallResponse? jgjg;
  // Stores action output result for [Backend Call - Insert Row] action in Button widget.
  ChatRow? chatsale;
  Completer<List<FollowsRow>>? requestCompleter;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    textFieldFocusNode?.dispose();
    textController?.dispose();
  }

  /// Additional helper methods.
  Future waitForRequestCompleted({
    double minWait = 0,
    double maxWait = double.infinity,
  }) async {
    final stopwatch = Stopwatch()..start();
    while (true) {
      await Future.delayed(Duration(milliseconds: 50));
      final timeElapsed = stopwatch.elapsedMilliseconds;
      final requestComplete = requestCompleter?.isCompleted ?? false;
      if (timeElapsed > maxWait || (requestComplete && timeElapsed > minWait)) {
        break;
      }
    }
  }
}
