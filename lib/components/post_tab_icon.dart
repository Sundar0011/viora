// post_tab_icon.dart
// Flock bottom-nav "Post" (create) tab glyph, drawn in code instead of loaded
// from a raster. Replaces `assets/images/post_blue.png` / `post_grey.png`, which
// could never be tinted (a `srcIn` tint flattens the two-tone glyph and the plus
// disappears) and therefore still shipped the pre-Flock blue `#2450FF` in the
// active state and a white-bar-tuned `#979797` in the inactive state.
//
// Drawing it means the glyph tracks `FlutterFlowTheme` forever: raspberry
// `#C42D63` in light, `#FF6F94` in dark, with the plus knocked out in the nav
// bar's own surface colour so it reads exactly like the original two-tone PNG.
// Pure Flutter — no new dependency, no SVG.
//
// Geometry below is measured from the 96x96 originals, so the silhouette keeps
// the same optical weight as the four sibling tab glyphs:
//   diamond bounding box  74/96 = 0.771 of the canvas
//   corner arc radius      8/96 = 0.083 of the canvas (0.153 of the square side)
//   plus extent           27/96 = 0.281 of the canvas (identical in both PNGs)
//   plus stroke        4-6 / 96 = 0.042-0.063 (blue was 4px, grey 6px; we split)
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '/flutter_flow/flutter_flow_theme.dart';

/// The rounded-diamond "create a post" glyph for the bottom navigation bar.
///
/// Usage:
///   PostTabIcon(isActive: widget.pagename == 'post')
class PostTabIcon extends StatelessWidget {
  const PostTabIcon({
    super.key,
    required this.isActive,
    this.size = 28.0,
  });

  /// True paints the diamond in `primary`; false paints it in `secondaryText`.
  final bool isActive;

  /// Layout box for the glyph. The diamond is inscribed inside it.
  final double size;

  /// Side of the un-rotated square; its diagonal spans 77.1% of [size].
  double get _squareSide => size * 0.545;

  /// Corner rounding that reproduces the PNG's soft-cornered diamond.
  double get _cornerRadius => _squareSide * 0.153;

  /// Tip-to-tip length of the knocked-out plus.
  double get _armLength => size * 0.281;

  /// Stroke thickness of the plus, with fully rounded ends.
  double get _armThickness => size * 0.055;

  /// One rounded bar of the plus; [horizontal] flips its orientation.
  Widget _buildArm(Color color, {required bool horizontal}) {
    return Container(
      width: horizontal ? _armLength : _armThickness,
      height: horizontal ? _armThickness : _armLength,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(_armThickness / 2.0),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final FlutterFlowTheme theme = FlutterFlowTheme.of(context);

    // Active = brand raspberry (light) / brightened raspberry (dark); inactive =
    // the same muted token every sibling tab's inactive glyph already uses.
    final Color fill = isActive ? theme.primary : theme.secondaryText;

    // The plus is a knockout, so it must match the bar surface behind it.
    final Color knockout = theme.secondaryBackground;

    return SizedBox(
      width: size,
      height: size,
      child: Center(
        child: Transform.rotate(
          angle: math.pi / 4.0,
          child: Container(
            width: _squareSide,
            height: _squareSide,
            decoration: BoxDecoration(
              color: fill,
              borderRadius: BorderRadius.circular(_cornerRadius),
            ),
            // Counter-rotation keeps the plus upright inside the tilted square.
            child: Center(
              child: Transform.rotate(
                angle: -math.pi / 4.0,
                child: Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    _buildArm(knockout, horizontal: true),
                    _buildArm(knockout, horizontal: false),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
