import '/auth/supabase_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/backend/supabase/supabase.dart';
import '/components/comp_pageview_widget.dart';
import '/components/comp_share_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/pages/group/comp_assign_admin/comp_assign_admin_widget.dart';
import '/pages/group/comp_group_1/comp_group1_widget.dart';
import '/pages/group/comp_group_2/comp_group2_widget.dart';
import '/pages/group/comp_group_members/comp_group_members_widget.dart';
import '/pages/group/comp_invite_friends/comp_invite_friends_widget.dart';
import '/pages/group/comp_joining_request/comp_joining_request_widget.dart';
import '/pages/group/comp_private_group_members/comp_private_group_members_widget.dart';
import '/pages/group/comp_revoke_admin/comp_revoke_admin_widget.dart';
import '/pages/home/comp_likes/comp_likes_widget.dart';
import '/pages/home/comp_loading/comp_loading_widget.dart';
import '/pages/home/comp_report_post/comp_report_post_widget.dart';
import '/pages/home/comp_three_dot_edit_post/comp_three_dot_edit_post_widget.dart';
import 'dart:ui';
import '/custom_code/actions/index.dart' as actions;
import '/custom_code/widgets/index.dart' as custom_widgets;
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';
import 'dart:math' as math;
import 'group_details_widget.dart' show GroupDetailsWidget;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class GroupDetailsModel extends FlutterFlowModel<GroupDetailsWidget> {
  ///  Local state fields for this page.

  String? readMore;

  String? showMoreId;

  bool loader = true;

  String postReadId = '123';

  String reportPostId = ' ';

  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Backend Call - API (GetPost)] action in Column widget.
  ApiCallResponse? post112;
  // Stores action output result for [Backend Call - API (UpdateTotalGroupMembers)] action in Join_Group_Button widget.
  ApiCallResponse? apiResultd2pCopy;
  // Stores action output result for [Backend Call - API (AddLike)] action in Container widget.
  ApiCallResponse? addlike2;
  // Stores action output result for [Backend Call - API (GetPostAllComments)] action in Container widget.
  ApiCallResponse? apiResultpio;
  // Stores action output result for [Backend Call - API (FindCommonChat)] action in message_To_Admin_Button widget.
  ApiCallResponse? chatFound;
  // Stores action output result for [Backend Call - Insert Row] action in message_To_Admin_Button widget.
  ChatRow? chat;
  // Stores action output result for [Backend Call - API (delete admin)] action in Resign_Role_Button widget.
  ApiCallResponse? apiResultyty;
  // Stores action output result for [Backend Call - API (UpdateTotalGroupMembers)] action in Join widget.
  ApiCallResponse? apiResultd2p;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
