import '/auth/supabase_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/backend/supabase/supabase.dart';
import '/components/comp_pageview_widget.dart';
import '/components/comp_share_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/upload_data.dart';
import '/pages/home/comp_likes/comp_likes_widget.dart';
import '/pages/home/comp_loading/comp_loading_widget.dart';
import '/pages/home/comp_three_dot_edit_post/comp_three_dot_edit_post_widget.dart';
import '/pages/profile/comp_follow_nearby/comp_follow_nearby_widget.dart';
import '/pages/profile/comp_followers/comp_followers_widget.dart';
import '/pages/profile/comp_following/comp_following_widget.dart';
import 'dart:ui';
import '/custom_code/actions/index.dart' as actions;
import '/custom_code/widgets/index.dart' as custom_widgets;
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';
import 'dart:async';
import 'dart:math' as math;
import 'user_profile_widget.dart' show UserProfileWidget;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class UserProfileModel extends FlutterFlowModel<UserProfileWidget> {
  ///  Local state fields for this page.

  bool profileReadmore = false;

  bool postReadmore = false;

  bool viewAllGroups = false;

  bool showData = false;

  dynamic neighbourhoodData;

  String reportPostId = ' ';

  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Backend Call - API (GetNeighborhoodPeoples)] action in UserProfile widget.
  ApiCallResponse? neighbourData;
  // Stores action output result for [Backend Call - API (GetNeighborhoodPeoples)] action in UserProfile widget.
  ApiCallResponse? neighbourDataRealtime;
  // Stores action output result for [Backend Call - Query Rows] action in UserProfile widget.
  List<PostRow>? postCount;
  bool isDataUploading_uploadDataOpm = false;
  FFUploadedFile uploadedLocalFile_uploadDataOpm =
      FFUploadedFile(bytes: Uint8List.fromList([]), originalFilename: '');
  String uploadedFileUrl_uploadDataOpm = '';

  Completer<List<PublicUserProfileRow>>? requestCompleter;
  bool isDataUploading_uploadDataOpm1 = false;
  FFUploadedFile uploadedLocalFile_uploadDataOpm1 =
      FFUploadedFile(bytes: Uint8List.fromList([]), originalFilename: '');
  String uploadedFileUrl_uploadDataOpm1 = '';

  // Stores action output result for [Backend Call - API (UpdateTotalGroupMembers)] action in Join widget.
  ApiCallResponse? apiResultd2p;
  // Stores action output result for [Backend Call - API (UpdateTotalGroupMembers)] action in Invited widget.
  ApiCallResponse? apiResultd2pp;
  // Stores action output result for [Backend Call - API (UpdateTotalGroupMembers)] action in Join widget.
  ApiCallResponse? apiResultd2p22;
  // Stores action output result for [Backend Call - API (UpdateTotalGroupMembers)] action in Invited widget.
  ApiCallResponse? apiResultd2ppjj;
  // Stores action output result for [Backend Call - API (AddLike)] action in Container widget.
  ApiCallResponse? addlike2;
  // Stores action output result for [Backend Call - API (GetNeighborhoodPeoples)] action in Container widget.
  ApiCallResponse? neighbourData1;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}

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
