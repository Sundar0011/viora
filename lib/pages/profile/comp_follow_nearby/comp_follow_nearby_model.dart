import '/auth/supabase_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/pages/profile/shimmer_loader_followers/shimmer_loader_followers_widget.dart';
import 'dart:ui';
import 'comp_follow_nearby_widget.dart' show CompFollowNearbyWidget;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class CompFollowNearbyModel extends FlutterFlowModel<CompFollowNearbyWidget> {
  ///  Local state fields for this component.

  dynamic neighbourhoodUsersData;

  bool showData = false;

  ///  State fields for stateful widgets in this component.

  // Stores action output result for [Backend Call - API (GetNeighborhoodPeoples)] action in Comp_FollowNearby widget.
  ApiCallResponse? neighbourhoodData;
  // Stores action output result for [Backend Call - API (GetNeighborhoodPeoples)] action in Container widget.
  ApiCallResponse? neighbourhoodData1;
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
