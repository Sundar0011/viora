// app_network_image.dart
// Flock shared network-image widget. Wraps `CachedNetworkImage` so every remote
// image in the app is disk/memory cached, shows a shimmer placeholder while it
// loads, degrades to a neutral themed glyph on failure, and always reserves its
// box so nothing shifts when the image resolves (ui-review 2026-07-21 §2.5).
// Replaces bare `Image.network` call sites. Light + dark safe: every colour is a
// `FlutterFlowTheme` token.
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '/flutter_flow/flutter_flow_theme.dart';
import 'app_shimmer_box.dart';

/// A cached, placeholder-backed, error-tolerant remote image.
///
/// Usage — post photo:
///   AppNetworkImage(url: post.imageUrl, width: double.infinity, height: 220,
///     borderRadius: BorderRadius.circular(24), semanticLabel: 'Post photo')
///
/// Usage — avatar:
///   AppNetworkImage(url: user.photo, width: 40, height: 40, isAvatar: true,
///     semanticLabel: "Asha's profile photo")
class AppNetworkImage extends StatelessWidget {
  const AppNetworkImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.isAvatar = false,
    this.semanticLabel,
    this.fallbackIcon,
    this.backgroundColor,
  });

  /// Remote image URL. Null / empty / blank renders the fallback, never a crash.
  final String? url;

  /// Reserved width. Pass a real value wherever possible to avoid layout shift.
  final double? width;

  /// Reserved height. Pass a real value wherever possible to avoid layout shift.
  final double? height;

  /// How the image fills its box. Defaults to cover.
  final BoxFit fit;

  /// Corner radius for non-avatar images. Ignored when [isAvatar] is true.
  final BorderRadius? borderRadius;

  /// True renders a circular image and a person glyph fallback.
  final bool isAvatar;

  /// Screen-reader description. When given, the widget is wrapped in
  /// `Semantics(image: true, label: ...)`; when null the image is decorative.
  final String? semanticLabel;

  /// Optional override for the fallback glyph shown on error/empty URL.
  final IconData? fallbackIcon;

  /// Optional override for the placeholder/fallback surface colour.
  final Color? backgroundColor;

  /// True when there is no usable URL to load.
  bool get _hasNoUrl => url == null || url!.trim().isEmpty;

  /// Circle for avatars, caller-supplied radius (or square) otherwise.
  BorderRadius _resolveRadius() {
    if (isAvatar) {
      return BorderRadius.circular(9999.0);
    }
    return borderRadius ?? BorderRadius.zero;
  }

  /// Glyph size scaled to the box, clamped so it never dominates or disappears.
  double _glyphSize() {
    final double shortestSide = <double>[
      width ?? 48.0,
      height ?? 48.0,
    ].reduce((double a, double b) => a < b ? a : b);
    final double scaled = shortestSide * 0.45;
    if (scaled < 14.0) {
      return 14.0;
    }
    if (scaled > 40.0) {
      return 40.0;
    }
    return scaled;
  }

  /// Neutral themed fallback: person glyph for avatars, image glyph otherwise.
  Widget _buildFallback(BuildContext context) {
    final FlutterFlowTheme theme = FlutterFlowTheme.of(context);
    return Container(
      width: width,
      height: height,
      color: backgroundColor ?? theme.alternate,
      alignment: Alignment.center,
      child: Icon(
        fallbackIcon ??
            (isAvatar ? Icons.person_rounded : Icons.image_outlined),
        size: _glyphSize(),
        color: theme.secondaryText,
      ),
    );
  }

  /// Shimmer block occupying exactly the reserved box while the image loads.
  Widget _buildPlaceholder(BuildContext context) {
    return AppShimmerBox(
      width: width,
      height: height,
      shape: isAvatar ? BoxShape.circle : BoxShape.rectangle,
      borderRadius: isAvatar ? null : borderRadius,
    );
  }

  @override
  Widget build(BuildContext context) {
    final Widget content = _hasNoUrl
        ? _buildFallback(context)
        : CachedNetworkImage(
            imageUrl: url!.trim(),
            width: width,
            height: height,
            fit: fit,
            fadeInDuration: const Duration(milliseconds: 180),
            fadeOutDuration: const Duration(milliseconds: 120),
            placeholder: (BuildContext context, String _) =>
                _buildPlaceholder(context),
            errorWidget: (BuildContext context, String _, Object __) =>
                _buildFallback(context),
          );

    // SizedBox reserves the box before, during and after loading so the
    // surrounding layout never reflows when the image resolves.
    Widget result = SizedBox(
      width: width,
      height: height,
      child: ClipRRect(
        borderRadius: _resolveRadius(),
        child: content,
      ),
    );

    if (semanticLabel != null && semanticLabel!.isNotEmpty) {
      result = Semantics(
        image: true,
        label: semanticLabel,
        child: ExcludeSemantics(child: result),
      );
    }

    return result;
  }
}
