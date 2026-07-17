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
import '/pages/home/comp_report_post/comp_report_post_widget.dart';
import '/pages/home/comp_three_dot_block_user/comp_three_dot_block_user_widget.dart';
import '/pages/profile/comp_follow_nearby/comp_follow_nearby_widget.dart';
import 'dart:ui';
import '/custom_code/actions/index.dart' as actions;
import '/custom_code/widgets/index.dart' as custom_widgets;
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';
import 'dart:math' as math;
import 'other_profile_widget.dart' show OtherProfileWidget;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class OtherProfileModel extends FlutterFlowModel<OtherProfileWidget> {
  ///  Local state fields for this page.

  bool profileReadmore = false;

  bool postReadmore = false;

  bool viewAllGroups = false;

  dynamic othersGroup;

  dynamic neighbourHoods;

  bool showData = false;

  String reportPostId = ' ';

  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Backend Call - API (GetOtherUserFollowingGroupsr)] action in otherProfile widget.
  ApiCallResponse? othersGroupData;
  // Stores action output result for [Backend Call - API (GetNeighborhoodPeoples)] action in otherProfile widget.
  ApiCallResponse? neighbourData12;
  // Stores action output result for [Backend Call - Query Rows] action in otherProfile widget.
  List<PostRow>? postCount;
  // Stores action output result for [Backend Call - API (FindCommonChat)] action in Image widget.
  ApiCallResponse? chatFound;
  // Stores action output result for [Backend Call - Insert Row] action in Image widget.
  ChatRow? chat;
  // Stores action output result for [Backend Call - API (UpdateTotalGroupMembers)] action in Join widget.
  ApiCallResponse? apiResultd2p22;
  // Stores action output result for [Backend Call - API (GetOtherUserFollowingGroupsr)] action in Join widget.
  ApiCallResponse? othersGroupData4;
  // Stores action output result for [Backend Call - API (GetOtherUserFollowingGroupsr)] action in Request widget.
  ApiCallResponse? othersGroupData5;
  // Stores action output result for [Backend Call - API (UpdateTotalGroupMembers)] action in Invited widget.
  ApiCallResponse? apiResultd2ppjj;
  // Stores action output result for [Backend Call - API (GetOtherUserFollowingGroupsr)] action in InviteAndRequest widget.
  ApiCallResponse? othersGroupData6;
  // Stores action output result for [Backend Call - API (UpdateTotalGroupMembers)] action in Join widget.
  ApiCallResponse? apiResultd2p22009;
  // Stores action output result for [Backend Call - API (GetOtherUserFollowingGroupsr)] action in Join widget.
  ApiCallResponse? othersGroupData2;
  // Stores action output result for [Backend Call - API (GetOtherUserFollowingGroupsr)] action in Request widget.
  ApiCallResponse? othersGroupData3;
  // Stores action output result for [Backend Call - API (UpdateTotalGroupMembers)] action in Invited widget.
  ApiCallResponse? apiResultd2ppjj0;
  // Stores action output result for [Backend Call - API (GetOtherUserFollowingGroupsr)] action in InviteAndRequest widget.
  ApiCallResponse? othersGroupData1;
  // Stores action output result for [Backend Call - API (AddLike)] action in Container widget.
  ApiCallResponse? addlike2;
  // Stores action output result for [Backend Call - API (GetNeighborhoodPeoples)] action in Container widget.
  ApiCallResponse? neighbourData13;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
