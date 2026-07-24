import '/auth/supabase_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/backend/supabase/supabase.dart';
import '/components/app_icon_button.dart';
import '/components/app_network_image.dart';
import '/components/comp_no_data_found_widget.dart';
import '/components/empty_state.dart';
import '/components/comp_notification_widget.dart';
import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/custom_code/widgets/index.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/pages/components/comp_navbar/comp_navbar_widget.dart';
import 'dart:math';
import 'dart:ui';
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';
import 'dart:math' as math;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'notification_model.dart';
export 'notification_model.dart';

class NotificationWidget extends StatefulWidget {
  const NotificationWidget({super.key});

  static String routeName = 'Notification';
  static String routePath = 'notification';

  @override
  State<NotificationWidget> createState() => _NotificationWidgetState();
}

class _NotificationWidgetState extends State<NotificationWidget>
    with TickerProviderStateMixin {
  late NotificationModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  final animationsMap = <String, AnimationInfo>{};

  /// True when the last notification fetch failed, so the screen can show a
  /// real error state with a retry instead of a misleading empty state.
  bool _loadFailed = false;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => NotificationModel());

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      _model.opt = 'all';
      safeSetState(() {});
      await _refreshNotifications();
    });

    animationsMap.addAll({
      'containerOnPageLoadAnimation1': AnimationInfo(
        loop: true,
        trigger: AnimationTrigger.onPageLoad,
        effectsBuilder: () => [
          ShimmerEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            color: FlutterFlowTheme.of(context).shimmerHighlight,
            angle: 0.524,
          ),
        ],
      ),
      'containerOnPageLoadAnimation2': AnimationInfo(
        loop: true,
        trigger: AnimationTrigger.onPageLoad,
        effectsBuilder: () => [
          ShimmerEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            color: FlutterFlowTheme.of(context).shimmerHighlight,
            angle: 0.524,
          ),
        ],
      ),
      'containerOnPageLoadAnimation3': AnimationInfo(
        loop: true,
        trigger: AnimationTrigger.onPageLoad,
        effectsBuilder: () => [
          ShimmerEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            color: FlutterFlowTheme.of(context).shimmerHighlight,
            angle: 0.524,
          ),
        ],
      ),
    });
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  /// Re-fetches the notification feed. Used on page load and pull-to-refresh.
  /// A failed call raises [_loadFailed] instead of silently showing "nothing new".
  Future<void> _refreshNotifications() async {
    try {
      _model.notificationjson = await NotificationCall.call(
        token: currentJwtToken,
        pUserid: currentUserUid,
      );
      final bool succeeded = _model.notificationjson?.succeeded ?? false;
      if (succeeded) {
        FFAppState().notifications = (_model.notificationjson?.jsonBody ?? '');
      }
      _loadFailed = !succeeded;
    } catch (_) {
      _loadFailed = true;
    }
    _model.showData = true;
    safeSetState(() {});
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).white,
        body: SafeArea(
          top: true,
          bottom: true,
          child: Container(
            decoration: BoxDecoration(
              color: FlutterFlowTheme.of(context).pageBack,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: FlutterFlowTheme.of(context).secondaryBackground,
                  ),
                  child: Padding(
                    // 9 (not 12) because the Messages button's 44dp tap target
                    // is now the tallest child: 44 + 9 + 9 == 38 + 12 + 12, so
                    // the bar stays 62dp and every child keeps its exact y.
                    padding: EdgeInsetsDirectional.fromSTEB(0.0, 9.0, 0.0, 9.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        InkWell(
                          splashColor: FlutterFlowTheme.of(context)
                              .primary
                              .withAlpha(0x14),
                          focusColor: Colors.transparent,
                          hoverColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          onTap: () async {
                            HapticFeedback.lightImpact();
                            context.pushNamed(ProfileWidget.routeName);
                          },
                          // Shared top-bar avatar spec - keep in sync with
                          // home/community/sale. Was a plain ClipRRect with no
                          // gradient ring, which made this tab's header differ.
                          child: GradientAvatarRing(
                            diameter: 38.0,
                            ringWidth: 2.0,
                            child: AppNetworkImage(
                              url: FFAppState().AsProfilePicture,
                              fit: BoxFit.cover,
                              fallbackIcon: Icons.person_rounded,
                              semanticLabel: 'Your profile photo',
                            ),
                          ),
                        ),
                        Expanded(
                          child: InkWell(
                            splashColor: FlutterFlowTheme.of(context)
                                .primary
                                .withAlpha(0x14),
                            focusColor: Colors.transparent,
                            hoverColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            onTap: () async {
                              context.pushNamed(
                                SearchWidget.routeName,
                                queryParameters: {
                                  'searchName': serializeParam(
                                    '',
                                    ParamType.String,
                                  ),
                                }.withoutNulls,
                              );
                            },
                            child: Container(
                              height: 36.0,
                              decoration: BoxDecoration(
                                color: FlutterFlowTheme.of(context).alternate,
                                borderRadius: BorderRadius.circular(
                                    FlutterFlowTheme.of(context)
                                        .designToken
                                        .radius
                                        .md),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Icon(
                                    Icons.search,
                                    color: FlutterFlowTheme.of(context).greyL4,
                                    size: 20.0,
                                  ),
                                  Text(
                                    'Search',
                                    style: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          font: GoogleFonts.manrope(
                                            fontWeight: FontWeight.w500,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMedium
                                                    .fontStyle,
                                          ),
                                          color: FlutterFlowTheme.of(context)
                                              .greyL4,
                                          letterSpacing: 0.0,
                                          fontWeight: FontWeight.w500,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .bodyMedium
                                                  .fontStyle,
                                          lineHeight: 1.3,
                                        ),
                                  ),
                                ]
                                    .divide(SizedBox(width: 12.0))
                                    .addToStart(SizedBox(width: 12.0))
                                    .addToEnd(SizedBox(width: 12.0)),
                              ),
                            ),
                          ),
                        ),
                        AppIconButton(
                          semanticLabel: 'Messages',
                          tooltip: 'Messages',
                          onTap: () async {
                            context.pushNamed(
                              ChatWidget.routeName,
                              queryParameters: {
                                'selectMessage': serializeParam(
                                  false,
                                  ParamType.bool,
                                ),
                              }.withoutNulls,
                            );
                          },
                          // The 34dp grey disc is unchanged; AppIconButton only
                          // grows the invisible hit area out to 44dp.
                          iconWidget: Container(
                            width: 34.0,
                            height: 34.0,
                            decoration: BoxDecoration(
                              color: FlutterFlowTheme.of(context).greyL2,
                              shape: BoxShape.circle,
                            ),
                            alignment: AlignmentDirectional(0.0, 0.0),
                            child: Stack(
                              alignment: AlignmentDirectional(0.0, 0.0),
                              children: [
                                Icon(
                                  Icons.message_rounded,
                                  color:
                                      FlutterFlowTheme.of(context).primaryText,
                                  size: 18.0,
                                ),
                                if (('${getJsonField(
                                          FFAppState().matchedUsers,
                                          r'''$[0].total_unread_message_count''',
                                        ).toString()}' !=
                                        '0') &&
                                    ('${getJsonField(
                                          FFAppState().matchedUsers,
                                          r'''$''',
                                        ).toString()}' !=
                                        '[]'))
                                  Align(
                                    alignment: AlignmentDirectional(1.0, -1.0),
                                    child: Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          0.0, 5.0, 5.0, 0.0),
                                      child: Container(
                                        width: 10.0,
                                        height: 10.0,
                                        decoration: BoxDecoration(
                                          color: FlutterFlowTheme.of(context)
                                              .greyL2,
                                          borderRadius:
                                              BorderRadius.circular(24.0),
                                        ),
                                        alignment:
                                            AlignmentDirectional(0.0, 0.0),
                                        child: Container(
                                          width: 5.0,
                                          height: 5.0,
                                          decoration: BoxDecoration(
                                            color: FlutterFlowTheme.of(context)
                                                .primary,
                                            borderRadius:
                                                BorderRadius.circular(24.0),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ]
                          .divide(SizedBox(width: 10.0))
                          .addToStart(SizedBox(width: 20.0))
                          .addToEnd(SizedBox(width: 20.0)),
                    ),
                  ),
                ),
                Container(
                  width: double.infinity,
                  height: 48.0,
                  decoration: BoxDecoration(
                    color: FlutterFlowTheme.of(context).secondaryBackground,
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        FFButtonWidget(
                          onPressed: () async {
                            HapticFeedback.lightImpact();
                            _model.opt = 'all';
                            safeSetState(() {});
                          },
                          text: 'All',
                          options: FFButtonOptions(
                            height: 28.0,
                            padding: EdgeInsetsDirectional.fromSTEB(
                                16.0, 0.0, 16.0, 0.0),
                            iconPadding: EdgeInsetsDirectional.fromSTEB(
                                0.0, 0.0, 0.0, 0.0),
                            color: _model.opt == 'all'
                                ? FlutterFlowTheme.of(context).greenColor1
                                : FlutterFlowTheme.of(context).white,
                            textStyle: FlutterFlowTheme.of(context)
                                .labelMedium
                                .override(
                                  font: GoogleFonts.manrope(
                                    fontWeight: FlutterFlowTheme.of(context)
                                        .labelMedium
                                        .fontWeight,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .labelMedium
                                        .fontStyle,
                                  ),
                                  color: _model.opt == 'all'
                                      ? Colors.white
                                      : FlutterFlowTheme.of(context).greyL4,
                                  letterSpacing: 0.0,
                                  fontWeight: FlutterFlowTheme.of(context)
                                      .labelMedium
                                      .fontWeight,
                                  fontStyle: FlutterFlowTheme.of(context)
                                      .labelMedium
                                      .fontStyle,
                                ),
                            elevation: 0.0,
                            borderSide: BorderSide(
                              color: _model.opt != 'all'
                                  ? FlutterFlowTheme.of(context).greyL4
                                  : FlutterFlowTheme.of(context).greenColor2,
                              width: 1.0,
                            ),
                            borderRadius: BorderRadius.circular(24.0),
                          ),
                        ),
                        FFButtonWidget(
                          onPressed: () async {
                            HapticFeedback.lightImpact();
                            _model.opt = 'post';
                            safeSetState(() {});
                          },
                          text: 'Post',
                          options: FFButtonOptions(
                            height: 28.0,
                            padding: EdgeInsetsDirectional.fromSTEB(
                                16.0, 0.0, 16.0, 0.0),
                            iconPadding: EdgeInsetsDirectional.fromSTEB(
                                0.0, 0.0, 0.0, 0.0),
                            color: _model.opt == 'post'
                                ? FlutterFlowTheme.of(context).greenColor1
                                : FlutterFlowTheme.of(context).white,
                            textStyle: FlutterFlowTheme.of(context)
                                .labelMedium
                                .override(
                                  font: GoogleFonts.manrope(
                                    fontWeight: FlutterFlowTheme.of(context)
                                        .labelMedium
                                        .fontWeight,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .labelMedium
                                        .fontStyle,
                                  ),
                                  color: _model.opt == 'post'
                                      ? Colors.white
                                      : FlutterFlowTheme.of(context).greyL4,
                                  letterSpacing: 0.0,
                                  fontWeight: FlutterFlowTheme.of(context)
                                      .labelMedium
                                      .fontWeight,
                                  fontStyle: FlutterFlowTheme.of(context)
                                      .labelMedium
                                      .fontStyle,
                                ),
                            elevation: 0.0,
                            borderSide: BorderSide(
                              color: _model.opt != 'post'
                                  ? FlutterFlowTheme.of(context).greyL4
                                  : FlutterFlowTheme.of(context).greenColor2,
                              width: 1.0,
                            ),
                            borderRadius: BorderRadius.circular(24.0),
                          ),
                        ),
                        FFButtonWidget(
                          onPressed: () async {
                            HapticFeedback.lightImpact();
                            _model.opt = 'group';
                            safeSetState(() {});
                          },
                          text: 'Group',
                          options: FFButtonOptions(
                            height: 28.0,
                            padding: EdgeInsetsDirectional.fromSTEB(
                                16.0, 0.0, 16.0, 0.0),
                            iconPadding: EdgeInsetsDirectional.fromSTEB(
                                0.0, 0.0, 0.0, 0.0),
                            color: _model.opt == 'group'
                                ? FlutterFlowTheme.of(context).greenColor1
                                : FlutterFlowTheme.of(context).white,
                            textStyle: FlutterFlowTheme.of(context)
                                .labelMedium
                                .override(
                                  font: GoogleFonts.manrope(
                                    fontWeight: FlutterFlowTheme.of(context)
                                        .labelMedium
                                        .fontWeight,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .labelMedium
                                        .fontStyle,
                                  ),
                                  color: _model.opt == 'group'
                                      ? Colors.white
                                      : FlutterFlowTheme.of(context).greyL4,
                                  letterSpacing: 0.0,
                                  fontWeight: FlutterFlowTheme.of(context)
                                      .labelMedium
                                      .fontWeight,
                                  fontStyle: FlutterFlowTheme.of(context)
                                      .labelMedium
                                      .fontStyle,
                                ),
                            elevation: 0.0,
                            borderSide: BorderSide(
                              color: _model.opt != 'group'
                                  ? FlutterFlowTheme.of(context).greyL4
                                  : FlutterFlowTheme.of(context).greenColor2,
                              width: 1.0,
                            ),
                            borderRadius: BorderRadius.circular(24.0),
                          ),
                        ),
                        FFButtonWidget(
                          onPressed: () async {
                            HapticFeedback.lightImpact();
                            _model.opt = 'event';
                            safeSetState(() {});
                          },
                          text: 'Event',
                          options: FFButtonOptions(
                            height: 28.0,
                            padding: EdgeInsetsDirectional.fromSTEB(
                                16.0, 0.0, 16.0, 0.0),
                            iconPadding: EdgeInsetsDirectional.fromSTEB(
                                0.0, 0.0, 0.0, 0.0),
                            color: _model.opt == 'event'
                                ? FlutterFlowTheme.of(context).greenColor1
                                : FlutterFlowTheme.of(context).white,
                            textStyle: FlutterFlowTheme.of(context)
                                .labelMedium
                                .override(
                                  font: GoogleFonts.manrope(
                                    fontWeight: FlutterFlowTheme.of(context)
                                        .labelMedium
                                        .fontWeight,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .labelMedium
                                        .fontStyle,
                                  ),
                                  color: _model.opt == 'event'
                                      ? Colors.white
                                      : FlutterFlowTheme.of(context).greyL4,
                                  letterSpacing: 0.0,
                                  fontWeight: FlutterFlowTheme.of(context)
                                      .labelMedium
                                      .fontWeight,
                                  fontStyle: FlutterFlowTheme.of(context)
                                      .labelMedium
                                      .fontStyle,
                                ),
                            elevation: 0.0,
                            borderSide: BorderSide(
                              color: _model.opt != 'event'
                                  ? FlutterFlowTheme.of(context).greyL4
                                  : FlutterFlowTheme.of(context).greenColor2,
                              width: 1.0,
                            ),
                            borderRadius: BorderRadius.circular(24.0),
                          ),
                        ),
                        FFButtonWidget(
                          onPressed: () async {
                            HapticFeedback.lightImpact();
                            _model.opt = 'business';
                            safeSetState(() {});
                          },
                          text: 'Business',
                          options: FFButtonOptions(
                            height: 28.0,
                            padding: EdgeInsetsDirectional.fromSTEB(
                                16.0, 0.0, 16.0, 0.0),
                            iconPadding: EdgeInsetsDirectional.fromSTEB(
                                0.0, 0.0, 0.0, 0.0),
                            color: _model.opt == 'business'
                                ? FlutterFlowTheme.of(context).greenColor1
                                : FlutterFlowTheme.of(context).white,
                            textStyle: FlutterFlowTheme.of(context)
                                .labelMedium
                                .override(
                                  font: GoogleFonts.manrope(
                                    fontWeight: FlutterFlowTheme.of(context)
                                        .labelMedium
                                        .fontWeight,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .labelMedium
                                        .fontStyle,
                                  ),
                                  color: _model.opt == 'business'
                                      ? Colors.white
                                      : FlutterFlowTheme.of(context).greyL4,
                                  letterSpacing: 0.0,
                                  fontWeight: FlutterFlowTheme.of(context)
                                      .labelMedium
                                      .fontWeight,
                                  fontStyle: FlutterFlowTheme.of(context)
                                      .labelMedium
                                      .fontStyle,
                                ),
                            elevation: 0.0,
                            borderSide: BorderSide(
                              color: _model.opt != 'business'
                                  ? FlutterFlowTheme.of(context).greyL4
                                  : FlutterFlowTheme.of(context).greenColor2,
                              width: 1.0,
                            ),
                            borderRadius: BorderRadius.circular(24.0),
                          ),
                        ),
                        FFButtonWidget(
                          onPressed: () async {
                            HapticFeedback.lightImpact();
                            _model.opt = 'sale';
                            safeSetState(() {});
                          },
                          text: 'For sale or free',
                          options: FFButtonOptions(
                            height: 28.0,
                            padding: EdgeInsetsDirectional.fromSTEB(
                                16.0, 0.0, 16.0, 0.0),
                            iconPadding: EdgeInsetsDirectional.fromSTEB(
                                0.0, 0.0, 0.0, 0.0),
                            color: _model.opt == 'sale'
                                ? FlutterFlowTheme.of(context).greenColor1
                                : FlutterFlowTheme.of(context).white,
                            textStyle: FlutterFlowTheme.of(context)
                                .labelMedium
                                .override(
                                  font: GoogleFonts.manrope(
                                    fontWeight: FlutterFlowTheme.of(context)
                                        .labelMedium
                                        .fontWeight,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .labelMedium
                                        .fontStyle,
                                  ),
                                  color: _model.opt == 'sale'
                                      ? Colors.white
                                      : FlutterFlowTheme.of(context).greyL4,
                                  letterSpacing: 0.0,
                                  fontWeight: FlutterFlowTheme.of(context)
                                      .labelMedium
                                      .fontWeight,
                                  fontStyle: FlutterFlowTheme.of(context)
                                      .labelMedium
                                      .fontStyle,
                                ),
                            elevation: 0.0,
                            borderSide: BorderSide(
                              color: _model.opt != 'sale'
                                  ? FlutterFlowTheme.of(context).greyL4
                                  : FlutterFlowTheme.of(context).greenColor2,
                              width: 1.0,
                            ),
                            borderRadius: BorderRadius.circular(24.0),
                          ),
                        ),
                      ]
                          .divide(SizedBox(width: 8.0))
                          .addToStart(SizedBox(width: 20.0))
                          .addToEnd(SizedBox(width: 20.0)),
                    ),
                  ),
                ),
                if (_model.showData && _loadFailed)
                  Expanded(
                    child: EmptyState(
                      icon: Icons.wifi_off_rounded,
                      title: 'Couldn\'t load notifications',
                      body:
                          'Check your connection and try again — nothing has been lost.',
                      actionLabel: 'Try again',
                      onAction: () => _refreshNotifications(),
                    ),
                  ),
                if (_model.showData && !_loadFailed)
                  Expanded(
                    // Pull-to-refresh: "did something new arrive?" is the whole
                    // reason this screen gets opened.
                    child: RefreshIndicator(
                      onRefresh: _refreshNotifications,
                      color: FlutterFlowTheme.of(context).primary,
                      backgroundColor:
                          FlutterFlowTheme.of(context).secondaryBackground,
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          if (_model.opt == 'all')
                            Expanded(
                              child: SingleChildScrollView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Builder(
                                      builder: (context) {
                                        final all = getJsonField(
                                          FFAppState().notifications,
                                          r'''$.all''',
                                        ).toList();
                                        if (all.isEmpty) {
                                          return CompNoDataFoundWidget(
                                            pageName: 'no',
                                            text1: 'Nothing new yet',
                                            text2:
                                                'When neighbours react, invite or message you, it shows up here.',
                                          );
                                        }

                                        return ListView.builder(
                                          padding: EdgeInsets.zero,
                                          primary: false,
                                          shrinkWrap: true,
                                          scrollDirection: Axis.vertical,
                                          itemCount: all.length,
                                          itemBuilder: (context, allIndex) {
                                            final allItem = all[allIndex];
                                            return InkWell(
                                              splashColor:
                                                  FlutterFlowTheme.of(context)
                                                      .primary
                                                      .withAlpha(0x14),
                                              focusColor: Colors.transparent,
                                              hoverColor: Colors.transparent,
                                              highlightColor:
                                                  Colors.transparent,
                                              onTap: () async {
                                                if ('${getJsonField(
                                                      allItem,
                                                      r'''$.type''',
                                                    ).toString()}' ==
                                                    'post') {
                                                  context.pushNamed(
                                                    CommentsPageWidget
                                                        .routeName,
                                                    queryParameters: {
                                                      'postId': serializeParam(
                                                        getJsonField(
                                                          allItem,
                                                          r'''$.post_id''',
                                                        ).toString(),
                                                        ParamType.String,
                                                      ),
                                                    }.withoutNulls,
                                                  );

                                                  if ('${getJsonField(
                                                        allItem,
                                                        r'''$.is_read''',
                                                      ).toString()}' ==
                                                      'false') {
                                                    await NotificationsTable()
                                                        .update(
                                                      data: {
                                                        'is_read': true,
                                                      },
                                                      matchingRows: (rows) =>
                                                          rows
                                                              .eqOrNull(
                                                                'receiver_id',
                                                                currentUserUid,
                                                              )
                                                              .eqOrNull(
                                                                'id',
                                                                getJsonField(
                                                                  allItem,
                                                                  r'''$.id''',
                                                                ).toString(),
                                                              ),
                                                    );
                                                    _model.notificationjson1 =
                                                        await NotificationCall
                                                            .call(
                                                      token: currentJwtToken,
                                                      pUserid: currentUserUid,
                                                    );

                                                    FFAppState()
                                                        .notifications = (_model
                                                            .notificationjson1
                                                            ?.jsonBody ??
                                                        '');
                                                    _model.updatePage(() {});
                                                  }
                                                } else {
                                                  if ('${getJsonField(
                                                        allItem,
                                                        r'''$.type''',
                                                      ).toString()}' ==
                                                      'comment') {
                                                    context.pushNamed(
                                                      EventDetailsWidget
                                                          .routeName,
                                                      queryParameters: {
                                                        'eventId':
                                                            serializeParam(
                                                          getJsonField(
                                                            allItem,
                                                            r'''$.event_id''',
                                                          ).toString(),
                                                          ParamType.String,
                                                        ),
                                                      }.withoutNulls,
                                                    );

                                                    if ('${getJsonField(
                                                          allItem,
                                                          r'''$.is_read''',
                                                        ).toString()}' ==
                                                        'false') {
                                                      await NotificationsTable()
                                                          .update(
                                                        data: {
                                                          'is_read': true,
                                                        },
                                                        matchingRows: (rows) =>
                                                            rows
                                                                .eqOrNull(
                                                                  'receiver_id',
                                                                  currentUserUid,
                                                                )
                                                                .eqOrNull(
                                                                  'id',
                                                                  getJsonField(
                                                                    allItem,
                                                                    r'''$.id''',
                                                                  ).toString(),
                                                                ),
                                                      );
                                                      _model.notificationjson12 =
                                                          await NotificationCall
                                                              .call(
                                                        token: currentJwtToken,
                                                        pUserid: currentUserUid,
                                                      );

                                                      FFAppState()
                                                          .notifications = (_model
                                                              .notificationjson12
                                                              ?.jsonBody ??
                                                          '');
                                                      _model.updatePage(() {});
                                                    }
                                                  } else {
                                                    if ('${getJsonField(
                                                          allItem,
                                                          r'''$.type''',
                                                        ).toString()}' ==
                                                        'event') {
                                                      context.pushNamed(
                                                        MyEventWidget.routeName,
                                                        queryParameters: {
                                                          'btnOption':
                                                              serializeParam(
                                                            'invitations',
                                                            ParamType.String,
                                                          ),
                                                        }.withoutNulls,
                                                      );

                                                      if ('${getJsonField(
                                                            allItem,
                                                            r'''$.is_read''',
                                                          ).toString()}' ==
                                                          'false') {
                                                        await NotificationsTable()
                                                            .update(
                                                          data: {
                                                            'is_read': true,
                                                          },
                                                          matchingRows:
                                                              (rows) => rows
                                                                  .eqOrNull(
                                                                    'receiver_id',
                                                                    currentUserUid,
                                                                  )
                                                                  .eqOrNull(
                                                                    'id',
                                                                    getJsonField(
                                                                      allItem,
                                                                      r'''$.id''',
                                                                    ).toString(),
                                                                  ),
                                                        );
                                                        _model.notificationjson131 =
                                                            await NotificationCall
                                                                .call(
                                                          token:
                                                              currentJwtToken,
                                                          pUserid:
                                                              currentUserUid,
                                                        );

                                                        FFAppState()
                                                            .notifications = (_model
                                                                .notificationjson131
                                                                ?.jsonBody ??
                                                            '');
                                                        _model
                                                            .updatePage(() {});
                                                      }
                                                    } else {
                                                      if ('${getJsonField(
                                                            allItem,
                                                            r'''$.type''',
                                                          ).toString()}' ==
                                                          'business') {
                                                        context.pushNamed(
                                                          BusinessHomePageWidget
                                                              .routeName,
                                                          queryParameters: {
                                                            'businessId':
                                                                serializeParam(
                                                              getJsonField(
                                                                allItem,
                                                                r'''$.business_id''',
                                                              ).toString(),
                                                              ParamType.String,
                                                            ),
                                                          }.withoutNulls,
                                                        );

                                                        if ('${getJsonField(
                                                              allItem,
                                                              r'''$.is_read''',
                                                            ).toString()}' ==
                                                            'false') {
                                                          await NotificationsTable()
                                                              .update(
                                                            data: {
                                                              'is_read': true,
                                                            },
                                                            matchingRows:
                                                                (rows) => rows
                                                                    .eqOrNull(
                                                                      'receiver_id',
                                                                      currentUserUid,
                                                                    )
                                                                    .eqOrNull(
                                                                      'id',
                                                                      getJsonField(
                                                                        allItem,
                                                                        r'''$.id''',
                                                                      ).toString(),
                                                                    ),
                                                          );
                                                          _model.notificationjson132 =
                                                              await NotificationCall
                                                                  .call(
                                                            token:
                                                                currentJwtToken,
                                                            pUserid:
                                                                currentUserUid,
                                                          );

                                                          FFAppState()
                                                              .notifications = (_model
                                                                  .notificationjson132
                                                                  ?.jsonBody ??
                                                              '');
                                                          _model.updatePage(
                                                              () {});
                                                        }
                                                      } else {
                                                        if ('${getJsonField(
                                                              allItem,
                                                              r'''$.type''',
                                                            ).toString()}' ==
                                                            'sale') {
                                                          context.pushNamed(
                                                            SaleDetailsWidget
                                                                .routeName,
                                                            queryParameters: {
                                                              'saleId':
                                                                  serializeParam(
                                                                getJsonField(
                                                                  allItem,
                                                                  r'''$.sale_id''',
                                                                ).toString(),
                                                                ParamType
                                                                    .String,
                                                              ),
                                                            }.withoutNulls,
                                                          );

                                                          if ('${getJsonField(
                                                                allItem,
                                                                r'''$.is_read''',
                                                              ).toString()}' ==
                                                              'false') {
                                                            await NotificationsTable()
                                                                .update(
                                                              data: {
                                                                'is_read': true,
                                                              },
                                                              matchingRows:
                                                                  (rows) => rows
                                                                      .eqOrNull(
                                                                        'receiver_id',
                                                                        currentUserUid,
                                                                      )
                                                                      .eqOrNull(
                                                                        'id',
                                                                        getJsonField(
                                                                          allItem,
                                                                          r'''$.id''',
                                                                        ).toString(),
                                                                      ),
                                                            );
                                                            _model.notificationjson1113 =
                                                                await NotificationCall
                                                                    .call(
                                                              token:
                                                                  currentJwtToken,
                                                              pUserid:
                                                                  currentUserUid,
                                                            );

                                                            FFAppState()
                                                                .notifications = (_model
                                                                    .notificationjson1113
                                                                    ?.jsonBody ??
                                                                '');
                                                            _model.updatePage(
                                                                () {});
                                                          }
                                                        } else {
                                                          if ('${getJsonField(
                                                                allItem,
                                                                r'''$.type''',
                                                              ).toString()}' ==
                                                              'group') {
                                                            context.pushNamed(
                                                              GroupDetailsWidget
                                                                  .routeName,
                                                              queryParameters: {
                                                                'groupId':
                                                                    serializeParam(
                                                                  getJsonField(
                                                                    allItem,
                                                                    r'''$.group_id''',
                                                                  ).toString(),
                                                                  ParamType
                                                                      .String,
                                                                ),
                                                              }.withoutNulls,
                                                            );

                                                            if ('${getJsonField(
                                                                  allItem,
                                                                  r'''$.is_read''',
                                                                ).toString()}' ==
                                                                'false') {
                                                              await NotificationsTable()
                                                                  .update(
                                                                data: {
                                                                  'is_read':
                                                                      true,
                                                                },
                                                                matchingRows:
                                                                    (rows) => rows
                                                                        .eqOrNull(
                                                                          'receiver_id',
                                                                          currentUserUid,
                                                                        )
                                                                        .eqOrNull(
                                                                          'id',
                                                                          getJsonField(
                                                                            allItem,
                                                                            r'''$.id''',
                                                                          ).toString(),
                                                                        ),
                                                              );
                                                              _model.notificationjson1322 =
                                                                  await NotificationCall
                                                                      .call(
                                                                token:
                                                                    currentJwtToken,
                                                                pUserid:
                                                                    currentUserUid,
                                                              );

                                                              FFAppState()
                                                                  .notifications = (_model
                                                                      .notificationjson132
                                                                      ?.jsonBody ??
                                                                  '');
                                                              _model.updatePage(
                                                                  () {});
                                                            }
                                                          } else {
                                                            if ('${getJsonField(
                                                                  allItem,
                                                                  r'''$.type''',
                                                                ).toString()}' ==
                                                                'invite') {
                                                              context.pushNamed(
                                                                MyEventWidget
                                                                    .routeName,
                                                                queryParameters:
                                                                    {
                                                                  'btnOption':
                                                                      serializeParam(
                                                                    'invitations',
                                                                    ParamType
                                                                        .String,
                                                                  ),
                                                                }.withoutNulls,
                                                              );

                                                              if ('${getJsonField(
                                                                    allItem,
                                                                    r'''$.is_read''',
                                                                  ).toString()}' ==
                                                                  'false') {
                                                                await NotificationsTable()
                                                                    .update(
                                                                  data: {
                                                                    'is_read':
                                                                        true,
                                                                  },
                                                                  matchingRows:
                                                                      (rows) => rows
                                                                          .eqOrNull(
                                                                            'receiver_id',
                                                                            currentUserUid,
                                                                          )
                                                                          .eqOrNull(
                                                                            'id',
                                                                            getJsonField(
                                                                              allItem,
                                                                              r'''$.id''',
                                                                            ).toString(),
                                                                          ),
                                                                );
                                                                _model.notificationjson1332 =
                                                                    await NotificationCall
                                                                        .call(
                                                                  token:
                                                                      currentJwtToken,
                                                                  pUserid:
                                                                      currentUserUid,
                                                                );

                                                                FFAppState()
                                                                    .notifications = (_model
                                                                        .notificationjson1332
                                                                        ?.jsonBody ??
                                                                    '');
                                                                _model
                                                                    .updatePage(
                                                                        () {});
                                                              }
                                                            } else {
                                                              if ('${getJsonField(
                                                                    allItem,
                                                                    r'''$.type''',
                                                                  ).toString()}' ==
                                                                  'group_invite') {
                                                                context
                                                                    .pushNamed(
                                                                  MyGroupWidget
                                                                      .routeName,
                                                                  queryParameters:
                                                                      {
                                                                    'initialButton':
                                                                        serializeParam(
                                                                      'invitations',
                                                                      ParamType
                                                                          .String,
                                                                    ),
                                                                  }.withoutNulls,
                                                                );

                                                                if ('${getJsonField(
                                                                      allItem,
                                                                      r'''$.is_read''',
                                                                    ).toString()}' ==
                                                                    'false') {
                                                                  await NotificationsTable()
                                                                      .update(
                                                                    data: {
                                                                      'is_read':
                                                                          true,
                                                                    },
                                                                    matchingRows:
                                                                        (rows) => rows
                                                                            .eqOrNull(
                                                                              'receiver_id',
                                                                              currentUserUid,
                                                                            )
                                                                            .eqOrNull(
                                                                              'id',
                                                                              getJsonField(
                                                                                allItem,
                                                                                r'''$.id''',
                                                                              ).toString(),
                                                                            ),
                                                                  );
                                                                  _model.notificationjson100 =
                                                                      await NotificationCall
                                                                          .call(
                                                                    token:
                                                                        currentJwtToken,
                                                                    pUserid:
                                                                        currentUserUid,
                                                                  );

                                                                  FFAppState()
                                                                      .notifications = (_model
                                                                          .notificationjson100
                                                                          ?.jsonBody ??
                                                                      '');
                                                                  _model
                                                                      .updatePage(
                                                                          () {});
                                                                }
                                                              }
                                                            }
                                                          }
                                                        }
                                                      }
                                                    }
                                                  }
                                                }

                                                safeSetState(() {});
                                              },
                                              child: Container(
                                                width: double.infinity,
                                                margin: EdgeInsetsDirectional
                                                    .fromSTEB(
                                                        12.0, 6.0, 12.0, 6.0),
                                                decoration: BoxDecoration(
                                                  color: '${getJsonField(
                                                            allItem,
                                                            r'''$.is_read''',
                                                          ).toString()}' ==
                                                          'true'
                                                      ? FlutterFlowTheme.of(
                                                              context)
                                                          .secondaryBackground
                                                      : FlutterFlowTheme.of(
                                                              context)
                                                          .primaryL1,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          20.0),
                                                  boxShadow: [
                                                    FFShadows(
                                                            FlutterFlowTheme.of(
                                                                context))
                                                        .sm,
                                                  ],
                                                ),
                                                child: Padding(
                                                  // 4/4 (was 8/16): the options
                                                  // button's 44dp tap box now
                                                  // carries ~12dp of internal
                                                  // whitespace, so the row's
                                                  // breathing room comes from
                                                  // inside the button instead of
                                                  // from outer padding. Card
                                                  // lands at 68.8dp vs 64.0
                                                  // originally; the 12dp margin
                                                  // below still separates cards.
                                                  padding: EdgeInsetsDirectional
                                                      .fromSTEB(
                                                          20.0, 4.0, 20.0, 4.0),
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    children: [
                                                      AppNetworkImage(
                                                        url: getJsonField(
                                                          allItem,
                                                          r'''$.profile_image''',
                                                        ).toString(),
                                                        width: 40.0,
                                                        height: 40.0,
                                                        fit: BoxFit.cover,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(4.0),
                                                        fallbackIcon: Icons
                                                            .person_rounded,
                                                        semanticLabel:
                                                            'Profile photo of ${getJsonField(
                                                          allItem,
                                                          r'''$.name''',
                                                        ).toString()}',
                                                      ),
                                                      Expanded(
                                                        child: Wrap(
                                                          spacing: 0.0,
                                                          runSpacing: 0.0,
                                                          alignment:
                                                              WrapAlignment
                                                                  .start,
                                                          crossAxisAlignment:
                                                              WrapCrossAlignment
                                                                  .start,
                                                          direction:
                                                              Axis.horizontal,
                                                          runAlignment:
                                                              WrapAlignment
                                                                  .start,
                                                          verticalDirection:
                                                              VerticalDirection
                                                                  .down,
                                                          clipBehavior:
                                                              Clip.none,
                                                          children: [
                                                            RichText(
                                                              textScaler:
                                                                  MediaQuery.of(
                                                                          context)
                                                                      .textScaler,
                                                              text: TextSpan(
                                                                children: [
                                                                  TextSpan(
                                                                    text:
                                                                        getJsonField(
                                                                      allItem,
                                                                      r'''$.name''',
                                                                    ).toString(),
                                                                    style: FlutterFlowTheme.of(
                                                                            context)
                                                                        .bodyMedium
                                                                        .override(
                                                                          font:
                                                                              GoogleFonts.manrope(
                                                                            fontWeight:
                                                                                FontWeight.w500,
                                                                            fontStyle:
                                                                                FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                          ),
                                                                          color:
                                                                              FlutterFlowTheme.of(context).extraBlack,
                                                                          letterSpacing:
                                                                              0.0,
                                                                          fontWeight:
                                                                              FontWeight.w500,
                                                                          fontStyle: FlutterFlowTheme.of(context)
                                                                              .bodyMedium
                                                                              .fontStyle,
                                                                          lineHeight:
                                                                              1.3,
                                                                        ),
                                                                  ),
                                                                  TextSpan(
                                                                    text: ' ',
                                                                    style:
                                                                        TextStyle(),
                                                                  ),
                                                                  TextSpan(
                                                                    text:
                                                                        getJsonField(
                                                                      allItem,
                                                                      r'''$.content''',
                                                                    ).toString(),
                                                                    style: FlutterFlowTheme.of(
                                                                            context)
                                                                        .bodyMedium
                                                                        .override(
                                                                          font:
                                                                              GoogleFonts.manrope(
                                                                            fontWeight:
                                                                                FontWeight.w500,
                                                                            fontStyle:
                                                                                FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                          ),
                                                                          color:
                                                                              FlutterFlowTheme.of(context).greyL4,
                                                                          letterSpacing:
                                                                              0.0,
                                                                          fontWeight:
                                                                              FontWeight.w500,
                                                                          fontStyle: FlutterFlowTheme.of(context)
                                                                              .bodyMedium
                                                                              .fontStyle,
                                                                          lineHeight:
                                                                              1.3,
                                                                        ),
                                                                  ),
                                                                  TextSpan(
                                                                    text: ' ',
                                                                    style:
                                                                        TextStyle(),
                                                                  ),
                                                                  TextSpan(
                                                                    text: getJsonField(
                                                                              allItem,
                                                                              r'''$.message''',
                                                                            ) !=
                                                                            null
                                                                        ? getJsonField(
                                                                            allItem,
                                                                            r'''$.message''',
                                                                          ).toString()
                                                                        : ' ',
                                                                    style:
                                                                        TextStyle(
                                                                      color: FlutterFlowTheme.of(
                                                                              context)
                                                                          .extraBlack,
                                                                    ),
                                                                  )
                                                                ],
                                                                style: FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .override(
                                                                      font: GoogleFonts
                                                                          .manrope(
                                                                        fontWeight: FlutterFlowTheme.of(context)
                                                                            .bodyMedium
                                                                            .fontWeight,
                                                                        fontStyle: FlutterFlowTheme.of(context)
                                                                            .bodyMedium
                                                                            .fontStyle,
                                                                      ),
                                                                      letterSpacing:
                                                                          0.0,
                                                                      fontWeight: FlutterFlowTheme.of(
                                                                              context)
                                                                          .bodyMedium
                                                                          .fontWeight,
                                                                      fontStyle: FlutterFlowTheme.of(
                                                                              context)
                                                                          .bodyMedium
                                                                          .fontStyle,
                                                                    ),
                                                              ),
                                                            ),
                                                            if (false)
                                                              Text(
                                                                getJsonField(
                                                                  allItem,
                                                                  r'''$.message''',
                                                                ).toString(),
                                                                style: FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .override(
                                                                      font: GoogleFonts
                                                                          .manrope(
                                                                        fontWeight:
                                                                            FontWeight.w500,
                                                                        fontStyle: FlutterFlowTheme.of(context)
                                                                            .bodyMedium
                                                                            .fontStyle,
                                                                      ),
                                                                      color: FlutterFlowTheme.of(
                                                                              context)
                                                                          .extraBlack,
                                                                      letterSpacing:
                                                                          0.0,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500,
                                                                      fontStyle: FlutterFlowTheme.of(
                                                                              context)
                                                                          .bodyMedium
                                                                          .fontStyle,
                                                                      lineHeight:
                                                                          1.3,
                                                                    ),
                                                              ),
                                                          ],
                                                        ),
                                                      ),
                                                      Column(
                                                        mainAxisSize:
                                                            MainAxisSize.max,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .end,
                                                        children: [
                                                          Text(
                                                            functions
                                                                .getRelativeTime(
                                                                    getJsonField(
                                                              allItem,
                                                              r'''$.created_at''',
                                                            ).toString()),
                                                            style: FlutterFlowTheme
                                                                    .of(context)
                                                                .bodyMedium
                                                                .override(
                                                                  font: GoogleFonts
                                                                      .manrope(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                    fontStyle: FlutterFlowTheme.of(
                                                                            context)
                                                                        .bodyMedium
                                                                        .fontStyle,
                                                                  ),
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .greyL4,
                                                                  fontSize:
                                                                      12.0,
                                                                  letterSpacing:
                                                                      0.0,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  fontStyle: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMedium
                                                                      .fontStyle,
                                                                  lineHeight:
                                                                      1.4,
                                                                ),
                                                          ),
                                                          Transform.rotate(
                                                            angle: 90.0 *
                                                                (math.pi / 180),
                                                            child:
                                                                AppIconButton(
                                                              icon: Icons
                                                                  .keyboard_control,
                                                              iconSize: 20.0,
                                                              color: FlutterFlowTheme
                                                                      .of(context)
                                                                  .primaryText,
                                                              semanticLabel:
                                                                  'Notification options',
                                                              tooltip:
                                                                  'Notification options',
                                                              onTap: () async {
                                                                await showModalBottomSheet(
                                                                  isScrollControlled:
                                                                      true,
                                                                  backgroundColor:
                                                                      Colors
                                                                          .transparent,
                                                                  context:
                                                                      context,
                                                                  builder:
                                                                      (context) {
                                                                    return GestureDetector(
                                                                      onTap:
                                                                          () {
                                                                        FocusScope.of(context)
                                                                            .unfocus();
                                                                        FocusManager
                                                                            .instance
                                                                            .primaryFocus
                                                                            ?.unfocus();
                                                                      },
                                                                      child:
                                                                          Padding(
                                                                        padding:
                                                                            MediaQuery.viewInsetsOf(context),
                                                                        child:
                                                                            CompNotificationWidget(
                                                                          notificationId:
                                                                              getJsonField(
                                                                            allItem,
                                                                            r'''$.id''',
                                                                          ).toString(),
                                                                          isread:
                                                                              getJsonField(
                                                                            allItem,
                                                                            r'''$.is_read''',
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    );
                                                                  },
                                                                ).then((value) =>
                                                                    safeSetState(
                                                                        () {}));
                                                              },
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ].divide(
                                                        SizedBox(width: 8.0)),
                                                  ),
                                                ),
                                              ),
                                            )
                                                .animate()
                                                .fadeIn(
                                                    duration: 260.ms,
                                                    delay: (40 * (allIndex % 8))
                                                        .ms)
                                                .slideY(
                                                    begin: 0.06,
                                                    end: 0,
                                                    curve: Curves.easeOutCubic);
                                          },
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          if (_model.opt == 'post')
                            Expanded(
                              child: SingleChildScrollView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Builder(
                                      builder: (context) {
                                        final posts = getJsonField(
                                          FFAppState().notifications,
                                          r'''$.post''',
                                        ).toList();
                                        if (posts.isEmpty) {
                                          return CompNoDataFoundWidget(
                                            pageName: 'no',
                                            text1: 'Nothing new yet',
                                            text2:
                                                'When neighbours react, invite or message you, it shows up here.',
                                          );
                                        }

                                        return ListView.builder(
                                          padding: EdgeInsets.zero,
                                          primary: false,
                                          shrinkWrap: true,
                                          scrollDirection: Axis.vertical,
                                          itemCount: posts.length,
                                          itemBuilder: (context, postsIndex) {
                                            final postsItem = posts[postsIndex];
                                            return InkWell(
                                              splashColor:
                                                  FlutterFlowTheme.of(context)
                                                      .primary
                                                      .withAlpha(0x14),
                                              focusColor: Colors.transparent,
                                              hoverColor: Colors.transparent,
                                              highlightColor:
                                                  Colors.transparent,
                                              onTap: () async {
                                                context.pushNamed(
                                                  CommentsPageWidget.routeName,
                                                  queryParameters: {
                                                    'postId': serializeParam(
                                                      getJsonField(
                                                        postsItem,
                                                        r'''$.post_id''',
                                                      ).toString(),
                                                      ParamType.String,
                                                    ),
                                                  }.withoutNulls,
                                                );

                                                if ('${getJsonField(
                                                      postsItem,
                                                      r'''$.is_read''',
                                                    ).toString()}' ==
                                                    'false') {
                                                  await NotificationsTable()
                                                      .update(
                                                    data: {
                                                      'is_read': true,
                                                    },
                                                    matchingRows: (rows) => rows
                                                        .eqOrNull(
                                                          'receiver_id',
                                                          currentUserUid,
                                                        )
                                                        .eqOrNull(
                                                          'id',
                                                          getJsonField(
                                                            postsItem,
                                                            r'''$.id''',
                                                          ).toString(),
                                                        ),
                                                  );
                                                  _model.json1 =
                                                      await NotificationCall
                                                          .call(
                                                    token: currentJwtToken,
                                                    pUserid: currentUserUid,
                                                  );

                                                  FFAppState().notifications =
                                                      (_model.json1?.jsonBody ??
                                                          '');
                                                  _model.updatePage(() {});
                                                }

                                                safeSetState(() {});
                                              },
                                              child: Container(
                                                width: double.infinity,
                                                decoration: BoxDecoration(
                                                  color: '${getJsonField(
                                                            postsItem,
                                                            r'''$.is_read''',
                                                          ).toString()}' ==
                                                          'true'
                                                      ? FlutterFlowTheme.of(
                                                              context)
                                                          .white
                                                      : FlutterFlowTheme.of(
                                                              context)
                                                          .greayL1,
                                                  border: Border.all(
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .greyL2,
                                                    width: 1.0,
                                                  ),
                                                ),
                                                child: Padding(
                                                  // 6/8 (was 8/16). These five
                                                  // tabs are full-bleed rows
                                                  // with no margin, separated
                                                  // only by their 1dp border, so
                                                  // the padding IS the breathing
                                                  // room: 6/8 keeps a 16dp
                                                  // content gap between
                                                  // neighbours while the options
                                                  // button's 44dp box supplies
                                                  // the rest. Bottom stays
                                                  // heavier than top to keep the
                                                  // original vertical rhythm.
                                                  padding: EdgeInsetsDirectional
                                                      .fromSTEB(
                                                          20.0, 6.0, 20.0, 8.0),
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    children: [
                                                      AppNetworkImage(
                                                        url: getJsonField(
                                                          postsItem,
                                                          r'''$.profile_image''',
                                                        ).toString(),
                                                        width: 40.0,
                                                        height: 40.0,
                                                        fit: BoxFit.cover,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(4.0),
                                                        fallbackIcon: Icons
                                                            .person_rounded,
                                                        semanticLabel:
                                                            'Profile photo of ${getJsonField(
                                                          postsItem,
                                                          r'''$.name''',
                                                        ).toString()}',
                                                      ),
                                                      Expanded(
                                                        child: Wrap(
                                                          spacing: 0.0,
                                                          runSpacing: 0.0,
                                                          alignment:
                                                              WrapAlignment
                                                                  .start,
                                                          crossAxisAlignment:
                                                              WrapCrossAlignment
                                                                  .start,
                                                          direction:
                                                              Axis.horizontal,
                                                          runAlignment:
                                                              WrapAlignment
                                                                  .start,
                                                          verticalDirection:
                                                              VerticalDirection
                                                                  .down,
                                                          clipBehavior:
                                                              Clip.none,
                                                          children: [
                                                            RichText(
                                                              textScaler:
                                                                  MediaQuery.of(
                                                                          context)
                                                                      .textScaler,
                                                              text: TextSpan(
                                                                children: [
                                                                  TextSpan(
                                                                    text:
                                                                        getJsonField(
                                                                      postsItem,
                                                                      r'''$.name''',
                                                                    ).toString(),
                                                                    style: FlutterFlowTheme.of(
                                                                            context)
                                                                        .bodyMedium
                                                                        .override(
                                                                          font:
                                                                              GoogleFonts.manrope(
                                                                            fontWeight:
                                                                                FontWeight.w500,
                                                                            fontStyle:
                                                                                FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                          ),
                                                                          color:
                                                                              FlutterFlowTheme.of(context).extraBlack,
                                                                          letterSpacing:
                                                                              0.0,
                                                                          fontWeight:
                                                                              FontWeight.w500,
                                                                          fontStyle: FlutterFlowTheme.of(context)
                                                                              .bodyMedium
                                                                              .fontStyle,
                                                                          lineHeight:
                                                                              1.3,
                                                                        ),
                                                                  ),
                                                                  TextSpan(
                                                                    text: ' ',
                                                                    style:
                                                                        TextStyle(),
                                                                  ),
                                                                  TextSpan(
                                                                    text:
                                                                        getJsonField(
                                                                      postsItem,
                                                                      r'''$.content''',
                                                                    ).toString(),
                                                                    style: FlutterFlowTheme.of(
                                                                            context)
                                                                        .bodyMedium
                                                                        .override(
                                                                          font:
                                                                              GoogleFonts.manrope(
                                                                            fontWeight:
                                                                                FontWeight.w500,
                                                                            fontStyle:
                                                                                FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                          ),
                                                                          color:
                                                                              FlutterFlowTheme.of(context).greyL4,
                                                                          letterSpacing:
                                                                              0.0,
                                                                          fontWeight:
                                                                              FontWeight.w500,
                                                                          fontStyle: FlutterFlowTheme.of(context)
                                                                              .bodyMedium
                                                                              .fontStyle,
                                                                          lineHeight:
                                                                              1.3,
                                                                        ),
                                                                  )
                                                                ],
                                                                style: FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .override(
                                                                      font: GoogleFonts
                                                                          .manrope(
                                                                        fontWeight: FlutterFlowTheme.of(context)
                                                                            .bodyMedium
                                                                            .fontWeight,
                                                                        fontStyle: FlutterFlowTheme.of(context)
                                                                            .bodyMedium
                                                                            .fontStyle,
                                                                      ),
                                                                      letterSpacing:
                                                                          0.0,
                                                                      fontWeight: FlutterFlowTheme.of(
                                                                              context)
                                                                          .bodyMedium
                                                                          .fontWeight,
                                                                      fontStyle: FlutterFlowTheme.of(
                                                                              context)
                                                                          .bodyMedium
                                                                          .fontStyle,
                                                                    ),
                                                              ),
                                                            ),
                                                            if (getJsonField(
                                                                  postsItem,
                                                                  r'''$.message''',
                                                                ) !=
                                                                null)
                                                              Text(
                                                                getJsonField(
                                                                  postsItem,
                                                                  r'''$.message''',
                                                                ).toString(),
                                                                style: FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .override(
                                                                      font: GoogleFonts
                                                                          .manrope(
                                                                        fontWeight:
                                                                            FontWeight.w500,
                                                                        fontStyle: FlutterFlowTheme.of(context)
                                                                            .bodyMedium
                                                                            .fontStyle,
                                                                      ),
                                                                      color: FlutterFlowTheme.of(
                                                                              context)
                                                                          .extraBlack,
                                                                      letterSpacing:
                                                                          0.0,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500,
                                                                      fontStyle: FlutterFlowTheme.of(
                                                                              context)
                                                                          .bodyMedium
                                                                          .fontStyle,
                                                                      lineHeight:
                                                                          1.3,
                                                                    ),
                                                              ),
                                                          ],
                                                        ),
                                                      ),
                                                      Column(
                                                        mainAxisSize:
                                                            MainAxisSize.max,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .end,
                                                        children: [
                                                          Text(
                                                            functions.shortRelativeTime(
                                                                functions
                                                                    .returnRelativeTIme(
                                                                        getJsonField(
                                                              postsItem,
                                                              r'''$.created_at''',
                                                            ).toString())),
                                                            style: FlutterFlowTheme
                                                                    .of(context)
                                                                .bodyMedium
                                                                .override(
                                                                  font: GoogleFonts
                                                                      .manrope(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                    fontStyle: FlutterFlowTheme.of(
                                                                            context)
                                                                        .bodyMedium
                                                                        .fontStyle,
                                                                  ),
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .greyL4,
                                                                  fontSize:
                                                                      12.0,
                                                                  letterSpacing:
                                                                      0.0,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  fontStyle: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMedium
                                                                      .fontStyle,
                                                                  lineHeight:
                                                                      1.4,
                                                                ),
                                                          ),
                                                          Transform.rotate(
                                                            angle: 90.0 *
                                                                (math.pi / 180),
                                                            child:
                                                                AppIconButton(
                                                              icon: Icons
                                                                  .keyboard_control,
                                                              iconSize: 20.0,
                                                              color: FlutterFlowTheme
                                                                      .of(context)
                                                                  .primaryText,
                                                              semanticLabel:
                                                                  'Notification options',
                                                              tooltip:
                                                                  'Notification options',
                                                              onTap: () async {
                                                                await showModalBottomSheet(
                                                                  isScrollControlled:
                                                                      true,
                                                                  backgroundColor:
                                                                      Colors
                                                                          .transparent,
                                                                  context:
                                                                      context,
                                                                  builder:
                                                                      (context) {
                                                                    return GestureDetector(
                                                                      onTap:
                                                                          () {
                                                                        FocusScope.of(context)
                                                                            .unfocus();
                                                                        FocusManager
                                                                            .instance
                                                                            .primaryFocus
                                                                            ?.unfocus();
                                                                      },
                                                                      child:
                                                                          Padding(
                                                                        padding:
                                                                            MediaQuery.viewInsetsOf(context),
                                                                        child:
                                                                            CompNotificationWidget(
                                                                          notificationId:
                                                                              getJsonField(
                                                                            postsItem,
                                                                            r'''$.id''',
                                                                          ).toString(),
                                                                          isread:
                                                                              getJsonField(
                                                                            postsItem,
                                                                            r'''$.is_read''',
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    );
                                                                  },
                                                                ).then((value) =>
                                                                    safeSetState(
                                                                        () {}));
                                                              },
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ].divide(
                                                        SizedBox(width: 8.0)),
                                                  ),
                                                ),
                                              ),
                                            )
                                                .animate()
                                                .fadeIn(
                                                    duration: 260.ms,
                                                    delay:
                                                        (40 * (postsIndex % 8))
                                                            .ms)
                                                .slideY(
                                                    begin: 0.06,
                                                    end: 0,
                                                    curve: Curves.easeOutCubic);
                                          },
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          if (_model.opt == 'group')
                            Expanded(
                              child: SingleChildScrollView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Builder(
                                      builder: (context) {
                                        final group = getJsonField(
                                          FFAppState().notifications,
                                          r'''$.group''',
                                        ).toList();
                                        if (group.isEmpty) {
                                          return CompNoDataFoundWidget(
                                            pageName: 'no',
                                            text1: 'Nothing new yet',
                                            text2:
                                                'When neighbours react, invite or message you, it shows up here.',
                                          );
                                        }

                                        return ListView.builder(
                                          padding: EdgeInsets.zero,
                                          primary: false,
                                          shrinkWrap: true,
                                          scrollDirection: Axis.vertical,
                                          itemCount: group.length,
                                          itemBuilder: (context, groupIndex) {
                                            final groupItem = group[groupIndex];
                                            return InkWell(
                                              splashColor:
                                                  FlutterFlowTheme.of(context)
                                                      .primary
                                                      .withAlpha(0x14),
                                              focusColor: Colors.transparent,
                                              hoverColor: Colors.transparent,
                                              highlightColor:
                                                  Colors.transparent,
                                              onTap: () async {
                                                if ('${getJsonField(
                                                      groupItem,
                                                      r'''$.is_read''',
                                                    ).toString()}' ==
                                                    'false') {
                                                  await NotificationsTable()
                                                      .update(
                                                    data: {
                                                      'is_read': true,
                                                    },
                                                    matchingRows: (rows) => rows
                                                        .eqOrNull(
                                                          'receiver_id',
                                                          currentUserUid,
                                                        )
                                                        .eqOrNull(
                                                          'id',
                                                          getJsonField(
                                                            groupItem,
                                                            r'''$.id''',
                                                          ).toString(),
                                                        ),
                                                  );
                                                  _model.json5 =
                                                      await NotificationCall
                                                          .call(
                                                    token: currentJwtToken,
                                                    pUserid: currentUserUid,
                                                  );

                                                  FFAppState().notifications =
                                                      (_model.json5?.jsonBody ??
                                                          '');
                                                  _model.updatePage(() {});
                                                }

                                                context.pushNamed(
                                                  GroupDetailsWidget.routeName,
                                                  queryParameters: {
                                                    'groupId': serializeParam(
                                                      getJsonField(
                                                        groupItem,
                                                        r'''$.group_id''',
                                                      ).toString(),
                                                      ParamType.String,
                                                    ),
                                                  }.withoutNulls,
                                                );

                                                safeSetState(() {});
                                              },
                                              child: Container(
                                                width: double.infinity,
                                                decoration: BoxDecoration(
                                                  color: '${getJsonField(
                                                            groupItem,
                                                            r'''$.is_read''',
                                                          ).toString()}' ==
                                                          'true'
                                                      ? FlutterFlowTheme.of(
                                                              context)
                                                          .white
                                                      : FlutterFlowTheme.of(
                                                              context)
                                                          .greayL1,
                                                  border: Border.all(
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .greyL2,
                                                    width: 1.0,
                                                  ),
                                                ),
                                                child: Padding(
                                                  // 6/8 (was 8/16). These five
                                                  // tabs are full-bleed rows
                                                  // with no margin, separated
                                                  // only by their 1dp border, so
                                                  // the padding IS the breathing
                                                  // room: 6/8 keeps a 16dp
                                                  // content gap between
                                                  // neighbours while the options
                                                  // button's 44dp box supplies
                                                  // the rest. Bottom stays
                                                  // heavier than top to keep the
                                                  // original vertical rhythm.
                                                  padding: EdgeInsetsDirectional
                                                      .fromSTEB(
                                                          20.0, 6.0, 20.0, 8.0),
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    children: [
                                                      AppNetworkImage(
                                                        url: getJsonField(
                                                          groupItem,
                                                          r'''$.profile_image''',
                                                        ).toString(),
                                                        width: 40.0,
                                                        height: 40.0,
                                                        fit: BoxFit.cover,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(4.0),
                                                        fallbackIcon: Icons
                                                            .person_rounded,
                                                        semanticLabel:
                                                            'Profile photo of ${getJsonField(
                                                          groupItem,
                                                          r'''$.name''',
                                                        ).toString()}',
                                                      ),
                                                      Expanded(
                                                        child: Wrap(
                                                          spacing: 0.0,
                                                          runSpacing: 0.0,
                                                          alignment:
                                                              WrapAlignment
                                                                  .start,
                                                          crossAxisAlignment:
                                                              WrapCrossAlignment
                                                                  .start,
                                                          direction:
                                                              Axis.horizontal,
                                                          runAlignment:
                                                              WrapAlignment
                                                                  .start,
                                                          verticalDirection:
                                                              VerticalDirection
                                                                  .down,
                                                          clipBehavior:
                                                              Clip.none,
                                                          children: [
                                                            RichText(
                                                              textScaler:
                                                                  MediaQuery.of(
                                                                          context)
                                                                      .textScaler,
                                                              text: TextSpan(
                                                                children: [
                                                                  TextSpan(
                                                                    text:
                                                                        getJsonField(
                                                                      groupItem,
                                                                      r'''$.name''',
                                                                    ).toString(),
                                                                    style: FlutterFlowTheme.of(
                                                                            context)
                                                                        .bodyMedium
                                                                        .override(
                                                                          font:
                                                                              GoogleFonts.manrope(
                                                                            fontWeight:
                                                                                FontWeight.w500,
                                                                            fontStyle:
                                                                                FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                          ),
                                                                          color:
                                                                              FlutterFlowTheme.of(context).extraBlack,
                                                                          letterSpacing:
                                                                              0.0,
                                                                          fontWeight:
                                                                              FontWeight.w500,
                                                                          fontStyle: FlutterFlowTheme.of(context)
                                                                              .bodyMedium
                                                                              .fontStyle,
                                                                          lineHeight:
                                                                              1.3,
                                                                        ),
                                                                  ),
                                                                  TextSpan(
                                                                    text: ' ',
                                                                    style:
                                                                        TextStyle(),
                                                                  ),
                                                                  TextSpan(
                                                                    text:
                                                                        getJsonField(
                                                                      groupItem,
                                                                      r'''$.content''',
                                                                    ).toString(),
                                                                    style: FlutterFlowTheme.of(
                                                                            context)
                                                                        .bodyMedium
                                                                        .override(
                                                                          font:
                                                                              GoogleFonts.manrope(
                                                                            fontWeight:
                                                                                FontWeight.w500,
                                                                            fontStyle:
                                                                                FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                          ),
                                                                          color:
                                                                              FlutterFlowTheme.of(context).greyL4,
                                                                          letterSpacing:
                                                                              0.0,
                                                                          fontWeight:
                                                                              FontWeight.w500,
                                                                          fontStyle: FlutterFlowTheme.of(context)
                                                                              .bodyMedium
                                                                              .fontStyle,
                                                                          lineHeight:
                                                                              1.3,
                                                                        ),
                                                                  )
                                                                ],
                                                                style: FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .override(
                                                                      font: GoogleFonts
                                                                          .manrope(
                                                                        fontWeight: FlutterFlowTheme.of(context)
                                                                            .bodyMedium
                                                                            .fontWeight,
                                                                        fontStyle: FlutterFlowTheme.of(context)
                                                                            .bodyMedium
                                                                            .fontStyle,
                                                                      ),
                                                                      letterSpacing:
                                                                          0.0,
                                                                      fontWeight: FlutterFlowTheme.of(
                                                                              context)
                                                                          .bodyMedium
                                                                          .fontWeight,
                                                                      fontStyle: FlutterFlowTheme.of(
                                                                              context)
                                                                          .bodyMedium
                                                                          .fontStyle,
                                                                    ),
                                                              ),
                                                            ),
                                                            if (getJsonField(
                                                                  groupItem,
                                                                  r'''$.message''',
                                                                ) !=
                                                                null)
                                                              Text(
                                                                getJsonField(
                                                                  groupItem,
                                                                  r'''$.message''',
                                                                ).toString(),
                                                                style: FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .override(
                                                                      font: GoogleFonts
                                                                          .manrope(
                                                                        fontWeight:
                                                                            FontWeight.w500,
                                                                        fontStyle: FlutterFlowTheme.of(context)
                                                                            .bodyMedium
                                                                            .fontStyle,
                                                                      ),
                                                                      color: FlutterFlowTheme.of(
                                                                              context)
                                                                          .extraBlack,
                                                                      letterSpacing:
                                                                          0.0,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500,
                                                                      fontStyle: FlutterFlowTheme.of(
                                                                              context)
                                                                          .bodyMedium
                                                                          .fontStyle,
                                                                      lineHeight:
                                                                          1.3,
                                                                    ),
                                                              ),
                                                          ],
                                                        ),
                                                      ),
                                                      Column(
                                                        mainAxisSize:
                                                            MainAxisSize.max,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .end,
                                                        children: [
                                                          Text(
                                                            functions.shortRelativeTime(
                                                                functions
                                                                    .returnRelativeTIme(
                                                                        getJsonField(
                                                              groupItem,
                                                              r'''$.created_at''',
                                                            ).toString())),
                                                            style: FlutterFlowTheme
                                                                    .of(context)
                                                                .bodyMedium
                                                                .override(
                                                                  font: GoogleFonts
                                                                      .manrope(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                    fontStyle: FlutterFlowTheme.of(
                                                                            context)
                                                                        .bodyMedium
                                                                        .fontStyle,
                                                                  ),
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .greyL4,
                                                                  fontSize:
                                                                      12.0,
                                                                  letterSpacing:
                                                                      0.0,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  fontStyle: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMedium
                                                                      .fontStyle,
                                                                  lineHeight:
                                                                      1.4,
                                                                ),
                                                          ),
                                                          Transform.rotate(
                                                            angle: 90.0 *
                                                                (math.pi / 180),
                                                            child:
                                                                AppIconButton(
                                                              icon: Icons
                                                                  .keyboard_control,
                                                              iconSize: 20.0,
                                                              color: FlutterFlowTheme
                                                                      .of(context)
                                                                  .primaryText,
                                                              semanticLabel:
                                                                  'Notification options',
                                                              tooltip:
                                                                  'Notification options',
                                                              onTap: () async {
                                                                await showModalBottomSheet(
                                                                  isScrollControlled:
                                                                      true,
                                                                  backgroundColor:
                                                                      Colors
                                                                          .transparent,
                                                                  context:
                                                                      context,
                                                                  builder:
                                                                      (context) {
                                                                    return GestureDetector(
                                                                      onTap:
                                                                          () {
                                                                        FocusScope.of(context)
                                                                            .unfocus();
                                                                        FocusManager
                                                                            .instance
                                                                            .primaryFocus
                                                                            ?.unfocus();
                                                                      },
                                                                      child:
                                                                          Padding(
                                                                        padding:
                                                                            MediaQuery.viewInsetsOf(context),
                                                                        child:
                                                                            CompNotificationWidget(
                                                                          notificationId:
                                                                              getJsonField(
                                                                            groupItem,
                                                                            r'''$.id''',
                                                                          ).toString(),
                                                                          isread:
                                                                              getJsonField(
                                                                            groupItem,
                                                                            r'''$.is_read''',
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    );
                                                                  },
                                                                ).then((value) =>
                                                                    safeSetState(
                                                                        () {}));
                                                              },
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ].divide(
                                                        SizedBox(width: 8.0)),
                                                  ),
                                                ),
                                              ),
                                            )
                                                .animate()
                                                .fadeIn(
                                                    duration: 260.ms,
                                                    delay:
                                                        (40 * (groupIndex % 8))
                                                            .ms)
                                                .slideY(
                                                    begin: 0.06,
                                                    end: 0,
                                                    curve: Curves.easeOutCubic);
                                          },
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          if (_model.opt == 'event')
                            Expanded(
                              child: SingleChildScrollView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Builder(
                                      builder: (context) {
                                        final events = getJsonField(
                                          FFAppState().notifications,
                                          r'''$.event''',
                                        ).toList();
                                        if (events.isEmpty) {
                                          return CompNoDataFoundWidget(
                                            pageName: 'no',
                                            text1: 'Nothing new yet',
                                            text2:
                                                'When neighbours react, invite or message you, it shows up here.',
                                          );
                                        }

                                        return ListView.builder(
                                          padding: EdgeInsets.zero,
                                          primary: false,
                                          shrinkWrap: true,
                                          scrollDirection: Axis.vertical,
                                          itemCount: events.length,
                                          itemBuilder: (context, eventsIndex) {
                                            final eventsItem =
                                                events[eventsIndex];
                                            return InkWell(
                                              splashColor:
                                                  FlutterFlowTheme.of(context)
                                                      .primary
                                                      .withAlpha(0x14),
                                              focusColor: Colors.transparent,
                                              hoverColor: Colors.transparent,
                                              highlightColor:
                                                  Colors.transparent,
                                              onTap: () async {
                                                if ('${getJsonField(
                                                      eventsItem,
                                                      r'''$.type''',
                                                    ).toString()}' ==
                                                    'event') {
                                                  context.pushNamed(
                                                    EventDetailsWidget
                                                        .routeName,
                                                    queryParameters: {
                                                      'eventId': serializeParam(
                                                        getJsonField(
                                                          eventsItem,
                                                          r'''$.event_id''',
                                                        ).toString(),
                                                        ParamType.String,
                                                      ),
                                                    }.withoutNulls,
                                                  );
                                                } else {
                                                  context.pushNamed(
                                                    MyEventWidget.routeName,
                                                    queryParameters: {
                                                      'btnOption':
                                                          serializeParam(
                                                        'invitations',
                                                        ParamType.String,
                                                      ),
                                                    }.withoutNulls,
                                                  );
                                                }

                                                if ('${getJsonField(
                                                      eventsItem,
                                                      r'''$.is_read''',
                                                    ).toString()}' ==
                                                    'false') {
                                                  await NotificationsTable()
                                                      .update(
                                                    data: {
                                                      'is_read': true,
                                                    },
                                                    matchingRows: (rows) => rows
                                                        .eqOrNull(
                                                          'receiver_id',
                                                          currentUserUid,
                                                        )
                                                        .eqOrNull(
                                                          'id',
                                                          getJsonField(
                                                            eventsItem,
                                                            r'''$.id''',
                                                          ).toString(),
                                                        ),
                                                  );
                                                  _model.json4 =
                                                      await NotificationCall
                                                          .call(
                                                    token: currentJwtToken,
                                                    pUserid: currentUserUid,
                                                  );

                                                  FFAppState().notifications =
                                                      (_model.json4?.jsonBody ??
                                                          '');
                                                  _model.updatePage(() {});
                                                }

                                                safeSetState(() {});
                                              },
                                              child: Container(
                                                width: double.infinity,
                                                decoration: BoxDecoration(
                                                  color: '${getJsonField(
                                                            eventsItem,
                                                            r'''$.is_read''',
                                                          ).toString()}' ==
                                                          'true'
                                                      ? FlutterFlowTheme.of(
                                                              context)
                                                          .white
                                                      : FlutterFlowTheme.of(
                                                              context)
                                                          .greayL1,
                                                  border: Border.all(
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .greyL2,
                                                    width: 1.0,
                                                  ),
                                                ),
                                                child: Padding(
                                                  // 6/8 (was 8/16). These five
                                                  // tabs are full-bleed rows
                                                  // with no margin, separated
                                                  // only by their 1dp border, so
                                                  // the padding IS the breathing
                                                  // room: 6/8 keeps a 16dp
                                                  // content gap between
                                                  // neighbours while the options
                                                  // button's 44dp box supplies
                                                  // the rest. Bottom stays
                                                  // heavier than top to keep the
                                                  // original vertical rhythm.
                                                  padding: EdgeInsetsDirectional
                                                      .fromSTEB(
                                                          20.0, 6.0, 20.0, 8.0),
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    children: [
                                                      AppNetworkImage(
                                                        url: getJsonField(
                                                          eventsItem,
                                                          r'''$.profile_image''',
                                                        ).toString(),
                                                        width: 40.0,
                                                        height: 40.0,
                                                        fit: BoxFit.cover,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(4.0),
                                                        fallbackIcon: Icons
                                                            .person_rounded,
                                                        semanticLabel:
                                                            'Profile photo of ${getJsonField(
                                                          eventsItem,
                                                          r'''$.name''',
                                                        ).toString()}',
                                                      ),
                                                      Expanded(
                                                        child: Wrap(
                                                          spacing: 0.0,
                                                          runSpacing: 0.0,
                                                          alignment:
                                                              WrapAlignment
                                                                  .start,
                                                          crossAxisAlignment:
                                                              WrapCrossAlignment
                                                                  .start,
                                                          direction:
                                                              Axis.horizontal,
                                                          runAlignment:
                                                              WrapAlignment
                                                                  .start,
                                                          verticalDirection:
                                                              VerticalDirection
                                                                  .down,
                                                          clipBehavior:
                                                              Clip.none,
                                                          children: [
                                                            RichText(
                                                              textScaler:
                                                                  MediaQuery.of(
                                                                          context)
                                                                      .textScaler,
                                                              text: TextSpan(
                                                                children: [
                                                                  TextSpan(
                                                                    text:
                                                                        getJsonField(
                                                                      eventsItem,
                                                                      r'''$.name''',
                                                                    ).toString(),
                                                                    style: FlutterFlowTheme.of(
                                                                            context)
                                                                        .bodyMedium
                                                                        .override(
                                                                          font:
                                                                              GoogleFonts.manrope(
                                                                            fontWeight:
                                                                                FontWeight.w500,
                                                                            fontStyle:
                                                                                FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                          ),
                                                                          color:
                                                                              FlutterFlowTheme.of(context).extraBlack,
                                                                          letterSpacing:
                                                                              0.0,
                                                                          fontWeight:
                                                                              FontWeight.w500,
                                                                          fontStyle: FlutterFlowTheme.of(context)
                                                                              .bodyMedium
                                                                              .fontStyle,
                                                                          lineHeight:
                                                                              1.3,
                                                                        ),
                                                                  ),
                                                                  TextSpan(
                                                                    text: ' ',
                                                                    style:
                                                                        TextStyle(),
                                                                  ),
                                                                  TextSpan(
                                                                    text:
                                                                        getJsonField(
                                                                      eventsItem,
                                                                      r'''$.content''',
                                                                    ).toString(),
                                                                    style: FlutterFlowTheme.of(
                                                                            context)
                                                                        .bodyMedium
                                                                        .override(
                                                                          font:
                                                                              GoogleFonts.manrope(
                                                                            fontWeight:
                                                                                FontWeight.w500,
                                                                            fontStyle:
                                                                                FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                          ),
                                                                          color:
                                                                              FlutterFlowTheme.of(context).greyL4,
                                                                          letterSpacing:
                                                                              0.0,
                                                                          fontWeight:
                                                                              FontWeight.w500,
                                                                          fontStyle: FlutterFlowTheme.of(context)
                                                                              .bodyMedium
                                                                              .fontStyle,
                                                                          lineHeight:
                                                                              1.3,
                                                                        ),
                                                                  )
                                                                ],
                                                                style: FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .override(
                                                                      font: GoogleFonts
                                                                          .manrope(
                                                                        fontWeight: FlutterFlowTheme.of(context)
                                                                            .bodyMedium
                                                                            .fontWeight,
                                                                        fontStyle: FlutterFlowTheme.of(context)
                                                                            .bodyMedium
                                                                            .fontStyle,
                                                                      ),
                                                                      letterSpacing:
                                                                          0.0,
                                                                      fontWeight: FlutterFlowTheme.of(
                                                                              context)
                                                                          .bodyMedium
                                                                          .fontWeight,
                                                                      fontStyle: FlutterFlowTheme.of(
                                                                              context)
                                                                          .bodyMedium
                                                                          .fontStyle,
                                                                    ),
                                                              ),
                                                            ),
                                                            if (getJsonField(
                                                                  eventsItem,
                                                                  r'''$.message''',
                                                                ) !=
                                                                null)
                                                              Text(
                                                                getJsonField(
                                                                  eventsItem,
                                                                  r'''$.message''',
                                                                ).toString(),
                                                                style: FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .override(
                                                                      font: GoogleFonts
                                                                          .manrope(
                                                                        fontWeight:
                                                                            FontWeight.w500,
                                                                        fontStyle: FlutterFlowTheme.of(context)
                                                                            .bodyMedium
                                                                            .fontStyle,
                                                                      ),
                                                                      color: FlutterFlowTheme.of(
                                                                              context)
                                                                          .extraBlack,
                                                                      letterSpacing:
                                                                          0.0,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500,
                                                                      fontStyle: FlutterFlowTheme.of(
                                                                              context)
                                                                          .bodyMedium
                                                                          .fontStyle,
                                                                      lineHeight:
                                                                          1.3,
                                                                    ),
                                                              ),
                                                          ],
                                                        ),
                                                      ),
                                                      Column(
                                                        mainAxisSize:
                                                            MainAxisSize.max,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .end,
                                                        children: [
                                                          Text(
                                                            functions.shortRelativeTime(
                                                                functions
                                                                    .returnRelativeTIme(
                                                                        getJsonField(
                                                              eventsItem,
                                                              r'''$.created_at''',
                                                            ).toString())),
                                                            style: FlutterFlowTheme
                                                                    .of(context)
                                                                .bodyMedium
                                                                .override(
                                                                  font: GoogleFonts
                                                                      .manrope(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                    fontStyle: FlutterFlowTheme.of(
                                                                            context)
                                                                        .bodyMedium
                                                                        .fontStyle,
                                                                  ),
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .greyL4,
                                                                  fontSize:
                                                                      12.0,
                                                                  letterSpacing:
                                                                      0.0,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  fontStyle: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMedium
                                                                      .fontStyle,
                                                                  lineHeight:
                                                                      1.4,
                                                                ),
                                                          ),
                                                          Transform.rotate(
                                                            angle: 90.0 *
                                                                (math.pi / 180),
                                                            child:
                                                                AppIconButton(
                                                              icon: Icons
                                                                  .keyboard_control,
                                                              iconSize: 20.0,
                                                              color: FlutterFlowTheme
                                                                      .of(context)
                                                                  .primaryText,
                                                              semanticLabel:
                                                                  'Notification options',
                                                              tooltip:
                                                                  'Notification options',
                                                              onTap: () async {
                                                                await showModalBottomSheet(
                                                                  isScrollControlled:
                                                                      true,
                                                                  backgroundColor:
                                                                      Colors
                                                                          .transparent,
                                                                  context:
                                                                      context,
                                                                  builder:
                                                                      (context) {
                                                                    return GestureDetector(
                                                                      onTap:
                                                                          () {
                                                                        FocusScope.of(context)
                                                                            .unfocus();
                                                                        FocusManager
                                                                            .instance
                                                                            .primaryFocus
                                                                            ?.unfocus();
                                                                      },
                                                                      child:
                                                                          Padding(
                                                                        padding:
                                                                            MediaQuery.viewInsetsOf(context),
                                                                        child:
                                                                            CompNotificationWidget(
                                                                          notificationId:
                                                                              getJsonField(
                                                                            eventsItem,
                                                                            r'''$.id''',
                                                                          ).toString(),
                                                                          isread:
                                                                              getJsonField(
                                                                            eventsItem,
                                                                            r'''$.is_read''',
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    );
                                                                  },
                                                                ).then((value) =>
                                                                    safeSetState(
                                                                        () {}));
                                                              },
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ].divide(
                                                        SizedBox(width: 8.0)),
                                                  ),
                                                ),
                                              ),
                                            )
                                                .animate()
                                                .fadeIn(
                                                    duration: 260.ms,
                                                    delay:
                                                        (40 * (eventsIndex % 8))
                                                            .ms)
                                                .slideY(
                                                    begin: 0.06,
                                                    end: 0,
                                                    curve: Curves.easeOutCubic);
                                          },
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          if (_model.opt == 'business')
                            Expanded(
                              child: SingleChildScrollView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Builder(
                                      builder: (context) {
                                        final business = getJsonField(
                                          FFAppState().notifications,
                                          r'''$.business''',
                                        ).toList();
                                        if (business.isEmpty) {
                                          return CompNoDataFoundWidget(
                                            pageName: 'no',
                                            text1: 'Nothing new yet',
                                            text2:
                                                'When neighbours react, invite or message you, it shows up here.',
                                          );
                                        }

                                        return ListView.builder(
                                          padding: EdgeInsets.zero,
                                          primary: false,
                                          shrinkWrap: true,
                                          scrollDirection: Axis.vertical,
                                          itemCount: business.length,
                                          itemBuilder:
                                              (context, businessIndex) {
                                            final businessItem =
                                                business[businessIndex];
                                            return InkWell(
                                              splashColor:
                                                  FlutterFlowTheme.of(context)
                                                      .primary
                                                      .withAlpha(0x14),
                                              focusColor: Colors.transparent,
                                              hoverColor: Colors.transparent,
                                              highlightColor:
                                                  Colors.transparent,
                                              onTap: () async {
                                                context.pushNamed(
                                                  BusinessHomePageWidget
                                                      .routeName,
                                                  queryParameters: {
                                                    'businessId':
                                                        serializeParam(
                                                      getJsonField(
                                                        businessItem,
                                                        r'''$.business_id''',
                                                      ).toString(),
                                                      ParamType.String,
                                                    ),
                                                  }.withoutNulls,
                                                );

                                                if ('${getJsonField(
                                                      businessItem,
                                                      r'''$.is_read''',
                                                    ).toString()}' ==
                                                    'false') {
                                                  await NotificationsTable()
                                                      .update(
                                                    data: {
                                                      'is_read': true,
                                                    },
                                                    matchingRows: (rows) => rows
                                                        .eqOrNull(
                                                          'receiver_id',
                                                          currentUserUid,
                                                        )
                                                        .eqOrNull(
                                                          'id',
                                                          getJsonField(
                                                            businessItem,
                                                            r'''$.id''',
                                                          ).toString(),
                                                        ),
                                                  );
                                                  _model.json2 =
                                                      await NotificationCall
                                                          .call(
                                                    token: currentJwtToken,
                                                    pUserid: currentUserUid,
                                                  );

                                                  FFAppState().notifications =
                                                      (_model.json2?.jsonBody ??
                                                          '');
                                                  _model.updatePage(() {});
                                                }

                                                safeSetState(() {});
                                              },
                                              child: Container(
                                                width: double.infinity,
                                                decoration: BoxDecoration(
                                                  color: '${getJsonField(
                                                            businessItem,
                                                            r'''$.is_read''',
                                                          ).toString()}' ==
                                                          'true'
                                                      ? FlutterFlowTheme.of(
                                                              context)
                                                          .white
                                                      : FlutterFlowTheme.of(
                                                              context)
                                                          .greayL1,
                                                  border: Border.all(
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .greyL2,
                                                    width: 1.0,
                                                  ),
                                                ),
                                                child: Padding(
                                                  // 6/8 (was 8/16). These five
                                                  // tabs are full-bleed rows
                                                  // with no margin, separated
                                                  // only by their 1dp border, so
                                                  // the padding IS the breathing
                                                  // room: 6/8 keeps a 16dp
                                                  // content gap between
                                                  // neighbours while the options
                                                  // button's 44dp box supplies
                                                  // the rest. Bottom stays
                                                  // heavier than top to keep the
                                                  // original vertical rhythm.
                                                  padding: EdgeInsetsDirectional
                                                      .fromSTEB(
                                                          20.0, 6.0, 20.0, 8.0),
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    children: [
                                                      AppNetworkImage(
                                                        url: getJsonField(
                                                          businessItem,
                                                          r'''$.profile_image''',
                                                        ).toString(),
                                                        width: 40.0,
                                                        height: 40.0,
                                                        fit: BoxFit.cover,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(4.0),
                                                        fallbackIcon: Icons
                                                            .person_rounded,
                                                        semanticLabel:
                                                            'Profile photo of ${getJsonField(
                                                          businessItem,
                                                          r'''$.name''',
                                                        ).toString()}',
                                                      ),
                                                      Expanded(
                                                        child: Wrap(
                                                          spacing: 0.0,
                                                          runSpacing: 0.0,
                                                          alignment:
                                                              WrapAlignment
                                                                  .start,
                                                          crossAxisAlignment:
                                                              WrapCrossAlignment
                                                                  .start,
                                                          direction:
                                                              Axis.horizontal,
                                                          runAlignment:
                                                              WrapAlignment
                                                                  .start,
                                                          verticalDirection:
                                                              VerticalDirection
                                                                  .down,
                                                          clipBehavior:
                                                              Clip.none,
                                                          children: [
                                                            RichText(
                                                              textScaler:
                                                                  MediaQuery.of(
                                                                          context)
                                                                      .textScaler,
                                                              text: TextSpan(
                                                                children: [
                                                                  TextSpan(
                                                                    text:
                                                                        getJsonField(
                                                                      businessItem,
                                                                      r'''$.name''',
                                                                    ).toString(),
                                                                    style: FlutterFlowTheme.of(
                                                                            context)
                                                                        .bodyMedium
                                                                        .override(
                                                                          font:
                                                                              GoogleFonts.manrope(
                                                                            fontWeight:
                                                                                FontWeight.w500,
                                                                            fontStyle:
                                                                                FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                          ),
                                                                          color:
                                                                              FlutterFlowTheme.of(context).extraBlack,
                                                                          letterSpacing:
                                                                              0.0,
                                                                          fontWeight:
                                                                              FontWeight.w500,
                                                                          fontStyle: FlutterFlowTheme.of(context)
                                                                              .bodyMedium
                                                                              .fontStyle,
                                                                          lineHeight:
                                                                              1.3,
                                                                        ),
                                                                  ),
                                                                  TextSpan(
                                                                    text: ' ',
                                                                    style:
                                                                        TextStyle(),
                                                                  ),
                                                                  TextSpan(
                                                                    text:
                                                                        getJsonField(
                                                                      businessItem,
                                                                      r'''$.content''',
                                                                    ).toString(),
                                                                    style: FlutterFlowTheme.of(
                                                                            context)
                                                                        .bodyMedium
                                                                        .override(
                                                                          font:
                                                                              GoogleFonts.manrope(
                                                                            fontWeight:
                                                                                FontWeight.w500,
                                                                            fontStyle:
                                                                                FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                          ),
                                                                          color:
                                                                              FlutterFlowTheme.of(context).greyL4,
                                                                          letterSpacing:
                                                                              0.0,
                                                                          fontWeight:
                                                                              FontWeight.w500,
                                                                          fontStyle: FlutterFlowTheme.of(context)
                                                                              .bodyMedium
                                                                              .fontStyle,
                                                                          lineHeight:
                                                                              1.3,
                                                                        ),
                                                                  )
                                                                ],
                                                                style: FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .override(
                                                                      font: GoogleFonts
                                                                          .manrope(
                                                                        fontWeight: FlutterFlowTheme.of(context)
                                                                            .bodyMedium
                                                                            .fontWeight,
                                                                        fontStyle: FlutterFlowTheme.of(context)
                                                                            .bodyMedium
                                                                            .fontStyle,
                                                                      ),
                                                                      letterSpacing:
                                                                          0.0,
                                                                      fontWeight: FlutterFlowTheme.of(
                                                                              context)
                                                                          .bodyMedium
                                                                          .fontWeight,
                                                                      fontStyle: FlutterFlowTheme.of(
                                                                              context)
                                                                          .bodyMedium
                                                                          .fontStyle,
                                                                    ),
                                                              ),
                                                            ),
                                                            if (getJsonField(
                                                                  businessItem,
                                                                  r'''$.message''',
                                                                ) !=
                                                                null)
                                                              Text(
                                                                getJsonField(
                                                                  businessItem,
                                                                  r'''$.message''',
                                                                ).toString(),
                                                                style: FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .override(
                                                                      font: GoogleFonts
                                                                          .manrope(
                                                                        fontWeight:
                                                                            FontWeight.w500,
                                                                        fontStyle: FlutterFlowTheme.of(context)
                                                                            .bodyMedium
                                                                            .fontStyle,
                                                                      ),
                                                                      color: FlutterFlowTheme.of(
                                                                              context)
                                                                          .extraBlack,
                                                                      letterSpacing:
                                                                          0.0,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500,
                                                                      fontStyle: FlutterFlowTheme.of(
                                                                              context)
                                                                          .bodyMedium
                                                                          .fontStyle,
                                                                      lineHeight:
                                                                          1.3,
                                                                    ),
                                                              ),
                                                          ],
                                                        ),
                                                      ),
                                                      Column(
                                                        mainAxisSize:
                                                            MainAxisSize.max,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .end,
                                                        children: [
                                                          Text(
                                                            functions
                                                                .returnRelativeTIme(
                                                                    getJsonField(
                                                              businessItem,
                                                              r'''$.created_at''',
                                                            ).toString()),
                                                            style: FlutterFlowTheme
                                                                    .of(context)
                                                                .bodyMedium
                                                                .override(
                                                                  font: GoogleFonts
                                                                      .manrope(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                    fontStyle: FlutterFlowTheme.of(
                                                                            context)
                                                                        .bodyMedium
                                                                        .fontStyle,
                                                                  ),
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .greyL4,
                                                                  fontSize:
                                                                      12.0,
                                                                  letterSpacing:
                                                                      0.0,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  fontStyle: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMedium
                                                                      .fontStyle,
                                                                  lineHeight:
                                                                      1.4,
                                                                ),
                                                          ),
                                                          Transform.rotate(
                                                            angle: 90.0 *
                                                                (math.pi / 180),
                                                            child:
                                                                AppIconButton(
                                                              icon: Icons
                                                                  .keyboard_control,
                                                              iconSize: 20.0,
                                                              color: FlutterFlowTheme
                                                                      .of(context)
                                                                  .primaryText,
                                                              semanticLabel:
                                                                  'Notification options',
                                                              tooltip:
                                                                  'Notification options',
                                                              onTap: () async {
                                                                await showModalBottomSheet(
                                                                  isScrollControlled:
                                                                      true,
                                                                  backgroundColor:
                                                                      Colors
                                                                          .transparent,
                                                                  context:
                                                                      context,
                                                                  builder:
                                                                      (context) {
                                                                    return GestureDetector(
                                                                      onTap:
                                                                          () {
                                                                        FocusScope.of(context)
                                                                            .unfocus();
                                                                        FocusManager
                                                                            .instance
                                                                            .primaryFocus
                                                                            ?.unfocus();
                                                                      },
                                                                      child:
                                                                          Padding(
                                                                        padding:
                                                                            MediaQuery.viewInsetsOf(context),
                                                                        child:
                                                                            CompNotificationWidget(
                                                                          notificationId:
                                                                              getJsonField(
                                                                            businessItem,
                                                                            r'''$.id''',
                                                                          ).toString(),
                                                                          isread:
                                                                              getJsonField(
                                                                            businessItem,
                                                                            r'''$.is_read''',
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    );
                                                                  },
                                                                ).then((value) =>
                                                                    safeSetState(
                                                                        () {}));
                                                              },
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ].divide(
                                                        SizedBox(width: 8.0)),
                                                  ),
                                                ),
                                              ),
                                            )
                                                .animate()
                                                .fadeIn(
                                                    duration: 260.ms,
                                                    delay: (40 *
                                                            (businessIndex % 8))
                                                        .ms)
                                                .slideY(
                                                    begin: 0.06,
                                                    end: 0,
                                                    curve: Curves.easeOutCubic);
                                          },
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          if (_model.opt == 'sale')
                            Expanded(
                              child: SingleChildScrollView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Builder(
                                      builder: (context) {
                                        final sale = getJsonField(
                                          FFAppState().notifications,
                                          r'''$.sale''',
                                        ).toList();
                                        if (sale.isEmpty) {
                                          return CompNoDataFoundWidget(
                                            pageName: 'no',
                                            text1: 'Nothing new yet',
                                            text2:
                                                'When neighbours react, invite or message you, it shows up here.',
                                          );
                                        }

                                        return ListView.builder(
                                          padding: EdgeInsets.zero,
                                          primary: false,
                                          shrinkWrap: true,
                                          scrollDirection: Axis.vertical,
                                          itemCount: sale.length,
                                          itemBuilder: (context, saleIndex) {
                                            final saleItem = sale[saleIndex];
                                            return InkWell(
                                              splashColor:
                                                  FlutterFlowTheme.of(context)
                                                      .primary
                                                      .withAlpha(0x14),
                                              focusColor: Colors.transparent,
                                              hoverColor: Colors.transparent,
                                              highlightColor:
                                                  Colors.transparent,
                                              onTap: () async {
                                                context.pushNamed(
                                                  SaleDetailsWidget.routeName,
                                                  queryParameters: {
                                                    'saleId': serializeParam(
                                                      getJsonField(
                                                        saleItem,
                                                        r'''$.sale_id''',
                                                      ).toString(),
                                                      ParamType.String,
                                                    ),
                                                  }.withoutNulls,
                                                );

                                                if ('${getJsonField(
                                                      saleItem,
                                                      r'''$.is_read''',
                                                    ).toString()}' ==
                                                    'false') {
                                                  await NotificationsTable()
                                                      .update(
                                                    data: {
                                                      'is_read': true,
                                                    },
                                                    matchingRows: (rows) => rows
                                                        .eqOrNull(
                                                          'receiver_id',
                                                          currentUserUid,
                                                        )
                                                        .eqOrNull(
                                                          'id',
                                                          getJsonField(
                                                            saleItem,
                                                            r'''$.id''',
                                                          ).toString(),
                                                        ),
                                                  );
                                                  _model.json3 =
                                                      await NotificationCall
                                                          .call(
                                                    token: currentJwtToken,
                                                    pUserid: currentUserUid,
                                                  );

                                                  FFAppState().notifications =
                                                      (_model.json3?.jsonBody ??
                                                          '');
                                                  _model.updatePage(() {});
                                                }

                                                safeSetState(() {});
                                              },
                                              child: Container(
                                                width: double.infinity,
                                                decoration: BoxDecoration(
                                                  color: '${getJsonField(
                                                            saleItem,
                                                            r'''$.is_read''',
                                                          ).toString()}' ==
                                                          'true'
                                                      ? FlutterFlowTheme.of(
                                                              context)
                                                          .white
                                                      : FlutterFlowTheme.of(
                                                              context)
                                                          .greayL1,
                                                  border: Border.all(
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .greyL2,
                                                    width: 1.0,
                                                  ),
                                                ),
                                                child: Padding(
                                                  // 6/8 (was 8/16). These five
                                                  // tabs are full-bleed rows
                                                  // with no margin, separated
                                                  // only by their 1dp border, so
                                                  // the padding IS the breathing
                                                  // room: 6/8 keeps a 16dp
                                                  // content gap between
                                                  // neighbours while the options
                                                  // button's 44dp box supplies
                                                  // the rest. Bottom stays
                                                  // heavier than top to keep the
                                                  // original vertical rhythm.
                                                  padding: EdgeInsetsDirectional
                                                      .fromSTEB(
                                                          20.0, 6.0, 20.0, 8.0),
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    children: [
                                                      AppNetworkImage(
                                                        url: getJsonField(
                                                          saleItem,
                                                          r'''$.profile_image''',
                                                        ).toString(),
                                                        width: 40.0,
                                                        height: 40.0,
                                                        fit: BoxFit.cover,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(4.0),
                                                        fallbackIcon: Icons
                                                            .person_rounded,
                                                        semanticLabel:
                                                            'Profile photo of ${getJsonField(
                                                          saleItem,
                                                          r'''$.name''',
                                                        ).toString()}',
                                                      ),
                                                      Expanded(
                                                        child: Wrap(
                                                          spacing: 0.0,
                                                          runSpacing: 0.0,
                                                          alignment:
                                                              WrapAlignment
                                                                  .start,
                                                          crossAxisAlignment:
                                                              WrapCrossAlignment
                                                                  .start,
                                                          direction:
                                                              Axis.horizontal,
                                                          runAlignment:
                                                              WrapAlignment
                                                                  .start,
                                                          verticalDirection:
                                                              VerticalDirection
                                                                  .down,
                                                          clipBehavior:
                                                              Clip.none,
                                                          children: [
                                                            RichText(
                                                              textScaler:
                                                                  MediaQuery.of(
                                                                          context)
                                                                      .textScaler,
                                                              text: TextSpan(
                                                                children: [
                                                                  TextSpan(
                                                                    text:
                                                                        getJsonField(
                                                                      saleItem,
                                                                      r'''$.name''',
                                                                    ).toString(),
                                                                    style: FlutterFlowTheme.of(
                                                                            context)
                                                                        .bodyMedium
                                                                        .override(
                                                                          font:
                                                                              GoogleFonts.manrope(
                                                                            fontWeight:
                                                                                FontWeight.w500,
                                                                            fontStyle:
                                                                                FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                          ),
                                                                          color:
                                                                              FlutterFlowTheme.of(context).extraBlack,
                                                                          letterSpacing:
                                                                              0.0,
                                                                          fontWeight:
                                                                              FontWeight.w500,
                                                                          fontStyle: FlutterFlowTheme.of(context)
                                                                              .bodyMedium
                                                                              .fontStyle,
                                                                          lineHeight:
                                                                              1.3,
                                                                        ),
                                                                  ),
                                                                  TextSpan(
                                                                    text: ' ',
                                                                    style:
                                                                        TextStyle(),
                                                                  ),
                                                                  TextSpan(
                                                                    text:
                                                                        getJsonField(
                                                                      saleItem,
                                                                      r'''$.content''',
                                                                    ).toString(),
                                                                    style: FlutterFlowTheme.of(
                                                                            context)
                                                                        .bodyMedium
                                                                        .override(
                                                                          font:
                                                                              GoogleFonts.manrope(
                                                                            fontWeight:
                                                                                FontWeight.w500,
                                                                            fontStyle:
                                                                                FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                          ),
                                                                          color:
                                                                              FlutterFlowTheme.of(context).greyL4,
                                                                          letterSpacing:
                                                                              0.0,
                                                                          fontWeight:
                                                                              FontWeight.w500,
                                                                          fontStyle: FlutterFlowTheme.of(context)
                                                                              .bodyMedium
                                                                              .fontStyle,
                                                                          lineHeight:
                                                                              1.3,
                                                                        ),
                                                                  )
                                                                ],
                                                                style: FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .override(
                                                                      font: GoogleFonts
                                                                          .manrope(
                                                                        fontWeight: FlutterFlowTheme.of(context)
                                                                            .bodyMedium
                                                                            .fontWeight,
                                                                        fontStyle: FlutterFlowTheme.of(context)
                                                                            .bodyMedium
                                                                            .fontStyle,
                                                                      ),
                                                                      letterSpacing:
                                                                          0.0,
                                                                      fontWeight: FlutterFlowTheme.of(
                                                                              context)
                                                                          .bodyMedium
                                                                          .fontWeight,
                                                                      fontStyle: FlutterFlowTheme.of(
                                                                              context)
                                                                          .bodyMedium
                                                                          .fontStyle,
                                                                    ),
                                                              ),
                                                            ),
                                                            if (getJsonField(
                                                                  saleItem,
                                                                  r'''$.message''',
                                                                ) !=
                                                                null)
                                                              Text(
                                                                getJsonField(
                                                                  saleItem,
                                                                  r'''$.message''',
                                                                ).toString(),
                                                                style: FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .override(
                                                                      font: GoogleFonts
                                                                          .manrope(
                                                                        fontWeight:
                                                                            FontWeight.w500,
                                                                        fontStyle: FlutterFlowTheme.of(context)
                                                                            .bodyMedium
                                                                            .fontStyle,
                                                                      ),
                                                                      color: FlutterFlowTheme.of(
                                                                              context)
                                                                          .extraBlack,
                                                                      letterSpacing:
                                                                          0.0,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500,
                                                                      fontStyle: FlutterFlowTheme.of(
                                                                              context)
                                                                          .bodyMedium
                                                                          .fontStyle,
                                                                      lineHeight:
                                                                          1.3,
                                                                    ),
                                                              ),
                                                          ],
                                                        ),
                                                      ),
                                                      Column(
                                                        mainAxisSize:
                                                            MainAxisSize.max,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .end,
                                                        children: [
                                                          Text(
                                                            functions
                                                                .returnRelativeTIme(
                                                                    getJsonField(
                                                              saleItem,
                                                              r'''$.created_at''',
                                                            ).toString()),
                                                            style: FlutterFlowTheme
                                                                    .of(context)
                                                                .bodyMedium
                                                                .override(
                                                                  font: GoogleFonts
                                                                      .manrope(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                    fontStyle: FlutterFlowTheme.of(
                                                                            context)
                                                                        .bodyMedium
                                                                        .fontStyle,
                                                                  ),
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .greyL4,
                                                                  fontSize:
                                                                      12.0,
                                                                  letterSpacing:
                                                                      0.0,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  fontStyle: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMedium
                                                                      .fontStyle,
                                                                  lineHeight:
                                                                      1.4,
                                                                ),
                                                          ),
                                                          Transform.rotate(
                                                            angle: 90.0 *
                                                                (math.pi / 180),
                                                            child:
                                                                AppIconButton(
                                                              icon: Icons
                                                                  .keyboard_control,
                                                              iconSize: 20.0,
                                                              color: FlutterFlowTheme
                                                                      .of(context)
                                                                  .primaryText,
                                                              semanticLabel:
                                                                  'Notification options',
                                                              tooltip:
                                                                  'Notification options',
                                                              onTap: () async {
                                                                await showModalBottomSheet(
                                                                  isScrollControlled:
                                                                      true,
                                                                  backgroundColor:
                                                                      Colors
                                                                          .transparent,
                                                                  context:
                                                                      context,
                                                                  builder:
                                                                      (context) {
                                                                    return GestureDetector(
                                                                      onTap:
                                                                          () {
                                                                        FocusScope.of(context)
                                                                            .unfocus();
                                                                        FocusManager
                                                                            .instance
                                                                            .primaryFocus
                                                                            ?.unfocus();
                                                                      },
                                                                      child:
                                                                          Padding(
                                                                        padding:
                                                                            MediaQuery.viewInsetsOf(context),
                                                                        child:
                                                                            CompNotificationWidget(
                                                                          notificationId:
                                                                              getJsonField(
                                                                            saleItem,
                                                                            r'''$.id''',
                                                                          ).toString(),
                                                                          isread:
                                                                              getJsonField(
                                                                            saleItem,
                                                                            r'''$.is_read''',
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    );
                                                                  },
                                                                ).then((value) =>
                                                                    safeSetState(
                                                                        () {}));
                                                              },
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ].divide(
                                                        SizedBox(width: 8.0)),
                                                  ),
                                                ),
                                              ),
                                            )
                                                .animate()
                                                .fadeIn(
                                                    duration: 260.ms,
                                                    delay:
                                                        (40 * (saleIndex % 8))
                                                            .ms)
                                                .slideY(
                                                    begin: 0.06,
                                                    end: 0,
                                                    curve: Curves.easeOutCubic);
                                          },
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                if (_model.showData == false)
                  Expanded(
                    child: Padding(
                      padding:
                          EdgeInsetsDirectional.fromSTEB(20.0, 10.0, 20.0, 0.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Align(
                            alignment: AlignmentDirectional(0.0, -1.0),
                            child: Container(
                              width: double.infinity,
                              height: 64.0,
                              decoration: BoxDecoration(
                                color: FlutterFlowTheme.of(context).greyL2,
                                borderRadius: BorderRadius.circular(4.0),
                              ),
                            ).animateOnPageLoad(animationsMap[
                                'containerOnPageLoadAnimation1']!),
                          ),
                          Align(
                            alignment: AlignmentDirectional(0.0, -1.0),
                            child: Container(
                              width: double.infinity,
                              height: 64.0,
                              decoration: BoxDecoration(
                                color: FlutterFlowTheme.of(context).greyL2,
                                borderRadius: BorderRadius.circular(4.0),
                              ),
                            ).animateOnPageLoad(animationsMap[
                                'containerOnPageLoadAnimation2']!),
                          ),
                          Align(
                            alignment: AlignmentDirectional(0.0, -1.0),
                            child: Container(
                              width: double.infinity,
                              height: 64.0,
                              decoration: BoxDecoration(
                                color: FlutterFlowTheme.of(context).greyL2,
                                borderRadius: BorderRadius.circular(4.0),
                              ),
                            ).animateOnPageLoad(animationsMap[
                                'containerOnPageLoadAnimation3']!),
                          ),
                        ].divide(SizedBox(height: 10.0)),
                      ),
                    ),
                  ),
                wrapWithModel(
                  model: _model.compNavbarModel,
                  updateCallback: () => safeSetState(() {}),
                  child: CompNavbarWidget(
                    pagename: 'notification',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
