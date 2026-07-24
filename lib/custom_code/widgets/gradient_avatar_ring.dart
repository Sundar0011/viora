// gradient_avatar_ring.dart
// Wraps a circular avatar with the Flock "Sunrise" gradient ring, used
// sparingly for the signed-in user's own avatar and "featured/verified
// neighbor" affordances (design spec §5, Avatars).
import '/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';

class GradientAvatarRing extends StatelessWidget {
  const GradientAvatarRing({
    super.key,
    required this.child,
    required this.diameter,
    this.ringWidth = 2.5,
  });

  /// The avatar widget (image/circle avatar) rendered inside the ring.
  final Widget child;

  /// Outer diameter of the ring, in logical pixels.
  final double diameter;

  /// Ring stroke thickness (spec: 2-3px).
  final double ringWidth;

  // Builds the gradient ring container with the avatar clipped inside it.
  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gradient =
        isDark ? FlockGradients.sunriseDark : FlockGradients.sunriseLight;
    final innerDiameter = diameter - (ringWidth * 2);

    return Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: gradient,
      ),
      padding: EdgeInsets.all(ringWidth),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: theme.secondaryBackground,
        ),
        padding: const EdgeInsets.all(1.0),
        child: ClipOval(
          child: SizedBox(
            width: innerDiameter,
            height: innerDiameter,
            child: child,
          ),
        ),
      ),
    );
  }
}
