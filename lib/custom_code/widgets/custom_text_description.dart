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

class CustomTextDescription extends StatefulWidget {
  const CustomTextDescription({
    super.key,
    this.width,
    this.height,
    required this.description,
    this.tagList,
  });

  final double? width;
  final double? height;
  final String description;
  final String? tagList;

  @override
  State<CustomTextDescription> createState() => _CustomTextDescriptionState();
}

class _CustomTextDescriptionState extends State<CustomTextDescription> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
