import '/auth/supabase_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/backend/supabase/supabase.dart';
import '/components/comp_no_data_found_widget.dart';
import '/components/comp_share_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/pages/business/comp_business_contact/comp_business_contact_widget.dart';
import '/pages/group/comp_share_group/comp_share_group_widget.dart';
import '/pages/home/comp_likes/comp_likes_widget.dart';
import '/pages/home/comp_loading/comp_loading_widget.dart';
import '/pages/home/comp_three_dot_block_user/comp_three_dot_block_user_widget.dart';
import '/pages/home/comp_three_dot_edit_post/comp_three_dot_edit_post_widget.dart';
import '/pages/loder_components/shimmer_loader/shimmer_loader_widget.dart';
import '/pages/sale/comp_category_filter/comp_category_filter_widget.dart';
import '/pages/sale/comp_kms_filter/comp_kms_filter_widget.dart';
import '/pages/sale/comp_sales_sort/comp_sales_sort_widget.dart';
import 'dart:ui';
import '/custom_code/actions/index.dart' as actions;
import '/custom_code/widgets/index.dart' as custom_widgets;
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';
import 'dart:async';
import 'dart:math' as math;
import 'search_widget.dart' show SearchWidget;
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class SearchModel extends FlutterFlowModel<SearchWidget> {
  ///  Local state fields for this page.

  String optionChoosed = 'all';

  bool searchEmpty = false;

  String? postReadId;

  bool showData = false;

  bool isSearchHistory = false;

  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Backend Call - Query Rows] action in Search widget.
  List<SearchHistoryRow>? isSearchHistoryPresent;
  Completer<ApiCallResponse>? apiRequestCompleter1;
  Completer<ApiCallResponse>? apiRequestCompleter3;
  Completer<ApiCallResponse>? apiRequestCompleter2;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode;
  TextEditingController? textController;
  String? Function(BuildContext, String?)? textControllerValidator;
  // Stores action output result for [Backend Call - API (GetAllSearch)] action in TextField widget.
  ApiCallResponse? apiResulth6n;
  // Stores action output result for [Backend Call - API (UpdateSearchHistory)] action in TextField widget.
  ApiCallResponse? apiResultskh;
  // Stores action output result for [Backend Call - API (GetAllSearch)] action in Container widget.
  ApiCallResponse? allData;
  // Stores action output result for [Backend Call - API (GetAllSearch)] action in Container widget.
  ApiCallResponse? posts;
  // Stores action output result for [Backend Call - API (GetAllSearch)] action in Container widget.
  ApiCallResponse? neighbourhood;
  // Stores action output result for [Backend Call - API (GetAllSearch)] action in Container widget.
  ApiCallResponse? businessHome;
  // Stores action output result for [Backend Call - API (GetAllSearch)] action in Container widget.
  ApiCallResponse? group;
  // Stores action output result for [Backend Call - API (GetAllSearch)] action in Container widget.
  ApiCallResponse? event;
  // Stores action output result for [Backend Call - API (GetAllSearch)] action in Container widget.
  ApiCallResponse? sale;
  // Stores action output result for [Backend Call - API (GetAllSearch)] action in Container widget.
  ApiCallResponse? priceFilter;
  // Stores action output result for [Backend Call - API (GetAllSearch)] action in Icon widget.
  ApiCallResponse? goToGroup;
  // Stores action output result for [Backend Call - API (UpdateTotalGroupMembers)] action in Join widget.
  ApiCallResponse? apiResultd2p5;
  // Stores action output result for [Backend Call - API (GetAllSearch)] action in Join widget.
  ApiCallResponse? apiResulth6ntt;
  // Stores action output result for [Backend Call - API (GetAllSearch)] action in Request widget.
  ApiCallResponse? apiResulth6nttdsfdfcxf;
  // Stores action output result for [Backend Call - API (UpdateTotalGroupMembers)] action in Invited widget.
  ApiCallResponse? apiResultd2pp23zxz;
  // Stores action output result for [Backend Call - API (GetAllSearch)] action in Invited widget.
  ApiCallResponse? apiResulth6nttcvvcvv;
  // Stores action output result for [Backend Call - API (GetAllSearch)] action in InviteAndRequest widget.
  ApiCallResponse? apiResulth6nttff;
  // Stores action output result for [Backend Call - API (GetAllSearch)] action in Icon widget.
  ApiCallResponse? goToEvent;
  // Stores action output result for [Backend Call - API (UpdateEventAttendeeCount)] action in Attend widget.
  ApiCallResponse? apiResultrykre;
  // Stores action output result for [Backend Call - API (UpdateEventAttendeeCount)] action in invited widget.
  ApiCallResponse? apiResultrykuuoo;
  // Stores action output result for [Backend Call - API (UpdateEventAttendeeCount)] action in Attending widget.
  ApiCallResponse? kkkj;
  // Stores action output result for [Backend Call - API (GetAllSearch)] action in Icon widget.
  ApiCallResponse? goToNeighbourhood;
  // Stores action output result for [Backend Call - API (GetAllSearch)] action in Icon widget.
  ApiCallResponse? goToSale;
  // Stores action output result for [Backend Call - API (GetAllSearch)] action in Icon widget.
  ApiCallResponse? goToPost;
  // Stores action output result for [Backend Call - API (AddLike)] action in Container widget.
  ApiCallResponse? addlike2;
  // Stores action output result for [Backend Call - API (GetPostAllComments)] action in Container widget.
  ApiCallResponse? apiResultpio;
  // Stores action output result for [Backend Call - API (GetAllSearch)] action in Icon widget.
  ApiCallResponse? gotToBusiness;
  // Model for Comp_No_Data_Found component.
  late CompNoDataFoundModel compNoDataFoundModel1;
  // Model for Comp_No_Data_Found component.
  late CompNoDataFoundModel compNoDataFoundModel2;
  // Stores action output result for [Backend Call - API (AddLike)] action in Container widget.
  ApiCallResponse? addlike222;
  // Stores action output result for [Backend Call - API (GetPostAllComments)] action in Container widget.
  ApiCallResponse? apiResultpio22;
  // Model for Comp_No_Data_Found component.
  late CompNoDataFoundModel compNoDataFoundModel3;
  // Model for Comp_No_Data_Found component.
  late CompNoDataFoundModel compNoDataFoundModel4;
  // Model for Comp_No_Data_Found component.
  late CompNoDataFoundModel compNoDataFoundModel5;
  // Stores action output result for [Backend Call - API (UpdateEventAttendeeCount)] action in Attend widget.
  ApiCallResponse? apiResultrykremmm;
  // Stores action output result for [Backend Call - API (UpdateEventAttendeeCount)] action in invited widget.
  ApiCallResponse? apiResultrykuu;
  // Stores action output result for [Backend Call - API (UpdateEventAttendeeCount)] action in Attending widget.
  ApiCallResponse? kk;
  // Model for Comp_No_Data_Found component.
  late CompNoDataFoundModel compNoDataFoundModel6;
  // Stores action output result for [Backend Call - API (UpdateTotalGroupMembers)] action in Join widget.
  ApiCallResponse? apiResultd2p5bvv;
  // Stores action output result for [Backend Call - API (GetAllSearch)] action in Join widget.
  ApiCallResponse? apiResulth6nttzx;
  // Stores action output result for [Backend Call - API (GetAllSearch)] action in Request widget.
  ApiCallResponse? apiResulth6nttzxc;
  // Stores action output result for [Backend Call - API (UpdateTotalGroupMembers)] action in Invited widget.
  ApiCallResponse? apiResultd2pp23fxx;
  // Stores action output result for [Backend Call - API (GetAllSearch)] action in Invited widget.
  ApiCallResponse? apiResulth6nttcvcss;
  // Stores action output result for [Backend Call - API (GetAllSearch)] action in InviteAndRequest widget.
  ApiCallResponse? apiResulth6nttcvc;
  Completer<List<SearchHistoryRow>>? requestCompleter;
  // Stores action output result for [Backend Call - API (GetAllSearch)] action in Container widget.
  ApiCallResponse? searchHistoryData;

  @override
  void initState(BuildContext context) {
    compNoDataFoundModel1 = createModel(context, () => CompNoDataFoundModel());
    compNoDataFoundModel2 = createModel(context, () => CompNoDataFoundModel());
    compNoDataFoundModel3 = createModel(context, () => CompNoDataFoundModel());
    compNoDataFoundModel4 = createModel(context, () => CompNoDataFoundModel());
    compNoDataFoundModel5 = createModel(context, () => CompNoDataFoundModel());
    compNoDataFoundModel6 = createModel(context, () => CompNoDataFoundModel());
  }

  @override
  void dispose() {
    textFieldFocusNode?.dispose();
    textController?.dispose();

    compNoDataFoundModel1.dispose();
    compNoDataFoundModel2.dispose();
    compNoDataFoundModel3.dispose();
    compNoDataFoundModel4.dispose();
    compNoDataFoundModel5.dispose();
    compNoDataFoundModel6.dispose();
  }

  /// Additional helper methods.
  Future waitForApiRequestCompleted1({
    double minWait = 0,
    double maxWait = double.infinity,
  }) async {
    final stopwatch = Stopwatch()..start();
    while (true) {
      await Future.delayed(Duration(milliseconds: 50));
      final timeElapsed = stopwatch.elapsedMilliseconds;
      final requestComplete = apiRequestCompleter1?.isCompleted ?? false;
      if (timeElapsed > maxWait || (requestComplete && timeElapsed > minWait)) {
        break;
      }
    }
  }

  Future waitForApiRequestCompleted3({
    double minWait = 0,
    double maxWait = double.infinity,
  }) async {
    final stopwatch = Stopwatch()..start();
    while (true) {
      await Future.delayed(Duration(milliseconds: 50));
      final timeElapsed = stopwatch.elapsedMilliseconds;
      final requestComplete = apiRequestCompleter3?.isCompleted ?? false;
      if (timeElapsed > maxWait || (requestComplete && timeElapsed > minWait)) {
        break;
      }
    }
  }

  Future waitForApiRequestCompleted2({
    double minWait = 0,
    double maxWait = double.infinity,
  }) async {
    final stopwatch = Stopwatch()..start();
    while (true) {
      await Future.delayed(Duration(milliseconds: 50));
      final timeElapsed = stopwatch.elapsedMilliseconds;
      final requestComplete = apiRequestCompleter2?.isCompleted ?? false;
      if (timeElapsed > maxWait || (requestComplete && timeElapsed > minWait)) {
        break;
      }
    }
  }

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
