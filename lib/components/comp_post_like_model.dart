import '/auth/supabase_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/pages/home/comp_likes/comp_likes_widget.dart';
import 'dart:ui';
import 'comp_post_like_widget.dart' show CompPostLikeWidget;
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class CompPostLikeModel extends FlutterFlowModel<CompPostLikeWidget> {
  ///  State fields for stateful widgets in this component.

  // Stores action output result for [Backend Call - API (AddLike)] action in Icon widget.
  ApiCallResponse? addlike;
  Completer<List<PostLikeRow>>? requestCompleter;
  // Stores action output result for [Backend Call - API (AddLike)] action in Icon widget.
  ApiCallResponse? addlike2;

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
