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

class ModernLoadingWidget extends StatefulWidget {
  const ModernLoadingWidget({
    super.key,
    this.width,
    this.height,
    this.primaryColor,
    this.secondaryColor,
    this.backgroundColor,
  });

  final double? width;
  final double? height;
  final Color? primaryColor;
  final Color? secondaryColor;
  final Color? backgroundColor;

  @override
  State<ModernLoadingWidget> createState() => _ModernLoadingWidgetState();
}

class _ModernLoadingWidgetState extends State<ModernLoadingWidget>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  final String appName = "SquaDD";

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );

    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryCol = widget.primaryColor ?? const Color(0xFF6366F1);
    final secondaryCol = widget.secondaryColor ?? const Color(0xFF8B5CF6);
    final size = widget.width ?? 200.0;

    return Container(
      width: widget.width,
      height: widget.height,
      child: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            // Calculate how many letters should be visible
            final totalDuration = 1.0;
            final typingDuration = 0.7; // 70% for typing
            final pauseDuration = 0.3; // 30% pause before restart

            String displayText = "";
            bool showCursor = false;

            if (_controller.value <= typingDuration) {
              // Typing phase
              final typingProgress = _controller.value / typingDuration;
              final visibleLetters = (typingProgress * appName.length).floor();
              displayText = appName.substring(0, visibleLetters);
              showCursor = true;
            } else {
              // Pause phase - show full text
              displayText = appName;
              // Blinking cursor during pause
              final blinkProgress =
                  (_controller.value - typingDuration) / pauseDuration;
              showCursor =
                  (blinkProgress * 6) % 2 < 1; // Blink 3 times during pause
            }

            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Display the typed text
                ...displayText
                    .split('')
                    .map((letter) => Container(
                          margin:
                              EdgeInsets.symmetric(horizontal: size * 0.005),
                          child: Text(
                            letter,
                            style: TextStyle(
                              fontSize: size * 0.15,
                              fontWeight: FontWeight.w600,
                              color: primaryCol,
                              fontFamily: 'Manrope',
                              shadows: [
                                Shadow(
                                  color: primaryCol.withOpacity(0.3),
                                  blurRadius: 4,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                          ),
                        ))
                    .toList(),

                // Typing cursor
                if (showCursor)
                  Container(
                    width: 2,
                    height: size * 0.12,
                    margin: const EdgeInsets.only(left: 2),
                    decoration: BoxDecoration(
                      color: secondaryCol,
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
