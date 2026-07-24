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

import 'dart:ui' as ui;
import 'package:flutter/services.dart';

class CustomPinCode extends StatefulWidget {
  const CustomPinCode({
    super.key,
    this.width,
    this.height,
  });

  final double? width;
  final double? height;

  @override
  State<CustomPinCode> createState() => _CustomPinCodeState();
}

class _CustomPinCodeState extends State<CustomPinCode> {
  final List<TextEditingController> _controllers =
      List.generate(4, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (index) => FocusNode());
  String _lastOtpValue = '';

  @override
  void initState() {
    super.initState();
    FFAppState().Otp = '';
    _lastOtpValue = '';

    for (var controller in _controllers) {
      controller.clear();
    }

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        FocusScope.of(context).requestFocus(_focusNodes[0]);
      }
    });
  }

  @override
  void didUpdateWidget(CustomPinCode oldWidget) {
    super.didUpdateWidget(oldWidget);
    _checkAppStateChange();
  }

  void _checkAppStateChange() {
    // Check if app state OTP has been cleared from outside
    if (FFAppState().Otp.isEmpty && _lastOtpValue.isNotEmpty) {
      _clearAllFields();
    }
    _lastOtpValue = FFAppState().Otp;
  }

  void _clearAllFields() {
    for (var controller in _controllers) {
      controller.clear();
    }
    // Focus on first field after clearing
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        FocusScope.of(context).requestFocus(_focusNodes[0]);
      }
    });
    setState(() {});
  }

  void _onOtpChanged(int index, String value) {
    if (value.isNotEmpty) {
      if (index < 3) {
        FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
      } else {
        FocusScope.of(context).unfocus();
      }
    }

    String otpString = _controllers.map((c) => c.text).join();
    FFAppState().Otp = otpString.length == 4 ? otpString : '';
    _lastOtpValue = FFAppState().Otp;

    setState(() {});
  }

  void _handleBackspace(int index, RawKeyEvent event) {
    if (event is RawKeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace) {
      if (_controllers[index].text.isEmpty && index > 0) {
        FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check for app state changes on each build
    _checkAppStateChange();

    return Directionality(
      textDirection: ui.TextDirection.ltr,
      child: Container(
        width: widget.width ?? 280,
        height: widget.height ?? 52,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            4,
            (index) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6), // 12px gap
              child: SizedBox(
                width: 58,
                height: 52,
                child: RawKeyboardListener(
                  focusNode: FocusNode(),
                  onKey: (event) => _handleBackspace(index, event),
                  child: TextField(
                    controller: _controllers[index],
                    focusNode: _focusNodes[index],
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    maxLength: 1,
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: FlutterFlowTheme.of(context).primaryText,
                      height: 1, // 140%
                      letterSpacing: 0.08,
                    ),
                    textInputAction:
                        index < 3 ? TextInputAction.next : TextInputAction.done,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    cursorColor: FlutterFlowTheme.of(context).primaryText,
                    onChanged: (value) => _onOtpChanged(index, value),
                    onSubmitted: (value) {
                      if (index == 3) {
                        FocusScope.of(context).unfocus();
                      }
                    },
                    decoration: InputDecoration(
                      counterText: "",
                      contentPadding: const EdgeInsets.symmetric(vertical: 18),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                            color: FlutterFlowTheme.of(context).primaryText),
                      ),
                      filled: true,
                      fillColor:
                          const Color(0x1AFFFFFF), // rgba(255,255,255,0.10)
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
