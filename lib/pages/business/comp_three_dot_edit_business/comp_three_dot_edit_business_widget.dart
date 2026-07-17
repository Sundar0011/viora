import '/auth/supabase_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/pages/business/comp_delete_business/comp_delete_business_widget.dart';
import '/pages/business/comp_mismatch/comp_mismatch_widget.dart';
import '/pages/business/comp_promotion_ended/comp_promotion_ended_widget.dart';
import '/pages/business/comp_promotion_is_live/comp_promotion_is_live_widget.dart';
import '/pages/business/comp_promotion_rejected/comp_promotion_rejected_widget.dart';
import '/pages/business/comp_under_review/comp_under_review_widget.dart';
import 'dart:ui';
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'comp_three_dot_edit_business_model.dart';
export 'comp_three_dot_edit_business_model.dart';

class CompThreeDotEditBusinessWidget extends StatefulWidget {
  const CompThreeDotEditBusinessWidget({
    super.key,
    required this.businessId,
  });

  final String? businessId;

  @override
  State<CompThreeDotEditBusinessWidget> createState() =>
      _CompThreeDotEditBusinessWidgetState();
}

class _CompThreeDotEditBusinessWidgetState
    extends State<CompThreeDotEditBusinessWidget> {
  late CompThreeDotEditBusinessModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => CompThreeDotEditBusinessModel());

    // On component load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      _model.apiResulteyq = await GetPromotionplanCall.call(
        pBusinessid: widget!.businessId,
        token: currentJwtToken,
      );
    });
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.0),
          topRight: Radius.circular(24.0),
        ),
      ),
      child: SingleChildScrollView(
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
            Align(
              alignment: AlignmentDirectional(0.0, 1.0),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  InkWell(
                    splashColor: Colors.transparent,
                    focusColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onTap: () async {
                      context.pushNamed(
                        CreatePageWidget.routeName,
                        queryParameters: {
                          'pageType': serializeParam(
                            'edit',
                            ParamType.String,
                          ),
                          'businessId': serializeParam(
                            widget!.businessId,
                            ParamType.String,
                          ),
                        }.withoutNulls,
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(),
                      child: Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(
                            16.0, 7.0, 16.0, 7.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(0.0),
                              child: Image.asset(
                                'assets/images/border_color.webp',
                                width: 20.0,
                                height: 20.0,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Text(
                              'Edit this page',
                              style: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                    font: GoogleFonts.manrope(
                                      fontWeight: FontWeight.w500,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontStyle,
                                    ),
                                    color: FlutterFlowTheme.of(context).greyD1,
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.w500,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontStyle,
                                    lineHeight: 1.4,
                                  ),
                            ),
                          ].divide(SizedBox(width: 8.0)),
                        ),
                      ),
                    ),
                  ),
                  InkWell(
                    splashColor: Colors.transparent,
                    focusColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onTap: () async {
                      if (((String var1) {
                            return var1 == "false";
                          }(getJsonField(
                            (_model.apiResulteyq?.jsonBody ?? ''),
                            r'''$.plan''',
                          ).toString())) ==
                          true) {
                        context.pushNamed(
                          PromoteBusinessWidget.routeName,
                          queryParameters: {
                            'businessId': serializeParam(
                              widget!.businessId,
                              ParamType.String,
                            ),
                            'pagetype': serializeParam(
                              'new',
                              ParamType.String,
                            ),
                          }.withoutNulls,
                        );
                      } else {
                        if (((String var1) {
                              return var1 == "under review";
                            }(getJsonField(
                              (_model.apiResulteyq?.jsonBody ?? ''),
                              r'''$.plan''',
                            ).toString())) ==
                            true) {
                          await showModalBottomSheet(
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            context: context,
                            builder: (context) {
                              return Padding(
                                padding: MediaQuery.viewInsetsOf(context),
                                child: CompUnderReviewWidget(
                                  type: 'home',
                                ),
                              );
                            },
                          ).then((value) => safeSetState(() {}));
                        } else {
                          if (((String var1) {
                                return var1 == "mismatch";
                              }(getJsonField(
                                (_model.apiResulteyq?.jsonBody ?? ''),
                                r'''$.plan''',
                              ).toString())) ==
                              true) {
                            await showModalBottomSheet(
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              context: context,
                              builder: (context) {
                                return Padding(
                                  padding: MediaQuery.viewInsetsOf(context),
                                  child: CompMismatchWidget(
                                    businessId: widget!.businessId!,
                                  ),
                                );
                              },
                            ).then((value) => safeSetState(() {}));
                          } else {
                            if (((String var1) {
                                  return var1 == "ended";
                                }(getJsonField(
                                  (_model.apiResulteyq?.jsonBody ?? ''),
                                  r'''$.plan''',
                                ).toString())) ==
                                true) {
                              await showModalBottomSheet(
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                context: context,
                                builder: (context) {
                                  return Padding(
                                    padding: MediaQuery.viewInsetsOf(context),
                                    child: CompPromotionEndedWidget(
                                      type: 'renew',
                                      businessId: widget!.businessId!,
                                    ),
                                  );
                                },
                              ).then((value) => safeSetState(() {}));
                            } else {
                              if (((String var1) {
                                    return var1 == "live";
                                  }(getJsonField(
                                    (_model.apiResulteyq?.jsonBody ?? ''),
                                    r'''$.plan''',
                                  ).toString())) ==
                                  true) {
                                await showModalBottomSheet(
                                  isScrollControlled: true,
                                  backgroundColor: Colors.transparent,
                                  context: context,
                                  builder: (context) {
                                    return Padding(
                                      padding: MediaQuery.viewInsetsOf(context),
                                      child: CompPromotionIsLiveWidget(
                                        type: 'review',
                                        businessId: widget!.businessId!,
                                        planEndDate: functions
                                            .returnPlanEndDate(getJsonField(
                                          (_model.apiResulteyq?.jsonBody ?? ''),
                                          r'''$.plan_end_date''',
                                        ).toString()),
                                      ),
                                    );
                                  },
                                ).then((value) => safeSetState(() {}));
                              } else {
                                if (((String var1) {
                                      return var1 == "rejected";
                                    }(getJsonField(
                                      (_model.apiResulteyq?.jsonBody ?? ''),
                                      r'''$.plan''',
                                    ).toString())) ==
                                    true) {
                                  await showModalBottomSheet(
                                    isScrollControlled: true,
                                    backgroundColor: Colors.transparent,
                                    context: context,
                                    builder: (context) {
                                      return Padding(
                                        padding:
                                            MediaQuery.viewInsetsOf(context),
                                        child: CompPromotionRejectedWidget(
                                          type: 'renew',
                                          businessId: widget!.businessId!,
                                        ),
                                      );
                                    },
                                  ).then((value) => safeSetState(() {}));
                                }
                              }
                            }
                          }
                        }
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(),
                      child: Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(
                            16.0, 7.0, 16.0, 7.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(0.0),
                              child: Image.asset(
                                'assets/images/campaign.webp',
                                width: 20.0,
                                height: 20.0,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Text(
                              'Promote business',
                              style: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                    font: GoogleFonts.manrope(
                                      fontWeight: FontWeight.w500,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontStyle,
                                    ),
                                    color: FlutterFlowTheme.of(context).greyD1,
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.w500,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontStyle,
                                    lineHeight: 1.4,
                                  ),
                            ),
                          ].divide(SizedBox(width: 8.0)),
                        ),
                      ),
                    ),
                  ),
                  InkWell(
                    splashColor: Colors.transparent,
                    focusColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onTap: () async {
                      await showModalBottomSheet(
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        enableDrag: false,
                        context: context,
                        builder: (context) {
                          return Padding(
                            padding: MediaQuery.viewInsetsOf(context),
                            child: CompDeleteBusinessWidget(
                              businessId: widget!.businessId!,
                            ),
                          );
                        },
                      ).then((value) => safeSetState(() {}));
                    },
                    child: Container(
                      decoration: BoxDecoration(),
                      child: Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(
                            16.0, 7.0, 16.0, 7.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(0.0),
                              child: Image.asset(
                                'assets/images/delete_(1).webp',
                                width: 20.0,
                                height: 20.0,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Text(
                              'Delete this page',
                              style: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                    font: GoogleFonts.manrope(
                                      fontWeight: FontWeight.w500,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontStyle,
                                    ),
                                    color: FlutterFlowTheme.of(context).greyD1,
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.w500,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontStyle,
                                    lineHeight: 1.4,
                                  ),
                            ),
                          ].divide(SizedBox(width: 8.0)),
                        ),
                      ),
                    ),
                  ),
                ].addToStart(SizedBox(height: 16.0)),
              ),
            ),
          ].addToStart(SizedBox(height: 8.0)).addToEnd(SizedBox(height: 24.0)),
        ),
      ),
    );
  }
}
