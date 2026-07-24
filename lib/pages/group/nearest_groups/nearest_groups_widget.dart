import '/pages/group/group_list_refresh.dart';
import '/components/empty_state.dart';
import '/components/app_network_image.dart';
import '/auth/supabase_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'nearest_groups_model.dart';
export 'nearest_groups_model.dart';

class NearestGroupsWidget extends StatefulWidget {
  const NearestGroupsWidget({super.key});

  static String routeName = 'NearestGroups';
  static String routePath = 'nearestGroups';

  @override
  State<NearestGroupsWidget> createState() => _NearestGroupsWidgetState();
}

class _NearestGroupsWidgetState extends State<NearestGroupsWidget> {
  late NearestGroupsModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => NearestGroupsModel());
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
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        body: SafeArea(
          top: true,
          bottom: true,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Padding(
                        padding:
                            EdgeInsetsDirectional.fromSTEB(0.0, 8.0, 0.0, 0.0),
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
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    10.0, 12.0, 20.0, 8.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        color: FlutterFlowTheme.of(context)
                                            .secondaryBackground,
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
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
                                          Text(
                                            'Near You',
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
                                        ].divide(SizedBox(width: 10.0)),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                width: double.infinity,
                                height: 1.0,
                                decoration: BoxDecoration(
                                  color: FlutterFlowTheme.of(context)
                                      .secondaryBackground,
                                ),
                              ),
                              Container(
                                width: double.infinity,
                                height: 1.0,
                                decoration: BoxDecoration(
                                  color: FlutterFlowTheme.of(context).greyL2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: FlutterFlowTheme.of(context)
                                .secondaryBackground,
                          ),
                          child: RefreshIndicator(
                            onRefresh: () => handleGroupListRefresh(context),
                            color: FlutterFlowTheme.of(context).primary,
                            backgroundColor: FlutterFlowTheme.of(context)
                                .secondaryBackground,
                            child: Visibility(
                              visible: '${getJsonField(
                                    FFAppState().AsGroupList,
                                    r'''$''',
                                  ).toString()}' !=
                                  '[]',
                              replacement: ListView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                padding: EdgeInsets.fromLTRB(0, 48.0, 0, 24.0),
                                children: [
                                  EmptyState(
                                    icon: Icons.groups_2_outlined,
                                    title: 'No groups nearby yet',
                                    body:
                                        'Groups created around your neighbourhood will show up here. Pull down to refresh.',
                                  ),
                                ],
                              ),
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
                                    physics:
                                        const AlwaysScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    scrollDirection: Axis.vertical,
                                    itemCount: grops.length,
                                    separatorBuilder: (_, __) =>
                                        SizedBox(height: 12.0),
                                    itemBuilder: (context, gropsIndex) {
                                      final gropsItem = grops[gropsIndex];
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
                                        child: Semantics(
                                          button: true,
                                          label: 'Open group',
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
                                                GroupDetailsWidget.routeName,
                                                queryParameters: {
                                                  'groupId': serializeParam(
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
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .secondaryBackground,
                                              ),
                                              child: Padding(
                                                padding: EdgeInsetsDirectional
                                                    .fromSTEB(
                                                        20.0, 8.0, 20.0, 8.0),
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
                                                            MainAxisSize.max,
                                                        children: [
                                                          AppNetworkImage(
                                                            url: getJsonField(
                                                                    gropsItem,
                                                                    r'''$.profile_picture''')
                                                                .toString(),
                                                            width: 40.0,
                                                            height: 40.0,
                                                            fit: BoxFit.cover,
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
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .max,
                                                                    children: [
                                                                      AppNetworkImage(
                                                                        url: getJsonField(gropsItem,
                                                                                r'''$.invited_by_profile_picture''')
                                                                            .toString(),
                                                                        width:
                                                                            12.0,
                                                                        height:
                                                                            12.0,
                                                                        fit: BoxFit
                                                                            .cover,
                                                                        isAvatar:
                                                                            true,
                                                                        semanticLabel:
                                                                            'Inviter profile photo',
                                                                      ),
                                                                      Expanded(
                                                                        child:
                                                                            Text(
                                                                          '${getJsonField(
                                                                            gropsItem,
                                                                            r'''$.invited_by_name''',
                                                                          ).toString()} invited you to join this group ',
                                                                          maxLines:
                                                                              1,
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
                                                                      ),
                                                                    ].divide(SizedBox(
                                                                        width:
                                                                            6.0)),
                                                                  ),
                                                                Text(
                                                                  getJsonField(
                                                                    gropsItem,
                                                                    r'''$.name''',
                                                                  ).toString(),
                                                                  maxLines: 1,
                                                                  style: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMedium
                                                                      .override(
                                                                        font: GoogleFonts
                                                                            .manrope(
                                                                          fontWeight:
                                                                              FontWeight.w600,
                                                                          fontStyle: FlutterFlowTheme.of(context)
                                                                              .bodyMedium
                                                                              .fontStyle,
                                                                        ),
                                                                        color: FlutterFlowTheme.of(context)
                                                                            .extraBlack,
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
                                                                if ('${getJsonField(
                                                                      gropsItem,
                                                                      r'''$.user_status''',
                                                                    ).toString()}' !=
                                                                    'invite')
                                                                  Text(
                                                                    '${getJsonField(
                                                                      gropsItem,
                                                                      r'''$.total_members''',
                                                                    ).toString()} ${'${getJsonField(
                                                                          gropsItem,
                                                                          r'''$.total_members''',
                                                                        ).toString()}' == '1' ? 'member' : 'members'}',
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
                                                                              12.0,
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
                                                                'requested_date':
                                                                    supaSerialize<
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
                                                              height: 24.0,
                                                              padding:
                                                                  EdgeInsetsDirectional
                                                                      .fromSTEB(
                                                                          16.0,
                                                                          0.0,
                                                                          16.0,
                                                                          0.0),
                                                              iconPadding:
                                                                  EdgeInsetsDirectional
                                                                      .fromSTEB(
                                                                          0.0,
                                                                          0.0,
                                                                          0.0,
                                                                          0.0),
                                                              color: Colors
                                                                  .transparent,
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
                                                                        color: FlutterFlowTheme.of(context)
                                                                            .primaryD3,
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
                                                              elevation: 0.0,
                                                              borderSide:
                                                                  BorderSide(
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .primaryD3,
                                                                width: 1.0,
                                                              ),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .only(
                                                                topLeft: Radius
                                                                    .circular(
                                                                        100.0),
                                                                topRight: Radius
                                                                    .circular(
                                                                        100.0),
                                                                bottomLeft: Radius
                                                                    .circular(
                                                                        100.0),
                                                                bottomRight: Radius
                                                                    .circular(
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
                                                            onPressed: () {},
                                                            text: 'Joined',
                                                            icon: Icon(
                                                              Icons.done_all,
                                                              size: 15.0,
                                                            ),
                                                            options:
                                                                FFButtonOptions(
                                                              height: 24.0,
                                                              padding:
                                                                  EdgeInsetsDirectional
                                                                      .fromSTEB(
                                                                          16.0,
                                                                          0.0,
                                                                          16.0,
                                                                          0.0),
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
                                                                      .greyL4,
                                                              color: Colors
                                                                  .transparent,
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
                                                                        color: FlutterFlowTheme.of(context)
                                                                            .greyL4,
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
                                                              elevation: 0.0,
                                                              borderSide:
                                                                  BorderSide(
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .greyL4,
                                                                width: 1.0,
                                                              ),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .only(
                                                                topLeft: Radius
                                                                    .circular(
                                                                        100.0),
                                                                topRight: Radius
                                                                    .circular(
                                                                        100.0),
                                                                bottomLeft: Radius
                                                                    .circular(
                                                                        100.0),
                                                                bottomRight: Radius
                                                                    .circular(
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
                                                            onPressed: () {},
                                                            text: 'Requested',
                                                            options:
                                                                FFButtonOptions(
                                                              height: 24.0,
                                                              padding:
                                                                  EdgeInsetsDirectional
                                                                      .fromSTEB(
                                                                          16.0,
                                                                          0.0,
                                                                          16.0,
                                                                          0.0),
                                                              iconPadding:
                                                                  EdgeInsetsDirectional
                                                                      .fromSTEB(
                                                                          0.0,
                                                                          0.0,
                                                                          0.0,
                                                                          0.0),
                                                              color: FlutterFlowTheme
                                                                      .of(context)
                                                                  .greyL2,
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
                                                                        color: FlutterFlowTheme.of(context)
                                                                            .greyL3,
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
                                                              elevation: 0.0,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .only(
                                                                topLeft: Radius
                                                                    .circular(
                                                                        100.0),
                                                                topRight: Radius
                                                                    .circular(
                                                                        100.0),
                                                                bottomLeft: Radius
                                                                    .circular(
                                                                        100.0),
                                                                bottomRight: Radius
                                                                    .circular(
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
                                                                    supaSerialize<
                                                                            DateTime>(
                                                                        functions
                                                                            .getCurrentUtcTime()),
                                                              });
                                                            },
                                                            text: 'Request',
                                                            icon: Icon(
                                                              Icons
                                                                  .lock_outline_sharp,
                                                              size: 15.0,
                                                            ),
                                                            options:
                                                                FFButtonOptions(
                                                              height: 24.0,
                                                              padding:
                                                                  EdgeInsetsDirectional
                                                                      .fromSTEB(
                                                                          16.0,
                                                                          0.0,
                                                                          16.0,
                                                                          0.0),
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
                                                                      .primaryD3,
                                                              color: Colors
                                                                  .transparent,
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
                                                                        color: FlutterFlowTheme.of(context)
                                                                            .primaryD3,
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
                                                              elevation: 0.0,
                                                              borderSide:
                                                                  BorderSide(
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .primaryD3,
                                                                width: 1.0,
                                                              ),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .only(
                                                                topLeft: Radius
                                                                    .circular(
                                                                        100.0),
                                                                topRight: Radius
                                                                    .circular(
                                                                        100.0),
                                                                bottomLeft: Radius
                                                                    .circular(
                                                                        100.0),
                                                                bottomRight: Radius
                                                                    .circular(
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
                                                            onPressed: () {},
                                                            text: 'Admin',
                                                            options:
                                                                FFButtonOptions(
                                                              height: 24.0,
                                                              padding:
                                                                  EdgeInsetsDirectional
                                                                      .fromSTEB(
                                                                          12.0,
                                                                          0.0,
                                                                          12.0,
                                                                          0.0),
                                                              iconPadding:
                                                                  EdgeInsetsDirectional
                                                                      .fromSTEB(
                                                                          0.0,
                                                                          0.0,
                                                                          0.0,
                                                                          0.0),
                                                              color: FlutterFlowTheme
                                                                      .of(context)
                                                                  .primary,
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
                                                              elevation: 0.0,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .only(
                                                                topLeft: Radius
                                                                    .circular(
                                                                        100.0),
                                                                topRight: Radius
                                                                    .circular(
                                                                        100.0),
                                                                bottomLeft: Radius
                                                                    .circular(
                                                                        100.0),
                                                                bottomRight: Radius
                                                                    .circular(
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
                                                                    true,
                                                                'is_member':
                                                                    true,
                                                                'joined_at': supaSerialize<
                                                                        DateTime>(
                                                                    functions
                                                                        .getCurrentUtcTime()),
                                                                'is_approved':
                                                                    true,
                                                                'invited_by':
                                                                    getJsonField(
                                                                  gropsItem,
                                                                  r'''$.invited_by_user_id''',
                                                                ).toString(),
                                                              });
                                                              await GroupMembersInviteTable()
                                                                  .update(
                                                                data: {
                                                                  'is_member':
                                                                      true,
                                                                },
                                                                matchingRows:
                                                                    (rows) => rows
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
                                                              height: 24.0,
                                                              padding:
                                                                  EdgeInsetsDirectional
                                                                      .fromSTEB(
                                                                          16.0,
                                                                          0.0,
                                                                          16.0,
                                                                          0.0),
                                                              iconPadding:
                                                                  EdgeInsetsDirectional
                                                                      .fromSTEB(
                                                                          0.0,
                                                                          0.0,
                                                                          0.0,
                                                                          0.0),
                                                              color: Colors
                                                                  .transparent,
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
                                                                        color: FlutterFlowTheme.of(context)
                                                                            .primaryD3,
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
                                                              elevation: 0.0,
                                                              borderSide:
                                                                  BorderSide(
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .primaryD3,
                                                                width: 1.0,
                                                              ),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .only(
                                                                topLeft: Radius
                                                                    .circular(
                                                                        100.0),
                                                                topRight: Radius
                                                                    .circular(
                                                                        100.0),
                                                                bottomLeft: Radius
                                                                    .circular(
                                                                        100.0),
                                                                bottomRight: Radius
                                                                    .circular(
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
                                                              HapticFeedback
                                                                  .lightImpact();
                                                              await GroupUserStatusTable()
                                                                  .update(
                                                                data: {
                                                                  'is_requested':
                                                                      true,
                                                                  'requested_date': supaSerialize<
                                                                          DateTime>(
                                                                      functions
                                                                          .getCurrentUtcTime()),
                                                                },
                                                                matchingRows:
                                                                    (rows) => rows
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
                                                            text: 'Request',
                                                            icon: Icon(
                                                              Icons
                                                                  .lock_outline_sharp,
                                                              size: 15.0,
                                                            ),
                                                            options:
                                                                FFButtonOptions(
                                                              height: 24.0,
                                                              padding:
                                                                  EdgeInsetsDirectional
                                                                      .fromSTEB(
                                                                          16.0,
                                                                          0.0,
                                                                          16.0,
                                                                          0.0),
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
                                                                      .primaryD3,
                                                              color: Colors
                                                                  .transparent,
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
                                                                        color: FlutterFlowTheme.of(context)
                                                                            .primaryD3,
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
                                                              elevation: 0.0,
                                                              borderSide:
                                                                  BorderSide(
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .primaryD3,
                                                                width: 1.0,
                                                              ),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .only(
                                                                topLeft: Radius
                                                                    .circular(
                                                                        100.0),
                                                                topRight: Radius
                                                                    .circular(
                                                                        100.0),
                                                                bottomLeft: Radius
                                                                    .circular(
                                                                        100.0),
                                                                bottomRight: Radius
                                                                    .circular(
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
                                      )
                                          .animate()
                                          .fadeIn(
                                              duration: 260.ms,
                                              delay: (40 * (gropsIndex % 8)).ms)
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
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
