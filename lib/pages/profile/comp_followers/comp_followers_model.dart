import '/auth/supabase_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/backend/supabase/supabase.dart';
import '/components/comp_no_data_found_widget.dart';
import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/pages/home/comp_loading/comp_loading_widget.dart';
import 'dart:math';
import 'dart:ui';
import '/custom_code/actions/index.dart' as actions;
import 'comp_followers_widget.dart' show CompFollowersWidget;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class CompFollowersModel extends FlutterFlowModel<CompFollowersWidget> {
  ///  Local state fields for this component.

  bool show = false;

  ///  State fields for stateful widgets in this component.

  // Model for Comp_No_Data_Found component.
  late CompNoDataFoundModel compNoDataFoundModel;

  @override
  void initState(BuildContext context) {
    compNoDataFoundModel = createModel(context, () => CompNoDataFoundModel());
  }

  @override
  void dispose() {
    compNoDataFoundModel.dispose();
  }
}
