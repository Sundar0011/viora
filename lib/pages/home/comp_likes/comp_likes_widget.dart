import '/components/app_network_image.dart';
import '/auth/supabase_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/pages/home/comp_loading/comp_loading_widget.dart';
import '/pages/profile/shimmer_loader_followers/shimmer_loader_followers_widget.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'comp_likes_model.dart';
export 'comp_likes_model.dart';

class CompLikesWidget extends StatefulWidget {
  const CompLikesWidget({
    super.key,
    required this.postId,
    required this.postUserid,
  });

  final String? postId;
  final String? postUserid;

  @override
  State<CompLikesWidget> createState() => _CompLikesWidgetState();
}

class _CompLikesWidgetState extends State<CompLikesWidget> {
  late CompLikesModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => CompLikesModel());

    // On component load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      _model.apiResultmbg = await GetLikedUsersCall.call(
        pPostid: widget!.postId,
        token: currentJwtToken,
      );

      await Future.delayed(
        Duration(
          milliseconds: 2000,
        ),
      );
      _model.showData = true;
      safeSetState(() {});
    });
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
            padding: EdgeInsetsDirectional.fromSTEB(10.0, 0.0, 0.0, 0.0),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Align(
                  alignment: AlignmentDirectional(-1.0, 0.0),
                  child: FlutterFlowIconButton(
                    borderRadius: 100.0,
                    icon: Icon(
                      Icons.arrow_back,
                      color: FlutterFlowTheme.of(context).extraBlack,
                      size: 24.0,
                    ),
                    onPressed: () async {
                      context.safePop();
                    },
                  ),
                ),
                Text(
                  'Likes',
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                        font: GoogleFonts.manrope(
                          fontWeight: FontWeight.w600,
                          fontStyle:
                              FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                        ),
                        color: FlutterFlowTheme.of(context).extraBlack,
                        fontSize: 18.0,
                        letterSpacing: 0.0,
                        fontWeight: FontWeight.w600,
                        fontStyle:
                            FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                        lineHeight: 1.4,
                      ),
                ),
              ].divide(SizedBox(width: 10.0)),
            ),
          ),
          if (((_model.apiResultmbg?.bodyText ?? '') != '[]') &&
              _model.showData)
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(0.0, 16.0, 0.0, 0.0),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  ListView(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    scrollDirection: Axis.vertical,
                    children: [
                      Builder(
                        builder: (context) {
                          final likedUsers =
                              (_model.apiResultmbg?.jsonBody ?? '').toList();

                          return Column(
                            mainAxisSize: MainAxisSize.max,
                            children: List.generate(likedUsers.length,
                                (likedUsersIndex) {
                              final likedUsersItem =
                                  likedUsers[likedUsersIndex];
                              return Padding(
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
                                        AppNetworkImage(
                                          url: getJsonField(
                                            likedUsersItem,
                                            r'''$.profile_picture''',
                                          ).toString(),
                                          width: 32.0,
                                          height: 32.0,
                                          fit: BoxFit.cover,
                                          isAvatar: true,
                                          semanticLabel: 'Profile photo of ' +
                                              getJsonField(likedUsersItem,
                                                      r'''$.name''')
                                                  .toString(),
                                        ),
                                        Column(
                                          mainAxisSize: MainAxisSize.max,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              getJsonField(
                                                likedUsersItem,
                                                r'''$.name''',
                                              ).toString(),
                                              style: FlutterFlowTheme.of(
                                                      context)
                                                  .bodyMedium
                                                  .override(
                                                    font: GoogleFonts.manrope(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontStyle:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .bodyMedium
                                                              .fontStyle,
                                                    ),
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .extraBlack,
                                                    fontSize: 16.0,
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
                                            Text(
                                              getJsonField(
                                                likedUsersItem,
                                                r'''$.city''',
                                              ).toString(),
                                              style: FlutterFlowTheme.of(
                                                      context)
                                                  .bodyMedium
                                                  .override(
                                                    font: GoogleFonts.manrope(
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontStyle:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .bodyMedium
                                                              .fontStyle,
                                                    ),
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .greyL4,
                                                    fontSize: 12.0,
                                                    letterSpacing: 0.0,
                                                    fontWeight: FontWeight.w500,
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
                                    InkWell(
                                      splashColor: FlutterFlowTheme.of(context)
                                          .primary
                                          .withAlpha(0x14),
                                      focusColor: Colors.transparent,
                                      hoverColor: Colors.transparent,
                                      highlightColor: Colors.transparent,
                                      onTap: () async {
                                        await AddFollowCall.call(
                                          pFollowerid: currentUserUid,
                                          pFollowingid: getJsonField(
                                            likedUsersItem,
                                            r'''$.user_id''',
                                          ).toString(),
                                          pCommunityid:
                                              FFAppState().communityId,
                                          token: currentJwtToken,
                                        );
                                      },
                                      child: Container(
                                        width: 120.0,
                                        height: 30.0,
                                        decoration: BoxDecoration(),
                                        alignment:
                                            AlignmentDirectional(0.0, 0.0),
                                        child: Visibility(
                                          visible: (getJsonField(
                                                    likedUsersItem,
                                                    r'''$.user_id''',
                                                  ).toString() ==
                                                  currentUserUid) ==
                                              false,
                                          child:
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
                                                      likedUsersItem,
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
                                                  rowFollowsRowList =
                                                  snapshot.data!;

                                              final rowFollowsRow =
                                                  rowFollowsRowList.isNotEmpty
                                                      ? rowFollowsRowList.first
                                                      : null;

                                              return Row(
                                                mainAxisSize: MainAxisSize.max,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  if (rowFollowsRow?.id ==
                                                          null ||
                                                      rowFollowsRow?.id == '')
                                                    Row(
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
                                                                fontSize: 12.0,
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
                                                      ],
                                                    ),
                                                  if (rowFollowsRow?.id !=
                                                          null &&
                                                      rowFollowsRow?.id != '')
                                                    Row(
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
                                                                lineHeight: 1.4,
                                                              ),
                                                        ),
                                                      ].divide(
                                                          SizedBox(width: 6.0)),
                                                    ),
                                                ],
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          );
                        },
                      ),
                    ],
                  ),
                ].divide(SizedBox(height: 24.0)),
              ),
            ),
          if (!_model.showData)
            Expanded(
              child: Padding(
                padding: EdgeInsetsDirectional.fromSTEB(0.0, 30.0, 0.0, 250.0),
                child: wrapWithModel(
                  model: _model.shimmerLoaderFollowersModel,
                  updateCallback: () => safeSetState(() {}),
                  child: ShimmerLoaderFollowersWidget(),
                ),
              ),
            ),
          if ((_model.apiResultmbg?.bodyText ?? '') == '[]')
            Expanded(
              child: Container(
                width: double.infinity,
                height: 100.0,
                decoration: BoxDecoration(
                  color: FlutterFlowTheme.of(context).secondaryBackground,
                ),
                alignment: AlignmentDirectional(0.0, 0.0),
                child: Text(
                  'No likes to show',
                  textAlign: TextAlign.center,
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                        font: GoogleFonts.manrope(
                          fontWeight: FontWeight.w600,
                          fontStyle:
                              FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                        ),
                        color: FlutterFlowTheme.of(context).greyL3,
                        fontSize: 18.0,
                        letterSpacing: 0.0,
                        fontWeight: FontWeight.w600,
                        fontStyle:
                            FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                      ),
                ),
              ),
            ),
        ].addToStart(SizedBox(height: 8.0)).addToEnd(SizedBox(height: 24.0)),
      ),
    );
  }
}
