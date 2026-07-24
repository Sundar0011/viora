// app_icon_button.dart
// Flock shared icon button. Guarantees a >=44x44 tap target regardless of the
// visual glyph size (the hit area grows, the icon does not), bakes in the
// `Semantics(button:, label:, enabled:)` node that the app is missing everywhere
// (ui-review 2026-07-21 §2.3), gives real press feedback inside 120ms, and
// supports a proper disabled state. Light + dark safe: colours are theme tokens.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '/flutter_flow/flutter_flow_theme.dart';

/// An accessible, correctly-sized icon button.
///
/// Usage:
///   AppIconButton(
///     icon: Icons.favorite_border,
///     semanticLabel: 'Like, 12 likes',
///     onTap: () => _toggleLike(),
///   )
class AppIconButton extends StatefulWidget {
  const AppIconButton({
    super.key,
    this.icon,
    this.iconWidget,
    required this.semanticLabel,
    required this.onTap,
    this.iconSize = 24.0,
    this.color,
    this.disabledColor,
    this.backgroundColor,
    this.borderRadius,
    this.minTapTarget = 44.0,
    this.enabled = true,
    this.enableHaptic = true,
    this.tooltip,
  }) : assert(icon != null || iconWidget != null,
            'AppIconButton needs either an icon or an iconWidget');

  /// Glyph to render. Ignored when [iconWidget] is supplied.
  final IconData? icon;

  /// Custom glyph widget (e.g. a `FaIcon` or an SVG) instead of [icon].
  final Widget? iconWidget;

  /// Screen-reader label. Required — an icon-only control is unusable without it.
  final String semanticLabel;

  /// Tap callback. Null disables the button (same as `enabled: false`).
  final VoidCallback? onTap;

  /// Visual glyph size. This never changes the tap target size.
  final double iconSize;

  /// Glyph colour when enabled. Defaults to `primaryText`.
  final Color? color;

  /// Glyph colour when disabled. Defaults to a dimmed `secondaryText`.
  final Color? disabledColor;

  /// Optional filled background behind the glyph (e.g. a circular chip).
  final Color? backgroundColor;

  /// Corner radius for [backgroundColor] and the ripple. Defaults to a circle.
  final BorderRadius? borderRadius;

  /// Minimum width AND height of the tap target. Never set below 44.
  final double minTapTarget;

  /// Set false to render the disabled state without changing [onTap].
  final bool enabled;

  /// Light haptic tick on tap (both Android and iOS).
  final bool enableHaptic;

  /// Optional long-press tooltip. Falls back to no tooltip when null.
  final String? tooltip;

  @override
  State<AppIconButton> createState() => _AppIconButtonState();
}

class _AppIconButtonState extends State<AppIconButton> {
  bool _pressed = false;

  /// True only when the caller both allows taps and supplied a callback.
  bool get _isEnabled => widget.enabled && widget.onTap != null;

  /// Tracks the press state that drives the fast scale/opacity feedback.
  void _setPressed(bool pressed) {
    if (_pressed == pressed) {
      return;
    }
    setState(() => _pressed = pressed);
  }

  /// Fires the haptic tick then the caller's callback.
  void _handleTap() {
    if (!_isEnabled) {
      return;
    }
    if (widget.enableHaptic) {
      HapticFeedback.lightImpact();
    }
    widget.onTap!.call();
  }

  @override
  Widget build(BuildContext context) {
    final FlutterFlowTheme theme = FlutterFlowTheme.of(context);

    // Never let a caller shrink the touch target below the platform minimum.
    final double target =
        widget.minTapTarget < 44.0 ? 44.0 : widget.minTapTarget;

    final BorderRadius radius =
        widget.borderRadius ?? BorderRadius.circular(9999.0);

    final Color glyphColor = _isEnabled
        ? (widget.color ?? theme.primaryText)
        : (widget.disabledColor ?? theme.secondaryText.withAlpha(0x61));

    final Widget glyph = widget.iconWidget ??
        Icon(
          widget.icon,
          size: widget.iconSize,
          color: glyphColor,
        );

    // Press feedback lands well inside the 80-150ms window; the ink splash
    // underneath continues the motion for the rest of the gesture.
    final Widget pressable = AnimatedScale(
      scale: _pressed && _isEnabled ? 0.90 : 1.0,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      child: AnimatedOpacity(
        opacity: _pressed && _isEnabled ? 0.7 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: IconTheme.merge(
          data: IconThemeData(color: glyphColor, size: widget.iconSize),
          child: glyph,
        ),
      ),
    );

    Widget button = Material(
      color: widget.backgroundColor ?? Colors.transparent,
      borderRadius: radius,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: _isEnabled ? _handleTap : null,
        onTapDown: _isEnabled ? (TapDownDetails _) => _setPressed(true) : null,
        onTapCancel: _isEnabled ? () => _setPressed(false) : null,
        onTapUp: _isEnabled ? (TapUpDetails _) => _setPressed(false) : null,
        borderRadius: radius,
        splashColor: theme.primary.withAlpha(0x1F),
        highlightColor: theme.primary.withAlpha(0x14),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: target,
            minHeight: target,
          ),
          child: Center(
            widthFactor: 1.0,
            heightFactor: 1.0,
            child: pressable,
          ),
        ),
      ),
    );

    if (widget.tooltip != null && widget.tooltip!.isNotEmpty) {
      button = Tooltip(
        message: widget.tooltip!,
        excludeFromSemantics: true,
        child: button,
      );
    }

    // MergeSemantics folds the InkWell's tap action and this label into a single
    // node, so TalkBack/VoiceOver announce "<label>, button" (or "dimmed").
    return MergeSemantics(
      child: Semantics(
        button: true,
        enabled: _isEnabled,
        label: widget.semanticLabel,
        child: button,
      ),
    );
  }
}
