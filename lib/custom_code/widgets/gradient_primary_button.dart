// gradient_primary_button.dart
// Flock "Sunrise" gradient CTA button — reserved for the single highest
// priority action per flow (onboarding CTA, create-post/create-listing CTA).
// Pill radius, white label, subtle raspberry-tinted shadow, press scale.
import '/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';

class GradientPrimaryButton extends StatefulWidget {
  const GradientPrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.width,
    this.height = 46.0,
    this.textStyle,
  });

  /// Button label.
  final String text;

  /// Tap callback.
  final VoidCallback onPressed;

  /// Optional fixed width; defaults to filling the available width.
  final double? width;

  /// Button height (≥44px touch target maintained by default 46).
  final double height;

  /// Optional style override for the label; defaults to titleSmall/white.
  final TextStyle? textStyle;

  @override
  State<GradientPrimaryButton> createState() => _GradientPrimaryButtonState();
}

class _GradientPrimaryButtonState extends State<GradientPrimaryButton> {
  bool _pressed = false;

  // Applies the subtle press-down scale used for all Flock buttons.
  void _setPressed(bool pressed) => setState(() => _pressed = pressed);

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gradient =
        isDark ? FlockGradients.sunriseDark : FlockGradients.sunriseLight;

    return GestureDetector(
      onTapDown: (_) => _setPressed(true),
      onTapCancel: () => _setPressed(false),
      onTapUp: (_) => _setPressed(false),
      onTap: widget.onPressed,
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOutBack,
        child: Container(
          width: widget.width ?? double.infinity,
          height: widget.height,
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(theme.designToken.radius.full),
            boxShadow: [
              BoxShadow(
                color: theme.primary.withAlpha(0x33),
                blurRadius: 4.0,
                offset: const Offset(0.0, 2.0),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            widget.text,
            style: widget.textStyle ??
                theme.titleSmall.override(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
      ),
    );
  }
}
