// empty_state.dart
// Flock shared empty-state block: icon (or illustration) + title + optional body
// + optional CTA. One component for "no posts yet", "no search results",
// "no groups", and — via `AsyncStateView` — the designed error state the app is
// missing today (ui-review 2026-07-21 §2.7). Light + dark safe: every colour is
// a `FlutterFlowTheme` token; spacing/radius come from FFSpacing / FFRadius.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '/flutter_flow/flutter_flow_theme.dart';

/// A centred "nothing here" (or "something went wrong") block.
///
/// Usage:
///   EmptyState(
///     icon: Icons.forum_outlined,
///     title: 'No posts yet',
///     body: 'Be the first to say hello to your neighbours.',
///     actionLabel: 'Create a post',
///     onAction: () => context.pushNamed('createPost'),
///   )
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.title,
    this.body,
    this.icon,
    this.illustrationAsset,
    this.iconColor,
    this.iconBackgroundColor,
    this.actionLabel,
    this.onAction,
    this.compact = false,
    this.padding,
    this.animate = true,
  });

  /// Headline, e.g. "No posts yet". Required.
  final String title;

  /// Optional supporting sentence under the headline.
  final String? body;

  /// Glyph shown in the round badge. Defaults to an inbox glyph.
  final IconData? icon;

  /// Optional asset illustration; when set it replaces the glyph badge.
  final String? illustrationAsset;

  /// Glyph colour override (the error state passes `theme.error`).
  final Color? iconColor;

  /// Glyph badge background override. Defaults to `alternate`.
  final Color? iconBackgroundColor;

  /// CTA label. The button only renders when both this and [onAction] are set.
  final String? actionLabel;

  /// CTA callback.
  final VoidCallback? onAction;

  /// Tighter sizing for use inside a card, sheet or short list slot.
  final bool compact;

  /// Outer padding override. Defaults to 24px horizontal / 32px vertical.
  final EdgeInsetsGeometry? padding;

  /// Set false to skip the entrance animation.
  final bool animate;

  /// True when a usable CTA (label + callback) was supplied.
  bool get _hasAction =>
      actionLabel != null && actionLabel!.isNotEmpty && onAction != null;

  /// Illustration image, or the round glyph badge when no asset is given.
  Widget _buildArtwork(BuildContext context, FlutterFlowTheme theme) {
    if (illustrationAsset != null && illustrationAsset!.isNotEmpty) {
      return Image.asset(
        illustrationAsset!,
        height: compact ? 96.0 : 140.0,
        fit: BoxFit.contain,
      );
    }

    final double badgeSize = compact ? 56.0 : 72.0;
    return Container(
      width: badgeSize,
      height: badgeSize,
      decoration: BoxDecoration(
        color: iconBackgroundColor ?? theme.alternate,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Icon(
        icon ?? Icons.inbox_outlined,
        size: compact ? 26.0 : 34.0,
        color: iconColor ?? theme.secondaryText,
      ),
    );
  }

  /// Pill CTA button — primary fill, white label, >=46px tall touch target.
  Widget _buildAction(BuildContext context, FlutterFlowTheme theme) {
    return Semantics(
      button: true,
      label: actionLabel,
      child: Material(
        color: theme.primary,
        borderRadius: BorderRadius.circular(theme.designToken.radius.full),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            onAction!.call();
          },
          borderRadius: BorderRadius.circular(theme.designToken.radius.full),
          splashColor: Colors.white.withAlpha(0x33),
          highlightColor: Colors.white.withAlpha(0x1F),
          child: Container(
            constraints: const BoxConstraints(minHeight: 46.0),
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            alignment: Alignment.center,
            child: Text(
              actionLabel!,
              textAlign: TextAlign.center,
              style: theme.titleSmall.override(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final FlutterFlowTheme theme = FlutterFlowTheme.of(context);
    final FFSpacing spacing = theme.designToken.spacing;

    // Honour the OS reduced-motion setting on both Android and iOS.
    final bool reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;

    final Widget column = Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        _buildArtwork(context, theme),
        SizedBox(height: compact ? spacing.sm : spacing.md),
        Text(
          title,
          textAlign: TextAlign.center,
          style: (compact ? theme.titleMedium : theme.headlineSmall).override(
            color: theme.primaryText,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (body != null && body!.isNotEmpty) ...<Widget>[
          SizedBox(height: spacing.sm),
          Text(
            body!,
            textAlign: TextAlign.center,
            style: theme.bodyMedium.override(color: theme.secondaryText),
          ),
        ],
        if (_hasAction) ...<Widget>[
          SizedBox(height: compact ? spacing.md : spacing.lg),
          _buildAction(context, theme),
        ],
      ],
    );

    final Widget content = Padding(
      padding: padding ??
          EdgeInsets.symmetric(
            horizontal: spacing.lg,
            vertical: compact ? spacing.md : spacing.xl,
          ),
      child: Center(child: column),
    );

    if (!animate || reduceMotion) {
      return content;
    }

    return content.animate().fadeIn(duration: 250.ms).scale(
          begin: const Offset(0.96, 0.96),
          end: const Offset(1.0, 1.0),
          duration: 250.ms,
          curve: Curves.easeOutBack,
        );
  }
}
