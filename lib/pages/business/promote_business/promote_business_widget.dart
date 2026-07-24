import '/backend/supabase/supabase.dart';
import '/components/async_state_view.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'promote_business_model.dart';
export 'promote_business_model.dart';

class PromoteBusinessWidget extends StatefulWidget {
  const PromoteBusinessWidget({
    super.key,
    required this.businessId,
    required this.pagetype,
  });

  final String? businessId;
  final String? pagetype;

  static String routeName = 'PromoteBusiness';
  static String routePath = 'promoteBusiness';

  @override
  State<PromoteBusinessWidget> createState() => _PromoteBusinessWidgetState();
}

class _PromoteBusinessWidgetState extends State<PromoteBusinessWidget> {
  late PromoteBusinessModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PromoteBusinessModel());

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      _model.plans = await BusinessPromotePlansTable().queryRows(
        queryFn: (q) => q.order('price', ascending: true),
      );
      _model.plan =
          '${_model.plans?.firstOrNull?.currency}${_model.plans?.firstOrNull?.price?.toString()}';
      _model.planid = _model.plans?.firstOrNull?.id;
      safeSetState(() {});
    });
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
          bottom: true,
          child: Container(
            decoration: BoxDecoration(
              color: FlutterFlowTheme.of(context).pageBack,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Container(
                  width: double.infinity,
                  height: 56.0,
                  decoration: BoxDecoration(
                    color: FlutterFlowTheme.of(context).secondaryBackground,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      FlutterFlowIconButton(
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
                      Text(
                        'Promote Business',
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              font: GoogleFonts.manrope(
                                fontWeight: FontWeight.w600,
                                fontStyle: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .fontStyle,
                              ),
                              color: FlutterFlowTheme.of(context).extraBlack,
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
                Expanded(
                  child: Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(0.0, 4.0, 0.0, 0.0),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: FlutterFlowTheme.of(context).secondaryBackground,
                      ),
                      child: Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(
                            20.0, 0.0, 20.0, 0.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Text(
                              'Reach more local customers by featuring your business on Flock. Choose a plan that suits you',
                              style: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                    font: GoogleFonts.manrope(
                                      fontWeight: FontWeight.w600,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontStyle,
                                    ),
                                    color: FlutterFlowTheme.of(context).greyD1,
                                    fontSize: 16.0,
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.w600,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontStyle,
                                    lineHeight: 1.4,
                                  ),
                            ),
                            FutureBuilder<List<BusinessPromotePlansRow>>(
                              future: BusinessPromotePlansTable().queryRows(
                                queryFn: (q) =>
                                    q.order('price', ascending: true),
                              ),
                              builder: (context, snapshot) {
                                // One shared treatment for loading (shimmer),
                                // failure (retry) and "no plans" instead of a
                                // bare spinner and a blank list.
                                return AsyncStateView.fromSnapshot<
                                    List<BusinessPromotePlansRow>>(
                                  snapshot: snapshot,
                                  skeletonItemCount: 3,
                                  skeletonHasAvatar: false,
                                  onRetry: () => safeSetState(() {}),
                                  emptyIcon: Icons.campaign_outlined,
                                  emptyTitle: 'No promotions available',
                                  emptyBody:
                                      'There are no promotion plans on offer right now. Please check back soon.',
                                  builder: (context,
                                      listViewBusinessPromotePlansRowList) {
                                    return ListView.separated(
                                      padding: EdgeInsets.zero,
                                      primary: false,
                                      shrinkWrap: true,
                                      scrollDirection: Axis.vertical,
                                      itemCount:
                                          listViewBusinessPromotePlansRowList
                                              .length,
                                      separatorBuilder: (_, __) =>
                                          SizedBox(height: 12.0),
                                      itemBuilder: (context, listViewIndex) {
                                        final listViewBusinessPromotePlansRow =
                                            listViewBusinessPromotePlansRowList[
                                                listViewIndex];
                                        return InkWell(
                                          splashColor:
                                              FlutterFlowTheme.of(context)
                                                  .primary
                                                  .withAlpha(0x14),
                                          focusColor: Colors.transparent,
                                          hoverColor: Colors.transparent,
                                          highlightColor: Colors.transparent,
                                          onTap: () async {
                                            _model.radiobtn = listViewIndex;
                                            _model.plan =
                                                '${listViewBusinessPromotePlansRow.currency}${listViewBusinessPromotePlansRow.price.toString()}';
                                            _model.planid =
                                                listViewBusinessPromotePlansRow
                                                    .id;
                                            safeSetState(() {});
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(),
                                            child: Padding(
                                              padding: EdgeInsetsDirectional
                                                  .fromSTEB(0.0, 4.0, 0.0, 4.0),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.max,
                                                children: [
                                                  Container(
                                                    width: 20.0,
                                                    height: 20.0,
                                                    decoration: BoxDecoration(
                                                      color: FlutterFlowTheme
                                                              .of(context)
                                                          .secondaryBackground,
                                                      shape: BoxShape.circle,
                                                      border: Border.all(
                                                        color: _model
                                                                    .radiobtn !=
                                                                listViewIndex
                                                            ? FlutterFlowTheme
                                                                    .of(context)
                                                                .greyL4
                                                            : FlutterFlowTheme
                                                                    .of(context)
                                                                .primary,
                                                      ),
                                                    ),
                                                    alignment:
                                                        AlignmentDirectional(
                                                            0.0, 0.0),
                                                    child: Visibility(
                                                      visible:
                                                          _model.radiobtn ==
                                                              listViewIndex,
                                                      child: Container(
                                                        width: 12.0,
                                                        height: 12.0,
                                                        decoration:
                                                            BoxDecoration(
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .primary,
                                                          shape:
                                                              BoxShape.circle,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Text(
                                                    '${listViewBusinessPromotePlansRow.daysCount.toString()}-Day Promotion – ${listViewBusinessPromotePlansRow.currency}${listViewBusinessPromotePlansRow.price.toString()}',
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
                                                              .greyD1,
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
                                                ].divide(SizedBox(width: 8.0)),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                );
                              },
                            ),
                            Expanded(
                              child: Align(
                                alignment: AlignmentDirectional(0.0, 1.0),
                                child: Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      0.0, 0.0, 0.0, 15.0),
                                  child: FFButtonWidget(
                                    onPressed: () async {
                                      HapticFeedback.lightImpact();

                                      context.pushNamed(
                                        UploadReceiptWidget.routeName,
                                        queryParameters: {
                                          'amount': serializeParam(
                                            _model.plan,
                                            ParamType.String,
                                          ),
                                          'planid': serializeParam(
                                            _model.planid,
                                            ParamType.int,
                                          ),
                                          'businessId': serializeParam(
                                            widget!.businessId,
                                            ParamType.String,
                                          ),
                                          'type': serializeParam(
                                            widget!.pagetype,
                                            ParamType.String,
                                          ),
                                        }.withoutNulls,
                                      );
                                    },
                                    text: 'Continue',
                                    options: FFButtonOptions(
                                      width: double.infinity,
                                      height: 40.0,
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          16.0, 12.0, 16.0, 12.0),
                                      iconPadding:
                                          EdgeInsetsDirectional.fromSTEB(
                                              0.0, 0.0, 0.0, 0.0),
                                      color:
                                          FlutterFlowTheme.of(context).primary,
                                      textStyle: FlutterFlowTheme.of(context)
                                          .titleSmall
                                          .override(
                                            font: GoogleFonts.manrope(
                                              fontWeight:
                                                  FlutterFlowTheme.of(context)
                                                      .titleSmall
                                                      .fontWeight,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .titleSmall
                                                      .fontStyle,
                                            ),
                                            color: Colors.white,
                                            letterSpacing: 0.0,
                                            fontWeight:
                                                FlutterFlowTheme.of(context)
                                                    .titleSmall
                                                    .fontWeight,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .titleSmall
                                                    .fontStyle,
                                            lineHeight: 1.4,
                                          ),
                                      elevation: 0.0,
                                      borderRadius: BorderRadius.circular(24.0),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ]
                              .divide(SizedBox(height: 12.0))
                              .addToStart(SizedBox(height: 12.0)),
                        ),
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
