// Automatic FlutterFlow imports
import '/backend/schema/enums/enums.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom widgets
import '/custom_code/actions/index.dart'; // Imports custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

class ConditionalCheckbox extends StatefulWidget {
  const ConditionalCheckbox({
    Key? key,
    required this.userId,
    this.width = 20.0,
    this.height = 20.0,
  }) : super(key: key);

  final String userId;
  final double width;
  final double height;

  @override
  _ConditionalCheckboxState createState() => _ConditionalCheckboxState();
}

class _ConditionalCheckboxState extends State<ConditionalCheckbox> {
  @override
  Widget build(BuildContext context) {
    final isChecked = FFAppState().userIds.contains(widget.userId);

    return GestureDetector(
      onTap: () {
        setState(() {
          if (isChecked) {
            FFAppState().update(() {
              FFAppState().userIds.remove(widget.userId);
            });
          } else {
            FFAppState().update(() {
              FFAppState().userIds.add(widget.userId);
            });
          }
        });
      },
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          border: Border.all(color: FlutterFlowTheme.of(context).alternate),
          borderRadius: BorderRadius.circular(4),
          color: isChecked
              ? FlutterFlowTheme.of(context).primary
              : Colors.transparent,
        ),
        child: isChecked
            ? Icon(Icons.check, size: widget.width * 0.8, color: Colors.white)
            : null,
      ),
    );
  }
}
