import '/components/async_state_view.dart';
import '/components/app_icon_button.dart';
import '/components/app_network_image.dart';
import '/auth/supabase_auth/auth_util.dart';
import '/backend/supabase/supabase.dart';
import '/components/comp_no_data_found_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/pages/group/comp_unblock_user/comp_unblock_user_widget.dart';
import '/pages/home/comp_loading/comp_loading_widget.dart';
import 'dart:ui';
import '/custom_code/actions/index.dart' as actions;
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'blocked_users_model.dart';
export 'blocked_users_model.dart';

class BlockedUsersWidget extends StatefulWidget {
  const BlockedUsersWidget({super.key});

  static String routeName = 'BlockedUsers';
  static String routePath = 'blockedUsers';

  @override
  State<BlockedUsersWidget> createState() => _BlockedUsersWidgetState();
}

class _BlockedUsersWidgetState extends State<BlockedUsersWidget> {
  late BlockedUsersModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => BlockedUsersModel());

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      await actions.unsubscribe(
        'blocks',
      );
      await Future.delayed(
        Duration(
          milliseconds: 1000,
        ),
      );
      await actions.subscribe(
        'bocks',
        () async {
          safeSetState(() => _model.requestCompleter = null);
          await _model.waitForRequestCompleted();
        },
      );
    });
  }

  /// Re-runs the blocked-accounts query (used by the error state's Retry).
  Future<void> _reloadBlocks() async {
    safeSetState(() => _model.requestCompleter = null);
    await _model.waitForRequestCompleted();
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                FutureBuilder<List<BlocksRow>>(
                  future: BlocksTable().queryRows(
                    queryFn: (q) => q.eqOrNull(
                      'blocker_id',
                      currentUserUid,
                    ),
                  ),
                  builder: (context, snapshot) {
                    // Customize what your widget looks like when it's loading.
                    if (!snapshot.hasData) {
                      return Container(
                        height: 67.0,
                        child: CompLoadingWidget(
                          name: '',
                        ),
                      );
                    }
                    List<BlocksRow> containerBlocksRowList = snapshot.data!;

                    return Container(
                      decoration: BoxDecoration(
                        color: FlutterFlowTheme.of(context).white,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                10.0, 0.0, 20.0, 0.0),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                AppIconButton(
                                  icon: Icons.arrow_back,
                                  semanticLabel: 'Back',
                                  tooltip: 'Back',
                                  iconSize: 24.0,
                                  color:
                                      FlutterFlowTheme.of(context).extraBlack,
                                  onTap: () async {
                                    context.safePop();
                                  },
                                ),
                                Column(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Blocked Accounts',
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
                                            color: FlutterFlowTheme.of(context)
                                                .extraBlack,
                                            fontSize: 18.0,
                                            letterSpacing: 0.0,
                                            fontWeight: FontWeight.w600,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMedium
                                                    .fontStyle,
                                            lineHeight: 1.4,
                                          ),
                                    ),
                                    Text(
                                      '${containerBlocksRowList.length.toString()} people are blocked by you',
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
                                            color: FlutterFlowTheme.of(context)
                                                .greyL5,
                                            fontSize: 12.0,
                                            letterSpacing: 0.0,
                                            fontWeight: FontWeight.w600,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMedium
                                                    .fontStyle,
                                            lineHeight: 1.4,
                                          ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ]
                            .divide(SizedBox(height: 12.0))
                            .addToStart(SizedBox(height: 12.0))
                            .addToEnd(SizedBox(height: 12.0)),
                      ),
                    );
                  },
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(0.0, 4.0, 0.0, 0.0),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: FlutterFlowTheme.of(context).secondaryBackground,
                      ),
                      child: FutureBuilder<List<BlocksRow>>(
                        future: (_model.requestCompleter ??=
                                Completer<List<BlocksRow>>()
                                  ..complete(BlocksTable().queryRows(
                                    queryFn: (q) => q.eqOrNull(
                                      'blocker_id',
                                      currentUserUid,
                                    ),
                                  )))
                            .future,
                        builder: (context, snapshot) {
                          // Loading / error / empty / data all go through the
                          // one shared state wrapper (ui-review 2026-07-21 §2.7).
                          return AsyncStateView.fromSnapshot<List<BlocksRow>>(
                            snapshot: snapshot,
                            onRetry: _reloadBlocks,
                            emptyBuilder: (BuildContext context) =>
                                CompNoDataFoundWidget(
                              pageName: 'block',
                              text1: 'No blocked accounts',
                              text2: 'Any accounts you block will appear here.',
                            ).animate().fadeIn(duration: 400.ms).scale(
                                      begin: Offset(0.92, 0.92),
                                      end: Offset(1, 1),
                                      curve: Curves.easeOutBack,
                                    ),
                            builder: (BuildContext context,
                                List<BlocksRow> listViewBlocksRowList) {
                              return ListView.builder(
                                padding: EdgeInsets.zero,
                                shrinkWrap: true,
                                scrollDirection: Axis.vertical,
                                itemCount: listViewBlocksRowList.length,
                                itemBuilder: (context, listViewIndex) {
                                  final listViewBlocksRow =
                                      listViewBlocksRowList[listViewIndex];
                                  return FutureBuilder<
                                      List<PublicUserProfileRow>>(
                                    future:
                                        PublicUserProfileTable().querySingleRow(
                                      queryFn: (q) => q.eqOrNull(
                                        'id',
                                        listViewBlocksRow.blockedId,
                                      ),
                                    ),
                                    builder: (context, snapshot) {
                                      // Customize what your widget looks like when it's loading.
                                      if (!snapshot.hasData) {
                                        return CompLoadingWidget(
                                          name: 'profile',
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
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          Padding(
                                            padding:
                                                EdgeInsetsDirectional.fromSTEB(
                                                    20.0, 12.0, 20.0, 12.0),
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
                                                    Container(
                                                      width: 32.0,
                                                      height: 32.0,
                                                      clipBehavior:
                                                          Clip.antiAlias,
                                                      decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                      ),
                                                      child: AppNetworkImage(
                                                        url: columnPublicUserProfileRow!
                                                            .profilePicture!,
                                                        width: 32.0,
                                                        height: 32.0,
                                                        fit: BoxFit.cover,
                                                        fallbackIcon: Icons
                                                            .person_rounded,
                                                        semanticLabel:
                                                            'Blocked neighbour profile photo',
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
                                                          valueOrDefault<
                                                              String>(
                                                            columnPublicUserProfileRow
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
                                                                fontSize: 16.0,
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
                                                        Text(
                                                          valueOrDefault<
                                                              String>(
                                                            columnPublicUserProfileRow
                                                                ?.city,
                                                            'city',
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
                                                      ],
                                                    ),
                                                  ].divide(
                                                      SizedBox(width: 8.0)),
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
                                                    HapticFeedback
                                                        .lightImpact();
                                                    await showModalBottomSheet(
                                                      isScrollControlled: true,
                                                      backgroundColor:
                                                          Colors.transparent,
                                                      enableDrag: false,
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
                                                                CompUnblockUserWidget(
                                                              unBlockUserId:
                                                                  listViewBlocksRow
                                                                      .blockedId,
                                                              unBlockUserName:
                                                                  columnPublicUserProfileRow!
                                                                      .name!,
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    ).then((value) =>
                                                        safeSetState(() {}));
                                                  },
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    children: [
                                                      Icon(
                                                        Icons.check,
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .greyL4,
                                                        size: 14.0,
                                                      ),
                                                      Text(
                                                        'Unblock',
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
                                                              color: FlutterFlowTheme
                                                                      .of(context)
                                                                  .greyL4,
                                                              fontSize: 12.0,
                                                              letterSpacing:
                                                                  0.0,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              fontStyle:
                                                                  FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMedium
                                                                      .fontStyle,
                                                              lineHeight: 1.4,
                                                            ),
                                                      ),
                                                    ].divide(
                                                        SizedBox(width: 6.0)),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            width: double.infinity,
                                            height: 1.0,
                                            decoration: BoxDecoration(
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .greayL1,
                                            ),
                                          ),
                                        ],
                                      )
                                          .animate()
                                          .fadeIn(
                                            duration: 260.ms,
                                            delay:
                                                (40 * (listViewIndex % 8)).ms,
                                          )
                                          .slideY(
                                            begin: 0.06,
                                            end: 0,
                                            curve: Curves.easeOutCubic,
                                          );
                                    },
                                  );
                                },
                              );
                            },
                          );
                        },
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
