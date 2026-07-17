import '/auth/supabase_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/backend/supabase/supabase.dart';
import '/components/comp_no_data_found_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/pages/home/comp_loading/comp_loading_widget.dart';
import 'dart:ui';
import '/flutter_flow/custom_functions.dart' as functions;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'comp_joining_request_model.dart';
export 'comp_joining_request_model.dart';

class CompJoiningRequestWidget extends StatefulWidget {
  const CompJoiningRequestWidget({
    super.key,
    required this.groupId,
  });

  final String? groupId;

  @override
  State<CompJoiningRequestWidget> createState() =>
      _CompJoiningRequestWidgetState();
}

class _CompJoiningRequestWidgetState extends State<CompJoiningRequestWidget> {
  late CompJoiningRequestModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => CompJoiningRequestModel());
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                            'Joining Requests',
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
                FutureBuilder<List<GroupUserStatusRow>>(
                  future: GroupUserStatusTable().queryRows(
                    queryFn: (q) => q
                        .eqOrNull(
                          'group_id',
                          widget!.groupId,
                        )
                        .eqOrNull(
                          'is_requested',
                          true,
                        )
                        .eqOrNull(
                          'is_approved',
                          false,
                        ),
                  ),
                  builder: (context, snapshot) {
                    // Customize what your widget looks like when it's loading.
                    if (!snapshot.hasData) {
                      return CompLoadingWidget(
                        name: 'invite',
                      );
                    }
                    List<GroupUserStatusRow> listViewGroupUserStatusRowList =
                        snapshot.data!;

                    if (listViewGroupUserStatusRowList.isEmpty) {
                      return CompNoDataFoundWidget(
                        pageName: 'no',
                        text1: 'No joining requests yet ',
                        text2:
                            'When someone requests to join your group, their details will appear here.',
                      );
                    }

                    return ListView.builder(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      scrollDirection: Axis.vertical,
                      itemCount: listViewGroupUserStatusRowList.length,
                      itemBuilder: (context, listViewIndex) {
                        final listViewGroupUserStatusRow =
                            listViewGroupUserStatusRowList[listViewIndex];
                        return FutureBuilder<List<PublicUserProfileRow>>(
                          future: PublicUserProfileTable().querySingleRow(
                            queryFn: (q) => q.eqOrNull(
                              'id',
                              listViewGroupUserStatusRow.userId,
                            ),
                          ),
                          builder: (context, snapshot) {
                            // Customize what your widget looks like when it's loading.
                            if (!snapshot.hasData) {
                              return CompLoadingWidget(
                                name: 'singleInvite',
                              );
                            }
                            List<PublicUserProfileRow>
                                columnPublicUserProfileRowList = snapshot.data!;

                            // Return an empty Container when the item does not exist.
                            if (snapshot.data!.isEmpty) {
                              return Container();
                            }
                            final columnPublicUserProfileRow =
                                columnPublicUserProfileRowList.isNotEmpty
                                    ? columnPublicUserProfileRowList.first
                                    : null;

                            return Column(
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
                                            child: Image.network(
                                              columnPublicUserProfileRow!
                                                  .profilePicture!,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          Column(
                                            mainAxisSize: MainAxisSize.max,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                valueOrDefault<String>(
                                                  columnPublicUserProfileRow
                                                      ?.name,
                                                  'name',
                                                ),
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
                                                      color:
                                                          FlutterFlowTheme.of(
                                                                  context)
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
                                                valueOrDefault<String>(
                                                  columnPublicUserProfileRow
                                                      ?.city,
                                                  'city',
                                                ),
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
                                                      color:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .greyL4,
                                                      fontSize: 10.0,
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
                                      FFButtonWidget(
                                        onPressed: () async {
                                          await GroupUserStatusTable().update(
                                            data: {
                                              'is_approved': true,
                                              'is_member': true,
                                              'approved_by': currentUserUid,
                                              'joined_at':
                                                  supaSerialize<DateTime>(
                                                      functions
                                                          .getCurrentUtcTime()),
                                            },
                                            matchingRows: (rows) => rows
                                                .eqOrNull(
                                                  'group_id',
                                                  widget!.groupId,
                                                )
                                                .eqOrNull(
                                                  'user_id',
                                                  columnPublicUserProfileRow
                                                      ?.id,
                                                ),
                                          );
                                          await GroupMembersInviteTable()
                                              .update(
                                            data: {
                                              'is_member': true,
                                              'accepted_at':
                                                  supaSerialize<DateTime>(
                                                      functions
                                                          .getCurrentUtcTime()),
                                            },
                                            matchingRows: (rows) => rows
                                                .eqOrNull(
                                                  'group_id',
                                                  widget!.groupId,
                                                )
                                                .eqOrNull(
                                                  'invited_user',
                                                  columnPublicUserProfileRow
                                                      ?.id,
                                                ),
                                          );
                                          await GroupMembersTable().insert({
                                            'community_id':
                                                columnPublicUserProfileRow
                                                    ?.communityId,
                                            'user_id':
                                                columnPublicUserProfileRow?.id,
                                            'group_id': widget!.groupId,
                                            'is_approved': true,
                                            'approved_by': currentUserUid,
                                            'joined_at': supaSerialize<
                                                    DateTime>(
                                                functions.getCurrentUtcTime()),
                                          });
                                          _model.apiResultcky =
                                              await UpdateTotalGroupMembersCall
                                                  .call(
                                            token: currentJwtToken,
                                            anonKey: FFDevEnvironmentValues()
                                                .AnonKey,
                                            groupId: widget!.groupId,
                                          );

                                          safeSetState(() {});
                                        },
                                        text: 'Approve',
                                        options: FFButtonOptions(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  0.0, 0.0, 0.0, 0.0),
                                          iconPadding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  0.0, 0.0, 0.0, 0.0),
                                          color: Color(0x00264AFF),
                                          textStyle: FlutterFlowTheme.of(
                                                  context)
                                              .titleSmall
                                              .override(
                                                font: GoogleFonts.interTight(
                                                  fontWeight:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .titleSmall
                                                          .fontWeight,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .titleSmall
                                                          .fontStyle,
                                                ),
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .primaryD3,
                                                fontSize: 12.0,
                                                letterSpacing: 0.0,
                                                fontWeight:
                                                    FlutterFlowTheme.of(context)
                                                        .titleSmall
                                                        .fontWeight,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .titleSmall
                                                        .fontStyle,
                                              ),
                                          elevation: 0.0,
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: double.infinity,
                                  height: 1.0,
                                  decoration: BoxDecoration(
                                    color: FlutterFlowTheme.of(context).greayL1,
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
              ].divide(SizedBox(height: 24.0)),
            ),
          ),
        ].addToStart(SizedBox(height: 8.0)).addToEnd(SizedBox(height: 24.0)),
      ),
    );
  }
}
