import '/components/async_state_view.dart';
import '/components/empty_state.dart';
import '/components/app_icon_button.dart';
import '/components/app_network_image.dart';
import '/auth/supabase_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/backend/supabase/supabase.dart';
import '/components/comp_no_data_found_widget.dart';
import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/pages/home/comp_loading/comp_loading_widget.dart';
import 'dart:math';
import 'dart:ui';
import '/custom_code/actions/index.dart' as actions;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'comp_followers_model.dart';
export 'comp_followers_model.dart';

class CompFollowersWidget extends StatefulWidget {
  const CompFollowersWidget({
    super.key,
    required this.groupId,
  });

  final String? groupId;

  @override
  State<CompFollowersWidget> createState() => _CompFollowersWidgetState();
}

class _CompFollowersWidgetState extends State<CompFollowersWidget>
    with TickerProviderStateMixin {
  late CompFollowersModel _model;

  final animationsMap = <String, AnimationInfo>{};

  /// Non-null when the followers fetch failed; drives the error state.
  Object? _loadError;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => CompFollowersModel());

    // On component load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      await _loadFollowers();
    });

    animationsMap.addAll({
      'containerOnPageLoadAnimation1': AnimationInfo(
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
      'containerOnPageLoadAnimation4': AnimationInfo(
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
      'containerOnPageLoadAnimation5': AnimationInfo(
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
      'containerOnPageLoadAnimation6': AnimationInfo(
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
      'containerOnPageLoadAnimation7': AnimationInfo(
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
      'containerOnPageLoadAnimation8': AnimationInfo(
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
      'containerOnPageLoadAnimation9': AnimationInfo(
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

  /// Loads the followers list, recording any failure so the UI can show it.
  Future<void> _loadFollowers() async {
    try {
      _loadError = null;
      await actions.loadFollowersRealTime(
        ' ',
      );
    } catch (e) {
      _loadError = e;
    }
    _model.show = true;
    safeSetState(() {});
  }

  /// Retry handler for the error state: re-shows the skeleton, then re-fetches.
  Future<void> _retryLoad() async {
    _loadError = null;
    _model.show = false;
    safeSetState(() {});
    await _loadFollowers();
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    return Container(
      height: 500.0,
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.0),
          topRight: Radius.circular(24.0),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Container(
            width: 134.0,
            height: 5.0,
            decoration: BoxDecoration(
              color: FlutterFlowTheme.of(context).extraBlack,
              borderRadius: BorderRadius.circular(24.0),
            ),
          ),
          Padding(
            padding: EdgeInsetsDirectional.fromSTEB(0.0, 16.0, 0.0, 0.0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Padding(
                      padding:
                          EdgeInsetsDirectional.fromSTEB(10.0, 0.0, 0.0, 0.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Align(
                            alignment: AlignmentDirectional(-1.0, 0.0),
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
                          Text(
                            'People Following you',
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
                    ),
                  ],
                ),
              ].divide(SizedBox(height: 24.0)),
            ),
          ),
          if (_loadError != null)
            Expanded(
              child: EmptyState(
                icon: Icons.error_outline_rounded,
                iconColor: FlutterFlowTheme.of(context).error,
                iconBackgroundColor:
                    FlutterFlowTheme.of(context).error.withAlpha(0x1F),
                title: 'Something went wrong',
                body: AsyncStateView.describeError(_loadError!),
                actionLabel: 'Retry',
                onAction: _retryLoad,
                compact: true,
              ),
            ),
          if (_loadError == null && _model.show)
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  if ('${getJsonField(
                        FFAppState().followers,
                        r'''$''',
                      ).toString()}' !=
                      '[]')
                    Builder(
                      builder: (context) {
                        final followers = getJsonField(
                          FFAppState().followers,
                          r'''$''',
                        ).toList();

                        return ListView.builder(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          scrollDirection: Axis.vertical,
                          itemCount: followers.length,
                          itemBuilder: (context, followersIndex) {
                            final followersItem = followers[followersIndex];
                            return Padding(
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
                                    Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          20.0, 12.0, 20.0, 12.0),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Container(
                                                width: 32.0,
                                                height: 32.0,
                                                clipBehavior: Clip.antiAlias,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                ),
                                                child: AppNetworkImage(
                                                  url: getJsonField(
                                                    followersItem,
                                                    r'''$.profile_picture''',
                                                  ).toString(),
                                                  width: 32.0,
                                                  height: 32.0,
                                                  fit: BoxFit.cover,
                                                  fallbackIcon:
                                                      Icons.person_rounded,
                                                  semanticLabel:
                                                      '${getJsonField(
                                                    followersItem,
                                                    r'''$.name''',
                                                  ).toString()} profile photo',
                                                ),
                                              ),
                                              Column(
                                                mainAxisSize: MainAxisSize.max,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    getJsonField(
                                                      followersItem,
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
                                                            fontStyle:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .fontStyle,
                                                          ),
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .extraBlack,
                                                          fontSize: 16.0,
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
                                                  Text(
                                                    getJsonField(
                                                      followersItem,
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
                                                            fontStyle:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .fontStyle,
                                                          ),
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .greyL4,
                                                          fontSize: 12.0,
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FontWeight.w500,
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
                                            ].divide(SizedBox(width: 8.0)),
                                          ),
                                          FutureBuilder<List<FollowsRow>>(
                                            future:
                                                FollowsTable().querySingleRow(
                                              queryFn: (q) => q
                                                  .eqOrNull(
                                                    'follower_id',
                                                    currentUserUid,
                                                  )
                                                  .eqOrNull(
                                                    'following_id',
                                                    getJsonField(
                                                      followersItem,
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
                                              List<FollowsRow>
                                                  stackFollowsRowList =
                                                  snapshot.data!;

                                              final stackFollowsRow =
                                                  stackFollowsRowList.isNotEmpty
                                                      ? stackFollowsRowList
                                                          .first
                                                      : null;

                                              return Stack(
                                                children: [
                                                  if (stackFollowsRow?.id ==
                                                          null ||
                                                      stackFollowsRow?.id == '')
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
                                                        HapticFeedback
                                                            .lightImpact();
                                                        await AddFollowCall
                                                            .call(
                                                          pFollowerid:
                                                              currentUserUid,
                                                          pFollowingid:
                                                              getJsonField(
                                                            followersItem,
                                                            r'''$.user_id''',
                                                          ).toString(),
                                                          pCommunityid:
                                                              FFAppState()
                                                                  .communityId,
                                                          token:
                                                              currentJwtToken,
                                                        );
                                                      },
                                                      child: Row(
                                                        mainAxisSize:
                                                            MainAxisSize.max,
                                                        children: [
                                                          Icon(
                                                            Icons.add,
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .primaryD3,
                                                            size: 14.0,
                                                          ),
                                                          Text(
                                                            'Follow',
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
                                                                      .primaryD3,
                                                                  fontSize:
                                                                      12.0,
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
                                                        ].divide(SizedBox(
                                                            width: 6.0)),
                                                      ),
                                                    ),
                                                  if (stackFollowsRow?.id !=
                                                          null &&
                                                      stackFollowsRow?.id != '')
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
                                                        HapticFeedback
                                                            .lightImpact();
                                                        await AddFollowCall
                                                            .call(
                                                          pFollowerid:
                                                              currentUserUid,
                                                          pFollowingid:
                                                              getJsonField(
                                                            followersItem,
                                                            r'''$.user_id''',
                                                          ).toString(),
                                                          pCommunityid:
                                                              FFAppState()
                                                                  .communityId,
                                                          token:
                                                              currentJwtToken,
                                                        );
                                                      },
                                                      child: Row(
                                                        mainAxisSize:
                                                            MainAxisSize.max,
                                                        children: [
                                                          ClipRRect(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8.0),
                                                            child: Image.asset(
                                                              'assets/images/check.png',
                                                              width: 12.0,
                                                              height: 12.0,
                                                              fit: BoxFit.cover,
                                                            ),
                                                          ),
                                                          Text(
                                                            'Following',
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
                                                        ].divide(SizedBox(
                                                            width: 6.0)),
                                                      ),
                                                    ),
                                                ],
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      width: double.infinity,
                                      height: 1.0,
                                      decoration: BoxDecoration(
                                        color: FlutterFlowTheme.of(context)
                                            .greayL1,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                                .animate()
                                .fadeIn(
                                  duration: 260.ms,
                                  delay: (40 * (followersIndex % 8)).ms,
                                )
                                .slideY(
                                  begin: 0.06,
                                  end: 0,
                                  curve: Curves.easeOutCubic,
                                );
                          },
                        );
                      },
                    ),
                  if ('${getJsonField(
                        FFAppState().followers,
                        r'''$''',
                      ).toString()}' ==
                      '[]')
                    Expanded(
                      child: Align(
                        alignment: AlignmentDirectional(0.0, 0.0),
                        child: wrapWithModel(
                          model: _model.compNoDataFoundModel,
                          updateCallback: () => safeSetState(() {}),
                          child: CompNoDataFoundWidget(
                            pageName: 'followers',
                            text1: 'No followers yet',
                            text2:
                                'Once someone follows you, they\'ll show up here.',
                          ),
                        ).animate().fadeIn(duration: 400.ms).scale(
                              begin: Offset(0.92, 0.92),
                              end: Offset(1, 1),
                              curve: Curves.easeOutBack,
                            ),
                      ),
                    ),
                ],
              ),
            ),
          if (_loadError == null && !_model.show)
            Align(
              alignment: AlignmentDirectional(0.0, 0.0),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Padding(
                    padding:
                        EdgeInsetsDirectional.fromSTEB(20.0, 12.0, 0.0, 12.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Container(
                          width: 32.0,
                          height: 32.0,
                          decoration: BoxDecoration(
                            color: FlutterFlowTheme.of(context).greyL2,
                            borderRadius: BorderRadius.circular(24.0),
                          ),
                        ).animateOnPageLoad(
                            animationsMap['containerOnPageLoadAnimation1']!),
                        Column(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 200.0,
                              height: 20.0,
                              decoration: BoxDecoration(
                                color: FlutterFlowTheme.of(context).greyL2,
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ).animateOnPageLoad(animationsMap[
                                'containerOnPageLoadAnimation2']!),
                            Container(
                              width: 100.0,
                              height: 14.0,
                              decoration: BoxDecoration(
                                color: FlutterFlowTheme.of(context).greyL2,
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ).animateOnPageLoad(animationsMap[
                                'containerOnPageLoadAnimation3']!),
                          ].divide(SizedBox(height: 4.0)),
                        ),
                      ].divide(SizedBox(width: 10.0)),
                    ),
                  ),
                  Padding(
                    padding:
                        EdgeInsetsDirectional.fromSTEB(20.0, 12.0, 0.0, 12.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Container(
                          width: 32.0,
                          height: 32.0,
                          decoration: BoxDecoration(
                            color: FlutterFlowTheme.of(context).greyL2,
                            borderRadius: BorderRadius.circular(24.0),
                          ),
                        ).animateOnPageLoad(
                            animationsMap['containerOnPageLoadAnimation4']!),
                        Column(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 200.0,
                              height: 20.0,
                              decoration: BoxDecoration(
                                color: FlutterFlowTheme.of(context).greyL2,
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ).animateOnPageLoad(animationsMap[
                                'containerOnPageLoadAnimation5']!),
                            Container(
                              width: 100.0,
                              height: 14.0,
                              decoration: BoxDecoration(
                                color: FlutterFlowTheme.of(context).greyL2,
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ).animateOnPageLoad(animationsMap[
                                'containerOnPageLoadAnimation6']!),
                          ].divide(SizedBox(height: 4.0)),
                        ),
                      ].divide(SizedBox(width: 10.0)),
                    ),
                  ),
                  Padding(
                    padding:
                        EdgeInsetsDirectional.fromSTEB(20.0, 12.0, 0.0, 12.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Container(
                          width: 32.0,
                          height: 32.0,
                          decoration: BoxDecoration(
                            color: FlutterFlowTheme.of(context).greyL2,
                            borderRadius: BorderRadius.circular(24.0),
                          ),
                        ).animateOnPageLoad(
                            animationsMap['containerOnPageLoadAnimation7']!),
                        Column(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 200.0,
                              height: 20.0,
                              decoration: BoxDecoration(
                                color: FlutterFlowTheme.of(context).greyL2,
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ).animateOnPageLoad(animationsMap[
                                'containerOnPageLoadAnimation8']!),
                            Container(
                              width: 100.0,
                              height: 14.0,
                              decoration: BoxDecoration(
                                color: FlutterFlowTheme.of(context).greyL2,
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ).animateOnPageLoad(animationsMap[
                                'containerOnPageLoadAnimation9']!),
                          ].divide(SizedBox(height: 4.0)),
                        ),
                      ].divide(SizedBox(width: 10.0)),
                    ),
                  ),
                ],
              ),
            ),
        ].addToStart(SizedBox(height: 8.0)).addToEnd(SizedBox(height: 24.0)),
      ),
    );
  }
}
