import '/auth/supabase_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/backend/supabase/supabase.dart';
import '/components/comp_no_data_found_widget.dart';
import '/components/comp_notification_widget.dart';
import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_theme.dart';
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

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => NotificationModel());

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      _model.opt = 'all';
      safeSetState(() {});
      _model.notificationjson = await NotificationCall.call(
        token: currentJwtToken,
        pUserid: currentUserUid,
      );

      FFAppState().notifications = (_model.notificationjson?.jsonBody ?? '');
      safeSetState(() {});
      _model.showData = true;
      safeSetState(() {});
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
            color: Color(0xB2FFFFFF),
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
            color: Color(0xB2FFFFFF),
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
            color: Color(0xB2FFFFFF),
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
                    padding:
                        EdgeInsetsDirectional.fromSTEB(0.0, 12.0, 0.0, 12.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        InkWell(
                          splashColor: Colors.transparent,
                          focusColor: Colors.transparent,
                          hoverColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          onTap: () async {
                            context.pushNamed(ProfileWidget.routeName);
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(24.0),
                            child: Image.network(
                              FFAppState().AsProfilePicture,
                              width: 32.0,
                              height: 32.0,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Expanded(
                          child: InkWell(
                            splashColor: Colors.transparent,
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
                                color: Color(0xFFF7F9FC),
                                borderRadius: BorderRadius.circular(4.0),
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
                        Container(
                          width: 34.0,
                          height: 34.0,
                          decoration: BoxDecoration(
                            color: FlutterFlowTheme.of(context).greyL2,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(100.0),
                              topRight: Radius.circular(100.0),
                              bottomLeft: Radius.circular(100.0),
                              bottomRight: Radius.circular(100.0),
                            ),
                          ),
                          alignment: AlignmentDirectional(0.0, 0.0),
                          child: InkWell(
                            splashColor: Colors.transparent,
                            focusColor: Colors.transparent,
                            hoverColor: Colors.transparent,
                            highlightColor: Colors.transparent,
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
                                  font: GoogleFonts.inter(
                                    fontWeight: FlutterFlowTheme.of(context)
                                        .labelMedium
                                        .fontWeight,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .labelMedium
                                        .fontStyle,
                                  ),
                                  color: _model.opt == 'all'
                                      ? FlutterFlowTheme.of(context).white
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
                                  font: GoogleFonts.inter(
                                    fontWeight: FlutterFlowTheme.of(context)
                                        .labelMedium
                                        .fontWeight,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .labelMedium
                                        .fontStyle,
                                  ),
                                  color: _model.opt == 'post'
                                      ? FlutterFlowTheme.of(context).white
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
                                  font: GoogleFonts.inter(
                                    fontWeight: FlutterFlowTheme.of(context)
                                        .labelMedium
                                        .fontWeight,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .labelMedium
                                        .fontStyle,
                                  ),
                                  color: _model.opt == 'group'
                                      ? FlutterFlowTheme.of(context).white
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
                                  font: GoogleFonts.inter(
                                    fontWeight: FlutterFlowTheme.of(context)
                                        .labelMedium
                                        .fontWeight,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .labelMedium
                                        .fontStyle,
                                  ),
                                  color: _model.opt == 'event'
                                      ? FlutterFlowTheme.of(context).white
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
                                  font: GoogleFonts.inter(
                                    fontWeight: FlutterFlowTheme.of(context)
                                        .labelMedium
                                        .fontWeight,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .labelMedium
                                        .fontStyle,
                                  ),
                                  color: _model.opt == 'business'
                                      ? FlutterFlowTheme.of(context).white
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
                                  font: GoogleFonts.inter(
                                    fontWeight: FlutterFlowTheme.of(context)
                                        .labelMedium
                                        .fontWeight,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .labelMedium
                                        .fontStyle,
                                  ),
                                  color: _model.opt == 'sale'
                                      ? FlutterFlowTheme.of(context).white
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
                if (_model.showData)
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        if (_model.opt == 'all')
                          Expanded(
                            child: SingleChildScrollView(
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
                                          text1: '📭 No Notifications Yet',
                                          text2:
                                              'Stay tuned! We’ll let you know when there’s something new to see.',
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
                                            splashColor: Colors.transparent,
                                            focusColor: Colors.transparent,
                                            hoverColor: Colors.transparent,
                                            highlightColor: Colors.transparent,
                                            onTap: () async {
                                              if ('${getJsonField(
                                                    allItem,
                                                    r'''$.type''',
                                                  ).toString()}' ==
                                                  'post') {
                                                context.pushNamed(
                                                  CommentsPageWidget.routeName,
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
                                                    matchingRows: (rows) => rows
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

                                                  FFAppState().notifications =
                                                      (_model.notificationjson1
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
                                                      'eventId': serializeParam(
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
                                                      _model.notificationjson131 =
                                                          await NotificationCall
                                                              .call(
                                                        token: currentJwtToken,
                                                        pUserid: currentUserUid,
                                                      );

                                                      FFAppState()
                                                          .notifications = (_model
                                                              .notificationjson131
                                                              ?.jsonBody ??
                                                          '');
                                                      _model.updatePage(() {});
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
                                                        _model
                                                            .updatePage(() {});
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
                                                              queryParameters: {
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
                                                              _model.updatePage(
                                                                  () {});
                                                            }
                                                          } else {
                                                            if ('${getJsonField(
                                                                  allItem,
                                                                  r'''$.type''',
                                                                ).toString()}' ==
                                                                'group_invite') {
                                                              context.pushNamed(
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
                                              decoration: BoxDecoration(
                                                color: '${getJsonField(
                                                          allItem,
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
                                                padding: EdgeInsetsDirectional
                                                    .fromSTEB(
                                                        20.0, 8.0, 20.0, 16.0),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  children: [
                                                    ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              4.0),
                                                      child: Image.network(
                                                        getJsonField(
                                                          allItem,
                                                          r'''$.profile_image''',
                                                        ).toString(),
                                                        width: 40.0,
                                                        height: 40.0,
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                    Expanded(
                                                      child: Wrap(
                                                        spacing: 0.0,
                                                        runSpacing: 0.0,
                                                        alignment:
                                                            WrapAlignment.start,
                                                        crossAxisAlignment:
                                                            WrapCrossAlignment
                                                                .start,
                                                        direction:
                                                            Axis.horizontal,
                                                        runAlignment:
                                                            WrapAlignment.start,
                                                        verticalDirection:
                                                            VerticalDirection
                                                                .down,
                                                        clipBehavior: Clip.none,
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
                                                                        font: GoogleFonts
                                                                            .manrope(
                                                                          fontWeight:
                                                                              FontWeight.w500,
                                                                          fontStyle: FlutterFlowTheme.of(context)
                                                                              .bodyMedium
                                                                              .fontStyle,
                                                                        ),
                                                                        color: FlutterFlowTheme.of(context)
                                                                            .extraBlack,
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
                                                                        font: GoogleFonts
                                                                            .inter(
                                                                          fontWeight:
                                                                              FontWeight.w500,
                                                                          fontStyle: FlutterFlowTheme.of(context)
                                                                              .bodyMedium
                                                                              .fontStyle,
                                                                        ),
                                                                        color: FlutterFlowTheme.of(context)
                                                                            .greyL4,
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
                                                              style: FlutterFlowTheme
                                                                      .of(context)
                                                                  .bodyMedium
                                                                  .override(
                                                                    font: GoogleFonts
                                                                        .inter(
                                                                      fontWeight: FlutterFlowTheme.of(
                                                                              context)
                                                                          .bodyMedium
                                                                          .fontWeight,
                                                                      fontStyle: FlutterFlowTheme.of(
                                                                              context)
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
                                                                fontSize: 12.0,
                                                                letterSpacing:
                                                                    0.0,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                fontStyle: FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .fontStyle,
                                                                lineHeight: 1.4,
                                                              ),
                                                        ),
                                                        Transform.rotate(
                                                          angle: 90.0 *
                                                              (math.pi / 180),
                                                          child: InkWell(
                                                            splashColor: Colors
                                                                .transparent,
                                                            focusColor: Colors
                                                                .transparent,
                                                            hoverColor: Colors
                                                                .transparent,
                                                            highlightColor:
                                                                Colors
                                                                    .transparent,
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
                                                                    onTap: () {
                                                                      FocusScope.of(
                                                                              context)
                                                                          .unfocus();
                                                                      FocusManager
                                                                          .instance
                                                                          .primaryFocus
                                                                          ?.unfocus();
                                                                    },
                                                                    child:
                                                                        Padding(
                                                                      padding: MediaQuery
                                                                          .viewInsetsOf(
                                                                              context),
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
                                                            child: Icon(
                                                              Icons
                                                                  .keyboard_control,
                                                              color: FlutterFlowTheme
                                                                      .of(context)
                                                                  .primaryText,
                                                              size: 20.0,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ].divide(
                                                      SizedBox(width: 8.0)),
                                                ),
                                              ),
                                            ),
                                          );
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
                                          text1: '📭 No Notifications Yet',
                                          text2:
                                              'Stay tuned! We’ll let you know when there’s something new to see.',
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
                                            splashColor: Colors.transparent,
                                            focusColor: Colors.transparent,
                                            hoverColor: Colors.transparent,
                                            highlightColor: Colors.transparent,
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
                                                    await NotificationCall.call(
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
                                                padding: EdgeInsetsDirectional
                                                    .fromSTEB(
                                                        20.0, 8.0, 20.0, 16.0),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  children: [
                                                    ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              4.0),
                                                      child: Image.network(
                                                        getJsonField(
                                                          postsItem,
                                                          r'''$.profile_image''',
                                                        ).toString(),
                                                        width: 40.0,
                                                        height: 40.0,
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                    Expanded(
                                                      child: Wrap(
                                                        spacing: 0.0,
                                                        runSpacing: 0.0,
                                                        alignment:
                                                            WrapAlignment.start,
                                                        crossAxisAlignment:
                                                            WrapCrossAlignment
                                                                .start,
                                                        direction:
                                                            Axis.horizontal,
                                                        runAlignment:
                                                            WrapAlignment.start,
                                                        verticalDirection:
                                                            VerticalDirection
                                                                .down,
                                                        clipBehavior: Clip.none,
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
                                                                        font: GoogleFonts
                                                                            .manrope(
                                                                          fontWeight:
                                                                              FontWeight.w500,
                                                                          fontStyle: FlutterFlowTheme.of(context)
                                                                              .bodyMedium
                                                                              .fontStyle,
                                                                        ),
                                                                        color: FlutterFlowTheme.of(context)
                                                                            .extraBlack,
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
                                                                        font: GoogleFonts
                                                                            .inter(
                                                                          fontWeight:
                                                                              FontWeight.w500,
                                                                          fontStyle: FlutterFlowTheme.of(context)
                                                                              .bodyMedium
                                                                              .fontStyle,
                                                                        ),
                                                                        color: FlutterFlowTheme.of(context)
                                                                            .greyL4,
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
                                                              style: FlutterFlowTheme
                                                                      .of(context)
                                                                  .bodyMedium
                                                                  .override(
                                                                    font: GoogleFonts
                                                                        .inter(
                                                                      fontWeight: FlutterFlowTheme.of(
                                                                              context)
                                                                          .bodyMedium
                                                                          .fontWeight,
                                                                      fontStyle: FlutterFlowTheme.of(
                                                                              context)
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
                                                                fontSize: 12.0,
                                                                letterSpacing:
                                                                    0.0,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                fontStyle: FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .fontStyle,
                                                                lineHeight: 1.4,
                                                              ),
                                                        ),
                                                        Transform.rotate(
                                                          angle: 90.0 *
                                                              (math.pi / 180),
                                                          child: InkWell(
                                                            splashColor: Colors
                                                                .transparent,
                                                            focusColor: Colors
                                                                .transparent,
                                                            hoverColor: Colors
                                                                .transparent,
                                                            highlightColor:
                                                                Colors
                                                                    .transparent,
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
                                                                    onTap: () {
                                                                      FocusScope.of(
                                                                              context)
                                                                          .unfocus();
                                                                      FocusManager
                                                                          .instance
                                                                          .primaryFocus
                                                                          ?.unfocus();
                                                                    },
                                                                    child:
                                                                        Padding(
                                                                      padding: MediaQuery
                                                                          .viewInsetsOf(
                                                                              context),
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
                                                            child: Icon(
                                                              Icons
                                                                  .keyboard_control,
                                                              color: FlutterFlowTheme
                                                                      .of(context)
                                                                  .primaryText,
                                                              size: 20.0,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ].divide(
                                                      SizedBox(width: 8.0)),
                                                ),
                                              ),
                                            ),
                                          );
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
                                          text1: '📭 No Notifications Yet',
                                          text2:
                                              'Stay tuned! We’ll let you know when there’s something new to see.',
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
                                            splashColor: Colors.transparent,
                                            focusColor: Colors.transparent,
                                            hoverColor: Colors.transparent,
                                            highlightColor: Colors.transparent,
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
                                                    await NotificationCall.call(
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
                                                padding: EdgeInsetsDirectional
                                                    .fromSTEB(
                                                        20.0, 8.0, 20.0, 16.0),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  children: [
                                                    ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              4.0),
                                                      child: Image.network(
                                                        getJsonField(
                                                          groupItem,
                                                          r'''$.profile_image''',
                                                        ).toString(),
                                                        width: 40.0,
                                                        height: 40.0,
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                    Expanded(
                                                      child: Wrap(
                                                        spacing: 0.0,
                                                        runSpacing: 0.0,
                                                        alignment:
                                                            WrapAlignment.start,
                                                        crossAxisAlignment:
                                                            WrapCrossAlignment
                                                                .start,
                                                        direction:
                                                            Axis.horizontal,
                                                        runAlignment:
                                                            WrapAlignment.start,
                                                        verticalDirection:
                                                            VerticalDirection
                                                                .down,
                                                        clipBehavior: Clip.none,
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
                                                                        font: GoogleFonts
                                                                            .manrope(
                                                                          fontWeight:
                                                                              FontWeight.w500,
                                                                          fontStyle: FlutterFlowTheme.of(context)
                                                                              .bodyMedium
                                                                              .fontStyle,
                                                                        ),
                                                                        color: FlutterFlowTheme.of(context)
                                                                            .extraBlack,
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
                                                                        font: GoogleFonts
                                                                            .inter(
                                                                          fontWeight:
                                                                              FontWeight.w500,
                                                                          fontStyle: FlutterFlowTheme.of(context)
                                                                              .bodyMedium
                                                                              .fontStyle,
                                                                        ),
                                                                        color: FlutterFlowTheme.of(context)
                                                                            .greyL4,
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
                                                              style: FlutterFlowTheme
                                                                      .of(context)
                                                                  .bodyMedium
                                                                  .override(
                                                                    font: GoogleFonts
                                                                        .inter(
                                                                      fontWeight: FlutterFlowTheme.of(
                                                                              context)
                                                                          .bodyMedium
                                                                          .fontWeight,
                                                                      fontStyle: FlutterFlowTheme.of(
                                                                              context)
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
                                                                fontSize: 12.0,
                                                                letterSpacing:
                                                                    0.0,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                fontStyle: FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .fontStyle,
                                                                lineHeight: 1.4,
                                                              ),
                                                        ),
                                                        Transform.rotate(
                                                          angle: 90.0 *
                                                              (math.pi / 180),
                                                          child: InkWell(
                                                            splashColor: Colors
                                                                .transparent,
                                                            focusColor: Colors
                                                                .transparent,
                                                            hoverColor: Colors
                                                                .transparent,
                                                            highlightColor:
                                                                Colors
                                                                    .transparent,
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
                                                                    onTap: () {
                                                                      FocusScope.of(
                                                                              context)
                                                                          .unfocus();
                                                                      FocusManager
                                                                          .instance
                                                                          .primaryFocus
                                                                          ?.unfocus();
                                                                    },
                                                                    child:
                                                                        Padding(
                                                                      padding: MediaQuery
                                                                          .viewInsetsOf(
                                                                              context),
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
                                                            child: Icon(
                                                              Icons
                                                                  .keyboard_control,
                                                              color: FlutterFlowTheme
                                                                      .of(context)
                                                                  .primaryText,
                                                              size: 20.0,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ].divide(
                                                      SizedBox(width: 8.0)),
                                                ),
                                              ),
                                            ),
                                          );
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
                                          text1: '📭 No Notifications Yet',
                                          text2:
                                              'Stay tuned! We’ll let you know when there’s something new to see.',
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
                                            splashColor: Colors.transparent,
                                            focusColor: Colors.transparent,
                                            hoverColor: Colors.transparent,
                                            highlightColor: Colors.transparent,
                                            onTap: () async {
                                              if ('${getJsonField(
                                                    eventsItem,
                                                    r'''$.type''',
                                                  ).toString()}' ==
                                                  'event') {
                                                context.pushNamed(
                                                  EventDetailsWidget.routeName,
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
                                                    'btnOption': serializeParam(
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
                                                    await NotificationCall.call(
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
                                                padding: EdgeInsetsDirectional
                                                    .fromSTEB(
                                                        20.0, 8.0, 20.0, 16.0),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  children: [
                                                    ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              4.0),
                                                      child: Image.network(
                                                        getJsonField(
                                                          eventsItem,
                                                          r'''$.profile_image''',
                                                        ).toString(),
                                                        width: 40.0,
                                                        height: 40.0,
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                    Expanded(
                                                      child: Wrap(
                                                        spacing: 0.0,
                                                        runSpacing: 0.0,
                                                        alignment:
                                                            WrapAlignment.start,
                                                        crossAxisAlignment:
                                                            WrapCrossAlignment
                                                                .start,
                                                        direction:
                                                            Axis.horizontal,
                                                        runAlignment:
                                                            WrapAlignment.start,
                                                        verticalDirection:
                                                            VerticalDirection
                                                                .down,
                                                        clipBehavior: Clip.none,
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
                                                                        font: GoogleFonts
                                                                            .manrope(
                                                                          fontWeight:
                                                                              FontWeight.w500,
                                                                          fontStyle: FlutterFlowTheme.of(context)
                                                                              .bodyMedium
                                                                              .fontStyle,
                                                                        ),
                                                                        color: FlutterFlowTheme.of(context)
                                                                            .extraBlack,
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
                                                                        font: GoogleFonts
                                                                            .inter(
                                                                          fontWeight:
                                                                              FontWeight.w500,
                                                                          fontStyle: FlutterFlowTheme.of(context)
                                                                              .bodyMedium
                                                                              .fontStyle,
                                                                        ),
                                                                        color: FlutterFlowTheme.of(context)
                                                                            .greyL4,
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
                                                              style: FlutterFlowTheme
                                                                      .of(context)
                                                                  .bodyMedium
                                                                  .override(
                                                                    font: GoogleFonts
                                                                        .inter(
                                                                      fontWeight: FlutterFlowTheme.of(
                                                                              context)
                                                                          .bodyMedium
                                                                          .fontWeight,
                                                                      fontStyle: FlutterFlowTheme.of(
                                                                              context)
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
                                                                fontSize: 12.0,
                                                                letterSpacing:
                                                                    0.0,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                fontStyle: FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .fontStyle,
                                                                lineHeight: 1.4,
                                                              ),
                                                        ),
                                                        Transform.rotate(
                                                          angle: 90.0 *
                                                              (math.pi / 180),
                                                          child: InkWell(
                                                            splashColor: Colors
                                                                .transparent,
                                                            focusColor: Colors
                                                                .transparent,
                                                            hoverColor: Colors
                                                                .transparent,
                                                            highlightColor:
                                                                Colors
                                                                    .transparent,
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
                                                                    onTap: () {
                                                                      FocusScope.of(
                                                                              context)
                                                                          .unfocus();
                                                                      FocusManager
                                                                          .instance
                                                                          .primaryFocus
                                                                          ?.unfocus();
                                                                    },
                                                                    child:
                                                                        Padding(
                                                                      padding: MediaQuery
                                                                          .viewInsetsOf(
                                                                              context),
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
                                                            child: Icon(
                                                              Icons
                                                                  .keyboard_control,
                                                              color: FlutterFlowTheme
                                                                      .of(context)
                                                                  .primaryText,
                                                              size: 20.0,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ].divide(
                                                      SizedBox(width: 8.0)),
                                                ),
                                              ),
                                            ),
                                          );
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
                                          text1: '📭 No Notifications Yet',
                                          text2:
                                              'Stay tuned! We’ll let you know when there’s something new to see.',
                                        );
                                      }

                                      return ListView.builder(
                                        padding: EdgeInsets.zero,
                                        primary: false,
                                        shrinkWrap: true,
                                        scrollDirection: Axis.vertical,
                                        itemCount: business.length,
                                        itemBuilder: (context, businessIndex) {
                                          final businessItem =
                                              business[businessIndex];
                                          return InkWell(
                                            splashColor: Colors.transparent,
                                            focusColor: Colors.transparent,
                                            hoverColor: Colors.transparent,
                                            highlightColor: Colors.transparent,
                                            onTap: () async {
                                              context.pushNamed(
                                                BusinessHomePageWidget
                                                    .routeName,
                                                queryParameters: {
                                                  'businessId': serializeParam(
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
                                                    await NotificationCall.call(
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
                                                padding: EdgeInsetsDirectional
                                                    .fromSTEB(
                                                        20.0, 8.0, 20.0, 16.0),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  children: [
                                                    ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              4.0),
                                                      child: Image.network(
                                                        getJsonField(
                                                          businessItem,
                                                          r'''$.profile_image''',
                                                        ).toString(),
                                                        width: 40.0,
                                                        height: 40.0,
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                    Expanded(
                                                      child: Wrap(
                                                        spacing: 0.0,
                                                        runSpacing: 0.0,
                                                        alignment:
                                                            WrapAlignment.start,
                                                        crossAxisAlignment:
                                                            WrapCrossAlignment
                                                                .start,
                                                        direction:
                                                            Axis.horizontal,
                                                        runAlignment:
                                                            WrapAlignment.start,
                                                        verticalDirection:
                                                            VerticalDirection
                                                                .down,
                                                        clipBehavior: Clip.none,
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
                                                                        font: GoogleFonts
                                                                            .manrope(
                                                                          fontWeight:
                                                                              FontWeight.w500,
                                                                          fontStyle: FlutterFlowTheme.of(context)
                                                                              .bodyMedium
                                                                              .fontStyle,
                                                                        ),
                                                                        color: FlutterFlowTheme.of(context)
                                                                            .extraBlack,
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
                                                                        font: GoogleFonts
                                                                            .inter(
                                                                          fontWeight:
                                                                              FontWeight.w500,
                                                                          fontStyle: FlutterFlowTheme.of(context)
                                                                              .bodyMedium
                                                                              .fontStyle,
                                                                        ),
                                                                        color: FlutterFlowTheme.of(context)
                                                                            .greyL4,
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
                                                              style: FlutterFlowTheme
                                                                      .of(context)
                                                                  .bodyMedium
                                                                  .override(
                                                                    font: GoogleFonts
                                                                        .inter(
                                                                      fontWeight: FlutterFlowTheme.of(
                                                                              context)
                                                                          .bodyMedium
                                                                          .fontWeight,
                                                                      fontStyle: FlutterFlowTheme.of(
                                                                              context)
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
                                                                fontSize: 12.0,
                                                                letterSpacing:
                                                                    0.0,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                fontStyle: FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .fontStyle,
                                                                lineHeight: 1.4,
                                                              ),
                                                        ),
                                                        Transform.rotate(
                                                          angle: 90.0 *
                                                              (math.pi / 180),
                                                          child: InkWell(
                                                            splashColor: Colors
                                                                .transparent,
                                                            focusColor: Colors
                                                                .transparent,
                                                            hoverColor: Colors
                                                                .transparent,
                                                            highlightColor:
                                                                Colors
                                                                    .transparent,
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
                                                                    onTap: () {
                                                                      FocusScope.of(
                                                                              context)
                                                                          .unfocus();
                                                                      FocusManager
                                                                          .instance
                                                                          .primaryFocus
                                                                          ?.unfocus();
                                                                    },
                                                                    child:
                                                                        Padding(
                                                                      padding: MediaQuery
                                                                          .viewInsetsOf(
                                                                              context),
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
                                                            child: Icon(
                                                              Icons
                                                                  .keyboard_control,
                                                              color: FlutterFlowTheme
                                                                      .of(context)
                                                                  .primaryText,
                                                              size: 20.0,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ].divide(
                                                      SizedBox(width: 8.0)),
                                                ),
                                              ),
                                            ),
                                          );
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
                                          text1: '📭 No Notifications Yet',
                                          text2:
                                              'Stay tuned! We’ll let you know when there’s something new to see.',
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
                                            splashColor: Colors.transparent,
                                            focusColor: Colors.transparent,
                                            hoverColor: Colors.transparent,
                                            highlightColor: Colors.transparent,
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
                                                    await NotificationCall.call(
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
                                                padding: EdgeInsetsDirectional
                                                    .fromSTEB(
                                                        20.0, 8.0, 20.0, 16.0),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  children: [
                                                    ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              4.0),
                                                      child: Image.network(
                                                        getJsonField(
                                                          saleItem,
                                                          r'''$.profile_image''',
                                                        ).toString(),
                                                        width: 40.0,
                                                        height: 40.0,
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                    Expanded(
                                                      child: Wrap(
                                                        spacing: 0.0,
                                                        runSpacing: 0.0,
                                                        alignment:
                                                            WrapAlignment.start,
                                                        crossAxisAlignment:
                                                            WrapCrossAlignment
                                                                .start,
                                                        direction:
                                                            Axis.horizontal,
                                                        runAlignment:
                                                            WrapAlignment.start,
                                                        verticalDirection:
                                                            VerticalDirection
                                                                .down,
                                                        clipBehavior: Clip.none,
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
                                                                        font: GoogleFonts
                                                                            .manrope(
                                                                          fontWeight:
                                                                              FontWeight.w500,
                                                                          fontStyle: FlutterFlowTheme.of(context)
                                                                              .bodyMedium
                                                                              .fontStyle,
                                                                        ),
                                                                        color: FlutterFlowTheme.of(context)
                                                                            .extraBlack,
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
                                                                        font: GoogleFonts
                                                                            .inter(
                                                                          fontWeight:
                                                                              FontWeight.w500,
                                                                          fontStyle: FlutterFlowTheme.of(context)
                                                                              .bodyMedium
                                                                              .fontStyle,
                                                                        ),
                                                                        color: FlutterFlowTheme.of(context)
                                                                            .greyL4,
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
                                                              style: FlutterFlowTheme
                                                                      .of(context)
                                                                  .bodyMedium
                                                                  .override(
                                                                    font: GoogleFonts
                                                                        .inter(
                                                                      fontWeight: FlutterFlowTheme.of(
                                                                              context)
                                                                          .bodyMedium
                                                                          .fontWeight,
                                                                      fontStyle: FlutterFlowTheme.of(
                                                                              context)
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
                                                                fontSize: 12.0,
                                                                letterSpacing:
                                                                    0.0,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                fontStyle: FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .fontStyle,
                                                                lineHeight: 1.4,
                                                              ),
                                                        ),
                                                        Transform.rotate(
                                                          angle: 90.0 *
                                                              (math.pi / 180),
                                                          child: InkWell(
                                                            splashColor: Colors
                                                                .transparent,
                                                            focusColor: Colors
                                                                .transparent,
                                                            hoverColor: Colors
                                                                .transparent,
                                                            highlightColor:
                                                                Colors
                                                                    .transparent,
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
                                                                    onTap: () {
                                                                      FocusScope.of(
                                                                              context)
                                                                          .unfocus();
                                                                      FocusManager
                                                                          .instance
                                                                          .primaryFocus
                                                                          ?.unfocus();
                                                                    },
                                                                    child:
                                                                        Padding(
                                                                      padding: MediaQuery
                                                                          .viewInsetsOf(
                                                                              context),
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
                                                            child: Icon(
                                                              Icons
                                                                  .keyboard_control,
                                                              color: FlutterFlowTheme
                                                                      .of(context)
                                                                  .primaryText,
                                                              size: 20.0,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ].divide(
                                                      SizedBox(width: 8.0)),
                                                ),
                                              ),
                                            ),
                                          );
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
