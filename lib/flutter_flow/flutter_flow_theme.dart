// flutter_flow_theme.dart
// Flock design-system theme tokens (light + dark) consumed by every screen via
// `FlutterFlowTheme.of(context)`. Also defines shared typography, spacing,
// radius and shadow tokens plus the signature "Sunrise" brand gradient.
// ignore_for_file: overridden_fields, annotate_overrides

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'flutter_flow_theme_dark.dart';

/// The Sunrise gradient stops used sparingly across the app (see design spec
/// section 2.A) — onboarding hero CTA, avatar rings, FAB, create-post CTA.
class FlockGradients {
  const FlockGradients._();

  /// Light-canvas Sunrise gradient: raspberry -> coral -> amber.
  static const LinearGradient sunriseLight = LinearGradient(
    colors: [Color(0xFFC42D63), Color(0xFFFF6F5E), Color(0xFFFFC145)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Dark-canvas Sunrise gradient: brightened for legibility on dark backgrounds.
  static const LinearGradient sunriseDark = LinearGradient(
    colors: [Color(0xFFFF6F94), Color(0xFFFF9142), Color(0xFFFFD166)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

abstract class FlutterFlowTheme {
  /// Returns the light or dark theme instance following the OS brightness
  /// setting (dark mode = "follow system", per owner decision).
  static FlutterFlowTheme of(BuildContext context) {
    final brightness = MediaQuery.platformBrightnessOf(context);
    return brightness == Brightness.dark ? DarkModeTheme() : LightModeTheme();
  }

  @Deprecated('Use primary instead')
  Color get primaryColor => primary;
  @Deprecated('Use secondary instead')
  Color get secondaryColor => secondary;
  @Deprecated('Use tertiary instead')
  Color get tertiaryColor => tertiary;

  late Color primary;
  late Color secondary;
  late Color tertiary;
  late Color alternate;
  late Color primaryText;
  late Color secondaryText;
  late Color primaryBackground;
  late Color secondaryBackground;
  late Color accent1;
  late Color accent2;
  late Color accent3;
  late Color accent4;
  late Color success;
  late Color warning;
  late Color error;
  late Color info;

  late Color greyL4;
  late Color greyL2;
  late Color extraBlack;
  late Color primaryD3;
  late Color pageBack;
  late Color white;
  late Color greenColor1;
  late Color greyL3;
  late Color greyL5;
  late Color greayL1;
  late Color primaryD4;
  late Color tertiaryL1;
  late Color customColor1;
  late Color primaryL1;
  late Color redColor2;
  late Color greenColor2;
  late Color greyD1;
  late Color secondaryNormal;
  late Color shimmerColor;

  /// Highlight sweep colour for skeleton loaders (ShimmerEffect). Must differ per
  /// theme: an opaque white sweep is correct on a light skeleton but flashes as a
  /// bright slab on a dark surface.
  late Color shimmerHighlight;

  FFDesignTokens get designToken => FFDesignTokens(this);

  @Deprecated('Use displaySmallFamily instead')
  String get title1Family => displaySmallFamily;
  @Deprecated('Use displaySmall instead')
  TextStyle get title1 => typography.displaySmall;
  @Deprecated('Use headlineMediumFamily instead')
  String get title2Family => typography.headlineMediumFamily;
  @Deprecated('Use headlineMedium instead')
  TextStyle get title2 => typography.headlineMedium;
  @Deprecated('Use headlineSmallFamily instead')
  String get title3Family => typography.headlineSmallFamily;
  @Deprecated('Use headlineSmall instead')
  TextStyle get title3 => typography.headlineSmall;
  @Deprecated('Use titleMediumFamily instead')
  String get subtitle1Family => typography.titleMediumFamily;
  @Deprecated('Use titleMedium instead')
  TextStyle get subtitle1 => typography.titleMedium;
  @Deprecated('Use titleSmallFamily instead')
  String get subtitle2Family => typography.titleSmallFamily;
  @Deprecated('Use titleSmall instead')
  TextStyle get subtitle2 => typography.titleSmall;
  @Deprecated('Use bodyMediumFamily instead')
  String get bodyText1Family => typography.bodyMediumFamily;
  @Deprecated('Use bodyMedium instead')
  TextStyle get bodyText1 => typography.bodyMedium;
  @Deprecated('Use bodySmallFamily instead')
  String get bodyText2Family => typography.bodySmallFamily;
  @Deprecated('Use bodySmall instead')
  TextStyle get bodyText2 => typography.bodySmall;

  String get displayLargeFamily => typography.displayLargeFamily;
  bool get displayLargeIsCustom => typography.displayLargeIsCustom;
  TextStyle get displayLarge => typography.displayLarge;
  String get displayMediumFamily => typography.displayMediumFamily;
  bool get displayMediumIsCustom => typography.displayMediumIsCustom;
  TextStyle get displayMedium => typography.displayMedium;
  String get displaySmallFamily => typography.displaySmallFamily;
  bool get displaySmallIsCustom => typography.displaySmallIsCustom;
  TextStyle get displaySmall => typography.displaySmall;
  String get headlineLargeFamily => typography.headlineLargeFamily;
  bool get headlineLargeIsCustom => typography.headlineLargeIsCustom;
  TextStyle get headlineLarge => typography.headlineLarge;
  String get headlineMediumFamily => typography.headlineMediumFamily;
  bool get headlineMediumIsCustom => typography.headlineMediumIsCustom;
  TextStyle get headlineMedium => typography.headlineMedium;
  String get headlineSmallFamily => typography.headlineSmallFamily;
  bool get headlineSmallIsCustom => typography.headlineSmallIsCustom;
  TextStyle get headlineSmall => typography.headlineSmall;
  String get titleLargeFamily => typography.titleLargeFamily;
  bool get titleLargeIsCustom => typography.titleLargeIsCustom;
  TextStyle get titleLarge => typography.titleLarge;
  String get titleMediumFamily => typography.titleMediumFamily;
  bool get titleMediumIsCustom => typography.titleMediumIsCustom;
  TextStyle get titleMedium => typography.titleMedium;
  String get titleSmallFamily => typography.titleSmallFamily;
  bool get titleSmallIsCustom => typography.titleSmallIsCustom;
  TextStyle get titleSmall => typography.titleSmall;
  String get labelLargeFamily => typography.labelLargeFamily;
  bool get labelLargeIsCustom => typography.labelLargeIsCustom;
  TextStyle get labelLarge => typography.labelLarge;
  String get labelMediumFamily => typography.labelMediumFamily;
  bool get labelMediumIsCustom => typography.labelMediumIsCustom;
  TextStyle get labelMedium => typography.labelMedium;
  String get labelSmallFamily => typography.labelSmallFamily;
  bool get labelSmallIsCustom => typography.labelSmallIsCustom;
  TextStyle get labelSmall => typography.labelSmall;
  String get bodyLargeFamily => typography.bodyLargeFamily;
  bool get bodyLargeIsCustom => typography.bodyLargeIsCustom;
  TextStyle get bodyLarge => typography.bodyLarge;
  String get bodyMediumFamily => typography.bodyMediumFamily;
  bool get bodyMediumIsCustom => typography.bodyMediumIsCustom;
  TextStyle get bodyMedium => typography.bodyMedium;
  String get bodySmallFamily => typography.bodySmallFamily;
  bool get bodySmallIsCustom => typography.bodySmallIsCustom;
  TextStyle get bodySmall => typography.bodySmall;

  Typography get typography => ThemeTypography(this);
}

class LightModeTheme extends FlutterFlowTheme {
  @Deprecated('Use primary instead')
  Color get primaryColor => primary;
  @Deprecated('Use secondary instead')
  Color get secondaryColor => secondary;
  @Deprecated('Use tertiary instead')
  Color get tertiaryColor => tertiary;

  // Flock "Sunrise" light palette (docs/design/flock-design-system.md §2.B).
  late Color primary = const Color(0xFFC42D63);
  late Color secondary = const Color(0xFF0B7A70);
  late Color tertiary = const Color(0xFFFFC145);
  late Color alternate = const Color(0xFFF1E4E7);
  late Color primaryText = const Color(0xFF1C1424);
  late Color secondaryText = const Color(0xFF6B6478);
  late Color primaryBackground = const Color(0xFFFFFBF9);
  late Color secondaryBackground = const Color(0xFFFFFFFF);
  late Color accent1 = const Color(0x4CC42D63);
  late Color accent2 = const Color(0x4D0B7A70);
  late Color accent3 = const Color(0x4DFFC145);
  late Color accent4 = const Color(0xCCFFFFFF);
  late Color success = const Color(0xFF1B9E6B);
  late Color warning = const Color(0xFFF2A93B);
  late Color error = const Color(0xFFE4453B);
  late Color info = const Color(0xFF2F6FED);

  late Color greyL4 = const Color(0xFF979797);
  late Color greyL2 = const Color(0xFFE8E8E8);
  late Color extraBlack = const Color(0xFF150F1A);
  late Color primaryD3 = const Color(0xFF8E1F49);
  late Color pageBack = const Color(0xFFFFFBF9);
  late Color white = const Color(0xFFFFFFFF);
  // Legacy SQUADD green. Every call site is a SELECTED filter/tab chip (notification
  // filters, search filters, chat tabs) - none carry success/green semantics - so these
  // are retinted to the Flock brand rather than renamed, which would touch 31 call sites.
  late Color greenColor1 = const Color(0xFFC42D63);
  late Color greyL3 = const Color(0xFFB9B9B9);
  late Color greyL5 = const Color(0xFF676767);
  late Color greayL1 = const Color(0xFFEDEEF1);
  late Color primaryD4 = const Color(0xFFA02653);
  late Color tertiaryL1 = const Color(0xFFFFF3DC);
  late Color customColor1 = const Color(0xFFB3B665);
  late Color primaryL1 = const Color(0xFFFBE4EC);
  late Color redColor2 = const Color(0xFFD8321F);
  // Border partner for greenColor1 - one step lighter so a selected chip reads as a
  // filled shape with a soft edge instead of a hard single-tone block.
  late Color greenColor2 = const Color(0xFFD94E7E);
  late Color greyD1 = const Color(0xFF494949);
  late Color secondaryNormal = const Color(0xFFFF4C6A);
  late Color shimmerColor = const Color(0x1A1C1424);
  // Opaque white sweep reads correctly over a light-grey skeleton.
  late Color shimmerHighlight = const Color(0xB2FFFFFF);
}

abstract class Typography {
  String get displayLargeFamily;
  bool get displayLargeIsCustom;
  TextStyle get displayLarge;
  String get displayMediumFamily;
  bool get displayMediumIsCustom;
  TextStyle get displayMedium;
  String get displaySmallFamily;
  bool get displaySmallIsCustom;
  TextStyle get displaySmall;
  String get headlineLargeFamily;
  bool get headlineLargeIsCustom;
  TextStyle get headlineLarge;
  String get headlineMediumFamily;
  bool get headlineMediumIsCustom;
  TextStyle get headlineMedium;
  String get headlineSmallFamily;
  bool get headlineSmallIsCustom;
  TextStyle get headlineSmall;
  String get titleLargeFamily;
  bool get titleLargeIsCustom;
  TextStyle get titleLarge;
  String get titleMediumFamily;
  bool get titleMediumIsCustom;
  TextStyle get titleMedium;
  String get titleSmallFamily;
  bool get titleSmallIsCustom;
  TextStyle get titleSmall;
  String get labelLargeFamily;
  bool get labelLargeIsCustom;
  TextStyle get labelLarge;
  String get labelMediumFamily;
  bool get labelMediumIsCustom;
  TextStyle get labelMedium;
  String get labelSmallFamily;
  bool get labelSmallIsCustom;
  TextStyle get labelSmall;
  String get bodyLargeFamily;
  bool get bodyLargeIsCustom;
  TextStyle get bodyLarge;
  String get bodyMediumFamily;
  bool get bodyMediumIsCustom;
  TextStyle get bodyMedium;
  String get bodySmallFamily;
  bool get bodySmallIsCustom;
  TextStyle get bodySmall;
}

class ThemeTypography extends Typography {
  ThemeTypography(this.theme);

  final FlutterFlowTheme theme;

  // Baloo 2 (display/headline) + Manrope (title/label/body) pairing per
  // docs/design/flock-design-system.md §3. Line-height bumped per spec.
  String get displayLargeFamily => 'Baloo 2';
  bool get displayLargeIsCustom => false;
  TextStyle get displayLarge => GoogleFonts.baloo2(
        color: theme.primaryText,
        fontWeight: FontWeight.w700,
        fontSize: 56.0,
        height: 1.3,
      );
  String get displayMediumFamily => 'Baloo 2';
  bool get displayMediumIsCustom => false;
  TextStyle get displayMedium => GoogleFonts.baloo2(
        color: theme.primaryText,
        fontWeight: FontWeight.w700,
        fontSize: 40.0,
        height: 1.3,
      );
  String get displaySmallFamily => 'Baloo 2';
  bool get displaySmallIsCustom => false;
  TextStyle get displaySmall => GoogleFonts.baloo2(
        color: theme.primaryText,
        fontWeight: FontWeight.w600,
        fontSize: 32.0,
        height: 1.3,
      );
  String get headlineLargeFamily => 'Baloo 2';
  bool get headlineLargeIsCustom => false;
  TextStyle get headlineLarge => GoogleFonts.baloo2(
        color: theme.primaryText,
        fontWeight: FontWeight.w600,
        fontSize: 28.0,
        height: 1.3,
      );
  String get headlineMediumFamily => 'Baloo 2';
  bool get headlineMediumIsCustom => false;
  TextStyle get headlineMedium => GoogleFonts.baloo2(
        color: theme.primaryText,
        fontWeight: FontWeight.w600,
        fontSize: 24.0,
        height: 1.3,
      );
  String get headlineSmallFamily => 'Baloo 2';
  bool get headlineSmallIsCustom => false;
  TextStyle get headlineSmall => GoogleFonts.baloo2(
        color: theme.primaryText,
        fontWeight: FontWeight.w600,
        fontSize: 20.0,
        height: 1.3,
      );
  String get titleLargeFamily => 'Manrope';
  bool get titleLargeIsCustom => false;
  TextStyle get titleLarge => GoogleFonts.manrope(
        color: theme.primaryText,
        fontWeight: FontWeight.w700,
        fontSize: 20.0,
      );
  String get titleMediumFamily => 'Manrope';
  bool get titleMediumIsCustom => false;
  TextStyle get titleMedium => GoogleFonts.manrope(
        color: theme.primaryText,
        fontWeight: FontWeight.w700,
        fontSize: 18.0,
      );
  String get titleSmallFamily => 'Manrope';
  bool get titleSmallIsCustom => false;
  TextStyle get titleSmall => GoogleFonts.manrope(
        color: theme.primaryText,
        fontWeight: FontWeight.w700,
        fontSize: 16.0,
      );
  String get labelLargeFamily => 'Manrope';
  bool get labelLargeIsCustom => false;
  TextStyle get labelLarge => GoogleFonts.manrope(
        color: theme.secondaryText,
        fontWeight: FontWeight.w600,
        fontSize: 16.0,
      );
  String get labelMediumFamily => 'Manrope';
  bool get labelMediumIsCustom => false;
  TextStyle get labelMedium => GoogleFonts.manrope(
        color: theme.secondaryText,
        fontWeight: FontWeight.w600,
        fontSize: 14.0,
      );
  String get labelSmallFamily => 'Manrope';
  bool get labelSmallIsCustom => false;
  TextStyle get labelSmall => GoogleFonts.manrope(
        color: theme.secondaryText,
        fontWeight: FontWeight.w600,
        fontSize: 12.0,
        letterSpacing: 0.2,
      );
  String get bodyLargeFamily => 'Manrope';
  bool get bodyLargeIsCustom => false;
  TextStyle get bodyLarge => GoogleFonts.manrope(
        color: theme.primaryText,
        fontWeight: FontWeight.normal,
        fontSize: 16.0,
        height: 1.45,
      );
  String get bodyMediumFamily => 'Manrope';
  bool get bodyMediumIsCustom => false;
  TextStyle get bodyMedium => GoogleFonts.manrope(
        color: theme.primaryText,
        fontWeight: FontWeight.normal,
        fontSize: 14.0,
        height: 1.45,
      );
  String get bodySmallFamily => 'Manrope';
  bool get bodySmallIsCustom => false;
  TextStyle get bodySmall => GoogleFonts.manrope(
        color: theme.primaryText,
        fontWeight: FontWeight.normal,
        fontSize: 12.0,
        height: 1.45,
      );
}

class FFDesignTokens {
  const FFDesignTokens(this.theme);
  final FlutterFlowTheme theme;
  FFSpacing get spacing => const FFSpacing();
  FFRadius get radius => const FFRadius();
  FFShadows get shadow => FFShadows(theme);
}

class FFSpacing {
  const FFSpacing();
  double get xs => 4.0;
  double get sm => 8.0;
  double get md => 16.0;
  double get lg => 24.0;
  double get xl => 32.0;
}

class FFRadius {
  const FFRadius();
  double get sm => 8.0;
  double get md => 16.0;
  double get lg => 24.0;
  double get full => 9999.0;
}

// Card/surface shadows retinted toward the brand raspberry hue (warm-shadow
// best practice, spec §4). Deep-overlay shadow (`xl`) stays pure black.
class FFShadows {
  const FFShadows(this.theme);
  final FlutterFlowTheme theme;
  BoxShadow get sm => BoxShadow(
        blurRadius: 3.0,
        color: theme.primary.withAlpha(0x1A),
        offset: const Offset(0.0, 1.0),
        spreadRadius: 0.0,
      );
  BoxShadow get md => BoxShadow(
        blurRadius: 6.0,
        color: theme.primary.withAlpha(0x1A),
        offset: const Offset(0.0, 3.0),
        spreadRadius: 0.0,
      );
  BoxShadow get lg => BoxShadow(
        blurRadius: 15.0,
        color: theme.primary.withAlpha(0x1A),
        offset: const Offset(0.0, 8.0),
        spreadRadius: 0.0,
      );
  BoxShadow get xl => const BoxShadow(
        blurRadius: 25.0,
        color: const Color(0x1A000000),
        offset: const Offset(0.0, 16.0),
        spreadRadius: 0.0,
      );
}

extension TextStyleHelper on TextStyle {
  TextStyle override({
    TextStyle? font,
    String? fontFamily,
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
    double? letterSpacing,
    FontStyle? fontStyle,
    bool useGoogleFonts = false,
    TextDecoration? decoration,
    double? lineHeight,
    List<Shadow>? shadows,
    String? package,
  }) {
    if (useGoogleFonts && fontFamily != null && fontFamily.isNotEmpty) {
      font = GoogleFonts.getFont(
        fontFamily,
        fontWeight: fontWeight ?? this.fontWeight,
        fontStyle: fontStyle ?? this.fontStyle,
      );
    }

    return font != null
        ? font.copyWith(
            color: color ?? this.color,
            fontSize: fontSize ?? this.fontSize,
            letterSpacing: letterSpacing ?? this.letterSpacing,
            fontWeight: fontWeight ?? this.fontWeight,
            fontStyle: fontStyle ?? this.fontStyle,
            decoration: decoration,
            height: lineHeight,
            shadows: shadows,
          )
        : copyWith(
            fontFamily: fontFamily,
            package: package,
            color: color,
            fontSize: fontSize,
            letterSpacing: letterSpacing,
            fontWeight: fontWeight,
            fontStyle: fontStyle,
            decoration: decoration,
            height: lineHeight,
            shadows: shadows,
          );
  }
}
