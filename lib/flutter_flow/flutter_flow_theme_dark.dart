// flutter_flow_theme_dark.dart
// Flock dark-mode palette split out from flutter_flow_theme.dart to keep
// individual theme files under the project's 400-line guideline.
// ignore_for_file: overridden_fields, annotate_overrides

import 'package:flutter/material.dart';
import 'flutter_flow_theme.dart';

/// Flock dark palette — mirrors [LightModeTheme] tokens with brightened
/// hues tuned for a dark canvas (docs/design/flock-design-system.md §2.C).
/// Selected via [FlutterFlowTheme.of] when the OS is in dark mode.
class DarkModeTheme extends FlutterFlowTheme {
  @Deprecated('Use primary instead')
  Color get primaryColor => primary;
  @Deprecated('Use secondary instead')
  Color get secondaryColor => secondary;
  @Deprecated('Use tertiary instead')
  Color get tertiaryColor => tertiary;

  late Color primary = const Color(0xFFFF6F94);
  late Color secondary = const Color(0xFF3FC7B8);
  late Color tertiary = const Color(0xFFFFCE6E);
  late Color alternate = const Color(0xFF332933);
  late Color primaryText = const Color(0xFFF6F1FA);
  late Color secondaryText = const Color(0xFFB3A8C2);
  late Color primaryBackground = const Color(0xFF15111C);
  late Color secondaryBackground = const Color(0xFF221B2B);
  late Color accent1 = const Color(0x4CC42D63);
  late Color accent2 = const Color(0x4D0B7A70);
  late Color accent3 = const Color(0x4DFFC145);
  late Color accent4 = const Color(0xCCFFFFFF);
  late Color success = const Color(0xFF3FBE8C);
  late Color warning = const Color(0xFFFFC15C);
  late Color error = const Color(0xFFFF6B60);
  late Color info = const Color(0xFF5C8DFF);

  late Color greyL4 = const Color(0xFF8C8399);
  late Color greyL2 = const Color(0xFF332933);
  // Dark-mode "strong text" anchor: light in dark so headings/labels that use
  // extraBlack stay readable (in light mode this token is near-black).
  late Color extraBlack = const Color(0xFFF6F1FA);
  late Color primaryD3 = const Color(0xFFB33D66);
  late Color pageBack = const Color(0xFF15111C);
  // Dark-mode surface anchor: many screens use `white` as a card/scaffold fill,
  // so it must invert to a dark surface in dark mode. Foreground-on-color uses
  // of `white` (text/icons on gradient/primary) are fixed at their call sites.
  late Color white = const Color(0xFF221B2B);
  // Legacy SQUADD green, retinted to the Flock brand - see the light theme for why.
  late Color greenColor1 = const Color(0xFFFF6F94);
  late Color greyL3 = const Color(0xFF4A4152);
  late Color greyL5 = const Color(0xFFB3A8C2);
  late Color greayL1 = const Color(0xFF221B2B);
  late Color primaryD4 = const Color(0xFFC44873);
  late Color tertiaryL1 = const Color(0xFF3A311F);
  late Color customColor1 = const Color(0xFFB3B665);
  late Color primaryL1 = const Color(0xFF3A2430);
  late Color redColor2 = const Color(0xFFFF6B60);
  late Color greenColor2 = const Color(0xFFFF8FAC);
  late Color greyD1 = const Color(0xFFEDEEF1);
  late Color secondaryNormal = const Color(0xFFFF6F94);
  late Color shimmerColor = const Color(0x1AF6F1FA);
  // 20% white: visible as a sweep on a dark card without flashing white.
  late Color shimmerHighlight = const Color(0x33FFFFFF);
}
