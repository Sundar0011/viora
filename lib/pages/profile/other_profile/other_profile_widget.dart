import '/components/app_icon_button.dart';
import '/components/app_network_image.dart';
import '/components/async_state_view.dart';
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
import '/pages/profile/comp_follow_nearby/comp_follow_nearby_widget.dart';
import 'dart:ui';
import '/custom_code/actions/index.dart' as actions;
import '/custom_code/widgets/index.dart' as custom_widgets;
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'other_profile_model.dart';
export 'other_profile_model.dart';

class OtherProfileWidget extends StatefulWidget {
  const OtherProfileWidget({
    super.key,
    required this.userid,
  });

  final String? userid;

  static String routeName = 'otherProfile';
  static String routePath = 'otherProfile';

  @override
  State<OtherProfileWidget> createState() => _OtherProfileWidgetState();
}

class _OtherProfileWidgetState extends State<OtherProfileWidget> {
  late OtherProfileModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  /// Non-null when the last load failed; drives the shared error state.
  Object? _loadError;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => OtherProfileModel());

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      await _initialLoad();
    });
  }

  /// First load: fetch the page data, then attach the realtime post listener.
  Future<void> _initialLoad() async {
    try {
      _loadError = null;
      await _fetchGroups();
      await _subscribeToPosts();
      await _fetchProfileData();
    } catch (e) {
      _loadError = e;
    }
    _model.showData = true;
    safeSetState(() {});
  }

  /// Loads the groups this user follows (shown in the "Groups" tab).
  Future<void> _fetchGroups() async {
    _model.othersGroupData = await GetOtherUserFollowingGroupsrCall.call(
      token: currentJwtToken,
      anonKey: FFDevEnvironmentValues().AnonKey,
      userId: widget!.userid,
    );

    _model.othersGroup = getJsonField(
      (_model.othersGroupData?.jsonBody ?? ''),
      r'''$''',
    );
    safeSetState(() {});
  }

  /// Loads this user's neighbourhood people and their visible post count.
  Future<void> _fetchProfileData() async {
    _model.neighbourData12 = await GetNeighborhoodPeoplesCall.call(
      pUserid: widget!.userid,
      token: currentJwtToken,
      pCommunityid: FFAppState().communityId,
    );

    _model.neighbourHoods = (_model.neighbourData12?.jsonBody ?? '');
    safeSetState(() {});
    _model.postCount = await PostTable().queryRows(
      queryFn: (q) => q
          .eqOrNull(
            'user_id',
            widget!.userid,
          )
          .eqOrNull(
            'is_deleted',
            false,
          ),
    );
  }

  /// Re-downloads the shared post feed this screen filters its posts from.
  Future<void> _fetchPosts() async {
    final ApiCallResponse postResponse = await GetPostCall.call(
      anonKey: FFDevEnvironmentValues().AnonKey,
      token: currentJwtToken,
    );

    FFAppState().AsPost = getJsonField(
      (postResponse.jsonBody ?? ''),
      r'''$''',
    );
  }

  /// Subscribes once to realtime post changes.
  Future<void> _subscribeToPosts() async {
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
      () async {},
    );
  }

  /// Pull-to-refresh handler: re-fetches groups, profile data and the feed.
  Future<void> _refreshProfile() async {
    try {
      _loadError = null;
      await _fetchGroups();
      await _fetchProfileData();
      await _fetchPosts();
    } catch (e) {
      _loadError = e;
    }
    safeSetState(() {});
  }

  /// Retry after a failed load: shows the skeleton again and re-runs the fetch.
  Future<void> _retryLoad() async {
    _loadError = null;
    _model.showData = false;
    safeSetState(() {});
    try {
      await _fetchGroups();
      await _fetchProfileData();
    } catch (e) {
      _loadError = e;
    }
    _model.showData = true;
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
          child: FutureBuilder<List<PublicUserProfileRow>>(
            future: PublicUserProfileTable().querySingleRow(
              queryFn: (q) => q.eqOrNull(
                'id',
                widget!.userid,
              ),
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
              List<PublicUserProfileRow> containerPublicUserProfileRowList =
                  snapshot.data!;

              final containerPublicUserProfileRow =
                  containerPublicUserProfileRowList.isNotEmpty
                      ? containerPublicUserProfileRowList.first
                      : null;

              return InkWell(
                splashColor:
                    FlutterFlowTheme.of(context).primary.withAlpha(0x14),
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
                  child: RefreshIndicator(
                    onRefresh: _refreshProfile,
                    color: FlutterFlowTheme.of(context).primary,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          AsyncStateView<bool>(
                            data: _model.showData ? true : null,
                            isLoading: !_model.showData && _loadError == null,
                            error: _loadError,
                            onRetry: _retryLoad,
                            isEmpty: (bool loaded) => false,
                            builder: (BuildContext context, bool loaded) =>
                                SingleChildScrollView(
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Align(
                                            alignment:
                                                AlignmentDirectional(-1.0, 0.0),
                                            child: Padding(
                                              padding: EdgeInsetsDirectional
                                                  .fromSTEB(
                                                      10.0, 0.0, 0.0, 0.0),
                                              child: AppIconButton(
                                                icon: Icons.arrow_back,
                                                semanticLabel: 'Back',
                                                tooltip: 'Back',
                                                iconSize: 24.0,
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .extraBlack,
                                                onTap: () async {
                                                  context.safePop();
                                                },
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding:
                                                EdgeInsetsDirectional.fromSTEB(
                                                    0.0, 0.0, 20.0, 0.0),
                                            child: InkWell(
                                              splashColor:
                                                  FlutterFlowTheme.of(context)
                                                      .primary
                                                      .withAlpha(0x14),
                                              focusColor: Colors.transparent,
                                              hoverColor: Colors.transparent,
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
                                                        child:
                                                            CompThreeDotBlockUserWidget(
                                                          reportedByUserId:
                                                              currentUserUid,
                                                          reportedUserId:
                                                              containerPublicUserProfileRow!
                                                                  .id,
                                                          blockedUserName:
                                                              containerPublicUserProfileRow!
                                                                  .name!,
                                                          reportType: 'post',
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ).then((value) =>
                                                    safeSetState(() {}));
                                              },
                                              child: Container(
                                                width: 34.0,
                                                height: 34.0,
                                                decoration: BoxDecoration(
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .greyL2,
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
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Column(
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          color: FlutterFlowTheme.of(context)
                                              .white,
                                        ),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.max,
                                          children: [
                                            Stack(
                                              alignment: AlignmentDirectional(
                                                  -1.0, 1.0),
                                              children: [
                                                Padding(
                                                  padding: EdgeInsetsDirectional
                                                      .fromSTEB(
                                                          0.0, 0.0, 0.0, 60.0),
                                                  child: Stack(
                                                    alignment:
                                                        AlignmentDirectional(
                                                            1.0, 1.0),
                                                    children: [
                                                      ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(0.0),
                                                        child: AppNetworkImage(
                                                          url: FFAppState()
                                                              .AsCoverImage,
                                                          width:
                                                              double.infinity,
                                                          height: 240.0,
                                                          fit: BoxFit.cover,
                                                          semanticLabel:
                                                              'Cover photo',
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Stack(
                                                  alignment:
                                                      AlignmentDirectional(
                                                          1.0, 1.0),
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          EdgeInsetsDirectional
                                                              .fromSTEB(
                                                                  20.0,
                                                                  0.0,
                                                                  0.0,
                                                                  0.0),
                                                      child: ClipRRect(
                                                        borderRadius:
                                                            BorderRadius.only(
                                                          topLeft:
                                                              Radius.circular(
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
                                                        child: AppNetworkImage(
                                                          url: containerPublicUserProfileRow!
                                                              .profilePicture!,
                                                          width: 120.0,
                                                          height: 120.0,
                                                          fit: BoxFit.cover,
                                                          fallbackIcon: Icons
                                                              .person_rounded,
                                                          semanticLabel:
                                                              'Profile photo',
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            Padding(
                                              padding: EdgeInsetsDirectional
                                                  .fromSTEB(
                                                      20.0, 0.0, 20.0, 0.0),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.max,
                                                children: [
                                                  Row(
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Align(
                                                        alignment:
                                                            AlignmentDirectional(
                                                                -1.0, 0.0),
                                                        child: Text(
                                                          valueOrDefault<
                                                              String>(
                                                            containerPublicUserProfileRow
                                                                ?.name,
                                                            'name',
                                                          ),
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
                                                                fontSize: 20.0,
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
                                                      InkWell(
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
                                                          _model.chatFound =
                                                              await FindCommonChatCall
                                                                  .call(
                                                            anonKey:
                                                                FFDevEnvironmentValues()
                                                                    .AnonKey,
                                                            token:
                                                                currentJwtToken,
                                                            user1:
                                                                currentUserUid,
                                                            user2:
                                                                widget!.userid,
                                                          );

                                                          if (FindCommonChatCall
                                                                  .chatFound(
                                                                (_model.chatFound
                                                                        ?.jsonBody ??
                                                                    ''),
                                                              ) ==
                                                              true) {
                                                            await RestoreChatUserCall
                                                                .call(
                                                              pChatId:
                                                                  FindCommonChatCall
                                                                      .chatId(
                                                                (_model.chatFound
                                                                        ?.jsonBody ??
                                                                    ''),
                                                              ),
                                                              pUserId: widget!
                                                                  .userid,
                                                              anonKey:
                                                                  FFDevEnvironmentValues()
                                                                      .AnonKey,
                                                              token:
                                                                  currentJwtToken,
                                                            );

                                                            context.pushNamed(
                                                              MessagePageWidget
                                                                  .routeName,
                                                              queryParameters: {
                                                                'chatId':
                                                                    serializeParam(
                                                                  FindCommonChatCall
                                                                      .chatId(
                                                                    (_model.chatFound
                                                                            ?.jsonBody ??
                                                                        ''),
                                                                  ),
                                                                  ParamType
                                                                      .String,
                                                                ),
                                                                'userId':
                                                                    serializeParam(
                                                                  widget!
                                                                      .userid,
                                                                  ParamType
                                                                      .String,
                                                                ),
                                                              }.withoutNulls,
                                                            );
                                                          } else {
                                                            _model.chat =
                                                                await ChatTable()
                                                                    .insert({
                                                              'community_id':
                                                                  containerPublicUserProfileRow
                                                                      ?.communityId,
                                                              'first_message_date':
                                                                  supaSerialize<
                                                                          DateTime>(
                                                                      functions
                                                                          .getCurrentUtcTime()),
                                                              'created_by':
                                                                  currentUserUid,
                                                              'chat_type': 'dm',
                                                            });
                                                            await AddChatUsersCall
                                                                .call(
                                                              user2: widget!
                                                                  .userid,
                                                              communityId:
                                                                  containerPublicUserProfileRow
                                                                      ?.communityId
                                                                      ?.toString(),
                                                              chatId: _model
                                                                  .chat?.id,
                                                              anonKey:
                                                                  FFDevEnvironmentValues()
                                                                      .AnonKey,
                                                              token:
                                                                  currentJwtToken,
                                                            );

                                                            context.pushNamed(
                                                              MessagePageWidget
                                                                  .routeName,
                                                              queryParameters: {
                                                                'chatId':
                                                                    serializeParam(
                                                                  _model
                                                                      .chat?.id,
                                                                  ParamType
                                                                      .String,
                                                                ),
                                                                'userId':
                                                                    serializeParam(
                                                                  widget!
                                                                      .userid,
                                                                  ParamType
                                                                      .String,
                                                                ),
                                                              }.withoutNulls,
                                                            );
                                                          }

                                                          safeSetState(() {});
                                                        },
                                                        child: ClipRRect(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      8.0),
                                                          child: Image.asset(
                                                            'assets/images/forum.png',
                                                            width: 20.0,
                                                            height: 20.0,
                                                            fit: BoxFit.cover,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  Column(
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    children: [
                                                      Stack(
                                                        alignment:
                                                            AlignmentDirectional(
                                                                1.0, 1.0),
                                                        children: [
                                                          if (_model
                                                              .profileReadmore)
                                                            Align(
                                                              alignment:
                                                                  AlignmentDirectional(
                                                                      -1.0,
                                                                      -1.0),
                                                              child: Text(
                                                                valueOrDefault<
                                                                    String>(
                                                                  containerPublicUserProfileRow
                                                                      ?.bio,
                                                                  'Bio',
                                                                ),
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
                                                                          .greyL5,
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
                                                            ),
                                                          if (!_model
                                                              .profileReadmore)
                                                            Align(
                                                              alignment:
                                                                  AlignmentDirectional(
                                                                      -1.0,
                                                                      -1.0),
                                                              child: Text(
                                                                valueOrDefault<
                                                                    String>(
                                                                  containerPublicUserProfileRow
                                                                      ?.bio,
                                                                  'No Bio',
                                                                ).maybeHandleOverflow(
                                                                  maxChars: 99,
                                                                  replacement:
                                                                      '…',
                                                                ),
                                                                maxLines: 3,
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
                                                                          .greyL5,
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
                                                            ),
                                                          if (valueOrDefault<
                                                                  bool>(
                                                                ((containerPublicUserProfileRow!.bio!)
                                                                            .length >
                                                                        99) ==
                                                                    true,
                                                                false,
                                                              ) &&
                                                              !_model
                                                                  .profileReadmore)
                                                            Align(
                                                              alignment:
                                                                  AlignmentDirectional(
                                                                      1.0, 1.0),
                                                              child: InkWell(
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
                                                                  _model.profileReadmore =
                                                                      true;
                                                                  safeSetState(
                                                                      () {});
                                                                },
                                                                child: Text(
                                                                  'Read More',
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
                                                                            .greyL4,
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
                                                              ),
                                                            ),
                                                          if (valueOrDefault<
                                                                  bool>(
                                                                ((containerPublicUserProfileRow!.bio!)
                                                                            .length >
                                                                        99) ==
                                                                    true,
                                                                false,
                                                              ) &&
                                                              _model
                                                                  .profileReadmore)
                                                            Align(
                                                              alignment:
                                                                  AlignmentDirectional(
                                                                      1.0, 1.0),
                                                              child: InkWell(
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
                                                                  _model.profileReadmore =
                                                                      false;
                                                                  safeSetState(
                                                                      () {});
                                                                },
                                                                child: Text(
                                                                  'Read Less',
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
                                                                            .greyL4,
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
                                                              ),
                                                            ),
                                                        ],
                                                      ),
                                                    ].divide(
                                                        SizedBox(height: 4.0)),
                                                  ),
                                                  Row(
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      Text(
                                                        valueOrDefault<String>(
                                                          containerPublicUserProfileRow
                                                              ?.city,
                                                          'city',
                                                        ),
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
                                                      Container(
                                                        width: 2.0,
                                                        height: 2.0,
                                                        decoration:
                                                            BoxDecoration(
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .greyL4,
                                                        ),
                                                      ),
                                                      Text(
                                                        valueOrDefault<String>(
                                                          functions.getFinalValues(
                                                              containerPublicUserProfileRow!
                                                                  .followers),
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
                                                                        .w600,
                                                                fontStyle: FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .fontStyle,
                                                              ),
                                                              color: FlutterFlowTheme
                                                                      .of(context)
                                                                  .extraBlack,
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
                                                              lineHeight: 1.3,
                                                            ),
                                                      ),
                                                      Text(
                                                        'followers',
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
                                                    ].divide(
                                                        SizedBox(width: 4.0)),
                                                  ),
                                                ]
                                                    .divide(
                                                        SizedBox(height: 8.0))
                                                    .addToStart(
                                                        SizedBox(height: 12.0))
                                                    .addToEnd(
                                                        SizedBox(height: 12.0)),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  if ('${getJsonField(
                                        _model.othersGroup,
                                        r'''$''',
                                      ).toString()}' !=
                                      '[]')
                                    Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          0.0, 4.0, 0.0, 0.0),
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
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .secondaryBackground,
                                              ),
                                              child: Padding(
                                                padding: EdgeInsetsDirectional
                                                    .fromSTEB(
                                                        20.0, 12.0, 20.0, 12.0),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      'Groups',
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
                                                    Stack(
                                                      children: [
                                                        if (_model
                                                                .viewAllGroups ==
                                                            false)
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
                                                              _model.viewAllGroups =
                                                                  true;
                                                              safeSetState(
                                                                  () {});
                                                            },
                                                            child: Text(
                                                              'View all',
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
                                                                    lineHeight:
                                                                        1.4,
                                                                  ),
                                                            ),
                                                          ),
                                                        if (_model
                                                                .viewAllGroups ==
                                                            true)
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
                                                              _model.viewAllGroups =
                                                                  false;
                                                              safeSetState(
                                                                  () {});
                                                            },
                                                            child: Text(
                                                              'View less',
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
                                                                    lineHeight:
                                                                        1.4,
                                                                  ),
                                                            ),
                                                          ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            Stack(
                                              children: [
                                                if (('${getJsonField(
                                                          _model.othersGroup,
                                                          r'''$''',
                                                        ).toString()}' !=
                                                        '[]') &&
                                                    (_model.viewAllGroups ==
                                                        false) &&
                                                    (getJsonField(
                                                          _model.othersGroup,
                                                          r'''$''',
                                                        ) !=
                                                        null))
                                                  Builder(
                                                    builder: (context) {
                                                      final grops =
                                                          getJsonField(
                                                        _model.othersGroup,
                                                        r'''$''',
                                                      )
                                                              .toList()
                                                              .take(3)
                                                              .toList();

                                                      return ListView.separated(
                                                        padding:
                                                            EdgeInsets.fromLTRB(
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
                                                        separatorBuilder:
                                                            (_, __) => SizedBox(
                                                                height: 12.0),
                                                        itemBuilder: (context,
                                                            gropsIndex) {
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
                                                                        'listed') &&
                                                                    ('${getJsonField(
                                                                          gropsItem,
                                                                          r'''$.user_status''',
                                                                        ).toString()}' ==
                                                                        'admin')),
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
                                                                context
                                                                    .pushNamed(
                                                                  GroupDetailsWidget
                                                                      .routeName,
                                                                  queryParameters:
                                                                      {
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
                                                                width: double
                                                                    .infinity,
                                                                constraints:
                                                                    BoxConstraints(
                                                                        minHeight:
                                                                            56.0),
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .secondaryBackground,
                                                                ),
                                                                child: Padding(
                                                                  padding: EdgeInsetsDirectional
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
                                                                        child:
                                                                            Row(
                                                                          mainAxisSize:
                                                                              MainAxisSize.max,
                                                                          children:
                                                                              [
                                                                            ClipRRect(
                                                                              borderRadius: BorderRadius.circular(2.0),
                                                                              child: AppNetworkImage(
                                                                                url: getJsonField(
                                                                                  gropsItem,
                                                                                  r'''$.profile_picture''',
                                                                                ).toString(),
                                                                                width: 40.0,
                                                                                height: 40.0,
                                                                                fit: BoxFit.cover,
                                                                                fallbackIcon: Icons.groups_rounded,
                                                                                semanticLabel: 'Group photo',
                                                                              ),
                                                                            ),
                                                                            Expanded(
                                                                              child: Column(
                                                                                mainAxisSize: MainAxisSize.max,
                                                                                crossAxisAlignment: CrossAxisAlignment.start,
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
                                                                                          child: AppNetworkImage(
                                                                                            url: getJsonField(
                                                                                              gropsItem,
                                                                                              r'''$.invited_by_profile_picture''',
                                                                                            ).toString(),
                                                                                            width: 12.0,
                                                                                            height: 12.0,
                                                                                            fit: BoxFit.cover,
                                                                                            fallbackIcon: Icons.person_rounded,
                                                                                            semanticLabel: 'Profile photo of the neighbour who invited you',
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
                                                                          ].divide(SizedBox(width: 8.0)),
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
                                                                              onPressed: () async {
                                                                                await GroupMembersTable().insert({
                                                                                  'community_id': FFAppState().communityId,
                                                                                  'user_id': currentUserUid,
                                                                                  'group_id': getJsonField(
                                                                                    gropsItem,
                                                                                    r'''$.group_id''',
                                                                                  ).toString(),
                                                                                  'is_requested': false,
                                                                                  'requested_date': supaSerialize<DateTime>(functions.getCurrentUtcTime()),
                                                                                  'is_approved': true,
                                                                                  'approved_by': currentUserUid,
                                                                                  'joined_at': supaSerialize<DateTime>(functions.getCurrentUtcTime()),
                                                                                });
                                                                                await GroupUserStatusTable().insert({
                                                                                  'community_id': FFAppState().communityId,
                                                                                  'user_id': currentUserUid,
                                                                                  'group_id': getJsonField(
                                                                                    gropsItem,
                                                                                    r'''$.group_id''',
                                                                                  ).toString(),
                                                                                  'is_requested': false,
                                                                                  'is_invited': false,
                                                                                  'is_member': true,
                                                                                  'joined_at': supaSerialize<DateTime>(functions.getCurrentUtcTime()),
                                                                                });
                                                                                _model.apiResultd2p22 = await UpdateTotalGroupMembersCall.call(
                                                                                  token: currentJwtToken,
                                                                                  anonKey: FFDevEnvironmentValues().AnonKey,
                                                                                  groupId: getJsonField(
                                                                                    gropsItem,
                                                                                    r'''$.group_id''',
                                                                                  ).toString(),
                                                                                );

                                                                                _model.othersGroupData4 = await GetOtherUserFollowingGroupsrCall.call(
                                                                                  token: currentJwtToken,
                                                                                  anonKey: FFDevEnvironmentValues().AnonKey,
                                                                                  userId: widget!.userid,
                                                                                );

                                                                                _model.othersGroup = getJsonField(
                                                                                  (_model.othersGroupData4?.jsonBody ?? ''),
                                                                                  r'''$''',
                                                                                );
                                                                                safeSetState(() {});

                                                                                safeSetState(() {});
                                                                              },
                                                                              text: 'Join',
                                                                              options: FFButtonOptions(
                                                                                height: 24.0,
                                                                                padding: EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                                                                                iconPadding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                                                                                color: Colors.transparent,
                                                                                textStyle: FlutterFlowTheme.of(context).titleSmall.override(
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
                                                                              options: FFButtonOptions(
                                                                                height: 24.0,
                                                                                padding: EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                                                                                iconPadding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                                                                                iconColor: FlutterFlowTheme.of(context).greyL4,
                                                                                color: Colors.transparent,
                                                                                textStyle: FlutterFlowTheme.of(context).titleSmall.override(
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
                                                                          if ('${getJsonField(
                                                                                gropsItem,
                                                                                r'''$.user_status''',
                                                                              ).toString()}' ==
                                                                              'requested')
                                                                            FFButtonWidget(
                                                                              onPressed: () {},
                                                                              text: 'Requested',
                                                                              options: FFButtonOptions(
                                                                                height: 24.0,
                                                                                padding: EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                                                                                iconPadding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                                                                                color: FlutterFlowTheme.of(context).greyL2,
                                                                                textStyle: FlutterFlowTheme.of(context).titleSmall.override(
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
                                                                                elevation: 0.0,
                                                                                borderRadius: BorderRadius.only(
                                                                                  topLeft: Radius.circular(100.0),
                                                                                  topRight: Radius.circular(100.0),
                                                                                  bottomLeft: Radius.circular(100.0),
                                                                                  bottomRight: Radius.circular(100.0),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          if ('${getJsonField(
                                                                                gropsItem,
                                                                                r'''$.user_status''',
                                                                              ).toString()}' ==
                                                                              'request')
                                                                            FFButtonWidget(
                                                                              onPressed: () async {
                                                                                await GroupUserStatusTable().insert({
                                                                                  'community_id': FFAppState().communityId,
                                                                                  'user_id': currentUserUid,
                                                                                  'group_id': getJsonField(
                                                                                    gropsItem,
                                                                                    r'''$.group_id''',
                                                                                  ).toString(),
                                                                                  'is_requested': true,
                                                                                  'is_invited': false,
                                                                                  'is_member': false,
                                                                                  'is_approved': false,
                                                                                  'requested_date': supaSerialize<DateTime>(functions.getCurrentUtcTime()),
                                                                                });
                                                                                _model.othersGroupData5 = await GetOtherUserFollowingGroupsrCall.call(
                                                                                  token: currentJwtToken,
                                                                                  anonKey: FFDevEnvironmentValues().AnonKey,
                                                                                  userId: widget!.userid,
                                                                                );

                                                                                _model.othersGroup = getJsonField(
                                                                                  (_model.othersGroupData5?.jsonBody ?? ''),
                                                                                  r'''$''',
                                                                                );
                                                                                safeSetState(() {});

                                                                                safeSetState(() {});
                                                                              },
                                                                              text: 'Request',
                                                                              icon: Icon(
                                                                                Icons.lock_outline_sharp,
                                                                                size: 15.0,
                                                                              ),
                                                                              options: FFButtonOptions(
                                                                                height: 24.0,
                                                                                padding: EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                                                                                iconPadding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                                                                                iconColor: FlutterFlowTheme.of(context).primaryD3,
                                                                                color: Colors.transparent,
                                                                                textStyle: FlutterFlowTheme.of(context).titleSmall.override(
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
                                                                          if ('${getJsonField(
                                                                                gropsItem,
                                                                                r'''$.user_status''',
                                                                              ).toString()}' ==
                                                                              'admin')
                                                                            FFButtonWidget(
                                                                              onPressed: () {},
                                                                              text: 'Admin',
                                                                              options: FFButtonOptions(
                                                                                height: 24.0,
                                                                                padding: EdgeInsetsDirectional.fromSTEB(12.0, 0.0, 12.0, 0.0),
                                                                                iconPadding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                                                                                color: FlutterFlowTheme.of(context).primary,
                                                                                textStyle: FlutterFlowTheme.of(context).titleSmall.override(
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
                                                                                elevation: 0.0,
                                                                                borderRadius: BorderRadius.only(
                                                                                  topLeft: Radius.circular(100.0),
                                                                                  topRight: Radius.circular(100.0),
                                                                                  bottomLeft: Radius.circular(100.0),
                                                                                  bottomRight: Radius.circular(100.0),
                                                                                ),
                                                                              ),
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
                                                                              onPressed: () async {
                                                                                await GroupMembersTable().insert({
                                                                                  'community_id': FFAppState().communityId,
                                                                                  'user_id': currentUserUid,
                                                                                  'group_id': getJsonField(
                                                                                    gropsItem,
                                                                                    r'''$.group_id''',
                                                                                  ).toString(),
                                                                                  'is_requested': false,
                                                                                  'is_approved': true,
                                                                                  'approved_by': getJsonField(
                                                                                    gropsItem,
                                                                                    r'''$.invited_by_user_id''',
                                                                                  ).toString(),
                                                                                  'joined_at': supaSerialize<DateTime>(functions.getCurrentUtcTime()),
                                                                                });
                                                                                await GroupUserStatusTable().insert({
                                                                                  'community_id': FFAppState().communityId,
                                                                                  'user_id': currentUserUid,
                                                                                  'group_id': getJsonField(
                                                                                    gropsItem,
                                                                                    r'''$.group_id''',
                                                                                  ).toString(),
                                                                                  'is_requested': false,
                                                                                  'is_invited': true,
                                                                                  'is_member': true,
                                                                                  'joined_at': supaSerialize<DateTime>(functions.getCurrentUtcTime()),
                                                                                  'is_approved': true,
                                                                                  'invited_by': getJsonField(
                                                                                    gropsItem,
                                                                                    r'''$.invited_by_user_id''',
                                                                                  ).toString(),
                                                                                });
                                                                                await GroupMembersInviteTable().update(
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
                                                                                _model.apiResultd2ppjj = await UpdateTotalGroupMembersCall.call(
                                                                                  token: currentJwtToken,
                                                                                  anonKey: FFDevEnvironmentValues().AnonKey,
                                                                                  groupId: getJsonField(
                                                                                    gropsItem,
                                                                                    r'''$.group_id''',
                                                                                  ).toString(),
                                                                                );

                                                                                safeSetState(() {});
                                                                              },
                                                                              text: 'Join',
                                                                              options: FFButtonOptions(
                                                                                height: 24.0,
                                                                                padding: EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                                                                                iconPadding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                                                                                color: Colors.transparent,
                                                                                textStyle: FlutterFlowTheme.of(context).titleSmall.override(
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
                                                                              onPressed: () async {
                                                                                await GroupUserStatusTable().update(
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
                                                                                _model.othersGroupData6 = await GetOtherUserFollowingGroupsrCall.call(
                                                                                  token: currentJwtToken,
                                                                                  anonKey: FFDevEnvironmentValues().AnonKey,
                                                                                  userId: widget!.userid,
                                                                                );

                                                                                _model.othersGroup = getJsonField(
                                                                                  (_model.othersGroupData6?.jsonBody ?? ''),
                                                                                  r'''$''',
                                                                                );
                                                                                safeSetState(() {});

                                                                                safeSetState(() {});
                                                                              },
                                                                              text: 'Request',
                                                                              icon: Icon(
                                                                                Icons.lock_outline_sharp,
                                                                                size: 15.0,
                                                                              ),
                                                                              options: FFButtonOptions(
                                                                                height: 24.0,
                                                                                padding: EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                                                                                iconPadding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                                                                                iconColor: FlutterFlowTheme.of(context).primaryD3,
                                                                                color: Colors.transparent,
                                                                                textStyle: FlutterFlowTheme.of(context).titleSmall.override(
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
                                                if (('${getJsonField(
                                                          _model.othersGroup,
                                                          r'''$''',
                                                        ).toString()}' !=
                                                        '[]') &&
                                                    (_model.viewAllGroups ==
                                                        true) &&
                                                    (getJsonField(
                                                          _model.othersGroup,
                                                          r'''$''',
                                                        ) !=
                                                        null))
                                                  Builder(
                                                    builder: (context) {
                                                      final grops =
                                                          getJsonField(
                                                        _model.othersGroup,
                                                        r'''$''',
                                                      ).toList();

                                                      return ListView.separated(
                                                        padding:
                                                            EdgeInsets.fromLTRB(
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
                                                        separatorBuilder:
                                                            (_, __) => SizedBox(
                                                                height: 12.0),
                                                        itemBuilder: (context,
                                                            gropsIndex) {
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
                                                                        'listed') &&
                                                                    ('${getJsonField(
                                                                          gropsItem,
                                                                          r'''$.user_status''',
                                                                        ).toString()}' ==
                                                                        'admin')),
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
                                                                context
                                                                    .pushNamed(
                                                                  GroupDetailsWidget
                                                                      .routeName,
                                                                  queryParameters:
                                                                      {
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
                                                                width: double
                                                                    .infinity,
                                                                constraints:
                                                                    BoxConstraints(
                                                                        minHeight:
                                                                            56.0),
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .secondaryBackground,
                                                                ),
                                                                child: Padding(
                                                                  padding: EdgeInsetsDirectional
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
                                                                        child:
                                                                            Row(
                                                                          mainAxisSize:
                                                                              MainAxisSize.max,
                                                                          children:
                                                                              [
                                                                            ClipRRect(
                                                                              borderRadius: BorderRadius.circular(2.0),
                                                                              child: AppNetworkImage(
                                                                                url: getJsonField(
                                                                                  gropsItem,
                                                                                  r'''$.profile_picture''',
                                                                                ).toString(),
                                                                                width: 40.0,
                                                                                height: 40.0,
                                                                                fit: BoxFit.cover,
                                                                                fallbackIcon: Icons.groups_rounded,
                                                                                semanticLabel: 'Group photo',
                                                                              ),
                                                                            ),
                                                                            Expanded(
                                                                              child: Column(
                                                                                mainAxisSize: MainAxisSize.max,
                                                                                crossAxisAlignment: CrossAxisAlignment.start,
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
                                                                                          child: AppNetworkImage(
                                                                                            url: getJsonField(
                                                                                              gropsItem,
                                                                                              r'''$.invited_by_profile_picture''',
                                                                                            ).toString(),
                                                                                            width: 12.0,
                                                                                            height: 12.0,
                                                                                            fit: BoxFit.cover,
                                                                                            fallbackIcon: Icons.person_rounded,
                                                                                            semanticLabel: 'Profile photo of the neighbour who invited you',
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
                                                                          ].divide(SizedBox(width: 8.0)),
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
                                                                              onPressed: () async {
                                                                                await GroupMembersTable().insert({
                                                                                  'community_id': FFAppState().communityId,
                                                                                  'user_id': currentUserUid,
                                                                                  'group_id': getJsonField(
                                                                                    gropsItem,
                                                                                    r'''$.group_id''',
                                                                                  ).toString(),
                                                                                  'is_requested': false,
                                                                                  'requested_date': supaSerialize<DateTime>(functions.getCurrentUtcTime()),
                                                                                  'is_approved': true,
                                                                                  'approved_by': currentUserUid,
                                                                                  'joined_at': supaSerialize<DateTime>(functions.getCurrentUtcTime()),
                                                                                });
                                                                                await GroupUserStatusTable().insert({
                                                                                  'community_id': FFAppState().communityId,
                                                                                  'user_id': currentUserUid,
                                                                                  'group_id': getJsonField(
                                                                                    gropsItem,
                                                                                    r'''$.group_id''',
                                                                                  ).toString(),
                                                                                  'is_requested': false,
                                                                                  'is_invited': false,
                                                                                  'is_member': true,
                                                                                  'joined_at': supaSerialize<DateTime>(functions.getCurrentUtcTime()),
                                                                                });
                                                                                _model.apiResultd2p22009 = await UpdateTotalGroupMembersCall.call(
                                                                                  token: currentJwtToken,
                                                                                  anonKey: FFDevEnvironmentValues().AnonKey,
                                                                                  groupId: getJsonField(
                                                                                    gropsItem,
                                                                                    r'''$.group_id''',
                                                                                  ).toString(),
                                                                                );

                                                                                _model.othersGroupData2 = await GetOtherUserFollowingGroupsrCall.call(
                                                                                  token: currentJwtToken,
                                                                                  anonKey: FFDevEnvironmentValues().AnonKey,
                                                                                  userId: widget!.userid,
                                                                                );

                                                                                _model.othersGroup = getJsonField(
                                                                                  (_model.othersGroupData2?.jsonBody ?? ''),
                                                                                  r'''$''',
                                                                                );
                                                                                safeSetState(() {});

                                                                                safeSetState(() {});
                                                                              },
                                                                              text: 'Join',
                                                                              options: FFButtonOptions(
                                                                                height: 24.0,
                                                                                padding: EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                                                                                iconPadding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                                                                                color: Colors.transparent,
                                                                                textStyle: FlutterFlowTheme.of(context).titleSmall.override(
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
                                                                              options: FFButtonOptions(
                                                                                height: 24.0,
                                                                                padding: EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                                                                                iconPadding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                                                                                iconColor: FlutterFlowTheme.of(context).greyL4,
                                                                                color: Colors.transparent,
                                                                                textStyle: FlutterFlowTheme.of(context).titleSmall.override(
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
                                                                          if ('${getJsonField(
                                                                                gropsItem,
                                                                                r'''$.user_status''',
                                                                              ).toString()}' ==
                                                                              'requested')
                                                                            FFButtonWidget(
                                                                              onPressed: () {},
                                                                              text: 'Requested',
                                                                              options: FFButtonOptions(
                                                                                height: 24.0,
                                                                                padding: EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                                                                                iconPadding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                                                                                color: FlutterFlowTheme.of(context).greyL2,
                                                                                textStyle: FlutterFlowTheme.of(context).titleSmall.override(
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
                                                                                elevation: 0.0,
                                                                                borderRadius: BorderRadius.only(
                                                                                  topLeft: Radius.circular(100.0),
                                                                                  topRight: Radius.circular(100.0),
                                                                                  bottomLeft: Radius.circular(100.0),
                                                                                  bottomRight: Radius.circular(100.0),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          if ('${getJsonField(
                                                                                gropsItem,
                                                                                r'''$.user_status''',
                                                                              ).toString()}' ==
                                                                              'request')
                                                                            FFButtonWidget(
                                                                              onPressed: () async {
                                                                                await GroupUserStatusTable().insert({
                                                                                  'community_id': FFAppState().communityId,
                                                                                  'user_id': currentUserUid,
                                                                                  'group_id': getJsonField(
                                                                                    gropsItem,
                                                                                    r'''$.group_id''',
                                                                                  ).toString(),
                                                                                  'is_requested': true,
                                                                                  'is_invited': false,
                                                                                  'is_member': false,
                                                                                  'is_approved': false,
                                                                                  'requested_date': supaSerialize<DateTime>(functions.getCurrentUtcTime()),
                                                                                });
                                                                                _model.othersGroupData3 = await GetOtherUserFollowingGroupsrCall.call(
                                                                                  token: currentJwtToken,
                                                                                  anonKey: FFDevEnvironmentValues().AnonKey,
                                                                                  userId: widget!.userid,
                                                                                );

                                                                                _model.othersGroup = getJsonField(
                                                                                  (_model.othersGroupData3?.jsonBody ?? ''),
                                                                                  r'''$''',
                                                                                );
                                                                                safeSetState(() {});

                                                                                safeSetState(() {});
                                                                              },
                                                                              text: 'Request',
                                                                              icon: Icon(
                                                                                Icons.lock_outline_sharp,
                                                                                size: 15.0,
                                                                              ),
                                                                              options: FFButtonOptions(
                                                                                height: 24.0,
                                                                                padding: EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                                                                                iconPadding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                                                                                iconColor: FlutterFlowTheme.of(context).primaryD3,
                                                                                color: Colors.transparent,
                                                                                textStyle: FlutterFlowTheme.of(context).titleSmall.override(
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
                                                                          if ('${getJsonField(
                                                                                gropsItem,
                                                                                r'''$.user_status''',
                                                                              ).toString()}' ==
                                                                              'admin')
                                                                            FFButtonWidget(
                                                                              onPressed: () {},
                                                                              text: 'Admin',
                                                                              options: FFButtonOptions(
                                                                                height: 24.0,
                                                                                padding: EdgeInsetsDirectional.fromSTEB(12.0, 0.0, 12.0, 0.0),
                                                                                iconPadding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                                                                                color: FlutterFlowTheme.of(context).primary,
                                                                                textStyle: FlutterFlowTheme.of(context).titleSmall.override(
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
                                                                                elevation: 0.0,
                                                                                borderRadius: BorderRadius.only(
                                                                                  topLeft: Radius.circular(100.0),
                                                                                  topRight: Radius.circular(100.0),
                                                                                  bottomLeft: Radius.circular(100.0),
                                                                                  bottomRight: Radius.circular(100.0),
                                                                                ),
                                                                              ),
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
                                                                              onPressed: () async {
                                                                                await GroupMembersTable().insert({
                                                                                  'community_id': FFAppState().communityId,
                                                                                  'user_id': currentUserUid,
                                                                                  'group_id': getJsonField(
                                                                                    gropsItem,
                                                                                    r'''$.group_id''',
                                                                                  ).toString(),
                                                                                  'is_requested': false,
                                                                                  'is_approved': true,
                                                                                  'approved_by': getJsonField(
                                                                                    gropsItem,
                                                                                    r'''$.invited_by_user_id''',
                                                                                  ).toString(),
                                                                                  'joined_at': supaSerialize<DateTime>(functions.getCurrentUtcTime()),
                                                                                });
                                                                                await GroupUserStatusTable().insert({
                                                                                  'community_id': FFAppState().communityId,
                                                                                  'user_id': currentUserUid,
                                                                                  'group_id': getJsonField(
                                                                                    gropsItem,
                                                                                    r'''$.group_id''',
                                                                                  ).toString(),
                                                                                  'is_requested': false,
                                                                                  'is_invited': true,
                                                                                  'is_member': true,
                                                                                  'joined_at': supaSerialize<DateTime>(functions.getCurrentUtcTime()),
                                                                                  'is_approved': true,
                                                                                  'invited_by': getJsonField(
                                                                                    gropsItem,
                                                                                    r'''$.invited_by_user_id''',
                                                                                  ).toString(),
                                                                                });
                                                                                await GroupMembersInviteTable().update(
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
                                                                                _model.apiResultd2ppjj0 = await UpdateTotalGroupMembersCall.call(
                                                                                  token: currentJwtToken,
                                                                                  anonKey: FFDevEnvironmentValues().AnonKey,
                                                                                  groupId: getJsonField(
                                                                                    gropsItem,
                                                                                    r'''$.group_id''',
                                                                                  ).toString(),
                                                                                );

                                                                                safeSetState(() {});
                                                                              },
                                                                              text: 'Join',
                                                                              options: FFButtonOptions(
                                                                                height: 24.0,
                                                                                padding: EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                                                                                iconPadding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                                                                                color: Colors.transparent,
                                                                                textStyle: FlutterFlowTheme.of(context).titleSmall.override(
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
                                                                              onPressed: () async {
                                                                                await GroupUserStatusTable().update(
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
                                                                                _model.othersGroupData1 = await GetOtherUserFollowingGroupsrCall.call(
                                                                                  token: currentJwtToken,
                                                                                  anonKey: FFDevEnvironmentValues().AnonKey,
                                                                                  userId: widget!.userid,
                                                                                );

                                                                                _model.othersGroup = getJsonField(
                                                                                  (_model.othersGroupData1?.jsonBody ?? ''),
                                                                                  r'''$''',
                                                                                );
                                                                                safeSetState(() {});

                                                                                safeSetState(() {});
                                                                              },
                                                                              text: 'Request',
                                                                              icon: Icon(
                                                                                Icons.lock_outline_sharp,
                                                                                size: 15.0,
                                                                              ),
                                                                              options: FFButtonOptions(
                                                                                height: 24.0,
                                                                                padding: EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                                                                                iconPadding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                                                                                iconColor: FlutterFlowTheme.of(context).primaryD3,
                                                                                color: Colors.transparent,
                                                                                textStyle: FlutterFlowTheme.of(context).titleSmall.override(
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
                                              ],
                                            ),
                                          ],
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
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .secondaryBackground,
                                            ),
                                            child: Padding(
                                              padding: EdgeInsetsDirectional
                                                  .fromSTEB(
                                                      20.0, 12.0, 20.0, 12.0),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.max,
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    'Posts',
                                                    style: FlutterFlowTheme.of(
                                                            context)
                                                        .bodyMedium
                                                        .override(
                                                          font: GoogleFonts
                                                              .manrope(
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            fontStyle:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .fontStyle,
                                                          ),
                                                          color: FlutterFlowTheme
                                                                  .of(context)
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
                                                  if (_model.postCount!.length >
                                                      1)
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
                                                          UserAllPostWidget
                                                              .routeName,
                                                          queryParameters: {
                                                            'userid':
                                                                serializeParam(
                                                              widget!.userid,
                                                              ParamType.String,
                                                            ),
                                                          }.withoutNulls,
                                                        );
                                                      },
                                                      child: Text(
                                                        'View all',
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
                                                                  lineHeight:
                                                                      1.4,
                                                                ),
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Builder(
                                            builder: (context) {
                                              final posts = functions
                                                  .returnLimitedPosts(
                                                      FFAppState().AsPost,
                                                      1,
                                                      widget!.userid!)
                                                  .toList();

                                              // Designed empty state instead of
                                              // a blank gap under the tabs.
                                              if (posts.isEmpty) {
                                                return EmptyState(
                                                  icon: Icons.forum_outlined,
                                                  title: 'No posts yet',
                                                  body:
                                                      'This neighbour has not shared anything you can see.',
                                                );
                                              }

                                              return SingleChildScrollView(
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  children: List.generate(
                                                      posts.length,
                                                      (postsIndex) {
                                                    final postsItem =
                                                        posts[postsIndex];
                                                    return Stack(
                                                      children: [
                                                        Container(
                                                          decoration:
                                                              BoxDecoration(
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .white,
                                                          ),
                                                          child: Column(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .max,
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
                                                                          splashColor: FlutterFlowTheme.of(context)
                                                                              .primary
                                                                              .withAlpha(0x14),
                                                                          focusColor:
                                                                              Colors.transparent,
                                                                          hoverColor:
                                                                              Colors.transparent,
                                                                          highlightColor:
                                                                              Colors.transparent,
                                                                          onTap:
                                                                              () async {
                                                                            if (getJsonField(
                                                                                  postsItem,
                                                                                  r'''$.user_id''',
                                                                                ) !=
                                                                                currentUserUid) {
                                                                              context.pushNamed(
                                                                                OtherProfileWidget.routeName,
                                                                                queryParameters: {
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
                                                                              context.pushNamed(UserProfileWidget.routeName);
                                                                            }
                                                                          },
                                                                          child:
                                                                              Row(
                                                                            mainAxisSize:
                                                                                MainAxisSize.max,
                                                                            children:
                                                                                [
                                                                              Container(
                                                                                width: 32.0,
                                                                                height: 32.0,
                                                                                clipBehavior: Clip.antiAlias,
                                                                                decoration: BoxDecoration(
                                                                                  shape: BoxShape.circle,
                                                                                ),
                                                                                child: AppNetworkImage(
                                                                                  url: getJsonField(
                                                                                    postsItem,
                                                                                    r'''$.user_profile_picture''',
                                                                                  ).toString(),
                                                                                  width: 32.0,
                                                                                  height: 32.0,
                                                                                  fit: BoxFit.cover,
                                                                                  fallbackIcon: Icons.person_rounded,
                                                                                  semanticLabel: '${getJsonField(
                                                                                    postsItem,
                                                                                    r'''$.user_name''',
                                                                                  ).toString()} profile photo',
                                                                                ),
                                                                              ),
                                                                              Column(
                                                                                mainAxisSize: MainAxisSize.max,
                                                                                crossAxisAlignment: CrossAxisAlignment.start,
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
                                                                              MainAxisSize.max,
                                                                          children: [
                                                                            InkWell(
                                                                              splashColor: FlutterFlowTheme.of(context).primary.withAlpha(0x14),
                                                                              focusColor: Colors.transparent,
                                                                              hoverColor: Colors.transparent,
                                                                              highlightColor: Colors.transparent,
                                                                              onTap: () async {
                                                                                HapticFeedback.lightImpact();
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
                                                                              child: Container(
                                                                                decoration: BoxDecoration(),
                                                                                child: Padding(
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
                                                                            Transform.rotate(
                                                                              angle: 90.0 * (math.pi / 180),
                                                                              child: InkWell(
                                                                                splashColor: FlutterFlowTheme.of(context).primary.withAlpha(0x14),
                                                                                focusColor: Colors.transparent,
                                                                                hoverColor: Colors.transparent,
                                                                                highlightColor: Colors.transparent,
                                                                                onTap: () async {
                                                                                  _model.reportPostId = getJsonField(
                                                                                    postsItem,
                                                                                    r'''$.id''',
                                                                                  ).toString();
                                                                                  safeSetState(() {});
                                                                                },
                                                                                child: Container(
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
                                                                      padding: EdgeInsetsDirectional.fromSTEB(
                                                                          20.0,
                                                                          0.0,
                                                                          20.0,
                                                                          0.0),
                                                                      child:
                                                                          Column(
                                                                        mainAxisSize:
                                                                            MainAxisSize.max,
                                                                        children: [
                                                                          Row(
                                                                            mainAxisSize:
                                                                                MainAxisSize.max,
                                                                            crossAxisAlignment:
                                                                                CrossAxisAlignment.end,
                                                                            children: [
                                                                              if (_model.postReadmore == false)
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
                                                                              if (_model.postReadmore == true)
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
                                                                              alignment: AlignmentDirectional(1.0, -1.0),
                                                                              child: Column(
                                                                                mainAxisSize: MainAxisSize.max,
                                                                                children: [
                                                                                  InkWell(
                                                                                    splashColor: FlutterFlowTheme.of(context).primary.withAlpha(0x14),
                                                                                    focusColor: Colors.transparent,
                                                                                    hoverColor: Colors.transparent,
                                                                                    highlightColor: Colors.transparent,
                                                                                    onTap: () async {
                                                                                      if (_model.postReadmore == false) {
                                                                                        _model.postReadmore = false;
                                                                                        safeSetState(() {});
                                                                                      } else {
                                                                                        _model.postReadmore = true;
                                                                                        safeSetState(() {});
                                                                                      }
                                                                                    },
                                                                                    child: Container(
                                                                                      decoration: BoxDecoration(),
                                                                                      child: Padding(
                                                                                        padding: EdgeInsetsDirectional.fromSTEB(6.0, 6.0, 6.0, 6.0),
                                                                                        child: Text(
                                                                                          valueOrDefault<String>(
                                                                                            _model.postReadmore != false ? 'Read More' : 'Read Less',
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
                                                                      height:
                                                                          200.0,
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
                                                                          ClipRRect(
                                                                            borderRadius:
                                                                                BorderRadius.circular(0.0),
                                                                            child:
                                                                                AppNetworkImage(
                                                                              url: getJsonField(
                                                                                postsItem,
                                                                                r'''$.post_images[0]''',
                                                                              ).toString(),
                                                                              width: double.infinity,
                                                                              fit: BoxFit.contain,
                                                                              semanticLabel: 'Post photo',
                                                                            ),
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
                                                                            key:
                                                                                Key('Keyzw6_${postsIndex}_of_${posts.length}'),
                                                                            images:
                                                                                getJsonField(
                                                                              postsItem,
                                                                              r'''$.post_images''',
                                                                            ),
                                                                          ),
                                                                      ],
                                                                    ),
                                                                ].divide(SizedBox(
                                                                    height:
                                                                        10.0)),
                                                              ),
                                                              Padding(
                                                                padding: EdgeInsetsDirectional
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
                                                                        InkWell(
                                                                          splashColor: FlutterFlowTheme.of(context)
                                                                              .primary
                                                                              .withAlpha(0x14),
                                                                          focusColor:
                                                                              Colors.transparent,
                                                                          hoverColor:
                                                                              Colors.transparent,
                                                                          highlightColor:
                                                                              Colors.transparent,
                                                                          onTap:
                                                                              () async {
                                                                            _model.addlike2 =
                                                                                await AddLikeCall.call(
                                                                              pCommunityid: FFAppState().communityId.toString(),
                                                                              pUserid: currentUserUid,
                                                                              pPostid: getJsonField(
                                                                                postsItem,
                                                                                r'''$.id''',
                                                                              ).toString(),
                                                                              token: currentJwtToken,
                                                                            );

                                                                            safeSetState(() {});
                                                                          },
                                                                          child:
                                                                              Container(
                                                                            decoration:
                                                                                BoxDecoration(),
                                                                            child:
                                                                                Padding(
                                                                              padding: EdgeInsetsDirectional.fromSTEB(6.0, 6.0, 4.0, 6.0),
                                                                              child: Stack(
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
                                                                          splashColor: FlutterFlowTheme.of(context)
                                                                              .primary
                                                                              .withAlpha(0x14),
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
                                                                              context: context,
                                                                              builder: (context) {
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
                                                                              padding: EdgeInsetsDirectional.fromSTEB(0.0, 9.0, 16.0, 9.0),
                                                                              child: Text(
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
                                                                      splashColor: FlutterFlowTheme.of(
                                                                              context)
                                                                          .primary
                                                                          .withAlpha(
                                                                              0x14),
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
                                                                        if ('${getJsonField(
                                                                              postsItem,
                                                                              r'''$.comment_post_access_id''',
                                                                            ).toString()}' ==
                                                                            '1') {
                                                                          context
                                                                              .pushNamed(
                                                                            CommentsPageWidget.routeName,
                                                                            queryParameters:
                                                                                {
                                                                              'postId': serializeParam(
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
                                                                      child:
                                                                          Container(
                                                                        width:
                                                                            70.0,
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
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.center,
                                                                            children:
                                                                                [
                                                                              if ('${getJsonField(
                                                                                    postsItem,
                                                                                    r'''$.comment_post_access_id''',
                                                                                  ).toString()}' ==
                                                                                  '1')
                                                                                ClipRRect(
                                                                                  borderRadius: BorderRadius.circular(0.0),
                                                                                  child: Image.asset(
                                                                                    'assets/images/forum.png',
                                                                                    width: 22.0,
                                                                                    height: 22.0,
                                                                                    fit: BoxFit.cover,
                                                                                  ),
                                                                                ),
                                                                              if ('${getJsonField(
                                                                                    postsItem,
                                                                                    r'''$.comment_post_access_id''',
                                                                                  ).toString()}' ==
                                                                                  '4')
                                                                                ClipRRect(
                                                                                  borderRadius: BorderRadius.circular(0.0),
                                                                                  child: Image.asset(
                                                                                    'assets/images/forum.webp',
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
                                                                      splashColor: FlutterFlowTheme.of(
                                                                              context)
                                                                          .primary
                                                                          .withAlpha(
                                                                              0x14),
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
                                                                        ).then((value) =>
                                                                            safeSetState(() {}));
                                                                      },
                                                                      child:
                                                                          Container(
                                                                        width:
                                                                            70.0,
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
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.center,
                                                                            children:
                                                                                [
                                                                              ClipRRect(
                                                                                borderRadius: BorderRadius.circular(0.0),
                                                                                child: Image.asset(
                                                                                  'assets/images/share_windows.png',
                                                                                  width: 22.0,
                                                                                  height: 22.0,
                                                                                  fit: BoxFit.cover,
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
                                                                    height:
                                                                        4.0))
                                                                .addToStart(
                                                                    SizedBox(
                                                                        height:
                                                                            12.0))
                                                                .addToEnd(
                                                                    SizedBox(
                                                                        height:
                                                                            6.0)),
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
                                                                child:
                                                                    Container(
                                                                  width: 140.0,
                                                                  height: 38.0,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: FlutterFlowTheme.of(
                                                                            context)
                                                                        .secondaryBackground,
                                                                    boxShadow: [
                                                                      BoxShadow(
                                                                        blurRadius:
                                                                            6.0,
                                                                        color: Color(
                                                                            0x33000000),
                                                                        offset:
                                                                            Offset(
                                                                          0.0,
                                                                          2.0,
                                                                        ),
                                                                        spreadRadius:
                                                                            0.0,
                                                                      )
                                                                    ],
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            8.0),
                                                                  ),
                                                                  child:
                                                                      Padding(
                                                                    padding: EdgeInsetsDirectional
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
                                                                              BorderRadius.circular(8.0),
                                                                          child:
                                                                              Image.asset(
                                                                            'assets/images/flag_2.webp',
                                                                            width:
                                                                                20.0,
                                                                            height:
                                                                                20.0,
                                                                            fit:
                                                                                BoxFit.cover,
                                                                          ),
                                                                        ),
                                                                        Text(
                                                                          'Report Post',
                                                                          style: FlutterFlowTheme.of(context)
                                                                              .bodyMedium
                                                                              .override(
                                                                                font: GoogleFonts.manrope(
                                                                                  fontWeight: FontWeight.w500,
                                                                                  fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                ),
                                                                                color: FlutterFlowTheme.of(context).greyD1,
                                                                                letterSpacing: 0.0,
                                                                                fontWeight: FontWeight.w500,
                                                                                fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
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
                                                  }).divide(
                                                      SizedBox(height: 8.0)),
                                                ),
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Column(
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          color: FlutterFlowTheme.of(context)
                                              .white,
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            0.0, 4.0, 0.0, 0.0),
                                        child: Container(
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                            color: FlutterFlowTheme.of(context)
                                                .secondaryBackground,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (((int var1) {
                                        return var1 != 0;
                                      }(getJsonField(
                                        _model.neighbourHoods,
                                        r'''$.others_count''',
                                      ))) ==
                                      true)
                                    Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          0.0, 12.0, 0.0, 0.0),
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
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .secondaryBackground,
                                              ),
                                              child: Padding(
                                                padding: EdgeInsetsDirectional
                                                    .fromSTEB(
                                                        20.0, 12.0, 0.0, 12.0),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      'People you may know',
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
                                                    if ((getJsonField(
                                                              _model
                                                                  .neighbourHoods,
                                                              r'''$.others_count''',
                                                            ) >
                                                            5) ==
                                                        true)
                                                      InkWell(
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
                                                                      Container(
                                                                    height:
                                                                        500.0,
                                                                    child:
                                                                        CompFollowNearbyWidget(),
                                                                  ),
                                                                ),
                                                              );
                                                            },
                                                          ).then((value) =>
                                                              safeSetState(
                                                                  () {}));
                                                        },
                                                        child: Container(
                                                          width: 100.0,
                                                          height: 30.0,
                                                          decoration:
                                                              BoxDecoration(),
                                                          alignment:
                                                              AlignmentDirectional(
                                                                  0.0, 0.0),
                                                          child: Text(
                                                            'View all',
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
                                                                  lineHeight:
                                                                      1.4,
                                                                ),
                                                          ),
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            Builder(
                                              builder: (context) {
                                                final neighbours = getJsonField(
                                                  _model.neighbourHoods,
                                                  r'''$.others''',
                                                ).toList();

                                                return ListView.builder(
                                                  padding: EdgeInsets.zero,
                                                  shrinkWrap: true,
                                                  scrollDirection:
                                                      Axis.vertical,
                                                  itemCount: neighbours.length,
                                                  itemBuilder: (context,
                                                      neighboursIndex) {
                                                    final neighboursItem =
                                                        neighbours[
                                                            neighboursIndex];
                                                    return Container(
                                                      width: double.infinity,
                                                      decoration: BoxDecoration(
                                                        color: FlutterFlowTheme
                                                                .of(context)
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
                                                                  children: [
                                                                    Align(
                                                                      alignment:
                                                                          AlignmentDirectional(
                                                                              0.0,
                                                                              -1.0),
                                                                      child:
                                                                          Container(
                                                                        width:
                                                                            32.0,
                                                                        height:
                                                                            32.0,
                                                                        clipBehavior:
                                                                            Clip.antiAlias,
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          shape:
                                                                              BoxShape.circle,
                                                                        ),
                                                                        child:
                                                                            AppNetworkImage(
                                                                          url:
                                                                              getJsonField(
                                                                            neighboursItem,
                                                                            r'''$.profile_picture''',
                                                                          ).toString(),
                                                                          width:
                                                                              32.0,
                                                                          height:
                                                                              32.0,
                                                                          fit: BoxFit
                                                                              .cover,
                                                                          fallbackIcon:
                                                                              Icons.person_rounded,
                                                                          semanticLabel:
                                                                              '${getJsonField(
                                                                            neighboursItem,
                                                                            r'''$.name''',
                                                                          ).toString()} profile photo',
                                                                        ),
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
                                                                            neighboursItem,
                                                                            r'''$.name''',
                                                                          ).toString(),
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
                                                                        Text(
                                                                          getJsonField(
                                                                            neighboursItem,
                                                                            r'''$.city''',
                                                                          ).toString(),
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
                                                                  ].divide(SizedBox(
                                                                      width:
                                                                          8.0)),
                                                                ),
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
                                                                    await AddFollowCall
                                                                        .call(
                                                                      pFollowerid:
                                                                          currentUserUid,
                                                                      pFollowingid:
                                                                          getJsonField(
                                                                        neighboursItem,
                                                                        r'''$.user_id''',
                                                                      ).toString(),
                                                                      pCommunityid:
                                                                          FFAppState()
                                                                              .communityId,
                                                                      token:
                                                                          currentJwtToken,
                                                                    );

                                                                    _model.neighbourData13 =
                                                                        await GetNeighborhoodPeoplesCall
                                                                            .call(
                                                                      pUserid:
                                                                          currentUserUid,
                                                                      token:
                                                                          currentJwtToken,
                                                                      pCommunityid:
                                                                          FFAppState()
                                                                              .communityId,
                                                                    );

                                                                    _model
                                                                        .neighbourHoods = (_model
                                                                            .neighbourData13
                                                                            ?.jsonBody ??
                                                                        '');
                                                                    safeSetState(
                                                                        () {});

                                                                    safeSetState(
                                                                        () {});
                                                                  },
                                                                  child:
                                                                      Container(
                                                                    width: 80.0,
                                                                    height:
                                                                        30.0,
                                                                    decoration:
                                                                        BoxDecoration(),
                                                                    alignment:
                                                                        AlignmentDirectional(
                                                                            0.0,
                                                                            0.0),
                                                                    child: Row(
                                                                      mainAxisSize:
                                                                          MainAxisSize
                                                                              .max,
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .center,
                                                                      children:
                                                                          [
                                                                        Icon(
                                                                          Icons
                                                                              .add,
                                                                          color:
                                                                              FlutterFlowTheme.of(context).primaryD3,
                                                                          size:
                                                                              12.0,
                                                                        ),
                                                                        Text(
                                                                          'Follow',
                                                                          style: FlutterFlowTheme.of(context)
                                                                              .bodyMedium
                                                                              .override(
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
                                                                      ].divide(SizedBox(
                                                                              width: 6.0)),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          Container(
                                                            width:
                                                                double.infinity,
                                                            height: 1.0,
                                                            decoration:
                                                                BoxDecoration(
                                                              color: FlutterFlowTheme
                                                                      .of(context)
                                                                  .greayL1,
                                                            ),
                                                          ),
                                                        ],
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
                                ].addToEnd(SizedBox(height: 20.0)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
