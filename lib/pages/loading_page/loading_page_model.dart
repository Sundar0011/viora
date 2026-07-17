import '/auth/supabase_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:async';
import 'dart:ui';
import '/custom_code/actions/index.dart' as actions;
import '/index.dart';
import 'loading_page_widget.dart' show LoadingPageWidget;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class LoadingPageModel extends FlutterFlowModel<LoadingPageWidget> {
  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Custom Action - checkInternetConnect] action in loadingPage widget.
  bool? isOnline11;
  // Stores action output result for [Backend Call - Query Rows] action in loadingPage widget.
  List<PublicUserProfileRow>? publicProfile;
  // Stores action output result for [Backend Call - Query Rows] action in loadingPage widget.
  List<UserRow>? userDetails;
  // Stores action output result for [Backend Call - Query Rows] action in loadingPage widget.
  List<UserLocationsRow>? location;
  // Stores action output result for [Backend Call - API (GetGroupsWithUserStatus)] action in loadingPage widget.
  ApiCallResponse? group;
  // Stores action output result for [Backend Call - API (GetPost)] action in loadingPage widget.
  ApiCallResponse? post1;
  // Stores action output result for [Backend Call - API (GetChat)] action in loadingPage widget.
  ApiCallResponse? userChat;
  // Stores action output result for [Custom Action - checkNotificationAndStoreFCMToken] action in loadingPage widget.
  String? checknotificationStatus;
  // Stores action output result for [Backend Call - API (GetPostAllComments)] action in loadingPage widget.
  ApiCallResponse? apiResultpio;
  // Stores action output result for [Backend Call - API (CheckGroupMemberShare)] action in loadingPage widget.
  ApiCallResponse? showPost;
  // Stores action output result for [Backend Call - Query Rows] action in loadingPage widget.
  List<ChatUsersRow>? chat;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
