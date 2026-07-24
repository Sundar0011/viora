import '/pages/group/group_list_refresh.dart';
import '/components/empty_state.dart';
import '/components/app_shimmer_box.dart';
import '/components/app_icon_button.dart';
import '/components/app_network_image.dart';
import '/auth/supabase_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/backend/supabase/supabase.dart';
import '/components/comp_pageview_widget.dart';
import '/components/comp_share_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/pages/group/comp_assign_admin/comp_assign_admin_widget.dart';
import '/pages/group/comp_group_1/comp_group1_widget.dart';
import '/pages/group/comp_group_2/comp_group2_widget.dart';
import '/pages/group/comp_group_members/comp_group_members_widget.dart';
import '/pages/group/comp_invite_friends/comp_invite_friends_widget.dart';
import '/pages/group/comp_joining_request/comp_joining_request_widget.dart';
import '/pages/group/comp_private_group_members/comp_private_group_members_widget.dart';
import '/pages/group/comp_revoke_admin/comp_revoke_admin_widget.dart';
import '/pages/home/comp_likes/comp_likes_widget.dart';
import '/pages/home/comp_loading/comp_loading_widget.dart';
import '/pages/home/comp_report_post/comp_report_post_widget.dart';
import '/pages/home/comp_three_dot_edit_post/comp_three_dot_edit_post_widget.dart';
import 'dart:ui';
import '/custom_code/actions/index.dart' as actions;
import '/custom_code/widgets/index.dart' as custom_widgets;
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/scheduler.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'group_details_model.dart';
export 'group_details_model.dart';

class GroupDetailsWidget extends StatefulWidget {
  const GroupDetailsWidget({
    super.key,
    required this.groupId,
  });

  final String? groupId;

  static String routeName = 'GroupDetails';
  static String routePath = 'groupDetails';

  @override
  State<GroupDetailsWidget> createState() => _GroupDetailsWidgetState();
}

class _GroupDetailsWidgetState extends State<GroupDetailsWidget> {
  late GroupDetailsModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => GroupDetailsModel());

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      await actions.fetchSpecificGroupWithStatusRealtime(
        widget!.groupId!,
      );
      _model.loader = false;
      safeSetState(() {});
    });
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  /// Content-shaped shimmer shown while the group loads, so the screen never
  /// renders as a frozen blank frame (ui-review 2026-07-21 §2.7).
  Widget _buildLoadingSkeleton(BuildContext context) {
    final FFSpacing spacing = FlutterFlowTheme.of(context).designToken.spacing;
    return Semantics(
      label: 'Loading group',
      liveRegion: true,
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        children: [
          const AppShimmerBox(width: double.infinity, height: 240.0),
          Padding(
            padding: EdgeInsets.all(spacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const AppShimmerLine(widthFactor: 0.6, height: 22.0),
                SizedBox(height: spacing.sm),
                const AppShimmerLine(widthFactor: 0.35, height: 14.0),
                SizedBox(height: spacing.md),
                const AppShimmerLine(widthFactor: 1.0, height: 44.0),
                SizedBox(height: spacing.lg),
                const AppShimmerLine(widthFactor: 0.9, height: 14.0),
                SizedBox(height: spacing.sm),
                const AppShimmerLine(widthFactor: 0.75, height: 14.0),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Retries the group fetch after a failure, re-running the loading gate.
  Future<void> _reloadGroupDetails() async {
    safeSetState(() => _model.loader = true);
    try {
      await refreshGroupDetails(widget!.groupId!);
    } catch (_) {
      // Already logged in the data layer; the error state below stays visible.
    } finally {
      if (mounted) {
        safeSetState(() => _model.loader = false);
      }
    }
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
          child: InkWell(
            splashColor: FlutterFlowTheme.of(context).primary.withAlpha(0x14),
            focusColor: Colors.transparent,
            hoverColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onTap: () async {
              _model.reportPostId = ' ';
              safeSetState(() {});
            },
            child: Container(
              decoration: BoxDecoration(
                color: FlutterFlowTheme.of(context).pageBack,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  if (!_model.loader &&
                      (FFAppState().AsSpecificGroupDetails != null))
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(),
                        child: RefreshIndicator(
                          onRefresh: () async {
                            _model.post112 = await GetPostCall.call(
                              anonKey: FFDevEnvironmentValues().AnonKey,
                              token: currentJwtToken,
                            );

                            FFAppState().AsPost = getJsonField(
                              (_model.post112?.jsonBody ?? ''),
                              r'''$''',
                            );
                            safeSetState(() {});
                            safeSetState(() {});
                          },
                          child: SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color: FlutterFlowTheme.of(context).white,
                                  ),
                                  child: Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        0.0, 12.0, 0.0, 12.0),
                                    child: Row(
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
                                                  FlutterFlowTheme.of(context)
                                                      .extraBlack,
                                              size: 24.0,
                                            ),
                                            onPressed: () async {
                                              context.safePop();
                                            },
                                          ),
                                        ),
                                        Expanded(
                                          child: InkWell(
                                            splashColor:
                                                FlutterFlowTheme.of(context)
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
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .alternate,
                                                borderRadius:
                                                    BorderRadius.circular(4.0),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.max,
                                                children: [
                                                  Icon(
                                                    Icons.search,
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .greyL4,
                                                    size: 20.0,
                                                  ),
                                                  Text(
                                                    'Search',
                                                    style: FlutterFlowTheme.of(
                                                            context)
                                                        .bodyMedium
                                                        .override(
                                                          font: GoogleFonts
                                                              .manrope(
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            fontStyle:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .fontStyle,
                                                          ),
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .greyL4,
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMedium
                                                                  .fontStyle,
                                                          lineHeight: 1.3,
                                                        ),
                                                  ),
                                                ]
                                                    .divide(
                                                        SizedBox(width: 12.0))
                                                    .addToStart(
                                                        SizedBox(width: 12.0))
                                                    .addToEnd(
                                                        SizedBox(width: 12.0)),
                                              ),
                                            ),
                                          ),
                                        ),
                                        if (('${getJsonField(
                                                  FFAppState()
                                                      .AsSpecificGroupDetails,
                                                  r'''$.e_group_type''',
                                                ).toString()}' ==
                                                'open') ||
                                            (('${getJsonField(
                                                      FFAppState()
                                                          .AsSpecificGroupDetails,
                                                      r'''$.user_status''',
                                                    ).toString()}' ==
                                                    'joined') ||
                                                ('${getJsonField(
                                                      FFAppState()
                                                          .AsSpecificGroupDetails,
                                                      r'''$.user_status''',
                                                    ).toString()}' ==
                                                    'admin')))
                                          AppIconButton(
                                            semanticLabel: 'Group options',
                                            iconSize: 16.0,
                                            onTap: () async {
                                              if (('${getJsonField(
                                                        FFAppState()
                                                            .AsSpecificGroupDetails,
                                                        r'''$.user_status''',
                                                      ).toString()}' ==
                                                      'joined') ||
                                                  ('${getJsonField(
                                                        FFAppState()
                                                            .AsSpecificGroupDetails,
                                                        r'''$.user_status''',
                                                      ).toString()}' ==
                                                      'admin')) {
                                                await showModalBottomSheet(
                                                  isScrollControlled: true,
                                                  backgroundColor:
                                                      Colors.transparent,
                                                  context: context,
                                                  builder: (context) {
                                                    return GestureDetector(
                                                      onTap: () {
                                                        FocusScope.of(context)
                                                            .unfocus();
                                                        FocusManager.instance
                                                            .primaryFocus
                                                            ?.unfocus();
                                                      },
                                                      child: Padding(
                                                        padding: MediaQuery
                                                            .viewInsetsOf(
                                                                context),
                                                        child: CompGroup1Widget(
                                                          groupId:
                                                              widget!.groupId!,
                                                          userStatus:
                                                              getJsonField(
                                                            FFAppState()
                                                                .AsSpecificGroupDetails,
                                                            r'''$.user_status''',
                                                          ).toString(),
                                                          userId: getJsonField(
                                                            FFAppState()
                                                                .AsSpecificGroupDetails,
                                                            r'''$.creator_id''',
                                                          ).toString(),
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ).then((value) =>
                                                    safeSetState(() {}));
                                              } else {
                                                await showModalBottomSheet(
                                                  isScrollControlled: true,
                                                  backgroundColor:
                                                      Colors.transparent,
                                                  context: context,
                                                  builder: (context) {
                                                    return GestureDetector(
                                                      onTap: () {
                                                        FocusScope.of(context)
                                                            .unfocus();
                                                        FocusManager.instance
                                                            .primaryFocus
                                                            ?.unfocus();
                                                      },
                                                      child: Padding(
                                                        padding: MediaQuery
                                                            .viewInsetsOf(
                                                                context),
                                                        child: CompGroup2Widget(
                                                          groupId:
                                                              widget!.groupId!,
                                                          userId: getJsonField(
                                                            FFAppState()
                                                                .AsSpecificGroupDetails,
                                                            r'''$.creator_id''',
                                                          ).toString(),
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ).then((value) =>
                                                    safeSetState(() {}));
                                              }
                                            },
                                            iconWidget: Container(
                                              width: 34.0,
                                              height: 34.0,
                                              decoration: BoxDecoration(
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .greyL2,
                                                borderRadius: BorderRadius.only(
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
                                              alignment: AlignmentDirectional(
                                                  0.0, 0.0),
                                              child: Transform.rotate(
                                                angle: 90.0 * (math.pi / 180),
                                                child: Icon(
                                                  Icons.keyboard_control,
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .primaryText,
                                                  size: 16.0,
                                                ),
                                              ),
                                            ),
                                          ),
                                      ]
                                          .divide(SizedBox(width: 10.0))
                                          .addToStart(SizedBox(width: 10.0))
                                          .addToEnd(SizedBox(width: 20.0)),
                                    ),
                                  ),
                                ),
                                Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: FlutterFlowTheme.of(context).white,
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      0.0, 4.0, 0.0, 0.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: FlutterFlowTheme.of(context).white,
                                    ),
                                    child: Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          0.0, 0.0, 0.0, 12.0),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          AppNetworkImage(
                                            url: getJsonField(
                                                    FFAppState()
                                                        .AsSpecificGroupDetails,
                                                    r'''$.profile_picture''')
                                                .toString(),
                                            width: double.infinity,
                                            height: 240.0,
                                            fit: BoxFit.cover,
                                            semanticLabel: 'Group cover photo',
                                          ),
                                          Padding(
                                            padding:
                                                EdgeInsetsDirectional.fromSTEB(
                                                    20.0, 0.0, 20.0, 0.0),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.max,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                if ('${getJsonField(
                                                      FFAppState()
                                                          .AsSpecificGroupDetails,
                                                      r'''$.user_status''',
                                                    ).toString()}' ==
                                                    'requested')
                                                  Row(
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    children: [
                                                      Icon(
                                                        Icons
                                                            .notifications_rounded,
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .greenColor2,
                                                        size: 24.0,
                                                      ),
                                                      Expanded(
                                                        child: Text(
                                                          'Notification about your request has been sent to the group admin(s) and you might hear from them soon.',
                                                          style: FlutterFlowTheme
                                                                  .of(context)
                                                              .bodyMedium
                                                              .override(
                                                                font: GoogleFonts
                                                                    .manrope(
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
                                                    ].divide(
                                                        SizedBox(width: 10.0)),
                                                  ),
                                                Text(
                                                  getJsonField(
                                                    FFAppState()
                                                        .AsSpecificGroupDetails,
                                                    r'''$.name''',
                                                  ).toString(),
                                                  style: FlutterFlowTheme.of(
                                                          context)
                                                      .bodyMedium
                                                      .override(
                                                        font:
                                                            GoogleFonts.manrope(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMedium
                                                                  .fontStyle,
                                                        ),
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .extraBlack,
                                                        fontSize: 24.0,
                                                        letterSpacing: 0.0,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyMedium
                                                                .fontStyle,
                                                        lineHeight: 1.4,
                                                      ),
                                                ),
                                                Row(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  children: [
                                                    Stack(
                                                      children: [
                                                        if ('${getJsonField(
                                                              FFAppState()
                                                                  .AsSpecificGroupDetails,
                                                              r'''$.e_group_type''',
                                                            ).toString()}' ==
                                                            'open')
                                                          Row(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .max,
                                                            children: [
                                                              ClipRRect(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            8.0),
                                                                child:
                                                                    Image.asset(
                                                                  'assets/images/public.png',
                                                                  width: 18.0,
                                                                  height: 18.0,
                                                                  fit: BoxFit
                                                                      .cover,
                                                                ),
                                                              ),
                                                              Text(
                                                                'Public group',
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
                                                                          .greyL4,
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
                                                            ].divide(SizedBox(
                                                                width: 4.0)),
                                                          ),
                                                        if ('${getJsonField(
                                                              FFAppState()
                                                                  .AsSpecificGroupDetails,
                                                              r'''$.e_group_type''',
                                                            ).toString()}' ==
                                                            'private')
                                                          Row(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .max,
                                                            children: [
                                                              Icon(
                                                                Icons
                                                                    .lock_outlined,
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .greyL4,
                                                                size: 18.0,
                                                              ),
                                                              Text(
                                                                'Private group',
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
                                                                          .greyL4,
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
                                                            ].divide(SizedBox(
                                                                width: 4.0)),
                                                          ),
                                                      ],
                                                    ),
                                                    Container(
                                                      width: 2.0,
                                                      height: 2.0,
                                                      decoration: BoxDecoration(
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .greyL4,
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
                                                        if (('${getJsonField(
                                                                  FFAppState()
                                                                      .AsSpecificGroupDetails,
                                                                  r'''$.user_status''',
                                                                ).toString()}' ==
                                                                'joined') ||
                                                            ('${getJsonField(
                                                                  FFAppState()
                                                                      .AsSpecificGroupDetails,
                                                                  r'''$.e_group_status''',
                                                                ).toString()}' ==
                                                                'open') ||
                                                            ('${getJsonField(
                                                                  FFAppState()
                                                                      .AsSpecificGroupDetails,
                                                                  r'''$.user_status''',
                                                                ).toString()}' ==
                                                                'admin')) {
                                                          await showModalBottomSheet(
                                                            isScrollControlled:
                                                                true,
                                                            backgroundColor:
                                                                Colors
                                                                    .transparent,
                                                            context: context,
                                                            builder: (context) {
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
                                                                child: Padding(
                                                                  padding: MediaQuery
                                                                      .viewInsetsOf(
                                                                          context),
                                                                  child:
                                                                      CompGroupMembersWidget(
                                                                    groupId: widget!
                                                                        .groupId!,
                                                                  ),
                                                                ),
                                                              );
                                                            },
                                                          ).then((value) =>
                                                              safeSetState(
                                                                  () {}));
                                                        } else {
                                                          await showModalBottomSheet(
                                                            isScrollControlled:
                                                                true,
                                                            backgroundColor:
                                                                Colors
                                                                    .transparent,
                                                            context: context,
                                                            builder: (context) {
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
                                                                child: Padding(
                                                                  padding: MediaQuery
                                                                      .viewInsetsOf(
                                                                          context),
                                                                  child:
                                                                      CompPrivateGroupMembersWidget(),
                                                                ),
                                                              );
                                                            },
                                                          ).then((value) =>
                                                              safeSetState(
                                                                  () {}));
                                                        }
                                                      },
                                                      child: Row(
                                                        mainAxisSize:
                                                            MainAxisSize.max,
                                                        children: [
                                                          Text(
                                                            getJsonField(
                                                              FFAppState()
                                                                  .AsSpecificGroupDetails,
                                                              r'''$.total_members''',
                                                            ).toString(),
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
                                                                      16.0,
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
                                                          Text(
                                                            '${getJsonField(
                                                                      FFAppState()
                                                                          .AsSpecificGroupDetails,
                                                                      r'''$.total_members''',
                                                                    ).toString()}' ==
                                                                    '0'
                                                                ? 'member'
                                                                : 'members',
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
                                                        ].divide(SizedBox(
                                                            width: 2.0)),
                                                      ),
                                                    ),
                                                  ].divide(
                                                      SizedBox(width: 4.0)),
                                                ),
                                                Column(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  children: [
                                                    if (_model.showMoreId !=
                                                        widget!.groupId)
                                                      Text(
                                                        getJsonField(
                                                          FFAppState()
                                                              .AsSpecificGroupDetails,
                                                          r'''$.description''',
                                                        )
                                                            .toString()
                                                            .maybeHandleOverflow(
                                                              maxChars: 170,
                                                              replacement: '…',
                                                            ),
                                                        textAlign:
                                                            TextAlign.justify,
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
                                                              color: FlutterFlowTheme
                                                                      .of(context)
                                                                  .greyL5,
                                                              fontSize: 16.0,
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
                                                    if (_model.showMoreId ==
                                                        widget!.groupId)
                                                      Text(
                                                        getJsonField(
                                                          FFAppState()
                                                              .AsSpecificGroupDetails,
                                                          r'''$.description''',
                                                        ).toString(),
                                                        textAlign:
                                                            TextAlign.justify,
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
                                                              color: FlutterFlowTheme
                                                                      .of(context)
                                                                  .greyL5,
                                                              fontSize: 16.0,
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
                                                    if (((getJsonField(
                                                                  FFAppState()
                                                                      .AsSpecificGroupDetails,
                                                                  r'''$.description''',
                                                                )
                                                                    .toString()
                                                                    .length >
                                                                171) ==
                                                            true) &&
                                                        (_model.showMoreId !=
                                                            widget!.groupId))
                                                      Align(
                                                        alignment:
                                                            AlignmentDirectional(
                                                                1.0, 0.0),
                                                        child: InkWell(
                                                          splashColor: Colors
                                                              .transparent,
                                                          focusColor: Colors
                                                              .transparent,
                                                          hoverColor: Colors
                                                              .transparent,
                                                          highlightColor: Colors
                                                              .transparent,
                                                          onTap: () async {
                                                            _model.showMoreId =
                                                                getJsonField(
                                                              FFAppState()
                                                                  .AsSpecificGroupDetails,
                                                              r'''$.group_id''',
                                                            ).toString();
                                                            safeSetState(() {});
                                                          },
                                                          child: Text(
                                                            'Read More',
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
                                                                  lineHeight:
                                                                      1.4,
                                                                ),
                                                          ),
                                                        ),
                                                      ),
                                                    if (((getJsonField(
                                                                  FFAppState()
                                                                      .AsSpecificGroupDetails,
                                                                  r'''$.description''',
                                                                )
                                                                    .toString()
                                                                    .length >
                                                                171) ==
                                                            true) &&
                                                        (_model.showMoreId ==
                                                            widget!.groupId))
                                                      Align(
                                                        alignment:
                                                            AlignmentDirectional(
                                                                1.0, 0.0),
                                                        child: InkWell(
                                                          splashColor: Colors
                                                              .transparent,
                                                          focusColor: Colors
                                                              .transparent,
                                                          hoverColor: Colors
                                                              .transparent,
                                                          highlightColor: Colors
                                                              .transparent,
                                                          onTap: () async {
                                                            _model.showMoreId =
                                                                null;
                                                            safeSetState(() {});
                                                          },
                                                          child: Text(
                                                            'Read Less',
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
                                                                  lineHeight:
                                                                      1.4,
                                                                ),
                                                          ),
                                                        ),
                                                      ),
                                                  ].divide(
                                                      SizedBox(height: 4.0)),
                                                ),
                                              ]
                                                  .divide(SizedBox(height: 8.0))
                                                  .addToStart(
                                                      SizedBox(height: 12.0)),
                                            ),
                                          ),
                                          Padding(
                                            padding:
                                                EdgeInsetsDirectional.fromSTEB(
                                                    20.0, 0.0, 20.0, 0.0),
                                            child: Stack(
                                              children: [
                                                if (('${getJsonField(
                                                          FFAppState()
                                                              .AsSpecificGroupDetails,
                                                          r'''$.user_status''',
                                                        ).toString()}' ==
                                                        'joined') ||
                                                    (('${getJsonField(
                                                              FFAppState()
                                                                  .AsSpecificGroupDetails,
                                                              r'''$.user_status''',
                                                            ).toString()}' ==
                                                            'admin') &&
                                                        ('${getJsonField(
                                                              FFAppState()
                                                                  .AsSpecificGroupDetails,
                                                              r'''$.e_group_type''',
                                                            ).toString()}' ==
                                                            'open')))
                                                  Padding(
                                                    padding:
                                                        EdgeInsetsDirectional
                                                            .fromSTEB(0.0, 16.0,
                                                                0.0, 0.0),
                                                    child: Row(
                                                      mainAxisSize:
                                                          MainAxisSize.max,
                                                      children: [
                                                        Expanded(
                                                          child: Container(
                                                            height: 36.0,
                                                            decoration:
                                                                BoxDecoration(
                                                              color: FlutterFlowTheme
                                                                      .of(context)
                                                                  .greayL1,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          24.0),
                                                            ),
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
                                                                  enableDrag:
                                                                      false,
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
                                                                            CompGroup1Widget(
                                                                          groupId:
                                                                              widget!.groupId!,
                                                                          userStatus:
                                                                              getJsonField(
                                                                            FFAppState().AsSpecificGroupDetails,
                                                                            r'''$.user_status''',
                                                                          ).toString(),
                                                                          userId:
                                                                              getJsonField(
                                                                            FFAppState().AsSpecificGroupDetails,
                                                                            r'''$.creator_id''',
                                                                          ).toString(),
                                                                        ),
                                                                      ),
                                                                    );
                                                                  },
                                                                ).then((value) =>
                                                                    safeSetState(
                                                                        () {}));
                                                              },
                                                              child: Row(
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .max,
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  Icon(
                                                                    Icons
                                                                        .how_to_reg,
                                                                    color: FlutterFlowTheme.of(
                                                                            context)
                                                                        .extraBlack,
                                                                    size: 22.0,
                                                                  ),
                                                                  Text(
                                                                    'Joined',
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
                                                                  Icon(
                                                                    Icons
                                                                        .arrow_drop_down,
                                                                    color: FlutterFlowTheme.of(
                                                                            context)
                                                                        .extraBlack,
                                                                    size: 22.0,
                                                                  ),
                                                                ].divide(SizedBox(
                                                                    width:
                                                                        8.0)),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        Expanded(
                                                          child: FFButtonWidget(
                                                            onPressed:
                                                                () async {
                                                              HapticFeedback
                                                                  .lightImpact();
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
                                                                          CompInviteFriendsWidget(
                                                                        groupId:
                                                                            widget!.groupId!,
                                                                      ),
                                                                    ),
                                                                  );
                                                                },
                                                              ).then((value) =>
                                                                  safeSetState(
                                                                      () {}));
                                                            },
                                                            text: 'Invite',
                                                            icon: Icon(
                                                              Icons.group_add,
                                                              size: 15.0,
                                                            ),
                                                            options:
                                                                FFButtonOptions(
                                                              height: 36.0,
                                                              padding:
                                                                  EdgeInsetsDirectional
                                                                      .fromSTEB(
                                                                          16.0,
                                                                          4.0,
                                                                          16.0,
                                                                          4.0),
                                                              iconAlignment:
                                                                  IconAlignment
                                                                      .start,
                                                              iconPadding:
                                                                  EdgeInsetsDirectional
                                                                      .fromSTEB(
                                                                          0.0,
                                                                          0.0,
                                                                          0.0,
                                                                          0.0),
                                                              iconColor:
                                                                  FlutterFlowTheme.of(
                                                                          context)
                                                                      .white,
                                                              color: FlutterFlowTheme
                                                                      .of(context)
                                                                  .primaryD4,
                                                              textStyle:
                                                                  FlutterFlowTheme.of(
                                                                          context)
                                                                      .titleSmall
                                                                      .override(
                                                                        font: GoogleFonts
                                                                            .manrope(
                                                                          fontWeight: FlutterFlowTheme.of(context)
                                                                              .titleSmall
                                                                              .fontWeight,
                                                                          fontStyle: FlutterFlowTheme.of(context)
                                                                              .titleSmall
                                                                              .fontStyle,
                                                                        ),
                                                                        color: Colors
                                                                            .white,
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
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          24.0),
                                                            ),
                                                          ),
                                                        ),
                                                      ].divide(
                                                          SizedBox(width: 8.0)),
                                                    ),
                                                  ),
                                                if ('${getJsonField(
                                                      FFAppState()
                                                          .AsSpecificGroupDetails,
                                                      r'''$.user_status''',
                                                    ).toString()}' ==
                                                    'join')
                                                  Padding(
                                                    padding:
                                                        EdgeInsetsDirectional
                                                            .fromSTEB(0.0, 16.0,
                                                                0.0, 0.0),
                                                    child: FFButtonWidget(
                                                      onPressed: () async {
                                                        await GroupMembersTable()
                                                            .insert({
                                                          'community_id':
                                                              FFAppState()
                                                                  .communityId,
                                                          'user_id':
                                                              currentUserUid,
                                                          'group_id':
                                                              widget!.groupId,
                                                          'is_requested': false,
                                                          'requested_date':
                                                              supaSerialize<
                                                                      DateTime>(
                                                                  functions
                                                                      .getCurrentUtcTime()),
                                                          'is_approved': true,
                                                          'approved_by':
                                                              currentUserUid,
                                                          'joined_at':
                                                              supaSerialize<
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
                                                              widget!.groupId,
                                                          'is_requested': false,
                                                          'is_invited': false,
                                                          'is_member': true,
                                                          'joined_at':
                                                              supaSerialize<
                                                                      DateTime>(
                                                                  functions
                                                                      .getCurrentUtcTime()),
                                                        });
                                                        await GroupMembersInviteTable()
                                                            .update(
                                                          data: {
                                                            'is_member': true,
                                                          },
                                                          matchingRows:
                                                              (rows) => rows
                                                                  .eqOrNull(
                                                                    'group_id',
                                                                    widget!
                                                                        .groupId,
                                                                  )
                                                                  .eqOrNull(
                                                                    'invited_user',
                                                                    currentUserUid,
                                                                  ),
                                                        );
                                                        _model.apiResultd2pCopy =
                                                            await UpdateTotalGroupMembersCall
                                                                .call(
                                                          token:
                                                              currentJwtToken,
                                                          anonKey:
                                                              FFDevEnvironmentValues()
                                                                  .AnonKey,
                                                          groupId:
                                                              widget!.groupId,
                                                        );

                                                        safeSetState(() {});
                                                      },
                                                      text: 'Join Group',
                                                      icon: Icon(
                                                        Icons.person_add_alt_1,
                                                        size: 20.0,
                                                      ),
                                                      options: FFButtonOptions(
                                                        width: double.infinity,
                                                        height: 46.0,
                                                        padding:
                                                            EdgeInsetsDirectional
                                                                .fromSTEB(
                                                                    16.0,
                                                                    12.0,
                                                                    16.0,
                                                                    12.0),
                                                        iconPadding:
                                                            EdgeInsetsDirectional
                                                                .fromSTEB(
                                                                    0.0,
                                                                    0.0,
                                                                    0.0,
                                                                    0.0),
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .primary,
                                                        textStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .titleSmall
                                                                .override(
                                                                  font: GoogleFonts
                                                                      .manrope(
                                                                    fontWeight: FlutterFlowTheme.of(
                                                                            context)
                                                                        .titleSmall
                                                                        .fontWeight,
                                                                    fontStyle: FlutterFlowTheme.of(
                                                                            context)
                                                                        .titleSmall
                                                                        .fontStyle,
                                                                  ),
                                                                  color: Colors
                                                                      .white,
                                                                  letterSpacing:
                                                                      0.0,
                                                                  fontWeight: FlutterFlowTheme.of(
                                                                          context)
                                                                      .titleSmall
                                                                      .fontWeight,
                                                                  fontStyle: FlutterFlowTheme.of(
                                                                          context)
                                                                      .titleSmall
                                                                      .fontStyle,
                                                                  lineHeight:
                                                                      1.4,
                                                                ),
                                                        elevation: 0.0,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(24.0),
                                                      ),
                                                    ),
                                                  ),
                                                if ('${getJsonField(
                                                      FFAppState()
                                                          .AsSpecificGroupDetails,
                                                      r'''$.user_status''',
                                                    ).toString()}' ==
                                                    'request')
                                                  Padding(
                                                    padding:
                                                        EdgeInsetsDirectional
                                                            .fromSTEB(0.0, 16.0,
                                                                0.0, 0.0),
                                                    child: FFButtonWidget(
                                                      onPressed: () async {
                                                        HapticFeedback
                                                            .lightImpact();
                                                        await GroupUserStatusTable()
                                                            .insert({
                                                          'community_id':
                                                              FFAppState()
                                                                  .communityId,
                                                          'user_id':
                                                              currentUserUid,
                                                          'group_id':
                                                              widget!.groupId,
                                                          'is_requested': true,
                                                          'is_invited': false,
                                                          'is_member': false,
                                                          'is_approved': false,
                                                          'requested_date':
                                                              supaSerialize<
                                                                      DateTime>(
                                                                  functions
                                                                      .getCurrentUtcTime()),
                                                        });
                                                      },
                                                      text: 'Request',
                                                      icon: Icon(
                                                        Icons.lock,
                                                        size: 20.0,
                                                      ),
                                                      options: FFButtonOptions(
                                                        width: double.infinity,
                                                        height: 46.0,
                                                        padding:
                                                            EdgeInsetsDirectional
                                                                .fromSTEB(
                                                                    16.0,
                                                                    12.0,
                                                                    16.0,
                                                                    12.0),
                                                        iconPadding:
                                                            EdgeInsetsDirectional
                                                                .fromSTEB(
                                                                    0.0,
                                                                    0.0,
                                                                    0.0,
                                                                    0.0),
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .primary,
                                                        textStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .titleSmall
                                                                .override(
                                                                  font: GoogleFonts
                                                                      .manrope(
                                                                    fontWeight: FlutterFlowTheme.of(
                                                                            context)
                                                                        .titleSmall
                                                                        .fontWeight,
                                                                    fontStyle: FlutterFlowTheme.of(
                                                                            context)
                                                                        .titleSmall
                                                                        .fontStyle,
                                                                  ),
                                                                  color: Colors
                                                                      .white,
                                                                  letterSpacing:
                                                                      0.0,
                                                                  fontWeight: FlutterFlowTheme.of(
                                                                          context)
                                                                      .titleSmall
                                                                      .fontWeight,
                                                                  fontStyle: FlutterFlowTheme.of(
                                                                          context)
                                                                      .titleSmall
                                                                      .fontStyle,
                                                                  lineHeight:
                                                                      1.4,
                                                                ),
                                                        elevation: 0.0,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(24.0),
                                                      ),
                                                    ),
                                                  ),
                                                if ('${getJsonField(
                                                      FFAppState()
                                                          .AsSpecificGroupDetails,
                                                      r'''$.user_status''',
                                                    ).toString()}' ==
                                                    'requested')
                                                  Padding(
                                                    padding:
                                                        EdgeInsetsDirectional
                                                            .fromSTEB(0.0, 16.0,
                                                                0.0, 0.0),
                                                    child: FFButtonWidget(
                                                      onPressed: () {},
                                                      text: 'Requested',
                                                      icon: FaIcon(
                                                        FontAwesomeIcons
                                                            .userCheck,
                                                        size: 20.0,
                                                      ),
                                                      options: FFButtonOptions(
                                                        width: double.infinity,
                                                        height: 46.0,
                                                        padding:
                                                            EdgeInsetsDirectional
                                                                .fromSTEB(
                                                                    16.0,
                                                                    12.0,
                                                                    16.0,
                                                                    12.0),
                                                        iconPadding:
                                                            EdgeInsetsDirectional
                                                                .fromSTEB(
                                                                    0.0,
                                                                    0.0,
                                                                    0.0,
                                                                    0.0),
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .greayL1,
                                                        textStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .titleSmall
                                                                .override(
                                                                  font: GoogleFonts
                                                                      .manrope(
                                                                    fontWeight: FlutterFlowTheme.of(
                                                                            context)
                                                                        .titleSmall
                                                                        .fontWeight,
                                                                    fontStyle: FlutterFlowTheme.of(
                                                                            context)
                                                                        .titleSmall
                                                                        .fontStyle,
                                                                  ),
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .extraBlack,
                                                                  letterSpacing:
                                                                      0.0,
                                                                  fontWeight: FlutterFlowTheme.of(
                                                                          context)
                                                                      .titleSmall
                                                                      .fontWeight,
                                                                  fontStyle: FlutterFlowTheme.of(
                                                                          context)
                                                                      .titleSmall
                                                                      .fontStyle,
                                                                  lineHeight:
                                                                      1.4,
                                                                ),
                                                        elevation: 0.0,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(24.0),
                                                      ),
                                                    ),
                                                  ),
                                                if (('${getJsonField(
                                                          FFAppState()
                                                              .AsSpecificGroupDetails,
                                                          r'''$.user_status''',
                                                        ).toString()}' ==
                                                        'admin') &&
                                                    ('${getJsonField(
                                                          FFAppState()
                                                              .AsSpecificGroupDetails,
                                                          r'''$.e_group_type''',
                                                        ).toString()}' ==
                                                        'private'))
                                                  Padding(
                                                    padding:
                                                        EdgeInsetsDirectional
                                                            .fromSTEB(0.0, 16.0,
                                                                0.0, 0.0),
                                                    child: FFButtonWidget(
                                                      onPressed: () async {
                                                        await showModalBottomSheet(
                                                          isScrollControlled:
                                                              true,
                                                          backgroundColor:
                                                              Colors
                                                                  .transparent,
                                                          context: context,
                                                          builder: (context) {
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
                                                              child: Padding(
                                                                padding: MediaQuery
                                                                    .viewInsetsOf(
                                                                        context),
                                                                child:
                                                                    CompJoiningRequestWidget(
                                                                  groupId: widget!
                                                                      .groupId!,
                                                                ),
                                                              ),
                                                            );
                                                          },
                                                        ).then((value) =>
                                                            safeSetState(
                                                                () {}));
                                                      },
                                                      text:
                                                          'View Joining Requests',
                                                      options: FFButtonOptions(
                                                        width: double.infinity,
                                                        height: 46.0,
                                                        padding:
                                                            EdgeInsetsDirectional
                                                                .fromSTEB(
                                                                    16.0,
                                                                    12.0,
                                                                    16.0,
                                                                    12.0),
                                                        iconPadding:
                                                            EdgeInsetsDirectional
                                                                .fromSTEB(
                                                                    0.0,
                                                                    0.0,
                                                                    0.0,
                                                                    0.0),
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .primary,
                                                        textStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .titleSmall
                                                                .override(
                                                                  font: GoogleFonts
                                                                      .manrope(
                                                                    fontWeight: FlutterFlowTheme.of(
                                                                            context)
                                                                        .titleSmall
                                                                        .fontWeight,
                                                                    fontStyle: FlutterFlowTheme.of(
                                                                            context)
                                                                        .titleSmall
                                                                        .fontStyle,
                                                                  ),
                                                                  color: Colors
                                                                      .white,
                                                                  letterSpacing:
                                                                      0.0,
                                                                  fontWeight: FlutterFlowTheme.of(
                                                                          context)
                                                                      .titleSmall
                                                                      .fontWeight,
                                                                  fontStyle: FlutterFlowTheme.of(
                                                                          context)
                                                                      .titleSmall
                                                                      .fontStyle,
                                                                  lineHeight:
                                                                      1.4,
                                                                ),
                                                        elevation: 0.0,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(24.0),
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
                                ),
                                if (('${getJsonField(
                                          FFAppState().AsSpecificGroupDetails,
                                          r'''$.user_status''',
                                        ).toString()}' ==
                                        'joined') ||
                                    ('${getJsonField(
                                          FFAppState().AsSpecificGroupDetails,
                                          r'''$.user_status''',
                                        ).toString()}' ==
                                        'admin'))
                                  Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        0.0, 8.0, 0.0, 0.0),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color:
                                            FlutterFlowTheme.of(context).white,
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          Padding(
                                            padding:
                                                EdgeInsetsDirectional.fromSTEB(
                                                    20.0, 12.0, 20.0, 12.0),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.max,
                                              children: [
                                                AppNetworkImage(
                                                  url: FFAppState()
                                                      .AsProfilePicture,
                                                  width: 40.0,
                                                  height: 40.0,
                                                  fit: BoxFit.cover,
                                                  isAvatar: true,
                                                  semanticLabel:
                                                      'Profile photo',
                                                ),
                                                Expanded(
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
                                                        CreatePostWidget
                                                            .routeName,
                                                        queryParameters: {
                                                          'groupId':
                                                              serializeParam(
                                                            widget!.groupId,
                                                            ParamType.String,
                                                          ),
                                                        }.withoutNulls,
                                                      );
                                                    },
                                                    child: Container(
                                                      height: 34.0,
                                                      decoration: BoxDecoration(
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .greayL1,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(4.0),
                                                      ),
                                                      child: Padding(
                                                        padding:
                                                            EdgeInsetsDirectional
                                                                .fromSTEB(
                                                                    12.0,
                                                                    8.0,
                                                                    0.0,
                                                                    0.0),
                                                        child: Text(
                                                          'Write Something...',
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
                                                                letterSpacing:
                                                                    0.0,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                fontStyle: FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .fontStyle,
                                                                lineHeight: 1.3,
                                                              ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ].divide(SizedBox(width: 10.0)),
                                            ),
                                          ),
                                          Container(
                                            width: double.infinity,
                                            height: 1.0,
                                            decoration: BoxDecoration(
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .greyL2,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                if (('${getJsonField(
                                          FFAppState().AsSpecificGroupDetails,
                                          r'''$.e_group_type''',
                                        ).toString()}' ==
                                        'open') ||
                                    ('${getJsonField(
                                          FFAppState().AsSpecificGroupDetails,
                                          r'''$.user_status''',
                                        ).toString()}' ==
                                        'joined') ||
                                    ('${getJsonField(
                                          FFAppState().AsSpecificGroupDetails,
                                          r'''$.user_status''',
                                        ).toString()}' ==
                                        'admin'))
                                  Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        0.0, 8.0, 0.0, 0.0),
                                    child: Container(
                                      decoration: BoxDecoration(),
                                      child: Builder(
                                        builder: (context) {
                                          final posts =
                                              FFAppState().AsPost.toList();
                                          // The list below only shows posts
                                          // belonging to this group, so count
                                          // those before claiming "no posts".
                                          final groupPosts = posts
                                              .where((p) =>
                                                  widget!.groupId ==
                                                  getJsonField(
                                                    p,
                                                    r'''$.group_id''',
                                                  ).toString())
                                              .toList();
                                          if (groupPosts.isEmpty) {
                                            return EmptyState(
                                              icon: Icons.forum_outlined,
                                              title:
                                                  'No posts in this group yet',
                                              body:
                                                  'Be the first to share something with this group.',
                                              compact: true,
                                            );
                                          }

                                          return Column(
                                            mainAxisSize: MainAxisSize.max,
                                            children: List.generate(
                                                posts.length, (postsIndex) {
                                              final postsItem =
                                                  posts[postsIndex];
                                              return Visibility(
                                                visible: widget!.groupId ==
                                                    getJsonField(
                                                      postsItem,
                                                      r'''$.group_id''',
                                                    ).toString(),
                                                child: Stack(
                                                  children: [
                                                    Container(
                                                      decoration: BoxDecoration(
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .white,
                                                      ),
                                                      child: Column(
                                                        mainAxisSize:
                                                            MainAxisSize.max,
                                                        children: [
                                                          Column(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .max,
                                                            children: [
                                                              Padding(
                                                                padding: EdgeInsetsDirectional
                                                                    .fromSTEB(
                                                                        20.0,
                                                                        0.0,
                                                                        14.0,
                                                                        0.0),
                                                                child: Row(
                                                                  mainAxisSize:
                                                                      MainAxisSize
                                                                          .max,
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceBetween,
                                                                  children: [
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
                                                                        if (getJsonField(
                                                                              postsItem,
                                                                              r'''$.user_id''',
                                                                            ) !=
                                                                            currentUserUid) {
                                                                          context
                                                                              .pushNamed(
                                                                            OtherProfileWidget.routeName,
                                                                            queryParameters:
                                                                                {
                                                                              'userid': serializeParam(
                                                                                getJsonField(
                                                                                  postsItem,
                                                                                  r'''$.user_id''',
                                                                                ).toString(),
                                                                                ParamType.String,
                                                                              ),
                                                                            }.withoutNulls,
                                                                          );
                                                                        } else {
                                                                          context
                                                                              .pushNamed(UserProfileWidget.routeName);
                                                                        }
                                                                      },
                                                                      child:
                                                                          Row(
                                                                        mainAxisSize:
                                                                            MainAxisSize.max,
                                                                        children:
                                                                            [
                                                                          AppNetworkImage(
                                                                            url:
                                                                                getJsonField(postsItem, r'''$.user_profile_picture''').toString(),
                                                                            width:
                                                                                32.0,
                                                                            height:
                                                                                32.0,
                                                                            fit:
                                                                                BoxFit.cover,
                                                                            isAvatar:
                                                                                true,
                                                                            semanticLabel:
                                                                                'Profile photo',
                                                                          ),
                                                                          Column(
                                                                            mainAxisSize:
                                                                                MainAxisSize.max,
                                                                            crossAxisAlignment:
                                                                                CrossAxisAlignment.start,
                                                                            children: [
                                                                              Text(
                                                                                getJsonField(
                                                                                  postsItem,
                                                                                  r'''$.user_name''',
                                                                                ).toString(),
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
                                                                              Row(
                                                                                mainAxisSize: MainAxisSize.max,
                                                                                children: [
                                                                                  Text(
                                                                                    getJsonField(
                                                                                      postsItem,
                                                                                      r'''$.user_city''',
                                                                                    ).toString(),
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
                                                                                  Container(
                                                                                    width: 2.0,
                                                                                    height: 2.0,
                                                                                    decoration: BoxDecoration(
                                                                                      color: FlutterFlowTheme.of(context).greyL4,
                                                                                      borderRadius: BorderRadius.circular(24.0),
                                                                                    ),
                                                                                  ),
                                                                                  Text(
                                                                                    functions.returnRelativeTIme(getJsonField(
                                                                                      postsItem,
                                                                                      r'''$.created_at''',
                                                                                    ).toString()),
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
                                                                                  Container(
                                                                                    width: 2.0,
                                                                                    height: 2.0,
                                                                                    decoration: BoxDecoration(
                                                                                      color: FlutterFlowTheme.of(context).greyL4,
                                                                                      borderRadius: BorderRadius.circular(24.0),
                                                                                    ),
                                                                                  ),
                                                                                  Container(
                                                                                    width: 8.0,
                                                                                    height: 8.0,
                                                                                    clipBehavior: Clip.antiAlias,
                                                                                    decoration: BoxDecoration(
                                                                                      shape: BoxShape.circle,
                                                                                    ),
                                                                                    child: Image.asset(
                                                                                      'assets/images/public.png',
                                                                                      fit: BoxFit.cover,
                                                                                    ),
                                                                                  ),
                                                                                ].divide(SizedBox(width: 4.0)),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ].divide(SizedBox(width: 8.0)),
                                                                      ),
                                                                    ),
                                                                    Row(
                                                                      mainAxisSize:
                                                                          MainAxisSize
                                                                              .max,
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
                                                                          onTap:
                                                                              () async {
                                                                            await AddFollowCall.call(
                                                                              pFollowerid: currentUserUid,
                                                                              pFollowingid: getJsonField(
                                                                                postsItem,
                                                                                r'''$.user_id''',
                                                                              ).toString(),
                                                                              pCommunityid: FFAppState().communityId,
                                                                              token: currentJwtToken,
                                                                            );
                                                                          },
                                                                          child:
                                                                              Container(
                                                                            decoration:
                                                                                BoxDecoration(),
                                                                            child:
                                                                                Padding(
                                                                              padding: EdgeInsetsDirectional.fromSTEB(6.0, 6.0, 6.0, 6.0),
                                                                              child: FutureBuilder<List<FollowsRow>>(
                                                                                future: FollowsTable().querySingleRow(
                                                                                  queryFn: (q) => q
                                                                                      .eqOrNull(
                                                                                        'follower_id',
                                                                                        currentUserUid,
                                                                                      )
                                                                                      .eqOrNull(
                                                                                        'following_id',
                                                                                        getJsonField(
                                                                                          postsItem,
                                                                                          r'''$.user_id''',
                                                                                        ).toString(),
                                                                                      ),
                                                                                ),
                                                                                builder: (context, snapshot) {
                                                                                  // Customize what your widget looks like when it's loading.
                                                                                  if (!snapshot.hasData) {
                                                                                    return CompLoadingWidget(
                                                                                      name: 'followPost',
                                                                                    );
                                                                                  }
                                                                                  List<FollowsRow> stackFollowsRowList = snapshot.data!;

                                                                                  final stackFollowsRow = stackFollowsRowList.isNotEmpty ? stackFollowsRowList.first : null;

                                                                                  return Stack(
                                                                                    children: [
                                                                                      if ((stackFollowsRow?.id == null || stackFollowsRow?.id == '') &&
                                                                                          (getJsonField(
                                                                                                postsItem,
                                                                                                r'''$.user_id''',
                                                                                              ) !=
                                                                                              currentUserUid))
                                                                                        Row(
                                                                                          mainAxisSize: MainAxisSize.max,
                                                                                          children: [
                                                                                            Icon(
                                                                                              Icons.add,
                                                                                              color: FlutterFlowTheme.of(context).primaryD3,
                                                                                              size: 14.0,
                                                                                            ),
                                                                                            Text(
                                                                                              'Follow',
                                                                                              style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                                    font: GoogleFonts.manrope(
                                                                                                      fontWeight: FontWeight.w600,
                                                                                                      fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                    ),
                                                                                                    color: FlutterFlowTheme.of(context).primaryD3,
                                                                                                    fontSize: 12.0,
                                                                                                    letterSpacing: 0.0,
                                                                                                    fontWeight: FontWeight.w600,
                                                                                                    fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                    lineHeight: 1.4,
                                                                                                  ),
                                                                                            ),
                                                                                          ].divide(SizedBox(width: 6.0)),
                                                                                        ),
                                                                                      if ((stackFollowsRow?.followingId != null && stackFollowsRow?.followingId != '') &&
                                                                                          (getJsonField(
                                                                                                postsItem,
                                                                                                r'''$.user_id''',
                                                                                              ) !=
                                                                                              currentUserUid))
                                                                                        Row(
                                                                                          mainAxisSize: MainAxisSize.max,
                                                                                          children: [
                                                                                            ClipRRect(
                                                                                              borderRadius: BorderRadius.circular(8.0),
                                                                                              child: Image.asset(
                                                                                                'assets/images/check.png',
                                                                                                width: 12.0,
                                                                                                height: 12.0,
                                                                                                fit: BoxFit.cover,
                                                                                              ),
                                                                                            ),
                                                                                            Text(
                                                                                              'Following',
                                                                                              style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                                    font: GoogleFonts.manrope(
                                                                                                      fontWeight: FontWeight.w600,
                                                                                                      fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                    ),
                                                                                                    color: FlutterFlowTheme.of(context).greyL4,
                                                                                                    letterSpacing: 0.0,
                                                                                                    fontWeight: FontWeight.w600,
                                                                                                    fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                    lineHeight: 1.4,
                                                                                                  ),
                                                                                            ),
                                                                                          ].divide(SizedBox(width: 6.0)),
                                                                                        ),
                                                                                    ],
                                                                                  );
                                                                                },
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        Transform
                                                                            .rotate(
                                                                          angle:
                                                                              90.0 * (math.pi / 180),
                                                                          child:
                                                                              AppIconButton(
                                                                            semanticLabel:
                                                                                'Post options',
                                                                            iconSize:
                                                                                16.0,
                                                                            onTap:
                                                                                () async {
                                                                              if ('${getJsonField(
                                                                                    postsItem,
                                                                                    r'''$.user_id''',
                                                                                  ).toString()}' ==
                                                                                  currentUserUid) {
                                                                                _model.reportPostId = ' ';
                                                                                safeSetState(() {});
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
                                                                                        child: CompThreeDotEditPostWidget(
                                                                                          postId: getJsonField(
                                                                                            postsItem,
                                                                                            r'''$.id''',
                                                                                          ).toString(),
                                                                                          groupId: getJsonField(
                                                                                            postsItem,
                                                                                            r'''$.group_id''',
                                                                                          ).toString(),
                                                                                        ),
                                                                                      ),
                                                                                    );
                                                                                  },
                                                                                ).then((value) => safeSetState(() {}));
                                                                              } else {
                                                                                _model.reportPostId = getJsonField(
                                                                                  postsItem,
                                                                                  r'''$.id''',
                                                                                ).toString();
                                                                                safeSetState(() {});
                                                                              }
                                                                            },
                                                                            iconWidget:
                                                                                Container(
                                                                              decoration: BoxDecoration(),
                                                                              child: Padding(
                                                                                padding: EdgeInsetsDirectional.fromSTEB(6.0, 6.0, 6.0, 6.0),
                                                                                child: Icon(
                                                                                  Icons.keyboard_control,
                                                                                  color: FlutterFlowTheme.of(context).primaryText,
                                                                                  size: 16.0,
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                              if (false)
                                                                Padding(
                                                                  padding: EdgeInsetsDirectional
                                                                      .fromSTEB(
                                                                          20.0,
                                                                          0.0,
                                                                          20.0,
                                                                          0.0),
                                                                  child: Column(
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .max,
                                                                    children: [
                                                                      Row(
                                                                        mainAxisSize:
                                                                            MainAxisSize.max,
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.end,
                                                                        children: [
                                                                          if (_model.postReadId !=
                                                                              getJsonField(
                                                                                postsItem,
                                                                                r'''$.id''',
                                                                              ).toString())
                                                                            Expanded(
                                                                              child: Text(
                                                                                getJsonField(
                                                                                  postsItem,
                                                                                  r'''$.content''',
                                                                                ).toString().maybeHandleOverflow(
                                                                                      maxChars: 99,
                                                                                      replacement: '…',
                                                                                    ),
                                                                                textAlign: TextAlign.start,
                                                                                maxLines: 2,
                                                                                style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                      font: GoogleFonts.manrope(
                                                                                        fontWeight: FontWeight.w500,
                                                                                        fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                      ),
                                                                                      color: FlutterFlowTheme.of(context).extraBlack,
                                                                                      letterSpacing: 0.0,
                                                                                      fontWeight: FontWeight.w500,
                                                                                      fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                      lineHeight: 1.3,
                                                                                    ),
                                                                              ),
                                                                            ),
                                                                          if (_model.postReadId ==
                                                                              getJsonField(
                                                                                postsItem,
                                                                                r'''$.id''',
                                                                              ).toString())
                                                                            Expanded(
                                                                              child: Text(
                                                                                getJsonField(
                                                                                  postsItem,
                                                                                  r'''$.content''',
                                                                                ).toString(),
                                                                                textAlign: TextAlign.start,
                                                                                style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                      font: GoogleFonts.manrope(
                                                                                        fontWeight: FontWeight.w500,
                                                                                        fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                      ),
                                                                                      color: FlutterFlowTheme.of(context).extraBlack,
                                                                                      letterSpacing: 0.0,
                                                                                      fontWeight: FontWeight.w500,
                                                                                      fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                      lineHeight: 1.3,
                                                                                    ),
                                                                              ),
                                                                            ),
                                                                        ],
                                                                      ),
                                                                      if ((getJsonField(
                                                                                postsItem,
                                                                                r'''$.content''',
                                                                              ).toString().length >
                                                                              100) ==
                                                                          true)
                                                                        Align(
                                                                          alignment: AlignmentDirectional(
                                                                              1.0,
                                                                              -1.0),
                                                                          child:
                                                                              Column(
                                                                            mainAxisSize:
                                                                                MainAxisSize.max,
                                                                            children: [
                                                                              InkWell(
                                                                                splashColor: FlutterFlowTheme.of(context).primary.withAlpha(0x14),
                                                                                focusColor: Colors.transparent,
                                                                                hoverColor: Colors.transparent,
                                                                                highlightColor: Colors.transparent,
                                                                                onTap: () async {
                                                                                  if (_model.postReadId ==
                                                                                      getJsonField(
                                                                                        postsItem,
                                                                                        r'''$.id''',
                                                                                      ).toString()) {
                                                                                    _model.postReadId = '123';
                                                                                    safeSetState(() {});
                                                                                  } else {
                                                                                    _model.postReadId = getJsonField(
                                                                                      postsItem,
                                                                                      r'''$.id''',
                                                                                    ).toString();
                                                                                    safeSetState(() {});
                                                                                  }
                                                                                },
                                                                                child: Container(
                                                                                  decoration: BoxDecoration(),
                                                                                  child: Padding(
                                                                                    padding: EdgeInsetsDirectional.fromSTEB(6.0, 6.0, 6.0, 6.0),
                                                                                    child: Text(
                                                                                      valueOrDefault<String>(
                                                                                        _model.postReadId !=
                                                                                                getJsonField(
                                                                                                  postsItem,
                                                                                                  r'''$.id''',
                                                                                                ).toString()
                                                                                            ? 'Read More'
                                                                                            : 'Read Less',
                                                                                        'Read More',
                                                                                      ),
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
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              Padding(
                                                                padding: EdgeInsetsDirectional
                                                                    .fromSTEB(
                                                                        20.0,
                                                                        0.0,
                                                                        20.0,
                                                                        0.0),
                                                                child: custom_widgets
                                                                    .ShowContent(
                                                                  width: double
                                                                      .infinity,
                                                                  height: 200.0,
                                                                  currentUserId:
                                                                      currentUserUid,
                                                                  richTextContent:
                                                                      getJsonField(
                                                                    postsItem,
                                                                    r'''$.content''',
                                                                  ),
                                                                  tldrContent:
                                                                      getJsonField(
                                                                    postsItem,
                                                                    r'''$.tldr''',
                                                                  ).toString(),
                                                                ),
                                                              ),
                                                              if (((String
                                                                      var1) {
                                                                    return var1 !=
                                                                        "null";
                                                                  }(getJsonField(
                                                                    postsItem,
                                                                    r'''$.post_images''',
                                                                  ).toString())) ==
                                                                  true)
                                                                Stack(
                                                                  children: [
                                                                    if (((getJsonField(
                                                                              postsItem,
                                                                              r'''$.post_images''',
                                                                              true,
                                                                            ) as List?)!
                                                                                .map<String>((e) => e.toString())
                                                                                .toList()
                                                                                .cast<String>()
                                                                                .length ==
                                                                            1) ==
                                                                        true)
                                                                      AppNetworkImage(
                                                                        url: getJsonField(postsItem,
                                                                                r'''$.post_images[0]''')
                                                                            .toString(),
                                                                        width: double
                                                                            .infinity,
                                                                        fit: BoxFit
                                                                            .contain,
                                                                        semanticLabel:
                                                                            'Post photo',
                                                                      ),
                                                                    if (((getJsonField(
                                                                              postsItem,
                                                                              r'''$.post_images''',
                                                                              true,
                                                                            ) as List?)!
                                                                                .map<String>((e) => e.toString())
                                                                                .toList()
                                                                                .cast<String>()
                                                                                .length >
                                                                            1) ==
                                                                        true)
                                                                      CompPageviewWidget(
                                                                        key: Key(
                                                                            'Keyicu_${postsIndex}_of_${posts.length}'),
                                                                        images:
                                                                            getJsonField(
                                                                          postsItem,
                                                                          r'''$.post_images''',
                                                                        ),
                                                                      ),
                                                                  ],
                                                                ),
                                                            ].divide(SizedBox(
                                                                height: 10.0)),
                                                          ),
                                                          Padding(
                                                            padding:
                                                                EdgeInsetsDirectional
                                                                    .fromSTEB(
                                                                        14.0,
                                                                        0.0,
                                                                        14.0,
                                                                        0.0),
                                                            child: Row(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .max,
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                Row(
                                                                  mainAxisSize:
                                                                      MainAxisSize
                                                                          .max,
                                                                  children: [
                                                                    AppIconButton(
                                                                      semanticLabel:
                                                                          'Like this post',
                                                                      iconSize:
                                                                          22.0,
                                                                      onTap:
                                                                          () async {
                                                                        _model.addlike2 =
                                                                            await AddLikeCall.call(
                                                                          pCommunityid: FFAppState()
                                                                              .communityId
                                                                              .toString(),
                                                                          pUserid:
                                                                              currentUserUid,
                                                                          pPostid:
                                                                              getJsonField(
                                                                            postsItem,
                                                                            r'''$.id''',
                                                                          ).toString(),
                                                                          token:
                                                                              currentJwtToken,
                                                                        );

                                                                        safeSetState(
                                                                            () {});
                                                                      },
                                                                      iconWidget:
                                                                          Container(
                                                                        decoration:
                                                                            BoxDecoration(),
                                                                        child:
                                                                            Padding(
                                                                          padding: EdgeInsetsDirectional.fromSTEB(
                                                                              6.0,
                                                                              6.0,
                                                                              4.0,
                                                                              6.0),
                                                                          child:
                                                                              Stack(
                                                                            children: [
                                                                              Icon(
                                                                                Icons.favorite_border,
                                                                                color: FlutterFlowTheme.of(context).greyL4,
                                                                                size: 22.0,
                                                                              ),
                                                                              FutureBuilder<List<PostLikeRow>>(
                                                                                future: PostLikeTable().querySingleRow(
                                                                                  queryFn: (q) => q
                                                                                      .eqOrNull(
                                                                                        'post_id',
                                                                                        getJsonField(
                                                                                          postsItem,
                                                                                          r'''$.id''',
                                                                                        ).toString(),
                                                                                      )
                                                                                      .eqOrNull(
                                                                                        'user_id',
                                                                                        currentUserUid,
                                                                                      ),
                                                                                ),
                                                                                builder: (context, snapshot) {
                                                                                  // Customize what your widget looks like when it's loading.
                                                                                  if (!snapshot.hasData) {
                                                                                    return Container(
                                                                                      width: 22.0,
                                                                                      height: 22.0,
                                                                                      child: CompLoadingWidget(
                                                                                        name: 'like',
                                                                                      ),
                                                                                    );
                                                                                  }
                                                                                  List<PostLikeRow> iconPostLikeRowList = snapshot.data!;

                                                                                  // Return an empty Container when the item does not exist.
                                                                                  if (snapshot.data!.isEmpty) {
                                                                                    return Container();
                                                                                  }
                                                                                  final iconPostLikeRow = iconPostLikeRowList.isNotEmpty ? iconPostLikeRowList.first : null;

                                                                                  return Icon(
                                                                                    Icons.favorite,
                                                                                    color: FlutterFlowTheme.of(context).redColor2,
                                                                                    size: 22.0,
                                                                                  );
                                                                                },
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
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
                                                                        await showModalBottomSheet(
                                                                          isScrollControlled:
                                                                              true,
                                                                          backgroundColor:
                                                                              Colors.transparent,
                                                                          context:
                                                                              context,
                                                                          builder:
                                                                              (context) {
                                                                            return GestureDetector(
                                                                              onTap: () {
                                                                                FocusScope.of(context).unfocus();
                                                                                FocusManager.instance.primaryFocus?.unfocus();
                                                                              },
                                                                              child: Padding(
                                                                                padding: MediaQuery.viewInsetsOf(context),
                                                                                child: CompLikesWidget(
                                                                                  postId: getJsonField(
                                                                                    postsItem,
                                                                                    r'''$.id''',
                                                                                  ).toString(),
                                                                                  postUserid: getJsonField(
                                                                                    postsItem,
                                                                                    r'''$.user_id''',
                                                                                  ).toString(),
                                                                                ),
                                                                              ),
                                                                            );
                                                                          },
                                                                        ).then((value) =>
                                                                            safeSetState(() {}));
                                                                      },
                                                                      child:
                                                                          Container(
                                                                        decoration:
                                                                            BoxDecoration(),
                                                                        child:
                                                                            Padding(
                                                                          padding: EdgeInsetsDirectional.fromSTEB(
                                                                              0.0,
                                                                              9.0,
                                                                              16.0,
                                                                              9.0),
                                                                          child:
                                                                              Text(
                                                                            valueOrDefault<String>(
                                                                              getJsonField(
                                                                                postsItem,
                                                                                r'''$.likes_count''',
                                                                              )?.toString(),
                                                                              '0',
                                                                            ),
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
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                                InkWell(
                                                                  splashColor:
                                                                      Colors
                                                                          .transparent,
                                                                  focusColor: Colors
                                                                      .transparent,
                                                                  hoverColor: Colors
                                                                      .transparent,
                                                                  highlightColor:
                                                                      Colors
                                                                          .transparent,
                                                                  onTap:
                                                                      () async {
                                                                    _model.apiResultpio =
                                                                        await GetPostAllCommentsCall
                                                                            .call(
                                                                      pPostId:
                                                                          getJsonField(
                                                                        postsItem,
                                                                        r'''$.id''',
                                                                      ).toString(),
                                                                      token:
                                                                          currentJwtToken,
                                                                    );

                                                                    FFAppState()
                                                                            .AsComments =
                                                                        getJsonField(
                                                                      (_model.apiResultpio
                                                                              ?.jsonBody ??
                                                                          ''),
                                                                      r'''$.comments''',
                                                                    );
                                                                    FFAppState()
                                                                            .AsCommentReplies =
                                                                        getJsonField(
                                                                      (_model.apiResultpio
                                                                              ?.jsonBody ??
                                                                          ''),
                                                                      r'''$.replies''',
                                                                    );
                                                                    safeSetState(
                                                                        () {});

                                                                    context
                                                                        .pushNamed(
                                                                      CommentsPageWidget
                                                                          .routeName,
                                                                      queryParameters:
                                                                          {
                                                                        'postId':
                                                                            serializeParam(
                                                                          getJsonField(
                                                                            postsItem,
                                                                            r'''$.id''',
                                                                          ).toString(),
                                                                          ParamType
                                                                              .String,
                                                                        ),
                                                                      }.withoutNulls,
                                                                    );

                                                                    safeSetState(
                                                                        () {});
                                                                  },
                                                                  child:
                                                                      Container(
                                                                    decoration:
                                                                        BoxDecoration(),
                                                                    child:
                                                                        Padding(
                                                                      padding: EdgeInsetsDirectional.fromSTEB(
                                                                          6.0,
                                                                          6.0,
                                                                          6.0,
                                                                          6.0),
                                                                      child:
                                                                          Row(
                                                                        mainAxisSize:
                                                                            MainAxisSize.max,
                                                                        children:
                                                                            [
                                                                          ClipRRect(
                                                                            borderRadius:
                                                                                BorderRadius.circular(0.0),
                                                                            child:
                                                                                Image.asset(
                                                                              'assets/images/forum.png',
                                                                              width: 22.0,
                                                                              height: 22.0,
                                                                              fit: BoxFit.cover,
                                                                            ),
                                                                          ),
                                                                          Text(
                                                                            valueOrDefault<String>(
                                                                              getJsonField(
                                                                                postsItem,
                                                                                r'''$.comment_count''',
                                                                              )?.toString(),
                                                                              '0',
                                                                            ),
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
                                                                        ].divide(SizedBox(width: 4.0)),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                InkWell(
                                                                  splashColor:
                                                                      Colors
                                                                          .transparent,
                                                                  focusColor: Colors
                                                                      .transparent,
                                                                  hoverColor: Colors
                                                                      .transparent,
                                                                  highlightColor:
                                                                      Colors
                                                                          .transparent,
                                                                  onTap:
                                                                      () async {
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
                                                                            FocusScope.of(context).unfocus();
                                                                            FocusManager.instance.primaryFocus?.unfocus();
                                                                          },
                                                                          child:
                                                                              Padding(
                                                                            padding:
                                                                                MediaQuery.viewInsetsOf(context),
                                                                            child:
                                                                                CompShareWidget(
                                                                              pagename: 'grouppost',
                                                                              id: getJsonField(
                                                                                postsItem,
                                                                                r'''$.id''',
                                                                              ).toString(),
                                                                            ),
                                                                          ),
                                                                        );
                                                                      },
                                                                    ).then((value) =>
                                                                        safeSetState(
                                                                            () {}));
                                                                  },
                                                                  child:
                                                                      Container(
                                                                    decoration:
                                                                        BoxDecoration(),
                                                                    child:
                                                                        Padding(
                                                                      padding: EdgeInsetsDirectional.fromSTEB(
                                                                          6.0,
                                                                          6.0,
                                                                          6.0,
                                                                          6.0),
                                                                      child:
                                                                          Row(
                                                                        mainAxisSize:
                                                                            MainAxisSize.max,
                                                                        children:
                                                                            [
                                                                          InkWell(
                                                                            splashColor:
                                                                                Colors.transparent,
                                                                            focusColor:
                                                                                Colors.transparent,
                                                                            hoverColor:
                                                                                Colors.transparent,
                                                                            highlightColor:
                                                                                Colors.transparent,
                                                                            onTap:
                                                                                () async {
                                                                              await showModalBottomSheet(
                                                                                isScrollControlled: true,
                                                                                backgroundColor: Colors.transparent,
                                                                                enableDrag: false,
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
                                                                                        pagename: 'post',
                                                                                        id: getJsonField(
                                                                                          postsItem,
                                                                                          r'''$.id''',
                                                                                        ).toString(),
                                                                                      ),
                                                                                    ),
                                                                                  );
                                                                                },
                                                                              ).then((value) => safeSetState(() {}));
                                                                            },
                                                                            child:
                                                                                ClipRRect(
                                                                              borderRadius: BorderRadius.circular(0.0),
                                                                              child: Image.asset(
                                                                                'assets/images/share_windows.png',
                                                                                width: 22.0,
                                                                                height: 22.0,
                                                                                fit: BoxFit.cover,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          Text(
                                                                            valueOrDefault<String>(
                                                                              getJsonField(
                                                                                postsItem,
                                                                                r'''$.share_count''',
                                                                              )?.toString(),
                                                                              '0',
                                                                            ),
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
                                                                        ].divide(SizedBox(width: 4.0)),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ]
                                                            .divide(SizedBox(
                                                                height: 4.0))
                                                            .addToStart(
                                                                SizedBox(
                                                                    height:
                                                                        12.0))
                                                            .addToEnd(SizedBox(
                                                                height: 6.0)),
                                                      ),
                                                    ),
                                                    if ('${getJsonField(
                                                          postsItem,
                                                          r'''$.id''',
                                                        ).toString()}' ==
                                                        _model.reportPostId)
                                                      Align(
                                                        alignment:
                                                            AlignmentDirectional(
                                                                1.0, -1.0),
                                                        child: Padding(
                                                          padding:
                                                              EdgeInsetsDirectional
                                                                  .fromSTEB(
                                                                      0.0,
                                                                      36.0,
                                                                      36.0,
                                                                      0.0),
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
                                                                          CompReportPostWidget(
                                                                        postId:
                                                                            getJsonField(
                                                                          postsItem,
                                                                          r'''$.id''',
                                                                        ).toString(),
                                                                        userId:
                                                                            getJsonField(
                                                                          postsItem,
                                                                          r'''$.user_id''',
                                                                        ).toString(),
                                                                      ),
                                                                    ),
                                                                  );
                                                                },
                                                              ).then((value) =>
                                                                  safeSetState(
                                                                      () {}));
                                                            },
                                                            child: Container(
                                                              width: 140.0,
                                                              height: 38.0,
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .secondaryBackground,
                                                                boxShadow: [
                                                                  FlutterFlowTheme.of(
                                                                          context)
                                                                      .designToken
                                                                      .shadow
                                                                      .md
                                                                ],
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            8.0),
                                                              ),
                                                              child: Padding(
                                                                padding:
                                                                    EdgeInsetsDirectional
                                                                        .fromSTEB(
                                                                            16.0,
                                                                            0.0,
                                                                            0.0,
                                                                            0.0),
                                                                child: Row(
                                                                  mainAxisSize:
                                                                      MainAxisSize
                                                                          .max,
                                                                  children: [
                                                                    ClipRRect(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              8.0),
                                                                      child: Image
                                                                          .asset(
                                                                        'assets/images/flag_2.webp',
                                                                        width:
                                                                            20.0,
                                                                        height:
                                                                            20.0,
                                                                        fit: BoxFit
                                                                            .cover,
                                                                      ),
                                                                    ),
                                                                    Text(
                                                                      'Report Post',
                                                                      style: FlutterFlowTheme.of(
                                                                              context)
                                                                          .bodyMedium
                                                                          .override(
                                                                            font:
                                                                                GoogleFonts.manrope(
                                                                              fontWeight: FontWeight.w500,
                                                                              fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                            ),
                                                                            color:
                                                                                FlutterFlowTheme.of(context).greyD1,
                                                                            letterSpacing:
                                                                                0.0,
                                                                            fontWeight:
                                                                                FontWeight.w500,
                                                                            fontStyle:
                                                                                FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                            lineHeight:
                                                                                1.4,
                                                                          ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                              );
                                            }).divide(
                                              SizedBox(height: 8.0),
                                              filterFn: (postsIndex) {
                                                final postsItem =
                                                    posts[postsIndex];
                                                return widget!.groupId ==
                                                    getJsonField(
                                                      postsItem,
                                                      r'''$.group_id''',
                                                    ).toString();
                                              },
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                Column(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    if (('${getJsonField(
                                              FFAppState()
                                                  .AsSpecificGroupDetails,
                                              r'''$.e_group_type''',
                                            ).toString()}' ==
                                            'private') &&
                                        (('${getJsonField(
                                                  FFAppState()
                                                      .AsSpecificGroupDetails,
                                                  r'''$.user_status''',
                                                ).toString()}' ==
                                                'request') ||
                                            ('${getJsonField(
                                                  FFAppState()
                                                      .AsSpecificGroupDetails,
                                                  r'''$.user_status''',
                                                ).toString()}' ==
                                                'requested')))
                                      Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            0.0, 8.0, 0.0, 0.0),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: FlutterFlowTheme.of(context)
                                                .secondaryBackground,
                                          ),
                                          child: Padding(
                                            padding:
                                                EdgeInsetsDirectional.fromSTEB(
                                                    20.0, 0.0, 20.0, 0.0),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.max,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Details',
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
                                                                .extraBlack,
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
                                                Column(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Column(
                                                      mainAxisSize:
                                                          MainAxisSize.max,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          'Private',
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
                                                                lineHeight: 1.3,
                                                              ),
                                                        ),
                                                        Text(
                                                          'Only members can see who’s in the group and what they post',
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
                                                                    .greyL5,
                                                                fontSize: 14.0,
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
                                                      ].divide(SizedBox(
                                                          height: 4.0)),
                                                    ),
                                                    Column(
                                                      mainAxisSize:
                                                          MainAxisSize.max,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          'Visible',
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
                                                                lineHeight: 1.3,
                                                              ),
                                                        ),
                                                        if ('${getJsonField(
                                                              FFAppState()
                                                                  .AsSpecificGroupDetails,
                                                              r'''$.e_discoverability''',
                                                            ).toString()}' ==
                                                            'listed')
                                                          Text(
                                                            'This group appears in search results and is visible to other members’ profiles.',
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
                                                                      .greyL5,
                                                                  fontSize:
                                                                      14.0,
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
                                                        if ('${getJsonField(
                                                              FFAppState()
                                                                  .AsSpecificGroupDetails,
                                                              r'''$.e_discoverability''',
                                                            ).toString()}' !=
                                                            'listed')
                                                          Text(
                                                            'This group does not appear in search results and is not visible on other members’ profiles.',
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
                                                                      .greyL5,
                                                                  fontSize:
                                                                      14.0,
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
                                                      ].divide(SizedBox(
                                                          height: 4.0)),
                                                    ),
                                                    Column(
                                                      mainAxisSize:
                                                          MainAxisSize.max,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          'History',
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
                                                                lineHeight: 1.3,
                                                              ),
                                                        ),
                                                        Text(
                                                          'Group created on ${functions.formatTimestamp(getJsonField(
                                                            FFAppState()
                                                                .AsSpecificGroupDetails,
                                                            r'''$.created_at''',
                                                          ).toString())}',
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
                                                                    .greyL5,
                                                                fontSize: 14.0,
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
                                                      ].divide(SizedBox(
                                                          height: 4.0)),
                                                    ),
                                                  ].divide(
                                                      SizedBox(height: 12.0)),
                                                ),
                                              ]
                                                  .divide(
                                                      SizedBox(height: 12.0))
                                                  .addToStart(
                                                      SizedBox(height: 12.0))
                                                  .addToEnd(
                                                      SizedBox(height: 12.0)),
                                            ),
                                          ),
                                        ),
                                      ),
                                    if ('${getJsonField(
                                          FFAppState().AsSpecificGroupDetails,
                                          r'''$.e_group_type''',
                                        ).toString()}' ==
                                        'private')
                                      Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            0.0, 8.0, 0.0, 0.0),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: FlutterFlowTheme.of(context)
                                                .secondaryBackground,
                                          ),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.max,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding: EdgeInsetsDirectional
                                                    .fromSTEB(
                                                        20.0, 0.0, 20.0, 0.0),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      'Admins',
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
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .extraBlack,
                                                                fontSize: 18.0,
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
                                                    if ('${getJsonField(
                                                          FFAppState()
                                                              .AsSpecificGroupDetails,
                                                          r'''$.user_status''',
                                                        ).toString()}' ==
                                                        'admin')
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
                                                          await showModalBottomSheet(
                                                            isScrollControlled:
                                                                true,
                                                            backgroundColor:
                                                                Colors
                                                                    .transparent,
                                                            context: context,
                                                            builder: (context) {
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
                                                                child: Padding(
                                                                  padding: MediaQuery
                                                                      .viewInsetsOf(
                                                                          context),
                                                                  child:
                                                                      CompAssignAdminWidget(
                                                                    groupId: widget!
                                                                        .groupId!,
                                                                    creatorId:
                                                                        '${getJsonField(
                                                                      FFAppState()
                                                                          .AsSpecificGroupDetails,
                                                                      r'''$.creator_id''',
                                                                    ).toString()}',
                                                                  ),
                                                                ),
                                                              );
                                                            },
                                                          ).then((value) =>
                                                              safeSetState(
                                                                  () {}));
                                                        },
                                                        child: Text(
                                                          'Assign Role',
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
                                                                    .primary,
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
                                                  ],
                                                ),
                                              ),
                                              FutureBuilder<
                                                  List<GroupAdminRow>>(
                                                future:
                                                    GroupAdminTable().queryRows(
                                                  queryFn: (q) => q.eqOrNull(
                                                    'group_id',
                                                    widget!.groupId,
                                                  ),
                                                ),
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
                                                  List<GroupAdminRow>
                                                      listViewGroupAdminRowList =
                                                      snapshot.data!;

                                                  return ListView.builder(
                                                    padding: EdgeInsets.zero,
                                                    primary: false,
                                                    shrinkWrap: true,
                                                    scrollDirection:
                                                        Axis.vertical,
                                                    itemCount:
                                                        listViewGroupAdminRowList
                                                            .length,
                                                    itemBuilder: (context,
                                                        listViewIndex) {
                                                      final listViewGroupAdminRow =
                                                          listViewGroupAdminRowList[
                                                              listViewIndex];
                                                      return FutureBuilder<
                                                          List<
                                                              PublicUserProfileRow>>(
                                                        future:
                                                            PublicUserProfileTable()
                                                                .querySingleRow(
                                                          queryFn: (q) =>
                                                              q.eqOrNull(
                                                            'id',
                                                            listViewGroupAdminRow
                                                                .userId,
                                                          ),
                                                        ),
                                                        builder: (context,
                                                            snapshot) {
                                                          // Customize what your widget looks like when it's loading.
                                                          if (!snapshot
                                                              .hasData) {
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
                                                          List<PublicUserProfileRow>
                                                              columnPublicUserProfileRowList =
                                                              snapshot.data!;

                                                          final columnPublicUserProfileRow =
                                                              columnPublicUserProfileRowList
                                                                      .isNotEmpty
                                                                  ? columnPublicUserProfileRowList
                                                                      .first
                                                                  : null;

                                                          return Column(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .max,
                                                            children: [
                                                              Padding(
                                                                padding: EdgeInsetsDirectional
                                                                    .fromSTEB(
                                                                        20.0,
                                                                        12.0,
                                                                        20.0,
                                                                        12.0),
                                                                child: Row(
                                                                  mainAxisSize:
                                                                      MainAxisSize
                                                                          .max,
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceBetween,
                                                                  children: [
                                                                    Row(
                                                                      mainAxisSize:
                                                                          MainAxisSize
                                                                              .max,
                                                                      children:
                                                                          [
                                                                        AppNetworkImage(
                                                                          url: columnPublicUserProfileRow!
                                                                              .profilePicture!,
                                                                          width:
                                                                              32.0,
                                                                          height:
                                                                              32.0,
                                                                          fit: BoxFit
                                                                              .cover,
                                                                          isAvatar:
                                                                              true,
                                                                          semanticLabel:
                                                                              'Profile photo',
                                                                        ),
                                                                        Column(
                                                                          mainAxisSize:
                                                                              MainAxisSize.max,
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.start,
                                                                          children: [
                                                                            Text(
                                                                              valueOrDefault<String>(
                                                                                columnPublicUserProfileRow?.name,
                                                                                'name',
                                                                              ),
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
                                                                              valueOrDefault<String>(
                                                                                columnPublicUserProfileRow?.city,
                                                                                'city',
                                                                              ),
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
                                                                          ],
                                                                        ),
                                                                      ].divide(SizedBox(
                                                                              width: 8.0)),
                                                                    ),
                                                                    Stack(
                                                                      children: [
                                                                        if (('${getJsonField(
                                                                                  FFAppState().AsSpecificGroupDetails,
                                                                                  r'''$.user_status''',
                                                                                ).toString()}' !=
                                                                                'admin') &&
                                                                            ('${getJsonField(
                                                                                  FFAppState().AsSpecificGroupDetails,
                                                                                  r'''$.creator_id''',
                                                                                ).toString()}' !=
                                                                                listViewGroupAdminRow.userId))
                                                                          FFButtonWidget(
                                                                            onPressed:
                                                                                () async {
                                                                              _model.chatFound = await FindCommonChatCall.call(
                                                                                anonKey: FFDevEnvironmentValues().AnonKey,
                                                                                token: currentJwtToken,
                                                                                user1: currentUserUid,
                                                                                user2: columnPublicUserProfileRow?.id,
                                                                              );

                                                                              if (FindCommonChatCall.chatFound(
                                                                                (_model.chatFound?.jsonBody ?? ''),
                                                                              )!) {
                                                                                await RestoreChatUserCall.call(
                                                                                  pChatId: FindCommonChatCall.chatId(
                                                                                    (_model.chatFound?.jsonBody ?? ''),
                                                                                  ),
                                                                                  pUserId: columnPublicUserProfileRow?.id,
                                                                                  anonKey: FFDevEnvironmentValues().AnonKey,
                                                                                  token: currentJwtToken,
                                                                                );

                                                                                context.pushNamed(
                                                                                  MessagePageWidget.routeName,
                                                                                  queryParameters: {
                                                                                    'chatId': serializeParam(
                                                                                      FindCommonChatCall.chatId(
                                                                                        (_model.chatFound?.jsonBody ?? ''),
                                                                                      ),
                                                                                      ParamType.String,
                                                                                    ),
                                                                                    'userId': serializeParam(
                                                                                      columnPublicUserProfileRow?.id,
                                                                                      ParamType.String,
                                                                                    ),
                                                                                  }.withoutNulls,
                                                                                );
                                                                              } else {
                                                                                _model.chat = await ChatTable().insert({
                                                                                  'community_id': 1,
                                                                                  'first_message_date': supaSerialize<DateTime>(functions.getCurrentUtcTime()),
                                                                                  'created_by': currentUserUid,
                                                                                  'chat_type': 'dm',
                                                                                });
                                                                                await AddChatUsersCall.call(
                                                                                  user2: columnPublicUserProfileRow?.id,
                                                                                  communityId: '1',
                                                                                  chatId: _model.chat?.id,
                                                                                  anonKey: FFDevEnvironmentValues().AnonKey,
                                                                                  token: currentJwtToken,
                                                                                );

                                                                                context.pushNamed(
                                                                                  MessagePageWidget.routeName,
                                                                                  queryParameters: {
                                                                                    'chatId': serializeParam(
                                                                                      _model.chat?.id,
                                                                                      ParamType.String,
                                                                                    ),
                                                                                    'userId': serializeParam(
                                                                                      columnPublicUserProfileRow?.id,
                                                                                      ParamType.String,
                                                                                    ),
                                                                                  }.withoutNulls,
                                                                                );
                                                                              }

                                                                              safeSetState(() {});
                                                                            },
                                                                            text:
                                                                                'Message',
                                                                            options:
                                                                                FFButtonOptions(
                                                                              padding: EdgeInsetsDirectional.fromSTEB(16.0, 6.0, 16.0, 6.0),
                                                                              iconPadding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                                                                              color: FlutterFlowTheme.of(context).primaryL1,
                                                                              textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                                                                                    font: GoogleFonts.manrope(
                                                                                      fontWeight: FlutterFlowTheme.of(context).titleSmall.fontWeight,
                                                                                      fontStyle: FlutterFlowTheme.of(context).titleSmall.fontStyle,
                                                                                    ),
                                                                                    color: FlutterFlowTheme.of(context).primary,
                                                                                    fontSize: 14.0,
                                                                                    letterSpacing: 0.0,
                                                                                    fontWeight: FlutterFlowTheme.of(context).titleSmall.fontWeight,
                                                                                    fontStyle: FlutterFlowTheme.of(context).titleSmall.fontStyle,
                                                                                    lineHeight: 1.4,
                                                                                  ),
                                                                              elevation: 0.0,
                                                                              borderRadius: BorderRadius.circular(24.0),
                                                                            ),
                                                                            showLoadingIndicator:
                                                                                false,
                                                                          ),
                                                                        if (('${getJsonField(
                                                                                  FFAppState().AsSpecificGroupDetails,
                                                                                  r'''$.user_status''',
                                                                                ).toString()}' ==
                                                                                'admin') &&
                                                                            (listViewGroupAdminRow.userId !=
                                                                                currentUserUid) &&
                                                                            ('${getJsonField(
                                                                                  FFAppState().AsSpecificGroupDetails,
                                                                                  r'''$.creator_id''',
                                                                                ).toString()}' !=
                                                                                listViewGroupAdminRow.userId))
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
                                                                                      child: CompRevokeAdminWidget(
                                                                                        userId: listViewGroupAdminRow.userId,
                                                                                        groupId: widget!.groupId!,
                                                                                      ),
                                                                                    ),
                                                                                  );
                                                                                },
                                                                              ).then((value) => safeSetState(() {}));
                                                                            },
                                                                            text:
                                                                                'Revoke Role',
                                                                            options:
                                                                                FFButtonOptions(
                                                                              height: 24.0,
                                                                              padding: EdgeInsetsDirectional.fromSTEB(12.0, 0.0, 12.0, 0.0),
                                                                              iconPadding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                                                                              color: FlutterFlowTheme.of(context).greayL1,
                                                                              textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                                                                                    font: GoogleFonts.manrope(
                                                                                      fontWeight: FlutterFlowTheme.of(context).titleSmall.fontWeight,
                                                                                      fontStyle: FlutterFlowTheme.of(context).titleSmall.fontStyle,
                                                                                    ),
                                                                                    color: FlutterFlowTheme.of(context).extraBlack,
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
                                                                        if (('${getJsonField(
                                                                                  FFAppState().AsSpecificGroupDetails,
                                                                                  r'''$.user_status''',
                                                                                ).toString()}' ==
                                                                                'admin') &&
                                                                            (listViewGroupAdminRow.userId ==
                                                                                currentUserUid) &&
                                                                            ('${getJsonField(
                                                                                  FFAppState().AsSpecificGroupDetails,
                                                                                  r'''$.creator_id''',
                                                                                ).toString()}' !=
                                                                                listViewGroupAdminRow.userId))
                                                                          FFButtonWidget(
                                                                            onPressed:
                                                                                () async {
                                                                              _model.apiResultyty = await DeleteAdminCall.call(
                                                                                groupId: widget!.groupId,
                                                                                anonKey: FFDevEnvironmentValues().AnonKey,
                                                                                token: currentJwtToken,
                                                                                userId: currentUserUid,
                                                                              );

                                                                              safeSetState(() {});
                                                                            },
                                                                            text:
                                                                                'Resign Role',
                                                                            options:
                                                                                FFButtonOptions(
                                                                              height: 24.0,
                                                                              padding: EdgeInsetsDirectional.fromSTEB(12.0, 0.0, 12.0, 0.0),
                                                                              iconPadding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                                                                              color: FlutterFlowTheme.of(context).greayL1,
                                                                              textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                                                                                    font: GoogleFonts.manrope(
                                                                                      fontWeight: FlutterFlowTheme.of(context).titleSmall.fontWeight,
                                                                                      fontStyle: FlutterFlowTheme.of(context).titleSmall.fontStyle,
                                                                                    ),
                                                                                    color: FlutterFlowTheme.of(context).extraBlack,
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
                                                                        if (('${getJsonField(
                                                                                  FFAppState().AsSpecificGroupDetails,
                                                                                  r'''$.user_status''',
                                                                                ).toString()}' ==
                                                                                'admin') &&
                                                                            ('${getJsonField(
                                                                                  FFAppState().AsSpecificGroupDetails,
                                                                                  r'''$.creator_id''',
                                                                                ).toString()}' ==
                                                                                listViewGroupAdminRow.userId))
                                                                          FFButtonWidget(
                                                                            onPressed:
                                                                                () {},
                                                                            text:
                                                                                'Creator',
                                                                            options:
                                                                                FFButtonOptions(
                                                                              height: 24.0,
                                                                              padding: EdgeInsetsDirectional.fromSTEB(12.0, 0.0, 12.0, 0.0),
                                                                              iconPadding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                                                                              color: FlutterFlowTheme.of(context).primary,
                                                                              textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                                                                                    font: GoogleFonts.manrope(
                                                                                      fontWeight: FlutterFlowTheme.of(context).titleSmall.fontWeight,
                                                                                      fontStyle: FlutterFlowTheme.of(context).titleSmall.fontStyle,
                                                                                    ),
                                                                                    color: FlutterFlowTheme.of(context).secondaryBackground,
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
                                                                      ],
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                              Container(
                                                                width: double
                                                                    .infinity,
                                                                height: 1.0,
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .greayL1,
                                                                ),
                                                              ),
                                                            ],
                                                          );
                                                        },
                                                      );
                                                    },
                                                  );
                                                },
                                              ),
                                            ]
                                                .divide(SizedBox(height: 12.0))
                                                .addToStart(
                                                    SizedBox(height: 12.0))
                                                .addToEnd(
                                                    SizedBox(height: 12.0)),
                                          ),
                                        ),
                                      ),
                                  ],
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  20.0, 0.0, 0.0, 0.0),
                                          child: Text(
                                            'Similar Groups',
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                                  font: GoogleFonts.manrope(
                                                    fontWeight: FontWeight.w600,
                                                    fontStyle:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .bodyMedium
                                                            .fontStyle,
                                                  ),
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .extraBlack,
                                                  fontSize: 18.0,
                                                  letterSpacing: 0.0,
                                                  fontWeight: FontWeight.w600,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMedium
                                                          .fontStyle,
                                                  lineHeight: 1.4,
                                                ),
                                          ),
                                        ),
                                        if ('${getJsonField(
                                              FFAppState().AsGroupList,
                                              r'''$''',
                                            ).toString()}' !=
                                            '[]')
                                          Builder(
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
                                                    visible: widget!.groupId !=
                                                        getJsonField(
                                                          gropsItem,
                                                          r'''$.group_id''',
                                                        ).toString(),
                                                    child: Semantics(
                                                      button: true,
                                                      label: 'Open group',
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
                                                          constraints:
                                                              BoxConstraints(
                                                                  minHeight:
                                                                      56.0),
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
                                                                      AppNetworkImage(
                                                                        url: getJsonField(gropsItem,
                                                                                r'''$.profile_picture''')
                                                                            .toString(),
                                                                        width:
                                                                            40.0,
                                                                        height:
                                                                            40.0,
                                                                        fit: BoxFit
                                                                            .cover,
                                                                        borderRadius:
                                                                            BorderRadius.circular(2.0),
                                                                        semanticLabel:
                                                                            'Group cover photo',
                                                                      ),
                                                                      Expanded(
                                                                        child:
                                                                            Column(
                                                                          mainAxisSize:
                                                                              MainAxisSize.max,
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.start,
                                                                          children: [
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
                                                                          HapticFeedback
                                                                              .lightImpact();
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
                                                                              Colors.transparent,
                                                                          textStyle: FlutterFlowTheme.of(context)
                                                                              .titleSmall
                                                                              .override(
                                                                                font: GoogleFonts.manrope(
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
                                                                            () {},
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
                                                                              Colors.transparent,
                                                                          textStyle: FlutterFlowTheme.of(context)
                                                                              .titleSmall
                                                                              .override(
                                                                                font: GoogleFonts.manrope(
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
                                                                            () {},
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
                                                                                font: GoogleFonts.manrope(
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
                                                                          HapticFeedback
                                                                              .lightImpact();
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
                                                                              Colors.transparent,
                                                                          textStyle: FlutterFlowTheme.of(context)
                                                                              .titleSmall
                                                                              .override(
                                                                                font: GoogleFonts.manrope(
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
                                                                            () {},
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
                                                                              FlutterFlowTheme.of(context).primary,
                                                                          textStyle: FlutterFlowTheme.of(context)
                                                                              .titleSmall
                                                                              .override(
                                                                                font: GoogleFonts.manrope(
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
                                                                  ],
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                },
                                              );
                                            },
                                          ),
                                      ]
                                          .addToStart(SizedBox(height: 12.0))
                                          .addToEnd(SizedBox(height: 12.0)),
                                    ),
                                  ),
                                ),
                              ].addToEnd(SizedBox(height: 20.0)),
                            ),
                          ),
                        ),
                      ),
                    ),
                  if (_model.loader)
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color:
                              FlutterFlowTheme.of(context).secondaryBackground,
                        ),
                        child: _buildLoadingSkeleton(context),
                      ),
                    ),
                  // Failed / missing fetch: this branch used to be absent, so a
                  // failure left the screen blank forever (ui-review §2.7).
                  if (!_model.loader &&
                      (FFAppState().AsSpecificGroupDetails == null))
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color:
                              FlutterFlowTheme.of(context).secondaryBackground,
                        ),
                        child: EmptyState(
                          icon: Icons.wifi_off_rounded,
                          title: 'Could not load this group',
                          body:
                              'We could not reach this group right now. Check your connection and try again.',
                          actionLabel: 'Retry',
                          onAction: () => _reloadGroupDetails(),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
