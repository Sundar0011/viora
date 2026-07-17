import '/auth/supabase_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/backend/supabase/supabase.dart';
import '/components/comp_no_data_found_widget.dart';
import '/components/comp_share_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/pages/business/comp_business_contact/comp_business_contact_widget.dart';
import '/pages/components/comp_navbar/comp_navbar_widget.dart';
import '/pages/home/comp_loading/comp_loading_widget.dart';
import 'dart:ui';
import '/custom_code/actions/index.dart' as actions;
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'community_model.dart';
export 'community_model.dart';

class CommunityWidget extends StatefulWidget {
  const CommunityWidget({
    super.key,
    this.pageType,
  });

  final String? pageType;

  static String routeName = 'Community';
  static String routePath = 'community';

  @override
  State<CommunityWidget> createState() => _CommunityWidgetState();
}

class _CommunityWidgetState extends State<CommunityWidget> {
  late CommunityModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => CommunityModel());

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      await actions.fetchGroupsWithStatusRealtime();
      if (widget!.pageType == 'businesscreate') {
        _model.switchBtn = 'business';
        safeSetState(() {});
      }
      await actions.unsubscribe(
        'event_attending',
      );
      await Future.delayed(
        Duration(
          milliseconds: 1000,
        ),
      );
      await actions.subscribe(
        'event_attending',
        () async {
          safeSetState(() => _model.requestCompleter1 = null);
          await _model.waitForRequestCompleted1();
        },
      );
      await actions.unsubscribe(
        'event_page',
      );
      await Future.delayed(
        Duration(
          milliseconds: 1000,
        ),
      );
      await actions.subscribe(
        'event_page',
        () async {
          safeSetState(() => _model.requestCompleter3 = null);
          await _model.waitForRequestCompleted3();
          safeSetState(() => _model.requestCompleter2 = null);
          await _model.waitForRequestCompleted2();
          safeSetState(() => _model.requestCompleter4 = null);
          await _model.waitForRequestCompleted4();
        },
      );
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
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color:
                              FlutterFlowTheme.of(context).secondaryBackground,
                        ),
                        child: Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              0.0, 12.0, 0.0, 12.0),
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
                                          'group',
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
                                          color: FlutterFlowTheme.of(context)
                                              .greyL4,
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
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMedium
                                                          .fontStyle,
                                                ),
                                                color:
                                                    FlutterFlowTheme.of(context)
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
                              InkWell(
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
                                child: Container(
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
                                  child: Stack(
                                    alignment: AlignmentDirectional(0.0, 0.0),
                                    children: [
                                      Icon(
                                        Icons.message_rounded,
                                        color: FlutterFlowTheme.of(context)
                                            .primaryText,
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
                                          alignment:
                                              AlignmentDirectional(1.0, -1.0),
                                          child: Padding(
                                            padding:
                                                EdgeInsetsDirectional.fromSTEB(
                                                    0.0, 5.0, 5.0, 0.0),
                                            child: Container(
                                              width: 10.0,
                                              height: 10.0,
                                              decoration: BoxDecoration(
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .greyL2,
                                                borderRadius:
                                                    BorderRadius.circular(24.0),
                                              ),
                                              alignment: AlignmentDirectional(
                                                  0.0, 0.0),
                                              child: Container(
                                                width: 5.0,
                                                height: 5.0,
                                                decoration: BoxDecoration(
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .primary,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          24.0),
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
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Expanded(
                            child: InkWell(
                              splashColor: Colors.transparent,
                              focusColor: Colors.transparent,
                              hoverColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              onTap: () async {
                                _model.switchOpt = 'groups';
                                safeSetState(() {});
                                await Future.delayed(
                                  Duration(
                                    milliseconds: 200,
                                  ),
                                );
                                _model.switchOpt = null;
                                safeSetState(() {});
                                _model.switchBtn = 'groups';
                                safeSetState(() {});
                              },
                              child: AnimatedContainer(
                                duration: Duration(milliseconds: 300),
                                curve: Curves.easeOut,
                                height: 48.0,
                                decoration: BoxDecoration(
                                  color: FlutterFlowTheme.of(context).white,
                                ),
                                child: SingleChildScrollView(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      Container(
                                        height: 46.0,
                                        decoration: BoxDecoration(),
                                        child: Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  0.0, 12.0, 0.0, 10.0),
                                          child: Stack(
                                            children: [
                                              if (_model.switchBtn != 'groups')
                                                Text(
                                                  'Groups',
                                                  style: FlutterFlowTheme.of(
                                                          context)
                                                      .bodyMedium
                                                      .override(
                                                        font:
                                                            GoogleFonts.manrope(
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMedium
                                                                  .fontStyle,
                                                        ),
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .greyL4,
                                                        fontSize: 18.0,
                                                        letterSpacing: 0.0,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyMedium
                                                                .fontStyle,
                                                        lineHeight: 1.4,
                                                      ),
                                                ),
                                              if (_model.switchBtn == 'groups')
                                                Text(
                                                  'Groups',
                                                  style: FlutterFlowTheme.of(
                                                          context)
                                                      .bodyMedium
                                                      .override(
                                                        font:
                                                            GoogleFonts.manrope(
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMedium
                                                                  .fontStyle,
                                                        ),
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .primary,
                                                        fontSize: 18.0,
                                                        letterSpacing: 0.0,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyMedium
                                                                .fontStyle,
                                                        lineHeight: 1.4,
                                                      ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      if (_model.switchBtn == 'groups')
                                        Container(
                                          width: double.infinity,
                                          height: 2.0,
                                          decoration: BoxDecoration(
                                            color: FlutterFlowTheme.of(context)
                                                .primary,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
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
                                _model.switchBtn = 'events';
                                safeSetState(() {});
                              },
                              child: AnimatedContainer(
                                duration: Duration(milliseconds: 300),
                                curve: Curves.easeOut,
                                height: 48.0,
                                decoration: BoxDecoration(
                                  color: FlutterFlowTheme.of(context).white,
                                ),
                                child: SingleChildScrollView(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Container(
                                        height: 46.0,
                                        decoration: BoxDecoration(),
                                        child: Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  0.0, 12.0, 0.0, 10.0),
                                          child: Stack(
                                            children: [
                                              if (_model.switchBtn != 'events')
                                                Text(
                                                  'Events',
                                                  style: FlutterFlowTheme.of(
                                                          context)
                                                      .bodyMedium
                                                      .override(
                                                        font:
                                                            GoogleFonts.manrope(
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMedium
                                                                  .fontStyle,
                                                        ),
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .greyL4,
                                                        fontSize: 18.0,
                                                        letterSpacing: 0.0,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyMedium
                                                                .fontStyle,
                                                        lineHeight: 1.4,
                                                      ),
                                                ),
                                              if (_model.switchBtn == 'events')
                                                Text(
                                                  'Events',
                                                  style: FlutterFlowTheme.of(
                                                          context)
                                                      .bodyMedium
                                                      .override(
                                                        font:
                                                            GoogleFonts.manrope(
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMedium
                                                                  .fontStyle,
                                                        ),
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .primary,
                                                        fontSize: 18.0,
                                                        letterSpacing: 0.0,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyMedium
                                                                .fontStyle,
                                                        lineHeight: 1.4,
                                                      ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      if (_model.switchBtn == 'events')
                                        Container(
                                          width: double.infinity,
                                          height: 2.0,
                                          decoration: BoxDecoration(
                                            color: FlutterFlowTheme.of(context)
                                                .primary,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
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
                                _model.switchOpt = 'business';
                                safeSetState(() {});
                                await Future.delayed(
                                  Duration(
                                    milliseconds: 200,
                                  ),
                                );
                                _model.switchOpt = null;
                                safeSetState(() {});
                                _model.switchBtn = 'business';
                                safeSetState(() {});
                              },
                              child: AnimatedContainer(
                                duration: Duration(milliseconds: 300),
                                curve: Curves.easeOut,
                                height: 48.0,
                                decoration: BoxDecoration(
                                  color: FlutterFlowTheme.of(context).white,
                                ),
                                child: SingleChildScrollView(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Container(
                                        height: 46.0,
                                        decoration: BoxDecoration(),
                                        child: Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  0.0, 12.0, 0.0, 10.0),
                                          child: Stack(
                                            children: [
                                              if (_model.switchBtn !=
                                                  'business')
                                                Text(
                                                  'Business',
                                                  style: FlutterFlowTheme.of(
                                                          context)
                                                      .bodyMedium
                                                      .override(
                                                        font:
                                                            GoogleFonts.manrope(
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMedium
                                                                  .fontStyle,
                                                        ),
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .greyL4,
                                                        fontSize: 18.0,
                                                        letterSpacing: 0.0,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyMedium
                                                                .fontStyle,
                                                        lineHeight: 1.4,
                                                      ),
                                                ),
                                              if (_model.switchBtn ==
                                                  'business')
                                                Text(
                                                  'Business',
                                                  style: FlutterFlowTheme.of(
                                                          context)
                                                      .bodyMedium
                                                      .override(
                                                        font:
                                                            GoogleFonts.manrope(
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMedium
                                                                  .fontStyle,
                                                        ),
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .primary,
                                                        fontSize: 18.0,
                                                        letterSpacing: 0.0,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyMedium
                                                                .fontStyle,
                                                        lineHeight: 1.4,
                                                      ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      if (_model.switchBtn == 'business')
                                        Container(
                                          width: double.infinity,
                                          height: 2.0,
                                          decoration: BoxDecoration(
                                            color: FlutterFlowTheme.of(context)
                                                .primary,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (_model.switchBtn == 'groups')
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      0.0, 4.0, 0.0, 0.0),
                                  child: Container(
                                    width: double.infinity,
                                    height: 52.0,
                                    decoration: BoxDecoration(
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryBackground,
                                    ),
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Row(
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          InkWell(
                                            splashColor: Colors.transparent,
                                            focusColor: Colors.transparent,
                                            hoverColor: Colors.transparent,
                                            highlightColor: Colors.transparent,
                                            onTap: () async {
                                              _model.option = 'invitations';
                                              safeSetState(() {});

                                              context.pushNamed(
                                                MyGroupWidget.routeName,
                                                queryParameters: {
                                                  'initialButton':
                                                      serializeParam(
                                                    'invitations',
                                                    ParamType.String,
                                                  ),
                                                }.withoutNulls,
                                              );
                                            },
                                            child: Container(
                                              height: 36.0,
                                              decoration: BoxDecoration(
                                                color: _model.option == '1'
                                                    ? Color(0xFF0F8849)
                                                    : FlutterFlowTheme.of(
                                                            context)
                                                        .white,
                                                borderRadius:
                                                    BorderRadius.circular(24.0),
                                                border: Border.all(
                                                  color: _model.option != '1'
                                                      ? FlutterFlowTheme.of(
                                                              context)
                                                          .greyL4
                                                      : FlutterFlowTheme.of(
                                                              context)
                                                          .white,
                                                ),
                                              ),
                                              child: Align(
                                                alignment: AlignmentDirectional(
                                                    0.0, 0.0),
                                                child: Padding(
                                                  padding: EdgeInsetsDirectional
                                                      .fromSTEB(
                                                          24.0, 0.0, 24.0, 0.0),
                                                  child: Text(
                                                    'Invitations  (${valueOrDefault<String>(
                                                      getJsonField(
                                                        FFAppState()
                                                            .AsGroupList,
                                                        r'''$[0].total_invited''',
                                                      )?.toString(),
                                                      '0',
                                                    )})',
                                                    style:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .bodyMedium
                                                            .override(
                                                              font: GoogleFonts
                                                                  .manrope(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                fontStyle: FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .fontStyle,
                                                              ),
                                                              color: _model
                                                                          .option !=
                                                                      '1'
                                                                  ? FlutterFlowTheme.of(
                                                                          context)
                                                                      .greyL4
                                                                  : FlutterFlowTheme.of(
                                                                          context)
                                                                      .white,
                                                              letterSpacing:
                                                                  0.0,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              fontStyle:
                                                                  FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMedium
                                                                      .fontStyle,
                                                              lineHeight: 1.4,
                                                            ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          InkWell(
                                            splashColor: Colors.transparent,
                                            focusColor: Colors.transparent,
                                            hoverColor: Colors.transparent,
                                            highlightColor: Colors.transparent,
                                            onTap: () async {
                                              _model.option = 'myGroups';
                                              safeSetState(() {});
                                              await Future.delayed(
                                                Duration(
                                                  milliseconds: 500,
                                                ),
                                              );
                                              _model.option = '';
                                              safeSetState(() {});

                                              context.pushNamed(
                                                MyGroupWidget.routeName,
                                                queryParameters: {
                                                  'initialButton':
                                                      serializeParam(
                                                    'all',
                                                    ParamType.String,
                                                  ),
                                                }.withoutNulls,
                                              );
                                            },
                                            child: Container(
                                              height: 36.0,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(24.0),
                                                border: Border.all(
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .greyL4,
                                                ),
                                              ),
                                              child: Align(
                                                alignment: AlignmentDirectional(
                                                    0.0, 0.0),
                                                child: Padding(
                                                  padding: EdgeInsetsDirectional
                                                      .fromSTEB(
                                                          24.0, 0.0, 24.0, 0.0),
                                                  child: Text(
                                                    'My Groups',
                                                    style:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .bodyMedium
                                                            .override(
                                                              font: GoogleFonts
                                                                  .manrope(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                fontStyle: FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .fontStyle,
                                                              ),
                                                              color: _model
                                                                          .option !=
                                                                      '2'
                                                                  ? FlutterFlowTheme.of(
                                                                          context)
                                                                      .greyL4
                                                                  : FlutterFlowTheme.of(
                                                                          context)
                                                                      .white,
                                                              letterSpacing:
                                                                  0.0,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              fontStyle:
                                                                  FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMedium
                                                                      .fontStyle,
                                                              lineHeight: 1.4,
                                                            ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          InkWell(
                                            splashColor: Colors.transparent,
                                            focusColor: Colors.transparent,
                                            hoverColor: Colors.transparent,
                                            highlightColor: Colors.transparent,
                                            onTap: () async {
                                              context.pushNamed(
                                                  CreateGroupWidget.routeName);
                                            },
                                            child: Container(
                                              height: 36.0,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(24.0),
                                                border: Border.all(
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .greyL4,
                                                ),
                                              ),
                                              child: Align(
                                                alignment: AlignmentDirectional(
                                                    0.0, 0.0),
                                                child: Padding(
                                                  padding: EdgeInsetsDirectional
                                                      .fromSTEB(
                                                          24.0, 0.0, 24.0, 0.0),
                                                  child: Text(
                                                    'Create Group',
                                                    style:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .bodyMedium
                                                            .override(
                                                              font: GoogleFonts
                                                                  .manrope(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                fontStyle: FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .fontStyle,
                                                              ),
                                                              color: _model
                                                                          .option !=
                                                                      '2'
                                                                  ? FlutterFlowTheme.of(
                                                                          context)
                                                                      .greyL4
                                                                  : FlutterFlowTheme.of(
                                                                          context)
                                                                      .white,
                                                              letterSpacing:
                                                                  0.0,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              fontStyle:
                                                                  FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMedium
                                                                      .fontStyle,
                                                              lineHeight: 1.4,
                                                            ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ]
                                            .divide(SizedBox(width: 8.0))
                                            .addToStart(SizedBox(width: 20.0))
                                            .addToEnd(SizedBox(width: 20.0)),
                                      ),
                                    ),
                                  ),
                                ),
                                if ('${getJsonField(
                                      FFAppState().AsGroupList,
                                      r'''$[0].nearest_count''',
                                    ).toString()}' !=
                                    '0')
                                  Container(
                                    decoration: BoxDecoration(),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  0.0, 8.0, 0.0, 0.0),
                                          child: Container(
                                            width: double.infinity,
                                            decoration: BoxDecoration(
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .secondaryBackground,
                                            ),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.max,
                                              children: [
                                                Padding(
                                                  padding: EdgeInsetsDirectional
                                                      .fromSTEB(20.0, 12.0,
                                                          20.0, 8.0),
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    children: [
                                                      Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .secondaryBackground,
                                                        ),
                                                        child: Row(
                                                          mainAxisSize:
                                                              MainAxisSize.max,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Text(
                                                              'Near You',
                                                              style: FlutterFlowTheme
                                                                      .of(context)
                                                                  .bodyMedium
                                                                  .override(
                                                                    font: GoogleFonts
                                                                        .manrope(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600,
                                                                      fontStyle: FlutterFlowTheme.of(
                                                                              context)
                                                                          .bodyMedium
                                                                          .fontStyle,
                                                                    ),
                                                                    color: FlutterFlowTheme.of(
                                                                            context)
                                                                        .extraBlack,
                                                                    fontSize:
                                                                        18.0,
                                                                    letterSpacing:
                                                                        0.0,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                    fontStyle: FlutterFlowTheme.of(
                                                                            context)
                                                                        .bodyMedium
                                                                        .fontStyle,
                                                                    lineHeight:
                                                                        1.4,
                                                                  ),
                                                            ),
                                                            InkWell(
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
                                                                context.pushNamed(
                                                                    NearestGroupsWidget
                                                                        .routeName);
                                                              },
                                                              child: Icon(
                                                                Icons
                                                                    .arrow_forward,
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .primaryText,
                                                                size: 24.0,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Container(
                                                  width: double.infinity,
                                                  height: 1.0,
                                                  decoration: BoxDecoration(
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .secondaryBackground,
                                                  ),
                                                ),
                                                Container(
                                                  width: double.infinity,
                                                  height: 1.0,
                                                  decoration: BoxDecoration(
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .greyL2,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Container(
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                            color: FlutterFlowTheme.of(context)
                                                .secondaryBackground,
                                          ),
                                          child: Visibility(
                                            visible: '${getJsonField(
                                                  FFAppState().AsGroupList,
                                                  r'''$''',
                                                ).toString()}' !=
                                                '[]',
                                            child: Builder(
                                              builder: (context) {
                                                final grops = getJsonField(
                                                  FFAppState().AsGroupList,
                                                  r'''$''',
                                                ).toList().take(4).toList();

                                                return ListView.separated(
                                                  padding: EdgeInsets.fromLTRB(
                                                    0,
                                                    12.0,
                                                    0,
                                                    12.0,
                                                  ),
                                                  primary: false,
                                                  shrinkWrap: true,
                                                  scrollDirection:
                                                      Axis.vertical,
                                                  itemCount: grops.length,
                                                  separatorBuilder: (_, __) =>
                                                      SizedBox(height: 12.0),
                                                  itemBuilder:
                                                      (context, gropsIndex) {
                                                    final gropsItem =
                                                        grops[gropsIndex];
                                                    return Visibility(
                                                      visible: (('${getJsonField(
                                                                    gropsItem,
                                                                    r'''$.e_discoverability''',
                                                                  ).toString()}' ==
                                                                  'listed') &&
                                                              ('${getJsonField(
                                                                    gropsItem,
                                                                    r'''$.nearest''',
                                                                  ).toString()}' ==
                                                                  'true')) ||
                                                          (('${getJsonField(
                                                                    gropsItem,
                                                                    r'''$.e_discoverability''',
                                                                  ).toString()}' ==
                                                                  'unlisted') &&
                                                              ('${getJsonField(
                                                                    gropsItem,
                                                                    r'''$.user_status''',
                                                                  ).toString()}' ==
                                                                  'joined')) ||
                                                          (('${getJsonField(
                                                                    gropsItem,
                                                                    r'''$.e_discoverability''',
                                                                  ).toString()}' ==
                                                                  'unlisted') &&
                                                              ('${getJsonField(
                                                                    gropsItem,
                                                                    r'''$.user_status''',
                                                                  ).toString()}' ==
                                                                  'admin')) ||
                                                          (('${getJsonField(
                                                                    gropsItem,
                                                                    r'''$.e_discoverability''',
                                                                  ).toString()}' ==
                                                                  'unlisted') &&
                                                              ('${getJsonField(
                                                                    gropsItem,
                                                                    r'''$.user_status''',
                                                                  ).toString()}' ==
                                                                  'invite')) ||
                                                          (('${getJsonField(
                                                                    gropsItem,
                                                                    r'''$.e_discoverability''',
                                                                  ).toString()}' ==
                                                                  'unlisted') &&
                                                              ('${getJsonField(
                                                                    gropsItem,
                                                                    r'''$.user_status''',
                                                                  ).toString()}' ==
                                                                  'requested')) ||
                                                          ('${getJsonField(
                                                                gropsItem,
                                                                r'''$.nearest''',
                                                              ).toString()}' ==
                                                              'true'),
                                                      child: InkWell(
                                                        splashColor:
                                                            Colors.transparent,
                                                        focusColor:
                                                            Colors.transparent,
                                                        hoverColor:
                                                            Colors.transparent,
                                                        highlightColor:
                                                            Colors.transparent,
                                                        onTap: () async {
                                                          context.pushNamed(
                                                            GroupDetailsWidget
                                                                .routeName,
                                                            queryParameters: {
                                                              'groupId':
                                                                  serializeParam(
                                                                getJsonField(
                                                                  gropsItem,
                                                                  r'''$.group_id''',
                                                                ).toString(),
                                                                ParamType
                                                                    .String,
                                                              ),
                                                            }.withoutNulls,
                                                          );
                                                        },
                                                        child: Container(
                                                          width:
                                                              double.infinity,
                                                          height: 56.0,
                                                          decoration:
                                                              BoxDecoration(
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .secondaryBackground,
                                                          ),
                                                          child: Padding(
                                                            padding:
                                                                EdgeInsetsDirectional
                                                                    .fromSTEB(
                                                                        20.0,
                                                                        8.0,
                                                                        20.0,
                                                                        8.0),
                                                            child: Row(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .max,
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                Expanded(
                                                                  child: Row(
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .max,
                                                                    children: [
                                                                      ClipRRect(
                                                                        borderRadius:
                                                                            BorderRadius.circular(2.0),
                                                                        child: Image
                                                                            .network(
                                                                          getJsonField(
                                                                            gropsItem,
                                                                            r'''$.profile_picture''',
                                                                          ).toString(),
                                                                          width:
                                                                              40.0,
                                                                          height:
                                                                              40.0,
                                                                          fit: BoxFit
                                                                              .cover,
                                                                        ),
                                                                      ),
                                                                      Expanded(
                                                                        child:
                                                                            Column(
                                                                          mainAxisSize:
                                                                              MainAxisSize.max,
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.start,
                                                                          children: [
                                                                            if (('${getJsonField(
                                                                                      gropsItem,
                                                                                      r'''$.invited_by_user_id''',
                                                                                    ).toString()}' !=
                                                                                    'null') &&
                                                                                ('${getJsonField(
                                                                                      gropsItem,
                                                                                      r'''$.user_status''',
                                                                                    ).toString()}' ==
                                                                                    'invite'))
                                                                              Row(
                                                                                mainAxisSize: MainAxisSize.max,
                                                                                children: [
                                                                                  Container(
                                                                                    width: 12.0,
                                                                                    height: 12.0,
                                                                                    clipBehavior: Clip.antiAlias,
                                                                                    decoration: BoxDecoration(
                                                                                      shape: BoxShape.circle,
                                                                                    ),
                                                                                    child: Image.network(
                                                                                      getJsonField(
                                                                                        gropsItem,
                                                                                        r'''$.invited_by_profile_picture''',
                                                                                      ).toString(),
                                                                                      fit: BoxFit.cover,
                                                                                    ),
                                                                                  ),
                                                                                  Expanded(
                                                                                    child: Text(
                                                                                      '${getJsonField(
                                                                                        gropsItem,
                                                                                        r'''$.invited_by_name''',
                                                                                      ).toString()} invited you to join this group ',
                                                                                      maxLines: 1,
                                                                                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                            font: GoogleFonts.manrope(
                                                                                              fontWeight: FontWeight.w500,
                                                                                              fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                            ),
                                                                                            color: FlutterFlowTheme.of(context).greyL4,
                                                                                            fontSize: 10.0,
                                                                                            letterSpacing: 0.0,
                                                                                            fontWeight: FontWeight.w500,
                                                                                            fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                            lineHeight: 1.4,
                                                                                          ),
                                                                                    ),
                                                                                  ),
                                                                                ].divide(SizedBox(width: 6.0)),
                                                                              ),
                                                                            Text(
                                                                              getJsonField(
                                                                                gropsItem,
                                                                                r'''$.name''',
                                                                              ).toString(),
                                                                              maxLines: 1,
                                                                              style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                    font: GoogleFonts.manrope(
                                                                                      fontWeight: FontWeight.w600,
                                                                                      fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                    ),
                                                                                    color: FlutterFlowTheme.of(context).extraBlack,
                                                                                    fontSize: 16.0,
                                                                                    letterSpacing: 0.0,
                                                                                    fontWeight: FontWeight.w600,
                                                                                    fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                    lineHeight: 1.4,
                                                                                  ),
                                                                            ),
                                                                            if ('${getJsonField(
                                                                                  gropsItem,
                                                                                  r'''$.user_status''',
                                                                                ).toString()}' !=
                                                                                'invite')
                                                                              Text(
                                                                                '${getJsonField(
                                                                                  gropsItem,
                                                                                  r'''$.total_members''',
                                                                                ).toString()} members',
                                                                                style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                      font: GoogleFonts.manrope(
                                                                                        fontWeight: FontWeight.w500,
                                                                                        fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                      ),
                                                                                      color: FlutterFlowTheme.of(context).greyL4,
                                                                                      fontSize: 10.0,
                                                                                      letterSpacing: 0.0,
                                                                                      fontWeight: FontWeight.w500,
                                                                                      fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                      lineHeight: 1.4,
                                                                                    ),
                                                                              ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ].divide(SizedBox(
                                                                        width:
                                                                            8.0)),
                                                                  ),
                                                                ),
                                                                Stack(
                                                                  children: [
                                                                    if ('${getJsonField(
                                                                          gropsItem,
                                                                          r'''$.user_status''',
                                                                        ).toString()}' ==
                                                                        'join')
                                                                      FFButtonWidget(
                                                                        onPressed:
                                                                            () async {
                                                                          await GroupMembersTable()
                                                                              .insert({
                                                                            'community_id':
                                                                                FFAppState().communityId,
                                                                            'user_id':
                                                                                currentUserUid,
                                                                            'group_id':
                                                                                getJsonField(
                                                                              gropsItem,
                                                                              r'''$.group_id''',
                                                                            ).toString(),
                                                                            'is_requested':
                                                                                false,
                                                                            'requested_date':
                                                                                supaSerialize<DateTime>(functions.getCurrentUtcTime()),
                                                                            'is_approved':
                                                                                true,
                                                                            'approved_by':
                                                                                currentUserUid,
                                                                            'joined_at':
                                                                                supaSerialize<DateTime>(functions.getCurrentUtcTime()),
                                                                          });
                                                                          await GroupUserStatusTable()
                                                                              .insert({
                                                                            'community_id':
                                                                                FFAppState().communityId,
                                                                            'user_id':
                                                                                currentUserUid,
                                                                            'group_id':
                                                                                getJsonField(
                                                                              gropsItem,
                                                                              r'''$.group_id''',
                                                                            ).toString(),
                                                                            'is_requested':
                                                                                false,
                                                                            'is_invited':
                                                                                false,
                                                                            'is_member':
                                                                                true,
                                                                            'joined_at':
                                                                                supaSerialize<DateTime>(functions.getCurrentUtcTime()),
                                                                          });
                                                                          _model.apiResultd2p =
                                                                              await UpdateTotalGroupMembersCall.call(
                                                                            token:
                                                                                currentJwtToken,
                                                                            anonKey:
                                                                                FFDevEnvironmentValues().AnonKey,
                                                                            groupId:
                                                                                getJsonField(
                                                                              gropsItem,
                                                                              r'''$.group_id''',
                                                                            ).toString(),
                                                                          );

                                                                          safeSetState(
                                                                              () {});
                                                                        },
                                                                        text:
                                                                            'Join',
                                                                        options:
                                                                            FFButtonOptions(
                                                                          height:
                                                                              24.0,
                                                                          padding: EdgeInsetsDirectional.fromSTEB(
                                                                              16.0,
                                                                              0.0,
                                                                              16.0,
                                                                              0.0),
                                                                          iconPadding: EdgeInsetsDirectional.fromSTEB(
                                                                              0.0,
                                                                              0.0,
                                                                              0.0,
                                                                              0.0),
                                                                          color:
                                                                              Color(0x00264AFF),
                                                                          textStyle: FlutterFlowTheme.of(context)
                                                                              .titleSmall
                                                                              .override(
                                                                                font: GoogleFonts.interTight(
                                                                                  fontWeight: FlutterFlowTheme.of(context).titleSmall.fontWeight,
                                                                                  fontStyle: FlutterFlowTheme.of(context).titleSmall.fontStyle,
                                                                                ),
                                                                                color: FlutterFlowTheme.of(context).primaryD3,
                                                                                fontSize: 12.0,
                                                                                letterSpacing: 0.0,
                                                                                fontWeight: FlutterFlowTheme.of(context).titleSmall.fontWeight,
                                                                                fontStyle: FlutterFlowTheme.of(context).titleSmall.fontStyle,
                                                                              ),
                                                                          elevation:
                                                                              0.0,
                                                                          borderSide:
                                                                              BorderSide(
                                                                            color:
                                                                                FlutterFlowTheme.of(context).primaryD3,
                                                                            width:
                                                                                1.0,
                                                                          ),
                                                                          borderRadius:
                                                                              BorderRadius.only(
                                                                            topLeft:
                                                                                Radius.circular(100.0),
                                                                            topRight:
                                                                                Radius.circular(100.0),
                                                                            bottomLeft:
                                                                                Radius.circular(100.0),
                                                                            bottomRight:
                                                                                Radius.circular(100.0),
                                                                          ),
                                                                        ),
                                                                        showLoadingIndicator:
                                                                            false,
                                                                      ),
                                                                    if ('${getJsonField(
                                                                          gropsItem,
                                                                          r'''$.user_status''',
                                                                        ).toString()}' ==
                                                                        'joined')
                                                                      FFButtonWidget(
                                                                        onPressed:
                                                                            () {
                                                                          print(
                                                                              'Joined pressed ...');
                                                                        },
                                                                        text:
                                                                            'Joined',
                                                                        icon:
                                                                            Icon(
                                                                          Icons
                                                                              .done_all,
                                                                          size:
                                                                              15.0,
                                                                        ),
                                                                        options:
                                                                            FFButtonOptions(
                                                                          height:
                                                                              24.0,
                                                                          padding: EdgeInsetsDirectional.fromSTEB(
                                                                              16.0,
                                                                              0.0,
                                                                              16.0,
                                                                              0.0),
                                                                          iconPadding: EdgeInsetsDirectional.fromSTEB(
                                                                              0.0,
                                                                              0.0,
                                                                              0.0,
                                                                              0.0),
                                                                          iconColor:
                                                                              FlutterFlowTheme.of(context).greyL4,
                                                                          color:
                                                                              Color(0x00264AFF),
                                                                          textStyle: FlutterFlowTheme.of(context)
                                                                              .titleSmall
                                                                              .override(
                                                                                font: GoogleFonts.interTight(
                                                                                  fontWeight: FlutterFlowTheme.of(context).titleSmall.fontWeight,
                                                                                  fontStyle: FlutterFlowTheme.of(context).titleSmall.fontStyle,
                                                                                ),
                                                                                color: FlutterFlowTheme.of(context).greyL4,
                                                                                fontSize: 12.0,
                                                                                letterSpacing: 0.0,
                                                                                fontWeight: FlutterFlowTheme.of(context).titleSmall.fontWeight,
                                                                                fontStyle: FlutterFlowTheme.of(context).titleSmall.fontStyle,
                                                                              ),
                                                                          elevation:
                                                                              0.0,
                                                                          borderSide:
                                                                              BorderSide(
                                                                            color:
                                                                                FlutterFlowTheme.of(context).greyL4,
                                                                            width:
                                                                                1.0,
                                                                          ),
                                                                          borderRadius:
                                                                              BorderRadius.only(
                                                                            topLeft:
                                                                                Radius.circular(100.0),
                                                                            topRight:
                                                                                Radius.circular(100.0),
                                                                            bottomLeft:
                                                                                Radius.circular(100.0),
                                                                            bottomRight:
                                                                                Radius.circular(100.0),
                                                                          ),
                                                                        ),
                                                                        showLoadingIndicator:
                                                                            false,
                                                                      ),
                                                                    if ('${getJsonField(
                                                                          gropsItem,
                                                                          r'''$.user_status''',
                                                                        ).toString()}' ==
                                                                        'requested')
                                                                      FFButtonWidget(
                                                                        onPressed:
                                                                            () {
                                                                          print(
                                                                              'Requested pressed ...');
                                                                        },
                                                                        text:
                                                                            'Requested',
                                                                        options:
                                                                            FFButtonOptions(
                                                                          height:
                                                                              24.0,
                                                                          padding: EdgeInsetsDirectional.fromSTEB(
                                                                              16.0,
                                                                              0.0,
                                                                              16.0,
                                                                              0.0),
                                                                          iconPadding: EdgeInsetsDirectional.fromSTEB(
                                                                              0.0,
                                                                              0.0,
                                                                              0.0,
                                                                              0.0),
                                                                          color:
                                                                              FlutterFlowTheme.of(context).greyL2,
                                                                          textStyle: FlutterFlowTheme.of(context)
                                                                              .titleSmall
                                                                              .override(
                                                                                font: GoogleFonts.interTight(
                                                                                  fontWeight: FlutterFlowTheme.of(context).titleSmall.fontWeight,
                                                                                  fontStyle: FlutterFlowTheme.of(context).titleSmall.fontStyle,
                                                                                ),
                                                                                color: FlutterFlowTheme.of(context).greyL3,
                                                                                fontSize: 12.0,
                                                                                letterSpacing: 0.0,
                                                                                fontWeight: FlutterFlowTheme.of(context).titleSmall.fontWeight,
                                                                                fontStyle: FlutterFlowTheme.of(context).titleSmall.fontStyle,
                                                                              ),
                                                                          elevation:
                                                                              0.0,
                                                                          borderRadius:
                                                                              BorderRadius.only(
                                                                            topLeft:
                                                                                Radius.circular(100.0),
                                                                            topRight:
                                                                                Radius.circular(100.0),
                                                                            bottomLeft:
                                                                                Radius.circular(100.0),
                                                                            bottomRight:
                                                                                Radius.circular(100.0),
                                                                          ),
                                                                        ),
                                                                        showLoadingIndicator:
                                                                            false,
                                                                      ),
                                                                    if ('${getJsonField(
                                                                          gropsItem,
                                                                          r'''$.user_status''',
                                                                        ).toString()}' ==
                                                                        'request')
                                                                      FFButtonWidget(
                                                                        onPressed:
                                                                            () async {
                                                                          await GroupUserStatusTable()
                                                                              .insert({
                                                                            'community_id':
                                                                                FFAppState().communityId,
                                                                            'user_id':
                                                                                currentUserUid,
                                                                            'group_id':
                                                                                getJsonField(
                                                                              gropsItem,
                                                                              r'''$.group_id''',
                                                                            ).toString(),
                                                                            'is_requested':
                                                                                true,
                                                                            'is_invited':
                                                                                false,
                                                                            'is_member':
                                                                                false,
                                                                            'is_approved':
                                                                                false,
                                                                            'requested_date':
                                                                                supaSerialize<DateTime>(functions.getCurrentUtcTime()),
                                                                          });
                                                                        },
                                                                        text:
                                                                            'Request',
                                                                        icon:
                                                                            Icon(
                                                                          Icons
                                                                              .lock_outline_sharp,
                                                                          size:
                                                                              15.0,
                                                                        ),
                                                                        options:
                                                                            FFButtonOptions(
                                                                          height:
                                                                              24.0,
                                                                          padding: EdgeInsetsDirectional.fromSTEB(
                                                                              16.0,
                                                                              0.0,
                                                                              16.0,
                                                                              0.0),
                                                                          iconPadding: EdgeInsetsDirectional.fromSTEB(
                                                                              0.0,
                                                                              0.0,
                                                                              0.0,
                                                                              0.0),
                                                                          iconColor:
                                                                              FlutterFlowTheme.of(context).primaryD3,
                                                                          color:
                                                                              Color(0x00264AFF),
                                                                          textStyle: FlutterFlowTheme.of(context)
                                                                              .titleSmall
                                                                              .override(
                                                                                font: GoogleFonts.interTight(
                                                                                  fontWeight: FlutterFlowTheme.of(context).titleSmall.fontWeight,
                                                                                  fontStyle: FlutterFlowTheme.of(context).titleSmall.fontStyle,
                                                                                ),
                                                                                color: FlutterFlowTheme.of(context).primaryD3,
                                                                                fontSize: 12.0,
                                                                                letterSpacing: 0.0,
                                                                                fontWeight: FlutterFlowTheme.of(context).titleSmall.fontWeight,
                                                                                fontStyle: FlutterFlowTheme.of(context).titleSmall.fontStyle,
                                                                              ),
                                                                          elevation:
                                                                              0.0,
                                                                          borderSide:
                                                                              BorderSide(
                                                                            color:
                                                                                FlutterFlowTheme.of(context).primaryD3,
                                                                            width:
                                                                                1.0,
                                                                          ),
                                                                          borderRadius:
                                                                              BorderRadius.only(
                                                                            topLeft:
                                                                                Radius.circular(100.0),
                                                                            topRight:
                                                                                Radius.circular(100.0),
                                                                            bottomLeft:
                                                                                Radius.circular(100.0),
                                                                            bottomRight:
                                                                                Radius.circular(100.0),
                                                                          ),
                                                                        ),
                                                                        showLoadingIndicator:
                                                                            false,
                                                                      ),
                                                                    if ('${getJsonField(
                                                                          gropsItem,
                                                                          r'''$.user_status''',
                                                                        ).toString()}' ==
                                                                        'admin')
                                                                      FFButtonWidget(
                                                                        onPressed:
                                                                            () {
                                                                          print(
                                                                              'Button pressed ...');
                                                                        },
                                                                        text:
                                                                            'Admin',
                                                                        options:
                                                                            FFButtonOptions(
                                                                          height:
                                                                              24.0,
                                                                          padding: EdgeInsetsDirectional.fromSTEB(
                                                                              12.0,
                                                                              0.0,
                                                                              12.0,
                                                                              0.0),
                                                                          iconPadding: EdgeInsetsDirectional.fromSTEB(
                                                                              0.0,
                                                                              0.0,
                                                                              0.0,
                                                                              0.0),
                                                                          color:
                                                                              Color(0xFF23B3A6),
                                                                          textStyle: FlutterFlowTheme.of(context)
                                                                              .titleSmall
                                                                              .override(
                                                                                font: GoogleFonts.interTight(
                                                                                  fontWeight: FlutterFlowTheme.of(context).titleSmall.fontWeight,
                                                                                  fontStyle: FlutterFlowTheme.of(context).titleSmall.fontStyle,
                                                                                ),
                                                                                color: Colors.white,
                                                                                fontSize: 12.0,
                                                                                letterSpacing: 0.0,
                                                                                fontWeight: FlutterFlowTheme.of(context).titleSmall.fontWeight,
                                                                                fontStyle: FlutterFlowTheme.of(context).titleSmall.fontStyle,
                                                                              ),
                                                                          elevation:
                                                                              0.0,
                                                                          borderRadius:
                                                                              BorderRadius.only(
                                                                            topLeft:
                                                                                Radius.circular(100.0),
                                                                            topRight:
                                                                                Radius.circular(100.0),
                                                                            bottomLeft:
                                                                                Radius.circular(100.0),
                                                                            bottomRight:
                                                                                Radius.circular(100.0),
                                                                          ),
                                                                        ),
                                                                        showLoadingIndicator:
                                                                            false,
                                                                      ),
                                                                    if (('${getJsonField(
                                                                              gropsItem,
                                                                              r'''$.user_status''',
                                                                            ).toString()}' ==
                                                                            'invite') &&
                                                                        ('${getJsonField(
                                                                              gropsItem,
                                                                              r'''$.e_group_type''',
                                                                            ).toString()}' ==
                                                                            'open'))
                                                                      FFButtonWidget(
                                                                        onPressed:
                                                                            () async {
                                                                          await GroupMembersTable()
                                                                              .insert({
                                                                            'community_id':
                                                                                FFAppState().communityId,
                                                                            'user_id':
                                                                                currentUserUid,
                                                                            'group_id':
                                                                                getJsonField(
                                                                              gropsItem,
                                                                              r'''$.group_id''',
                                                                            ).toString(),
                                                                            'is_requested':
                                                                                false,
                                                                            'is_approved':
                                                                                true,
                                                                            'approved_by':
                                                                                getJsonField(
                                                                              gropsItem,
                                                                              r'''$.invited_by_user_id''',
                                                                            ).toString(),
                                                                            'joined_at':
                                                                                supaSerialize<DateTime>(functions.getCurrentUtcTime()),
                                                                          });
                                                                          await GroupUserStatusTable()
                                                                              .update(
                                                                            data: {
                                                                              'is_requested': false,
                                                                              'is_member': true,
                                                                              'is_approved': true,
                                                                              'joined_at': supaSerialize<DateTime>(functions.getCurrentUtcTime()),
                                                                            },
                                                                            matchingRows: (rows) => rows
                                                                                .eqOrNull(
                                                                                  'group_id',
                                                                                  getJsonField(
                                                                                    gropsItem,
                                                                                    r'''$.group_id''',
                                                                                  ).toString(),
                                                                                )
                                                                                .eqOrNull(
                                                                                  'user_id',
                                                                                  currentUserUid,
                                                                                ),
                                                                          );
                                                                          await GroupMembersInviteTable()
                                                                              .update(
                                                                            data: {
                                                                              'is_member': true,
                                                                            },
                                                                            matchingRows: (rows) => rows
                                                                                .eqOrNull(
                                                                                  'group_id',
                                                                                  getJsonField(
                                                                                    gropsItem,
                                                                                    r'''$.group_id''',
                                                                                  ).toString(),
                                                                                )
                                                                                .eqOrNull(
                                                                                  'invited_by',
                                                                                  getJsonField(
                                                                                    gropsItem,
                                                                                    r'''$.invited_by_user_id''',
                                                                                  ).toString(),
                                                                                )
                                                                                .eqOrNull(
                                                                                  'invited_user',
                                                                                  currentUserUid,
                                                                                ),
                                                                          );
                                                                          _model.apiResultd2pp =
                                                                              await UpdateTotalGroupMembersCall.call(
                                                                            token:
                                                                                currentJwtToken,
                                                                            anonKey:
                                                                                FFDevEnvironmentValues().AnonKey,
                                                                            groupId:
                                                                                getJsonField(
                                                                              gropsItem,
                                                                              r'''$.group_id''',
                                                                            ).toString(),
                                                                          );

                                                                          safeSetState(
                                                                              () {});
                                                                        },
                                                                        text:
                                                                            'Join',
                                                                        options:
                                                                            FFButtonOptions(
                                                                          height:
                                                                              24.0,
                                                                          padding: EdgeInsetsDirectional.fromSTEB(
                                                                              16.0,
                                                                              0.0,
                                                                              16.0,
                                                                              0.0),
                                                                          iconPadding: EdgeInsetsDirectional.fromSTEB(
                                                                              0.0,
                                                                              0.0,
                                                                              0.0,
                                                                              0.0),
                                                                          color:
                                                                              Color(0x00264AFF),
                                                                          textStyle: FlutterFlowTheme.of(context)
                                                                              .titleSmall
                                                                              .override(
                                                                                font: GoogleFonts.interTight(
                                                                                  fontWeight: FlutterFlowTheme.of(context).titleSmall.fontWeight,
                                                                                  fontStyle: FlutterFlowTheme.of(context).titleSmall.fontStyle,
                                                                                ),
                                                                                color: FlutterFlowTheme.of(context).primaryD3,
                                                                                fontSize: 12.0,
                                                                                letterSpacing: 0.0,
                                                                                fontWeight: FlutterFlowTheme.of(context).titleSmall.fontWeight,
                                                                                fontStyle: FlutterFlowTheme.of(context).titleSmall.fontStyle,
                                                                              ),
                                                                          elevation:
                                                                              0.0,
                                                                          borderSide:
                                                                              BorderSide(
                                                                            color:
                                                                                FlutterFlowTheme.of(context).primaryD3,
                                                                            width:
                                                                                1.0,
                                                                          ),
                                                                          borderRadius:
                                                                              BorderRadius.only(
                                                                            topLeft:
                                                                                Radius.circular(100.0),
                                                                            topRight:
                                                                                Radius.circular(100.0),
                                                                            bottomLeft:
                                                                                Radius.circular(100.0),
                                                                            bottomRight:
                                                                                Radius.circular(100.0),
                                                                          ),
                                                                        ),
                                                                        showLoadingIndicator:
                                                                            false,
                                                                      ),
                                                                    if (('${getJsonField(
                                                                              gropsItem,
                                                                              r'''$.user_status''',
                                                                            ).toString()}' ==
                                                                            'invite') &&
                                                                        ('${getJsonField(
                                                                              gropsItem,
                                                                              r'''$.e_group_type''',
                                                                            ).toString()}' ==
                                                                            'private'))
                                                                      FFButtonWidget(
                                                                        onPressed:
                                                                            () async {
                                                                          await GroupUserStatusTable()
                                                                              .update(
                                                                            data: {
                                                                              'is_requested': true,
                                                                              'requested_date': supaSerialize<DateTime>(functions.getCurrentUtcTime()),
                                                                            },
                                                                            matchingRows: (rows) => rows
                                                                                .eqOrNull(
                                                                                  'group_id',
                                                                                  getJsonField(
                                                                                    gropsItem,
                                                                                    r'''$.group_id''',
                                                                                  ).toString(),
                                                                                )
                                                                                .eqOrNull(
                                                                                  'user_id',
                                                                                  currentUserUid,
                                                                                )
                                                                                .eqOrNull(
                                                                                  'invited_by',
                                                                                  getJsonField(
                                                                                    gropsItem,
                                                                                    r'''$.invited_by_user_id''',
                                                                                  ).toString(),
                                                                                ),
                                                                          );
                                                                        },
                                                                        text:
                                                                            'Request',
                                                                        icon:
                                                                            Icon(
                                                                          Icons
                                                                              .lock_outline_sharp,
                                                                          size:
                                                                              15.0,
                                                                        ),
                                                                        options:
                                                                            FFButtonOptions(
                                                                          height:
                                                                              24.0,
                                                                          padding: EdgeInsetsDirectional.fromSTEB(
                                                                              16.0,
                                                                              0.0,
                                                                              16.0,
                                                                              0.0),
                                                                          iconPadding: EdgeInsetsDirectional.fromSTEB(
                                                                              0.0,
                                                                              0.0,
                                                                              0.0,
                                                                              0.0),
                                                                          iconColor:
                                                                              FlutterFlowTheme.of(context).primaryD3,
                                                                          color:
                                                                              Color(0x00264AFF),
                                                                          textStyle: FlutterFlowTheme.of(context)
                                                                              .titleSmall
                                                                              .override(
                                                                                font: GoogleFonts.interTight(
                                                                                  fontWeight: FlutterFlowTheme.of(context).titleSmall.fontWeight,
                                                                                  fontStyle: FlutterFlowTheme.of(context).titleSmall.fontStyle,
                                                                                ),
                                                                                color: FlutterFlowTheme.of(context).primaryD3,
                                                                                fontSize: 12.0,
                                                                                letterSpacing: 0.0,
                                                                                fontWeight: FlutterFlowTheme.of(context).titleSmall.fontWeight,
                                                                                fontStyle: FlutterFlowTheme.of(context).titleSmall.fontStyle,
                                                                              ),
                                                                          elevation:
                                                                              0.0,
                                                                          borderSide:
                                                                              BorderSide(
                                                                            color:
                                                                                FlutterFlowTheme.of(context).primaryD3,
                                                                            width:
                                                                                1.0,
                                                                          ),
                                                                          borderRadius:
                                                                              BorderRadius.only(
                                                                            topLeft:
                                                                                Radius.circular(100.0),
                                                                            topRight:
                                                                                Radius.circular(100.0),
                                                                            bottomLeft:
                                                                                Radius.circular(100.0),
                                                                            bottomRight:
                                                                                Radius.circular(100.0),
                                                                          ),
                                                                        ),
                                                                        showLoadingIndicator:
                                                                            false,
                                                                      ),
                                                                  ],
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                );
                                              },
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                Container(
                                  decoration: BoxDecoration(),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            0.0, 8.0, 0.0, 0.0),
                                        child: Container(
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                            color: FlutterFlowTheme.of(context)
                                                .secondaryBackground,
                                          ),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Padding(
                                                padding: EdgeInsetsDirectional
                                                    .fromSTEB(
                                                        20.0, 12.0, 20.0, 8.0),
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  children: [
                                                    Container(
                                                      decoration: BoxDecoration(
                                                        color: FlutterFlowTheme
                                                                .of(context)
                                                            .secondaryBackground,
                                                      ),
                                                      child: Row(
                                                        mainAxisSize:
                                                            MainAxisSize.max,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Text(
                                                            'Explore Groups',
                                                            style: FlutterFlowTheme
                                                                    .of(context)
                                                                .bodyMedium
                                                                .override(
                                                                  font: GoogleFonts
                                                                      .manrope(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                    fontStyle: FlutterFlowTheme.of(
                                                                            context)
                                                                        .bodyMedium
                                                                        .fontStyle,
                                                                  ),
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .extraBlack,
                                                                  fontSize:
                                                                      18.0,
                                                                  letterSpacing:
                                                                      0.0,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  fontStyle: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMedium
                                                                      .fontStyle,
                                                                  lineHeight:
                                                                      1.4,
                                                                ),
                                                          ),
                                                          InkWell(
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
                                                              context.pushNamed(
                                                                  AllGroupsWidget
                                                                      .routeName);
                                                            },
                                                            child: Icon(
                                                              Icons
                                                                  .arrow_forward,
                                                              color: FlutterFlowTheme
                                                                      .of(context)
                                                                  .primaryText,
                                                              size: 24.0,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Container(
                                                width: double.infinity,
                                                height: 1.0,
                                                decoration: BoxDecoration(
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryBackground,
                                                ),
                                              ),
                                              Container(
                                                width: double.infinity,
                                                height: 1.0,
                                                decoration: BoxDecoration(
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .greyL2,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          color: FlutterFlowTheme.of(context)
                                              .secondaryBackground,
                                        ),
                                        child: Visibility(
                                          visible: '${getJsonField(
                                                FFAppState().AsGroupList,
                                                r'''$''',
                                              ).toString()}' !=
                                              '[]',
                                          child: Builder(
                                            builder: (context) {
                                              final grops = getJsonField(
                                                FFAppState().AsGroupList,
                                                r'''$''',
                                              ).toList().take(4).toList();

                                              return ListView.separated(
                                                padding: EdgeInsets.fromLTRB(
                                                  0,
                                                  12.0,
                                                  0,
                                                  12.0,
                                                ),
                                                primary: false,
                                                shrinkWrap: true,
                                                scrollDirection: Axis.vertical,
                                                itemCount: grops.length,
                                                separatorBuilder: (_, __) =>
                                                    SizedBox(height: 12.0),
                                                itemBuilder:
                                                    (context, gropsIndex) {
                                                  final gropsItem =
                                                      grops[gropsIndex];
                                                  return Visibility(
                                                    visible: ('${getJsonField(
                                                              gropsItem,
                                                              r'''$.e_discoverability''',
                                                            ).toString()}' ==
                                                            'listed') ||
                                                        (('${getJsonField(
                                                                  gropsItem,
                                                                  r'''$.e_discoverability''',
                                                                ).toString()}' ==
                                                                'unlisted') &&
                                                            ('${getJsonField(
                                                                  gropsItem,
                                                                  r'''$.user_status''',
                                                                ).toString()}' ==
                                                                'joined')) ||
                                                        (('${getJsonField(
                                                                  gropsItem,
                                                                  r'''$.e_discoverability''',
                                                                ).toString()}' ==
                                                                'unlisted') &&
                                                            ('${getJsonField(
                                                                  gropsItem,
                                                                  r'''$.user_status''',
                                                                ).toString()}' ==
                                                                'admin')) ||
                                                        (('${getJsonField(
                                                                  gropsItem,
                                                                  r'''$.e_discoverability''',
                                                                ).toString()}' ==
                                                                'unlisted') &&
                                                            ('${getJsonField(
                                                                  gropsItem,
                                                                  r'''$.user_status''',
                                                                ).toString()}' ==
                                                                'invite')) ||
                                                        (('${getJsonField(
                                                                  gropsItem,
                                                                  r'''$.e_discoverability''',
                                                                ).toString()}' ==
                                                                'unlisted') &&
                                                            ('${getJsonField(
                                                                  gropsItem,
                                                                  r'''$.user_status''',
                                                                ).toString()}' ==
                                                                'requested')),
                                                    child: InkWell(
                                                      splashColor:
                                                          Colors.transparent,
                                                      focusColor:
                                                          Colors.transparent,
                                                      hoverColor:
                                                          Colors.transparent,
                                                      highlightColor:
                                                          Colors.transparent,
                                                      onTap: () async {
                                                        context.pushNamed(
                                                          GroupDetailsWidget
                                                              .routeName,
                                                          queryParameters: {
                                                            'groupId':
                                                                serializeParam(
                                                              getJsonField(
                                                                gropsItem,
                                                                r'''$.group_id''',
                                                              ).toString(),
                                                              ParamType.String,
                                                            ),
                                                          }.withoutNulls,
                                                        );
                                                      },
                                                      child: Container(
                                                        width: double.infinity,
                                                        height: 56.0,
                                                        decoration:
                                                            BoxDecoration(
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .secondaryBackground,
                                                        ),
                                                        child: Padding(
                                                          padding:
                                                              EdgeInsetsDirectional
                                                                  .fromSTEB(
                                                                      20.0,
                                                                      8.0,
                                                                      20.0,
                                                                      8.0),
                                                          child: Row(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .max,
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              Expanded(
                                                                child: Row(
                                                                  mainAxisSize:
                                                                      MainAxisSize
                                                                          .max,
                                                                  children: [
                                                                    ClipRRect(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              2.0),
                                                                      child: Image
                                                                          .network(
                                                                        getJsonField(
                                                                          gropsItem,
                                                                          r'''$.profile_picture''',
                                                                        ).toString(),
                                                                        width:
                                                                            40.0,
                                                                        height:
                                                                            40.0,
                                                                        fit: BoxFit
                                                                            .cover,
                                                                      ),
                                                                    ),
                                                                    Expanded(
                                                                      child:
                                                                          Column(
                                                                        mainAxisSize:
                                                                            MainAxisSize.max,
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.start,
                                                                        children: [
                                                                          if (('${getJsonField(
                                                                                    gropsItem,
                                                                                    r'''$.invited_by_user_id''',
                                                                                  ).toString()}' !=
                                                                                  'null') &&
                                                                              ('${getJsonField(
                                                                                    gropsItem,
                                                                                    r'''$.user_status''',
                                                                                  ).toString()}' ==
                                                                                  'invite'))
                                                                            Row(
                                                                              mainAxisSize: MainAxisSize.max,
                                                                              children: [
                                                                                Container(
                                                                                  width: 12.0,
                                                                                  height: 12.0,
                                                                                  clipBehavior: Clip.antiAlias,
                                                                                  decoration: BoxDecoration(
                                                                                    shape: BoxShape.circle,
                                                                                  ),
                                                                                  child: Image.network(
                                                                                    getJsonField(
                                                                                      gropsItem,
                                                                                      r'''$.invited_by_profile_picture''',
                                                                                    ).toString(),
                                                                                    fit: BoxFit.cover,
                                                                                  ),
                                                                                ),
                                                                                Expanded(
                                                                                  child: Text(
                                                                                    '${getJsonField(
                                                                                      gropsItem,
                                                                                      r'''$.invited_by_name''',
                                                                                    ).toString()} invited you to join this group ',
                                                                                    maxLines: 1,
                                                                                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                          font: GoogleFonts.manrope(
                                                                                            fontWeight: FontWeight.w500,
                                                                                            fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                          ),
                                                                                          color: FlutterFlowTheme.of(context).greyL4,
                                                                                          fontSize: 10.0,
                                                                                          letterSpacing: 0.0,
                                                                                          fontWeight: FontWeight.w500,
                                                                                          fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                          lineHeight: 1.4,
                                                                                        ),
                                                                                  ),
                                                                                ),
                                                                              ].divide(SizedBox(width: 6.0)),
                                                                            ),
                                                                          Text(
                                                                            getJsonField(
                                                                              gropsItem,
                                                                              r'''$.name''',
                                                                            ).toString(),
                                                                            maxLines:
                                                                                1,
                                                                            style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                  font: GoogleFonts.manrope(
                                                                                    fontWeight: FontWeight.w600,
                                                                                    fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                  ),
                                                                                  color: FlutterFlowTheme.of(context).extraBlack,
                                                                                  fontSize: 16.0,
                                                                                  letterSpacing: 0.0,
                                                                                  fontWeight: FontWeight.w600,
                                                                                  fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                  lineHeight: 1.4,
                                                                                ),
                                                                          ),
                                                                          if ('${getJsonField(
                                                                                gropsItem,
                                                                                r'''$.user_status''',
                                                                              ).toString()}' !=
                                                                              'invite')
                                                                            Text(
                                                                              '${getJsonField(
                                                                                gropsItem,
                                                                                r'''$.total_members''',
                                                                              ).toString()} members',
                                                                              style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                    font: GoogleFonts.manrope(
                                                                                      fontWeight: FontWeight.w500,
                                                                                      fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                    ),
                                                                                    color: FlutterFlowTheme.of(context).greyL4,
                                                                                    fontSize: 10.0,
                                                                                    letterSpacing: 0.0,
                                                                                    fontWeight: FontWeight.w500,
                                                                                    fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                    lineHeight: 1.4,
                                                                                  ),
                                                                            ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ].divide(SizedBox(
                                                                      width:
                                                                          8.0)),
                                                                ),
                                                              ),
                                                              Stack(
                                                                children: [
                                                                  if ('${getJsonField(
                                                                        gropsItem,
                                                                        r'''$.user_status''',
                                                                      ).toString()}' ==
                                                                      'join')
                                                                    FFButtonWidget(
                                                                      onPressed:
                                                                          () async {
                                                                        await GroupMembersTable()
                                                                            .insert({
                                                                          'community_id':
                                                                              FFAppState().communityId,
                                                                          'user_id':
                                                                              currentUserUid,
                                                                          'group_id':
                                                                              getJsonField(
                                                                            gropsItem,
                                                                            r'''$.group_id''',
                                                                          ).toString(),
                                                                          'is_requested':
                                                                              false,
                                                                          'requested_date':
                                                                              supaSerialize<DateTime>(functions.getCurrentUtcTime()),
                                                                          'is_approved':
                                                                              true,
                                                                          'approved_by':
                                                                              currentUserUid,
                                                                          'joined_at':
                                                                              supaSerialize<DateTime>(functions.getCurrentUtcTime()),
                                                                        });
                                                                        await GroupUserStatusTable()
                                                                            .insert({
                                                                          'community_id':
                                                                              FFAppState().communityId,
                                                                          'user_id':
                                                                              currentUserUid,
                                                                          'group_id':
                                                                              getJsonField(
                                                                            gropsItem,
                                                                            r'''$.group_id''',
                                                                          ).toString(),
                                                                          'is_requested':
                                                                              false,
                                                                          'is_invited':
                                                                              false,
                                                                          'is_member':
                                                                              true,
                                                                          'joined_at':
                                                                              supaSerialize<DateTime>(functions.getCurrentUtcTime()),
                                                                        });
                                                                        _model.apiResultd2p5 =
                                                                            await UpdateTotalGroupMembersCall.call(
                                                                          token:
                                                                              currentJwtToken,
                                                                          anonKey:
                                                                              FFDevEnvironmentValues().AnonKey,
                                                                          groupId:
                                                                              getJsonField(
                                                                            gropsItem,
                                                                            r'''$.group_id''',
                                                                          ).toString(),
                                                                        );

                                                                        safeSetState(
                                                                            () {});
                                                                      },
                                                                      text:
                                                                          'Join',
                                                                      options:
                                                                          FFButtonOptions(
                                                                        height:
                                                                            24.0,
                                                                        padding: EdgeInsetsDirectional.fromSTEB(
                                                                            16.0,
                                                                            0.0,
                                                                            16.0,
                                                                            0.0),
                                                                        iconPadding: EdgeInsetsDirectional.fromSTEB(
                                                                            0.0,
                                                                            0.0,
                                                                            0.0,
                                                                            0.0),
                                                                        color: Color(
                                                                            0x00264AFF),
                                                                        textStyle: FlutterFlowTheme.of(context)
                                                                            .titleSmall
                                                                            .override(
                                                                              font: GoogleFonts.interTight(
                                                                                fontWeight: FlutterFlowTheme.of(context).titleSmall.fontWeight,
                                                                                fontStyle: FlutterFlowTheme.of(context).titleSmall.fontStyle,
                                                                              ),
                                                                              color: FlutterFlowTheme.of(context).primaryD3,
                                                                              fontSize: 12.0,
                                                                              letterSpacing: 0.0,
                                                                              fontWeight: FlutterFlowTheme.of(context).titleSmall.fontWeight,
                                                                              fontStyle: FlutterFlowTheme.of(context).titleSmall.fontStyle,
                                                                            ),
                                                                        elevation:
                                                                            0.0,
                                                                        borderSide:
                                                                            BorderSide(
                                                                          color:
                                                                              FlutterFlowTheme.of(context).primaryD3,
                                                                          width:
                                                                              1.0,
                                                                        ),
                                                                        borderRadius:
                                                                            BorderRadius.only(
                                                                          topLeft:
                                                                              Radius.circular(100.0),
                                                                          topRight:
                                                                              Radius.circular(100.0),
                                                                          bottomLeft:
                                                                              Radius.circular(100.0),
                                                                          bottomRight:
                                                                              Radius.circular(100.0),
                                                                        ),
                                                                      ),
                                                                      showLoadingIndicator:
                                                                          false,
                                                                    ),
                                                                  if ('${getJsonField(
                                                                        gropsItem,
                                                                        r'''$.user_status''',
                                                                      ).toString()}' ==
                                                                      'joined')
                                                                    FFButtonWidget(
                                                                      onPressed:
                                                                          () {
                                                                        print(
                                                                            'Joined pressed ...');
                                                                      },
                                                                      text:
                                                                          'Joined',
                                                                      icon:
                                                                          Icon(
                                                                        Icons
                                                                            .done_all,
                                                                        size:
                                                                            15.0,
                                                                      ),
                                                                      options:
                                                                          FFButtonOptions(
                                                                        height:
                                                                            24.0,
                                                                        padding: EdgeInsetsDirectional.fromSTEB(
                                                                            16.0,
                                                                            0.0,
                                                                            16.0,
                                                                            0.0),
                                                                        iconPadding: EdgeInsetsDirectional.fromSTEB(
                                                                            0.0,
                                                                            0.0,
                                                                            0.0,
                                                                            0.0),
                                                                        iconColor:
                                                                            FlutterFlowTheme.of(context).greyL4,
                                                                        color: Color(
                                                                            0x00264AFF),
                                                                        textStyle: FlutterFlowTheme.of(context)
                                                                            .titleSmall
                                                                            .override(
                                                                              font: GoogleFonts.interTight(
                                                                                fontWeight: FlutterFlowTheme.of(context).titleSmall.fontWeight,
                                                                                fontStyle: FlutterFlowTheme.of(context).titleSmall.fontStyle,
                                                                              ),
                                                                              color: FlutterFlowTheme.of(context).greyL4,
                                                                              fontSize: 12.0,
                                                                              letterSpacing: 0.0,
                                                                              fontWeight: FlutterFlowTheme.of(context).titleSmall.fontWeight,
                                                                              fontStyle: FlutterFlowTheme.of(context).titleSmall.fontStyle,
                                                                            ),
                                                                        elevation:
                                                                            0.0,
                                                                        borderSide:
                                                                            BorderSide(
                                                                          color:
                                                                              FlutterFlowTheme.of(context).greyL4,
                                                                          width:
                                                                              1.0,
                                                                        ),
                                                                        borderRadius:
                                                                            BorderRadius.only(
                                                                          topLeft:
                                                                              Radius.circular(100.0),
                                                                          topRight:
                                                                              Radius.circular(100.0),
                                                                          bottomLeft:
                                                                              Radius.circular(100.0),
                                                                          bottomRight:
                                                                              Radius.circular(100.0),
                                                                        ),
                                                                      ),
                                                                      showLoadingIndicator:
                                                                          false,
                                                                    ),
                                                                  if ('${getJsonField(
                                                                        gropsItem,
                                                                        r'''$.user_status''',
                                                                      ).toString()}' ==
                                                                      'requested')
                                                                    FFButtonWidget(
                                                                      onPressed:
                                                                          () {
                                                                        print(
                                                                            'Requested pressed ...');
                                                                      },
                                                                      text:
                                                                          'Requested',
                                                                      options:
                                                                          FFButtonOptions(
                                                                        height:
                                                                            24.0,
                                                                        padding: EdgeInsetsDirectional.fromSTEB(
                                                                            16.0,
                                                                            0.0,
                                                                            16.0,
                                                                            0.0),
                                                                        iconPadding: EdgeInsetsDirectional.fromSTEB(
                                                                            0.0,
                                                                            0.0,
                                                                            0.0,
                                                                            0.0),
                                                                        color: FlutterFlowTheme.of(context)
                                                                            .greyL2,
                                                                        textStyle: FlutterFlowTheme.of(context)
                                                                            .titleSmall
                                                                            .override(
                                                                              font: GoogleFonts.interTight(
                                                                                fontWeight: FlutterFlowTheme.of(context).titleSmall.fontWeight,
                                                                                fontStyle: FlutterFlowTheme.of(context).titleSmall.fontStyle,
                                                                              ),
                                                                              color: FlutterFlowTheme.of(context).greyL3,
                                                                              fontSize: 12.0,
                                                                              letterSpacing: 0.0,
                                                                              fontWeight: FlutterFlowTheme.of(context).titleSmall.fontWeight,
                                                                              fontStyle: FlutterFlowTheme.of(context).titleSmall.fontStyle,
                                                                            ),
                                                                        elevation:
                                                                            0.0,
                                                                        borderRadius:
                                                                            BorderRadius.only(
                                                                          topLeft:
                                                                              Radius.circular(100.0),
                                                                          topRight:
                                                                              Radius.circular(100.0),
                                                                          bottomLeft:
                                                                              Radius.circular(100.0),
                                                                          bottomRight:
                                                                              Radius.circular(100.0),
                                                                        ),
                                                                      ),
                                                                      showLoadingIndicator:
                                                                          false,
                                                                    ),
                                                                  if ('${getJsonField(
                                                                        gropsItem,
                                                                        r'''$.user_status''',
                                                                      ).toString()}' ==
                                                                      'request')
                                                                    FFButtonWidget(
                                                                      onPressed:
                                                                          () async {
                                                                        await GroupUserStatusTable()
                                                                            .insert({
                                                                          'community_id':
                                                                              FFAppState().communityId,
                                                                          'user_id':
                                                                              currentUserUid,
                                                                          'group_id':
                                                                              getJsonField(
                                                                            gropsItem,
                                                                            r'''$.group_id''',
                                                                          ).toString(),
                                                                          'is_requested':
                                                                              true,
                                                                          'is_invited':
                                                                              false,
                                                                          'is_member':
                                                                              false,
                                                                          'is_approved':
                                                                              false,
                                                                          'requested_date':
                                                                              supaSerialize<DateTime>(functions.getCurrentUtcTime()),
                                                                        });
                                                                      },
                                                                      text:
                                                                          'Request',
                                                                      icon:
                                                                          Icon(
                                                                        Icons
                                                                            .lock_outline_sharp,
                                                                        size:
                                                                            15.0,
                                                                      ),
                                                                      options:
                                                                          FFButtonOptions(
                                                                        height:
                                                                            24.0,
                                                                        padding: EdgeInsetsDirectional.fromSTEB(
                                                                            16.0,
                                                                            0.0,
                                                                            16.0,
                                                                            0.0),
                                                                        iconPadding: EdgeInsetsDirectional.fromSTEB(
                                                                            0.0,
                                                                            0.0,
                                                                            0.0,
                                                                            0.0),
                                                                        iconColor:
                                                                            FlutterFlowTheme.of(context).primaryD3,
                                                                        color: Color(
                                                                            0x00264AFF),
                                                                        textStyle: FlutterFlowTheme.of(context)
                                                                            .titleSmall
                                                                            .override(
                                                                              font: GoogleFonts.interTight(
                                                                                fontWeight: FlutterFlowTheme.of(context).titleSmall.fontWeight,
                                                                                fontStyle: FlutterFlowTheme.of(context).titleSmall.fontStyle,
                                                                              ),
                                                                              color: FlutterFlowTheme.of(context).primaryD3,
                                                                              fontSize: 12.0,
                                                                              letterSpacing: 0.0,
                                                                              fontWeight: FlutterFlowTheme.of(context).titleSmall.fontWeight,
                                                                              fontStyle: FlutterFlowTheme.of(context).titleSmall.fontStyle,
                                                                            ),
                                                                        elevation:
                                                                            0.0,
                                                                        borderSide:
                                                                            BorderSide(
                                                                          color:
                                                                              FlutterFlowTheme.of(context).primaryD3,
                                                                          width:
                                                                              1.0,
                                                                        ),
                                                                        borderRadius:
                                                                            BorderRadius.only(
                                                                          topLeft:
                                                                              Radius.circular(100.0),
                                                                          topRight:
                                                                              Radius.circular(100.0),
                                                                          bottomLeft:
                                                                              Radius.circular(100.0),
                                                                          bottomRight:
                                                                              Radius.circular(100.0),
                                                                        ),
                                                                      ),
                                                                      showLoadingIndicator:
                                                                          false,
                                                                    ),
                                                                  if ('${getJsonField(
                                                                        gropsItem,
                                                                        r'''$.user_status''',
                                                                      ).toString()}' ==
                                                                      'admin')
                                                                    FFButtonWidget(
                                                                      onPressed:
                                                                          () {
                                                                        print(
                                                                            'Button pressed ...');
                                                                      },
                                                                      text:
                                                                          'Admin',
                                                                      options:
                                                                          FFButtonOptions(
                                                                        height:
                                                                            24.0,
                                                                        padding: EdgeInsetsDirectional.fromSTEB(
                                                                            12.0,
                                                                            0.0,
                                                                            12.0,
                                                                            0.0),
                                                                        iconPadding: EdgeInsetsDirectional.fromSTEB(
                                                                            0.0,
                                                                            0.0,
                                                                            0.0,
                                                                            0.0),
                                                                        color: Color(
                                                                            0xFF23B3A6),
                                                                        textStyle: FlutterFlowTheme.of(context)
                                                                            .titleSmall
                                                                            .override(
                                                                              font: GoogleFonts.interTight(
                                                                                fontWeight: FlutterFlowTheme.of(context).titleSmall.fontWeight,
                                                                                fontStyle: FlutterFlowTheme.of(context).titleSmall.fontStyle,
                                                                              ),
                                                                              color: Colors.white,
                                                                              fontSize: 12.0,
                                                                              letterSpacing: 0.0,
                                                                              fontWeight: FlutterFlowTheme.of(context).titleSmall.fontWeight,
                                                                              fontStyle: FlutterFlowTheme.of(context).titleSmall.fontStyle,
                                                                            ),
                                                                        elevation:
                                                                            0.0,
                                                                        borderRadius:
                                                                            BorderRadius.only(
                                                                          topLeft:
                                                                              Radius.circular(100.0),
                                                                          topRight:
                                                                              Radius.circular(100.0),
                                                                          bottomLeft:
                                                                              Radius.circular(100.0),
                                                                          bottomRight:
                                                                              Radius.circular(100.0),
                                                                        ),
                                                                      ),
                                                                      showLoadingIndicator:
                                                                          false,
                                                                    ),
                                                                  if (('${getJsonField(
                                                                            gropsItem,
                                                                            r'''$.user_status''',
                                                                          ).toString()}' ==
                                                                          'invite') &&
                                                                      ('${getJsonField(
                                                                            gropsItem,
                                                                            r'''$.e_group_type''',
                                                                          ).toString()}' ==
                                                                          'open'))
                                                                    FFButtonWidget(
                                                                      onPressed:
                                                                          () async {
                                                                        await GroupMembersTable()
                                                                            .insert({
                                                                          'community_id':
                                                                              FFAppState().communityId,
                                                                          'user_id':
                                                                              currentUserUid,
                                                                          'group_id':
                                                                              getJsonField(
                                                                            gropsItem,
                                                                            r'''$.group_id''',
                                                                          ).toString(),
                                                                          'is_requested':
                                                                              false,
                                                                          'is_approved':
                                                                              true,
                                                                          'approved_by':
                                                                              getJsonField(
                                                                            gropsItem,
                                                                            r'''$.invited_by_user_id''',
                                                                          ).toString(),
                                                                          'joined_at':
                                                                              supaSerialize<DateTime>(functions.getCurrentUtcTime()),
                                                                        });
                                                                        await GroupUserStatusTable()
                                                                            .update(
                                                                          data: {
                                                                            'is_requested':
                                                                                false,
                                                                            'is_member':
                                                                                true,
                                                                            'is_approved':
                                                                                true,
                                                                            'joined_at':
                                                                                supaSerialize<DateTime>(functions.getCurrentUtcTime()),
                                                                          },
                                                                          matchingRows: (rows) => rows
                                                                              .eqOrNull(
                                                                                'group_id',
                                                                                getJsonField(
                                                                                  gropsItem,
                                                                                  r'''$.group_id''',
                                                                                ).toString(),
                                                                              )
                                                                              .eqOrNull(
                                                                                'user_id',
                                                                                currentUserUid,
                                                                              ),
                                                                        );
                                                                        await GroupMembersInviteTable()
                                                                            .update(
                                                                          data: {
                                                                            'is_member':
                                                                                true,
                                                                          },
                                                                          matchingRows: (rows) => rows
                                                                              .eqOrNull(
                                                                                'group_id',
                                                                                getJsonField(
                                                                                  gropsItem,
                                                                                  r'''$.group_id''',
                                                                                ).toString(),
                                                                              )
                                                                              .eqOrNull(
                                                                                'invited_by',
                                                                                getJsonField(
                                                                                  gropsItem,
                                                                                  r'''$.invited_by_user_id''',
                                                                                ).toString(),
                                                                              )
                                                                              .eqOrNull(
                                                                                'invited_user',
                                                                                currentUserUid,
                                                                              ),
                                                                        );
                                                                        _model.apiResultd2ppCopy =
                                                                            await UpdateTotalGroupMembersCall.call(
                                                                          token:
                                                                              currentJwtToken,
                                                                          anonKey:
                                                                              FFDevEnvironmentValues().AnonKey,
                                                                          groupId:
                                                                              getJsonField(
                                                                            gropsItem,
                                                                            r'''$.group_id''',
                                                                          ).toString(),
                                                                        );

                                                                        safeSetState(
                                                                            () {});
                                                                      },
                                                                      text:
                                                                          'Join',
                                                                      options:
                                                                          FFButtonOptions(
                                                                        height:
                                                                            24.0,
                                                                        padding: EdgeInsetsDirectional.fromSTEB(
                                                                            16.0,
                                                                            0.0,
                                                                            16.0,
                                                                            0.0),
                                                                        iconPadding: EdgeInsetsDirectional.fromSTEB(
                                                                            0.0,
                                                                            0.0,
                                                                            0.0,
                                                                            0.0),
                                                                        color: Color(
                                                                            0x00264AFF),
                                                                        textStyle: FlutterFlowTheme.of(context)
                                                                            .titleSmall
                                                                            .override(
                                                                              font: GoogleFonts.interTight(
                                                                                fontWeight: FlutterFlowTheme.of(context).titleSmall.fontWeight,
                                                                                fontStyle: FlutterFlowTheme.of(context).titleSmall.fontStyle,
                                                                              ),
                                                                              color: FlutterFlowTheme.of(context).primaryD3,
                                                                              fontSize: 12.0,
                                                                              letterSpacing: 0.0,
                                                                              fontWeight: FlutterFlowTheme.of(context).titleSmall.fontWeight,
                                                                              fontStyle: FlutterFlowTheme.of(context).titleSmall.fontStyle,
                                                                            ),
                                                                        elevation:
                                                                            0.0,
                                                                        borderSide:
                                                                            BorderSide(
                                                                          color:
                                                                              FlutterFlowTheme.of(context).primaryD3,
                                                                          width:
                                                                              1.0,
                                                                        ),
                                                                        borderRadius:
                                                                            BorderRadius.only(
                                                                          topLeft:
                                                                              Radius.circular(100.0),
                                                                          topRight:
                                                                              Radius.circular(100.0),
                                                                          bottomLeft:
                                                                              Radius.circular(100.0),
                                                                          bottomRight:
                                                                              Radius.circular(100.0),
                                                                        ),
                                                                      ),
                                                                      showLoadingIndicator:
                                                                          false,
                                                                    ),
                                                                  if (('${getJsonField(
                                                                            gropsItem,
                                                                            r'''$.user_status''',
                                                                          ).toString()}' ==
                                                                          'invite') &&
                                                                      ('${getJsonField(
                                                                            gropsItem,
                                                                            r'''$.e_group_type''',
                                                                          ).toString()}' ==
                                                                          'private'))
                                                                    FFButtonWidget(
                                                                      onPressed:
                                                                          () async {
                                                                        await GroupUserStatusTable()
                                                                            .update(
                                                                          data: {
                                                                            'is_requested':
                                                                                true,
                                                                            'requested_date':
                                                                                supaSerialize<DateTime>(functions.getCurrentUtcTime()),
                                                                          },
                                                                          matchingRows: (rows) => rows
                                                                              .eqOrNull(
                                                                                'group_id',
                                                                                getJsonField(
                                                                                  gropsItem,
                                                                                  r'''$.group_id''',
                                                                                ).toString(),
                                                                              )
                                                                              .eqOrNull(
                                                                                'user_id',
                                                                                currentUserUid,
                                                                              )
                                                                              .eqOrNull(
                                                                                'invited_by',
                                                                                getJsonField(
                                                                                  gropsItem,
                                                                                  r'''$.invited_by_user_id''',
                                                                                ).toString(),
                                                                              ),
                                                                        );
                                                                      },
                                                                      text:
                                                                          'Request',
                                                                      icon:
                                                                          Icon(
                                                                        Icons
                                                                            .lock_outline_sharp,
                                                                        size:
                                                                            15.0,
                                                                      ),
                                                                      options:
                                                                          FFButtonOptions(
                                                                        height:
                                                                            24.0,
                                                                        padding: EdgeInsetsDirectional.fromSTEB(
                                                                            16.0,
                                                                            0.0,
                                                                            16.0,
                                                                            0.0),
                                                                        iconPadding: EdgeInsetsDirectional.fromSTEB(
                                                                            0.0,
                                                                            0.0,
                                                                            0.0,
                                                                            0.0),
                                                                        iconColor:
                                                                            FlutterFlowTheme.of(context).primaryD3,
                                                                        color: Color(
                                                                            0x00264AFF),
                                                                        textStyle: FlutterFlowTheme.of(context)
                                                                            .titleSmall
                                                                            .override(
                                                                              font: GoogleFonts.interTight(
                                                                                fontWeight: FlutterFlowTheme.of(context).titleSmall.fontWeight,
                                                                                fontStyle: FlutterFlowTheme.of(context).titleSmall.fontStyle,
                                                                              ),
                                                                              color: FlutterFlowTheme.of(context).primaryD3,
                                                                              fontSize: 12.0,
                                                                              letterSpacing: 0.0,
                                                                              fontWeight: FlutterFlowTheme.of(context).titleSmall.fontWeight,
                                                                              fontStyle: FlutterFlowTheme.of(context).titleSmall.fontStyle,
                                                                            ),
                                                                        elevation:
                                                                            0.0,
                                                                        borderSide:
                                                                            BorderSide(
                                                                          color:
                                                                              FlutterFlowTheme.of(context).primaryD3,
                                                                          width:
                                                                              1.0,
                                                                        ),
                                                                        borderRadius:
                                                                            BorderRadius.only(
                                                                          topLeft:
                                                                              Radius.circular(100.0),
                                                                          topRight:
                                                                              Radius.circular(100.0),
                                                                          bottomLeft:
                                                                              Radius.circular(100.0),
                                                                          bottomRight:
                                                                              Radius.circular(100.0),
                                                                        ),
                                                                      ),
                                                                      showLoadingIndicator:
                                                                          false,
                                                                    ),
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                },
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      if (_model.switchBtn == 'events')
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Expanded(
                                child: SingleChildScrollView(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            0.0, 4.0, 0.0, 8.0),
                                        child: Container(
                                          width: double.infinity,
                                          height: 52.0,
                                          decoration: BoxDecoration(
                                            color: FlutterFlowTheme.of(context)
                                                .secondaryBackground,
                                          ),
                                          child: SingleChildScrollView(
                                            scrollDirection: Axis.horizontal,
                                            child: Row(
                                              mainAxisSize: MainAxisSize.max,
                                              children: [
                                                FutureBuilder<
                                                    List<EventAttendingRow>>(
                                                  future: (_model
                                                              .requestCompleter1 ??=
                                                          Completer<
                                                              List<
                                                                  EventAttendingRow>>()
                                                            ..complete(
                                                                EventAttendingTable()
                                                                    .queryRows(
                                                              queryFn: (q) => q
                                                                  .eqOrNull(
                                                                    'attending_id',
                                                                    currentUserUid,
                                                                  )
                                                                  .eqOrNull(
                                                                    'is_invited',
                                                                    true,
                                                                  )
                                                                  .eqOrNull(
                                                                    'is_attending',
                                                                    false,
                                                                  )
                                                                  .gtOrNull(
                                                                    'end_date_time',
                                                                    supaSerialize<
                                                                            DateTime>(
                                                                        getCurrentTimestamp),
                                                                  )
                                                                  .eqOrNull(
                                                                    'is_group_deleted',
                                                                    false,
                                                                  ),
                                                            )))
                                                      .future,
                                                  builder: (context, snapshot) {
                                                    // Customize what your widget looks like when it's loading.
                                                    if (!snapshot.hasData) {
                                                      return CompLoadingWidget(
                                                        name: 'invitations',
                                                      );
                                                    }
                                                    List<EventAttendingRow>
                                                        eventContainerEventAttendingRowList =
                                                        snapshot.data!;

                                                    return InkWell(
                                                      splashColor:
                                                          Colors.transparent,
                                                      focusColor:
                                                          Colors.transparent,
                                                      hoverColor:
                                                          Colors.transparent,
                                                      highlightColor:
                                                          Colors.transparent,
                                                      onTap: () async {
                                                        context.pushNamed(
                                                          MyEventWidget
                                                              .routeName,
                                                          queryParameters: {
                                                            'btnOption':
                                                                serializeParam(
                                                              'invitations',
                                                              ParamType.String,
                                                            ),
                                                          }.withoutNulls,
                                                        );
                                                      },
                                                      child: Container(
                                                        height: 36.0,
                                                        decoration:
                                                            BoxDecoration(
                                                          color: _model
                                                                      .option ==
                                                                  '1'
                                                              ? Color(
                                                                  0xFF0F8849)
                                                              : FlutterFlowTheme
                                                                      .of(context)
                                                                  .white,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      24.0),
                                                          border: Border.all(
                                                            color: _model
                                                                        .option !=
                                                                    '1'
                                                                ? FlutterFlowTheme.of(
                                                                        context)
                                                                    .greyL4
                                                                : FlutterFlowTheme.of(
                                                                        context)
                                                                    .white,
                                                          ),
                                                        ),
                                                        child: Align(
                                                          alignment:
                                                              AlignmentDirectional(
                                                                  0.0, 0.0),
                                                          child: Padding(
                                                            padding:
                                                                EdgeInsetsDirectional
                                                                    .fromSTEB(
                                                                        24.0,
                                                                        0.0,
                                                                        24.0,
                                                                        0.0),
                                                            child: Text(
                                                              'Invitations (${eventContainerEventAttendingRowList.length.toString()})',
                                                              style: FlutterFlowTheme
                                                                      .of(context)
                                                                  .bodyMedium
                                                                  .override(
                                                                    font: GoogleFonts
                                                                        .manrope(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600,
                                                                      fontStyle: FlutterFlowTheme.of(
                                                                              context)
                                                                          .bodyMedium
                                                                          .fontStyle,
                                                                    ),
                                                                    color: _model
                                                                                .option !=
                                                                            '1'
                                                                        ? FlutterFlowTheme.of(context)
                                                                            .greyL4
                                                                        : FlutterFlowTheme.of(context)
                                                                            .white,
                                                                    letterSpacing:
                                                                        0.0,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                    fontStyle: FlutterFlowTheme.of(
                                                                            context)
                                                                        .bodyMedium
                                                                        .fontStyle,
                                                                    lineHeight:
                                                                        1.4,
                                                                  ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ),
                                                InkWell(
                                                  splashColor:
                                                      Colors.transparent,
                                                  focusColor:
                                                      Colors.transparent,
                                                  hoverColor:
                                                      Colors.transparent,
                                                  highlightColor:
                                                      Colors.transparent,
                                                  onTap: () async {
                                                    context.pushNamed(
                                                      MyEventWidget.routeName,
                                                      queryParameters: {
                                                        'btnOption':
                                                            serializeParam(
                                                          'all',
                                                          ParamType.String,
                                                        ),
                                                      }.withoutNulls,
                                                    );
                                                  },
                                                  child: Container(
                                                    height: 36.0,
                                                    decoration: BoxDecoration(
                                                      color: _model.option ==
                                                              '2'
                                                          ? Color(0xFF0F8849)
                                                          : Color(0x00000000),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              24.0),
                                                      border: Border.all(
                                                        color: _model.option !=
                                                                '2'
                                                            ? FlutterFlowTheme
                                                                    .of(context)
                                                                .greyL4
                                                            : FlutterFlowTheme
                                                                    .of(context)
                                                                .white,
                                                      ),
                                                    ),
                                                    child: Align(
                                                      alignment:
                                                          AlignmentDirectional(
                                                              0.0, 0.0),
                                                      child: Padding(
                                                        padding:
                                                            EdgeInsetsDirectional
                                                                .fromSTEB(
                                                                    24.0,
                                                                    0.0,
                                                                    24.0,
                                                                    0.0),
                                                        child: Text(
                                                          'My Events',
                                                          style: FlutterFlowTheme
                                                                  .of(context)
                                                              .bodyMedium
                                                              .override(
                                                                font: GoogleFonts
                                                                    .manrope(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  fontStyle: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMedium
                                                                      .fontStyle,
                                                                ),
                                                                color: _model
                                                                            .option !=
                                                                        '2'
                                                                    ? FlutterFlowTheme.of(
                                                                            context)
                                                                        .greyL4
                                                                    : FlutterFlowTheme.of(
                                                                            context)
                                                                        .white,
                                                                letterSpacing:
                                                                    0.0,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                fontStyle: FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .fontStyle,
                                                                lineHeight: 1.4,
                                                              ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                InkWell(
                                                  splashColor:
                                                      Colors.transparent,
                                                  focusColor:
                                                      Colors.transparent,
                                                  hoverColor:
                                                      Colors.transparent,
                                                  highlightColor:
                                                      Colors.transparent,
                                                  onTap: () async {
                                                    context.pushNamed(
                                                        CreateEventWidget
                                                            .routeName);
                                                  },
                                                  child: Container(
                                                    height: 36.0,
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              24.0),
                                                      border: Border.all(
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .greyL4,
                                                      ),
                                                    ),
                                                    child: Align(
                                                      alignment:
                                                          AlignmentDirectional(
                                                              0.0, 0.0),
                                                      child: Padding(
                                                        padding:
                                                            EdgeInsetsDirectional
                                                                .fromSTEB(
                                                                    24.0,
                                                                    0.0,
                                                                    24.0,
                                                                    0.0),
                                                        child: Text(
                                                          'Create an event',
                                                          style: FlutterFlowTheme
                                                                  .of(context)
                                                              .bodyMedium
                                                              .override(
                                                                font: GoogleFonts
                                                                    .manrope(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  fontStyle: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMedium
                                                                      .fontStyle,
                                                                ),
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .greyL4,
                                                                letterSpacing:
                                                                    0.0,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                fontStyle: FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .fontStyle,
                                                                lineHeight: 1.4,
                                                              ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ]
                                                  .divide(SizedBox(width: 8.0))
                                                  .addToStart(
                                                      SizedBox(width: 20.0))
                                                  .addToEnd(
                                                      SizedBox(width: 20.0)),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: FlutterFlowTheme.of(context)
                                                .white,
                                          ),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Container(
                                                width: double.infinity,
                                                decoration: BoxDecoration(
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryBackground,
                                                ),
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          EdgeInsetsDirectional
                                                              .fromSTEB(
                                                                  20.0,
                                                                  12.0,
                                                                  20.0,
                                                                  11.0),
                                                      child: Column(
                                                        mainAxisSize:
                                                            MainAxisSize.max,
                                                        children: [
                                                          Container(
                                                            decoration:
                                                                BoxDecoration(
                                                              color: FlutterFlowTheme
                                                                      .of(context)
                                                                  .secondaryBackground,
                                                            ),
                                                            child: Padding(
                                                              padding:
                                                                  EdgeInsetsDirectional
                                                                      .fromSTEB(
                                                                          0.0,
                                                                          0.0,
                                                                          0.0,
                                                                          8.0),
                                                              child: Row(
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .max,
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                children: [
                                                                  Text(
                                                                    'Latest Events',
                                                                    style: FlutterFlowTheme.of(
                                                                            context)
                                                                        .bodyMedium
                                                                        .override(
                                                                          font:
                                                                              GoogleFonts.manrope(
                                                                            fontWeight:
                                                                                FontWeight.w600,
                                                                            fontStyle:
                                                                                FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                          ),
                                                                          color:
                                                                              FlutterFlowTheme.of(context).extraBlack,
                                                                          fontSize:
                                                                              18.0,
                                                                          letterSpacing:
                                                                              0.0,
                                                                          fontWeight:
                                                                              FontWeight.w600,
                                                                          fontStyle: FlutterFlowTheme.of(context)
                                                                              .bodyMedium
                                                                              .fontStyle,
                                                                          lineHeight:
                                                                              1.4,
                                                                        ),
                                                                  ),
                                                                  InkWell(
                                                                    splashColor:
                                                                        Colors
                                                                            .transparent,
                                                                    focusColor:
                                                                        Colors
                                                                            .transparent,
                                                                    hoverColor:
                                                                        Colors
                                                                            .transparent,
                                                                    highlightColor:
                                                                        Colors
                                                                            .transparent,
                                                                    onTap:
                                                                        () async {
                                                                      context.pushNamed(
                                                                          LatestEventWidget
                                                                              .routeName);
                                                                    },
                                                                    child: Icon(
                                                                      Icons
                                                                          .arrow_forward,
                                                                      color: FlutterFlowTheme.of(
                                                                              context)
                                                                          .primaryText,
                                                                      size:
                                                                          24.0,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Container(
                                                      width: double.infinity,
                                                      height: 1.0,
                                                      decoration: BoxDecoration(
                                                        color: FlutterFlowTheme
                                                                .of(context)
                                                            .secondaryBackground,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Padding(
                                                padding: EdgeInsetsDirectional
                                                    .fromSTEB(
                                                        20.0, 0.0, 20.0, 0.0),
                                                child: FutureBuilder<
                                                    List<EventPageRow>>(
                                                  future: (_model
                                                              .requestCompleter3 ??=
                                                          Completer<
                                                              List<
                                                                  EventPageRow>>()
                                                            ..complete(
                                                                EventPageTable()
                                                                    .queryRows(
                                                              queryFn: (q) => q
                                                                  .eqOrNull(
                                                                    'is_deleted',
                                                                    false,
                                                                  )
                                                                  .gtOrNull(
                                                                    'end_date_time',
                                                                    supaSerialize<
                                                                            DateTime>(
                                                                        getCurrentTimestamp),
                                                                  )
                                                                  .eqOrNull(
                                                                    'community_id',
                                                                    FFAppState()
                                                                        .communityId,
                                                                  )
                                                                  .order(
                                                                      'created_at'),
                                                              limit: 4,
                                                            )))
                                                      .future,
                                                  builder: (context, snapshot) {
                                                    // Customize what your widget looks like when it's loading.
                                                    if (!snapshot.hasData) {
                                                      return CompLoadingWidget(
                                                        name: 'eventGrid',
                                                      );
                                                    }
                                                    List<EventPageRow>
                                                        latestEventGridViewEventPageRowList =
                                                        snapshot.data!;

                                                    if (latestEventGridViewEventPageRowList
                                                        .isEmpty) {
                                                      return CompNoDataFoundWidget(
                                                        pageName: 'no',
                                                        text1:
                                                            'No events to show',
                                                        text2:
                                                            'Looks like no one has uploaded anything yet. Check back soon!',
                                                      );
                                                    }

                                                    return GridView.builder(
                                                      padding: EdgeInsets.zero,
                                                      gridDelegate:
                                                          SliverGridDelegateWithFixedCrossAxisCount(
                                                        crossAxisCount: 2,
                                                        crossAxisSpacing: 10.0,
                                                        mainAxisSpacing: 10.0,
                                                        childAspectRatio: 0.52,
                                                      ),
                                                      primary: false,
                                                      shrinkWrap: true,
                                                      scrollDirection:
                                                          Axis.vertical,
                                                      itemCount:
                                                          latestEventGridViewEventPageRowList
                                                              .length,
                                                      itemBuilder: (context,
                                                          latestEventGridViewIndex) {
                                                        final latestEventGridViewEventPageRow =
                                                            latestEventGridViewEventPageRowList[
                                                                latestEventGridViewIndex];
                                                        return FutureBuilder<
                                                            List<
                                                                EventAttendingRow>>(
                                                          future:
                                                              EventAttendingTable()
                                                                  .querySingleRow(
                                                            queryFn: (q) => q
                                                                .eqOrNull(
                                                                  'event_id',
                                                                  latestEventGridViewEventPageRow
                                                                      .id,
                                                                )
                                                                .eqOrNull(
                                                                  'attending_id',
                                                                  currentUserUid,
                                                                ),
                                                          ),
                                                          builder: (context,
                                                              snapshot) {
                                                            // Customize what your widget looks like when it's loading.
                                                            if (!snapshot
                                                                .hasData) {
                                                              return CompLoadingWidget(
                                                                name:
                                                                    'eventCard',
                                                              );
                                                            }
                                                            List<EventAttendingRow>
                                                                containerEventAttendingRowList =
                                                                snapshot.data!;

                                                            final containerEventAttendingRow =
                                                                containerEventAttendingRowList
                                                                        .isNotEmpty
                                                                    ? containerEventAttendingRowList
                                                                        .first
                                                                    : null;

                                                            return InkWell(
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
                                                                context
                                                                    .pushNamed(
                                                                  EventDetailsWidget
                                                                      .routeName,
                                                                  queryParameters:
                                                                      {
                                                                    'eventId':
                                                                        serializeParam(
                                                                      latestEventGridViewEventPageRow
                                                                          .id,
                                                                      ParamType
                                                                          .String,
                                                                    ),
                                                                  }.withoutNulls,
                                                                );
                                                              },
                                                              child: Container(
                                                                height: 316.0,
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .secondaryBackground,
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              8.0),
                                                                  border: Border
                                                                      .all(
                                                                    color: FlutterFlowTheme.of(
                                                                            context)
                                                                        .greyL2,
                                                                  ),
                                                                ),
                                                                child: Padding(
                                                                  padding: EdgeInsetsDirectional
                                                                      .fromSTEB(
                                                                          8.0,
                                                                          8.0,
                                                                          8.0,
                                                                          8.0),
                                                                  child: Column(
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .max,
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Stack(
                                                                        alignment: AlignmentDirectional(
                                                                            -1.0,
                                                                            1.0),
                                                                        children: [
                                                                          ClipRRect(
                                                                            borderRadius:
                                                                                BorderRadius.circular(2.0),
                                                                            child:
                                                                                Image.network(
                                                                              latestEventGridViewEventPageRow.coverImage,
                                                                              width: double.infinity,
                                                                              height: 120.0,
                                                                              fit: BoxFit.cover,
                                                                            ),
                                                                          ),
                                                                          if (functions
                                                                              .endSoon(latestEventGridViewEventPageRow.endDateTime!))
                                                                            Padding(
                                                                              padding: EdgeInsetsDirectional.fromSTEB(8.0, 0.0, 0.0, 8.0),
                                                                              child: ClipRRect(
                                                                                borderRadius: BorderRadius.circular(4.0),
                                                                                child: BackdropFilter(
                                                                                  filter: ImageFilter.blur(
                                                                                    sigmaX: 2.0,
                                                                                    sigmaY: 2.0,
                                                                                  ),
                                                                                  child: Container(
                                                                                    width: 70.0,
                                                                                    height: 18.0,
                                                                                    decoration: BoxDecoration(
                                                                                      color: Color(0x1AFFFFFF),
                                                                                      borderRadius: BorderRadius.circular(4.0),
                                                                                    ),
                                                                                    alignment: AlignmentDirectional(0.0, 0.0),
                                                                                    child: Text(
                                                                                      'Ending Soon',
                                                                                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                            font: GoogleFonts.manrope(
                                                                                              fontWeight: FontWeight.w600,
                                                                                              fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                            ),
                                                                                            color: FlutterFlowTheme.of(context).white,
                                                                                            fontSize: 10.0,
                                                                                            letterSpacing: 0.0,
                                                                                            fontWeight: FontWeight.w600,
                                                                                            fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                            lineHeight: 1.4,
                                                                                          ),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                        ],
                                                                      ),
                                                                      Expanded(
                                                                        child:
                                                                            Column(
                                                                          mainAxisSize:
                                                                              MainAxisSize.max,
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.start,
                                                                          children:
                                                                              [
                                                                            if ((containerEventAttendingRow?.id != null && containerEventAttendingRow?.id != '') &&
                                                                                (containerEventAttendingRow?.isInvited == true) &&
                                                                                (containerEventAttendingRow?.isAttending == false))
                                                                              FutureBuilder<List<PublicUserProfileRow>>(
                                                                                future: PublicUserProfileTable().querySingleRow(
                                                                                  queryFn: (q) => q.eqOrNull(
                                                                                    'id',
                                                                                    containerEventAttendingRow?.invitedBy,
                                                                                  ),
                                                                                ),
                                                                                builder: (context, snapshot) {
                                                                                  // Customize what your widget looks like when it's loading.
                                                                                  if (!snapshot.hasData) {
                                                                                    return CompLoadingWidget(
                                                                                      name: 'loadingInvite',
                                                                                    );
                                                                                  }
                                                                                  List<PublicUserProfileRow> rowPublicUserProfileRowList = snapshot.data!;

                                                                                  // Return an empty Container when the item does not exist.
                                                                                  if (snapshot.data!.isEmpty) {
                                                                                    return Container();
                                                                                  }
                                                                                  final rowPublicUserProfileRow = rowPublicUserProfileRowList.isNotEmpty ? rowPublicUserProfileRowList.first : null;

                                                                                  return Row(
                                                                                    mainAxisSize: MainAxisSize.max,
                                                                                    children: [
                                                                                      Container(
                                                                                        width: 12.0,
                                                                                        height: 12.0,
                                                                                        clipBehavior: Clip.antiAlias,
                                                                                        decoration: BoxDecoration(
                                                                                          shape: BoxShape.circle,
                                                                                        ),
                                                                                        child: Image.network(
                                                                                          rowPublicUserProfileRow!.profilePicture!,
                                                                                          fit: BoxFit.cover,
                                                                                        ),
                                                                                      ),
                                                                                      Expanded(
                                                                                        child: Row(
                                                                                          mainAxisSize: MainAxisSize.max,
                                                                                          children: [
                                                                                            Text(
                                                                                              valueOrDefault<String>(
                                                                                                rowPublicUserProfileRow?.name,
                                                                                                'name  jjhgjh jhjhjh jhjhjhj',
                                                                                              ),
                                                                                              style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                                    font: GoogleFonts.manrope(
                                                                                                      fontWeight: FontWeight.w500,
                                                                                                      fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                    ),
                                                                                                    color: FlutterFlowTheme.of(context).greyL4,
                                                                                                    fontSize: 10.0,
                                                                                                    letterSpacing: 0.0,
                                                                                                    fontWeight: FontWeight.w500,
                                                                                                    fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                    lineHeight: 1.4,
                                                                                                  ),
                                                                                            ),
                                                                                            Expanded(
                                                                                              child: Text(
                                                                                                ' invited you to join this event',
                                                                                                maxLines: 1,
                                                                                                style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                                      font: GoogleFonts.manrope(
                                                                                                        fontWeight: FontWeight.w500,
                                                                                                        fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                      ),
                                                                                                      color: FlutterFlowTheme.of(context).greyL4,
                                                                                                      fontSize: 10.0,
                                                                                                      letterSpacing: 0.0,
                                                                                                      fontWeight: FontWeight.w500,
                                                                                                      fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                      lineHeight: 1.4,
                                                                                                    ),
                                                                                              ),
                                                                                            ),
                                                                                          ],
                                                                                        ),
                                                                                      ),
                                                                                    ].divide(SizedBox(width: 10.0)),
                                                                                  );
                                                                                },
                                                                              ),
                                                                            Column(
                                                                              mainAxisSize: MainAxisSize.max,
                                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                                              children: [
                                                                                Text(
                                                                                  latestEventGridViewEventPageRow.name,
                                                                                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                        font: GoogleFonts.manrope(
                                                                                          fontWeight: FontWeight.w600,
                                                                                          fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                        ),
                                                                                        color: FlutterFlowTheme.of(context).extraBlack,
                                                                                        fontSize: 16.0,
                                                                                        letterSpacing: 0.0,
                                                                                        fontWeight: FontWeight.w600,
                                                                                        fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                        lineHeight: 1.4,
                                                                                      ),
                                                                                ),
                                                                                Text(
                                                                                  latestEventGridViewEventPageRow.description,
                                                                                  maxLines: containerEventAttendingRow?.isInvited == true ? 1 : 3,
                                                                                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                        font: GoogleFonts.manrope(
                                                                                          fontWeight: FontWeight.w500,
                                                                                          fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                        ),
                                                                                        color: FlutterFlowTheme.of(context).greyL4,
                                                                                        fontSize: 10.0,
                                                                                        letterSpacing: 0.0,
                                                                                        fontWeight: FontWeight.w500,
                                                                                        fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                        lineHeight: 1.4,
                                                                                      ),
                                                                                ),
                                                                              ].divide(SizedBox(height: 2.0)),
                                                                            ),
                                                                            Column(
                                                                              mainAxisSize: MainAxisSize.max,
                                                                              children: [
                                                                                Row(
                                                                                  mainAxisSize: MainAxisSize.max,
                                                                                  children: [
                                                                                    ClipRRect(
                                                                                      borderRadius: BorderRadius.circular(0.0),
                                                                                      child: Image.asset(
                                                                                        'assets/images/calendar_clock.png',
                                                                                        width: 16.0,
                                                                                        height: 16.0,
                                                                                        fit: BoxFit.cover,
                                                                                      ),
                                                                                    ),
                                                                                    Text(
                                                                                      valueOrDefault<String>(
                                                                                        functions.eventDate(latestEventGridViewEventPageRow.startDateTime),
                                                                                        'May 23, 6:00 PM UTC',
                                                                                      ),
                                                                                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                            font: GoogleFonts.manrope(
                                                                                              fontWeight: FontWeight.w500,
                                                                                              fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                            ),
                                                                                            color: FlutterFlowTheme.of(context).greyL4,
                                                                                            fontSize: 10.0,
                                                                                            letterSpacing: 0.0,
                                                                                            fontWeight: FontWeight.w500,
                                                                                            fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                            lineHeight: 1.4,
                                                                                          ),
                                                                                    ),
                                                                                  ].divide(SizedBox(width: 6.0)),
                                                                                ),
                                                                                Row(
                                                                                  mainAxisSize: MainAxisSize.max,
                                                                                  children: [
                                                                                    ClipRRect(
                                                                                      borderRadius: BorderRadius.circular(0.0),
                                                                                      child: Image.asset(
                                                                                        'assets/images/explore.png',
                                                                                        width: 16.0,
                                                                                        height: 16.0,
                                                                                        fit: BoxFit.cover,
                                                                                      ),
                                                                                    ),
                                                                                    Flexible(
                                                                                      child: Text(
                                                                                        valueOrDefault<String>(
                                                                                          latestEventGridViewEventPageRow.address,
                                                                                          'Address',
                                                                                        ),
                                                                                        maxLines: 1,
                                                                                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                              font: GoogleFonts.manrope(
                                                                                                fontWeight: FontWeight.w500,
                                                                                                fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                              ),
                                                                                              color: FlutterFlowTheme.of(context).greyL4,
                                                                                              fontSize: 10.0,
                                                                                              letterSpacing: 0.0,
                                                                                              fontWeight: FontWeight.w500,
                                                                                              fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                              lineHeight: 1.4,
                                                                                            ),
                                                                                      ),
                                                                                    ),
                                                                                  ].divide(SizedBox(width: 6.0)),
                                                                                ),
                                                                                Row(
                                                                                  mainAxisSize: MainAxisSize.max,
                                                                                  children: [
                                                                                    ClipRRect(
                                                                                      borderRadius: BorderRadius.circular(0.0),
                                                                                      child: Image.asset(
                                                                                        'assets/images/crowdsource_(1).png',
                                                                                        width: 16.0,
                                                                                        height: 16.0,
                                                                                        fit: BoxFit.cover,
                                                                                      ),
                                                                                    ),
                                                                                    Text(
                                                                                      '${latestEventGridViewEventPageRow.attendeeCount.toString()} attending',
                                                                                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                            font: GoogleFonts.manrope(
                                                                                              fontWeight: FontWeight.w500,
                                                                                              fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                            ),
                                                                                            color: FlutterFlowTheme.of(context).greyL4,
                                                                                            fontSize: 10.0,
                                                                                            letterSpacing: 0.0,
                                                                                            fontWeight: FontWeight.w500,
                                                                                            fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                            lineHeight: 1.4,
                                                                                          ),
                                                                                    ),
                                                                                  ].divide(SizedBox(width: 6.0)),
                                                                                ),
                                                                              ].divide(SizedBox(height: 4.0)),
                                                                            ),
                                                                          ].divide(SizedBox(height: 4.0)),
                                                                        ),
                                                                      ),
                                                                      if (latestEventGridViewEventPageRow
                                                                              .adminUser !=
                                                                          currentUserUid)
                                                                        Stack(
                                                                          children: [
                                                                            FFButtonWidget(
                                                                              onPressed: () async {
                                                                                await EventAttendingTable().insert({
                                                                                  'community_id': latestEventGridViewEventPageRow.communityId,
                                                                                  'event_id': latestEventGridViewEventPageRow.id,
                                                                                  'attending_id': currentUserUid,
                                                                                  'is_invited': false,
                                                                                  'is_attending': true,
                                                                                });
                                                                                _model.apiResultrykop = await UpdateEventAttendeeCountCall.call(
                                                                                  token: currentJwtToken,
                                                                                  eventId: latestEventGridViewEventPageRow.id,
                                                                                );

                                                                                safeSetState(() {});
                                                                              },
                                                                              text: 'Attend',
                                                                              icon: Icon(
                                                                                Icons.edit_calendar_outlined,
                                                                                size: 15.0,
                                                                              ),
                                                                              options: FFButtonOptions(
                                                                                width: double.infinity,
                                                                                height: 24.0,
                                                                                padding: EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                                                                                iconPadding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                                                                                color: FlutterFlowTheme.of(context).white,
                                                                                textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                                                                                      font: GoogleFonts.interTight(
                                                                                        fontWeight: FlutterFlowTheme.of(context).titleSmall.fontWeight,
                                                                                        fontStyle: FlutterFlowTheme.of(context).titleSmall.fontStyle,
                                                                                      ),
                                                                                      color: FlutterFlowTheme.of(context).primaryD3,
                                                                                      fontSize: 12.0,
                                                                                      letterSpacing: 0.0,
                                                                                      fontWeight: FlutterFlowTheme.of(context).titleSmall.fontWeight,
                                                                                      fontStyle: FlutterFlowTheme.of(context).titleSmall.fontStyle,
                                                                                    ),
                                                                                elevation: 0.0,
                                                                                borderSide: BorderSide(
                                                                                  color: FlutterFlowTheme.of(context).primaryD3,
                                                                                  width: 1.0,
                                                                                ),
                                                                                borderRadius: BorderRadius.only(
                                                                                  topLeft: Radius.circular(100.0),
                                                                                  topRight: Radius.circular(100.0),
                                                                                  bottomLeft: Radius.circular(100.0),
                                                                                  bottomRight: Radius.circular(100.0),
                                                                                ),
                                                                              ),
                                                                              showLoadingIndicator: false,
                                                                            ),
                                                                            if ((containerEventAttendingRow?.id != null && containerEventAttendingRow?.id != '') &&
                                                                                (containerEventAttendingRow?.isAttending == false))
                                                                              FFButtonWidget(
                                                                                onPressed: () async {
                                                                                  await EventAttendingTable().update(
                                                                                    data: {
                                                                                      'is_attending': true,
                                                                                    },
                                                                                    matchingRows: (rows) => rows
                                                                                        .eqOrNull(
                                                                                          'event_id',
                                                                                          latestEventGridViewEventPageRow.id,
                                                                                        )
                                                                                        .eqOrNull(
                                                                                          'attending_id',
                                                                                          currentUserUid,
                                                                                        ),
                                                                                  );
                                                                                  _model.apiResultrykui = await UpdateEventAttendeeCountCall.call(
                                                                                    token: currentJwtToken,
                                                                                    eventId: latestEventGridViewEventPageRow.id,
                                                                                  );

                                                                                  safeSetState(() {});
                                                                                },
                                                                                text: 'Attend',
                                                                                icon: Icon(
                                                                                  Icons.edit_calendar_outlined,
                                                                                  size: 15.0,
                                                                                ),
                                                                                options: FFButtonOptions(
                                                                                  width: double.infinity,
                                                                                  height: 24.0,
                                                                                  padding: EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                                                                                  iconPadding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                                                                                  color: FlutterFlowTheme.of(context).white,
                                                                                  textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                                                                                        font: GoogleFonts.interTight(
                                                                                          fontWeight: FlutterFlowTheme.of(context).titleSmall.fontWeight,
                                                                                          fontStyle: FlutterFlowTheme.of(context).titleSmall.fontStyle,
                                                                                        ),
                                                                                        color: FlutterFlowTheme.of(context).primaryD3,
                                                                                        fontSize: 12.0,
                                                                                        letterSpacing: 0.0,
                                                                                        fontWeight: FlutterFlowTheme.of(context).titleSmall.fontWeight,
                                                                                        fontStyle: FlutterFlowTheme.of(context).titleSmall.fontStyle,
                                                                                      ),
                                                                                  elevation: 0.0,
                                                                                  borderSide: BorderSide(
                                                                                    color: FlutterFlowTheme.of(context).primaryD3,
                                                                                    width: 1.0,
                                                                                  ),
                                                                                  borderRadius: BorderRadius.only(
                                                                                    topLeft: Radius.circular(100.0),
                                                                                    topRight: Radius.circular(100.0),
                                                                                    bottomLeft: Radius.circular(100.0),
                                                                                    bottomRight: Radius.circular(100.0),
                                                                                  ),
                                                                                ),
                                                                                showLoadingIndicator: false,
                                                                              ),
                                                                            if ((containerEventAttendingRow?.id != null && containerEventAttendingRow?.id != '') &&
                                                                                (containerEventAttendingRow?.isAttending == true))
                                                                              FFButtonWidget(
                                                                                onPressed: () async {
                                                                                  await EventAttendingTable().update(
                                                                                    data: {
                                                                                      'is_attending': false,
                                                                                    },
                                                                                    matchingRows: (rows) => rows
                                                                                        .eqOrNull(
                                                                                          'event_id',
                                                                                          latestEventGridViewEventPageRow.id,
                                                                                        )
                                                                                        .eqOrNull(
                                                                                          'attending_id',
                                                                                          currentUserUid,
                                                                                        ),
                                                                                  );
                                                                                  _model.apiResultrykyy = await UpdateEventAttendeeCountCall.call(
                                                                                    token: currentJwtToken,
                                                                                    eventId: latestEventGridViewEventPageRow.id,
                                                                                  );

                                                                                  safeSetState(() {});
                                                                                },
                                                                                text: 'Attending',
                                                                                icon: Icon(
                                                                                  Icons.edit_calendar_outlined,
                                                                                  size: 15.0,
                                                                                ),
                                                                                options: FFButtonOptions(
                                                                                  width: double.infinity,
                                                                                  height: 24.0,
                                                                                  padding: EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                                                                                  iconPadding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                                                                                  color: FlutterFlowTheme.of(context).white,
                                                                                  textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                                                                                        font: GoogleFonts.interTight(
                                                                                          fontWeight: FlutterFlowTheme.of(context).titleSmall.fontWeight,
                                                                                          fontStyle: FlutterFlowTheme.of(context).titleSmall.fontStyle,
                                                                                        ),
                                                                                        color: FlutterFlowTheme.of(context).greyL4,
                                                                                        fontSize: 12.0,
                                                                                        letterSpacing: 0.0,
                                                                                        fontWeight: FlutterFlowTheme.of(context).titleSmall.fontWeight,
                                                                                        fontStyle: FlutterFlowTheme.of(context).titleSmall.fontStyle,
                                                                                      ),
                                                                                  elevation: 0.0,
                                                                                  borderSide: BorderSide(
                                                                                    color: FlutterFlowTheme.of(context).greyL4,
                                                                                    width: 1.0,
                                                                                  ),
                                                                                  borderRadius: BorderRadius.only(
                                                                                    topLeft: Radius.circular(100.0),
                                                                                    topRight: Radius.circular(100.0),
                                                                                    bottomLeft: Radius.circular(100.0),
                                                                                    bottomRight: Radius.circular(100.0),
                                                                                  ),
                                                                                ),
                                                                                showLoadingIndicator: false,
                                                                              ),
                                                                          ],
                                                                        ),
                                                                    ].divide(SizedBox(
                                                                        height:
                                                                            8.0)),
                                                                  ),
                                                                ),
                                                              ),
                                                            );
                                                          },
                                                        );
                                                      },
                                                    );
                                                  },
                                                ),
                                              ),
                                            ].addToEnd(SizedBox(height: 12.0)),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            0.0, 8.0, 0.0, 0.0),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: FlutterFlowTheme.of(context)
                                                .white,
                                          ),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Container(
                                                width: double.infinity,
                                                decoration: BoxDecoration(
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryBackground,
                                                ),
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          EdgeInsetsDirectional
                                                              .fromSTEB(
                                                                  20.0,
                                                                  12.0,
                                                                  20.0,
                                                                  11.0),
                                                      child: Column(
                                                        mainAxisSize:
                                                            MainAxisSize.max,
                                                        children: [
                                                          Container(
                                                            decoration:
                                                                BoxDecoration(
                                                              color: FlutterFlowTheme
                                                                      .of(context)
                                                                  .secondaryBackground,
                                                            ),
                                                            child: Padding(
                                                              padding:
                                                                  EdgeInsetsDirectional
                                                                      .fromSTEB(
                                                                          0.0,
                                                                          0.0,
                                                                          0.0,
                                                                          8.0),
                                                              child: Row(
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .max,
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                children: [
                                                                  Text(
                                                                    'Ending Soon',
                                                                    style: FlutterFlowTheme.of(
                                                                            context)
                                                                        .bodyMedium
                                                                        .override(
                                                                          font:
                                                                              GoogleFonts.manrope(
                                                                            fontWeight:
                                                                                FontWeight.w600,
                                                                            fontStyle:
                                                                                FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                          ),
                                                                          color:
                                                                              FlutterFlowTheme.of(context).extraBlack,
                                                                          fontSize:
                                                                              18.0,
                                                                          letterSpacing:
                                                                              0.0,
                                                                          fontWeight:
                                                                              FontWeight.w600,
                                                                          fontStyle: FlutterFlowTheme.of(context)
                                                                              .bodyMedium
                                                                              .fontStyle,
                                                                          lineHeight:
                                                                              1.4,
                                                                        ),
                                                                  ),
                                                                  InkWell(
                                                                    splashColor:
                                                                        Colors
                                                                            .transparent,
                                                                    focusColor:
                                                                        Colors
                                                                            .transparent,
                                                                    hoverColor:
                                                                        Colors
                                                                            .transparent,
                                                                    highlightColor:
                                                                        Colors
                                                                            .transparent,
                                                                    onTap:
                                                                        () async {
                                                                      context.pushNamed(
                                                                          EndingEventWidget
                                                                              .routeName);
                                                                    },
                                                                    child: Icon(
                                                                      Icons
                                                                          .arrow_forward,
                                                                      color: FlutterFlowTheme.of(
                                                                              context)
                                                                          .primaryText,
                                                                      size:
                                                                          24.0,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Container(
                                                      width: double.infinity,
                                                      height: 1.0,
                                                      decoration: BoxDecoration(
                                                        color: FlutterFlowTheme
                                                                .of(context)
                                                            .secondaryBackground,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Padding(
                                                padding: EdgeInsetsDirectional
                                                    .fromSTEB(
                                                        20.0, 0.0, 20.0, 0.0),
                                                child: FutureBuilder<
                                                    List<EventPageRow>>(
                                                  future: (_model
                                                              .requestCompleter2 ??=
                                                          Completer<
                                                              List<
                                                                  EventPageRow>>()
                                                            ..complete(
                                                                EventPageTable()
                                                                    .queryRows(
                                                              queryFn: (q) => q
                                                                  .eqOrNull(
                                                                    'is_deleted',
                                                                    false,
                                                                  )
                                                                  .gtOrNull(
                                                                    'end_date_time',
                                                                    supaSerialize<
                                                                            DateTime>(
                                                                        getCurrentTimestamp),
                                                                  )
                                                                  .order(
                                                                      'end_date_time'),
                                                              limit: 4,
                                                            )))
                                                      .future,
                                                  builder: (context, snapshot) {
                                                    // Customize what your widget looks like when it's loading.
                                                    if (!snapshot.hasData) {
                                                      return Center(
                                                        child: SizedBox(
                                                          width: 50.0,
                                                          height: 50.0,
                                                          child:
                                                              CircularProgressIndicator(
                                                            valueColor:
                                                                AlwaysStoppedAnimation<
                                                                    Color>(
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .primary,
                                                            ),
                                                          ),
                                                        ),
                                                      );
                                                    }
                                                    List<EventPageRow>
                                                        endingEventGridViewEventPageRowList =
                                                        snapshot.data!;

                                                    if (endingEventGridViewEventPageRowList
                                                        .isEmpty) {
                                                      return CompNoDataFoundWidget(
                                                        pageName: 'no',
                                                        text1:
                                                            'No events to show',
                                                        text2:
                                                            'Looks like no one has uploaded anything yet. Check back soon!',
                                                      );
                                                    }

                                                    return GridView.builder(
                                                      padding: EdgeInsets.zero,
                                                      gridDelegate:
                                                          SliverGridDelegateWithFixedCrossAxisCount(
                                                        crossAxisCount: 2,
                                                        crossAxisSpacing: 10.0,
                                                        mainAxisSpacing: 10.0,
                                                        childAspectRatio: 0.52,
                                                      ),
                                                      primary: false,
                                                      shrinkWrap: true,
                                                      scrollDirection:
                                                          Axis.vertical,
                                                      itemCount:
                                                          endingEventGridViewEventPageRowList
                                                              .length,
                                                      itemBuilder: (context,
                                                          endingEventGridViewIndex) {
                                                        final endingEventGridViewEventPageRow =
                                                            endingEventGridViewEventPageRowList[
                                                                endingEventGridViewIndex];
                                                        return FutureBuilder<
                                                            List<
                                                                EventAttendingRow>>(
                                                          future:
                                                              EventAttendingTable()
                                                                  .querySingleRow(
                                                            queryFn: (q) => q
                                                                .eqOrNull(
                                                                  'event_id',
                                                                  endingEventGridViewEventPageRow
                                                                      .id,
                                                                )
                                                                .eqOrNull(
                                                                  'attending_id',
                                                                  currentUserUid,
                                                                ),
                                                          ),
                                                          builder: (context,
                                                              snapshot) {
                                                            // Customize what your widget looks like when it's loading.
                                                            if (!snapshot
                                                                .hasData) {
                                                              return CompLoadingWidget(
                                                                name:
                                                                    'eventCard',
                                                              );
                                                            }
                                                            List<EventAttendingRow>
                                                                containerEventAttendingRowList =
                                                                snapshot.data!;

                                                            final containerEventAttendingRow =
                                                                containerEventAttendingRowList
                                                                        .isNotEmpty
                                                                    ? containerEventAttendingRowList
                                                                        .first
                                                                    : null;

                                                            return InkWell(
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
                                                                context
                                                                    .pushNamed(
                                                                  EventDetailsWidget
                                                                      .routeName,
                                                                  queryParameters:
                                                                      {
                                                                    'eventId':
                                                                        serializeParam(
                                                                      endingEventGridViewEventPageRow
                                                                          .id,
                                                                      ParamType
                                                                          .String,
                                                                    ),
                                                                  }.withoutNulls,
                                                                );
                                                              },
                                                              child: Container(
                                                                height: 316.0,
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .secondaryBackground,
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              8.0),
                                                                  border: Border
                                                                      .all(
                                                                    color: FlutterFlowTheme.of(
                                                                            context)
                                                                        .greyL2,
                                                                  ),
                                                                ),
                                                                child: Padding(
                                                                  padding: EdgeInsetsDirectional
                                                                      .fromSTEB(
                                                                          8.0,
                                                                          8.0,
                                                                          8.0,
                                                                          8.0),
                                                                  child: Column(
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .max,
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Stack(
                                                                        alignment: AlignmentDirectional(
                                                                            -1.0,
                                                                            1.0),
                                                                        children: [
                                                                          ClipRRect(
                                                                            borderRadius:
                                                                                BorderRadius.circular(2.0),
                                                                            child:
                                                                                Image.network(
                                                                              endingEventGridViewEventPageRow.coverImage,
                                                                              width: double.infinity,
                                                                              height: 120.0,
                                                                              fit: BoxFit.cover,
                                                                            ),
                                                                          ),
                                                                          if (functions
                                                                              .endSoon(endingEventGridViewEventPageRow.endDateTime!))
                                                                            Padding(
                                                                              padding: EdgeInsetsDirectional.fromSTEB(8.0, 0.0, 0.0, 8.0),
                                                                              child: ClipRRect(
                                                                                borderRadius: BorderRadius.circular(4.0),
                                                                                child: BackdropFilter(
                                                                                  filter: ImageFilter.blur(
                                                                                    sigmaX: 2.0,
                                                                                    sigmaY: 2.0,
                                                                                  ),
                                                                                  child: Container(
                                                                                    width: 70.0,
                                                                                    height: 18.0,
                                                                                    decoration: BoxDecoration(
                                                                                      color: Color(0x1AFFFFFF),
                                                                                      borderRadius: BorderRadius.circular(4.0),
                                                                                    ),
                                                                                    alignment: AlignmentDirectional(0.0, 0.0),
                                                                                    child: Text(
                                                                                      'Ending Soon',
                                                                                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                            font: GoogleFonts.manrope(
                                                                                              fontWeight: FontWeight.w600,
                                                                                              fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                            ),
                                                                                            color: FlutterFlowTheme.of(context).white,
                                                                                            fontSize: 10.0,
                                                                                            letterSpacing: 0.0,
                                                                                            fontWeight: FontWeight.w600,
                                                                                            fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                            lineHeight: 1.4,
                                                                                          ),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                        ],
                                                                      ),
                                                                      Expanded(
                                                                        child:
                                                                            Column(
                                                                          mainAxisSize:
                                                                              MainAxisSize.max,
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.start,
                                                                          children:
                                                                              [
                                                                            if ((containerEventAttendingRow?.id != null && containerEventAttendingRow?.id != '') &&
                                                                                (containerEventAttendingRow?.isInvited == true) &&
                                                                                (containerEventAttendingRow?.isAttending == false))
                                                                              FutureBuilder<List<PublicUserProfileRow>>(
                                                                                future: PublicUserProfileTable().querySingleRow(
                                                                                  queryFn: (q) => q.eqOrNull(
                                                                                    'id',
                                                                                    containerEventAttendingRow?.invitedBy,
                                                                                  ),
                                                                                ),
                                                                                builder: (context, snapshot) {
                                                                                  // Customize what your widget looks like when it's loading.
                                                                                  if (!snapshot.hasData) {
                                                                                    return CompLoadingWidget(
                                                                                      name: 'loadingInvite',
                                                                                    );
                                                                                  }
                                                                                  List<PublicUserProfileRow> rowPublicUserProfileRowList = snapshot.data!;

                                                                                  // Return an empty Container when the item does not exist.
                                                                                  if (snapshot.data!.isEmpty) {
                                                                                    return Container();
                                                                                  }
                                                                                  final rowPublicUserProfileRow = rowPublicUserProfileRowList.isNotEmpty ? rowPublicUserProfileRowList.first : null;

                                                                                  return Row(
                                                                                    mainAxisSize: MainAxisSize.max,
                                                                                    children: [
                                                                                      Container(
                                                                                        width: 12.0,
                                                                                        height: 12.0,
                                                                                        clipBehavior: Clip.antiAlias,
                                                                                        decoration: BoxDecoration(
                                                                                          shape: BoxShape.circle,
                                                                                        ),
                                                                                        child: Image.network(
                                                                                          rowPublicUserProfileRow!.profilePicture!,
                                                                                          fit: BoxFit.cover,
                                                                                        ),
                                                                                      ),
                                                                                      Expanded(
                                                                                        child: Row(
                                                                                          mainAxisSize: MainAxisSize.max,
                                                                                          children: [
                                                                                            Text(
                                                                                              valueOrDefault<String>(
                                                                                                rowPublicUserProfileRow?.name,
                                                                                                'name  jjhgjh jhjhjh jhjhjhj',
                                                                                              ),
                                                                                              style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                                    font: GoogleFonts.manrope(
                                                                                                      fontWeight: FontWeight.w500,
                                                                                                      fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                    ),
                                                                                                    color: FlutterFlowTheme.of(context).greyL4,
                                                                                                    fontSize: 10.0,
                                                                                                    letterSpacing: 0.0,
                                                                                                    fontWeight: FontWeight.w500,
                                                                                                    fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                    lineHeight: 1.4,
                                                                                                  ),
                                                                                            ),
                                                                                            Expanded(
                                                                                              child: Text(
                                                                                                ' invited you to join this event',
                                                                                                maxLines: 1,
                                                                                                style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                                      font: GoogleFonts.manrope(
                                                                                                        fontWeight: FontWeight.w500,
                                                                                                        fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                      ),
                                                                                                      color: FlutterFlowTheme.of(context).greyL4,
                                                                                                      fontSize: 10.0,
                                                                                                      letterSpacing: 0.0,
                                                                                                      fontWeight: FontWeight.w500,
                                                                                                      fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                      lineHeight: 1.4,
                                                                                                    ),
                                                                                              ),
                                                                                            ),
                                                                                          ],
                                                                                        ),
                                                                                      ),
                                                                                    ].divide(SizedBox(width: 10.0)),
                                                                                  );
                                                                                },
                                                                              ),
                                                                            Column(
                                                                              mainAxisSize: MainAxisSize.max,
                                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                                              children: [
                                                                                Text(
                                                                                  endingEventGridViewEventPageRow.name,
                                                                                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                        font: GoogleFonts.manrope(
                                                                                          fontWeight: FontWeight.w600,
                                                                                          fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                        ),
                                                                                        color: FlutterFlowTheme.of(context).extraBlack,
                                                                                        fontSize: 16.0,
                                                                                        letterSpacing: 0.0,
                                                                                        fontWeight: FontWeight.w600,
                                                                                        fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                        lineHeight: 1.4,
                                                                                      ),
                                                                                ),
                                                                                Text(
                                                                                  endingEventGridViewEventPageRow.description,
                                                                                  maxLines: containerEventAttendingRow?.isInvited == true ? 1 : 3,
                                                                                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                        font: GoogleFonts.manrope(
                                                                                          fontWeight: FontWeight.w500,
                                                                                          fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                        ),
                                                                                        color: FlutterFlowTheme.of(context).greyL4,
                                                                                        fontSize: 10.0,
                                                                                        letterSpacing: 0.0,
                                                                                        fontWeight: FontWeight.w500,
                                                                                        fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                        lineHeight: 1.4,
                                                                                      ),
                                                                                ),
                                                                              ].divide(SizedBox(height: 2.0)),
                                                                            ),
                                                                            Column(
                                                                              mainAxisSize: MainAxisSize.max,
                                                                              children: [
                                                                                Row(
                                                                                  mainAxisSize: MainAxisSize.max,
                                                                                  children: [
                                                                                    ClipRRect(
                                                                                      borderRadius: BorderRadius.circular(0.0),
                                                                                      child: Image.asset(
                                                                                        'assets/images/calendar_clock.png',
                                                                                        width: 16.0,
                                                                                        height: 16.0,
                                                                                        fit: BoxFit.cover,
                                                                                      ),
                                                                                    ),
                                                                                    Text(
                                                                                      valueOrDefault<String>(
                                                                                        functions.eventDate(endingEventGridViewEventPageRow.startDateTime),
                                                                                        'May 23, 6:00 PM UTC',
                                                                                      ),
                                                                                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                            font: GoogleFonts.manrope(
                                                                                              fontWeight: FontWeight.w500,
                                                                                              fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                            ),
                                                                                            color: FlutterFlowTheme.of(context).greyL4,
                                                                                            fontSize: 10.0,
                                                                                            letterSpacing: 0.0,
                                                                                            fontWeight: FontWeight.w500,
                                                                                            fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                            lineHeight: 1.4,
                                                                                          ),
                                                                                    ),
                                                                                  ].divide(SizedBox(width: 6.0)),
                                                                                ),
                                                                                Row(
                                                                                  mainAxisSize: MainAxisSize.max,
                                                                                  children: [
                                                                                    ClipRRect(
                                                                                      borderRadius: BorderRadius.circular(0.0),
                                                                                      child: Image.asset(
                                                                                        'assets/images/explore.png',
                                                                                        width: 16.0,
                                                                                        height: 16.0,
                                                                                        fit: BoxFit.cover,
                                                                                      ),
                                                                                    ),
                                                                                    Flexible(
                                                                                      child: Text(
                                                                                        valueOrDefault<String>(
                                                                                          endingEventGridViewEventPageRow.address,
                                                                                          'Address',
                                                                                        ),
                                                                                        maxLines: 1,
                                                                                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                              font: GoogleFonts.manrope(
                                                                                                fontWeight: FontWeight.w500,
                                                                                                fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                              ),
                                                                                              color: FlutterFlowTheme.of(context).greyL4,
                                                                                              fontSize: 10.0,
                                                                                              letterSpacing: 0.0,
                                                                                              fontWeight: FontWeight.w500,
                                                                                              fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                              lineHeight: 1.4,
                                                                                            ),
                                                                                      ),
                                                                                    ),
                                                                                  ].divide(SizedBox(width: 6.0)),
                                                                                ),
                                                                                Row(
                                                                                  mainAxisSize: MainAxisSize.max,
                                                                                  children: [
                                                                                    ClipRRect(
                                                                                      borderRadius: BorderRadius.circular(0.0),
                                                                                      child: Image.asset(
                                                                                        'assets/images/crowdsource_(1).png',
                                                                                        width: 16.0,
                                                                                        height: 16.0,
                                                                                        fit: BoxFit.cover,
                                                                                      ),
                                                                                    ),
                                                                                    Text(
                                                                                      '${endingEventGridViewEventPageRow.attendeeCount.toString()} attending',
                                                                                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                            font: GoogleFonts.manrope(
                                                                                              fontWeight: FontWeight.w500,
                                                                                              fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                            ),
                                                                                            color: FlutterFlowTheme.of(context).greyL4,
                                                                                            fontSize: 10.0,
                                                                                            letterSpacing: 0.0,
                                                                                            fontWeight: FontWeight.w500,
                                                                                            fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                            lineHeight: 1.4,
                                                                                          ),
                                                                                    ),
                                                                                  ].divide(SizedBox(width: 6.0)),
                                                                                ),
                                                                              ].divide(SizedBox(height: 4.0)),
                                                                            ),
                                                                          ].divide(SizedBox(height: 4.0)),
                                                                        ),
                                                                      ),
                                                                      if (endingEventGridViewEventPageRow
                                                                              .adminUser !=
                                                                          currentUserUid)
                                                                        Stack(
                                                                          children: [
                                                                            FFButtonWidget(
                                                                              onPressed: () async {
                                                                                await EventAttendingTable().insert({
                                                                                  'community_id': endingEventGridViewEventPageRow.communityId,
                                                                                  'event_id': endingEventGridViewEventPageRow.id,
                                                                                  'attending_id': currentUserUid,
                                                                                  'is_invited': false,
                                                                                  'is_attending': true,
                                                                                });
                                                                                _model.apiResultrykmlk = await UpdateEventAttendeeCountCall.call(
                                                                                  token: currentJwtToken,
                                                                                  eventId: endingEventGridViewEventPageRow.id,
                                                                                );

                                                                                safeSetState(() {});
                                                                              },
                                                                              text: 'Attend',
                                                                              icon: Icon(
                                                                                Icons.edit_calendar_outlined,
                                                                                size: 15.0,
                                                                              ),
                                                                              options: FFButtonOptions(
                                                                                width: double.infinity,
                                                                                height: 24.0,
                                                                                padding: EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                                                                                iconPadding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                                                                                color: FlutterFlowTheme.of(context).white,
                                                                                textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                                                                                      font: GoogleFonts.interTight(
                                                                                        fontWeight: FlutterFlowTheme.of(context).titleSmall.fontWeight,
                                                                                        fontStyle: FlutterFlowTheme.of(context).titleSmall.fontStyle,
                                                                                      ),
                                                                                      color: FlutterFlowTheme.of(context).primaryD3,
                                                                                      fontSize: 12.0,
                                                                                      letterSpacing: 0.0,
                                                                                      fontWeight: FlutterFlowTheme.of(context).titleSmall.fontWeight,
                                                                                      fontStyle: FlutterFlowTheme.of(context).titleSmall.fontStyle,
                                                                                    ),
                                                                                elevation: 0.0,
                                                                                borderSide: BorderSide(
                                                                                  color: FlutterFlowTheme.of(context).primaryD3,
                                                                                  width: 1.0,
                                                                                ),
                                                                                borderRadius: BorderRadius.only(
                                                                                  topLeft: Radius.circular(100.0),
                                                                                  topRight: Radius.circular(100.0),
                                                                                  bottomLeft: Radius.circular(100.0),
                                                                                  bottomRight: Radius.circular(100.0),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            if ((containerEventAttendingRow?.id != null && containerEventAttendingRow?.id != '') &&
                                                                                (containerEventAttendingRow?.isAttending == false))
                                                                              FFButtonWidget(
                                                                                onPressed: () async {
                                                                                  await EventAttendingTable().update(
                                                                                    data: {
                                                                                      'is_attending': true,
                                                                                    },
                                                                                    matchingRows: (rows) => rows
                                                                                        .eqOrNull(
                                                                                          'event_id',
                                                                                          endingEventGridViewEventPageRow.id,
                                                                                        )
                                                                                        .eqOrNull(
                                                                                          'attending_id',
                                                                                          currentUserUid,
                                                                                        ),
                                                                                  );
                                                                                  _model.apiResultryklop = await UpdateEventAttendeeCountCall.call(
                                                                                    token: currentJwtToken,
                                                                                    eventId: endingEventGridViewEventPageRow.id,
                                                                                  );

                                                                                  safeSetState(() {});
                                                                                },
                                                                                text: 'Attend',
                                                                                icon: Icon(
                                                                                  Icons.edit_calendar_outlined,
                                                                                  size: 15.0,
                                                                                ),
                                                                                options: FFButtonOptions(
                                                                                  width: double.infinity,
                                                                                  height: 24.0,
                                                                                  padding: EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                                                                                  iconPadding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                                                                                  color: FlutterFlowTheme.of(context).white,
                                                                                  textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                                                                                        font: GoogleFonts.interTight(
                                                                                          fontWeight: FlutterFlowTheme.of(context).titleSmall.fontWeight,
                                                                                          fontStyle: FlutterFlowTheme.of(context).titleSmall.fontStyle,
                                                                                        ),
                                                                                        color: FlutterFlowTheme.of(context).primaryD3,
                                                                                        fontSize: 12.0,
                                                                                        letterSpacing: 0.0,
                                                                                        fontWeight: FlutterFlowTheme.of(context).titleSmall.fontWeight,
                                                                                        fontStyle: FlutterFlowTheme.of(context).titleSmall.fontStyle,
                                                                                      ),
                                                                                  elevation: 0.0,
                                                                                  borderSide: BorderSide(
                                                                                    color: FlutterFlowTheme.of(context).primaryD3,
                                                                                    width: 1.0,
                                                                                  ),
                                                                                  borderRadius: BorderRadius.only(
                                                                                    topLeft: Radius.circular(100.0),
                                                                                    topRight: Radius.circular(100.0),
                                                                                    bottomLeft: Radius.circular(100.0),
                                                                                    bottomRight: Radius.circular(100.0),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            if ((containerEventAttendingRow?.id != null && containerEventAttendingRow?.id != '') &&
                                                                                (containerEventAttendingRow?.isAttending == true))
                                                                              FFButtonWidget(
                                                                                onPressed: () async {
                                                                                  await EventAttendingTable().update(
                                                                                    data: {
                                                                                      'is_attending': false,
                                                                                    },
                                                                                    matchingRows: (rows) => rows
                                                                                        .eqOrNull(
                                                                                          'event_id',
                                                                                          endingEventGridViewEventPageRow.id,
                                                                                        )
                                                                                        .eqOrNull(
                                                                                          'attending_id',
                                                                                          currentUserUid,
                                                                                        ),
                                                                                  );
                                                                                  _model.apiResultrykkl = await UpdateEventAttendeeCountCall.call(
                                                                                    token: currentJwtToken,
                                                                                    eventId: endingEventGridViewEventPageRow.id,
                                                                                  );

                                                                                  safeSetState(() {});
                                                                                },
                                                                                text: 'Attending',
                                                                                icon: Icon(
                                                                                  Icons.edit_calendar_outlined,
                                                                                  size: 15.0,
                                                                                ),
                                                                                options: FFButtonOptions(
                                                                                  width: double.infinity,
                                                                                  height: 24.0,
                                                                                  padding: EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                                                                                  iconPadding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                                                                                  color: FlutterFlowTheme.of(context).white,
                                                                                  textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                                                                                        font: GoogleFonts.interTight(
                                                                                          fontWeight: FlutterFlowTheme.of(context).titleSmall.fontWeight,
                                                                                          fontStyle: FlutterFlowTheme.of(context).titleSmall.fontStyle,
                                                                                        ),
                                                                                        color: FlutterFlowTheme.of(context).greyL4,
                                                                                        fontSize: 12.0,
                                                                                        letterSpacing: 0.0,
                                                                                        fontWeight: FlutterFlowTheme.of(context).titleSmall.fontWeight,
                                                                                        fontStyle: FlutterFlowTheme.of(context).titleSmall.fontStyle,
                                                                                      ),
                                                                                  elevation: 0.0,
                                                                                  borderSide: BorderSide(
                                                                                    color: FlutterFlowTheme.of(context).greyL4,
                                                                                    width: 1.0,
                                                                                  ),
                                                                                  borderRadius: BorderRadius.only(
                                                                                    topLeft: Radius.circular(100.0),
                                                                                    topRight: Radius.circular(100.0),
                                                                                    bottomLeft: Radius.circular(100.0),
                                                                                    bottomRight: Radius.circular(100.0),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                          ],
                                                                        ),
                                                                    ].divide(SizedBox(
                                                                        height:
                                                                            8.0)),
                                                                  ),
                                                                ),
                                                              ),
                                                            );
                                                          },
                                                        );
                                                      },
                                                    );
                                                  },
                                                ),
                                              ),
                                            ].addToEnd(SizedBox(height: 12.0)),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            0.0, 8.0, 0.0, 0.0),
                                        child: Container(
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                            color: FlutterFlowTheme.of(context)
                                                .secondaryBackground,
                                          ),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Container(
                                                width: double.infinity,
                                                decoration: BoxDecoration(
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryBackground,
                                                ),
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          EdgeInsetsDirectional
                                                              .fromSTEB(
                                                                  20.0,
                                                                  12.0,
                                                                  20.0,
                                                                  11.0),
                                                      child: Column(
                                                        mainAxisSize:
                                                            MainAxisSize.max,
                                                        children: [
                                                          Container(
                                                            decoration:
                                                                BoxDecoration(
                                                              color: FlutterFlowTheme
                                                                      .of(context)
                                                                  .secondaryBackground,
                                                            ),
                                                            child: Padding(
                                                              padding:
                                                                  EdgeInsetsDirectional
                                                                      .fromSTEB(
                                                                          0.0,
                                                                          0.0,
                                                                          0.0,
                                                                          8.0),
                                                              child: Row(
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .max,
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                children: [
                                                                  Text(
                                                                    'All Events',
                                                                    style: FlutterFlowTheme.of(
                                                                            context)
                                                                        .bodyMedium
                                                                        .override(
                                                                          font:
                                                                              GoogleFonts.manrope(
                                                                            fontWeight:
                                                                                FontWeight.w600,
                                                                            fontStyle:
                                                                                FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                          ),
                                                                          color:
                                                                              FlutterFlowTheme.of(context).extraBlack,
                                                                          fontSize:
                                                                              18.0,
                                                                          letterSpacing:
                                                                              0.0,
                                                                          fontWeight:
                                                                              FontWeight.w600,
                                                                          fontStyle: FlutterFlowTheme.of(context)
                                                                              .bodyMedium
                                                                              .fontStyle,
                                                                          lineHeight:
                                                                              1.4,
                                                                        ),
                                                                  ),
                                                                  InkWell(
                                                                    splashColor:
                                                                        Colors
                                                                            .transparent,
                                                                    focusColor:
                                                                        Colors
                                                                            .transparent,
                                                                    hoverColor:
                                                                        Colors
                                                                            .transparent,
                                                                    highlightColor:
                                                                        Colors
                                                                            .transparent,
                                                                    onTap:
                                                                        () async {
                                                                      context.pushNamed(
                                                                          AllEventsWidget
                                                                              .routeName);
                                                                    },
                                                                    child: Icon(
                                                                      Icons
                                                                          .arrow_forward,
                                                                      color: FlutterFlowTheme.of(
                                                                              context)
                                                                          .primaryText,
                                                                      size:
                                                                          24.0,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Container(
                                                      width: double.infinity,
                                                      height: 1.0,
                                                      decoration: BoxDecoration(
                                                        color: FlutterFlowTheme
                                                                .of(context)
                                                            .secondaryBackground,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Padding(
                                                padding: EdgeInsetsDirectional
                                                    .fromSTEB(
                                                        20.0, 0.0, 20.0, 0.0),
                                                child: FutureBuilder<
                                                    List<EventPageRow>>(
                                                  future: (_model
                                                              .requestCompleter4 ??=
                                                          Completer<
                                                              List<
                                                                  EventPageRow>>()
                                                            ..complete(
                                                                EventPageTable()
                                                                    .queryRows(
                                                              queryFn: (q) => q
                                                                  .eqOrNull(
                                                                    'is_deleted',
                                                                    false,
                                                                  )
                                                                  .gtOrNull(
                                                                    'end_date_time',
                                                                    supaSerialize<
                                                                            DateTime>(
                                                                        getCurrentTimestamp),
                                                                  )
                                                                  .order(
                                                                      'created_at'),
                                                              limit: 4,
                                                            )))
                                                      .future,
                                                  builder: (context, snapshot) {
                                                    // Customize what your widget looks like when it's loading.
                                                    if (!snapshot.hasData) {
                                                      return Center(
                                                        child: SizedBox(
                                                          width: 50.0,
                                                          height: 50.0,
                                                          child:
                                                              CircularProgressIndicator(
                                                            valueColor:
                                                                AlwaysStoppedAnimation<
                                                                    Color>(
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .primary,
                                                            ),
                                                          ),
                                                        ),
                                                      );
                                                    }
                                                    List<EventPageRow>
                                                        allEventsListViewEventPageRowList =
                                                        snapshot.data!;

                                                    if (allEventsListViewEventPageRowList
                                                        .isEmpty) {
                                                      return CompNoDataFoundWidget(
                                                        pageName: 'no',
                                                        text1:
                                                            'No events to show',
                                                        text2:
                                                            'Looks like no one has uploaded anything yet. Check back soon!',
                                                      );
                                                    }

                                                    return ListView.separated(
                                                      padding: EdgeInsets.zero,
                                                      primary: false,
                                                      shrinkWrap: true,
                                                      scrollDirection:
                                                          Axis.vertical,
                                                      itemCount:
                                                          allEventsListViewEventPageRowList
                                                              .length,
                                                      separatorBuilder:
                                                          (_, __) => SizedBox(
                                                              height: 12.0),
                                                      itemBuilder: (context,
                                                          allEventsListViewIndex) {
                                                        final allEventsListViewEventPageRow =
                                                            allEventsListViewEventPageRowList[
                                                                allEventsListViewIndex];
                                                        return FutureBuilder<
                                                            List<
                                                                EventAttendingRow>>(
                                                          future:
                                                              EventAttendingTable()
                                                                  .querySingleRow(
                                                            queryFn: (q) => q
                                                                .eqOrNull(
                                                                  'event_id',
                                                                  allEventsListViewEventPageRow
                                                                      .id,
                                                                )
                                                                .eqOrNull(
                                                                  'attending_id',
                                                                  currentUserUid,
                                                                ),
                                                          ),
                                                          builder: (context,
                                                              snapshot) {
                                                            // Customize what your widget looks like when it's loading.
                                                            if (!snapshot
                                                                .hasData) {
                                                              return CompLoadingWidget(
                                                                name:
                                                                    'eventCard2',
                                                              );
                                                            }
                                                            List<EventAttendingRow>
                                                                containerEventAttendingRowList =
                                                                snapshot.data!;

                                                            final containerEventAttendingRow =
                                                                containerEventAttendingRowList
                                                                        .isNotEmpty
                                                                    ? containerEventAttendingRowList
                                                                        .first
                                                                    : null;

                                                            return InkWell(
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
                                                                context
                                                                    .pushNamed(
                                                                  EventDetailsWidget
                                                                      .routeName,
                                                                  queryParameters:
                                                                      {
                                                                    'eventId':
                                                                        serializeParam(
                                                                      allEventsListViewEventPageRow
                                                                          .id,
                                                                      ParamType
                                                                          .String,
                                                                    ),
                                                                  }.withoutNulls,
                                                                );
                                                              },
                                                              child: Container(
                                                                height: 188.0,
                                                                decoration:
                                                                    BoxDecoration(),
                                                                child: Padding(
                                                                  padding: EdgeInsetsDirectional
                                                                      .fromSTEB(
                                                                          0.0,
                                                                          8.0,
                                                                          0.0,
                                                                          8.0),
                                                                  child: Row(
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .max,
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      ClipRRect(
                                                                        borderRadius:
                                                                            BorderRadius.circular(2.0),
                                                                        child: Image
                                                                            .network(
                                                                          allEventsListViewEventPageRow
                                                                              .coverImage,
                                                                          width:
                                                                              120.0,
                                                                          height:
                                                                              120.0,
                                                                          fit: BoxFit
                                                                              .cover,
                                                                        ),
                                                                      ),
                                                                      Expanded(
                                                                        child:
                                                                            Column(
                                                                          mainAxisSize:
                                                                              MainAxisSize.max,
                                                                          children: [
                                                                            Expanded(
                                                                              child: Column(
                                                                                mainAxisSize: MainAxisSize.max,
                                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                                children: [
                                                                                  if ((containerEventAttendingRow?.id != null && containerEventAttendingRow?.id != '') && (containerEventAttendingRow?.isInvited == true) && (containerEventAttendingRow?.isAttending == false))
                                                                                    FutureBuilder<List<PublicUserProfileRow>>(
                                                                                      future: PublicUserProfileTable().querySingleRow(
                                                                                        queryFn: (q) => q.eqOrNull(
                                                                                          'id',
                                                                                          containerEventAttendingRow?.invitedBy,
                                                                                        ),
                                                                                      ),
                                                                                      builder: (context, snapshot) {
                                                                                        // Customize what your widget looks like when it's loading.
                                                                                        if (!snapshot.hasData) {
                                                                                          return CompLoadingWidget(
                                                                                            name: 'loadingInvite',
                                                                                          );
                                                                                        }
                                                                                        List<PublicUserProfileRow> rowPublicUserProfileRowList = snapshot.data!;

                                                                                        // Return an empty Container when the item does not exist.
                                                                                        if (snapshot.data!.isEmpty) {
                                                                                          return Container();
                                                                                        }
                                                                                        final rowPublicUserProfileRow = rowPublicUserProfileRowList.isNotEmpty ? rowPublicUserProfileRowList.first : null;

                                                                                        return Row(
                                                                                          mainAxisSize: MainAxisSize.max,
                                                                                          children: [
                                                                                            Container(
                                                                                              width: 12.0,
                                                                                              height: 12.0,
                                                                                              clipBehavior: Clip.antiAlias,
                                                                                              decoration: BoxDecoration(
                                                                                                shape: BoxShape.circle,
                                                                                              ),
                                                                                              child: Image.network(
                                                                                                rowPublicUserProfileRow!.profilePicture!,
                                                                                                fit: BoxFit.cover,
                                                                                              ),
                                                                                            ),
                                                                                            Expanded(
                                                                                              child: Row(
                                                                                                mainAxisSize: MainAxisSize.max,
                                                                                                children: [
                                                                                                  Text(
                                                                                                    valueOrDefault<String>(
                                                                                                      rowPublicUserProfileRow?.name,
                                                                                                      'name  jjhgjh jhjhjh jhjhjhj',
                                                                                                    ),
                                                                                                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                                          font: GoogleFonts.manrope(
                                                                                                            fontWeight: FontWeight.w500,
                                                                                                            fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                          ),
                                                                                                          color: FlutterFlowTheme.of(context).greyL4,
                                                                                                          fontSize: 10.0,
                                                                                                          letterSpacing: 0.0,
                                                                                                          fontWeight: FontWeight.w500,
                                                                                                          fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                          lineHeight: 1.4,
                                                                                                        ),
                                                                                                  ),
                                                                                                  Expanded(
                                                                                                    child: Text(
                                                                                                      ' invited you to join this event',
                                                                                                      maxLines: 1,
                                                                                                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                                            font: GoogleFonts.manrope(
                                                                                                              fontWeight: FontWeight.w500,
                                                                                                              fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                            ),
                                                                                                            color: FlutterFlowTheme.of(context).greyL4,
                                                                                                            fontSize: 10.0,
                                                                                                            letterSpacing: 0.0,
                                                                                                            fontWeight: FontWeight.w500,
                                                                                                            fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                            lineHeight: 1.4,
                                                                                                          ),
                                                                                                    ),
                                                                                                  ),
                                                                                                ],
                                                                                              ),
                                                                                            ),
                                                                                          ].divide(SizedBox(width: 10.0)),
                                                                                        );
                                                                                      },
                                                                                    ),
                                                                                  Column(
                                                                                    mainAxisSize: MainAxisSize.max,
                                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                                    children: [
                                                                                      Text(
                                                                                        allEventsListViewEventPageRow.name,
                                                                                        maxLines: 2,
                                                                                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                              font: GoogleFonts.manrope(
                                                                                                fontWeight: FontWeight.w600,
                                                                                                fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                              ),
                                                                                              color: FlutterFlowTheme.of(context).extraBlack,
                                                                                              fontSize: 16.0,
                                                                                              letterSpacing: 0.0,
                                                                                              fontWeight: FontWeight.w600,
                                                                                              fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                              lineHeight: 1.4,
                                                                                            ),
                                                                                      ),
                                                                                      Text(
                                                                                        allEventsListViewEventPageRow.description,
                                                                                        maxLines: 2,
                                                                                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                              font: GoogleFonts.manrope(
                                                                                                fontWeight: FontWeight.w500,
                                                                                                fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                              ),
                                                                                              color: FlutterFlowTheme.of(context).greyL4,
                                                                                              fontSize: 10.0,
                                                                                              letterSpacing: 0.0,
                                                                                              fontWeight: FontWeight.w500,
                                                                                              fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                              lineHeight: 1.4,
                                                                                            ),
                                                                                      ),
                                                                                    ].divide(SizedBox(height: 2.0)),
                                                                                  ),
                                                                                  Padding(
                                                                                    padding: EdgeInsetsDirectional.fromSTEB(0.0, 4.0, 0.0, 0.0),
                                                                                    child: Column(
                                                                                      mainAxisSize: MainAxisSize.max,
                                                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                                                      children: [
                                                                                        Row(
                                                                                          mainAxisSize: MainAxisSize.max,
                                                                                          children: [
                                                                                            ClipRRect(
                                                                                              borderRadius: BorderRadius.circular(0.0),
                                                                                              child: Image.asset(
                                                                                                'assets/images/calendar_clock.png',
                                                                                                width: 16.0,
                                                                                                height: 16.0,
                                                                                                fit: BoxFit.cover,
                                                                                              ),
                                                                                            ),
                                                                                            Text(
                                                                                              valueOrDefault<String>(
                                                                                                functions.eventDate(allEventsListViewEventPageRow.startDateTime),
                                                                                                'date',
                                                                                              ),
                                                                                              style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                                    font: GoogleFonts.manrope(
                                                                                                      fontWeight: FontWeight.w500,
                                                                                                      fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                    ),
                                                                                                    color: FlutterFlowTheme.of(context).greyL4,
                                                                                                    fontSize: 10.0,
                                                                                                    letterSpacing: 0.0,
                                                                                                    fontWeight: FontWeight.w500,
                                                                                                    fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                    lineHeight: 1.4,
                                                                                                  ),
                                                                                            ),
                                                                                          ].divide(SizedBox(width: 6.0)),
                                                                                        ),
                                                                                        Row(
                                                                                          mainAxisSize: MainAxisSize.max,
                                                                                          children: [
                                                                                            ClipRRect(
                                                                                              borderRadius: BorderRadius.circular(0.0),
                                                                                              child: Image.asset(
                                                                                                'assets/images/explore.png',
                                                                                                width: 16.0,
                                                                                                height: 16.0,
                                                                                                fit: BoxFit.cover,
                                                                                              ),
                                                                                            ),
                                                                                            Expanded(
                                                                                              child: Text(
                                                                                                valueOrDefault<String>(
                                                                                                  allEventsListViewEventPageRow.address,
                                                                                                  'Address',
                                                                                                ),
                                                                                                maxLines: 1,
                                                                                                style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                                      font: GoogleFonts.manrope(
                                                                                                        fontWeight: FontWeight.w500,
                                                                                                        fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                      ),
                                                                                                      color: FlutterFlowTheme.of(context).greyL4,
                                                                                                      fontSize: 10.0,
                                                                                                      letterSpacing: 0.0,
                                                                                                      fontWeight: FontWeight.w500,
                                                                                                      fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                      lineHeight: 1.4,
                                                                                                    ),
                                                                                              ),
                                                                                            ),
                                                                                          ].divide(SizedBox(width: 6.0)),
                                                                                        ),
                                                                                        Row(
                                                                                          mainAxisSize: MainAxisSize.max,
                                                                                          children: [
                                                                                            ClipRRect(
                                                                                              borderRadius: BorderRadius.circular(0.0),
                                                                                              child: Image.asset(
                                                                                                'assets/images/crowdsource_(1).png',
                                                                                                width: 16.0,
                                                                                                height: 16.0,
                                                                                                fit: BoxFit.cover,
                                                                                              ),
                                                                                            ),
                                                                                            Text(
                                                                                              '${allEventsListViewEventPageRow.attendeeCount.toString()} attending',
                                                                                              style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                                    font: GoogleFonts.manrope(
                                                                                                      fontWeight: FontWeight.w500,
                                                                                                      fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                    ),
                                                                                                    color: FlutterFlowTheme.of(context).greyL4,
                                                                                                    fontSize: 10.0,
                                                                                                    letterSpacing: 0.0,
                                                                                                    fontWeight: FontWeight.w500,
                                                                                                    fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                    lineHeight: 1.4,
                                                                                                  ),
                                                                                            ),
                                                                                          ].divide(SizedBox(width: 6.0)),
                                                                                        ),
                                                                                      ].divide(SizedBox(height: 4.0)),
                                                                                    ),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                            if (allEventsListViewEventPageRow.adminUser !=
                                                                                currentUserUid)
                                                                              Stack(
                                                                                children: [
                                                                                  FFButtonWidget(
                                                                                    onPressed: () async {
                                                                                      await EventAttendingTable().insert({
                                                                                        'community_id': FFAppState().communityId,
                                                                                        'event_id': allEventsListViewEventPageRow.id,
                                                                                        'attending_id': currentUserUid,
                                                                                        'is_invited': false,
                                                                                        'is_attending': true,
                                                                                      });
                                                                                      _model.apiResultryklop67 = await UpdateEventAttendeeCountCall.call(
                                                                                        token: currentJwtToken,
                                                                                        eventId: allEventsListViewEventPageRow.id,
                                                                                      );

                                                                                      safeSetState(() {});
                                                                                    },
                                                                                    text: 'Attend',
                                                                                    icon: Icon(
                                                                                      Icons.edit_calendar_outlined,
                                                                                      size: 15.0,
                                                                                    ),
                                                                                    options: FFButtonOptions(
                                                                                      width: double.infinity,
                                                                                      height: 24.0,
                                                                                      padding: EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                                                                                      iconPadding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                                                                                      color: FlutterFlowTheme.of(context).white,
                                                                                      textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                                                                                            font: GoogleFonts.interTight(
                                                                                              fontWeight: FlutterFlowTheme.of(context).titleSmall.fontWeight,
                                                                                              fontStyle: FlutterFlowTheme.of(context).titleSmall.fontStyle,
                                                                                            ),
                                                                                            color: FlutterFlowTheme.of(context).primaryD3,
                                                                                            fontSize: 12.0,
                                                                                            letterSpacing: 0.0,
                                                                                            fontWeight: FlutterFlowTheme.of(context).titleSmall.fontWeight,
                                                                                            fontStyle: FlutterFlowTheme.of(context).titleSmall.fontStyle,
                                                                                          ),
                                                                                      elevation: 0.0,
                                                                                      borderSide: BorderSide(
                                                                                        color: FlutterFlowTheme.of(context).primaryD3,
                                                                                        width: 1.0,
                                                                                      ),
                                                                                      borderRadius: BorderRadius.only(
                                                                                        topLeft: Radius.circular(100.0),
                                                                                        topRight: Radius.circular(100.0),
                                                                                        bottomLeft: Radius.circular(100.0),
                                                                                        bottomRight: Radius.circular(100.0),
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                  if ((containerEventAttendingRow?.id != null && containerEventAttendingRow?.id != '') && (containerEventAttendingRow?.isAttending == false))
                                                                                    FFButtonWidget(
                                                                                      onPressed: () async {
                                                                                        await EventAttendingTable().update(
                                                                                          data: {
                                                                                            'is_attending': true,
                                                                                          },
                                                                                          matchingRows: (rows) => rows
                                                                                              .eqOrNull(
                                                                                                'event_id',
                                                                                                allEventsListViewEventPageRow.id,
                                                                                              )
                                                                                              .eqOrNull(
                                                                                                'attending_id',
                                                                                                currentUserUid,
                                                                                              ),
                                                                                        );
                                                                                        _model.apiResultryklop78 = await UpdateEventAttendeeCountCall.call(
                                                                                          token: currentJwtToken,
                                                                                          eventId: allEventsListViewEventPageRow.id,
                                                                                        );

                                                                                        safeSetState(() {});
                                                                                      },
                                                                                      text: 'Attend',
                                                                                      icon: Icon(
                                                                                        Icons.edit_calendar_outlined,
                                                                                        size: 15.0,
                                                                                      ),
                                                                                      options: FFButtonOptions(
                                                                                        width: double.infinity,
                                                                                        height: 24.0,
                                                                                        padding: EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                                                                                        iconPadding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                                                                                        color: FlutterFlowTheme.of(context).white,
                                                                                        textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                                                                                              font: GoogleFonts.interTight(
                                                                                                fontWeight: FlutterFlowTheme.of(context).titleSmall.fontWeight,
                                                                                                fontStyle: FlutterFlowTheme.of(context).titleSmall.fontStyle,
                                                                                              ),
                                                                                              color: FlutterFlowTheme.of(context).primaryD3,
                                                                                              fontSize: 12.0,
                                                                                              letterSpacing: 0.0,
                                                                                              fontWeight: FlutterFlowTheme.of(context).titleSmall.fontWeight,
                                                                                              fontStyle: FlutterFlowTheme.of(context).titleSmall.fontStyle,
                                                                                            ),
                                                                                        elevation: 0.0,
                                                                                        borderSide: BorderSide(
                                                                                          color: FlutterFlowTheme.of(context).primaryD3,
                                                                                          width: 1.0,
                                                                                        ),
                                                                                        borderRadius: BorderRadius.only(
                                                                                          topLeft: Radius.circular(100.0),
                                                                                          topRight: Radius.circular(100.0),
                                                                                          bottomLeft: Radius.circular(100.0),
                                                                                          bottomRight: Radius.circular(100.0),
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                  if ((containerEventAttendingRow?.id != null && containerEventAttendingRow?.id != '') && (containerEventAttendingRow?.isAttending == true))
                                                                                    FFButtonWidget(
                                                                                      onPressed: () async {
                                                                                        await EventAttendingTable().update(
                                                                                          data: {
                                                                                            'is_attending': false,
                                                                                          },
                                                                                          matchingRows: (rows) => rows
                                                                                              .eqOrNull(
                                                                                                'event_id',
                                                                                                allEventsListViewEventPageRow.id,
                                                                                              )
                                                                                              .eqOrNull(
                                                                                                'attending_id',
                                                                                                currentUserUid,
                                                                                              ),
                                                                                        );
                                                                                        _model.apiResultryklop09 = await UpdateEventAttendeeCountCall.call(
                                                                                          token: currentJwtToken,
                                                                                          eventId: allEventsListViewEventPageRow.id,
                                                                                        );

                                                                                        safeSetState(() {});
                                                                                      },
                                                                                      text: 'Attending',
                                                                                      icon: Icon(
                                                                                        Icons.edit_calendar_outlined,
                                                                                        size: 15.0,
                                                                                      ),
                                                                                      options: FFButtonOptions(
                                                                                        width: double.infinity,
                                                                                        height: 24.0,
                                                                                        padding: EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                                                                                        iconPadding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                                                                                        color: FlutterFlowTheme.of(context).white,
                                                                                        textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                                                                                              font: GoogleFonts.interTight(
                                                                                                fontWeight: FlutterFlowTheme.of(context).titleSmall.fontWeight,
                                                                                                fontStyle: FlutterFlowTheme.of(context).titleSmall.fontStyle,
                                                                                              ),
                                                                                              color: FlutterFlowTheme.of(context).greyL4,
                                                                                              fontSize: 12.0,
                                                                                              letterSpacing: 0.0,
                                                                                              fontWeight: FlutterFlowTheme.of(context).titleSmall.fontWeight,
                                                                                              fontStyle: FlutterFlowTheme.of(context).titleSmall.fontStyle,
                                                                                            ),
                                                                                        elevation: 0.0,
                                                                                        borderSide: BorderSide(
                                                                                          color: FlutterFlowTheme.of(context).greyL4,
                                                                                          width: 1.0,
                                                                                        ),
                                                                                        borderRadius: BorderRadius.only(
                                                                                          topLeft: Radius.circular(100.0),
                                                                                          topRight: Radius.circular(100.0),
                                                                                          bottomLeft: Radius.circular(100.0),
                                                                                          bottomRight: Radius.circular(100.0),
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                ],
                                                                              ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ].divide(SizedBox(
                                                                        width:
                                                                            8.0)),
                                                                  ),
                                                                ),
                                                              ),
                                                            );
                                                          },
                                                        );
                                                      },
                                                    );
                                                  },
                                                ),
                                              ),
                                            ].addToEnd(SizedBox(height: 20.0)),
                                          ),
                                        ),
                                      ),
                                    ].addToEnd(SizedBox(height: 20.0)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (_model.switchBtn == 'business')
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    0.0, 4.0, 0.0, 8.0),
                                child: Container(
                                  width: double.infinity,
                                  height: 52.0,
                                  decoration: BoxDecoration(
                                    color: FlutterFlowTheme.of(context).white,
                                  ),
                                  child: Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        20.0, 0.0, 20.0, 0.0),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        FFButtonWidget(
                                          onPressed: () async {
                                            context.pushNamed(
                                                MyPagesWidget.routeName);
                                          },
                                          text: 'My Pages',
                                          options: FFButtonOptions(
                                            height: 28.0,
                                            padding:
                                                EdgeInsetsDirectional.fromSTEB(
                                                    16.0, 0.0, 16.0, 0.0),
                                            iconPadding:
                                                EdgeInsetsDirectional.fromSTEB(
                                                    0.0, 0.0, 0.0, 0.0),
                                            color: FlutterFlowTheme.of(context)
                                                .white,
                                            textStyle:
                                                FlutterFlowTheme.of(context)
                                                    .labelMedium
                                                    .override(
                                                      font: GoogleFonts.inter(
                                                        fontWeight:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .labelMedium
                                                                .fontWeight,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .labelMedium
                                                                .fontStyle,
                                                      ),
                                                      letterSpacing: 0.0,
                                                      fontWeight:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .labelMedium
                                                              .fontWeight,
                                                      fontStyle:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .labelMedium
                                                              .fontStyle,
                                                    ),
                                            elevation: 0.0,
                                            borderSide: BorderSide(
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .greyL4,
                                              width: 1.0,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(24.0),
                                          ),
                                        ),
                                        FFButtonWidget(
                                          onPressed: () async {
                                            context.pushNamed(
                                              CreatePageWidget.routeName,
                                              queryParameters: {
                                                'pageType': serializeParam(
                                                  'create',
                                                  ParamType.String,
                                                ),
                                              }.withoutNulls,
                                            );
                                          },
                                          text: 'Create Page',
                                          options: FFButtonOptions(
                                            height: 28.0,
                                            padding:
                                                EdgeInsetsDirectional.fromSTEB(
                                                    16.0, 0.0, 16.0, 0.0),
                                            iconPadding:
                                                EdgeInsetsDirectional.fromSTEB(
                                                    0.0, 0.0, 0.0, 0.0),
                                            color: FlutterFlowTheme.of(context)
                                                .white,
                                            textStyle:
                                                FlutterFlowTheme.of(context)
                                                    .labelMedium
                                                    .override(
                                                      font: GoogleFonts.inter(
                                                        fontWeight:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .labelMedium
                                                                .fontWeight,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .labelMedium
                                                                .fontStyle,
                                                      ),
                                                      letterSpacing: 0.0,
                                                      fontWeight:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .labelMedium
                                                              .fontWeight,
                                                      fontStyle:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .labelMedium
                                                              .fontStyle,
                                                    ),
                                            elevation: 0.0,
                                            borderSide: BorderSide(
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .greyL4,
                                              width: 1.0,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(24.0),
                                          ),
                                        ),
                                      ].divide(SizedBox(width: 8.0)),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  width: double.infinity,
                                  height: 100.0,
                                  decoration: BoxDecoration(
                                    color: FlutterFlowTheme.of(context)
                                        .secondaryBackground,
                                  ),
                                  child: FutureBuilder<ApiCallResponse>(
                                    future: GetBusinessCall.call(
                                      pUserid: currentUserUid,
                                      token: currentJwtToken,
                                      pCommunityid: FFAppState().communityId,
                                    ),
                                    builder: (context, snapshot) {
                                      // Customize what your widget looks like when it's loading.
                                      if (!snapshot.hasData) {
                                        return Center(
                                          child: SizedBox(
                                            width: 50.0,
                                            height: 50.0,
                                            child: CircularProgressIndicator(
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                FlutterFlowTheme.of(context)
                                                    .primary,
                                              ),
                                            ),
                                          ),
                                        );
                                      }
                                      final listViewGetBusinessResponse =
                                          snapshot.data!;

                                      return Builder(
                                        builder: (context) {
                                          final business =
                                              listViewGetBusinessResponse
                                                  .jsonBody
                                                  .toList();

                                          return ListView.separated(
                                            padding: EdgeInsets.zero,
                                            primary: false,
                                            shrinkWrap: true,
                                            scrollDirection: Axis.vertical,
                                            itemCount: business.length,
                                            separatorBuilder: (_, __) =>
                                                SizedBox(height: 5.0),
                                            itemBuilder:
                                                (context, businessIndex) {
                                              final businessItem =
                                                  business[businessIndex];
                                              return Column(
                                                mainAxisSize: MainAxisSize.max,
                                                children: [
                                                  InkWell(
                                                    splashColor:
                                                        Colors.transparent,
                                                    focusColor:
                                                        Colors.transparent,
                                                    hoverColor:
                                                        Colors.transparent,
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
                                                              r'''$.id''',
                                                            ).toString(),
                                                            ParamType.String,
                                                          ),
                                                        }.withoutNulls,
                                                      );
                                                    },
                                                    child: Container(
                                                      decoration:
                                                          BoxDecoration(),
                                                      child: Padding(
                                                        padding:
                                                            EdgeInsetsDirectional
                                                                .fromSTEB(
                                                                    20.0,
                                                                    16.0,
                                                                    20.0,
                                                                    16.0),
                                                        child: Row(
                                                          mainAxisSize:
                                                              MainAxisSize.max,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            ClipRRect(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8.0),
                                                              child:
                                                                  Image.network(
                                                                getJsonField(
                                                                  businessItem,
                                                                  r'''$.profile_picture''',
                                                                ).toString(),
                                                                width: 64.0,
                                                                height: 64.0,
                                                                fit: BoxFit
                                                                    .cover,
                                                              ),
                                                            ),
                                                            Flexible(
                                                              child: Column(
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .max,
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Text(
                                                                    getJsonField(
                                                                      businessItem,
                                                                      r'''$.name''',
                                                                    ).toString(),
                                                                    maxLines: 1,
                                                                    style: FlutterFlowTheme.of(
                                                                            context)
                                                                        .bodyMedium
                                                                        .override(
                                                                          font:
                                                                              GoogleFonts.manrope(
                                                                            fontWeight:
                                                                                FontWeight.w600,
                                                                            fontStyle:
                                                                                FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                          ),
                                                                          color:
                                                                              FlutterFlowTheme.of(context).extraBlack,
                                                                          fontSize:
                                                                              16.0,
                                                                          letterSpacing:
                                                                              0.0,
                                                                          fontWeight:
                                                                              FontWeight.w600,
                                                                          fontStyle: FlutterFlowTheme.of(context)
                                                                              .bodyMedium
                                                                              .fontStyle,
                                                                          lineHeight:
                                                                              1.4,
                                                                        ),
                                                                  ),
                                                                  Text(
                                                                    '${getJsonField(
                                                                      businessItem,
                                                                      r'''$.contacted_count''',
                                                                    ).toString()} people contacted this business',
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
                                                                          fontSize:
                                                                              10.0,
                                                                          letterSpacing:
                                                                              0.0,
                                                                          fontWeight:
                                                                              FontWeight.w500,
                                                                          fontStyle: FlutterFlowTheme.of(context)
                                                                              .bodyMedium
                                                                              .fontStyle,
                                                                          lineHeight:
                                                                              1.4,
                                                                        ),
                                                                  ),
                                                                  Padding(
                                                                    padding: EdgeInsetsDirectional
                                                                        .fromSTEB(
                                                                            0.0,
                                                                            8.0,
                                                                            0.0,
                                                                            0.0),
                                                                    child: Row(
                                                                      mainAxisSize:
                                                                          MainAxisSize
                                                                              .max,
                                                                      children:
                                                                          [
                                                                        Expanded(
                                                                          child:
                                                                              FFButtonWidget(
                                                                            onPressed:
                                                                                () async {
                                                                              await showModalBottomSheet(
                                                                                isScrollControlled: true,
                                                                                backgroundColor: Colors.transparent,
                                                                                context: context,
                                                                                builder: (context) {
                                                                                  return GestureDetector(
                                                                                    onTap: () {
                                                                                      FocusScope.of(context).unfocus();
                                                                                      FocusManager.instance.primaryFocus?.unfocus();
                                                                                    },
                                                                                    child: Padding(
                                                                                      padding: MediaQuery.viewInsetsOf(context),
                                                                                      child: CompBusinessContactWidget(
                                                                                        website: getJsonField(
                                                                                          businessItem,
                                                                                          r'''$.website_link''',
                                                                                        ).toString(),
                                                                                        email: getJsonField(
                                                                                          businessItem,
                                                                                          r'''$.email''',
                                                                                        ).toString(),
                                                                                        mobile: getJsonField(
                                                                                          businessItem,
                                                                                          r'''$.phonenumber''',
                                                                                        ).toString(),
                                                                                        userid: getJsonField(
                                                                                          businessItem,
                                                                                          r'''$.admin_user''',
                                                                                        ).toString(),
                                                                                        businessid: getJsonField(
                                                                                          businessItem,
                                                                                          r'''$.id''',
                                                                                        ).toString(),
                                                                                      ),
                                                                                    ),
                                                                                  );
                                                                                },
                                                                              ).then((value) => safeSetState(() {}));
                                                                            },
                                                                            text:
                                                                                'Contact',
                                                                            icon:
                                                                                Icon(
                                                                              Icons.arrow_drop_down,
                                                                              size: 15.0,
                                                                            ),
                                                                            options:
                                                                                FFButtonOptions(
                                                                              height: 24.0,
                                                                              padding: EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                                                                              iconAlignment: IconAlignment.end,
                                                                              iconPadding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                                                                              iconColor: FlutterFlowTheme.of(context).white,
                                                                              color: FlutterFlowTheme.of(context).primary,
                                                                              textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                                                                                    font: GoogleFonts.interTight(
                                                                                      fontWeight: FlutterFlowTheme.of(context).titleSmall.fontWeight,
                                                                                      fontStyle: FlutterFlowTheme.of(context).titleSmall.fontStyle,
                                                                                    ),
                                                                                    color: Colors.white,
                                                                                    fontSize: 12.0,
                                                                                    letterSpacing: 0.0,
                                                                                    fontWeight: FlutterFlowTheme.of(context).titleSmall.fontWeight,
                                                                                    fontStyle: FlutterFlowTheme.of(context).titleSmall.fontStyle,
                                                                                  ),
                                                                              elevation: 0.0,
                                                                              borderRadius: BorderRadius.circular(24.0),
                                                                            ),
                                                                            showLoadingIndicator:
                                                                                false,
                                                                          ),
                                                                        ),
                                                                        Expanded(
                                                                          child:
                                                                              FFButtonWidget(
                                                                            onPressed:
                                                                                () async {
                                                                              await showModalBottomSheet(
                                                                                isScrollControlled: true,
                                                                                backgroundColor: Colors.transparent,
                                                                                context: context,
                                                                                builder: (context) {
                                                                                  return GestureDetector(
                                                                                    onTap: () {
                                                                                      FocusScope.of(context).unfocus();
                                                                                      FocusManager.instance.primaryFocus?.unfocus();
                                                                                    },
                                                                                    child: Padding(
                                                                                      padding: MediaQuery.viewInsetsOf(context),
                                                                                      child: CompShareWidget(
                                                                                        pagename: 'business',
                                                                                        id: getJsonField(
                                                                                          businessItem,
                                                                                          r'''$.id''',
                                                                                        ).toString(),
                                                                                      ),
                                                                                    ),
                                                                                  );
                                                                                },
                                                                              ).then((value) => safeSetState(() {}));
                                                                            },
                                                                            text:
                                                                                'Share',
                                                                            options:
                                                                                FFButtonOptions(
                                                                              height: 24.0,
                                                                              padding: EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                                                                              iconAlignment: IconAlignment.end,
                                                                              iconPadding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                                                                              color: FlutterFlowTheme.of(context).greyL2,
                                                                              textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                                                                                    font: GoogleFonts.interTight(
                                                                                      fontWeight: FlutterFlowTheme.of(context).titleSmall.fontWeight,
                                                                                      fontStyle: FlutterFlowTheme.of(context).titleSmall.fontStyle,
                                                                                    ),
                                                                                    color: FlutterFlowTheme.of(context).greyD1,
                                                                                    fontSize: 12.0,
                                                                                    letterSpacing: 0.0,
                                                                                    fontWeight: FlutterFlowTheme.of(context).titleSmall.fontWeight,
                                                                                    fontStyle: FlutterFlowTheme.of(context).titleSmall.fontStyle,
                                                                                  ),
                                                                              elevation: 0.0,
                                                                              borderRadius: BorderRadius.circular(24.0),
                                                                            ),
                                                                            showLoadingIndicator:
                                                                                false,
                                                                          ),
                                                                        ),
                                                                      ].divide(SizedBox(
                                                                              width: 10.0)),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ].divide(SizedBox(
                                                              width: 10.0)),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Divider(
                                                    height: 0.0,
                                                    thickness: 2.0,
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .alternate,
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                        },
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                wrapWithModel(
                  model: _model.compNavbarModel,
                  updateCallback: () => safeSetState(() {}),
                  child: CompNavbarWidget(
                    pagename: 'community',
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
