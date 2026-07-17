import '/auth/supabase_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/components/comp_no_data_found_widget.dart';
import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:math';
import 'dart:ui';
import 'comp_review_invite_widget.dart' show CompReviewInviteWidget;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class CompReviewInviteModel extends FlutterFlowModel<CompReviewInviteWidget> {
  ///  Local state fields for this component.

  bool show = false;

  dynamic profileData;

  ///  State fields for stateful widgets in this component.

  // Stores action output result for [Backend Call - API (GetInvitedUsersForGroup)] action in Comp_Review_Invite widget.
  ApiCallResponse? apiResultw1f;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
