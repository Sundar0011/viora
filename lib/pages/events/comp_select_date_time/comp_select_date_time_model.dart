import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/custom_code/widgets/index.dart' as custom_widgets;
import '/flutter_flow/custom_functions.dart' as functions;
import 'comp_select_date_time_widget.dart' show CompSelectDateTimeWidget;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class CompSelectDateTimeModel
    extends FlutterFlowModel<CompSelectDateTimeWidget> {
  ///  Local state fields for this component.

  List<String> stringTimeArray = [
    '06:00 AM',
    '07:00 AM',
    '08:00 AM',
    '09:00 AM',
    '10:00 AM',
    '11:00 AM',
    '12:00 AM',
    '01:00 PM',
    '02:00 PM',
    '03:00 PM',
    '04:00 PM',
    '05:00 PM',
    '06:00 PM'
  ];
  void addToStringTimeArray(String item) => stringTimeArray.add(item);
  void removeFromStringTimeArray(String item) => stringTimeArray.remove(item);
  void removeAtIndexFromStringTimeArray(int index) =>
      stringTimeArray.removeAt(index);
  void insertAtIndexInStringTimeArray(int index, String item) =>
      stringTimeArray.insert(index, item);
  void updateStringTimeArrayAtIndex(int index, Function(String) updateFn) =>
      stringTimeArray[index] = updateFn(stringTimeArray[index]);

  String selectTime = '08:00 AM';

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
