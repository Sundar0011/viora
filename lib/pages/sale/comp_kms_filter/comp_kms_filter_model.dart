import '/auth/supabase_auth/auth_util.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/custom_code/actions/index.dart' as actions;
import 'comp_kms_filter_widget.dart' show CompKmsFilterWidget;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class CompKmsFilterModel extends FlutterFlowModel<CompKmsFilterWidget> {
  ///  Local state fields for this component.

  String filterchoosed = 'All categories';

  List<int> kms = [1, 3, 5, 7, 10, 15, 20, 30, 40, 50];
  void addToKms(int item) => kms.add(item);
  void removeFromKms(int item) => kms.remove(item);
  void removeAtIndexFromKms(int index) => kms.removeAt(index);
  void insertAtIndexInKms(int index, int item) => kms.insert(index, item);
  void updateKmsAtIndex(int index, Function(int) updateFn) =>
      kms[index] = updateFn(kms[index]);

  ///  State fields for stateful widgets in this component.

  // Stores action output result for [Custom Action - getSaleHomePage] action in Kms-1 widget.
  List<dynamic>? customActionOutput1;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
