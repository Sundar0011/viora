// app_shimmer_box.dart
// Flock shared skeleton primitive. Renders a single theme-tokened shimmer block
// used as the ONE app-wide loading treatment (see ui-review 2026-07-21 §2.7).
// Consumed by `AppNetworkImage` (image placeholder) and `AsyncStateView`
// (list skeleton). Light + dark safe: colours come only from `shimmerColor`,
// `shimmerHighlight` and `alternate` theme tokens.
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '/flutter_flow/flutter_flow_theme.dart';

/// A single animated skeleton block (rectangle, rounded rectangle or circle).
///
/// The block always occupies the width/height it is given, so it can stand in
/// for real content without causing a layout shift when that content arrives.
class AppShimmerBox extends StatelessWidget {
  const AppShimmerBox({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
    this.shape = BoxShape.rectangle,
    this.animate = true,
  });

  /// Block width; null means "fill the available width".
  final double? width;

  /// Block height; null means "fill the available height".
  final double? height;

  /// Corner radius. Ignored when [shape] is [BoxShape.circle].
  final BorderRadius? borderRadius;

  /// Rectangle (default) or circle — circle is used for avatar placeholders.
  final BoxShape shape;

  /// Set false to render a static block (used when the OS asks for reduced motion).
  final bool animate;

  /// Opaque skeleton fill: the translucent `shimmerColor` tint composited over
  /// the neutral `alternate` surface, so the block reads correctly in both themes.
  static Color fillColor(FlutterFlowTheme theme) =>
      Color.alphaBlend(theme.shimmerColor, theme.alternate);

  @override
  Widget build(BuildContext context) {
    final FlutterFlowTheme theme = FlutterFlowTheme.of(context);

    // Respect the OS "reduce motion" accessibility setting on Android and iOS.
    final bool reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final bool shouldAnimate = animate && !reduceMotion;

    final Widget block = Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: fillColor(theme),
        shape: shape,
        borderRadius: shape == BoxShape.circle ? null : borderRadius,
      ),
    );

    if (!shouldAnimate) {
      return block;
    }

    return block.animate(onPlay: (AnimationController c) => c.repeat()).shimmer(
          duration: 1400.ms,
          color: theme.shimmerHighlight,
          angle: 0.45,
        );
  }
}

/// A skeleton stand-in for one line of text: a short rounded bar.
///
/// [widthFactor] is a fraction of the available width (0-1) so lines of
/// different lengths can be stacked to imply a paragraph.
class AppShimmerLine extends StatelessWidget {
  const AppShimmerLine({
    super.key,
    this.widthFactor = 1.0,
    this.height = 12.0,
    this.animate = true,
  });

  /// Fraction of the parent width this line occupies.
  final double widthFactor;

  /// Line height in logical pixels.
  final double height;

  /// Set false to render a static bar (reduced-motion callers).
  final bool animate;

  @override
  Widget build(BuildContext context) {
    final FlutterFlowTheme theme = FlutterFlowTheme.of(context);

    return FractionallySizedBox(
      alignment: AlignmentDirectional.centerStart,
      widthFactor: widthFactor.clamp(0.05, 1.0),
      child: AppShimmerBox(
        height: height,
        animate: animate,
        borderRadius: BorderRadius.circular(theme.designToken.radius.sm),
      ),
    );
  }
}
