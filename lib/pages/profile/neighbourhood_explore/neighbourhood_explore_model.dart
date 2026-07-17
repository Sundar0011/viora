import '/auth/supabase_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/backend/supabase/supabase.dart';
import '/components/comp_pageview_widget.dart';
import '/components/comp_share_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/pages/home/comp_likes/comp_likes_widget.dart';
import '/pages/home/comp_loading/comp_loading_widget.dart';
import '/pages/home/comp_three_dot_block_user/comp_three_dot_block_user_widget.dart';
import '/pages/home/comp_three_dot_edit_post/comp_three_dot_edit_post_widget.dart';
import 'dart:ui';
import '/custom_code/actions/index.dart' as actions;
import '/custom_code/widgets/index.dart' as custom_widgets;
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';
import 'dart:math' as math;
import 'neighbourhood_explore_widget.dart' show NeighbourhoodExploreWidget;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class NeighbourhoodExploreModel
    extends FlutterFlowModel<NeighbourhoodExploreWidget> {
  ///  Local state fields for this page.

  bool showData = false;

  dynamic neighbourhoodPosts;

  String? postIdRead;

  String? neighbours;

  String? postcount;

  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Backend Call - API (GetneighbourhoodPosts)] action in NeighbourhoodExplore widget.
  ApiCallResponse? apiResultlnn;
  // Stores action output result for [Backend Call - API (AddLike)] action in Container widget.
  ApiCallResponse? addlike2;
  // Stores action output result for [Backend Call - API (GetPostAllComments)] action in Container widget.
  ApiCallResponse? apiResultpio;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
