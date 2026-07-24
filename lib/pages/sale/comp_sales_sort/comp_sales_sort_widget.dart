import '/auth/supabase_auth/auth_util.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/custom_code/actions/index.dart' as actions;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'comp_sales_sort_model.dart';
export 'comp_sales_sort_model.dart';

class CompSalesSortWidget extends StatefulWidget {
  const CompSalesSortWidget({
    super.key,
    required this.pageType,
  });

  final String? pageType;

  @override
  State<CompSalesSortWidget> createState() => _CompSalesSortWidgetState();
}

class _CompSalesSortWidgetState extends State<CompSalesSortWidget> {
  late CompSalesSortModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => CompSalesSortModel());
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
            Padding(
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
                      FFAppState().SalesSort = 'Newest';
                      safeSetState(() {});
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
                      FFAppState().SalesHomePageData =
                          _model.customActionOutput1!.toList().cast<dynamic>();
                      safeSetState(() {});
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
                                if (FFAppState().SalesSort == 'Newest')
                                  Text(
                                    'Newest',
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
                                if (FFAppState().SalesSort != 'Newest')
                                  Text(
                                    'Newest',
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
                            if (FFAppState().SalesSort == 'Newest')
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
                  InkWell(
                    splashColor:
                        FlutterFlowTheme.of(context).primary.withAlpha(0x14),
                    focusColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onTap: () async {
                      HapticFeedback.lightImpact();
                      FFAppState().SalesSort = 'Closest';
                      safeSetState(() {});
                      _model.customActionOutput3 =
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
                          _model.customActionOutput3!.toList().cast<dynamic>();
                      safeSetState(() {});
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
                                if (FFAppState().SalesSort == 'Closest')
                                  Text(
                                    'Closest',
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
                                if (FFAppState().SalesSort != 'Closest')
                                  Text(
                                    'Closest',
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
                            if (FFAppState().SalesSort == 'Closest')
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
                ],
              ),
            ),
          ].addToStart(SizedBox(height: 8.0)).addToEnd(SizedBox(height: 24.0)),
        ),
      ),
    );
  }
}
