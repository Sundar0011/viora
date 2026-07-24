// async_state_view.dart
// Flock shared async-state wrapper. Replaces the four divergent loading
// treatments found across the app (shimmer / CircularProgressIndicator /
// ModernLoading / SimpleLoader) with ONE shimmer skeleton, and adds the designed
// ERROR state the app does not have anywhere today — CLAUDE.md §5 forbids
// silently swallowing failures (ui-review 2026-07-21 §2.7).
// Light + dark safe: every colour is a `FlutterFlowTheme` token.
import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '/flutter_flow/flutter_flow_theme.dart';
import 'app_shimmer_box.dart';
import 'empty_state.dart';

/// Wraps one async region and renders exactly one of: loading, error, empty, data.
///
/// Usage — with a FutureBuilder:
///   FutureBuilder<List<PostsRow>>(
///     future: _postsFuture,
///     builder: (context, snapshot) => AsyncStateView.fromSnapshot<List<PostsRow>>(
///       snapshot: snapshot,
///       onRetry: _reload,
///       emptyTitle: 'No posts yet',
///       emptyBody: 'Be the first to say hello to your neighbours.',
///       emptyIcon: Icons.forum_outlined,
///       builder: (context, posts) => _buildFeed(posts),
///     ),
///   )
///
/// Usage — with plain state fields:
///   AsyncStateView<List<GroupsRow>>(
///     isLoading: _loading,
///     error: _error,
///     data: _groups,
///     onRetry: _reload,
///     builder: (context, groups) => _buildList(groups),
///   )
class AsyncStateView<T> extends StatelessWidget {
  const AsyncStateView({
    super.key,
    required this.data,
    required this.builder,
    this.isLoading = false,
    this.error,
    this.onRetry,
    this.isEmpty,
    this.loadingBuilder,
    this.errorBuilder,
    this.emptyBuilder,
    this.emptyTitle = 'Nothing here yet',
    this.emptyBody,
    this.emptyIcon,
    this.emptyActionLabel,
    this.onEmptyAction,
    this.errorTitle = 'Something went wrong',
    this.errorMessage,
    this.retryLabel = 'Retry',
    this.skeletonItemCount = 5,
    this.skeletonHasAvatar = true,
    this.compact = false,
  });

  /// Loaded value. Null is treated as "empty".
  final T? data;

  /// Builds the success UI. Only called when data is present and not empty.
  final Widget Function(BuildContext context, T data) builder;

  /// True while the value is being fetched.
  final bool isLoading;

  /// Non-null when the fetch failed. Renders the error state.
  final Object? error;

  /// Retry callback. When null the error state shows no Retry button.
  final VoidCallback? onRetry;

  /// Custom emptiness test. Defaults to null / empty Iterable / Map / String.
  final bool Function(T data)? isEmpty;

  /// Custom loading UI. Defaults to the shared shimmer skeleton list.
  final WidgetBuilder? loadingBuilder;

  /// Custom error UI. Defaults to icon + message + Retry.
  final Widget Function(BuildContext context, Object error)? errorBuilder;

  /// Custom empty UI. Defaults to an [EmptyState] built from the empty* fields.
  final WidgetBuilder? emptyBuilder;

  /// Headline for the default empty state.
  final String emptyTitle;

  /// Supporting copy for the default empty state.
  final String? emptyBody;

  /// Glyph for the default empty state.
  final IconData? emptyIcon;

  /// Optional CTA label on the default empty state.
  final String? emptyActionLabel;

  /// Optional CTA callback on the default empty state.
  final VoidCallback? onEmptyAction;

  /// Headline for the default error state.
  final String errorTitle;

  /// Overrides the auto-derived, user-facing error sentence.
  final String? errorMessage;

  /// Label of the error-state retry button.
  final String retryLabel;

  /// How many skeleton rows the default loading state draws.
  final int skeletonItemCount;

  /// Whether skeleton rows include a leading circular avatar block.
  final bool skeletonHasAvatar;

  /// Tighter spacing for empty/error states inside cards or sheets.
  final bool compact;

  /// Decides whether the loaded value counts as "no content".
  bool _resolveEmpty() {
    final T? value = data;
    if (value == null) {
      return true;
    }
    if (isEmpty != null) {
      return isEmpty!(value);
    }
    if (value is Iterable) {
      return value.isEmpty;
    }
    if (value is Map) {
      return value.isEmpty;
    }
    if (value is String) {
      return value.trim().isEmpty;
    }
    return false;
  }

  /// Turns a raw exception into a short, non-technical sentence for the user.
  static String describeError(Object error) {
    if (kDebugMode) {
      // Never swallow the real failure — surface it in the debug console only.
      debugPrint('AsyncStateView error: $error');
    }
    if (error is SocketException) {
      return 'You appear to be offline. Check your connection and try again.';
    }
    if (error is TimeoutException) {
      return 'That took too long to load. Please try again.';
    }
    final String text = error.toString().toLowerCase();
    if (text.contains('failed host lookup') ||
        text.contains('socketexception') ||
        text.contains('network is unreachable') ||
        text.contains('connection closed') ||
        text.contains('connection refused')) {
      return 'You appear to be offline. Check your connection and try again.';
    }
    if (text.contains('timeout') || text.contains('timed out')) {
      return 'That took too long to load. Please try again.';
    }
    if (text.contains('permission') || text.contains('not authorized')) {
      return 'You do not have access to this content.';
    }
    return 'We could not load this right now. Please try again.';
  }

  /// Default loading UI: a shimmer skeleton list announced as "Loading".
  Widget _buildLoading(BuildContext context) {
    if (loadingBuilder != null) {
      return loadingBuilder!(context);
    }
    return Semantics(
      label: 'Loading',
      liveRegion: true,
      child: AppSkeletonList(
        itemCount: skeletonItemCount,
        hasAvatar: skeletonHasAvatar,
      ),
    );
  }

  /// Default error UI: themed glyph + friendly sentence + Retry button.
  Widget _buildError(BuildContext context, Object failure) {
    if (errorBuilder != null) {
      return errorBuilder!(context, failure);
    }
    final FlutterFlowTheme theme = FlutterFlowTheme.of(context);
    return EmptyState(
      icon: Icons.error_outline_rounded,
      iconColor: theme.error,
      iconBackgroundColor: theme.error.withAlpha(0x1F),
      title: errorTitle,
      body: errorMessage ?? describeError(failure),
      actionLabel: onRetry != null ? retryLabel : null,
      onAction: onRetry,
      compact: compact,
    );
  }

  /// Default empty UI: the shared [EmptyState] with the caller's copy.
  Widget _buildEmpty(BuildContext context) {
    if (emptyBuilder != null) {
      return emptyBuilder!(context);
    }
    return EmptyState(
      icon: emptyIcon,
      title: emptyTitle,
      body: emptyBody,
      actionLabel: emptyActionLabel,
      onAction: onEmptyAction,
      compact: compact,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return _buildLoading(context);
    }
    final Object? failure = error;
    if (failure != null) {
      return _buildError(context, failure);
    }
    if (_resolveEmpty()) {
      return _buildEmpty(context);
    }
    return builder(context, data as T);
  }

  /// Convenience factory that maps an [AsyncSnapshot] onto the four states.
  static AsyncStateView<S> fromSnapshot<S>({
    Key? key,
    required AsyncSnapshot<S> snapshot,
    required Widget Function(BuildContext context, S data) builder,
    VoidCallback? onRetry,
    bool Function(S data)? isEmpty,
    WidgetBuilder? loadingBuilder,
    Widget Function(BuildContext context, Object error)? errorBuilder,
    WidgetBuilder? emptyBuilder,
    String emptyTitle = 'Nothing here yet',
    String? emptyBody,
    IconData? emptyIcon,
    String? emptyActionLabel,
    VoidCallback? onEmptyAction,
    String errorTitle = 'Something went wrong',
    String? errorMessage,
    String retryLabel = 'Retry',
    int skeletonItemCount = 5,
    bool skeletonHasAvatar = true,
    bool compact = false,
  }) {
    return AsyncStateView<S>(
      key: key,
      data: snapshot.data,
      builder: builder,
      isLoading: snapshot.connectionState == ConnectionState.waiting &&
          !snapshot.hasData,
      error: snapshot.error,
      onRetry: onRetry,
      isEmpty: isEmpty,
      loadingBuilder: loadingBuilder,
      errorBuilder: errorBuilder,
      emptyBuilder: emptyBuilder,
      emptyTitle: emptyTitle,
      emptyBody: emptyBody,
      emptyIcon: emptyIcon,
      emptyActionLabel: emptyActionLabel,
      onEmptyAction: onEmptyAction,
      errorTitle: errorTitle,
      errorMessage: errorMessage,
      retryLabel: retryLabel,
      skeletonItemCount: skeletonItemCount,
      skeletonHasAvatar: skeletonHasAvatar,
      compact: compact,
    );
  }
}

/// The single app-wide loading treatment: stacked shimmer rows shaped like a
/// typical Flock list item (avatar + two text lines).
///
/// Public so screens that cannot adopt the full [AsyncStateView] (because their
/// state logic is not a single typed gate) can still render the SAME loading
/// treatment instead of falling back to a divergent spinner.
class AppSkeletonList extends StatelessWidget {
  const AppSkeletonList({
    super.key,
    this.itemCount = 5,
    this.hasAvatar = true,
  });

  /// Number of skeleton rows to draw.
  final int itemCount;

  /// Whether each row leads with a circular avatar block.
  final bool hasAvatar;

  @override
  Widget build(BuildContext context) {
    final FlutterFlowTheme theme = FlutterFlowTheme.of(context);
    final FFSpacing spacing = theme.designToken.spacing;
    final int rows = itemCount < 1 ? 1 : itemCount;

    return IgnorePointer(
      child: ListView.separated(
        padding: EdgeInsets.symmetric(
          horizontal: spacing.md,
          vertical: spacing.md,
        ),
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: rows,
        separatorBuilder: (BuildContext context, int index) =>
            SizedBox(height: spacing.md),
        itemBuilder: (BuildContext context, int index) => _SkeletonRow(
          hasAvatar: hasAvatar,
        ),
      ),
    );
  }
}

/// One skeleton row: optional avatar circle plus two shimmer text lines.
class _SkeletonRow extends StatelessWidget {
  const _SkeletonRow({required this.hasAvatar});

  /// Whether to draw the leading circular avatar block.
  final bool hasAvatar;

  @override
  Widget build(BuildContext context) {
    final FlutterFlowTheme theme = FlutterFlowTheme.of(context);
    final FFSpacing spacing = theme.designToken.spacing;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (hasAvatar) ...<Widget>[
          const AppShimmerBox(
            width: 40.0,
            height: 40.0,
            shape: BoxShape.circle,
          ),
          SizedBox(width: spacing.md),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const AppShimmerLine(widthFactor: 0.55, height: 14.0),
              SizedBox(height: spacing.sm),
              const AppShimmerLine(widthFactor: 0.9, height: 12.0),
              SizedBox(height: spacing.sm),
              const AppShimmerLine(widthFactor: 0.7, height: 12.0),
            ],
          ),
        ),
      ],
    );
  }
}
