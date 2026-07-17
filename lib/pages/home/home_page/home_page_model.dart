import '/auth/supabase_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/backend/supabase/supabase.dart';
import '/components/comp_pageview_widget.dart';
import '/components/comp_share_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/pages/components/comp_navbar/comp_navbar_widget.dart';
import '/pages/home/comp_likes/comp_likes_widget.dart';
import '/pages/home/comp_loading/comp_loading_widget.dart';
import '/pages/home/comp_report_post/comp_report_post_widget.dart';
import '/pages/home/comp_three_dot_edit_post/comp_three_dot_edit_post_widget.dart';
import '/pages/loder_components/shimmer_loader/shimmer_loader_widget.dart';
import 'dart:ui';
import '/custom_code/widgets/index.dart' as custom_widgets;
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';
import 'dart:math' as math;
import 'home_page_widget.dart' show HomePageWidget;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class HomePageModel extends FlutterFlowModel<HomePageWidget> {
  ///  Local state fields for this page.

  String? readMore = '';

  String? postIdRead;

  bool showPost = false;

  String postId = ' ';

  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Backend Call - API (GetPost)] action in Column widget.
  ApiCallResponse? post1;
  // Stores action output result for [Backend Call - API (AddLike)] action in Container widget.
  ApiCallResponse? addlike2;
  // Model for ShimmerLoader component.
  late ShimmerLoaderModel shimmerLoaderModel;
  // Model for Comp_Navbar component.
  late CompNavbarModel compNavbarModel;

  @override
  void initState(BuildContext context) {
    shimmerLoaderModel = createModel(context, () => ShimmerLoaderModel());
    compNavbarModel = createModel(context, () => CompNavbarModel());
  }

  @override
  void dispose() {
    shimmerLoaderModel.dispose();
    compNavbarModel.dispose();
  }
}
