import '/components/app_icon_button.dart';
import '/components/app_network_image.dart';
import '/components/empty_state.dart';
import '/auth/supabase_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/backend/supabase/supabase.dart';
import '/components/comp_pageview_widget.dart';
import '/components/comp_share_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/pages/home/comp_likes/comp_likes_widget.dart';
import '/pages/home/comp_loading/comp_loading_widget.dart';
import '/pages/home/comp_report_post/comp_report_post_widget.dart';
import '/pages/home/comp_three_dot_block_user/comp_three_dot_block_user_widget.dart';
import '/pages/home/comp_three_dot_edit_post/comp_three_dot_edit_post_widget.dart';
import 'dart:ui';
import '/custom_code/widgets/index.dart' as custom_widgets;
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';
import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'user_all_post_model.dart';
export 'user_all_post_model.dart';

class UserAllPostWidget extends StatefulWidget {
  const UserAllPostWidget({
    super.key,
    required this.userid,
  });

  final String? userid;

  static String routeName = 'UserAllPost';
  static String routePath = 'userAllPost';

  @override
  State<UserAllPostWidget> createState() => _UserAllPostWidgetState();
}

class _UserAllPostWidgetState extends State<UserAllPostWidget> {
  late UserAllPostModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => UserAllPostModel());
  }

  /// Pull-to-refresh handler: re-downloads the shared visible-post feed.
  Future<void> _refreshPosts() async {
    final ApiCallResponse postResponse = await GetPostCall.call(
      anonKey: FFDevEnvironmentValues().AnonKey,
      token: currentJwtToken,
    );

    FFAppState().AsPost = getJsonField(
      (postResponse.jsonBody ?? ''),
      r'''$''',
    );
    safeSetState(() {});
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
          child: InkWell(
            splashColor: FlutterFlowTheme.of(context).primary.withAlpha(0x14),
            focusColor: Colors.transparent,
            hoverColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onTap: () async {
              _model.postReportId = ' ';
              safeSetState(() {});
            },
            child: Container(
              decoration: BoxDecoration(
                color: FlutterFlowTheme.of(context).pageBack,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: FlutterFlowTheme.of(context).white,
                    ),
                    child: Padding(
                      padding:
                          EdgeInsetsDirectional.fromSTEB(0.0, 12.0, 0.0, 12.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Align(
                            alignment: AlignmentDirectional(-1.0, 0.0),
                            child: Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  10.0, 0.0, 0.0, 0.0),
                              child: AppIconButton(
                                icon: Icons.arrow_back,
                                semanticLabel: 'Back',
                                tooltip: 'Back',
                                iconSize: 24.0,
                                color: FlutterFlowTheme.of(context).extraBlack,
                                onTap: () async {
                                  context.safePop();
                                },
                              ),
                            ),
                          ),
                          Text(
                            'All Posts',
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
                        ],
                      ),
                    ),
                  ),
                  if (false)
                    Expanded(
                      child: FutureBuilder<List<PostRow>>(
                        future: PostTable().queryRows(
                          queryFn: (q) => q
                              .eqOrNull(
                                'user_id',
                                widget!.userid,
                              )
                              .eqOrNull(
                                'is_deleted',
                                false,
                              )
                              .order('created_at'),
                        ),
                        builder: (context, snapshot) {
                          // Customize what your widget looks like when it's loading.
                          if (!snapshot.hasData) {
                            return Center(
                              child: SizedBox(
                                width: 50.0,
                                height: 50.0,
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    FlutterFlowTheme.of(context).primary,
                                  ),
                                ),
                              ),
                            );
                          }
                          List<PostRow> postListViewPostRowList =
                              snapshot.data!;

                          return SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              children:
                                  List.generate(postListViewPostRowList.length,
                                      (postListViewIndex) {
                                final postListViewPostRow =
                                    postListViewPostRowList[postListViewIndex];
                                return Container(
                                  decoration: BoxDecoration(
                                    color: FlutterFlowTheme.of(context).white,
                                  ),
                                  child: FutureBuilder<ApiCallResponse>(
                                    future: GetPostUserDataCall.call(
                                      pPostid: postListViewPostRow.id,
                                      token: currentJwtToken,
                                      pUserid: widget!.userid,
                                    ),
                                    builder: (context, snapshot) {
                                      // Customize what your widget looks like when it's loading.
                                      if (!snapshot.hasData) {
                                        return CompLoadingWidget(
                                          name: 'singlePost',
                                        );
                                      }
                                      final columnGetPostUserDataResponse =
                                          snapshot.data!;

                                      return Column(
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          Column(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Padding(
                                                padding: EdgeInsetsDirectional
                                                    .fromSTEB(
                                                        20.0, 0.0, 14.0, 0.0),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Row(
                                                      mainAxisSize:
                                                          MainAxisSize.max,
                                                      children: [
                                                        Container(
                                                          width: 32.0,
                                                          height: 32.0,
                                                          clipBehavior:
                                                              Clip.antiAlias,
                                                          decoration:
                                                              BoxDecoration(
                                                            shape:
                                                                BoxShape.circle,
                                                          ),
                                                          child: Image.network(
                                                            getJsonField(
                                                              columnGetPostUserDataResponse
                                                                  .jsonBody,
                                                              r'''$.profile_image''',
                                                            ).toString(),
                                                            fit: BoxFit.cover,
                                                          ),
                                                        ),
                                                        Column(
                                                          mainAxisSize:
                                                              MainAxisSize.max,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              getJsonField(
                                                                columnGetPostUserDataResponse
                                                                    .jsonBody,
                                                                r'''$.name''',
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
                                                            Row(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .max,
                                                              children: [
                                                                Text(
                                                                  getJsonField(
                                                                    columnGetPostUserDataResponse
                                                                        .jsonBody,
                                                                    r'''$.city''',
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
                                                                            .greyL4,
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
                                                                Container(
                                                                  width: 2.0,
                                                                  height: 2.0,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: FlutterFlowTheme.of(
                                                                            context)
                                                                        .greyL4,
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            24.0),
                                                                  ),
                                                                ),
                                                                Text(
                                                                  dateTimeFormat(
                                                                      "relative",
                                                                      postListViewPostRow
                                                                          .createdAt),
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
                                                                            .greyL4,
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
                                                                Container(
                                                                  width: 2.0,
                                                                  height: 2.0,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: FlutterFlowTheme.of(
                                                                            context)
                                                                        .greyL4,
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            24.0),
                                                                  ),
                                                                ),
                                                                Container(
                                                                  width: 8.0,
                                                                  height: 8.0,
                                                                  clipBehavior:
                                                                      Clip.antiAlias,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    shape: BoxShape
                                                                        .circle,
                                                                  ),
                                                                  child: Image
                                                                      .asset(
                                                                    'assets/images/public.png',
                                                                    fit: BoxFit
                                                                        .cover,
                                                                  ),
                                                                ),
                                                              ].divide(SizedBox(
                                                                  width: 4.0)),
                                                            ),
                                                          ],
                                                        ),
                                                      ].divide(
                                                          SizedBox(width: 8.0)),
                                                    ),
                                                    Row(
                                                      mainAxisSize:
                                                          MainAxisSize.max,
                                                      children: [
                                                        InkWell(
                                                          splashColor:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .primary
                                                                  .withAlpha(
                                                                      0x14),
                                                          focusColor: Colors
                                                              .transparent,
                                                          hoverColor: Colors
                                                              .transparent,
                                                          highlightColor: Colors
                                                              .transparent,
                                                          onTap: () async {
                                                            await AddFollowCall
                                                                .call(
                                                              pFollowerid:
                                                                  currentUserUid,
                                                              pFollowingid:
                                                                  postListViewPostRow
                                                                      .userId,
                                                              pCommunityid:
                                                                  FFAppState()
                                                                      .communityId,
                                                              token:
                                                                  currentJwtToken,
                                                            );

                                                            safeSetState(() =>
                                                                _model.requestCompleter =
                                                                    null);
                                                            await _model
                                                                .waitForRequestCompleted();
                                                          },
                                                          child: Container(
                                                            decoration:
                                                                BoxDecoration(),
                                                            child: Padding(
                                                              padding:
                                                                  EdgeInsetsDirectional
                                                                      .fromSTEB(
                                                                          6.0,
                                                                          6.0,
                                                                          6.0,
                                                                          6.0),
                                                              child: FutureBuilder<
                                                                  List<
                                                                      FollowsRow>>(
                                                                future: (_model.requestCompleter ??= Completer<
                                                                        List<
                                                                            FollowsRow>>()
                                                                      ..complete(
                                                                          FollowsTable()
                                                                              .querySingleRow(
                                                                        queryFn: (q) => q
                                                                            .eqOrNull(
                                                                              'follower_id',
                                                                              currentUserUid,
                                                                            )
                                                                            .eqOrNull(
                                                                              'following_id',
                                                                              postListViewPostRow.userId,
                                                                            ),
                                                                      )))
                                                                    .future,
                                                                builder: (context,
                                                                    snapshot) {
                                                                  // Customize what your widget looks like when it's loading.
                                                                  if (!snapshot
                                                                      .hasData) {
                                                                    return CompLoadingWidget(
                                                                      name:
                                                                          'followPost',
                                                                    );
                                                                  }
                                                                  List<FollowsRow>
                                                                      stackFollowsRowList =
                                                                      snapshot
                                                                          .data!;

                                                                  final stackFollowsRow = stackFollowsRowList
                                                                          .isNotEmpty
                                                                      ? stackFollowsRowList
                                                                          .first
                                                                      : null;

                                                                  return Stack(
                                                                    children: [
                                                                      if ((stackFollowsRow?.id == null ||
                                                                              stackFollowsRow?.id ==
                                                                                  '') &&
                                                                          (postListViewPostRow.userId !=
                                                                              currentUserUid))
                                                                        Row(
                                                                          mainAxisSize:
                                                                              MainAxisSize.max,
                                                                          children:
                                                                              [
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
                                                                      if ((stackFollowsRow?.id != null &&
                                                                              stackFollowsRow?.id !=
                                                                                  '') &&
                                                                          (postListViewPostRow.userId !=
                                                                              currentUserUid))
                                                                        Row(
                                                                          mainAxisSize:
                                                                              MainAxisSize.max,
                                                                          children:
                                                                              [
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
                                                        Transform.rotate(
                                                          angle: 90.0 *
                                                              (math.pi / 180),
                                                          child: InkWell(
                                                            splashColor:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .primary
                                                                    .withAlpha(
                                                                        0x14),
                                                            focusColor: Colors
                                                                .transparent,
                                                            hoverColor: Colors
                                                                .transparent,
                                                            highlightColor:
                                                                Colors
                                                                    .transparent,
                                                            onTap: () async {
                                                              if (postListViewPostRow
                                                                      .userId ==
                                                                  currentUserUid) {
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
                                                                            CompThreeDotEditPostWidget(
                                                                          postId:
                                                                              postListViewPostRow.id,
                                                                          groupId:
                                                                              postListViewPostRow.groupId,
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
                                                                            CompThreeDotBlockUserWidget(
                                                                          reportedByUserId:
                                                                              currentUserUid,
                                                                          reportedUserId:
                                                                              postListViewPostRow.userId,
                                                                          blockedUserName:
                                                                              getJsonField(
                                                                            columnGetPostUserDataResponse.jsonBody,
                                                                            r'''$.name''',
                                                                          ).toString(),
                                                                          reportType:
                                                                              'post',
                                                                        ),
                                                                      ),
                                                                    );
                                                                  },
                                                                ).then((value) =>
                                                                    safeSetState(
                                                                        () {}));
                                                              }
                                                            },
                                                            child: Container(
                                                              decoration:
                                                                  BoxDecoration(),
                                                              child: Padding(
                                                                padding:
                                                                    EdgeInsetsDirectional
                                                                        .fromSTEB(
                                                                            6.0,
                                                                            6.0,
                                                                            6.0,
                                                                            6.0),
                                                                child: Icon(
                                                                  Icons
                                                                      .keyboard_control,
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .primaryText,
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
                                              Padding(
                                                padding: EdgeInsetsDirectional
                                                    .fromSTEB(
                                                        20.0, 0.0, 20.0, 0.0),
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  children: [
                                                    Row(
                                                      mainAxisSize:
                                                          MainAxisSize.max,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .end,
                                                      children: [
                                                        if (_model.postReadId !=
                                                            postListViewPostRow
                                                                .id)
                                                          Expanded(
                                                            child: Text(
                                                              postListViewPostRow
                                                                  .content
                                                                  .maybeHandleOverflow(
                                                                maxChars: 99,
                                                                replacement:
                                                                    '…',
                                                              ),
                                                              textAlign:
                                                                  TextAlign
                                                                      .start,
                                                              maxLines: 2,
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
                                                          ),
                                                        if (_model.postReadId ==
                                                            postListViewPostRow
                                                                .id)
                                                          Expanded(
                                                            child: Text(
                                                              postListViewPostRow
                                                                  .content,
                                                              textAlign:
                                                                  TextAlign
                                                                      .start,
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
                                                          ),
                                                      ],
                                                    ),
                                                    if ((postListViewPostRow
                                                                .content
                                                                .length >
                                                            100) ==
                                                        true)
                                                      Align(
                                                        alignment:
                                                            AlignmentDirectional(
                                                                1.0, -1.0),
                                                        child: Column(
                                                          mainAxisSize:
                                                              MainAxisSize.max,
                                                          children: [
                                                            InkWell(
                                                              splashColor:
                                                                  FlutterFlowTheme.of(
                                                                          context)
                                                                      .primary
                                                                      .withAlpha(
                                                                          0x14),
                                                              focusColor: Colors
                                                                  .transparent,
                                                              hoverColor: Colors
                                                                  .transparent,
                                                              highlightColor:
                                                                  Colors
                                                                      .transparent,
                                                              onTap: () async {
                                                                if (_model
                                                                        .postReadId ==
                                                                    postListViewPostRow
                                                                        .id) {
                                                                  _model.postReadId =
                                                                      null;
                                                                  safeSetState(
                                                                      () {});
                                                                } else {
                                                                  _model.postReadId =
                                                                      postListViewPostRow
                                                                          .id;
                                                                  safeSetState(
                                                                      () {});
                                                                }
                                                              },
                                                              child: Container(
                                                                decoration:
                                                                    BoxDecoration(),
                                                                child: Padding(
                                                                  padding: EdgeInsetsDirectional
                                                                      .fromSTEB(
                                                                          6.0,
                                                                          6.0,
                                                                          6.0,
                                                                          6.0),
                                                                  child: Text(
                                                                    valueOrDefault<
                                                                        String>(
                                                                      _model.postReadId !=
                                                                              postListViewPostRow.id
                                                                          ? 'Read More'
                                                                          : 'Read Less',
                                                                      'Read More',
                                                                    ),
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
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                              ),
                                              if ((getJsonField(
                                                        columnGetPostUserDataResponse
                                                            .jsonBody,
                                                        r'''$.images_count''',
                                                      ) ==
                                                      0) ==
                                                  false)
                                                Column(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  children: [
                                                    if ((getJsonField(
                                                              columnGetPostUserDataResponse
                                                                  .jsonBody,
                                                              r'''$.images_count''',
                                                            ) ==
                                                            1) ==
                                                        true)
                                                      ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(0.0),
                                                        child: Image.network(
                                                          getJsonField(
                                                            columnGetPostUserDataResponse
                                                                .jsonBody,
                                                            r'''$.images[0]''',
                                                          ).toString(),
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    if ((getJsonField(
                                                              columnGetPostUserDataResponse
                                                                  .jsonBody,
                                                              r'''$.images_count''',
                                                            ) >
                                                            1) ==
                                                        true)
                                                      CompPageviewWidget(
                                                        key: Key(
                                                            'Key5jc_${postListViewIndex}_of_${postListViewPostRowList.length}'),
                                                        images: getJsonField(
                                                          columnGetPostUserDataResponse
                                                              .jsonBody,
                                                          r'''$.images''',
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                            ].divide(SizedBox(height: 12.0)),
                                          ),
                                          Padding(
                                            padding:
                                                EdgeInsetsDirectional.fromSTEB(
                                                    14.0, 0.0, 14.0, 0.0),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.max,
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Row(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  children: [
                                                    InkWell(
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
                                                        _model.addlike =
                                                            await AddLikeCall
                                                                .call(
                                                          pCommunityid:
                                                              FFAppState()
                                                                  .communityId
                                                                  .toString(),
                                                          pUserid:
                                                              currentUserUid,
                                                          pPostid:
                                                              postListViewPostRow
                                                                  .id,
                                                          token:
                                                              currentJwtToken,
                                                        );

                                                        safeSetState(() {});
                                                      },
                                                      child: Container(
                                                        decoration:
                                                            BoxDecoration(),
                                                        child: Padding(
                                                          padding:
                                                              EdgeInsetsDirectional
                                                                  .fromSTEB(
                                                                      6.0,
                                                                      6.0,
                                                                      4.0,
                                                                      6.0),
                                                          child: Stack(
                                                            children: [
                                                              Icon(
                                                                Icons
                                                                    .favorite_border,
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .greyL4,
                                                                size: 22.0,
                                                              ),
                                                              FutureBuilder<
                                                                  List<
                                                                      PostLikeRow>>(
                                                                future: PostLikeTable()
                                                                    .querySingleRow(
                                                                  queryFn: (q) => q
                                                                      .eqOrNull(
                                                                        'post_id',
                                                                        postListViewPostRow
                                                                            .id,
                                                                      )
                                                                      .eqOrNull(
                                                                        'user_id',
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
                                                                          'no',
                                                                    );
                                                                  }
                                                                  List<PostLikeRow>
                                                                      iconPostLikeRowList =
                                                                      snapshot
                                                                          .data!;

                                                                  // Return an empty Container when the item does not exist.
                                                                  if (snapshot
                                                                      .data!
                                                                      .isEmpty) {
                                                                    return Container();
                                                                  }
                                                                  final iconPostLikeRow = iconPostLikeRowList
                                                                          .isNotEmpty
                                                                      ? iconPostLikeRowList
                                                                          .first
                                                                      : null;

                                                                  return Icon(
                                                                    Icons
                                                                        .favorite,
                                                                    color: FlutterFlowTheme.of(
                                                                            context)
                                                                        .redColor2,
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
                                                                    CompLikesWidget(
                                                                  postId:
                                                                      postListViewPostRow
                                                                          .id,
                                                                  postUserid:
                                                                      postListViewPostRow
                                                                          .userId,
                                                                ),
                                                              ),
                                                            );
                                                          },
                                                        ).then((value) =>
                                                            safeSetState(
                                                                () {}));
                                                      },
                                                      child: Container(
                                                        decoration:
                                                            BoxDecoration(),
                                                        child: Padding(
                                                          padding:
                                                              EdgeInsetsDirectional
                                                                  .fromSTEB(
                                                                      0.0,
                                                                      9.0,
                                                                      16.0,
                                                                      9.0),
                                                          child: Text(
                                                            valueOrDefault<
                                                                String>(
                                                              postListViewPostRow
                                                                  .likesCount
                                                                  ?.toString(),
                                                              '0',
                                                            ),
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
                                                        ),
                                                      ),
                                                    ),
                                                  ].divide(
                                                      SizedBox(width: 4.0)),
                                                ),
                                                InkWell(
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
                                                      CommentsPageWidget
                                                          .routeName,
                                                      queryParameters: {
                                                        'postId':
                                                            serializeParam(
                                                          postListViewPostRow
                                                              .id,
                                                          ParamType.String,
                                                        ),
                                                      }.withoutNulls,
                                                    );
                                                  },
                                                  child: Container(
                                                    decoration: BoxDecoration(),
                                                    child: Padding(
                                                      padding:
                                                          EdgeInsetsDirectional
                                                              .fromSTEB(
                                                                  6.0,
                                                                  6.0,
                                                                  6.0,
                                                                  6.0),
                                                      child: Row(
                                                        mainAxisSize:
                                                            MainAxisSize.max,
                                                        children: [
                                                          ClipRRect(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        0.0),
                                                            child: Image.asset(
                                                              'assets/images/forum.png',
                                                              width: 22.0,
                                                              height: 22.0,
                                                              fit: BoxFit.cover,
                                                            ),
                                                          ),
                                                          Text(
                                                            valueOrDefault<
                                                                String>(
                                                              postListViewPostRow
                                                                  .commentCount
                                                                  ?.toString(),
                                                              '0',
                                                            ),
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
                                                        ].divide(SizedBox(
                                                            width: 4.0)),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                InkWell(
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
                                                    await showModalBottomSheet(
                                                      isScrollControlled: true,
                                                      backgroundColor:
                                                          Colors.transparent,
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
                                                                CompShareWidget(
                                                              pagename: 'post',
                                                              id: postListViewPostRow
                                                                  .id,
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    ).then((value) =>
                                                        safeSetState(() {}));
                                                  },
                                                  child: Container(
                                                    decoration: BoxDecoration(),
                                                    child: Padding(
                                                      padding:
                                                          EdgeInsetsDirectional
                                                              .fromSTEB(
                                                                  6.0,
                                                                  6.0,
                                                                  6.0,
                                                                  6.0),
                                                      child: Row(
                                                        mainAxisSize:
                                                            MainAxisSize.max,
                                                        children: [
                                                          ClipRRect(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        0.0),
                                                            child: Image.asset(
                                                              'assets/images/share_windows.png',
                                                              width: 22.0,
                                                              height: 22.0,
                                                              fit: BoxFit.cover,
                                                            ),
                                                          ),
                                                          Text(
                                                            valueOrDefault<
                                                                String>(
                                                              postListViewPostRow
                                                                  .shareCount
                                                                  ?.toString(),
                                                              '0',
                                                            ),
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
                                                        ].divide(SizedBox(
                                                            width: 4.0)),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ]
                                            .divide(SizedBox(height: 4.0))
                                            .addToStart(SizedBox(height: 12.0))
                                            .addToEnd(SizedBox(height: 6.0)),
                                      );
                                    },
                                  ),
                                );
                              }),
                            ),
                          );
                        },
                      ),
                    ),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: _refreshPosts,
                      color: FlutterFlowTheme.of(context).primary,
                      child: Builder(
                        builder: (context) {
                          final posts = functions
                              .returnLimitedPosts(
                                  FFAppState().AsPost, 0, widget!.userid!)
                              .toList();

                          // Designed empty state instead of a blank screen.
                          if (posts.isEmpty) {
                            return ListView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              children: <Widget>[
                                EmptyState(
                                  icon: Icons.forum_outlined,
                                  title: 'No posts yet',
                                  body:
                                      'Posts shared with your neighbourhood will show up here.',
                                ),
                              ],
                            );
                          }

                          return SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              children:
                                  List.generate(posts.length, (postsIndex) {
                                final postsItem = posts[postsIndex];
                                return Stack(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        color:
                                            FlutterFlowTheme.of(context).white,
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          Column(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Padding(
                                                padding: EdgeInsetsDirectional
                                                    .fromSTEB(
                                                        20.0, 0.0, 14.0, 0.0),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    InkWell(
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
                                                        if (getJsonField(
                                                              postsItem,
                                                              r'''$.user_id''',
                                                            ) !=
                                                            currentUserUid) {
                                                          context.pushNamed(
                                                            OtherProfileWidget
                                                                .routeName,
                                                            queryParameters: {
                                                              'userid':
                                                                  serializeParam(
                                                                getJsonField(
                                                                  postsItem,
                                                                  r'''$.user_id''',
                                                                ).toString(),
                                                                ParamType
                                                                    .String,
                                                              ),
                                                            }.withoutNulls,
                                                          );
                                                        } else {
                                                          context.pushNamed(
                                                              UserProfileWidget
                                                                  .routeName);
                                                        }
                                                      },
                                                      child: Row(
                                                        mainAxisSize:
                                                            MainAxisSize.max,
                                                        children: [
                                                          Container(
                                                            width: 32.0,
                                                            height: 32.0,
                                                            clipBehavior:
                                                                Clip.antiAlias,
                                                            decoration:
                                                                BoxDecoration(
                                                              shape: BoxShape
                                                                  .circle,
                                                            ),
                                                            child:
                                                                AppNetworkImage(
                                                              url: getJsonField(
                                                                postsItem,
                                                                r'''$.user_profile_picture''',
                                                              ).toString(),
                                                              width: 32.0,
                                                              height: 32.0,
                                                              fit: BoxFit.cover,
                                                              fallbackIcon: Icons
                                                                  .person_rounded,
                                                              semanticLabel:
                                                                  '${getJsonField(
                                                                postsItem,
                                                                r'''$.user_name''',
                                                              ).toString()} profile photo',
                                                            ),
                                                          ),
                                                          Column(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .max,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(
                                                                getJsonField(
                                                                  postsItem,
                                                                  r'''$.user_name''',
                                                                ).toString(),
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
                                                              Row(
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .max,
                                                                children: [
                                                                  Text(
                                                                    getJsonField(
                                                                      postsItem,
                                                                      r'''$.user_city''',
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
                                                                  Container(
                                                                    width: 2.0,
                                                                    height: 2.0,
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      color: FlutterFlowTheme.of(
                                                                              context)
                                                                          .greyL4,
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              24.0),
                                                                    ),
                                                                  ),
                                                                  Text(
                                                                    functions
                                                                        .returnRelativeTIme(
                                                                            getJsonField(
                                                                      postsItem,
                                                                      r'''$.created_at''',
                                                                    ).toString()),
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
                                                                  Container(
                                                                    width: 2.0,
                                                                    height: 2.0,
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      color: FlutterFlowTheme.of(
                                                                              context)
                                                                          .greyL4,
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              24.0),
                                                                    ),
                                                                  ),
                                                                  Container(
                                                                    width: 8.0,
                                                                    height: 8.0,
                                                                    clipBehavior:
                                                                        Clip.antiAlias,
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      shape: BoxShape
                                                                          .circle,
                                                                    ),
                                                                    child: Image
                                                                        .asset(
                                                                      'assets/images/public.png',
                                                                      fit: BoxFit
                                                                          .cover,
                                                                    ),
                                                                  ),
                                                                ].divide(SizedBox(
                                                                    width:
                                                                        4.0)),
                                                              ),
                                                            ],
                                                          ),
                                                        ].divide(SizedBox(
                                                            width: 8.0)),
                                                      ),
                                                    ),
                                                    Row(
                                                      mainAxisSize:
                                                          MainAxisSize.max,
                                                      children: [
                                                        InkWell(
                                                          splashColor:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .primary
                                                                  .withAlpha(
                                                                      0x14),
                                                          focusColor: Colors
                                                              .transparent,
                                                          hoverColor: Colors
                                                              .transparent,
                                                          highlightColor: Colors
                                                              .transparent,
                                                          onTap: () async {
                                                            await AddFollowCall
                                                                .call(
                                                              pFollowerid:
                                                                  currentUserUid,
                                                              pFollowingid:
                                                                  getJsonField(
                                                                postsItem,
                                                                r'''$.user_id''',
                                                              ).toString(),
                                                              pCommunityid:
                                                                  FFAppState()
                                                                      .communityId,
                                                              token:
                                                                  currentJwtToken,
                                                            );
                                                          },
                                                          child: Container(
                                                            decoration:
                                                                BoxDecoration(),
                                                            child: Padding(
                                                              padding:
                                                                  EdgeInsetsDirectional
                                                                      .fromSTEB(
                                                                          6.0,
                                                                          6.0,
                                                                          6.0,
                                                                          6.0),
                                                              child: FutureBuilder<
                                                                  List<
                                                                      FollowsRow>>(
                                                                future: FollowsTable()
                                                                    .querySingleRow(
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
                                                                builder: (context,
                                                                    snapshot) {
                                                                  // Customize what your widget looks like when it's loading.
                                                                  if (!snapshot
                                                                      .hasData) {
                                                                    return CompLoadingWidget(
                                                                      name:
                                                                          'followPost',
                                                                    );
                                                                  }
                                                                  List<FollowsRow>
                                                                      stackFollowsRowList =
                                                                      snapshot
                                                                          .data!;

                                                                  final stackFollowsRow = stackFollowsRowList
                                                                          .isNotEmpty
                                                                      ? stackFollowsRowList
                                                                          .first
                                                                      : null;

                                                                  return Stack(
                                                                    children: [
                                                                      if ((stackFollowsRow?.id == null ||
                                                                              stackFollowsRow?.id == '') &&
                                                                          (getJsonField(
                                                                                postsItem,
                                                                                r'''$.user_id''',
                                                                              ) !=
                                                                              currentUserUid))
                                                                        Row(
                                                                          mainAxisSize:
                                                                              MainAxisSize.max,
                                                                          children:
                                                                              [
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
                                                                      if ((stackFollowsRow?.followingId != null &&
                                                                              stackFollowsRow?.followingId != '') &&
                                                                          (getJsonField(
                                                                                postsItem,
                                                                                r'''$.user_id''',
                                                                              ) !=
                                                                              currentUserUid))
                                                                        Row(
                                                                          mainAxisSize:
                                                                              MainAxisSize.max,
                                                                          children:
                                                                              [
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
                                                        Transform.rotate(
                                                          angle: 90.0 *
                                                              (math.pi / 180),
                                                          child: InkWell(
                                                            splashColor:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .primary
                                                                    .withAlpha(
                                                                        0x14),
                                                            focusColor: Colors
                                                                .transparent,
                                                            hoverColor: Colors
                                                                .transparent,
                                                            highlightColor:
                                                                Colors
                                                                    .transparent,
                                                            onTap: () async {
                                                              if (widget!
                                                                      .userid ==
                                                                  currentUserUid) {
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
                                                                            CompThreeDotEditPostWidget(
                                                                          postId:
                                                                              getJsonField(
                                                                            postsItem,
                                                                            r'''$.id''',
                                                                          ).toString(),
                                                                          groupId:
                                                                              getJsonField(
                                                                            postsItem,
                                                                            r'''$.group_id''',
                                                                          ).toString(),
                                                                        ),
                                                                      ),
                                                                    );
                                                                  },
                                                                ).then((value) =>
                                                                    safeSetState(
                                                                        () {}));

                                                                _model.postReadId =
                                                                    null;
                                                                safeSetState(
                                                                    () {});
                                                              } else {
                                                                _model.postReportId =
                                                                    getJsonField(
                                                                  postsItem,
                                                                  r'''$.id''',
                                                                ).toString();
                                                                safeSetState(
                                                                    () {});
                                                              }
                                                            },
                                                            child: Container(
                                                              decoration:
                                                                  BoxDecoration(),
                                                              child: Padding(
                                                                padding:
                                                                    EdgeInsetsDirectional
                                                                        .fromSTEB(
                                                                            6.0,
                                                                            6.0,
                                                                            6.0,
                                                                            6.0),
                                                                child: Icon(
                                                                  Icons
                                                                      .keyboard_control,
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .primaryText,
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
                                                          20.0, 0.0, 20.0, 0.0),
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    children: [
                                                      Row(
                                                        mainAxisSize:
                                                            MainAxisSize.max,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .end,
                                                        children: [
                                                          if (_model
                                                                  .postReadId !=
                                                              getJsonField(
                                                                postsItem,
                                                                r'''$.id''',
                                                              ).toString())
                                                            Expanded(
                                                              child: Text(
                                                                getJsonField(
                                                                  postsItem,
                                                                  r'''$.content''',
                                                                )
                                                                    .toString()
                                                                    .maybeHandleOverflow(
                                                                      maxChars:
                                                                          99,
                                                                      replacement:
                                                                          '…',
                                                                    ),
                                                                textAlign:
                                                                    TextAlign
                                                                        .start,
                                                                maxLines: 2,
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
                                                            ),
                                                          if (_model
                                                                  .postReadId ==
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
                                                                textAlign:
                                                                    TextAlign
                                                                        .start,
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
                                                            ),
                                                        ],
                                                      ),
                                                      if ((getJsonField(
                                                                postsItem,
                                                                r'''$.content''',
                                                              )
                                                                  .toString()
                                                                  .length >
                                                              100) ==
                                                          true)
                                                        Align(
                                                          alignment:
                                                              AlignmentDirectional(
                                                                  1.0, -1.0),
                                                          child: Column(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .max,
                                                            children: [
                                                              InkWell(
                                                                splashColor: FlutterFlowTheme.of(
                                                                        context)
                                                                    .primary
                                                                    .withAlpha(
                                                                        0x14),
                                                                focusColor: Colors
                                                                    .transparent,
                                                                hoverColor: Colors
                                                                    .transparent,
                                                                highlightColor:
                                                                    Colors
                                                                        .transparent,
                                                                onTap:
                                                                    () async {
                                                                  if (_model
                                                                          .postReadId ==
                                                                      getJsonField(
                                                                        postsItem,
                                                                        r'''$.id''',
                                                                      ).toString()) {
                                                                    _model.postReadId =
                                                                        null;
                                                                    safeSetState(
                                                                        () {});
                                                                  } else {
                                                                    _model.postReadId =
                                                                        getJsonField(
                                                                      postsItem,
                                                                      r'''$.id''',
                                                                    ).toString();
                                                                    safeSetState(
                                                                        () {});
                                                                  }
                                                                },
                                                                child:
                                                                    Container(
                                                                  decoration:
                                                                      BoxDecoration(),
                                                                  child:
                                                                      Padding(
                                                                    padding: EdgeInsetsDirectional
                                                                        .fromSTEB(
                                                                            6.0,
                                                                            6.0,
                                                                            6.0,
                                                                            6.0),
                                                                    child: Text(
                                                                      valueOrDefault<
                                                                          String>(
                                                                        _model.postReadId !=
                                                                                getJsonField(
                                                                                  postsItem,
                                                                                  r'''$.id''',
                                                                                ).toString()
                                                                            ? 'Read More'
                                                                            : 'Read Less',
                                                                        'Read More',
                                                                      ),
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
                                                                                FlutterFlowTheme.of(context).greyL4,
                                                                            fontSize:
                                                                                12.0,
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
                                                        20.0, 0.0, 20.0, 0.0),
                                                child:
                                                    custom_widgets.ShowContent(
                                                  width: double.infinity,
                                                  height: 200.0,
                                                  currentUserId: currentUserUid,
                                                  richTextContent: getJsonField(
                                                    postsItem,
                                                    r'''$.content''',
                                                  ),
                                                  tldrContent: getJsonField(
                                                    postsItem,
                                                    r'''$.tldr''',
                                                  ).toString(),
                                                ),
                                              ),
                                              if (((String var1) {
                                                    return var1 != "null";
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
                                                                .map<String>((e) =>
                                                                    e.toString())
                                                                .toList()
                                                                .cast<String>()
                                                                .length ==
                                                            1) ==
                                                        true)
                                                      ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(0.0),
                                                        child: AppNetworkImage(
                                                          url: getJsonField(
                                                            postsItem,
                                                            r'''$.post_images[0]''',
                                                          ).toString(),
                                                          width:
                                                              double.infinity,
                                                          fit: BoxFit.contain,
                                                          semanticLabel:
                                                              'Post photo',
                                                        ),
                                                      ),
                                                    if (((getJsonField(
                                                              postsItem,
                                                              r'''$.post_images''',
                                                              true,
                                                            ) as List?)!
                                                                .map<String>((e) =>
                                                                    e.toString())
                                                                .toList()
                                                                .cast<String>()
                                                                .length >
                                                            1) ==
                                                        true)
                                                      CompPageviewWidget(
                                                        key: Key(
                                                            'Keysf4_${postsIndex}_of_${posts.length}'),
                                                        images: getJsonField(
                                                          postsItem,
                                                          r'''$.post_images''',
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                            ].divide(SizedBox(height: 10.0)),
                                          ),
                                          Padding(
                                            padding:
                                                EdgeInsetsDirectional.fromSTEB(
                                                    14.0, 0.0, 14.0, 0.0),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.max,
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Row(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  children: [
                                                    InkWell(
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
                                                        _model.addlike2 =
                                                            await AddLikeCall
                                                                .call(
                                                          pCommunityid:
                                                              FFAppState()
                                                                  .communityId
                                                                  .toString(),
                                                          pUserid:
                                                              currentUserUid,
                                                          pPostid: getJsonField(
                                                            postsItem,
                                                            r'''$.id''',
                                                          ).toString(),
                                                          token:
                                                              currentJwtToken,
                                                        );

                                                        safeSetState(() {});
                                                      },
                                                      child: Container(
                                                        decoration:
                                                            BoxDecoration(),
                                                        child: Padding(
                                                          padding:
                                                              EdgeInsetsDirectional
                                                                  .fromSTEB(
                                                                      6.0,
                                                                      6.0,
                                                                      4.0,
                                                                      6.0),
                                                          child: Stack(
                                                            children: [
                                                              Icon(
                                                                Icons
                                                                    .favorite_border,
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .greyL4,
                                                                size: 22.0,
                                                              ),
                                                              FutureBuilder<
                                                                  List<
                                                                      PostLikeRow>>(
                                                                future: PostLikeTable()
                                                                    .querySingleRow(
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
                                                                builder: (context,
                                                                    snapshot) {
                                                                  // Customize what your widget looks like when it's loading.
                                                                  if (!snapshot
                                                                      .hasData) {
                                                                    return Container(
                                                                      width:
                                                                          22.0,
                                                                      height:
                                                                          22.0,
                                                                      child:
                                                                          CompLoadingWidget(
                                                                        name:
                                                                            'like',
                                                                      ),
                                                                    );
                                                                  }
                                                                  List<PostLikeRow>
                                                                      iconPostLikeRowList =
                                                                      snapshot
                                                                          .data!;

                                                                  // Return an empty Container when the item does not exist.
                                                                  if (snapshot
                                                                      .data!
                                                                      .isEmpty) {
                                                                    return Container();
                                                                  }
                                                                  final iconPostLikeRow = iconPostLikeRowList
                                                                          .isNotEmpty
                                                                      ? iconPostLikeRowList
                                                                          .first
                                                                      : null;

                                                                  return Icon(
                                                                    Icons
                                                                        .favorite,
                                                                    color: FlutterFlowTheme.of(
                                                                            context)
                                                                        .redColor2,
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
                                                                    CompLikesWidget(
                                                                  postId:
                                                                      getJsonField(
                                                                    postsItem,
                                                                    r'''$.id''',
                                                                  ).toString(),
                                                                  postUserid:
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
                                                        decoration:
                                                            BoxDecoration(),
                                                        child: Padding(
                                                          padding:
                                                              EdgeInsetsDirectional
                                                                  .fromSTEB(
                                                                      0.0,
                                                                      9.0,
                                                                      16.0,
                                                                      9.0),
                                                          child: Text(
                                                            valueOrDefault<
                                                                String>(
                                                              getJsonField(
                                                                postsItem,
                                                                r'''$.likes_count''',
                                                              )?.toString(),
                                                              '0',
                                                            ),
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
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                InkWell(
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
                                                    if ('${getJsonField(
                                                          postsItem,
                                                          r'''$.comment_post_access_id''',
                                                        ).toString()}' ==
                                                        '1') {
                                                      context.pushNamed(
                                                        CommentsPageWidget
                                                            .routeName,
                                                        queryParameters: {
                                                          'postId':
                                                              serializeParam(
                                                            getJsonField(
                                                              postsItem,
                                                              r'''$.id''',
                                                            ).toString(),
                                                            ParamType.String,
                                                          ),
                                                        }.withoutNulls,
                                                      );
                                                    }
                                                  },
                                                  child: Container(
                                                    width: 70.0,
                                                    decoration: BoxDecoration(),
                                                    child: Padding(
                                                      padding:
                                                          EdgeInsetsDirectional
                                                              .fromSTEB(
                                                                  6.0,
                                                                  6.0,
                                                                  6.0,
                                                                  6.0),
                                                      child: Row(
                                                        mainAxisSize:
                                                            MainAxisSize.max,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          if ('${getJsonField(
                                                                postsItem,
                                                                r'''$.comment_post_access_id''',
                                                              ).toString()}' ==
                                                              '1')
                                                            ClipRRect(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          0.0),
                                                              child:
                                                                  Image.asset(
                                                                'assets/images/forum.png',
                                                                width: 22.0,
                                                                height: 22.0,
                                                                fit: BoxFit
                                                                    .cover,
                                                              ),
                                                            ),
                                                          if ('${getJsonField(
                                                                postsItem,
                                                                r'''$.comment_post_access_id''',
                                                              ).toString()}' ==
                                                              '4')
                                                            ClipRRect(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          0.0),
                                                              child:
                                                                  Image.asset(
                                                                'assets/images/forum.webp',
                                                                width: 22.0,
                                                                height: 22.0,
                                                                fit: BoxFit
                                                                    .cover,
                                                              ),
                                                            ),
                                                          Text(
                                                            valueOrDefault<
                                                                String>(
                                                              getJsonField(
                                                                postsItem,
                                                                r'''$.comment_count''',
                                                              )?.toString(),
                                                              '0',
                                                            ),
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
                                                        ].divide(SizedBox(
                                                            width: 4.0)),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                InkWell(
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
                                                    await showModalBottomSheet(
                                                      isScrollControlled: true,
                                                      backgroundColor:
                                                          Colors.transparent,
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
                                                                CompShareWidget(
                                                              pagename: 'post',
                                                              id: getJsonField(
                                                                postsItem,
                                                                r'''$.id''',
                                                              ).toString(),
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    ).then((value) =>
                                                        safeSetState(() {}));
                                                  },
                                                  child: Container(
                                                    width: 70.0,
                                                    decoration: BoxDecoration(),
                                                    child: Padding(
                                                      padding:
                                                          EdgeInsetsDirectional
                                                              .fromSTEB(
                                                                  6.0,
                                                                  6.0,
                                                                  6.0,
                                                                  6.0),
                                                      child: Row(
                                                        mainAxisSize:
                                                            MainAxisSize.max,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          ClipRRect(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        0.0),
                                                            child: Image.asset(
                                                              'assets/images/share_windows.png',
                                                              width: 22.0,
                                                              height: 22.0,
                                                              fit: BoxFit.cover,
                                                            ),
                                                          ),
                                                          Text(
                                                            valueOrDefault<
                                                                String>(
                                                              getJsonField(
                                                                postsItem,
                                                                r'''$.share_count''',
                                                              )?.toString(),
                                                              '0',
                                                            ),
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
                                                        ].divide(SizedBox(
                                                            width: 4.0)),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ]
                                            .divide(SizedBox(height: 4.0))
                                            .addToStart(SizedBox(height: 12.0))
                                            .addToEnd(SizedBox(height: 6.0)),
                                      ),
                                    ),
                                    if ('${getJsonField(
                                          postsItem,
                                          r'''$.id''',
                                        ).toString()}' ==
                                        _model.postReportId)
                                      Align(
                                        alignment:
                                            AlignmentDirectional(1.0, -1.0),
                                        child: Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  0.0, 36.0, 36.0, 0.0),
                                          child: InkWell(
                                            splashColor:
                                                FlutterFlowTheme.of(context)
                                                    .primary
                                                    .withAlpha(0x14),
                                            focusColor: Colors.transparent,
                                            hoverColor: Colors.transparent,
                                            highlightColor: Colors.transparent,
                                            onTap: () async {
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
                                                      FocusManager
                                                          .instance.primaryFocus
                                                          ?.unfocus();
                                                    },
                                                    child: Padding(
                                                      padding: MediaQuery
                                                          .viewInsetsOf(
                                                              context),
                                                      child:
                                                          CompReportPostWidget(
                                                        postId: getJsonField(
                                                          postsItem,
                                                          r'''$.id''',
                                                        ).toString(),
                                                        userId: getJsonField(
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
                                            child: Container(
                                              width: 140.0,
                                              height: 38.0,
                                              decoration: BoxDecoration(
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .secondaryBackground,
                                                boxShadow: [
                                                  FlutterFlowTheme.of(context)
                                                      .designToken
                                                      .shadow
                                                      .md,
                                                ],
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                              ),
                                              child: Padding(
                                                padding: EdgeInsetsDirectional
                                                    .fromSTEB(
                                                        16.0, 0.0, 0.0, 0.0),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  children: [
                                                    ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8.0),
                                                      child: Image.asset(
                                                        'assets/images/flag_2.webp',
                                                        width: 20.0,
                                                        height: 20.0,
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                    Text(
                                                      'Report Post',
                                                      style:
                                                          FlutterFlowTheme.of(
                                                                  context)
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
                                                                    .greyD1,
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
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                );
                              }).divide(SizedBox(height: 8.0)),
                            ),
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
    );
  }
}
