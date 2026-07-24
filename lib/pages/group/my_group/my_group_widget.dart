import '/pages/group/group_list_refresh.dart';
import '/components/app_network_image.dart';
import '/auth/supabase_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/backend/supabase/supabase.dart';
import '/components/comp_no_data_found_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/pages/group/comp_no_groups_available/comp_no_groups_available_widget.dart';
import 'dart:ui';
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'my_group_model.dart';
export 'my_group_model.dart';

class MyGroupWidget extends StatefulWidget {
  const MyGroupWidget({
    super.key,
    required this.initialButton,
  });

  final String? initialButton;

  static String routeName = 'MyGroup';
  static String routePath = 'myGroup';

  @override
  State<MyGroupWidget> createState() => _MyGroupWidgetState();
}

class _MyGroupWidgetState extends State<MyGroupWidget> {
  late MyGroupModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => MyGroupModel());

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      _model.currentBtn = widget!.initialButton;
      safeSetState(() {});
      if (widget!.initialButton == 'all') {
        if ('${valueOrDefault<String>(
              getJsonField(
                FFAppState().AsGroupList,
                r'''$[0].total_count_all''',
              )?.toString(),
              '0',
            )}' ==
            '0') {
          _model.showListView = false;
          safeSetState(() {});
          _model.noDataComponentName = 'nogroup';
          safeSetState(() {});
        } else {
          _model.showListView = true;
          safeSetState(() {});
          _model.noDataComponentName = 'none';
          safeSetState(() {});
        }
      } else {
        if ('${valueOrDefault<String>(
              getJsonField(
                FFAppState().AsGroupList,
                r'''$[0].total_invite''',
              )?.toString(),
              '0',
            )}' ==
            '0') {
          _model.showListView = false;
          safeSetState(() {});
          _model.noDataComponentName = 'noinvitaion';
          safeSetState(() {});
        } else {
          _model.showListView = true;
          safeSetState(() {});
          _model.noDataComponentName = 'none';
          safeSetState(() {});
        }
      }
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
          bottom: true,
          child: Container(
            decoration: BoxDecoration(
              color: FlutterFlowTheme.of(context).pageBack,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Container(
                  width: double.infinity,
                  height: 56.0,
                  decoration: BoxDecoration(
                    color: FlutterFlowTheme.of(context).secondaryBackground,
                  ),
                  child: Padding(
                    padding:
                        EdgeInsetsDirectional.fromSTEB(10.0, 0.0, 20.0, 0.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Semantics(
                              button: true,
                              label: 'Back',
                              child: FlutterFlowIconButton(
                                borderRadius: 100.0,
                                icon: Icon(
                                  Icons.arrow_back,
                                  color:
                                      FlutterFlowTheme.of(context).extraBlack,
                                  size: 24.0,
                                ),
                                onPressed: () async {
                                  context.safePop();
                                },
                              ),
                            ),
                            Text(
                              'My Group',
                              style: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                    font: GoogleFonts.manrope(
                                      fontWeight: FontWeight.w600,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontStyle,
                                    ),
                                    color:
                                        FlutterFlowTheme.of(context).extraBlack,
                                    fontSize: 18.0,
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.w600,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontStyle,
                                    lineHeight: 1.4,
                                  ),
                            ),
                          ].divide(SizedBox(width: 10.0)),
                        ),
                        Container(
                          width: 82.0,
                          height: 32.0,
                          decoration: BoxDecoration(
                            color: FlutterFlowTheme.of(context).primary,
                            borderRadius: BorderRadius.circular(24.0),
                          ),
                          child: InkWell(
                            splashColor: FlutterFlowTheme.of(context)
                                .primary
                                .withAlpha(0x14),
                            focusColor: Colors.transparent,
                            hoverColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            onTap: () async {
                              context.pushNamed(CreateGroupWidget.routeName);
                            },
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add,
                                  color: Colors.white,
                                  size: 16.0,
                                ),
                                Text(
                                  'New',
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        font: GoogleFonts.manrope(
                                          fontWeight: FontWeight.w600,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .bodyMedium
                                                  .fontStyle,
                                        ),
                                        color: Colors.white,
                                        fontSize: 12.0,
                                        letterSpacing: 0.0,
                                        fontWeight: FontWeight.w600,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .fontStyle,
                                        lineHeight: 1.4,
                                      ),
                                ),
                              ].divide(SizedBox(width: 4.0)),
                            ),
                          ),
                        ),
                      ],
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
                        InkWell(
                          splashColor: FlutterFlowTheme.of(context)
                              .primary
                              .withAlpha(0x14),
                          focusColor: Colors.transparent,
                          hoverColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          onTap: () async {
                            _model.currentBtn = 'all';
                            safeSetState(() {});
                            if (('${valueOrDefault<String>(
                                      getJsonField(
                                        FFAppState().AsGroupList,
                                        r'''$[0].total_count_joined''',
                                      )?.toString(),
                                      '0',
                                    )}' ==
                                    '0') &&
                                ('${valueOrDefault<String>(
                                      getJsonField(
                                        FFAppState().AsGroupList,
                                        r'''$[0].total_invite''',
                                      )?.toString(),
                                      '0',
                                    )}' ==
                                    '0') &&
                                ('${valueOrDefault<String>(
                                      getJsonField(
                                        FFAppState().AsGroupList,
                                        r'''$[0].total_requested''',
                                      )?.toString(),
                                      '0',
                                    )}' ==
                                    '0') &&
                                ('${valueOrDefault<String>(
                                      getJsonField(
                                        FFAppState().AsGroupList,
                                        r'''$[0].total_admin''',
                                      )?.toString(),
                                      '0',
                                    )}' ==
                                    '0')) {
                              _model.showListView = false;
                              safeSetState(() {});
                              _model.noDataComponentName = 'nogroup';
                              safeSetState(() {});
                            } else {
                              _model.showListView = true;
                              safeSetState(() {});
                              _model.noDataComponentName = 'none';
                              safeSetState(() {});
                            }
                          },
                          child: Container(
                            height: 28.0,
                            decoration: BoxDecoration(
                              color: _model.currentBtn == 'all'
                                  ? FlutterFlowTheme.of(context).primary
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(24.0),
                              border: Border.all(
                                color: _model.currentBtn != 'all'
                                    ? FlutterFlowTheme.of(context).greyL4
                                    : Colors.transparent,
                              ),
                            ),
                            child: Align(
                              alignment: AlignmentDirectional(0.0, 0.0),
                              child: Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    16.0, 0.0, 16.0, 0.0),
                                child: Text(
                                  'All',
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        font: GoogleFonts.manrope(
                                          fontWeight: FontWeight.w600,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .bodyMedium
                                                  .fontStyle,
                                        ),
                                        color: _model.currentBtn == 'all'
                                            ? Colors.white
                                            : FlutterFlowTheme.of(context)
                                                .greyL4,
                                        fontSize: 12.0,
                                        letterSpacing: 0.0,
                                        fontWeight: FontWeight.w600,
                                        fontStyle: FlutterFlowTheme.of(context)
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
                          splashColor: FlutterFlowTheme.of(context)
                              .primary
                              .withAlpha(0x14),
                          focusColor: Colors.transparent,
                          hoverColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          onTap: () async {
                            _model.currentBtn = 'joined';
                            safeSetState(() {});
                            if ('${valueOrDefault<String>(
                                  getJsonField(
                                    FFAppState().AsGroupList,
                                    r'''$[0].total_count_joined''',
                                  )?.toString(),
                                  '0',
                                )}' ==
                                '0') {
                              _model.showListView = false;
                              safeSetState(() {});
                              _model.noDataComponentName = 'nogroup';
                              safeSetState(() {});
                            } else {
                              _model.showListView = true;
                              safeSetState(() {});
                              _model.noDataComponentName = 'none';
                              safeSetState(() {});
                            }
                          },
                          child: Container(
                            height: 28.0,
                            decoration: BoxDecoration(
                              color: _model.currentBtn == 'joined'
                                  ? FlutterFlowTheme.of(context).primary
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(24.0),
                              border: Border.all(
                                color: _model.currentBtn != 'joined'
                                    ? FlutterFlowTheme.of(context).greyL4
                                    : Colors.transparent,
                              ),
                            ),
                            child: Align(
                              alignment: AlignmentDirectional(0.0, 0.0),
                              child: Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    16.0, 0.0, 16.0, 0.0),
                                child: Text(
                                  'Joined',
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        font: GoogleFonts.manrope(
                                          fontWeight: FontWeight.w600,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .bodyMedium
                                                  .fontStyle,
                                        ),
                                        color: _model.currentBtn == 'joined'
                                            ? Colors.white
                                            : FlutterFlowTheme.of(context)
                                                .greyL4,
                                        fontSize: 12.0,
                                        letterSpacing: 0.0,
                                        fontWeight: FontWeight.w600,
                                        fontStyle: FlutterFlowTheme.of(context)
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
                          splashColor: FlutterFlowTheme.of(context)
                              .primary
                              .withAlpha(0x14),
                          focusColor: Colors.transparent,
                          hoverColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          onTap: () async {
                            _model.currentBtn = 'invitations';
                            safeSetState(() {});
                            if ('${valueOrDefault<String>(
                                  getJsonField(
                                    FFAppState().AsGroupList,
                                    r'''$[0].total_invite''',
                                  )?.toString(),
                                  '0',
                                )}' ==
                                '0') {
                              _model.showListView = false;
                              safeSetState(() {});
                              _model.noDataComponentName = 'noinvitation';
                              safeSetState(() {});
                            } else {
                              _model.showListView = true;
                              safeSetState(() {});
                              _model.noDataComponentName = 'none';
                              safeSetState(() {});
                            }
                          },
                          child: Container(
                            height: 28.0,
                            decoration: BoxDecoration(
                              color: _model.currentBtn == 'invitations'
                                  ? FlutterFlowTheme.of(context).primary
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(24.0),
                              border: Border.all(
                                color: _model.currentBtn != 'invitations'
                                    ? FlutterFlowTheme.of(context).greyL4
                                    : Colors.transparent,
                              ),
                            ),
                            child: Align(
                              alignment: AlignmentDirectional(0.0, 0.0),
                              child: Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    16.0, 0.0, 16.0, 0.0),
                                child: Text(
                                  'Invitations  (${valueOrDefault<String>(
                                    getJsonField(
                                      FFAppState().AsGroupList,
                                      r'''$[0].total_invited''',
                                    )?.toString(),
                                    '0',
                                  )})',
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        font: GoogleFonts.manrope(
                                          fontWeight: FontWeight.w600,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .bodyMedium
                                                  .fontStyle,
                                        ),
                                        color:
                                            _model.currentBtn == 'invitations'
                                                ? Colors.white
                                                : FlutterFlowTheme.of(context)
                                                    .greyL4,
                                        fontSize: 12.0,
                                        letterSpacing: 0.0,
                                        fontWeight: FontWeight.w600,
                                        fontStyle: FlutterFlowTheme.of(context)
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
                          splashColor: FlutterFlowTheme.of(context)
                              .primary
                              .withAlpha(0x14),
                          focusColor: Colors.transparent,
                          hoverColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          onTap: () async {
                            _model.currentBtn = 'created';
                            safeSetState(() {});
                            if ('${valueOrDefault<String>(
                                  getJsonField(
                                    FFAppState().AsGroupList,
                                    r'''$[0].total_admin''',
                                  )?.toString(),
                                  '0',
                                )}' ==
                                '0') {
                              _model.showListView = false;
                              safeSetState(() {});
                              _model.noDataComponentName = 'nogroup';
                              safeSetState(() {});
                            } else {
                              _model.showListView = true;
                              safeSetState(() {});
                              _model.noDataComponentName = 'none';
                              safeSetState(() {});
                            }
                          },
                          child: Container(
                            height: 28.0,
                            decoration: BoxDecoration(
                              color: _model.currentBtn == 'created'
                                  ? FlutterFlowTheme.of(context).primary
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(24.0),
                              border: Border.all(
                                color: _model.currentBtn != 'created'
                                    ? FlutterFlowTheme.of(context).greyL4
                                    : Colors.transparent,
                              ),
                            ),
                            child: Align(
                              alignment: AlignmentDirectional(0.0, 0.0),
                              child: Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    16.0, 0.0, 16.0, 0.0),
                                child: Text(
                                  'Created  (${valueOrDefault<String>(
                                    getJsonField(
                                      FFAppState().AsGroupList,
                                      r'''$[0].total_admin''',
                                    )?.toString(),
                                    '0',
                                  )})',
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        font: GoogleFonts.manrope(
                                          fontWeight: FontWeight.w600,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .bodyMedium
                                                  .fontStyle,
                                        ),
                                        color: _model.currentBtn == 'created'
                                            ? Colors.white
                                            : FlutterFlowTheme.of(context)
                                                .greyL4,
                                        fontSize: 12.0,
                                        letterSpacing: 0.0,
                                        fontWeight: FontWeight.w600,
                                        fontStyle: FlutterFlowTheme.of(context)
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
                          splashColor: FlutterFlowTheme.of(context)
                              .primary
                              .withAlpha(0x14),
                          focusColor: Colors.transparent,
                          hoverColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          onTap: () async {
                            _model.currentBtn = 'requested';
                            safeSetState(() {});
                            if ('${valueOrDefault<String>(
                                  getJsonField(
                                    FFAppState().AsGroupList,
                                    r'''$[0].total_requested''',
                                  )?.toString(),
                                  '0',
                                )}' ==
                                '0') {
                              _model.showListView = false;
                              safeSetState(() {});
                              _model.noDataComponentName = 'nogroup';
                              safeSetState(() {});
                            } else {
                              _model.showListView = true;
                              safeSetState(() {});
                              _model.noDataComponentName = 'none';
                              safeSetState(() {});
                            }
                          },
                          child: Container(
                            height: 28.0,
                            decoration: BoxDecoration(
                              color: _model.currentBtn == 'requested'
                                  ? FlutterFlowTheme.of(context).primary
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(24.0),
                              border: Border.all(
                                color: _model.currentBtn != 'requested'
                                    ? FlutterFlowTheme.of(context).greyL4
                                    : Colors.transparent,
                              ),
                            ),
                            child: Align(
                              alignment: AlignmentDirectional(0.0, 0.0),
                              child: Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    16.0, 0.0, 16.0, 0.0),
                                child: Text(
                                  'Requested  (${valueOrDefault<String>(
                                    getJsonField(
                                      FFAppState().AsGroupList,
                                      r'''$[0].total_requested''',
                                    )?.toString(),
                                    '0',
                                  )})',
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        font: GoogleFonts.manrope(
                                          fontWeight: FontWeight.w600,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .bodyMedium
                                                  .fontStyle,
                                        ),
                                        color: _model.currentBtn == 'requested'
                                            ? Colors.white
                                            : FlutterFlowTheme.of(context)
                                                .greyL4,
                                        fontSize: 12.0,
                                        letterSpacing: 0.0,
                                        fontWeight: FontWeight.w600,
                                        fontStyle: FlutterFlowTheme.of(context)
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
                Expanded(
                  child: Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(0.0, 4.0, 0.0, 0.0),
                    child: RefreshIndicator(
                      onRefresh: () => handleGroupListRefresh(context),
                      color: FlutterFlowTheme.of(context).primary,
                      backgroundColor:
                          FlutterFlowTheme.of(context).secondaryBackground,
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color:
                              FlutterFlowTheme.of(context).secondaryBackground,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (_model.noDataComponentName == 'noinvitation')
                              Expanded(
                                child: wrapWithModel(
                                  model: _model.compNoDataFoundModel1,
                                  updateCallback: () => safeSetState(() {}),
                                  child: CompNoDataFoundWidget(
                                    pageName: 'invitation',
                                    text1: 'No invitations',
                                    text2:
                                        'When someone invites you to a group, it’ll show up here.',
                                  ),
                                ),
                              ),
                            if (_model.noDataComponentName == 'nogroup')
                              Expanded(
                                child: wrapWithModel(
                                  model: _model.compNoDataFoundModel2,
                                  updateCallback: () => safeSetState(() {}),
                                  child: CompNoDataFoundWidget(
                                    pageName: 'group',
                                    text1: 'No groups to show',
                                    text2:
                                        'Groups will appear here once they\'re created, invited or joined by you.',
                                  ),
                                ),
                              ),
                            if (('${getJsonField(
                                      FFAppState().AsGroupList,
                                      r'''$''',
                                    ).toString()}' !=
                                    '[]') &&
                                _model.showListView &&
                                (_model.currentBtn == 'all'))
                              Expanded(
                                child: Align(
                                  alignment: AlignmentDirectional(0.0, -1.0),
                                  child: Builder(
                                    builder: (context) {
                                      final grops = getJsonField(
                                        FFAppState().AsGroupList,
                                        r'''$''',
                                      ).toList();
                                      if (grops.isEmpty) {
                                        return CompNoGroupsAvailableWidget();
                                      }

                                      return ListView.builder(
                                        physics:
                                            const AlwaysScrollableScrollPhysics(),
                                        padding: EdgeInsets.fromLTRB(
                                          0,
                                          12.0,
                                          0,
                                          12.0,
                                        ),
                                        shrinkWrap: true,
                                        scrollDirection: Axis.vertical,
                                        itemCount: grops.length,
                                        itemBuilder: (context, gropsIndex) {
                                          final gropsItem = grops[gropsIndex];
                                          return Visibility(
                                            visible: ('${getJsonField(
                                                      gropsItem,
                                                      r'''$.user_status''',
                                                    ).toString()}' ==
                                                    'joined') ||
                                                ('${getJsonField(
                                                      gropsItem,
                                                      r'''$.user_status''',
                                                    ).toString()}' ==
                                                    'admin') ||
                                                ('${getJsonField(
                                                      gropsItem,
                                                      r'''$.user_status''',
                                                    ).toString()}' ==
                                                    'requested') ||
                                                ('${getJsonField(
                                                      gropsItem,
                                                      r'''$.user_status''',
                                                    ).toString()}' ==
                                                    'invite'),
                                            child: Padding(
                                              padding: EdgeInsetsDirectional
                                                  .fromSTEB(
                                                      0.0, 0.0, 0.0, 12.0),
                                              child: Semantics(
                                                button: true,
                                                label: 'Open group',
                                                child: InkWell(
                                                  splashColor:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .primary
                                                          .withAlpha(0x14),
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
                                                    constraints: BoxConstraints(
                                                        minHeight: 56.0),
                                                    decoration: BoxDecoration(
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
                                                            MainAxisSize.max,
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
                                                                AppNetworkImage(
                                                                  url: getJsonField(
                                                                          gropsItem,
                                                                          r'''$.profile_picture''')
                                                                      .toString(),
                                                                  width: 40.0,
                                                                  height: 40.0,
                                                                  fit: BoxFit
                                                                      .cover,
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              2.0),
                                                                  semanticLabel:
                                                                      'Group cover photo',
                                                                ),
                                                                Expanded(
                                                                  child: Column(
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .max,
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      if ('${getJsonField(
                                                                            gropsItem,
                                                                            r'''$.invited_by_user_id''',
                                                                          ).toString()}' !=
                                                                          'null')
                                                                        Row(
                                                                          mainAxisSize:
                                                                              MainAxisSize.max,
                                                                          children:
                                                                              [
                                                                            AppNetworkImage(
                                                                              url: getJsonField(gropsItem, r'''$.invited_by_profile_picture''').toString(),
                                                                              width: 12.0,
                                                                              height: 12.0,
                                                                              fit: BoxFit.cover,
                                                                              isAvatar: true,
                                                                              semanticLabel: 'Inviter profile photo',
                                                                            ),
                                                                            Expanded(
                                                                              child: Text(
                                                                                '${getJsonField(
                                                                                  gropsItem,
                                                                                  r'''$.invited_by_name''',
                                                                                ).toString()} invited you to join this group',
                                                                                maxLines: 1,
                                                                                style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                      font: GoogleFonts.manrope(
                                                                                        fontWeight: FontWeight.w500,
                                                                                        fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                      ),
                                                                                      color: FlutterFlowTheme.of(context).greyL4,
                                                                                      fontSize: 12.0,
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
                                                                        style: FlutterFlowTheme.of(context)
                                                                            .bodyMedium
                                                                            .override(
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
                                                                            r'''$.invited_by_user_id''',
                                                                          ).toString()}' ==
                                                                          'null')
                                                                        Text(
                                                                          '${getJsonField(
                                                                            gropsItem,
                                                                            r'''$.total_members''',
                                                                          ).toString()} ${'${getJsonField(
                                                                                gropsItem,
                                                                                r'''$.total_members''',
                                                                              ).toString()}' == '1' ? 'member' : 'members'}',
                                                                          style: FlutterFlowTheme.of(context)
                                                                              .bodyMedium
                                                                              .override(
                                                                                font: GoogleFonts.manrope(
                                                                                  fontWeight: FontWeight.w500,
                                                                                  fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                ),
                                                                                color: FlutterFlowTheme.of(context).greyL4,
                                                                                fontSize: 12.0,
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
                                                                  width: 8.0)),
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
                                                                    HapticFeedback
                                                                        .lightImpact();
                                                                    await GroupMembersTable()
                                                                        .insert({
                                                                      'community_id':
                                                                          FFAppState()
                                                                              .communityId,
                                                                      'user_id':
                                                                          currentUserUid,
                                                                      'group_id':
                                                                          getJsonField(
                                                                        gropsItem,
                                                                        r'''$.group_id''',
                                                                      ).toString(),
                                                                      'is_requested':
                                                                          false,
                                                                      'requested_date': supaSerialize<
                                                                              DateTime>(
                                                                          functions
                                                                              .getCurrentUtcTime()),
                                                                      'is_approved':
                                                                          true,
                                                                      'approved_by':
                                                                          currentUserUid,
                                                                      'joined_at': supaSerialize<
                                                                              DateTime>(
                                                                          functions
                                                                              .getCurrentUtcTime()),
                                                                    });
                                                                    await GroupUserStatusTable()
                                                                        .insert({
                                                                      'community_id':
                                                                          FFAppState()
                                                                              .communityId,
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
                                                                      'joined_at': supaSerialize<
                                                                              DateTime>(
                                                                          functions
                                                                              .getCurrentUtcTime()),
                                                                    });
                                                                    _model.apiResultd2pnmb =
                                                                        await UpdateTotalGroupMembersCall
                                                                            .call(
                                                                      token:
                                                                          currentJwtToken,
                                                                      anonKey:
                                                                          FFDevEnvironmentValues()
                                                                              .AnonKey,
                                                                      groupId:
                                                                          getJsonField(
                                                                        gropsItem,
                                                                        r'''$.group_id''',
                                                                      ).toString(),
                                                                    );

                                                                    safeSetState(
                                                                        () {});
                                                                  },
                                                                  text: 'Join',
                                                                  options:
                                                                      FFButtonOptions(
                                                                    height:
                                                                        24.0,
                                                                    padding: EdgeInsetsDirectional
                                                                        .fromSTEB(
                                                                            16.0,
                                                                            0.0,
                                                                            16.0,
                                                                            0.0),
                                                                    iconPadding:
                                                                        EdgeInsetsDirectional.fromSTEB(
                                                                            0.0,
                                                                            0.0,
                                                                            0.0,
                                                                            0.0),
                                                                    color: Colors
                                                                        .transparent,
                                                                    textStyle: FlutterFlowTheme.of(
                                                                            context)
                                                                        .titleSmall
                                                                        .override(
                                                                          font:
                                                                              GoogleFonts.manrope(
                                                                            fontWeight:
                                                                                FlutterFlowTheme.of(context).titleSmall.fontWeight,
                                                                            fontStyle:
                                                                                FlutterFlowTheme.of(context).titleSmall.fontStyle,
                                                                          ),
                                                                          color:
                                                                              FlutterFlowTheme.of(context).primaryD3,
                                                                          fontSize:
                                                                              12.0,
                                                                          letterSpacing:
                                                                              0.0,
                                                                          fontWeight: FlutterFlowTheme.of(context)
                                                                              .titleSmall
                                                                              .fontWeight,
                                                                          fontStyle: FlutterFlowTheme.of(context)
                                                                              .titleSmall
                                                                              .fontStyle,
                                                                        ),
                                                                    elevation:
                                                                        0.0,
                                                                    borderSide:
                                                                        BorderSide(
                                                                      color: FlutterFlowTheme.of(
                                                                              context)
                                                                          .primaryD3,
                                                                      width:
                                                                          1.0,
                                                                    ),
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .only(
                                                                      topLeft: Radius
                                                                          .circular(
                                                                              100.0),
                                                                      topRight:
                                                                          Radius.circular(
                                                                              100.0),
                                                                      bottomLeft:
                                                                          Radius.circular(
                                                                              100.0),
                                                                      bottomRight:
                                                                          Radius.circular(
                                                                              100.0),
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
                                                                      () {},
                                                                  text:
                                                                      'Joined',
                                                                  icon: Icon(
                                                                    Icons
                                                                        .done_all,
                                                                    size: 15.0,
                                                                  ),
                                                                  options:
                                                                      FFButtonOptions(
                                                                    height:
                                                                        24.0,
                                                                    padding: EdgeInsetsDirectional
                                                                        .fromSTEB(
                                                                            16.0,
                                                                            0.0,
                                                                            16.0,
                                                                            0.0),
                                                                    iconPadding:
                                                                        EdgeInsetsDirectional.fromSTEB(
                                                                            0.0,
                                                                            0.0,
                                                                            0.0,
                                                                            0.0),
                                                                    iconColor: FlutterFlowTheme.of(
                                                                            context)
                                                                        .greyL4,
                                                                    color: Colors
                                                                        .transparent,
                                                                    textStyle: FlutterFlowTheme.of(
                                                                            context)
                                                                        .titleSmall
                                                                        .override(
                                                                          font:
                                                                              GoogleFonts.manrope(
                                                                            fontWeight:
                                                                                FlutterFlowTheme.of(context).titleSmall.fontWeight,
                                                                            fontStyle:
                                                                                FlutterFlowTheme.of(context).titleSmall.fontStyle,
                                                                          ),
                                                                          color:
                                                                              FlutterFlowTheme.of(context).greyL4,
                                                                          fontSize:
                                                                              12.0,
                                                                          letterSpacing:
                                                                              0.0,
                                                                          fontWeight: FlutterFlowTheme.of(context)
                                                                              .titleSmall
                                                                              .fontWeight,
                                                                          fontStyle: FlutterFlowTheme.of(context)
                                                                              .titleSmall
                                                                              .fontStyle,
                                                                        ),
                                                                    elevation:
                                                                        0.0,
                                                                    borderSide:
                                                                        BorderSide(
                                                                      color: FlutterFlowTheme.of(
                                                                              context)
                                                                          .greyL4,
                                                                      width:
                                                                          1.0,
                                                                    ),
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .only(
                                                                      topLeft: Radius
                                                                          .circular(
                                                                              100.0),
                                                                      topRight:
                                                                          Radius.circular(
                                                                              100.0),
                                                                      bottomLeft:
                                                                          Radius.circular(
                                                                              100.0),
                                                                      bottomRight:
                                                                          Radius.circular(
                                                                              100.0),
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
                                                                    HapticFeedback
                                                                        .lightImpact();
                                                                  },
                                                                  text:
                                                                      'Requested',
                                                                  options:
                                                                      FFButtonOptions(
                                                                    height:
                                                                        24.0,
                                                                    padding: EdgeInsetsDirectional
                                                                        .fromSTEB(
                                                                            16.0,
                                                                            0.0,
                                                                            16.0,
                                                                            0.0),
                                                                    iconPadding:
                                                                        EdgeInsetsDirectional.fromSTEB(
                                                                            0.0,
                                                                            0.0,
                                                                            0.0,
                                                                            0.0),
                                                                    color: FlutterFlowTheme.of(
                                                                            context)
                                                                        .greyL2,
                                                                    textStyle: FlutterFlowTheme.of(
                                                                            context)
                                                                        .titleSmall
                                                                        .override(
                                                                          font:
                                                                              GoogleFonts.manrope(
                                                                            fontWeight:
                                                                                FlutterFlowTheme.of(context).titleSmall.fontWeight,
                                                                            fontStyle:
                                                                                FlutterFlowTheme.of(context).titleSmall.fontStyle,
                                                                          ),
                                                                          color:
                                                                              FlutterFlowTheme.of(context).greyL3,
                                                                          fontSize:
                                                                              12.0,
                                                                          letterSpacing:
                                                                              0.0,
                                                                          fontWeight: FlutterFlowTheme.of(context)
                                                                              .titleSmall
                                                                              .fontWeight,
                                                                          fontStyle: FlutterFlowTheme.of(context)
                                                                              .titleSmall
                                                                              .fontStyle,
                                                                        ),
                                                                    elevation:
                                                                        0.0,
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .only(
                                                                      topLeft: Radius
                                                                          .circular(
                                                                              100.0),
                                                                      topRight:
                                                                          Radius.circular(
                                                                              100.0),
                                                                      bottomLeft:
                                                                          Radius.circular(
                                                                              100.0),
                                                                      bottomRight:
                                                                          Radius.circular(
                                                                              100.0),
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
                                                                          FFAppState()
                                                                              .communityId,
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
                                                                      'requested_date': supaSerialize<
                                                                              DateTime>(
                                                                          functions
                                                                              .getCurrentUtcTime()),
                                                                    });
                                                                  },
                                                                  text:
                                                                      'Request',
                                                                  icon: Icon(
                                                                    Icons
                                                                        .lock_outline_sharp,
                                                                    size: 15.0,
                                                                  ),
                                                                  options:
                                                                      FFButtonOptions(
                                                                    height:
                                                                        24.0,
                                                                    padding: EdgeInsetsDirectional
                                                                        .fromSTEB(
                                                                            16.0,
                                                                            0.0,
                                                                            16.0,
                                                                            0.0),
                                                                    iconPadding:
                                                                        EdgeInsetsDirectional.fromSTEB(
                                                                            0.0,
                                                                            0.0,
                                                                            0.0,
                                                                            0.0),
                                                                    iconColor: FlutterFlowTheme.of(
                                                                            context)
                                                                        .primaryD3,
                                                                    color: Colors
                                                                        .transparent,
                                                                    textStyle: FlutterFlowTheme.of(
                                                                            context)
                                                                        .titleSmall
                                                                        .override(
                                                                          font:
                                                                              GoogleFonts.manrope(
                                                                            fontWeight:
                                                                                FlutterFlowTheme.of(context).titleSmall.fontWeight,
                                                                            fontStyle:
                                                                                FlutterFlowTheme.of(context).titleSmall.fontStyle,
                                                                          ),
                                                                          color:
                                                                              FlutterFlowTheme.of(context).primaryD3,
                                                                          fontSize:
                                                                              12.0,
                                                                          letterSpacing:
                                                                              0.0,
                                                                          fontWeight: FlutterFlowTheme.of(context)
                                                                              .titleSmall
                                                                              .fontWeight,
                                                                          fontStyle: FlutterFlowTheme.of(context)
                                                                              .titleSmall
                                                                              .fontStyle,
                                                                        ),
                                                                    elevation:
                                                                        0.0,
                                                                    borderSide:
                                                                        BorderSide(
                                                                      color: FlutterFlowTheme.of(
                                                                              context)
                                                                          .primaryD3,
                                                                      width:
                                                                          1.0,
                                                                    ),
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .only(
                                                                      topLeft: Radius
                                                                          .circular(
                                                                              100.0),
                                                                      topRight:
                                                                          Radius.circular(
                                                                              100.0),
                                                                      bottomLeft:
                                                                          Radius.circular(
                                                                              100.0),
                                                                      bottomRight:
                                                                          Radius.circular(
                                                                              100.0),
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
                                                                    HapticFeedback
                                                                        .lightImpact();
                                                                  },
                                                                  text: 'Admin',
                                                                  options:
                                                                      FFButtonOptions(
                                                                    height:
                                                                        24.0,
                                                                    padding: EdgeInsetsDirectional
                                                                        .fromSTEB(
                                                                            12.0,
                                                                            0.0,
                                                                            12.0,
                                                                            0.0),
                                                                    iconPadding:
                                                                        EdgeInsetsDirectional.fromSTEB(
                                                                            0.0,
                                                                            0.0,
                                                                            0.0,
                                                                            0.0),
                                                                    color: FlutterFlowTheme.of(
                                                                            context)
                                                                        .primary,
                                                                    textStyle: FlutterFlowTheme.of(
                                                                            context)
                                                                        .titleSmall
                                                                        .override(
                                                                          font:
                                                                              GoogleFonts.manrope(
                                                                            fontWeight:
                                                                                FlutterFlowTheme.of(context).titleSmall.fontWeight,
                                                                            fontStyle:
                                                                                FlutterFlowTheme.of(context).titleSmall.fontStyle,
                                                                          ),
                                                                          color:
                                                                              Colors.white,
                                                                          fontSize:
                                                                              12.0,
                                                                          letterSpacing:
                                                                              0.0,
                                                                          fontWeight: FlutterFlowTheme.of(context)
                                                                              .titleSmall
                                                                              .fontWeight,
                                                                          fontStyle: FlutterFlowTheme.of(context)
                                                                              .titleSmall
                                                                              .fontStyle,
                                                                        ),
                                                                    elevation:
                                                                        0.0,
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .only(
                                                                      topLeft: Radius
                                                                          .circular(
                                                                              100.0),
                                                                      topRight:
                                                                          Radius.circular(
                                                                              100.0),
                                                                      bottomLeft:
                                                                          Radius.circular(
                                                                              100.0),
                                                                      bottomRight:
                                                                          Radius.circular(
                                                                              100.0),
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
                                                                    HapticFeedback
                                                                        .lightImpact();
                                                                    await GroupMembersTable()
                                                                        .insert({
                                                                      'community_id':
                                                                          FFAppState()
                                                                              .communityId,
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
                                                                      'joined_at': supaSerialize<
                                                                              DateTime>(
                                                                          functions
                                                                              .getCurrentUtcTime()),
                                                                    });
                                                                    await GroupMembersInviteTable()
                                                                        .update(
                                                                      data: {
                                                                        'is_member':
                                                                            true,
                                                                        'accepted_at':
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
                                                                            'invited_user',
                                                                            currentUserUid,
                                                                          ),
                                                                    );
                                                                    await GroupUserStatusTable()
                                                                        .update(
                                                                      data: {
                                                                        'is_member':
                                                                            true,
                                                                        'joined_at':
                                                                            supaSerialize<DateTime>(functions.getCurrentUtcTime()),
                                                                        'is_requested':
                                                                            true,
                                                                        'is_approved':
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
                                                                            'user_id',
                                                                            currentUserUid,
                                                                          ),
                                                                    );
                                                                    _model.apiResultd2ppzxx =
                                                                        await UpdateTotalGroupMembersCall
                                                                            .call(
                                                                      token:
                                                                          currentJwtToken,
                                                                      anonKey:
                                                                          FFDevEnvironmentValues()
                                                                              .AnonKey,
                                                                      groupId:
                                                                          getJsonField(
                                                                        gropsItem,
                                                                        r'''$.group_id''',
                                                                      ).toString(),
                                                                    );

                                                                    safeSetState(
                                                                        () {});
                                                                  },
                                                                  text: 'Join',
                                                                  options:
                                                                      FFButtonOptions(
                                                                    height:
                                                                        24.0,
                                                                    padding: EdgeInsetsDirectional
                                                                        .fromSTEB(
                                                                            16.0,
                                                                            0.0,
                                                                            16.0,
                                                                            0.0),
                                                                    iconPadding:
                                                                        EdgeInsetsDirectional.fromSTEB(
                                                                            0.0,
                                                                            0.0,
                                                                            0.0,
                                                                            0.0),
                                                                    color: Colors
                                                                        .transparent,
                                                                    textStyle: FlutterFlowTheme.of(
                                                                            context)
                                                                        .titleSmall
                                                                        .override(
                                                                          font:
                                                                              GoogleFonts.manrope(
                                                                            fontWeight:
                                                                                FlutterFlowTheme.of(context).titleSmall.fontWeight,
                                                                            fontStyle:
                                                                                FlutterFlowTheme.of(context).titleSmall.fontStyle,
                                                                          ),
                                                                          color:
                                                                              FlutterFlowTheme.of(context).primaryD3,
                                                                          fontSize:
                                                                              12.0,
                                                                          letterSpacing:
                                                                              0.0,
                                                                          fontWeight: FlutterFlowTheme.of(context)
                                                                              .titleSmall
                                                                              .fontWeight,
                                                                          fontStyle: FlutterFlowTheme.of(context)
                                                                              .titleSmall
                                                                              .fontStyle,
                                                                        ),
                                                                    elevation:
                                                                        0.0,
                                                                    borderSide:
                                                                        BorderSide(
                                                                      color: FlutterFlowTheme.of(
                                                                              context)
                                                                          .primaryD3,
                                                                      width:
                                                                          1.0,
                                                                    ),
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .only(
                                                                      topLeft: Radius
                                                                          .circular(
                                                                              100.0),
                                                                      topRight:
                                                                          Radius.circular(
                                                                              100.0),
                                                                      bottomLeft:
                                                                          Radius.circular(
                                                                              100.0),
                                                                      bottomRight:
                                                                          Radius.circular(
                                                                              100.0),
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
                                                                  icon: Icon(
                                                                    Icons
                                                                        .lock_outline_sharp,
                                                                    size: 15.0,
                                                                  ),
                                                                  options:
                                                                      FFButtonOptions(
                                                                    height:
                                                                        24.0,
                                                                    padding: EdgeInsetsDirectional
                                                                        .fromSTEB(
                                                                            16.0,
                                                                            0.0,
                                                                            16.0,
                                                                            0.0),
                                                                    iconPadding:
                                                                        EdgeInsetsDirectional.fromSTEB(
                                                                            0.0,
                                                                            0.0,
                                                                            0.0,
                                                                            0.0),
                                                                    iconColor: FlutterFlowTheme.of(
                                                                            context)
                                                                        .primaryD3,
                                                                    color: Colors
                                                                        .transparent,
                                                                    textStyle: FlutterFlowTheme.of(
                                                                            context)
                                                                        .titleSmall
                                                                        .override(
                                                                          font:
                                                                              GoogleFonts.manrope(
                                                                            fontWeight:
                                                                                FlutterFlowTheme.of(context).titleSmall.fontWeight,
                                                                            fontStyle:
                                                                                FlutterFlowTheme.of(context).titleSmall.fontStyle,
                                                                          ),
                                                                          color:
                                                                              FlutterFlowTheme.of(context).primaryD3,
                                                                          fontSize:
                                                                              12.0,
                                                                          letterSpacing:
                                                                              0.0,
                                                                          fontWeight: FlutterFlowTheme.of(context)
                                                                              .titleSmall
                                                                              .fontWeight,
                                                                          fontStyle: FlutterFlowTheme.of(context)
                                                                              .titleSmall
                                                                              .fontStyle,
                                                                        ),
                                                                    elevation:
                                                                        0.0,
                                                                    borderSide:
                                                                        BorderSide(
                                                                      color: FlutterFlowTheme.of(
                                                                              context)
                                                                          .primaryD3,
                                                                      width:
                                                                          1.0,
                                                                    ),
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .only(
                                                                      topLeft: Radius
                                                                          .circular(
                                                                              100.0),
                                                                      topRight:
                                                                          Radius.circular(
                                                                              100.0),
                                                                      bottomLeft:
                                                                          Radius.circular(
                                                                              100.0),
                                                                      bottomRight:
                                                                          Radius.circular(
                                                                              100.0),
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
                                              ),
                                            ),
                                          )
                                              .animate()
                                              .fadeIn(
                                                  duration: 260.ms,
                                                  delay: (40 * (gropsIndex % 8))
                                                      .ms)
                                              .slideY(
                                                  begin: 0.06,
                                                  end: 0,
                                                  curve: Curves.easeOutCubic);
                                        },
                                      );
                                    },
                                  ),
                                ),
                              ),
                            if (('${getJsonField(
                                      FFAppState().AsGroupList,
                                      r'''$''',
                                    ).toString()}' !=
                                    '[]') &&
                                _model.showListView &&
                                (_model.currentBtn == 'requested'))
                              Expanded(
                                child: Align(
                                  alignment: AlignmentDirectional(0.0, -1.0),
                                  child: Builder(
                                    builder: (context) {
                                      final grops = getJsonField(
                                        FFAppState().AsGroupList,
                                        r'''$''',
                                      ).toList();
                                      if (grops.isEmpty) {
                                        return CompNoGroupsAvailableWidget();
                                      }

                                      return ListView.builder(
                                        physics:
                                            const AlwaysScrollableScrollPhysics(),
                                        padding: EdgeInsets.fromLTRB(
                                          0,
                                          12.0,
                                          0,
                                          12.0,
                                        ),
                                        shrinkWrap: true,
                                        scrollDirection: Axis.vertical,
                                        itemCount: grops.length,
                                        itemBuilder: (context, gropsIndex) {
                                          final gropsItem = grops[gropsIndex];
                                          return Visibility(
                                            visible: ('${getJsonField(
                                                      gropsItem,
                                                      r'''$.user_status''',
                                                    ).toString()}' ==
                                                    'requested') &&
                                                (('${getJsonField(
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
                                                            'requested'))),
                                            child: Padding(
                                              padding: EdgeInsetsDirectional
                                                  .fromSTEB(
                                                      0.0, 0.0, 0.0, 12.0),
                                              child: Semantics(
                                                button: true,
                                                label: 'Open group',
                                                child: InkWell(
                                                  splashColor:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .primary
                                                          .withAlpha(0x14),
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
                                                    constraints: BoxConstraints(
                                                        minHeight: 56.0),
                                                    decoration: BoxDecoration(
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
                                                            MainAxisSize.max,
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
                                                                AppNetworkImage(
                                                                  url: getJsonField(
                                                                          gropsItem,
                                                                          r'''$.profile_picture''')
                                                                      .toString(),
                                                                  width: 40.0,
                                                                  height: 40.0,
                                                                  fit: BoxFit
                                                                      .cover,
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              2.0),
                                                                  semanticLabel:
                                                                      'Group cover photo',
                                                                ),
                                                                Expanded(
                                                                  child: Column(
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .max,
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      if ('${getJsonField(
                                                                            gropsItem,
                                                                            r'''$.invited_by_user_id''',
                                                                          ).toString()}' !=
                                                                          'null')
                                                                        Row(
                                                                          mainAxisSize:
                                                                              MainAxisSize.max,
                                                                          children:
                                                                              [
                                                                            AppNetworkImage(
                                                                              url: getJsonField(gropsItem, r'''$.invited_by_profile_picture''').toString(),
                                                                              width: 12.0,
                                                                              height: 12.0,
                                                                              fit: BoxFit.cover,
                                                                              isAvatar: true,
                                                                              semanticLabel: 'Inviter profile photo',
                                                                            ),
                                                                            Expanded(
                                                                              child: Text(
                                                                                '${getJsonField(
                                                                                  gropsItem,
                                                                                  r'''$.invited_by_name''',
                                                                                ).toString()} invited you to join this group',
                                                                                maxLines: 1,
                                                                                style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                      font: GoogleFonts.manrope(
                                                                                        fontWeight: FontWeight.w500,
                                                                                        fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                      ),
                                                                                      color: FlutterFlowTheme.of(context).greyL4,
                                                                                      fontSize: 12.0,
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
                                                                        style: FlutterFlowTheme.of(context)
                                                                            .bodyMedium
                                                                            .override(
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
                                                                            r'''$.invited_by_user_id''',
                                                                          ).toString()}' ==
                                                                          'null')
                                                                        Text(
                                                                          '${getJsonField(
                                                                            gropsItem,
                                                                            r'''$.total_members''',
                                                                          ).toString()} ${'${getJsonField(
                                                                                gropsItem,
                                                                                r'''$.total_members''',
                                                                              ).toString()}' == '1' ? 'member' : 'members'}',
                                                                          style: FlutterFlowTheme.of(context)
                                                                              .bodyMedium
                                                                              .override(
                                                                                font: GoogleFonts.manrope(
                                                                                  fontWeight: FontWeight.w500,
                                                                                  fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                ),
                                                                                color: FlutterFlowTheme.of(context).greyL4,
                                                                                fontSize: 12.0,
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
                                                                  width: 8.0)),
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
                                                                    HapticFeedback
                                                                        .lightImpact();
                                                                    await GroupMembersTable()
                                                                        .insert({
                                                                      'community_id':
                                                                          FFAppState()
                                                                              .communityId,
                                                                      'user_id':
                                                                          currentUserUid,
                                                                      'group_id':
                                                                          getJsonField(
                                                                        gropsItem,
                                                                        r'''$.group_id''',
                                                                      ).toString(),
                                                                      'is_requested':
                                                                          false,
                                                                      'requested_date': supaSerialize<
                                                                              DateTime>(
                                                                          functions
                                                                              .getCurrentUtcTime()),
                                                                      'is_approved':
                                                                          true,
                                                                      'approved_by':
                                                                          currentUserUid,
                                                                      'joined_at': supaSerialize<
                                                                              DateTime>(
                                                                          functions
                                                                              .getCurrentUtcTime()),
                                                                    });
                                                                    await GroupUserStatusTable()
                                                                        .insert({
                                                                      'community_id':
                                                                          FFAppState()
                                                                              .communityId,
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
                                                                      'joined_at': supaSerialize<
                                                                              DateTime>(
                                                                          functions
                                                                              .getCurrentUtcTime()),
                                                                    });
                                                                    _model.apiResultd2pq11 =
                                                                        await UpdateTotalGroupMembersCall
                                                                            .call(
                                                                      token:
                                                                          currentJwtToken,
                                                                      anonKey:
                                                                          FFDevEnvironmentValues()
                                                                              .AnonKey,
                                                                      groupId:
                                                                          getJsonField(
                                                                        gropsItem,
                                                                        r'''$.group_id''',
                                                                      ).toString(),
                                                                    );

                                                                    safeSetState(
                                                                        () {});
                                                                  },
                                                                  text: 'Join',
                                                                  options:
                                                                      FFButtonOptions(
                                                                    height:
                                                                        24.0,
                                                                    padding: EdgeInsetsDirectional
                                                                        .fromSTEB(
                                                                            16.0,
                                                                            0.0,
                                                                            16.0,
                                                                            0.0),
                                                                    iconPadding:
                                                                        EdgeInsetsDirectional.fromSTEB(
                                                                            0.0,
                                                                            0.0,
                                                                            0.0,
                                                                            0.0),
                                                                    color: Colors
                                                                        .transparent,
                                                                    textStyle: FlutterFlowTheme.of(
                                                                            context)
                                                                        .titleSmall
                                                                        .override(
                                                                          font:
                                                                              GoogleFonts.manrope(
                                                                            fontWeight:
                                                                                FlutterFlowTheme.of(context).titleSmall.fontWeight,
                                                                            fontStyle:
                                                                                FlutterFlowTheme.of(context).titleSmall.fontStyle,
                                                                          ),
                                                                          color:
                                                                              FlutterFlowTheme.of(context).primaryD3,
                                                                          fontSize:
                                                                              12.0,
                                                                          letterSpacing:
                                                                              0.0,
                                                                          fontWeight: FlutterFlowTheme.of(context)
                                                                              .titleSmall
                                                                              .fontWeight,
                                                                          fontStyle: FlutterFlowTheme.of(context)
                                                                              .titleSmall
                                                                              .fontStyle,
                                                                        ),
                                                                    elevation:
                                                                        0.0,
                                                                    borderSide:
                                                                        BorderSide(
                                                                      color: FlutterFlowTheme.of(
                                                                              context)
                                                                          .primaryD3,
                                                                      width:
                                                                          1.0,
                                                                    ),
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .only(
                                                                      topLeft: Radius
                                                                          .circular(
                                                                              100.0),
                                                                      topRight:
                                                                          Radius.circular(
                                                                              100.0),
                                                                      bottomLeft:
                                                                          Radius.circular(
                                                                              100.0),
                                                                      bottomRight:
                                                                          Radius.circular(
                                                                              100.0),
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
                                                                      () {},
                                                                  text:
                                                                      'Joined',
                                                                  icon: Icon(
                                                                    Icons
                                                                        .done_all,
                                                                    size: 15.0,
                                                                  ),
                                                                  options:
                                                                      FFButtonOptions(
                                                                    height:
                                                                        24.0,
                                                                    padding: EdgeInsetsDirectional
                                                                        .fromSTEB(
                                                                            16.0,
                                                                            0.0,
                                                                            16.0,
                                                                            0.0),
                                                                    iconPadding:
                                                                        EdgeInsetsDirectional.fromSTEB(
                                                                            0.0,
                                                                            0.0,
                                                                            0.0,
                                                                            0.0),
                                                                    iconColor: FlutterFlowTheme.of(
                                                                            context)
                                                                        .greyL4,
                                                                    color: Colors
                                                                        .transparent,
                                                                    textStyle: FlutterFlowTheme.of(
                                                                            context)
                                                                        .titleSmall
                                                                        .override(
                                                                          font:
                                                                              GoogleFonts.manrope(
                                                                            fontWeight:
                                                                                FlutterFlowTheme.of(context).titleSmall.fontWeight,
                                                                            fontStyle:
                                                                                FlutterFlowTheme.of(context).titleSmall.fontStyle,
                                                                          ),
                                                                          color:
                                                                              FlutterFlowTheme.of(context).greyL4,
                                                                          fontSize:
                                                                              12.0,
                                                                          letterSpacing:
                                                                              0.0,
                                                                          fontWeight: FlutterFlowTheme.of(context)
                                                                              .titleSmall
                                                                              .fontWeight,
                                                                          fontStyle: FlutterFlowTheme.of(context)
                                                                              .titleSmall
                                                                              .fontStyle,
                                                                        ),
                                                                    elevation:
                                                                        0.0,
                                                                    borderSide:
                                                                        BorderSide(
                                                                      color: FlutterFlowTheme.of(
                                                                              context)
                                                                          .greyL4,
                                                                      width:
                                                                          1.0,
                                                                    ),
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .only(
                                                                      topLeft: Radius
                                                                          .circular(
                                                                              100.0),
                                                                      topRight:
                                                                          Radius.circular(
                                                                              100.0),
                                                                      bottomLeft:
                                                                          Radius.circular(
                                                                              100.0),
                                                                      bottomRight:
                                                                          Radius.circular(
                                                                              100.0),
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
                                                                    HapticFeedback
                                                                        .lightImpact();
                                                                  },
                                                                  text:
                                                                      'Requested',
                                                                  options:
                                                                      FFButtonOptions(
                                                                    height:
                                                                        24.0,
                                                                    padding: EdgeInsetsDirectional
                                                                        .fromSTEB(
                                                                            16.0,
                                                                            0.0,
                                                                            16.0,
                                                                            0.0),
                                                                    iconPadding:
                                                                        EdgeInsetsDirectional.fromSTEB(
                                                                            0.0,
                                                                            0.0,
                                                                            0.0,
                                                                            0.0),
                                                                    color: FlutterFlowTheme.of(
                                                                            context)
                                                                        .greyL2,
                                                                    textStyle: FlutterFlowTheme.of(
                                                                            context)
                                                                        .titleSmall
                                                                        .override(
                                                                          font:
                                                                              GoogleFonts.manrope(
                                                                            fontWeight:
                                                                                FlutterFlowTheme.of(context).titleSmall.fontWeight,
                                                                            fontStyle:
                                                                                FlutterFlowTheme.of(context).titleSmall.fontStyle,
                                                                          ),
                                                                          color:
                                                                              FlutterFlowTheme.of(context).greyL3,
                                                                          fontSize:
                                                                              12.0,
                                                                          letterSpacing:
                                                                              0.0,
                                                                          fontWeight: FlutterFlowTheme.of(context)
                                                                              .titleSmall
                                                                              .fontWeight,
                                                                          fontStyle: FlutterFlowTheme.of(context)
                                                                              .titleSmall
                                                                              .fontStyle,
                                                                        ),
                                                                    elevation:
                                                                        0.0,
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .only(
                                                                      topLeft: Radius
                                                                          .circular(
                                                                              100.0),
                                                                      topRight:
                                                                          Radius.circular(
                                                                              100.0),
                                                                      bottomLeft:
                                                                          Radius.circular(
                                                                              100.0),
                                                                      bottomRight:
                                                                          Radius.circular(
                                                                              100.0),
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
                                                                          FFAppState()
                                                                              .communityId,
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
                                                                      'requested_date': supaSerialize<
                                                                              DateTime>(
                                                                          functions
                                                                              .getCurrentUtcTime()),
                                                                    });
                                                                  },
                                                                  text:
                                                                      'Request',
                                                                  icon: Icon(
                                                                    Icons
                                                                        .lock_outline_sharp,
                                                                    size: 15.0,
                                                                  ),
                                                                  options:
                                                                      FFButtonOptions(
                                                                    height:
                                                                        24.0,
                                                                    padding: EdgeInsetsDirectional
                                                                        .fromSTEB(
                                                                            16.0,
                                                                            0.0,
                                                                            16.0,
                                                                            0.0),
                                                                    iconPadding:
                                                                        EdgeInsetsDirectional.fromSTEB(
                                                                            0.0,
                                                                            0.0,
                                                                            0.0,
                                                                            0.0),
                                                                    iconColor: FlutterFlowTheme.of(
                                                                            context)
                                                                        .primaryD3,
                                                                    color: Colors
                                                                        .transparent,
                                                                    textStyle: FlutterFlowTheme.of(
                                                                            context)
                                                                        .titleSmall
                                                                        .override(
                                                                          font:
                                                                              GoogleFonts.manrope(
                                                                            fontWeight:
                                                                                FlutterFlowTheme.of(context).titleSmall.fontWeight,
                                                                            fontStyle:
                                                                                FlutterFlowTheme.of(context).titleSmall.fontStyle,
                                                                          ),
                                                                          color:
                                                                              FlutterFlowTheme.of(context).primaryD3,
                                                                          fontSize:
                                                                              12.0,
                                                                          letterSpacing:
                                                                              0.0,
                                                                          fontWeight: FlutterFlowTheme.of(context)
                                                                              .titleSmall
                                                                              .fontWeight,
                                                                          fontStyle: FlutterFlowTheme.of(context)
                                                                              .titleSmall
                                                                              .fontStyle,
                                                                        ),
                                                                    elevation:
                                                                        0.0,
                                                                    borderSide:
                                                                        BorderSide(
                                                                      color: FlutterFlowTheme.of(
                                                                              context)
                                                                          .primaryD3,
                                                                      width:
                                                                          1.0,
                                                                    ),
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .only(
                                                                      topLeft: Radius
                                                                          .circular(
                                                                              100.0),
                                                                      topRight:
                                                                          Radius.circular(
                                                                              100.0),
                                                                      bottomLeft:
                                                                          Radius.circular(
                                                                              100.0),
                                                                      bottomRight:
                                                                          Radius.circular(
                                                                              100.0),
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
                                                                    HapticFeedback
                                                                        .lightImpact();
                                                                  },
                                                                  text: 'Admin',
                                                                  options:
                                                                      FFButtonOptions(
                                                                    height:
                                                                        24.0,
                                                                    padding: EdgeInsetsDirectional
                                                                        .fromSTEB(
                                                                            12.0,
                                                                            0.0,
                                                                            12.0,
                                                                            0.0),
                                                                    iconPadding:
                                                                        EdgeInsetsDirectional.fromSTEB(
                                                                            0.0,
                                                                            0.0,
                                                                            0.0,
                                                                            0.0),
                                                                    color: FlutterFlowTheme.of(
                                                                            context)
                                                                        .primary,
                                                                    textStyle: FlutterFlowTheme.of(
                                                                            context)
                                                                        .titleSmall
                                                                        .override(
                                                                          font:
                                                                              GoogleFonts.manrope(
                                                                            fontWeight:
                                                                                FlutterFlowTheme.of(context).titleSmall.fontWeight,
                                                                            fontStyle:
                                                                                FlutterFlowTheme.of(context).titleSmall.fontStyle,
                                                                          ),
                                                                          color:
                                                                              Colors.white,
                                                                          fontSize:
                                                                              12.0,
                                                                          letterSpacing:
                                                                              0.0,
                                                                          fontWeight: FlutterFlowTheme.of(context)
                                                                              .titleSmall
                                                                              .fontWeight,
                                                                          fontStyle: FlutterFlowTheme.of(context)
                                                                              .titleSmall
                                                                              .fontStyle,
                                                                        ),
                                                                    elevation:
                                                                        0.0,
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .only(
                                                                      topLeft: Radius
                                                                          .circular(
                                                                              100.0),
                                                                      topRight:
                                                                          Radius.circular(
                                                                              100.0),
                                                                      bottomLeft:
                                                                          Radius.circular(
                                                                              100.0),
                                                                      bottomRight:
                                                                          Radius.circular(
                                                                              100.0),
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
                                                                    HapticFeedback
                                                                        .lightImpact();
                                                                    await GroupMembersTable()
                                                                        .insert({
                                                                      'community_id':
                                                                          FFAppState()
                                                                              .communityId,
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
                                                                      'joined_at': supaSerialize<
                                                                              DateTime>(
                                                                          functions
                                                                              .getCurrentUtcTime()),
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
                                                                    _model.apiResultd2ppCopyCopyCopyCopy =
                                                                        await UpdateTotalGroupMembersCall
                                                                            .call(
                                                                      token:
                                                                          currentJwtToken,
                                                                      anonKey:
                                                                          FFDevEnvironmentValues()
                                                                              .AnonKey,
                                                                      groupId:
                                                                          getJsonField(
                                                                        gropsItem,
                                                                        r'''$.group_id''',
                                                                      ).toString(),
                                                                    );

                                                                    safeSetState(
                                                                        () {});
                                                                  },
                                                                  text: 'Join',
                                                                  options:
                                                                      FFButtonOptions(
                                                                    height:
                                                                        24.0,
                                                                    padding: EdgeInsetsDirectional
                                                                        .fromSTEB(
                                                                            16.0,
                                                                            0.0,
                                                                            16.0,
                                                                            0.0),
                                                                    iconPadding:
                                                                        EdgeInsetsDirectional.fromSTEB(
                                                                            0.0,
                                                                            0.0,
                                                                            0.0,
                                                                            0.0),
                                                                    color: Colors
                                                                        .transparent,
                                                                    textStyle: FlutterFlowTheme.of(
                                                                            context)
                                                                        .titleSmall
                                                                        .override(
                                                                          font:
                                                                              GoogleFonts.manrope(
                                                                            fontWeight:
                                                                                FlutterFlowTheme.of(context).titleSmall.fontWeight,
                                                                            fontStyle:
                                                                                FlutterFlowTheme.of(context).titleSmall.fontStyle,
                                                                          ),
                                                                          color:
                                                                              FlutterFlowTheme.of(context).primaryD3,
                                                                          fontSize:
                                                                              12.0,
                                                                          letterSpacing:
                                                                              0.0,
                                                                          fontWeight: FlutterFlowTheme.of(context)
                                                                              .titleSmall
                                                                              .fontWeight,
                                                                          fontStyle: FlutterFlowTheme.of(context)
                                                                              .titleSmall
                                                                              .fontStyle,
                                                                        ),
                                                                    elevation:
                                                                        0.0,
                                                                    borderSide:
                                                                        BorderSide(
                                                                      color: FlutterFlowTheme.of(
                                                                              context)
                                                                          .primaryD3,
                                                                      width:
                                                                          1.0,
                                                                    ),
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .only(
                                                                      topLeft: Radius
                                                                          .circular(
                                                                              100.0),
                                                                      topRight:
                                                                          Radius.circular(
                                                                              100.0),
                                                                      bottomLeft:
                                                                          Radius.circular(
                                                                              100.0),
                                                                      bottomRight:
                                                                          Radius.circular(
                                                                              100.0),
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
                                                                  icon: Icon(
                                                                    Icons
                                                                        .lock_outline_sharp,
                                                                    size: 15.0,
                                                                  ),
                                                                  options:
                                                                      FFButtonOptions(
                                                                    height:
                                                                        24.0,
                                                                    padding: EdgeInsetsDirectional
                                                                        .fromSTEB(
                                                                            16.0,
                                                                            0.0,
                                                                            16.0,
                                                                            0.0),
                                                                    iconPadding:
                                                                        EdgeInsetsDirectional.fromSTEB(
                                                                            0.0,
                                                                            0.0,
                                                                            0.0,
                                                                            0.0),
                                                                    iconColor: FlutterFlowTheme.of(
                                                                            context)
                                                                        .primaryD3,
                                                                    color: Colors
                                                                        .transparent,
                                                                    textStyle: FlutterFlowTheme.of(
                                                                            context)
                                                                        .titleSmall
                                                                        .override(
                                                                          font:
                                                                              GoogleFonts.manrope(
                                                                            fontWeight:
                                                                                FlutterFlowTheme.of(context).titleSmall.fontWeight,
                                                                            fontStyle:
                                                                                FlutterFlowTheme.of(context).titleSmall.fontStyle,
                                                                          ),
                                                                          color:
                                                                              FlutterFlowTheme.of(context).primaryD3,
                                                                          fontSize:
                                                                              12.0,
                                                                          letterSpacing:
                                                                              0.0,
                                                                          fontWeight: FlutterFlowTheme.of(context)
                                                                              .titleSmall
                                                                              .fontWeight,
                                                                          fontStyle: FlutterFlowTheme.of(context)
                                                                              .titleSmall
                                                                              .fontStyle,
                                                                        ),
                                                                    elevation:
                                                                        0.0,
                                                                    borderSide:
                                                                        BorderSide(
                                                                      color: FlutterFlowTheme.of(
                                                                              context)
                                                                          .primaryD3,
                                                                      width:
                                                                          1.0,
                                                                    ),
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .only(
                                                                      topLeft: Radius
                                                                          .circular(
                                                                              100.0),
                                                                      topRight:
                                                                          Radius.circular(
                                                                              100.0),
                                                                      bottomLeft:
                                                                          Radius.circular(
                                                                              100.0),
                                                                      bottomRight:
                                                                          Radius.circular(
                                                                              100.0),
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
                                              ),
                                            ),
                                          )
                                              .animate()
                                              .fadeIn(
                                                  duration: 260.ms,
                                                  delay: (40 * (gropsIndex % 8))
                                                      .ms)
                                              .slideY(
                                                  begin: 0.06,
                                                  end: 0,
                                                  curve: Curves.easeOutCubic);
                                        },
                                      );
                                    },
                                  ),
                                ),
                              ),
                            if (('${getJsonField(
                                      FFAppState().AsGroupList,
                                      r'''$''',
                                    ).toString()}' !=
                                    '[]') &&
                                _model.showListView &&
                                (_model.currentBtn == 'created'))
                              Expanded(
                                child: Align(
                                  alignment: AlignmentDirectional(0.0, -1.0),
                                  child: Builder(
                                    builder: (context) {
                                      final grops = getJsonField(
                                        FFAppState().AsGroupList,
                                        r'''$''',
                                      ).toList();
                                      if (grops.isEmpty) {
                                        return CompNoGroupsAvailableWidget();
                                      }

                                      return ListView.builder(
                                        physics:
                                            const AlwaysScrollableScrollPhysics(),
                                        padding: EdgeInsets.fromLTRB(
                                          0,
                                          12.0,
                                          0,
                                          12.0,
                                        ),
                                        shrinkWrap: true,
                                        scrollDirection: Axis.vertical,
                                        itemCount: grops.length,
                                        itemBuilder: (context, gropsIndex) {
                                          final gropsItem = grops[gropsIndex];
                                          return Visibility(
                                            visible: ('${getJsonField(
                                                      gropsItem,
                                                      r'''$.user_status''',
                                                    ).toString()}' ==
                                                    'admin') &&
                                                (('${getJsonField(
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
                                                            'requested'))),
                                            child: Padding(
                                              padding: EdgeInsetsDirectional
                                                  .fromSTEB(
                                                      0.0, 0.0, 0.0, 12.0),
                                              child: Semantics(
                                                button: true,
                                                label: 'Open group',
                                                child: InkWell(
                                                  splashColor:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .primary
                                                          .withAlpha(0x14),
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
                                                    constraints: BoxConstraints(
                                                        minHeight: 56.0),
                                                    decoration: BoxDecoration(
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
                                                            MainAxisSize.max,
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
                                                                AppNetworkImage(
                                                                  url: getJsonField(
                                                                          gropsItem,
                                                                          r'''$.profile_picture''')
                                                                      .toString(),
                                                                  width: 40.0,
                                                                  height: 40.0,
                                                                  fit: BoxFit
                                                                      .cover,
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              2.0),
                                                                  semanticLabel:
                                                                      'Group cover photo',
                                                                ),
                                                                Expanded(
                                                                  child: Column(
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .max,
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      if ('${getJsonField(
                                                                            gropsItem,
                                                                            r'''$.invited_by_user_id''',
                                                                          ).toString()}' !=
                                                                          'null')
                                                                        Row(
                                                                          mainAxisSize:
                                                                              MainAxisSize.max,
                                                                          children:
                                                                              [
                                                                            AppNetworkImage(
                                                                              url: getJsonField(gropsItem, r'''$.invited_by_profile_picture''').toString(),
                                                                              width: 12.0,
                                                                              height: 12.0,
                                                                              fit: BoxFit.cover,
                                                                              isAvatar: true,
                                                                              semanticLabel: 'Inviter profile photo',
                                                                            ),
                                                                            Expanded(
                                                                              child: Text(
                                                                                '${getJsonField(
                                                                                  gropsItem,
                                                                                  r'''$.invited_by_name''',
                                                                                ).toString()} invited you to join this group',
                                                                                maxLines: 1,
                                                                                style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                      font: GoogleFonts.manrope(
                                                                                        fontWeight: FontWeight.w500,
                                                                                        fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                      ),
                                                                                      color: FlutterFlowTheme.of(context).greyL4,
                                                                                      fontSize: 12.0,
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
                                                                        style: FlutterFlowTheme.of(context)
                                                                            .bodyMedium
                                                                            .override(
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
                                                                            r'''$.invited_by_user_id''',
                                                                          ).toString()}' ==
                                                                          'null')
                                                                        Text(
                                                                          '${getJsonField(
                                                                            gropsItem,
                                                                            r'''$.total_members''',
                                                                          ).toString()} ${'${getJsonField(
                                                                                gropsItem,
                                                                                r'''$.total_members''',
                                                                              ).toString()}' == '1' ? 'member' : 'members'}',
                                                                          style: FlutterFlowTheme.of(context)
                                                                              .bodyMedium
                                                                              .override(
                                                                                font: GoogleFonts.manrope(
                                                                                  fontWeight: FontWeight.w500,
                                                                                  fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                ),
                                                                                color: FlutterFlowTheme.of(context).greyL4,
                                                                                fontSize: 12.0,
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
                                                                  width: 8.0)),
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
                                                                    HapticFeedback
                                                                        .lightImpact();
                                                                    await GroupMembersTable()
                                                                        .insert({
                                                                      'community_id':
                                                                          FFAppState()
                                                                              .communityId,
                                                                      'user_id':
                                                                          currentUserUid,
                                                                      'group_id':
                                                                          getJsonField(
                                                                        gropsItem,
                                                                        r'''$.group_id''',
                                                                      ).toString(),
                                                                      'is_requested':
                                                                          false,
                                                                      'requested_date': supaSerialize<
                                                                              DateTime>(
                                                                          functions
                                                                              .getCurrentUtcTime()),
                                                                      'is_approved':
                                                                          true,
                                                                      'approved_by':
                                                                          currentUserUid,
                                                                      'joined_at': supaSerialize<
                                                                              DateTime>(
                                                                          functions
                                                                              .getCurrentUtcTime()),
                                                                    });
                                                                    await GroupUserStatusTable()
                                                                        .insert({
                                                                      'community_id':
                                                                          FFAppState()
                                                                              .communityId,
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
                                                                      'joined_at': supaSerialize<
                                                                              DateTime>(
                                                                          functions
                                                                              .getCurrentUtcTime()),
                                                                    });
                                                                    _model.apiResultd2pxxxz =
                                                                        await UpdateTotalGroupMembersCall
                                                                            .call(
                                                                      token:
                                                                          currentJwtToken,
                                                                      anonKey:
                                                                          FFDevEnvironmentValues()
                                                                              .AnonKey,
                                                                      groupId:
                                                                          getJsonField(
                                                                        gropsItem,
                                                                        r'''$.group_id''',
                                                                      ).toString(),
                                                                    );

                                                                    safeSetState(
                                                                        () {});
                                                                  },
                                                                  text: 'Join',
                                                                  options:
                                                                      FFButtonOptions(
                                                                    height:
                                                                        24.0,
                                                                    padding: EdgeInsetsDirectional
                                                                        .fromSTEB(
                                                                            16.0,
                                                                            0.0,
                                                                            16.0,
                                                                            0.0),
                                                                    iconPadding:
                                                                        EdgeInsetsDirectional.fromSTEB(
                                                                            0.0,
                                                                            0.0,
                                                                            0.0,
                                                                            0.0),
                                                                    color: Colors
                                                                        .transparent,
                                                                    textStyle: FlutterFlowTheme.of(
                                                                            context)
                                                                        .titleSmall
                                                                        .override(
                                                                          font:
                                                                              GoogleFonts.manrope(
                                                                            fontWeight:
                                                                                FlutterFlowTheme.of(context).titleSmall.fontWeight,
                                                                            fontStyle:
                                                                                FlutterFlowTheme.of(context).titleSmall.fontStyle,
                                                                          ),
                                                                          color:
                                                                              FlutterFlowTheme.of(context).primaryD3,
                                                                          fontSize:
                                                                              12.0,
                                                                          letterSpacing:
                                                                              0.0,
                                                                          fontWeight: FlutterFlowTheme.of(context)
                                                                              .titleSmall
                                                                              .fontWeight,
                                                                          fontStyle: FlutterFlowTheme.of(context)
                                                                              .titleSmall
                                                                              .fontStyle,
                                                                        ),
                                                                    elevation:
                                                                        0.0,
                                                                    borderSide:
                                                                        BorderSide(
                                                                      color: FlutterFlowTheme.of(
                                                                              context)
                                                                          .primaryD3,
                                                                      width:
                                                                          1.0,
                                                                    ),
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .only(
                                                                      topLeft: Radius
                                                                          .circular(
                                                                              100.0),
                                                                      topRight:
                                                                          Radius.circular(
                                                                              100.0),
                                                                      bottomLeft:
                                                                          Radius.circular(
                                                                              100.0),
                                                                      bottomRight:
                                                                          Radius.circular(
                                                                              100.0),
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
                                                                      () {},
                                                                  text:
                                                                      'Joined',
                                                                  icon: Icon(
                                                                    Icons
                                                                        .done_all,
                                                                    size: 15.0,
                                                                  ),
                                                                  options:
                                                                      FFButtonOptions(
                                                                    height:
                                                                        24.0,
                                                                    padding: EdgeInsetsDirectional
                                                                        .fromSTEB(
                                                                            16.0,
                                                                            0.0,
                                                                            16.0,
                                                                            0.0),
                                                                    iconPadding:
                                                                        EdgeInsetsDirectional.fromSTEB(
                                                                            0.0,
                                                                            0.0,
                                                                            0.0,
                                                                            0.0),
                                                                    iconColor: FlutterFlowTheme.of(
                                                                            context)
                                                                        .greyL4,
                                                                    color: Colors
                                                                        .transparent,
                                                                    textStyle: FlutterFlowTheme.of(
                                                                            context)
                                                                        .titleSmall
                                                                        .override(
                                                                          font:
                                                                              GoogleFonts.manrope(
                                                                            fontWeight:
                                                                                FlutterFlowTheme.of(context).titleSmall.fontWeight,
                                                                            fontStyle:
                                                                                FlutterFlowTheme.of(context).titleSmall.fontStyle,
                                                                          ),
                                                                          color:
                                                                              FlutterFlowTheme.of(context).greyL4,
                                                                          fontSize:
                                                                              12.0,
                                                                          letterSpacing:
                                                                              0.0,
                                                                          fontWeight: FlutterFlowTheme.of(context)
                                                                              .titleSmall
                                                                              .fontWeight,
                                                                          fontStyle: FlutterFlowTheme.of(context)
                                                                              .titleSmall
                                                                              .fontStyle,
                                                                        ),
                                                                    elevation:
                                                                        0.0,
                                                                    borderSide:
                                                                        BorderSide(
                                                                      color: FlutterFlowTheme.of(
                                                                              context)
                                                                          .greyL4,
                                                                      width:
                                                                          1.0,
                                                                    ),
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .only(
                                                                      topLeft: Radius
                                                                          .circular(
                                                                              100.0),
                                                                      topRight:
                                                                          Radius.circular(
                                                                              100.0),
                                                                      bottomLeft:
                                                                          Radius.circular(
                                                                              100.0),
                                                                      bottomRight:
                                                                          Radius.circular(
                                                                              100.0),
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
                                                                    HapticFeedback
                                                                        .lightImpact();
                                                                  },
                                                                  text:
                                                                      'Requested',
                                                                  options:
                                                                      FFButtonOptions(
                                                                    height:
                                                                        24.0,
                                                                    padding: EdgeInsetsDirectional
                                                                        .fromSTEB(
                                                                            16.0,
                                                                            0.0,
                                                                            16.0,
                                                                            0.0),
                                                                    iconPadding:
                                                                        EdgeInsetsDirectional.fromSTEB(
                                                                            0.0,
                                                                            0.0,
                                                                            0.0,
                                                                            0.0),
                                                                    color: FlutterFlowTheme.of(
                                                                            context)
                                                                        .greyL2,
                                                                    textStyle: FlutterFlowTheme.of(
                                                                            context)
                                                                        .titleSmall
                                                                        .override(
                                                                          font:
                                                                              GoogleFonts.manrope(
                                                                            fontWeight:
                                                                                FlutterFlowTheme.of(context).titleSmall.fontWeight,
                                                                            fontStyle:
                                                                                FlutterFlowTheme.of(context).titleSmall.fontStyle,
                                                                          ),
                                                                          color:
                                                                              FlutterFlowTheme.of(context).greyL3,
                                                                          fontSize:
                                                                              12.0,
                                                                          letterSpacing:
                                                                              0.0,
                                                                          fontWeight: FlutterFlowTheme.of(context)
                                                                              .titleSmall
                                                                              .fontWeight,
                                                                          fontStyle: FlutterFlowTheme.of(context)
                                                                              .titleSmall
                                                                              .fontStyle,
                                                                        ),
                                                                    elevation:
                                                                        0.0,
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .only(
                                                                      topLeft: Radius
                                                                          .circular(
                                                                              100.0),
                                                                      topRight:
                                                                          Radius.circular(
                                                                              100.0),
                                                                      bottomLeft:
                                                                          Radius.circular(
                                                                              100.0),
                                                                      bottomRight:
                                                                          Radius.circular(
                                                                              100.0),
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
                                                                          FFAppState()
                                                                              .communityId,
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
                                                                      'requested_date': supaSerialize<
                                                                              DateTime>(
                                                                          functions
                                                                              .getCurrentUtcTime()),
                                                                    });
                                                                  },
                                                                  text:
                                                                      'Request',
                                                                  icon: Icon(
                                                                    Icons
                                                                        .lock_outline_sharp,
                                                                    size: 15.0,
                                                                  ),
                                                                  options:
                                                                      FFButtonOptions(
                                                                    height:
                                                                        24.0,
                                                                    padding: EdgeInsetsDirectional
                                                                        .fromSTEB(
                                                                            16.0,
                                                                            0.0,
                                                                            16.0,
                                                                            0.0),
                                                                    iconPadding:
                                                                        EdgeInsetsDirectional.fromSTEB(
                                                                            0.0,
                                                                            0.0,
                                                                            0.0,
                                                                            0.0),
                                                                    iconColor: FlutterFlowTheme.of(
                                                                            context)
                                                                        .primaryD3,
                                                                    color: Colors
                                                                        .transparent,
                                                                    textStyle: FlutterFlowTheme.of(
                                                                            context)
                                                                        .titleSmall
                                                                        .override(
                                                                          font:
                                                                              GoogleFonts.manrope(
                                                                            fontWeight:
                                                                                FlutterFlowTheme.of(context).titleSmall.fontWeight,
                                                                            fontStyle:
                                                                                FlutterFlowTheme.of(context).titleSmall.fontStyle,
                                                                          ),
                                                                          color:
                                                                              FlutterFlowTheme.of(context).primaryD3,
                                                                          fontSize:
                                                                              12.0,
                                                                          letterSpacing:
                                                                              0.0,
                                                                          fontWeight: FlutterFlowTheme.of(context)
                                                                              .titleSmall
                                                                              .fontWeight,
                                                                          fontStyle: FlutterFlowTheme.of(context)
                                                                              .titleSmall
                                                                              .fontStyle,
                                                                        ),
                                                                    elevation:
                                                                        0.0,
                                                                    borderSide:
                                                                        BorderSide(
                                                                      color: FlutterFlowTheme.of(
                                                                              context)
                                                                          .primaryD3,
                                                                      width:
                                                                          1.0,
                                                                    ),
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .only(
                                                                      topLeft: Radius
                                                                          .circular(
                                                                              100.0),
                                                                      topRight:
                                                                          Radius.circular(
                                                                              100.0),
                                                                      bottomLeft:
                                                                          Radius.circular(
                                                                              100.0),
                                                                      bottomRight:
                                                                          Radius.circular(
                                                                              100.0),
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
                                                                    HapticFeedback
                                                                        .lightImpact();
                                                                  },
                                                                  text: 'Admin',
                                                                  options:
                                                                      FFButtonOptions(
                                                                    height:
                                                                        24.0,
                                                                    padding: EdgeInsetsDirectional
                                                                        .fromSTEB(
                                                                            12.0,
                                                                            0.0,
                                                                            12.0,
                                                                            0.0),
                                                                    iconPadding:
                                                                        EdgeInsetsDirectional.fromSTEB(
                                                                            0.0,
                                                                            0.0,
                                                                            0.0,
                                                                            0.0),
                                                                    color: FlutterFlowTheme.of(
                                                                            context)
                                                                        .primary,
                                                                    textStyle: FlutterFlowTheme.of(
                                                                            context)
                                                                        .titleSmall
                                                                        .override(
                                                                          font:
                                                                              GoogleFonts.manrope(
                                                                            fontWeight:
                                                                                FlutterFlowTheme.of(context).titleSmall.fontWeight,
                                                                            fontStyle:
                                                                                FlutterFlowTheme.of(context).titleSmall.fontStyle,
                                                                          ),
                                                                          color:
                                                                              Colors.white,
                                                                          fontSize:
                                                                              12.0,
                                                                          letterSpacing:
                                                                              0.0,
                                                                          fontWeight: FlutterFlowTheme.of(context)
                                                                              .titleSmall
                                                                              .fontWeight,
                                                                          fontStyle: FlutterFlowTheme.of(context)
                                                                              .titleSmall
                                                                              .fontStyle,
                                                                        ),
                                                                    elevation:
                                                                        0.0,
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .only(
                                                                      topLeft: Radius
                                                                          .circular(
                                                                              100.0),
                                                                      topRight:
                                                                          Radius.circular(
                                                                              100.0),
                                                                      bottomLeft:
                                                                          Radius.circular(
                                                                              100.0),
                                                                      bottomRight:
                                                                          Radius.circular(
                                                                              100.0),
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
                                                                    HapticFeedback
                                                                        .lightImpact();
                                                                    await GroupMembersTable()
                                                                        .insert({
                                                                      'community_id':
                                                                          FFAppState()
                                                                              .communityId,
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
                                                                      'joined_at': supaSerialize<
                                                                              DateTime>(
                                                                          functions
                                                                              .getCurrentUtcTime()),
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
                                                                    _model.apiResultd2ppCopyCopyCopy =
                                                                        await UpdateTotalGroupMembersCall
                                                                            .call(
                                                                      token:
                                                                          currentJwtToken,
                                                                      anonKey:
                                                                          FFDevEnvironmentValues()
                                                                              .AnonKey,
                                                                      groupId:
                                                                          getJsonField(
                                                                        gropsItem,
                                                                        r'''$.group_id''',
                                                                      ).toString(),
                                                                    );

                                                                    safeSetState(
                                                                        () {});
                                                                  },
                                                                  text: 'Join',
                                                                  options:
                                                                      FFButtonOptions(
                                                                    height:
                                                                        24.0,
                                                                    padding: EdgeInsetsDirectional
                                                                        .fromSTEB(
                                                                            16.0,
                                                                            0.0,
                                                                            16.0,
                                                                            0.0),
                                                                    iconPadding:
                                                                        EdgeInsetsDirectional.fromSTEB(
                                                                            0.0,
                                                                            0.0,
                                                                            0.0,
                                                                            0.0),
                                                                    color: Colors
                                                                        .transparent,
                                                                    textStyle: FlutterFlowTheme.of(
                                                                            context)
                                                                        .titleSmall
                                                                        .override(
                                                                          font:
                                                                              GoogleFonts.manrope(
                                                                            fontWeight:
                                                                                FlutterFlowTheme.of(context).titleSmall.fontWeight,
                                                                            fontStyle:
                                                                                FlutterFlowTheme.of(context).titleSmall.fontStyle,
                                                                          ),
                                                                          color:
                                                                              FlutterFlowTheme.of(context).primaryD3,
                                                                          fontSize:
                                                                              12.0,
                                                                          letterSpacing:
                                                                              0.0,
                                                                          fontWeight: FlutterFlowTheme.of(context)
                                                                              .titleSmall
                                                                              .fontWeight,
                                                                          fontStyle: FlutterFlowTheme.of(context)
                                                                              .titleSmall
                                                                              .fontStyle,
                                                                        ),
                                                                    elevation:
                                                                        0.0,
                                                                    borderSide:
                                                                        BorderSide(
                                                                      color: FlutterFlowTheme.of(
                                                                              context)
                                                                          .primaryD3,
                                                                      width:
                                                                          1.0,
                                                                    ),
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .only(
                                                                      topLeft: Radius
                                                                          .circular(
                                                                              100.0),
                                                                      topRight:
                                                                          Radius.circular(
                                                                              100.0),
                                                                      bottomLeft:
                                                                          Radius.circular(
                                                                              100.0),
                                                                      bottomRight:
                                                                          Radius.circular(
                                                                              100.0),
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
                                                                  icon: Icon(
                                                                    Icons
                                                                        .lock_outline_sharp,
                                                                    size: 15.0,
                                                                  ),
                                                                  options:
                                                                      FFButtonOptions(
                                                                    height:
                                                                        24.0,
                                                                    padding: EdgeInsetsDirectional
                                                                        .fromSTEB(
                                                                            16.0,
                                                                            0.0,
                                                                            16.0,
                                                                            0.0),
                                                                    iconPadding:
                                                                        EdgeInsetsDirectional.fromSTEB(
                                                                            0.0,
                                                                            0.0,
                                                                            0.0,
                                                                            0.0),
                                                                    iconColor: FlutterFlowTheme.of(
                                                                            context)
                                                                        .primaryD3,
                                                                    color: Colors
                                                                        .transparent,
                                                                    textStyle: FlutterFlowTheme.of(
                                                                            context)
                                                                        .titleSmall
                                                                        .override(
                                                                          font:
                                                                              GoogleFonts.manrope(
                                                                            fontWeight:
                                                                                FlutterFlowTheme.of(context).titleSmall.fontWeight,
                                                                            fontStyle:
                                                                                FlutterFlowTheme.of(context).titleSmall.fontStyle,
                                                                          ),
                                                                          color:
                                                                              FlutterFlowTheme.of(context).primaryD3,
                                                                          fontSize:
                                                                              12.0,
                                                                          letterSpacing:
                                                                              0.0,
                                                                          fontWeight: FlutterFlowTheme.of(context)
                                                                              .titleSmall
                                                                              .fontWeight,
                                                                          fontStyle: FlutterFlowTheme.of(context)
                                                                              .titleSmall
                                                                              .fontStyle,
                                                                        ),
                                                                    elevation:
                                                                        0.0,
                                                                    borderSide:
                                                                        BorderSide(
                                                                      color: FlutterFlowTheme.of(
                                                                              context)
                                                                          .primaryD3,
                                                                      width:
                                                                          1.0,
                                                                    ),
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .only(
                                                                      topLeft: Radius
                                                                          .circular(
                                                                              100.0),
                                                                      topRight:
                                                                          Radius.circular(
                                                                              100.0),
                                                                      bottomLeft:
                                                                          Radius.circular(
                                                                              100.0),
                                                                      bottomRight:
                                                                          Radius.circular(
                                                                              100.0),
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
                                              ),
                                            ),
                                          )
                                              .animate()
                                              .fadeIn(
                                                  duration: 260.ms,
                                                  delay: (40 * (gropsIndex % 8))
                                                      .ms)
                                              .slideY(
                                                  begin: 0.06,
                                                  end: 0,
                                                  curve: Curves.easeOutCubic);
                                        },
                                      );
                                    },
                                  ),
                                ),
                              ),
                            if (('${getJsonField(
                                      FFAppState().AsGroupList,
                                      r'''$''',
                                    ).toString()}' !=
                                    '[]') &&
                                _model.showListView &&
                                (_model.currentBtn == 'invitations'))
                              Expanded(
                                child: Align(
                                  alignment: AlignmentDirectional(0.0, -1.0),
                                  child: Builder(
                                    builder: (context) {
                                      final grops = getJsonField(
                                        FFAppState().AsGroupList,
                                        r'''$''',
                                      ).toList();
                                      if (grops.isEmpty) {
                                        return CompNoGroupsAvailableWidget();
                                      }

                                      return ListView.builder(
                                        physics:
                                            const AlwaysScrollableScrollPhysics(),
                                        padding: EdgeInsets.fromLTRB(
                                          0,
                                          12.0,
                                          0,
                                          12.0,
                                        ),
                                        shrinkWrap: true,
                                        scrollDirection: Axis.vertical,
                                        itemCount: grops.length,
                                        itemBuilder: (context, gropsIndex) {
                                          final gropsItem = grops[gropsIndex];
                                          return Visibility(
                                            visible: ('${getJsonField(
                                                      gropsItem,
                                                      r'''$.user_status''',
                                                    ).toString()}' ==
                                                    'invite') &&
                                                (('${getJsonField(
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
                                                            'requested'))),
                                            child: Padding(
                                              padding: EdgeInsetsDirectional
                                                  .fromSTEB(
                                                      0.0, 0.0, 0.0, 12.0),
                                              child: Semantics(
                                                button: true,
                                                label: 'Open group',
                                                child: InkWell(
                                                  splashColor:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .primary
                                                          .withAlpha(0x14),
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
                                                    constraints: BoxConstraints(
                                                        minHeight: 56.0),
                                                    decoration: BoxDecoration(
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
                                                            MainAxisSize.max,
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
                                                                AppNetworkImage(
                                                                  url: getJsonField(
                                                                          gropsItem,
                                                                          r'''$.profile_picture''')
                                                                      .toString(),
                                                                  width: 40.0,
                                                                  height: 40.0,
                                                                  fit: BoxFit
                                                                      .cover,
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              2.0),
                                                                  semanticLabel:
                                                                      'Group cover photo',
                                                                ),
                                                                Expanded(
                                                                  child: Column(
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .max,
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      if ('${getJsonField(
                                                                            gropsItem,
                                                                            r'''$.invited_by_user_id''',
                                                                          ).toString()}' !=
                                                                          'null')
                                                                        Row(
                                                                          mainAxisSize:
                                                                              MainAxisSize.max,
                                                                          children:
                                                                              [
                                                                            AppNetworkImage(
                                                                              url: getJsonField(gropsItem, r'''$.invited_by_profile_picture''').toString(),
                                                                              width: 12.0,
                                                                              height: 12.0,
                                                                              fit: BoxFit.cover,
                                                                              isAvatar: true,
                                                                              semanticLabel: 'Inviter profile photo',
                                                                            ),
                                                                            Expanded(
                                                                              child: Text(
                                                                                '${getJsonField(
                                                                                  gropsItem,
                                                                                  r'''$.invited_by_name''',
                                                                                ).toString()} invited you to join this group',
                                                                                maxLines: 1,
                                                                                style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                      font: GoogleFonts.manrope(
                                                                                        fontWeight: FontWeight.w500,
                                                                                        fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                      ),
                                                                                      color: FlutterFlowTheme.of(context).greyL4,
                                                                                      fontSize: 12.0,
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
                                                                        style: FlutterFlowTheme.of(context)
                                                                            .bodyMedium
                                                                            .override(
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
                                                                            r'''$.invited_by_user_id''',
                                                                          ).toString()}' ==
                                                                          'null')
                                                                        Text(
                                                                          '${getJsonField(
                                                                            gropsItem,
                                                                            r'''$.total_members''',
                                                                          ).toString()} ${'${getJsonField(
                                                                                gropsItem,
                                                                                r'''$.total_members''',
                                                                              ).toString()}' == '1' ? 'member' : 'members'}',
                                                                          style: FlutterFlowTheme.of(context)
                                                                              .bodyMedium
                                                                              .override(
                                                                                font: GoogleFonts.manrope(
                                                                                  fontWeight: FontWeight.w500,
                                                                                  fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                ),
                                                                                color: FlutterFlowTheme.of(context).greyL4,
                                                                                fontSize: 12.0,
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
                                                                  width: 8.0)),
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
                                                                    HapticFeedback
                                                                        .lightImpact();
                                                                    await GroupMembersTable()
                                                                        .insert({
                                                                      'community_id':
                                                                          FFAppState()
                                                                              .communityId,
                                                                      'user_id':
                                                                          currentUserUid,
                                                                      'group_id':
                                                                          getJsonField(
                                                                        gropsItem,
                                                                        r'''$.group_id''',
                                                                      ).toString(),
                                                                      'is_requested':
                                                                          false,
                                                                      'requested_date': supaSerialize<
                                                                              DateTime>(
                                                                          functions
                                                                              .getCurrentUtcTime()),
                                                                      'is_approved':
                                                                          true,
                                                                      'approved_by':
                                                                          currentUserUid,
                                                                      'joined_at': supaSerialize<
                                                                              DateTime>(
                                                                          functions
                                                                              .getCurrentUtcTime()),
                                                                    });
                                                                    await GroupUserStatusTable()
                                                                        .insert({
                                                                      'community_id':
                                                                          FFAppState()
                                                                              .communityId,
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
                                                                      'joined_at': supaSerialize<
                                                                              DateTime>(
                                                                          functions
                                                                              .getCurrentUtcTime()),
                                                                    });
                                                                    _model.apiResultd2pCopy =
                                                                        await UpdateTotalGroupMembersCall
                                                                            .call(
                                                                      token:
                                                                          currentJwtToken,
                                                                      anonKey:
                                                                          FFDevEnvironmentValues()
                                                                              .AnonKey,
                                                                      groupId:
                                                                          getJsonField(
                                                                        gropsItem,
                                                                        r'''$.group_id''',
                                                                      ).toString(),
                                                                    );

                                                                    safeSetState(
                                                                        () {});
                                                                  },
                                                                  text: 'Join',
                                                                  options:
                                                                      FFButtonOptions(
                                                                    height:
                                                                        24.0,
                                                                    padding: EdgeInsetsDirectional
                                                                        .fromSTEB(
                                                                            16.0,
                                                                            0.0,
                                                                            16.0,
                                                                            0.0),
                                                                    iconPadding:
                                                                        EdgeInsetsDirectional.fromSTEB(
                                                                            0.0,
                                                                            0.0,
                                                                            0.0,
                                                                            0.0),
                                                                    color: Colors
                                                                        .transparent,
                                                                    textStyle: FlutterFlowTheme.of(
                                                                            context)
                                                                        .titleSmall
                                                                        .override(
                                                                          font:
                                                                              GoogleFonts.manrope(
                                                                            fontWeight:
                                                                                FlutterFlowTheme.of(context).titleSmall.fontWeight,
                                                                            fontStyle:
                                                                                FlutterFlowTheme.of(context).titleSmall.fontStyle,
                                                                          ),
                                                                          color:
                                                                              FlutterFlowTheme.of(context).primaryD3,
                                                                          fontSize:
                                                                              12.0,
                                                                          letterSpacing:
                                                                              0.0,
                                                                          fontWeight: FlutterFlowTheme.of(context)
                                                                              .titleSmall
                                                                              .fontWeight,
                                                                          fontStyle: FlutterFlowTheme.of(context)
                                                                              .titleSmall
                                                                              .fontStyle,
                                                                        ),
                                                                    elevation:
                                                                        0.0,
                                                                    borderSide:
                                                                        BorderSide(
                                                                      color: FlutterFlowTheme.of(
                                                                              context)
                                                                          .primaryD3,
                                                                      width:
                                                                          1.0,
                                                                    ),
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .only(
                                                                      topLeft: Radius
                                                                          .circular(
                                                                              100.0),
                                                                      topRight:
                                                                          Radius.circular(
                                                                              100.0),
                                                                      bottomLeft:
                                                                          Radius.circular(
                                                                              100.0),
                                                                      bottomRight:
                                                                          Radius.circular(
                                                                              100.0),
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
                                                                      () {},
                                                                  text:
                                                                      'Joined',
                                                                  icon: Icon(
                                                                    Icons
                                                                        .done_all,
                                                                    size: 15.0,
                                                                  ),
                                                                  options:
                                                                      FFButtonOptions(
                                                                    height:
                                                                        24.0,
                                                                    padding: EdgeInsetsDirectional
                                                                        .fromSTEB(
                                                                            16.0,
                                                                            0.0,
                                                                            16.0,
                                                                            0.0),
                                                                    iconPadding:
                                                                        EdgeInsetsDirectional.fromSTEB(
                                                                            0.0,
                                                                            0.0,
                                                                            0.0,
                                                                            0.0),
                                                                    iconColor: FlutterFlowTheme.of(
                                                                            context)
                                                                        .greyL4,
                                                                    color: Colors
                                                                        .transparent,
                                                                    textStyle: FlutterFlowTheme.of(
                                                                            context)
                                                                        .titleSmall
                                                                        .override(
                                                                          font:
                                                                              GoogleFonts.manrope(
                                                                            fontWeight:
                                                                                FlutterFlowTheme.of(context).titleSmall.fontWeight,
                                                                            fontStyle:
                                                                                FlutterFlowTheme.of(context).titleSmall.fontStyle,
                                                                          ),
                                                                          color:
                                                                              FlutterFlowTheme.of(context).greyL4,
                                                                          fontSize:
                                                                              12.0,
                                                                          letterSpacing:
                                                                              0.0,
                                                                          fontWeight: FlutterFlowTheme.of(context)
                                                                              .titleSmall
                                                                              .fontWeight,
                                                                          fontStyle: FlutterFlowTheme.of(context)
                                                                              .titleSmall
                                                                              .fontStyle,
                                                                        ),
                                                                    elevation:
                                                                        0.0,
                                                                    borderSide:
                                                                        BorderSide(
                                                                      color: FlutterFlowTheme.of(
                                                                              context)
                                                                          .greyL4,
                                                                      width:
                                                                          1.0,
                                                                    ),
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .only(
                                                                      topLeft: Radius
                                                                          .circular(
                                                                              100.0),
                                                                      topRight:
                                                                          Radius.circular(
                                                                              100.0),
                                                                      bottomLeft:
                                                                          Radius.circular(
                                                                              100.0),
                                                                      bottomRight:
                                                                          Radius.circular(
                                                                              100.0),
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
                                                                    HapticFeedback
                                                                        .lightImpact();
                                                                  },
                                                                  text:
                                                                      'Requested',
                                                                  options:
                                                                      FFButtonOptions(
                                                                    height:
                                                                        24.0,
                                                                    padding: EdgeInsetsDirectional
                                                                        .fromSTEB(
                                                                            16.0,
                                                                            0.0,
                                                                            16.0,
                                                                            0.0),
                                                                    iconPadding:
                                                                        EdgeInsetsDirectional.fromSTEB(
                                                                            0.0,
                                                                            0.0,
                                                                            0.0,
                                                                            0.0),
                                                                    color: FlutterFlowTheme.of(
                                                                            context)
                                                                        .greyL2,
                                                                    textStyle: FlutterFlowTheme.of(
                                                                            context)
                                                                        .titleSmall
                                                                        .override(
                                                                          font:
                                                                              GoogleFonts.manrope(
                                                                            fontWeight:
                                                                                FlutterFlowTheme.of(context).titleSmall.fontWeight,
                                                                            fontStyle:
                                                                                FlutterFlowTheme.of(context).titleSmall.fontStyle,
                                                                          ),
                                                                          color:
                                                                              FlutterFlowTheme.of(context).greyL3,
                                                                          fontSize:
                                                                              12.0,
                                                                          letterSpacing:
                                                                              0.0,
                                                                          fontWeight: FlutterFlowTheme.of(context)
                                                                              .titleSmall
                                                                              .fontWeight,
                                                                          fontStyle: FlutterFlowTheme.of(context)
                                                                              .titleSmall
                                                                              .fontStyle,
                                                                        ),
                                                                    elevation:
                                                                        0.0,
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .only(
                                                                      topLeft: Radius
                                                                          .circular(
                                                                              100.0),
                                                                      topRight:
                                                                          Radius.circular(
                                                                              100.0),
                                                                      bottomLeft:
                                                                          Radius.circular(
                                                                              100.0),
                                                                      bottomRight:
                                                                          Radius.circular(
                                                                              100.0),
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
                                                                          FFAppState()
                                                                              .communityId,
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
                                                                      'requested_date': supaSerialize<
                                                                              DateTime>(
                                                                          functions
                                                                              .getCurrentUtcTime()),
                                                                    });
                                                                  },
                                                                  text:
                                                                      'Request',
                                                                  icon: Icon(
                                                                    Icons
                                                                        .lock_outline_sharp,
                                                                    size: 15.0,
                                                                  ),
                                                                  options:
                                                                      FFButtonOptions(
                                                                    height:
                                                                        24.0,
                                                                    padding: EdgeInsetsDirectional
                                                                        .fromSTEB(
                                                                            16.0,
                                                                            0.0,
                                                                            16.0,
                                                                            0.0),
                                                                    iconPadding:
                                                                        EdgeInsetsDirectional.fromSTEB(
                                                                            0.0,
                                                                            0.0,
                                                                            0.0,
                                                                            0.0),
                                                                    iconColor: FlutterFlowTheme.of(
                                                                            context)
                                                                        .primaryD3,
                                                                    color: Colors
                                                                        .transparent,
                                                                    textStyle: FlutterFlowTheme.of(
                                                                            context)
                                                                        .titleSmall
                                                                        .override(
                                                                          font:
                                                                              GoogleFonts.manrope(
                                                                            fontWeight:
                                                                                FlutterFlowTheme.of(context).titleSmall.fontWeight,
                                                                            fontStyle:
                                                                                FlutterFlowTheme.of(context).titleSmall.fontStyle,
                                                                          ),
                                                                          color:
                                                                              FlutterFlowTheme.of(context).primaryD3,
                                                                          fontSize:
                                                                              12.0,
                                                                          letterSpacing:
                                                                              0.0,
                                                                          fontWeight: FlutterFlowTheme.of(context)
                                                                              .titleSmall
                                                                              .fontWeight,
                                                                          fontStyle: FlutterFlowTheme.of(context)
                                                                              .titleSmall
                                                                              .fontStyle,
                                                                        ),
                                                                    elevation:
                                                                        0.0,
                                                                    borderSide:
                                                                        BorderSide(
                                                                      color: FlutterFlowTheme.of(
                                                                              context)
                                                                          .primaryD3,
                                                                      width:
                                                                          1.0,
                                                                    ),
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .only(
                                                                      topLeft: Radius
                                                                          .circular(
                                                                              100.0),
                                                                      topRight:
                                                                          Radius.circular(
                                                                              100.0),
                                                                      bottomLeft:
                                                                          Radius.circular(
                                                                              100.0),
                                                                      bottomRight:
                                                                          Radius.circular(
                                                                              100.0),
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
                                                                    HapticFeedback
                                                                        .lightImpact();
                                                                  },
                                                                  text: 'Admin',
                                                                  options:
                                                                      FFButtonOptions(
                                                                    height:
                                                                        24.0,
                                                                    padding: EdgeInsetsDirectional
                                                                        .fromSTEB(
                                                                            12.0,
                                                                            0.0,
                                                                            12.0,
                                                                            0.0),
                                                                    iconPadding:
                                                                        EdgeInsetsDirectional.fromSTEB(
                                                                            0.0,
                                                                            0.0,
                                                                            0.0,
                                                                            0.0),
                                                                    color: FlutterFlowTheme.of(
                                                                            context)
                                                                        .primary,
                                                                    textStyle: FlutterFlowTheme.of(
                                                                            context)
                                                                        .titleSmall
                                                                        .override(
                                                                          font:
                                                                              GoogleFonts.manrope(
                                                                            fontWeight:
                                                                                FlutterFlowTheme.of(context).titleSmall.fontWeight,
                                                                            fontStyle:
                                                                                FlutterFlowTheme.of(context).titleSmall.fontStyle,
                                                                          ),
                                                                          color:
                                                                              Colors.white,
                                                                          fontSize:
                                                                              12.0,
                                                                          letterSpacing:
                                                                              0.0,
                                                                          fontWeight: FlutterFlowTheme.of(context)
                                                                              .titleSmall
                                                                              .fontWeight,
                                                                          fontStyle: FlutterFlowTheme.of(context)
                                                                              .titleSmall
                                                                              .fontStyle,
                                                                        ),
                                                                    elevation:
                                                                        0.0,
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .only(
                                                                      topLeft: Radius
                                                                          .circular(
                                                                              100.0),
                                                                      topRight:
                                                                          Radius.circular(
                                                                              100.0),
                                                                      bottomLeft:
                                                                          Radius.circular(
                                                                              100.0),
                                                                      bottomRight:
                                                                          Radius.circular(
                                                                              100.0),
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
                                                                    HapticFeedback
                                                                        .lightImpact();
                                                                    await GroupMembersTable()
                                                                        .insert({
                                                                      'community_id':
                                                                          FFAppState()
                                                                              .communityId,
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
                                                                      'joined_at': supaSerialize<
                                                                              DateTime>(
                                                                          functions
                                                                              .getCurrentUtcTime()),
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
                                                                    _model.apiResultd2ppCopyCopy =
                                                                        await UpdateTotalGroupMembersCall
                                                                            .call(
                                                                      token:
                                                                          currentJwtToken,
                                                                      anonKey:
                                                                          FFDevEnvironmentValues()
                                                                              .AnonKey,
                                                                      groupId:
                                                                          getJsonField(
                                                                        gropsItem,
                                                                        r'''$.group_id''',
                                                                      ).toString(),
                                                                    );

                                                                    safeSetState(
                                                                        () {});
                                                                  },
                                                                  text: 'Join',
                                                                  options:
                                                                      FFButtonOptions(
                                                                    height:
                                                                        24.0,
                                                                    padding: EdgeInsetsDirectional
                                                                        .fromSTEB(
                                                                            16.0,
                                                                            0.0,
                                                                            16.0,
                                                                            0.0),
                                                                    iconPadding:
                                                                        EdgeInsetsDirectional.fromSTEB(
                                                                            0.0,
                                                                            0.0,
                                                                            0.0,
                                                                            0.0),
                                                                    color: Colors
                                                                        .transparent,
                                                                    textStyle: FlutterFlowTheme.of(
                                                                            context)
                                                                        .titleSmall
                                                                        .override(
                                                                          font:
                                                                              GoogleFonts.manrope(
                                                                            fontWeight:
                                                                                FlutterFlowTheme.of(context).titleSmall.fontWeight,
                                                                            fontStyle:
                                                                                FlutterFlowTheme.of(context).titleSmall.fontStyle,
                                                                          ),
                                                                          color:
                                                                              FlutterFlowTheme.of(context).primaryD3,
                                                                          fontSize:
                                                                              12.0,
                                                                          letterSpacing:
                                                                              0.0,
                                                                          fontWeight: FlutterFlowTheme.of(context)
                                                                              .titleSmall
                                                                              .fontWeight,
                                                                          fontStyle: FlutterFlowTheme.of(context)
                                                                              .titleSmall
                                                                              .fontStyle,
                                                                        ),
                                                                    elevation:
                                                                        0.0,
                                                                    borderSide:
                                                                        BorderSide(
                                                                      color: FlutterFlowTheme.of(
                                                                              context)
                                                                          .primaryD3,
                                                                      width:
                                                                          1.0,
                                                                    ),
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .only(
                                                                      topLeft: Radius
                                                                          .circular(
                                                                              100.0),
                                                                      topRight:
                                                                          Radius.circular(
                                                                              100.0),
                                                                      bottomLeft:
                                                                          Radius.circular(
                                                                              100.0),
                                                                      bottomRight:
                                                                          Radius.circular(
                                                                              100.0),
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
                                                                  icon: Icon(
                                                                    Icons
                                                                        .lock_outline_sharp,
                                                                    size: 15.0,
                                                                  ),
                                                                  options:
                                                                      FFButtonOptions(
                                                                    height:
                                                                        24.0,
                                                                    padding: EdgeInsetsDirectional
                                                                        .fromSTEB(
                                                                            16.0,
                                                                            0.0,
                                                                            16.0,
                                                                            0.0),
                                                                    iconPadding:
                                                                        EdgeInsetsDirectional.fromSTEB(
                                                                            0.0,
                                                                            0.0,
                                                                            0.0,
                                                                            0.0),
                                                                    iconColor: FlutterFlowTheme.of(
                                                                            context)
                                                                        .primaryD3,
                                                                    color: Colors
                                                                        .transparent,
                                                                    textStyle: FlutterFlowTheme.of(
                                                                            context)
                                                                        .titleSmall
                                                                        .override(
                                                                          font:
                                                                              GoogleFonts.manrope(
                                                                            fontWeight:
                                                                                FlutterFlowTheme.of(context).titleSmall.fontWeight,
                                                                            fontStyle:
                                                                                FlutterFlowTheme.of(context).titleSmall.fontStyle,
                                                                          ),
                                                                          color:
                                                                              FlutterFlowTheme.of(context).primaryD3,
                                                                          fontSize:
                                                                              12.0,
                                                                          letterSpacing:
                                                                              0.0,
                                                                          fontWeight: FlutterFlowTheme.of(context)
                                                                              .titleSmall
                                                                              .fontWeight,
                                                                          fontStyle: FlutterFlowTheme.of(context)
                                                                              .titleSmall
                                                                              .fontStyle,
                                                                        ),
                                                                    elevation:
                                                                        0.0,
                                                                    borderSide:
                                                                        BorderSide(
                                                                      color: FlutterFlowTheme.of(
                                                                              context)
                                                                          .primaryD3,
                                                                      width:
                                                                          1.0,
                                                                    ),
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .only(
                                                                      topLeft: Radius
                                                                          .circular(
                                                                              100.0),
                                                                      topRight:
                                                                          Radius.circular(
                                                                              100.0),
                                                                      bottomLeft:
                                                                          Radius.circular(
                                                                              100.0),
                                                                      bottomRight:
                                                                          Radius.circular(
                                                                              100.0),
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
                                              ),
                                            ),
                                          )
                                              .animate()
                                              .fadeIn(
                                                  duration: 260.ms,
                                                  delay: (40 * (gropsIndex % 8))
                                                      .ms)
                                              .slideY(
                                                  begin: 0.06,
                                                  end: 0,
                                                  curve: Curves.easeOutCubic);
                                        },
                                      );
                                    },
                                  ),
                                ),
                              ),
                            if (('${getJsonField(
                                      FFAppState().AsGroupList,
                                      r'''$''',
                                    ).toString()}' !=
                                    '[]') &&
                                _model.showListView &&
                                (_model.currentBtn == 'joined'))
                              Expanded(
                                child: Align(
                                  alignment: AlignmentDirectional(0.0, -1.0),
                                  child: Builder(
                                    builder: (context) {
                                      final grops = getJsonField(
                                        FFAppState().AsGroupList,
                                        r'''$''',
                                      ).toList();
                                      if (grops.isEmpty) {
                                        return CompNoGroupsAvailableWidget();
                                      }

                                      return ListView.builder(
                                        physics:
                                            const AlwaysScrollableScrollPhysics(),
                                        padding: EdgeInsets.fromLTRB(
                                          0,
                                          12.0,
                                          0,
                                          12.0,
                                        ),
                                        shrinkWrap: true,
                                        scrollDirection: Axis.vertical,
                                        itemCount: grops.length,
                                        itemBuilder: (context, gropsIndex) {
                                          final gropsItem = grops[gropsIndex];
                                          return Visibility(
                                            visible: ('${getJsonField(
                                                      gropsItem,
                                                      r'''$.user_status''',
                                                    ).toString()}' ==
                                                    'joined') &&
                                                (('${getJsonField(
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
                                                            'requested'))),
                                            child: Padding(
                                              padding: EdgeInsetsDirectional
                                                  .fromSTEB(
                                                      0.0, 0.0, 0.0, 12.0),
                                              child: Semantics(
                                                button: true,
                                                label: 'Open group',
                                                child: InkWell(
                                                  splashColor:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .primary
                                                          .withAlpha(0x14),
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
                                                    constraints: BoxConstraints(
                                                        minHeight: 56.0),
                                                    decoration: BoxDecoration(
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
                                                            MainAxisSize.max,
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
                                                                AppNetworkImage(
                                                                  url: getJsonField(
                                                                          gropsItem,
                                                                          r'''$.profile_picture''')
                                                                      .toString(),
                                                                  width: 40.0,
                                                                  height: 40.0,
                                                                  fit: BoxFit
                                                                      .cover,
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              2.0),
                                                                  semanticLabel:
                                                                      'Group cover photo',
                                                                ),
                                                                Expanded(
                                                                  child: Column(
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .max,
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      if ('${getJsonField(
                                                                            gropsItem,
                                                                            r'''$.invited_by_user_id''',
                                                                          ).toString()}' !=
                                                                          'null')
                                                                        Row(
                                                                          mainAxisSize:
                                                                              MainAxisSize.max,
                                                                          children:
                                                                              [
                                                                            AppNetworkImage(
                                                                              url: getJsonField(gropsItem, r'''$.invited_by_profile_picture''').toString(),
                                                                              width: 12.0,
                                                                              height: 12.0,
                                                                              fit: BoxFit.cover,
                                                                              isAvatar: true,
                                                                              semanticLabel: 'Inviter profile photo',
                                                                            ),
                                                                            Expanded(
                                                                              child: Text(
                                                                                '${getJsonField(
                                                                                  gropsItem,
                                                                                  r'''$.invited_by_name''',
                                                                                ).toString()} invited you to join this group',
                                                                                maxLines: 1,
                                                                                style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                      font: GoogleFonts.manrope(
                                                                                        fontWeight: FontWeight.w500,
                                                                                        fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                      ),
                                                                                      color: FlutterFlowTheme.of(context).greyL4,
                                                                                      fontSize: 12.0,
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
                                                                        style: FlutterFlowTheme.of(context)
                                                                            .bodyMedium
                                                                            .override(
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
                                                                            r'''$.invited_by_user_id''',
                                                                          ).toString()}' ==
                                                                          'null')
                                                                        Text(
                                                                          '${getJsonField(
                                                                            gropsItem,
                                                                            r'''$.total_members''',
                                                                          ).toString()} ${'${getJsonField(
                                                                                gropsItem,
                                                                                r'''$.total_members''',
                                                                              ).toString()}' == '1' ? 'member' : 'members'}',
                                                                          style: FlutterFlowTheme.of(context)
                                                                              .bodyMedium
                                                                              .override(
                                                                                font: GoogleFonts.manrope(
                                                                                  fontWeight: FontWeight.w500,
                                                                                  fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                ),
                                                                                color: FlutterFlowTheme.of(context).greyL4,
                                                                                fontSize: 12.0,
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
                                                                  width: 8.0)),
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
                                                                    HapticFeedback
                                                                        .lightImpact();
                                                                    await GroupMembersTable()
                                                                        .insert({
                                                                      'community_id':
                                                                          FFAppState()
                                                                              .communityId,
                                                                      'user_id':
                                                                          currentUserUid,
                                                                      'group_id':
                                                                          getJsonField(
                                                                        gropsItem,
                                                                        r'''$.group_id''',
                                                                      ).toString(),
                                                                      'is_requested':
                                                                          false,
                                                                      'requested_date': supaSerialize<
                                                                              DateTime>(
                                                                          functions
                                                                              .getCurrentUtcTime()),
                                                                      'is_approved':
                                                                          true,
                                                                      'approved_by':
                                                                          currentUserUid,
                                                                      'joined_at': supaSerialize<
                                                                              DateTime>(
                                                                          functions
                                                                              .getCurrentUtcTime()),
                                                                    });
                                                                    await GroupUserStatusTable()
                                                                        .insert({
                                                                      'community_id':
                                                                          FFAppState()
                                                                              .communityId,
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
                                                                      'joined_at': supaSerialize<
                                                                              DateTime>(
                                                                          functions
                                                                              .getCurrentUtcTime()),
                                                                    });
                                                                    _model.apiResultd2p =
                                                                        await UpdateTotalGroupMembersCall
                                                                            .call(
                                                                      token:
                                                                          currentJwtToken,
                                                                      anonKey:
                                                                          FFDevEnvironmentValues()
                                                                              .AnonKey,
                                                                      groupId:
                                                                          getJsonField(
                                                                        gropsItem,
                                                                        r'''$.group_id''',
                                                                      ).toString(),
                                                                    );

                                                                    safeSetState(
                                                                        () {});
                                                                  },
                                                                  text: 'Join',
                                                                  options:
                                                                      FFButtonOptions(
                                                                    height:
                                                                        24.0,
                                                                    padding: EdgeInsetsDirectional
                                                                        .fromSTEB(
                                                                            16.0,
                                                                            0.0,
                                                                            16.0,
                                                                            0.0),
                                                                    iconPadding:
                                                                        EdgeInsetsDirectional.fromSTEB(
                                                                            0.0,
                                                                            0.0,
                                                                            0.0,
                                                                            0.0),
                                                                    color: Colors
                                                                        .transparent,
                                                                    textStyle: FlutterFlowTheme.of(
                                                                            context)
                                                                        .titleSmall
                                                                        .override(
                                                                          font:
                                                                              GoogleFonts.manrope(
                                                                            fontWeight:
                                                                                FlutterFlowTheme.of(context).titleSmall.fontWeight,
                                                                            fontStyle:
                                                                                FlutterFlowTheme.of(context).titleSmall.fontStyle,
                                                                          ),
                                                                          color:
                                                                              FlutterFlowTheme.of(context).primaryD3,
                                                                          fontSize:
                                                                              12.0,
                                                                          letterSpacing:
                                                                              0.0,
                                                                          fontWeight: FlutterFlowTheme.of(context)
                                                                              .titleSmall
                                                                              .fontWeight,
                                                                          fontStyle: FlutterFlowTheme.of(context)
                                                                              .titleSmall
                                                                              .fontStyle,
                                                                        ),
                                                                    elevation:
                                                                        0.0,
                                                                    borderSide:
                                                                        BorderSide(
                                                                      color: FlutterFlowTheme.of(
                                                                              context)
                                                                          .primaryD3,
                                                                      width:
                                                                          1.0,
                                                                    ),
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .only(
                                                                      topLeft: Radius
                                                                          .circular(
                                                                              100.0),
                                                                      topRight:
                                                                          Radius.circular(
                                                                              100.0),
                                                                      bottomLeft:
                                                                          Radius.circular(
                                                                              100.0),
                                                                      bottomRight:
                                                                          Radius.circular(
                                                                              100.0),
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
                                                                      () {},
                                                                  text:
                                                                      'Joined',
                                                                  icon: Icon(
                                                                    Icons
                                                                        .done_all,
                                                                    size: 15.0,
                                                                  ),
                                                                  options:
                                                                      FFButtonOptions(
                                                                    height:
                                                                        24.0,
                                                                    padding: EdgeInsetsDirectional
                                                                        .fromSTEB(
                                                                            16.0,
                                                                            0.0,
                                                                            16.0,
                                                                            0.0),
                                                                    iconPadding:
                                                                        EdgeInsetsDirectional.fromSTEB(
                                                                            0.0,
                                                                            0.0,
                                                                            0.0,
                                                                            0.0),
                                                                    iconColor: FlutterFlowTheme.of(
                                                                            context)
                                                                        .greyL4,
                                                                    color: Colors
                                                                        .transparent,
                                                                    textStyle: FlutterFlowTheme.of(
                                                                            context)
                                                                        .titleSmall
                                                                        .override(
                                                                          font:
                                                                              GoogleFonts.manrope(
                                                                            fontWeight:
                                                                                FlutterFlowTheme.of(context).titleSmall.fontWeight,
                                                                            fontStyle:
                                                                                FlutterFlowTheme.of(context).titleSmall.fontStyle,
                                                                          ),
                                                                          color:
                                                                              FlutterFlowTheme.of(context).greyL4,
                                                                          fontSize:
                                                                              12.0,
                                                                          letterSpacing:
                                                                              0.0,
                                                                          fontWeight: FlutterFlowTheme.of(context)
                                                                              .titleSmall
                                                                              .fontWeight,
                                                                          fontStyle: FlutterFlowTheme.of(context)
                                                                              .titleSmall
                                                                              .fontStyle,
                                                                        ),
                                                                    elevation:
                                                                        0.0,
                                                                    borderSide:
                                                                        BorderSide(
                                                                      color: FlutterFlowTheme.of(
                                                                              context)
                                                                          .greyL4,
                                                                      width:
                                                                          1.0,
                                                                    ),
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .only(
                                                                      topLeft: Radius
                                                                          .circular(
                                                                              100.0),
                                                                      topRight:
                                                                          Radius.circular(
                                                                              100.0),
                                                                      bottomLeft:
                                                                          Radius.circular(
                                                                              100.0),
                                                                      bottomRight:
                                                                          Radius.circular(
                                                                              100.0),
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
                                                                    HapticFeedback
                                                                        .lightImpact();
                                                                  },
                                                                  text:
                                                                      'Requested',
                                                                  options:
                                                                      FFButtonOptions(
                                                                    height:
                                                                        24.0,
                                                                    padding: EdgeInsetsDirectional
                                                                        .fromSTEB(
                                                                            16.0,
                                                                            0.0,
                                                                            16.0,
                                                                            0.0),
                                                                    iconPadding:
                                                                        EdgeInsetsDirectional.fromSTEB(
                                                                            0.0,
                                                                            0.0,
                                                                            0.0,
                                                                            0.0),
                                                                    color: FlutterFlowTheme.of(
                                                                            context)
                                                                        .greyL2,
                                                                    textStyle: FlutterFlowTheme.of(
                                                                            context)
                                                                        .titleSmall
                                                                        .override(
                                                                          font:
                                                                              GoogleFonts.manrope(
                                                                            fontWeight:
                                                                                FlutterFlowTheme.of(context).titleSmall.fontWeight,
                                                                            fontStyle:
                                                                                FlutterFlowTheme.of(context).titleSmall.fontStyle,
                                                                          ),
                                                                          color:
                                                                              FlutterFlowTheme.of(context).greyL3,
                                                                          fontSize:
                                                                              12.0,
                                                                          letterSpacing:
                                                                              0.0,
                                                                          fontWeight: FlutterFlowTheme.of(context)
                                                                              .titleSmall
                                                                              .fontWeight,
                                                                          fontStyle: FlutterFlowTheme.of(context)
                                                                              .titleSmall
                                                                              .fontStyle,
                                                                        ),
                                                                    elevation:
                                                                        0.0,
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .only(
                                                                      topLeft: Radius
                                                                          .circular(
                                                                              100.0),
                                                                      topRight:
                                                                          Radius.circular(
                                                                              100.0),
                                                                      bottomLeft:
                                                                          Radius.circular(
                                                                              100.0),
                                                                      bottomRight:
                                                                          Radius.circular(
                                                                              100.0),
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
                                                                          FFAppState()
                                                                              .communityId,
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
                                                                      'requested_date': supaSerialize<
                                                                              DateTime>(
                                                                          functions
                                                                              .getCurrentUtcTime()),
                                                                    });
                                                                  },
                                                                  text:
                                                                      'Request',
                                                                  icon: Icon(
                                                                    Icons
                                                                        .lock_outline_sharp,
                                                                    size: 15.0,
                                                                  ),
                                                                  options:
                                                                      FFButtonOptions(
                                                                    height:
                                                                        24.0,
                                                                    padding: EdgeInsetsDirectional
                                                                        .fromSTEB(
                                                                            16.0,
                                                                            0.0,
                                                                            16.0,
                                                                            0.0),
                                                                    iconPadding:
                                                                        EdgeInsetsDirectional.fromSTEB(
                                                                            0.0,
                                                                            0.0,
                                                                            0.0,
                                                                            0.0),
                                                                    iconColor: FlutterFlowTheme.of(
                                                                            context)
                                                                        .primaryD3,
                                                                    color: Colors
                                                                        .transparent,
                                                                    textStyle: FlutterFlowTheme.of(
                                                                            context)
                                                                        .titleSmall
                                                                        .override(
                                                                          font:
                                                                              GoogleFonts.manrope(
                                                                            fontWeight:
                                                                                FlutterFlowTheme.of(context).titleSmall.fontWeight,
                                                                            fontStyle:
                                                                                FlutterFlowTheme.of(context).titleSmall.fontStyle,
                                                                          ),
                                                                          color:
                                                                              FlutterFlowTheme.of(context).primaryD3,
                                                                          fontSize:
                                                                              12.0,
                                                                          letterSpacing:
                                                                              0.0,
                                                                          fontWeight: FlutterFlowTheme.of(context)
                                                                              .titleSmall
                                                                              .fontWeight,
                                                                          fontStyle: FlutterFlowTheme.of(context)
                                                                              .titleSmall
                                                                              .fontStyle,
                                                                        ),
                                                                    elevation:
                                                                        0.0,
                                                                    borderSide:
                                                                        BorderSide(
                                                                      color: FlutterFlowTheme.of(
                                                                              context)
                                                                          .primaryD3,
                                                                      width:
                                                                          1.0,
                                                                    ),
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .only(
                                                                      topLeft: Radius
                                                                          .circular(
                                                                              100.0),
                                                                      topRight:
                                                                          Radius.circular(
                                                                              100.0),
                                                                      bottomLeft:
                                                                          Radius.circular(
                                                                              100.0),
                                                                      bottomRight:
                                                                          Radius.circular(
                                                                              100.0),
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
                                                                    HapticFeedback
                                                                        .lightImpact();
                                                                  },
                                                                  text: 'Admin',
                                                                  options:
                                                                      FFButtonOptions(
                                                                    height:
                                                                        24.0,
                                                                    padding: EdgeInsetsDirectional
                                                                        .fromSTEB(
                                                                            12.0,
                                                                            0.0,
                                                                            12.0,
                                                                            0.0),
                                                                    iconPadding:
                                                                        EdgeInsetsDirectional.fromSTEB(
                                                                            0.0,
                                                                            0.0,
                                                                            0.0,
                                                                            0.0),
                                                                    color: FlutterFlowTheme.of(
                                                                            context)
                                                                        .primary,
                                                                    textStyle: FlutterFlowTheme.of(
                                                                            context)
                                                                        .titleSmall
                                                                        .override(
                                                                          font:
                                                                              GoogleFonts.manrope(
                                                                            fontWeight:
                                                                                FlutterFlowTheme.of(context).titleSmall.fontWeight,
                                                                            fontStyle:
                                                                                FlutterFlowTheme.of(context).titleSmall.fontStyle,
                                                                          ),
                                                                          color:
                                                                              Colors.white,
                                                                          fontSize:
                                                                              12.0,
                                                                          letterSpacing:
                                                                              0.0,
                                                                          fontWeight: FlutterFlowTheme.of(context)
                                                                              .titleSmall
                                                                              .fontWeight,
                                                                          fontStyle: FlutterFlowTheme.of(context)
                                                                              .titleSmall
                                                                              .fontStyle,
                                                                        ),
                                                                    elevation:
                                                                        0.0,
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .only(
                                                                      topLeft: Radius
                                                                          .circular(
                                                                              100.0),
                                                                      topRight:
                                                                          Radius.circular(
                                                                              100.0),
                                                                      bottomLeft:
                                                                          Radius.circular(
                                                                              100.0),
                                                                      bottomRight:
                                                                          Radius.circular(
                                                                              100.0),
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
                                                                    HapticFeedback
                                                                        .lightImpact();
                                                                    await GroupMembersTable()
                                                                        .insert({
                                                                      'community_id':
                                                                          FFAppState()
                                                                              .communityId,
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
                                                                      'joined_at': supaSerialize<
                                                                              DateTime>(
                                                                          functions
                                                                              .getCurrentUtcTime()),
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
                                                                        await UpdateTotalGroupMembersCall
                                                                            .call(
                                                                      token:
                                                                          currentJwtToken,
                                                                      anonKey:
                                                                          FFDevEnvironmentValues()
                                                                              .AnonKey,
                                                                      groupId:
                                                                          getJsonField(
                                                                        gropsItem,
                                                                        r'''$.group_id''',
                                                                      ).toString(),
                                                                    );

                                                                    safeSetState(
                                                                        () {});
                                                                  },
                                                                  text: 'Join',
                                                                  options:
                                                                      FFButtonOptions(
                                                                    height:
                                                                        24.0,
                                                                    padding: EdgeInsetsDirectional
                                                                        .fromSTEB(
                                                                            16.0,
                                                                            0.0,
                                                                            16.0,
                                                                            0.0),
                                                                    iconPadding:
                                                                        EdgeInsetsDirectional.fromSTEB(
                                                                            0.0,
                                                                            0.0,
                                                                            0.0,
                                                                            0.0),
                                                                    color: Colors
                                                                        .transparent,
                                                                    textStyle: FlutterFlowTheme.of(
                                                                            context)
                                                                        .titleSmall
                                                                        .override(
                                                                          font:
                                                                              GoogleFonts.manrope(
                                                                            fontWeight:
                                                                                FlutterFlowTheme.of(context).titleSmall.fontWeight,
                                                                            fontStyle:
                                                                                FlutterFlowTheme.of(context).titleSmall.fontStyle,
                                                                          ),
                                                                          color:
                                                                              FlutterFlowTheme.of(context).primaryD3,
                                                                          fontSize:
                                                                              12.0,
                                                                          letterSpacing:
                                                                              0.0,
                                                                          fontWeight: FlutterFlowTheme.of(context)
                                                                              .titleSmall
                                                                              .fontWeight,
                                                                          fontStyle: FlutterFlowTheme.of(context)
                                                                              .titleSmall
                                                                              .fontStyle,
                                                                        ),
                                                                    elevation:
                                                                        0.0,
                                                                    borderSide:
                                                                        BorderSide(
                                                                      color: FlutterFlowTheme.of(
                                                                              context)
                                                                          .primaryD3,
                                                                      width:
                                                                          1.0,
                                                                    ),
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .only(
                                                                      topLeft: Radius
                                                                          .circular(
                                                                              100.0),
                                                                      topRight:
                                                                          Radius.circular(
                                                                              100.0),
                                                                      bottomLeft:
                                                                          Radius.circular(
                                                                              100.0),
                                                                      bottomRight:
                                                                          Radius.circular(
                                                                              100.0),
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
                                                                  icon: Icon(
                                                                    Icons
                                                                        .lock_outline_sharp,
                                                                    size: 15.0,
                                                                  ),
                                                                  options:
                                                                      FFButtonOptions(
                                                                    height:
                                                                        24.0,
                                                                    padding: EdgeInsetsDirectional
                                                                        .fromSTEB(
                                                                            16.0,
                                                                            0.0,
                                                                            16.0,
                                                                            0.0),
                                                                    iconPadding:
                                                                        EdgeInsetsDirectional.fromSTEB(
                                                                            0.0,
                                                                            0.0,
                                                                            0.0,
                                                                            0.0),
                                                                    iconColor: FlutterFlowTheme.of(
                                                                            context)
                                                                        .primaryD3,
                                                                    color: Colors
                                                                        .transparent,
                                                                    textStyle: FlutterFlowTheme.of(
                                                                            context)
                                                                        .titleSmall
                                                                        .override(
                                                                          font:
                                                                              GoogleFonts.manrope(
                                                                            fontWeight:
                                                                                FlutterFlowTheme.of(context).titleSmall.fontWeight,
                                                                            fontStyle:
                                                                                FlutterFlowTheme.of(context).titleSmall.fontStyle,
                                                                          ),
                                                                          color:
                                                                              FlutterFlowTheme.of(context).primaryD3,
                                                                          fontSize:
                                                                              12.0,
                                                                          letterSpacing:
                                                                              0.0,
                                                                          fontWeight: FlutterFlowTheme.of(context)
                                                                              .titleSmall
                                                                              .fontWeight,
                                                                          fontStyle: FlutterFlowTheme.of(context)
                                                                              .titleSmall
                                                                              .fontStyle,
                                                                        ),
                                                                    elevation:
                                                                        0.0,
                                                                    borderSide:
                                                                        BorderSide(
                                                                      color: FlutterFlowTheme.of(
                                                                              context)
                                                                          .primaryD3,
                                                                      width:
                                                                          1.0,
                                                                    ),
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .only(
                                                                      topLeft: Radius
                                                                          .circular(
                                                                              100.0),
                                                                      topRight:
                                                                          Radius.circular(
                                                                              100.0),
                                                                      bottomLeft:
                                                                          Radius.circular(
                                                                              100.0),
                                                                      bottomRight:
                                                                          Radius.circular(
                                                                              100.0),
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
                                              ),
                                            ),
                                          )
                                              .animate()
                                              .fadeIn(
                                                  duration: 260.ms,
                                                  delay: (40 * (gropsIndex % 8))
                                                      .ms)
                                              .slideY(
                                                  begin: 0.06,
                                                  end: 0,
                                                  curve: Curves.easeOutCubic);
                                        },
                                      );
                                    },
                                  ),
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
          ),
        ),
      ),
    );
  }
}
