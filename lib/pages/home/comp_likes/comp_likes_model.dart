import '/auth/supabase_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/pages/home/comp_loading/comp_loading_widget.dart';
import '/pages/profile/shimmer_loader_followers/shimmer_loader_followers_widget.dart';
import 'dart:ui';
import 'comp_likes_widget.dart' show CompLikesWidget;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class CompLikesModel extends FlutterFlowModel<CompLikesWidget> {
  ///  Local state fields for this component.

  bool showData = false;

  ///  State fields for stateful widgets in this component.

  // Stores action output result for [Backend Call - API (GetLikedUsers)] action in Comp_Likes widget.
  ApiCallResponse? apiResultmbg;
  // Model for ShimmerLoaderFollowers component.
  late ShimmerLoaderFollowersModel shimmerLoaderFollowersModel;

  @override
  void initState(BuildContext context) {
    shimmerLoaderFollowersModel =
        createModel(context, () => ShimmerLoaderFollowersModel());
  }

  @override
  void dispose() {
    shimmerLoaderFollowersModel.dispose();
  }
}
