import '/auth/supabase_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/custom_code/actions/index.dart' as actions;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'comp_category_filter_model.dart';
export 'comp_category_filter_model.dart';

class CompCategoryFilterWidget extends StatefulWidget {
  const CompCategoryFilterWidget({
    super.key,
    required this.pageType,
    required this.searhText,
  });

  final String? pageType;
  final String? searhText;

  @override
  State<CompCategoryFilterWidget> createState() =>
      _CompCategoryFilterWidgetState();
}

class _CompCategoryFilterWidgetState extends State<CompCategoryFilterWidget> {
  late CompCategoryFilterModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => CompCategoryFilterModel());
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
      width: double.infinity,
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
          Expanded(
            child: Padding(
              padding: EdgeInsetsDirectional.fromSTEB(16.0, 16.0, 16.0, 0.0),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  InkWell(
                    splashColor:
                        FlutterFlowTheme.of(context).primary.withAlpha(0x14),
                    focusColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onTap: () async {
                      HapticFeedback.lightImpact();
                      FFAppState().SalesFilter = 'All categories';
                      safeSetState(() {});
                      if (widget!.pageType == 'sale') {
                        _model.customActionOutput =
                            await actions.getSaleHomePage(
                          FFDevEnvironmentValues().AnonKey,
                          currentJwtToken!,
                          currentUserUid,
                          FFAppState().SalesFilter,
                          FFAppState().SalesTypeFilter,
                          FFAppState().SalesKmFilter,
                          FFAppState().SalesSort,
                          FFAppState().communityId,
                        );
                        FFAppState().SalesHomePageData =
                            _model.customActionOutput!.toList().cast<dynamic>();
                        safeSetState(() {});
                      } else {
                        _model.allCategoriesFilter =
                            await GetAllSearchCall.call(
                          pSearchText: widget!.searhText,
                          pUserid: currentUserUid,
                          pCommunityid: FFAppState().communityId,
                          token: currentJwtToken,
                          pType: 'sale',
                          pCategory: FFAppState().SalesFilter,
                          pSaleType: FFAppState().SalesTypeFilter,
                          pSort: FFAppState().SalesSort,
                          pDistance: FFAppState().SalesKmFilter,
                        );

                        if ((_model.allCategoriesFilter?.succeeded ?? true)) {
                          FFAppState().SearchData =
                              (_model.allCategoriesFilter?.jsonBody ?? '');
                          safeSetState(() {});
                        }
                      }

                      Navigator.pop(context);

                      safeSetState(() {});
                    },
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: FlutterFlowTheme.of(context).secondaryBackground,
                      ),
                      child: Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(
                            0.0, 10.0, 0.0, 10.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Stack(
                              children: [
                                if (FFAppState().SalesFilter ==
                                    'All categories')
                                  Text(
                                    'All categories',
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
                                          color: FlutterFlowTheme.of(context)
                                              .extraBlack,
                                          letterSpacing: 0.0,
                                          fontWeight: FontWeight.w500,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .bodyMedium
                                                  .fontStyle,
                                          lineHeight: 1.3,
                                        ),
                                  ),
                                if (FFAppState().SalesFilter !=
                                    'All categories')
                                  Text(
                                    'All categories',
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
                                          color: FlutterFlowTheme.of(context)
                                              .greyD1,
                                          letterSpacing: 0.0,
                                          fontWeight: FontWeight.w500,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .bodyMedium
                                                  .fontStyle,
                                          lineHeight: 1.4,
                                        ),
                                  ),
                              ],
                            ),
                            if (FFAppState().SalesFilter == 'All categories')
                              Icon(
                                Icons.check,
                                color: FlutterFlowTheme.of(context).primary,
                                size: 24.0,
                              ),
                          ].divide(SizedBox(width: 16.0)),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: FutureBuilder<List<SaleCategoryRow>>(
                      future: SaleCategoryTable().queryRows(
                        queryFn: (q) => q.order('created_at'),
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
                        List<SaleCategoryRow> listViewSaleCategoryRowList =
                            snapshot.data!;

                        return ListView.builder(
                          padding: EdgeInsets.fromLTRB(
                            0,
                            0,
                            0,
                            24.0,
                          ),
                          shrinkWrap: true,
                          scrollDirection: Axis.vertical,
                          itemCount: listViewSaleCategoryRowList.length,
                          itemBuilder: (context, listViewIndex) {
                            final listViewSaleCategoryRow =
                                listViewSaleCategoryRowList[listViewIndex];
                            return InkWell(
                              splashColor: FlutterFlowTheme.of(context)
                                  .primary
                                  .withAlpha(0x14),
                              focusColor: Colors.transparent,
                              hoverColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              onTap: () async {
                                HapticFeedback.lightImpact();
                                FFAppState().SalesFilter =
                                    listViewSaleCategoryRow.name!;
                                safeSetState(() {});
                                if (widget!.pageType == 'sale') {
                                  _model.customActionOutput1 =
                                      await actions.getSaleHomePage(
                                    FFDevEnvironmentValues().AnonKey,
                                    currentJwtToken!,
                                    currentUserUid,
                                    FFAppState().SalesFilter,
                                    FFAppState().SalesTypeFilter,
                                    FFAppState().SalesKmFilter,
                                    FFAppState().SalesSort,
                                    FFAppState().communityId,
                                  );
                                  FFAppState().SalesHomePageData = _model
                                      .customActionOutput1!
                                      .toList()
                                      .cast<dynamic>();
                                  safeSetState(() {});
                                } else {
                                  _model.categoriesFilter =
                                      await GetAllSearchCall.call(
                                    pSearchText: widget!.searhText,
                                    pUserid: currentUserUid,
                                    pCommunityid: FFAppState().communityId,
                                    token: currentJwtToken,
                                    pType: 'sale',
                                    pCategory: FFAppState().SalesFilter,
                                    pSaleType: FFAppState().SalesTypeFilter,
                                    pSort: FFAppState().SalesSort,
                                    pDistance: FFAppState().SalesKmFilter,
                                  );

                                  if ((_model.categoriesFilter?.succeeded ??
                                      true)) {
                                    FFAppState().SearchData =
                                        (_model.categoriesFilter?.jsonBody ??
                                            '');
                                    safeSetState(() {});
                                  }
                                }

                                Navigator.pop(context);

                                safeSetState(() {});
                              },
                              child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: FlutterFlowTheme.of(context)
                                      .secondaryBackground,
                                ),
                                child: Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      0.0, 10.0, 0.0, 10.0),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Stack(
                                        children: [
                                          if (FFAppState().SalesFilter ==
                                              listViewSaleCategoryRow.name)
                                            Text(
                                              valueOrDefault<String>(
                                                listViewSaleCategoryRow.name,
                                                'name',
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
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .extraBlack,
                                                    letterSpacing: 0.0,
                                                    fontWeight: FontWeight.w500,
                                                    fontStyle:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .bodyMedium
                                                            .fontStyle,
                                                    lineHeight: 1.3,
                                                  ),
                                            ),
                                          if (FFAppState().SalesFilter !=
                                              listViewSaleCategoryRow.name)
                                            Text(
                                              valueOrDefault<String>(
                                                listViewSaleCategoryRow.name,
                                                'name',
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
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .greyD1,
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
                                      if (FFAppState().SalesFilter ==
                                          listViewSaleCategoryRow.name)
                                        Icon(
                                          Icons.check,
                                          color: FlutterFlowTheme.of(context)
                                              .primary,
                                          size: 24.0,
                                        ),
                                    ].divide(SizedBox(width: 16.0)),
                                  ),
                                ),
                              ),
                            )
                                .animate()
                                .fadeIn(
                                  duration: 260.ms,
                                  delay: (40 * (listViewIndex % 8)).ms,
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
                  ),
                ],
              ),
            ),
          ),
        ].addToStart(SizedBox(height: 8.0)).addToEnd(SizedBox(height: 24.0)),
      ),
    );
  }
}
