import '/components/empty_state.dart';
import '/components/app_icon_button.dart';
import '/components/app_network_image.dart';
import '/auth/supabase_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/backend/supabase/supabase.dart';
import '/components/comp_share_widget.dart';
import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/pages/home/comp_likes/comp_likes_widget.dart';
import '/pages/home/comp_loading/comp_loading_widget.dart';
import '/pages/home/comp_three_dot_block_user/comp_three_dot_block_user_widget.dart';
import '/pages/home/comp_three_dot_edit_post/comp_three_dot_edit_post_widget.dart';
import 'dart:math';
import 'dart:ui';
import '/custom_code/actions/index.dart' as actions;
import '/custom_code/widgets/index.dart' as custom_widgets;
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';
import 'dart:async';
import 'dart:math' as math;
import 'package:smooth_page_indicator/smooth_page_indicator.dart'
    as smooth_page_indicator;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'comments_page_model.dart';
export 'comments_page_model.dart';

class CommentsPageWidget extends StatefulWidget {
  const CommentsPageWidget({
    super.key,
    required this.postId,
    this.previousPage,
  });

  final String? postId;
  final String? previousPage;

  static String routeName = 'CommentsPage';
  static String routePath = 'commentsPage';

  @override
  State<CommentsPageWidget> createState() => _CommentsPageWidgetState();
}

class _CommentsPageWidgetState extends State<CommentsPageWidget>
    with TickerProviderStateMixin {
  late CommentsPageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  final animationsMap = <String, AnimationInfo>{};

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => CommentsPageModel());

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      await Future.wait([
        Future(() async {
          _model.apiResultpio = await GetPostAllCommentsCall.call(
            pPostId: widget!.postId,
            token: currentJwtToken,
          );

          FFAppState().AsComments = getJsonField(
            (_model.apiResultpio?.jsonBody ?? ''),
            r'''$.comments''',
          );
          FFAppState().AsCommentReplies = getJsonField(
            (_model.apiResultpio?.jsonBody ?? ''),
            r'''$.replies''',
          );
          safeSetState(() {});
          await actions.initRealtimeCommentUpdates();
          await actions.unsubscribe(
            'post',
          );
          await Future.delayed(
            Duration(
              milliseconds: 1000,
            ),
          );
          await actions.subscribe(
            'post',
            () async {
              safeSetState(() => _model.requestCompleter1 = null);
              await _model.waitForRequestCompleted1();
            },
          );
        }),
        Future(() async {
          _model.apiResultmhc = await GetPostUserDataCall.call(
            pPostid: widget!.postId,
            token: currentJwtToken,
            pUserid: currentUserUid,
          );

          FFAppState().showReply = false;
          safeSetState(() {});
          if ((_model.apiResultmhc?.succeeded ?? true)) {
            _model.postData = (_model.apiResultmhc?.jsonBody ?? '');
            safeSetState(() {});
          }
        }),
      ]);
      _model.showData = true;
      safeSetState(() {});
    });

    _model.textController1 ??= TextEditingController();
    _model.textFieldFocusNode ??= FocusNode();

    _model.replyTextFieldTextController ??= TextEditingController();
    _model.replyTextFieldFocusNode ??= FocusNode();

    animationsMap.addAll({
      'containerOnPageLoadAnimation': AnimationInfo(
        trigger: AnimationTrigger.onPageLoad,
        effectsBuilder: () => [
          VisibilityEffect(duration: 1500.ms),
          MoveEffect(
            curve: Curves.easeInOut,
            delay: 1500.0.ms,
            duration: 600.0.ms,
            begin: Offset(0.0, 30.0),
            end: Offset(0.0, 0.0),
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

  /// True when the post has no comments at all. `AsComments` is `dynamic`: the
  /// API returns null before the first load and an EMPTY LIST for a post nobody
  /// has commented on, and only the null case used to show an empty state.
  bool get _hasNoComments {
    final dynamic comments = FFAppState().AsComments;
    return comments == null || (comments is List && comments.isEmpty);
  }

  /// Pull-to-refresh: re-fetches the post row, its comments and its replies.
  /// Mirrors the exact calls the page makes on load, so the refreshed state is
  /// identical to a cold open (no partial/no-op refresh).
  Future<void> _refreshComments() async {
    // Dropping the completer makes the post-row FutureBuilder re-query on the
    // next build; `waitForRequestCompleted1` below waits for that round trip.
    safeSetState(() => _model.requestCompleter1 = null);

    _model.apiResultpio = await GetPostAllCommentsCall.call(
      pPostId: widget!.postId,
      token: currentJwtToken,
    );
    FFAppState().AsComments = getJsonField(
      (_model.apiResultpio?.jsonBody ?? ''),
      r'''$.comments''',
    );
    FFAppState().AsCommentReplies = getJsonField(
      (_model.apiResultpio?.jsonBody ?? ''),
      r'''$.replies''',
    );

    _model.apiResultmhc = await GetPostUserDataCall.call(
      pPostid: widget!.postId,
      token: currentJwtToken,
      pUserid: currentUserUid,
    );
    if ((_model.apiResultmhc?.succeeded ?? true)) {
      _model.postData = (_model.apiResultmhc?.jsonBody ?? '');
    }

    _model.showData = true;
    safeSetState(() {});
    await _model.waitForRequestCompleted1();
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
            child: FutureBuilder<List<PostRow>>(
              future: (_model.requestCompleter1 ??= Completer<List<PostRow>>()
                    ..complete(PostTable().querySingleRow(
                      queryFn: (q) => q.eqOrNull(
                        'id',
                        widget!.postId,
                      ),
                    )))
                  .future,
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
                List<PostRow> columnPostRowList = snapshot.data!;

                final columnPostRow = columnPostRowList.isNotEmpty
                    ? columnPostRowList.first
                    : null;

                return Column(
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Align(
                              alignment: AlignmentDirectional(-1.0, 0.0),
                              child: Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    10.0, 0.0, 0.0, 0.0),
                                child: FlutterFlowIconButton(
                                  borderRadius: 100.0,
                                  icon: Icon(
                                    Icons.arrow_back,
                                    color:
                                        FlutterFlowTheme.of(context).extraBlack,
                                    size: 24.0,
                                  ),
                                  onPressed: () async {
                                    if (widget!.previousPage == 'loading') {
                                      context
                                          .pushNamed(HomePageWidget.routeName);
                                    } else {
                                      context.safePop();
                                    }
                                  },
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  0.0, 0.0, 20.0, 0.0),
                              child: AppIconButton(
                                semanticLabel: 'More options for this post',
                                minTapTarget: 44.0,
                                enableHaptic: false,
                                onTap: () async {
                                  HapticFeedback.lightImpact();
                                  if (columnPostRow?.userId == currentUserUid) {
                                    await showModalBottomSheet(
                                      isScrollControlled: true,
                                      backgroundColor: Colors.transparent,
                                      context: context,
                                      builder: (context) {
                                        return GestureDetector(
                                          onTap: () {
                                            FocusScope.of(context).unfocus();
                                            FocusManager.instance.primaryFocus
                                                ?.unfocus();
                                          },
                                          child: Padding(
                                            padding: MediaQuery.viewInsetsOf(
                                                context),
                                            child: CompThreeDotEditPostWidget(
                                              postId: columnPostRow!.id,
                                              groupId: columnPostRow?.groupId,
                                            ),
                                          ),
                                        );
                                      },
                                    ).then((value) => safeSetState(() {}));
                                  } else {
                                    await showModalBottomSheet(
                                      isScrollControlled: true,
                                      backgroundColor: Colors.transparent,
                                      context: context,
                                      builder: (context) {
                                        return GestureDetector(
                                          onTap: () {
                                            FocusScope.of(context).unfocus();
                                            FocusManager.instance.primaryFocus
                                                ?.unfocus();
                                          },
                                          child: Padding(
                                            padding: MediaQuery.viewInsetsOf(
                                                context),
                                            child: CompThreeDotBlockUserWidget(
                                              reportedByUserId: currentUserUid,
                                              reportedUserId:
                                                  columnPostRow!.userId,
                                              blockedUserName: getJsonField(
                                                _model.postData,
                                                r'''$.name''',
                                              ).toString(),
                                              reportType: 'post',
                                            ),
                                          ),
                                        );
                                      },
                                    ).then((value) => safeSetState(() {}));
                                  }
                                },
                                iconWidget: ExcludeSemantics(
                                  child: Container(
                                    width: 34.0,
                                    height: 34.0,
                                    decoration: BoxDecoration(
                                      color:
                                          FlutterFlowTheme.of(context).greyL2,
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(100.0),
                                        topRight: Radius.circular(100.0),
                                        bottomLeft: Radius.circular(100.0),
                                        bottomRight: Radius.circular(100.0),
                                      ),
                                    ),
                                    alignment: AlignmentDirectional(0.0, 0.0),
                                    child: Transform.rotate(
                                      angle: 90.0 * (math.pi / 180),
                                      child: Icon(
                                        Icons.keyboard_control,
                                        color: FlutterFlowTheme.of(context)
                                            .primaryText,
                                        size: 16.0,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding:
                            EdgeInsetsDirectional.fromSTEB(0.0, 4.0, 0.0, 0.0),
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: FlutterFlowTheme.of(context).white,
                          ),
                          child: RefreshIndicator(
                            onRefresh: _refreshComments,
                            color: FlutterFlowTheme.of(context).primary,
                            child: SingleChildScrollView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  if (_model.showData)
                                    Column(
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
                                                mainAxisSize: MainAxisSize.max,
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  MergeSemantics(
                                                    child: Semantics(
                                                      button: true,
                                                      child: InkWell(
                                                        splashColor:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .primary
                                                                .withAlpha(
                                                                    0x14),
                                                        focusColor:
                                                            Colors.transparent,
                                                        hoverColor:
                                                            Colors.transparent,
                                                        highlightColor:
                                                            Colors.transparent,
                                                        onTap: () async {
                                                          HapticFeedback
                                                              .lightImpact();
                                                          context.pushNamed(
                                                            OtherProfileWidget
                                                                .routeName,
                                                            queryParameters: {
                                                              'userid':
                                                                  serializeParam(
                                                                columnPostRow
                                                                    ?.userId,
                                                                ParamType
                                                                    .String,
                                                              ),
                                                            }.withoutNulls,
                                                          );
                                                        },
                                                        child: Row(
                                                          mainAxisSize:
                                                              MainAxisSize.max,
                                                          children: [
                                                            AppNetworkImage(
                                                              url: getJsonField(
                                                                _model.postData,
                                                                r'''$.profile_image''',
                                                              ).toString(),
                                                              width: 32.0,
                                                              height: 32.0,
                                                              fit: BoxFit.cover,
                                                              isAvatar: true,
                                                              semanticLabel: 'Profile photo of ' +
                                                                  getJsonField(
                                                                          _model
                                                                              .postData,
                                                                          r'''$.name''')
                                                                      .toString(),
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
                                                                    _model
                                                                        .postData,
                                                                    r'''$.name''',
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
                                                                Row(
                                                                  mainAxisSize:
                                                                      MainAxisSize
                                                                          .max,
                                                                  children: [
                                                                    Text(
                                                                      getJsonField(
                                                                        _model
                                                                            .postData,
                                                                        r'''$.city''',
                                                                      ).toString(),
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
                                                                    Container(
                                                                      width:
                                                                          2.0,
                                                                      height:
                                                                          2.0,
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        color: FlutterFlowTheme.of(context)
                                                                            .greyL4,
                                                                        borderRadius:
                                                                            BorderRadius.circular(24.0),
                                                                      ),
                                                                    ),
                                                                    Text(
                                                                      dateTimeFormat(
                                                                          "relative",
                                                                          columnPostRow!
                                                                              .createdAt),
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
                                                                    Container(
                                                                      width:
                                                                          2.0,
                                                                      height:
                                                                          2.0,
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        color: FlutterFlowTheme.of(context)
                                                                            .greyL4,
                                                                        borderRadius:
                                                                            BorderRadius.circular(24.0),
                                                                      ),
                                                                    ),
                                                                    Container(
                                                                      width:
                                                                          8.0,
                                                                      height:
                                                                          8.0,
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
                                                    ),
                                                  ),
                                                  Row(
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    children: [
                                                      AppIconButton(
                                                        semanticLabel:
                                                            'Follow or unfollow ' +
                                                                getJsonField(
                                                                        _model
                                                                            .postData,
                                                                        r'''$.name''')
                                                                    .toString(),
                                                        minTapTarget: 44.0,
                                                        enableHaptic: false,
                                                        onTap: () async {
                                                          HapticFeedback
                                                              .lightImpact();
                                                          await AddFollowCall
                                                              .call(
                                                            pFollowerid:
                                                                currentUserUid,
                                                            pFollowingid:
                                                                columnPostRow
                                                                    ?.userId,
                                                            pCommunityid:
                                                                FFAppState()
                                                                    .communityId,
                                                            token:
                                                                currentJwtToken,
                                                          );

                                                          safeSetState(() =>
                                                              _model.requestCompleter3 =
                                                                  null);
                                                          await _model
                                                              .waitForRequestCompleted3();
                                                        },
                                                        iconWidget:
                                                            ExcludeSemantics(
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
                                                                future: (_model.requestCompleter3 ??= Completer<
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
                                                                              columnPostRow?.userId,
                                                                            )
                                                                            .eqOrNull(
                                                                              'community_id',
                                                                              FFAppState().communityId,
                                                                            ),
                                                                      )))
                                                                    .future,
                                                                builder: (context,
                                                                    snapshot) {
                                                                  // Customize what your widget looks like when it's loading.
                                                                  if (!snapshot
                                                                      .hasData) {
                                                                    return Center(
                                                                      child:
                                                                          SizedBox(
                                                                        width:
                                                                            50.0,
                                                                        height:
                                                                            50.0,
                                                                        child:
                                                                            CircularProgressIndicator(
                                                                          valueColor:
                                                                              AlwaysStoppedAnimation<Color>(
                                                                            FlutterFlowTheme.of(context).primary,
                                                                          ),
                                                                        ),
                                                                      ),
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
                                                                      if ((columnPostRow?.userId !=
                                                                              currentUserUid) &&
                                                                          (stackFollowsRow?.id == null ||
                                                                              stackFollowsRow?.id == ''))
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
                                                                      if (stackFollowsRow?.id !=
                                                                              null &&
                                                                          stackFollowsRow?.id !=
                                                                              '')
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
                                                        if (_model.postIdread !=
                                                            columnPostRow?.id)
                                                          Expanded(
                                                            child: Text(
                                                              columnPostRow!
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
                                                        if (_model.postIdread ==
                                                            columnPostRow?.id)
                                                          Expanded(
                                                            child: Text(
                                                              columnPostRow!
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
                                                        if ((columnPostRow!
                                                                    .content
                                                                    .length >
                                                                100) ==
                                                            true)
                                                          Column(
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
                                                                  HapticFeedback
                                                                      .lightImpact();
                                                                  if (_model
                                                                          .postIdread ==
                                                                      columnPostRow
                                                                          ?.id) {
                                                                    _model.postIdread =
                                                                        '123';
                                                                    safeSetState(
                                                                        () {});
                                                                  } else {
                                                                    _model.postIdread =
                                                                        widget!
                                                                            .postId!;
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
                                                                        _model.postIdread !=
                                                                                columnPostRow?.id
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
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            Padding(
                                              padding: EdgeInsetsDirectional
                                                  .fromSTEB(
                                                      20.0, 0.0, 20.0, 0.0),
                                              child: custom_widgets.ShowContent(
                                                width: double.infinity,
                                                height: 200.0,
                                                currentUserId: currentUserUid,
                                                richTextContent: functions
                                                    .textToJson(columnPostRow
                                                        ?.content)!,
                                                tldrContent:
                                                    columnPostRow?.tldr,
                                              ),
                                            ),
                                            if ((getJsonField(
                                                      _model.postData,
                                                      r'''$.images_count''',
                                                    ) >
                                                    1) ==
                                                true)
                                              Expanded(
                                                child: Builder(
                                                  builder: (context) {
                                                    final postImages =
                                                        getJsonField(
                                                      _model.postData,
                                                      r'''$.images''',
                                                    ).toList();

                                                    return Container(
                                                      width: double.infinity,
                                                      height: 500.0,
                                                      child: Stack(
                                                        children: [
                                                          PageView.builder(
                                                            controller: _model
                                                                    .pageViewController ??=
                                                                PageController(
                                                                    initialPage: max(
                                                                        0,
                                                                        min(
                                                                            0,
                                                                            postImages.length -
                                                                                1))),
                                                            scrollDirection:
                                                                Axis.horizontal,
                                                            itemCount:
                                                                postImages
                                                                    .length,
                                                            itemBuilder: (context,
                                                                postImagesIndex) {
                                                              final postImagesItem =
                                                                  postImages[
                                                                      postImagesIndex];
                                                              return Container(
                                                                width: double
                                                                    .infinity,
                                                                height: 260.0,
                                                                decoration:
                                                                    BoxDecoration(),
                                                              );
                                                            },
                                                          ),
                                                          Align(
                                                            alignment:
                                                                AlignmentDirectional(
                                                                    0.0, 1.0),
                                                            child: Padding(
                                                              padding:
                                                                  EdgeInsetsDirectional
                                                                      .fromSTEB(
                                                                          0.0,
                                                                          0.0,
                                                                          0.0,
                                                                          10.0),
                                                              child: smooth_page_indicator
                                                                  .SmoothPageIndicator(
                                                                controller: _model
                                                                        .pageViewController ??=
                                                                    PageController(
                                                                        initialPage: max(
                                                                            0,
                                                                            min(0,
                                                                                postImages.length - 1))),
                                                                count:
                                                                    postImages
                                                                        .length,
                                                                axisDirection: Axis
                                                                    .horizontal,
                                                                onDotClicked:
                                                                    (i) async {
                                                                  await _model
                                                                      .pageViewController!
                                                                      .animateToPage(
                                                                    i,
                                                                    duration: Duration(
                                                                        milliseconds:
                                                                            500),
                                                                    curve: Curves
                                                                        .ease,
                                                                  );
                                                                  safeSetState(
                                                                      () {});
                                                                },
                                                                effect: smooth_page_indicator
                                                                    .ExpandingDotsEffect(
                                                                  expansionFactor:
                                                                      4.0,
                                                                  spacing: 4.0,
                                                                  radius: 8.0,
                                                                  dotWidth: 8.0,
                                                                  dotHeight:
                                                                      4.0,
                                                                  dotColor: FlutterFlowTheme.of(
                                                                          context)
                                                                      .secondaryBackground,
                                                                  activeDotColor:
                                                                      FlutterFlowTheme.of(
                                                                              context)
                                                                          .secondaryBackground,
                                                                  paintStyle:
                                                                      PaintingStyle
                                                                          .fill,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                            if ((getJsonField(
                                                      _model.postData,
                                                      r'''$.images_count''',
                                                    ) ==
                                                    1) ==
                                                true)
                                              AppNetworkImage(
                                                url: getJsonField(
                                                  _model.postData,
                                                  r'''$.images[0]''',
                                                ).toString(),
                                                fit: BoxFit.cover,
                                                semanticLabel:
                                                    'Photo in post by ' +
                                                        getJsonField(
                                                                _model.postData,
                                                                r'''$.name''')
                                                            .toString(),
                                              ),
                                          ].divide(SizedBox(height: 12.0)),
                                        ),
                                        Container(
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                            color: FlutterFlowTheme.of(context)
                                                .secondaryBackground,
                                          ),
                                          child: Padding(
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
                                                    AppIconButton(
                                                      semanticLabel: 'Like, ' +
                                                          valueOrDefault<
                                                                  String>(
                                                              columnPostRow
                                                                  ?.likesCount
                                                                  ?.toString(),
                                                              '0') +
                                                          ' likes',
                                                      minTapTarget: 44.0,
                                                      enableHaptic: false,
                                                      onTap: () async {
                                                        HapticFeedback
                                                            .lightImpact();
                                                        _model.apiResult2gu =
                                                            await AddLikeCall
                                                                .call(
                                                          pCommunityid:
                                                              FFAppState()
                                                                  .communityId
                                                                  .toString(),
                                                          pUserid:
                                                              currentUserUid,
                                                          pPostid:
                                                              widget!.postId,
                                                          token:
                                                              currentJwtToken,
                                                        );

                                                        safeSetState(() => _model
                                                                .requestCompleter1 =
                                                            null);
                                                        await _model
                                                            .waitForRequestCompleted1();
                                                        safeSetState(() => _model
                                                                .requestCompleter2 =
                                                            null);
                                                        await _model
                                                            .waitForRequestCompleted2();

                                                        safeSetState(() {});
                                                      },
                                                      iconWidget:
                                                          ExcludeSemantics(
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
                                                                      .favorite_border_outlined,
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .greyL4,
                                                                  size: 24.0,
                                                                ),
                                                                FutureBuilder<
                                                                    List<
                                                                        PostLikeRow>>(
                                                                  future: (_model.requestCompleter2 ??= Completer<
                                                                          List<
                                                                              PostLikeRow>>()
                                                                        ..complete(
                                                                            PostLikeTable().querySingleRow(
                                                                          queryFn: (q) => q
                                                                              .eqOrNull(
                                                                                'post_id',
                                                                                widget!.postId,
                                                                              )
                                                                              .eqOrNull(
                                                                                'user_id',
                                                                                currentUserUid,
                                                                              ),
                                                                        )))
                                                                      .future,
                                                                  builder: (context,
                                                                      snapshot) {
                                                                    // Customize what your widget looks like when it's loading.
                                                                    if (!snapshot
                                                                        .hasData) {
                                                                      return Center(
                                                                        child:
                                                                            SizedBox(
                                                                          width:
                                                                              20.0,
                                                                          height:
                                                                              20.0,
                                                                          child:
                                                                              CircularProgressIndicator(
                                                                            valueColor:
                                                                                AlwaysStoppedAnimation<Color>(
                                                                              FlutterFlowTheme.of(context).primary,
                                                                            ),
                                                                          ),
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
                                                                          .primary,
                                                                      size:
                                                                          24.0,
                                                                    );
                                                                  },
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    AppIconButton(
                                                      semanticLabel:
                                                          'View who liked this post, ' +
                                                              valueOrDefault<
                                                                      String>(
                                                                  columnPostRow
                                                                      ?.likesCount
                                                                      ?.toString(),
                                                                  '0') +
                                                              ' likes',
                                                      minTapTarget: 44.0,
                                                      enableHaptic: false,
                                                      onTap: () async {
                                                        HapticFeedback
                                                            .lightImpact();
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
                                                                  postId: widget!
                                                                      .postId!,
                                                                  postUserid:
                                                                      columnPostRow!
                                                                          .userId,
                                                                ),
                                                              ),
                                                            );
                                                          },
                                                        ).then((value) =>
                                                            safeSetState(
                                                                () {}));
                                                      },
                                                      iconWidget:
                                                          ExcludeSemantics(
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
                                                                columnPostRow
                                                                    ?.likesCount
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
                                                    ),
                                                  ],
                                                ),
                                                Container(
                                                  decoration: BoxDecoration(),
                                                  child: Padding(
                                                    padding:
                                                        EdgeInsetsDirectional
                                                            .fromSTEB(6.0, 6.0,
                                                                6.0, 6.0),
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
                                                            columnPostRow
                                                                ?.commentCount
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
                                                      ].divide(
                                                          SizedBox(width: 4.0)),
                                                    ),
                                                  ),
                                                ),
                                                AppIconButton(
                                                  semanticLabel: 'Share, ' +
                                                      valueOrDefault<String>(
                                                          columnPostRow
                                                              ?.shareCount
                                                              ?.toString(),
                                                          '0') +
                                                      ' shares',
                                                  minTapTarget: 44.0,
                                                  enableHaptic: false,
                                                  onTap: () async {
                                                    HapticFeedback
                                                        .lightImpact();
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
                                                              id: widget!
                                                                  .postId!,
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    ).then((value) =>
                                                        safeSetState(() {}));
                                                  },
                                                  iconWidget: ExcludeSemantics(
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
                                                        child: Row(
                                                          mainAxisSize:
                                                              MainAxisSize.max,
                                                          children: [
                                                            ClipRRect(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          0.0),
                                                              child:
                                                                  Image.asset(
                                                                'assets/images/share_windows.png',
                                                                width: 22.0,
                                                                height: 22.0,
                                                                fit: BoxFit
                                                                    .cover,
                                                              ),
                                                            ),
                                                            Text(
                                                              valueOrDefault<
                                                                  String>(
                                                                columnPostRow
                                                                    ?.shareCount
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
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ]
                                          .divide(SizedBox(height: 4.0))
                                          .addToStart(SizedBox(height: 12.0))
                                          .addToEnd(SizedBox(height: 6.0)),
                                    ),
                                  if (!_model.showData)
                                    Container(
                                      width: 70.0,
                                      height: 70.0,
                                      child: custom_widgets.SimpleLoader(
                                        width: 70.0,
                                        height: 70.0,
                                      ),
                                    ),
                                  Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        20.0, 0.0, 20.0, 0.0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        FutureBuilder<ApiCallResponse>(
                                          future: GetlimitedPostLikesCall.call(
                                            pScreenwidth:
                                                MediaQuery.sizeOf(context)
                                                    .width,
                                            pPostid: widget!.postId,
                                            token: currentJwtToken,
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
                                            final columnGetlimitedPostLikesResponse =
                                                snapshot.data!;

                                            return Column(
                                              mainAxisSize: MainAxisSize.max,
                                              children: [
                                                if ('${columnGetlimitedPostLikesResponse.jsonBody.toString()}' !=
                                                    '[]')
                                                  Align(
                                                    alignment:
                                                        AlignmentDirectional(
                                                            -1.0, 0.0),
                                                    child: Text(
                                                      'Reactions',
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
                                                  ),
                                                if ('${columnGetlimitedPostLikesResponse.jsonBody.toString()}' !=
                                                    '[]')
                                                  Row(
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    children: [
                                                      Builder(
                                                        builder: (context) {
                                                          final limitedLikes =
                                                              columnGetlimitedPostLikesResponse
                                                                  .jsonBody
                                                                  .toList();

                                                          return Row(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .max,
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .start,
                                                            children: List.generate(
                                                                limitedLikes
                                                                    .length,
                                                                (limitedLikesIndex) {
                                                              final limitedLikesItem =
                                                                  limitedLikes[
                                                                      limitedLikesIndex];
                                                              return Stack(
                                                                alignment:
                                                                    AlignmentDirectional(
                                                                        1.0,
                                                                        1.0),
                                                                children: [
                                                                  Padding(
                                                                    padding: EdgeInsetsDirectional
                                                                        .fromSTEB(
                                                                            0.0,
                                                                            0.0,
                                                                            5.0,
                                                                            5.0),
                                                                    child:
                                                                        AppNetworkImage(
                                                                      url:
                                                                          getJsonField(
                                                                        limitedLikesItem,
                                                                        r'''$.profile_picture''',
                                                                      ).toString(),
                                                                      width:
                                                                          40.0,
                                                                      height:
                                                                          40.0,
                                                                      fit: BoxFit
                                                                          .cover,
                                                                      isAvatar:
                                                                          true,
                                                                      semanticLabel:
                                                                          'Profile photo',
                                                                    ),
                                                                  ),
                                                                  Icon(
                                                                    Icons
                                                                        .favorite,
                                                                    color: FlutterFlowTheme.of(
                                                                            context)
                                                                        .primary,
                                                                    size: 20.0,
                                                                  ),
                                                                ],
                                                              );
                                                            }).divide(SizedBox(
                                                                width: 12.0)),
                                                          );
                                                        },
                                                      ),
                                                      FlutterFlowIconButton(
                                                        borderRadius: 100.0,
                                                        buttonSize: 40.0,
                                                        fillColor:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .greyL2,
                                                        icon: Icon(
                                                          Icons
                                                              .arrow_forward_ios,
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .greyD1,
                                                          size: 16.0,
                                                        ),
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
                                                                      CompLikesWidget(
                                                                    postId: widget!
                                                                        .postId!,
                                                                    postUserid:
                                                                        columnPostRow!
                                                                            .userId,
                                                                  ),
                                                                ),
                                                              );
                                                            },
                                                          ).then((value) =>
                                                              safeSetState(
                                                                  () {}));
                                                        },
                                                      ),
                                                    ].divide(
                                                        SizedBox(width: 12.0)),
                                                  ),
                                              ],
                                            );
                                          },
                                        ),
                                        if (!_hasNoComments)
                                          Builder(
                                            builder: (context) {
                                              final comments = FFAppState()
                                                  .AsComments
                                                  .toList();

                                              return ListView.separated(
                                                padding: EdgeInsets.zero,
                                                primary: false,
                                                shrinkWrap: true,
                                                scrollDirection: Axis.vertical,
                                                itemCount: comments.length,
                                                separatorBuilder: (_, __) =>
                                                    SizedBox(height: 10.0),
                                                itemBuilder:
                                                    (context, commentsIndex) {
                                                  final commentsItem =
                                                      comments[commentsIndex];
                                                  return Column(
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    children: [
                                                      Container(
                                                        width: double.infinity,
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
                                                                      5.0),
                                                          child: Column(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .max,
                                                            children: [
                                                              Row(
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .max,
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Align(
                                                                    alignment:
                                                                        AlignmentDirectional(
                                                                            0.0,
                                                                            -1.0),
                                                                    child:
                                                                        AppNetworkImage(
                                                                      url:
                                                                          getJsonField(
                                                                        commentsItem,
                                                                        r'''$.profile_picture''',
                                                                      ).toString(),
                                                                      width:
                                                                          24.0,
                                                                      height:
                                                                          24.0,
                                                                      fit: BoxFit
                                                                          .cover,
                                                                      isAvatar:
                                                                          true,
                                                                      semanticLabel:
                                                                          'Profile photo of ' +
                                                                              getJsonField(commentsItem, r'''$.user_name''').toString(),
                                                                    ),
                                                                  ),
                                                                  Expanded(
                                                                    child:
                                                                        Column(
                                                                      mainAxisSize:
                                                                          MainAxisSize
                                                                              .max,
                                                                      children: [
                                                                        Row(
                                                                          mainAxisSize:
                                                                              MainAxisSize.max,
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.spaceBetween,
                                                                          children: [
                                                                            Text(
                                                                              getJsonField(
                                                                                commentsItem,
                                                                                r'''$.user_name''',
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
                                                                            Align(
                                                                              alignment: AlignmentDirectional(0.0, -1.0),
                                                                              child: Row(
                                                                                mainAxisSize: MainAxisSize.max,
                                                                                mainAxisAlignment: MainAxisAlignment.end,
                                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                                children: [
                                                                                  Text(
                                                                                    functions.returnRelativeTIme(getJsonField(
                                                                                      commentsItem,
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
                                                                                    width: 16.0,
                                                                                    height: 16.0,
                                                                                    decoration: BoxDecoration(
                                                                                      borderRadius: BorderRadius.only(
                                                                                        topLeft: Radius.circular(100.0),
                                                                                        topRight: Radius.circular(100.0),
                                                                                        bottomLeft: Radius.circular(100.0),
                                                                                        bottomRight: Radius.circular(100.0),
                                                                                      ),
                                                                                    ),
                                                                                    alignment: AlignmentDirectional(0.0, 0.0),
                                                                                    child: Transform.rotate(
                                                                                      angle: 90.0 * (math.pi / 180),
                                                                                      child: Visibility(
                                                                                        visible: false,
                                                                                        child: Icon(
                                                                                          Icons.keyboard_control,
                                                                                          color: FlutterFlowTheme.of(context).primaryText,
                                                                                          size: 16.0,
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ].divide(SizedBox(width: 12.0)),
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                        Column(
                                                                          mainAxisSize:
                                                                              MainAxisSize.max,
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.start,
                                                                          children:
                                                                              [
                                                                            Column(
                                                                              mainAxisSize: MainAxisSize.max,
                                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                                              children: [
                                                                                Padding(
                                                                                  padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 12.0, 0.0),
                                                                                  child: custom_widgets.ShowContent(
                                                                                    width: double.infinity,
                                                                                    height: 40.0,
                                                                                    currentUserId: currentUserUid,
                                                                                    richTextContent: functions.textToJson(getJsonField(
                                                                                      commentsItem,
                                                                                      r'''$.comment''',
                                                                                    ).toString())!,
                                                                                    tldrContent: getJsonField(
                                                                                      commentsItem,
                                                                                      r'''$.tldr''',
                                                                                    ).toString(),
                                                                                  ),
                                                                                ),
                                                                                if (false)
                                                                                  Text(
                                                                                    getJsonField(
                                                                                      commentsItem,
                                                                                      r'''$.comment''',
                                                                                    ).toString(),
                                                                                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                          font: GoogleFonts.manrope(
                                                                                            fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                                                                            fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                          ),
                                                                                          letterSpacing: 0.0,
                                                                                          fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                                                                          fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                        ),
                                                                                  ),
                                                                              ],
                                                                            ),
                                                                            Row(
                                                                              mainAxisSize: MainAxisSize.max,
                                                                              children: [
                                                                                Row(
                                                                                  mainAxisSize: MainAxisSize.max,
                                                                                  children: [
                                                                                    AppIconButton(
                                                                                      semanticLabel: 'Like, ' + valueOrDefault<String>(getJsonField(commentsItem, r'''$.likes_count''')?.toString(), '0') + ' likes',
                                                                                      minTapTarget: 44.0,
                                                                                      enableHaptic: false,
                                                                                      onTap: () async {
                                                                                        HapticFeedback.lightImpact();
                                                                                        _model.apiResultxyt = await AddCommentLikeCall.call(
                                                                                          pPostid: widget!.postId,
                                                                                          pUserid: currentUserUid,
                                                                                          pCommunityid: columnPostRow?.communityId,
                                                                                          pCommentid: getJsonField(
                                                                                            commentsItem,
                                                                                            r'''$.id''',
                                                                                          ).toString(),
                                                                                          token: currentJwtToken,
                                                                                        );

                                                                                        safeSetState(() {});
                                                                                      },
                                                                                      iconWidget: ExcludeSemantics(
                                                                                        child: Container(
                                                                                          width: 25.0,
                                                                                          height: 25.0,
                                                                                          decoration: BoxDecoration(),
                                                                                          alignment: AlignmentDirectional(0.0, 0.0),
                                                                                          child: Stack(
                                                                                            alignment: AlignmentDirectional(0.0, 0.0),
                                                                                            children: [
                                                                                              Icon(
                                                                                                Icons.favorite_border_outlined,
                                                                                                color: FlutterFlowTheme.of(context).greyL4,
                                                                                                size: 16.0,
                                                                                              ),
                                                                                              FutureBuilder<List<PostCommentLikesRow>>(
                                                                                                future: PostCommentLikesTable().querySingleRow(
                                                                                                  queryFn: (q) => q
                                                                                                      .eqOrNull(
                                                                                                        'community_id',
                                                                                                        columnPostRow?.communityId,
                                                                                                      )
                                                                                                      .eqOrNull(
                                                                                                        'post_id',
                                                                                                        widget!.postId,
                                                                                                      )
                                                                                                      .eqOrNull(
                                                                                                        'comment_id',
                                                                                                        getJsonField(
                                                                                                          commentsItem,
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
                                                                                                    return CompLoadingWidget(
                                                                                                      name: 'like',
                                                                                                    );
                                                                                                  }
                                                                                                  List<PostCommentLikesRow> iconPostCommentLikesRowList = snapshot.data!;

                                                                                                  // Return an empty Container when the item does not exist.
                                                                                                  if (snapshot.data!.isEmpty) {
                                                                                                    return Container();
                                                                                                  }
                                                                                                  final iconPostCommentLikesRow = iconPostCommentLikesRowList.isNotEmpty ? iconPostCommentLikesRowList.first : null;

                                                                                                  return Icon(
                                                                                                    Icons.favorite,
                                                                                                    color: FlutterFlowTheme.of(context).primary,
                                                                                                    size: 16.0,
                                                                                                  );
                                                                                                },
                                                                                              ),
                                                                                            ],
                                                                                          ),
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                    Text(
                                                                                      valueOrDefault<String>(
                                                                                        getJsonField(
                                                                                          commentsItem,
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
                                                                                            letterSpacing: 0.0,
                                                                                            fontWeight: FontWeight.w500,
                                                                                            fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                            lineHeight: 1.0,
                                                                                          ),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                                Row(
                                                                                  mainAxisSize: MainAxisSize.max,
                                                                                  children: [
                                                                                    ClipRRect(
                                                                                      borderRadius: BorderRadius.circular(0.0),
                                                                                      child: Image.asset(
                                                                                        'assets/images/forum.png',
                                                                                        width: 16.0,
                                                                                        height: 16.0,
                                                                                        fit: BoxFit.cover,
                                                                                      ),
                                                                                    ),
                                                                                    Text(
                                                                                      valueOrDefault<String>(
                                                                                        getJsonField(
                                                                                          commentsItem,
                                                                                          r'''$.replies_count''',
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
                                                                                            lineHeight: 1.0,
                                                                                          ),
                                                                                    ),
                                                                                  ].divide(SizedBox(width: 4.0)),
                                                                                ),
                                                                                AppIconButton(
                                                                                  semanticLabel: 'Reply to ' + getJsonField(commentsItem, r'''$.user_name''').toString(),
                                                                                  minTapTarget: 44.0,
                                                                                  enableHaptic: false,
                                                                                  onTap: () async {
                                                                                    HapticFeedback.lightImpact();
                                                                                    FFAppState().postCommentPostId = widget!.postId!;
                                                                                    FFAppState().postCommentUserName = getJsonField(
                                                                                      commentsItem,
                                                                                      r'''$.user_name''',
                                                                                    ).toString();
                                                                                    FFAppState().showReply = true;
                                                                                    FFAppState().CommentId = getJsonField(
                                                                                      commentsItem,
                                                                                      r'''$.id''',
                                                                                    ).toString();
                                                                                    safeSetState(() {});
                                                                                  },
                                                                                  iconWidget: ExcludeSemantics(
                                                                                    child: Container(
                                                                                      width: 65.0,
                                                                                      height: 20.0,
                                                                                      decoration: BoxDecoration(),
                                                                                      alignment: AlignmentDirectional(0.0, 0.0),
                                                                                      child: Text(
                                                                                        'Add reply',
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
                                                                                              lineHeight: 1.0,
                                                                                            ),
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ].divide(SizedBox(width: 12.0)),
                                                                            ),
                                                                          ].divide(SizedBox(height: 4.0)),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ].divide(SizedBox(
                                                                    width:
                                                                        8.0)),
                                                              ),
                                                              Padding(
                                                                padding: EdgeInsetsDirectional
                                                                    .fromSTEB(
                                                                        40.0,
                                                                        10.0,
                                                                        0.0,
                                                                        0.0),
                                                                child:
                                                                    Container(
                                                                  width: double
                                                                      .infinity,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: FlutterFlowTheme.of(
                                                                            context)
                                                                        .secondaryBackground,
                                                                  ),
                                                                  child:
                                                                      Visibility(
                                                                    visible: functions.checkCommentReplyPresent(
                                                                            FFAppState().AsCommentReplies,
                                                                            getJsonField(
                                                                              commentsItem,
                                                                              r'''$.id''',
                                                                            ).toString()) ==
                                                                        true,
                                                                    child:
                                                                        Builder(
                                                                      builder:
                                                                          (context) {
                                                                        final commentReplies = functions
                                                                            .returnCommentReplies(
                                                                                FFAppState().AsCommentReplies,
                                                                                getJsonField(
                                                                                  commentsItem,
                                                                                  r'''$.id''',
                                                                                ).toString())
                                                                            .toList();

                                                                        return ListView
                                                                            .separated(
                                                                          padding:
                                                                              EdgeInsets.zero,
                                                                          primary:
                                                                              false,
                                                                          shrinkWrap:
                                                                              true,
                                                                          scrollDirection:
                                                                              Axis.vertical,
                                                                          itemCount:
                                                                              commentReplies.length,
                                                                          separatorBuilder: (_, __) =>
                                                                              SizedBox(height: 10.0),
                                                                          itemBuilder:
                                                                              (context, commentRepliesIndex) {
                                                                            final commentRepliesItem =
                                                                                commentReplies[commentRepliesIndex];
                                                                            return Row(
                                                                              mainAxisSize: MainAxisSize.max,
                                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                                              children: [
                                                                                Align(
                                                                                  alignment: AlignmentDirectional(0.0, -1.0),
                                                                                  child: AppNetworkImage(
                                                                                    url: getJsonField(
                                                                                      commentRepliesItem,
                                                                                      r'''$.profile_picture''',
                                                                                    ).toString(),
                                                                                    width: 24.0,
                                                                                    height: 24.0,
                                                                                    fit: BoxFit.cover,
                                                                                    isAvatar: true,
                                                                                    semanticLabel: 'Profile photo of ' + getJsonField(commentRepliesItem, r'''$.user_name''').toString(),
                                                                                  ),
                                                                                ),
                                                                                Expanded(
                                                                                  child: Column(
                                                                                    mainAxisSize: MainAxisSize.max,
                                                                                    children: [
                                                                                      Row(
                                                                                        mainAxisSize: MainAxisSize.max,
                                                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                        children: [
                                                                                          Text(
                                                                                            getJsonField(
                                                                                              commentRepliesItem,
                                                                                              r'''$.user_name''',
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
                                                                                          Align(
                                                                                            alignment: AlignmentDirectional(0.0, -1.0),
                                                                                            child: Row(
                                                                                              mainAxisSize: MainAxisSize.max,
                                                                                              mainAxisAlignment: MainAxisAlignment.end,
                                                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                                                              children: [
                                                                                                Text(
                                                                                                  functions.returnRelativeTIme(getJsonField(
                                                                                                    commentRepliesItem,
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
                                                                                                  width: 16.0,
                                                                                                  height: 16.0,
                                                                                                  decoration: BoxDecoration(
                                                                                                    borderRadius: BorderRadius.only(
                                                                                                      topLeft: Radius.circular(100.0),
                                                                                                      topRight: Radius.circular(100.0),
                                                                                                      bottomLeft: Radius.circular(100.0),
                                                                                                      bottomRight: Radius.circular(100.0),
                                                                                                    ),
                                                                                                  ),
                                                                                                  alignment: AlignmentDirectional(0.0, 0.0),
                                                                                                  child: Transform.rotate(
                                                                                                    angle: 90.0 * (math.pi / 180),
                                                                                                    child: Visibility(
                                                                                                      visible: false,
                                                                                                      child: Icon(
                                                                                                        Icons.keyboard_control,
                                                                                                        color: FlutterFlowTheme.of(context).primaryText,
                                                                                                        size: 16.0,
                                                                                                      ),
                                                                                                    ),
                                                                                                  ),
                                                                                                ),
                                                                                              ].divide(SizedBox(width: 12.0)),
                                                                                            ),
                                                                                          ),
                                                                                        ],
                                                                                      ),
                                                                                      Column(
                                                                                        mainAxisSize: MainAxisSize.max,
                                                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                                                        children: [
                                                                                          Column(
                                                                                            mainAxisSize: MainAxisSize.max,
                                                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                                                            children: [
                                                                                              Padding(
                                                                                                padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 12.0, 0.0),
                                                                                                child: custom_widgets.ShowContent(
                                                                                                  width: double.infinity,
                                                                                                  height: 40.0,
                                                                                                  currentUserId: currentUserUid,
                                                                                                  richTextContent: functions.textToJson(getJsonField(
                                                                                                    commentRepliesItem,
                                                                                                    r'''$.comment''',
                                                                                                  ).toString())!,
                                                                                                  tldrContent: getJsonField(
                                                                                                    commentRepliesItem,
                                                                                                    r'''$.tldr''',
                                                                                                  ).toString(),
                                                                                                ),
                                                                                              ),
                                                                                            ],
                                                                                          ),
                                                                                        ].divide(SizedBox(height: 4.0)),
                                                                                      ),
                                                                                    ],
                                                                                  ),
                                                                                ),
                                                                              ].divide(SizedBox(width: 8.0)),
                                                                            );
                                                                          },
                                                                        );
                                                                      },
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                              Padding(
                                                                padding:
                                                                    EdgeInsetsDirectional
                                                                        .fromSTEB(
                                                                            0.0,
                                                                            4.0,
                                                                            0.0,
                                                                            0.0),
                                                                child:
                                                                    Container(
                                                                  width: double
                                                                      .infinity,
                                                                  height: 1.0,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: FlutterFlowTheme.of(
                                                                            context)
                                                                        .greyL2,
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  );
                                                },
                                              );
                                            },
                                          ),
                                        if (_hasNoComments)
                                          EmptyState(
                                            illustrationAsset:
                                                'assets/images/empty_comments.png',
                                            title: 'No comments yet',
                                            body:
                                                'Be the first to say something about this post.',
                                            compact: true,
                                          ),
                                      ].divide(SizedBox(height: 12.0)),
                                    ),
                                  ),
                                ].divide(SizedBox(height: 12.0)),
                              ),
                            ),
                          ),
                        ).animateOnPageLoad(
                            animationsMap['containerOnPageLoadAnimation']!),
                      ),
                    ),
                    if ((FFAppState().postCommentPostId == widget!.postId) &&
                        FFAppState().showReply)
                      Container(
                        width: double.infinity,
                        height: 35.0,
                        decoration: BoxDecoration(
                          color:
                              FlutterFlowTheme.of(context).secondaryBackground,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(12.0),
                            topRight: Radius.circular(12.0),
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              20.0, 0.0, 20.0, 0.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Text(
                                    'replying to ',
                                    style: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          font: GoogleFonts.manrope(
                                            fontWeight:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMedium
                                                    .fontWeight,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMedium
                                                    .fontStyle,
                                          ),
                                          letterSpacing: 0.0,
                                          fontWeight:
                                              FlutterFlowTheme.of(context)
                                                  .bodyMedium
                                                  .fontWeight,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .bodyMedium
                                                  .fontStyle,
                                        ),
                                  ),
                                  Text(
                                    '@${FFAppState().postCommentUserName}',
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
                                          letterSpacing: 0.0,
                                          fontWeight: FontWeight.w600,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .bodyMedium
                                                  .fontStyle,
                                        ),
                                  ),
                                ].divide(SizedBox(width: 5.0)),
                              ),
                              AppIconButton(
                                semanticLabel: 'Cancel reply',
                                minTapTarget: 44.0,
                                enableHaptic: false,
                                onTap: () async {
                                  HapticFeedback.lightImpact();
                                  FFAppState().showReply = false;
                                  FFAppState().postCommentUserName = '';
                                  FFAppState().postCommentPostId = '';
                                  safeSetState(() {});
                                },
                                iconWidget: ExcludeSemantics(
                                  child: Icon(
                                    Icons.close_sharp,
                                    color: FlutterFlowTheme.of(context)
                                        .primaryText,
                                    size: 24.0,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: FlutterFlowTheme.of(context).secondaryBackground,
                      ),
                      child: Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(
                            20.0, 12.0, 20.0, 12.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            AppNetworkImage(
                              url: FFAppState().AsProfilePicture,
                              width: 40.0,
                              height: 40.0,
                              fit: BoxFit.cover,
                              isAvatar: true,
                              semanticLabel: 'Your profile photo',
                            ),
                            Expanded(
                              child: Stack(
                                children: [
                                  if (false)
                                    Container(
                                      width: double.infinity,
                                      child: TextFormField(
                                        controller: _model.textController1,
                                        focusNode: _model.textFieldFocusNode,
                                        onFieldSubmitted: (_) async {
                                          if (_model.textController1.text
                                                  ?.trim()
                                                  .isNotEmpty ==
                                              true) {
                                            await PostCommentTable().insert({
                                              'user_id': currentUserUid,
                                              'post_id': widget!.postId,
                                              'community_id':
                                                  columnPostRow?.communityId,
                                              'comment':
                                                  _model.textController1.text,
                                              'likes_count': 0,
                                              'replies_count': 0,
                                            });
                                            safeSetState(() {
                                              _model.textController1?.clear();
                                              _model
                                                  .replyTextFieldTextController
                                                  ?.clear();
                                            });
                                            await UpdateCommentCountCall.call(
                                              token: currentJwtToken,
                                              pPostid: widget!.postId,
                                            );

                                            _model.countComments =
                                                await CountLikesCall.call(
                                              pCommentid:
                                                  FFAppState().CommentId,
                                              pPostId: widget!.postId,
                                              token: currentJwtToken,
                                              pType: 'post',
                                            );

                                            safeSetState(() => _model
                                                .requestCompleter1 = null);
                                            await _model
                                                .waitForRequestCompleted1();
                                          } else {
                                            safeSetState(() {
                                              _model.textController1?.clear();
                                              _model
                                                  .replyTextFieldTextController
                                                  ?.clear();
                                            });
                                          }

                                          safeSetState(() {});
                                        },
                                        autofocus: false,
                                        obscureText: false,
                                        decoration: InputDecoration(
                                          isDense: true,
                                          labelStyle: FlutterFlowTheme.of(
                                                  context)
                                              .labelMedium
                                              .override(
                                                font: GoogleFonts.manrope(
                                                  fontWeight: FontWeight.w500,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .labelMedium
                                                          .fontStyle,
                                                ),
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .greyL4,
                                                letterSpacing: 0.0,
                                                fontWeight: FontWeight.w500,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .labelMedium
                                                        .fontStyle,
                                                lineHeight: 1.3,
                                              ),
                                          hintText: 'Enter comment',
                                          hintStyle: FlutterFlowTheme.of(
                                                  context)
                                              .labelMedium
                                              .override(
                                                font: GoogleFonts.manrope(
                                                  fontWeight: FontWeight.w500,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .labelMedium
                                                          .fontStyle,
                                                ),
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .greyL4,
                                                letterSpacing: 0.0,
                                                fontWeight: FontWeight.w500,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .labelMedium
                                                        .fontStyle,
                                                lineHeight: 1.3,
                                              ),
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .greyL2,
                                              width: 1.0,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(4.0),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .greyD1,
                                              width: 1.0,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(4.0),
                                          ),
                                          errorBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .error,
                                              width: 1.0,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(4.0),
                                          ),
                                          focusedErrorBorder:
                                              OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .error,
                                              width: 1.0,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(4.0),
                                          ),
                                          filled: true,
                                          fillColor:
                                              FlutterFlowTheme.of(context)
                                                  .alternate,
                                          contentPadding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  12.0, 16.0, 12.0, 16.0),
                                        ),
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
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .primaryText,
                                              letterSpacing: 0.0,
                                              fontWeight: FontWeight.w500,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontStyle,
                                              lineHeight: 1.3,
                                            ),
                                        cursorColor:
                                            FlutterFlowTheme.of(context)
                                                .primaryText,
                                        validator: _model
                                            .textController1Validator
                                            .asValidator(context),
                                      ),
                                    ),
                                  if ((FFAppState().postCommentPostId ==
                                          widget!.postId) &&
                                      FFAppState().showReply)
                                    Container(
                                      width: double.infinity,
                                      child: TextFormField(
                                        controller:
                                            _model.replyTextFieldTextController,
                                        focusNode:
                                            _model.replyTextFieldFocusNode,
                                        onFieldSubmitted: (_) async {
                                          if (_model
                                                  .replyTextFieldTextController
                                                  .text
                                                  ?.trim()
                                                  .isNotEmpty ==
                                              true) {
                                            await PostCommentTable().insert({
                                              'user_id': currentUserUid,
                                              'post_id': widget!.postId,
                                              'community_id':
                                                  columnPostRow?.communityId,
                                              'comment': _model
                                                  .replyTextFieldTextController
                                                  .text,
                                              'likes_count': 0,
                                              'replies_count': 0,
                                              'parent_comment_id':
                                                  FFAppState().CommentId,
                                            });
                                            safeSetState(() {
                                              _model
                                                  .replyTextFieldTextController
                                                  ?.clear();
                                              _model.textController1?.clear();
                                            });
                                            await UpdateCommentCountCall.call(
                                              token: currentJwtToken,
                                              pPostid: widget!.postId,
                                            );

                                            await CountLikesCall.call(
                                              pCommentid:
                                                  FFAppState().CommentId,
                                              pPostId: widget!.postId,
                                              token: currentJwtToken,
                                              pType: 'reply',
                                            );

                                            FFAppState().showReply = false;
                                            safeSetState(() {});
                                          }
                                        },
                                        autofocus: false,
                                        obscureText: false,
                                        decoration: InputDecoration(
                                          isDense: true,
                                          labelStyle: FlutterFlowTheme.of(
                                                  context)
                                              .labelMedium
                                              .override(
                                                font: GoogleFonts.manrope(
                                                  fontWeight: FontWeight.w500,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .labelMedium
                                                          .fontStyle,
                                                ),
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .greyL4,
                                                letterSpacing: 0.0,
                                                fontWeight: FontWeight.w500,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .labelMedium
                                                        .fontStyle,
                                                lineHeight: 1.3,
                                              ),
                                          hintText: 'Enter reply',
                                          hintStyle: FlutterFlowTheme.of(
                                                  context)
                                              .labelMedium
                                              .override(
                                                font: GoogleFonts.manrope(
                                                  fontWeight: FontWeight.w500,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .labelMedium
                                                          .fontStyle,
                                                ),
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .greyL4,
                                                letterSpacing: 0.0,
                                                fontWeight: FontWeight.w500,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .labelMedium
                                                        .fontStyle,
                                                lineHeight: 1.3,
                                              ),
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .greyL2,
                                              width: 1.0,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(4.0),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .greyD1,
                                              width: 1.0,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(4.0),
                                          ),
                                          errorBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .error,
                                              width: 1.0,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(4.0),
                                          ),
                                          focusedErrorBorder:
                                              OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .error,
                                              width: 1.0,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(4.0),
                                          ),
                                          filled: true,
                                          fillColor:
                                              FlutterFlowTheme.of(context)
                                                  .alternate,
                                          contentPadding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  12.0, 16.0, 12.0, 16.0),
                                        ),
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
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .primaryText,
                                              letterSpacing: 0.0,
                                              fontWeight: FontWeight.w500,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontStyle,
                                              lineHeight: 1.3,
                                            ),
                                        cursorColor:
                                            FlutterFlowTheme.of(context)
                                                .primaryText,
                                        validator: _model
                                            .replyTextFieldTextControllerValidator
                                            .asValidator(context),
                                      ),
                                    ),
                                  custom_widgets.CommentMentionTextFieldWidget(
                                    width: double.infinity,
                                    height: 50.0,
                                    apiKey: FFDevEnvironmentValues().AnonKey,
                                    token: currentJwtToken!,
                                    postId: widget!.postId!,
                                    communityId: FFAppState().communityId,
                                    userId: currentUserUid,
                                  ),
                                ],
                              ),
                            ),
                            if (false)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: Image.asset(
                                  'assets/images/add_photo_alternate.png',
                                  width: 32.0,
                                  height: 32.0,
                                  fit: BoxFit.cover,
                                ),
                              ),
                          ].divide(SizedBox(width: 10.0)),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
