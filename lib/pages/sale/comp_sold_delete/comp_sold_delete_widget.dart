import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/pages/sale/comp_sale_delete/comp_sale_delete_widget.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'comp_sold_delete_model.dart';
export 'comp_sold_delete_model.dart';

class CompSoldDeleteWidget extends StatefulWidget {
  const CompSoldDeleteWidget({
    super.key,
    required this.pageType,
    required this.saleId,
  });

  final String? pageType;
  final String? saleId;

  @override
  State<CompSoldDeleteWidget> createState() => _CompSoldDeleteWidgetState();
}

class _CompSoldDeleteWidgetState extends State<CompSoldDeleteWidget> {
  late CompSoldDeleteModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => CompSoldDeleteModel());
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: EdgeInsetsDirectional.fromSTEB(20.0, 0.0, 20.0, 0.0),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: FlutterFlowTheme.of(context).secondaryBackground,
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Padding(
              padding: EdgeInsetsDirectional.fromSTEB(20.0, 20.0, 20.0, 20.0),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Align(
                    alignment: AlignmentDirectional(-1.0, -1.0),
                    child: Text(
                      () {
                        if (widget!.pageType == 'remove') {
                          return 'Remove product?';
                        } else if (widget!.pageType == 'sell') {
                          return 'Mark it for sale?';
                        } else {
                          return 'Mark it as Sold?';
                        }
                      }(),
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            font: GoogleFonts.manrope(
                              fontWeight: FontWeight.bold,
                              fontStyle: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .fontStyle,
                            ),
                            color: FlutterFlowTheme.of(context).extraBlack,
                            fontSize: 18.0,
                            letterSpacing: 0.0,
                            fontWeight: FontWeight.bold,
                            fontStyle: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .fontStyle,
                            lineHeight: 1.4,
                          ),
                    ),
                  ),
                  Padding(
                    padding:
                        EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 20.0, 0.0),
                    child: Text(
                      () {
                        if (widget!.pageType == 'remove') {
                          return 'Are you sure you want to remove this product from sales?';
                        } else if (widget!.pageType == 'remove') {
                          return 'Are you sure you want to mark this product as sale?';
                        } else {
                          return 'Are you sure you want to mark this product as sold?';
                        }
                      }(),
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            font: GoogleFonts.manrope(
                              fontWeight: FontWeight.w500,
                              fontStyle: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .fontStyle,
                            ),
                            color: FlutterFlowTheme.of(context).primaryText,
                            letterSpacing: 0.0,
                            fontWeight: FontWeight.w500,
                            fontStyle: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .fontStyle,
                            lineHeight: 1.3,
                          ),
                    ),
                  ),
                  Padding(
                    padding:
                        EdgeInsetsDirectional.fromSTEB(0.0, 10.0, 0.0, 0.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        InkWell(
                          splashColor: FlutterFlowTheme.of(context)
                              .primary
                              .withAlpha(0x14),
                          focusColor: Colors.transparent,
                          hoverColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          onTap: () async {
                            Navigator.pop(context);
                          },
                          child: Text(
                            widget!.pageType == 'remove' ? 'Cancel' : 'no',
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
                        ),
                        InkWell(
                          splashColor: FlutterFlowTheme.of(context)
                              .primary
                              .withAlpha(0x14),
                          focusColor: Colors.transparent,
                          hoverColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          onTap: () async {
                            if (widget!.pageType == 'remove') {
                              await SaleTable().update(
                                data: {
                                  'isdeleted': true,
                                },
                                matchingRows: (rows) => rows
                                    .eqOrNull(
                                      'id',
                                      widget!.saleId,
                                    )
                                    .eqOrNull(
                                      'community_id',
                                      FFAppState().communityId,
                                    ),
                              );
                              Navigator.pop(context);
                              await showModalBottomSheet(
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                isDismissible: false,
                                enableDrag: false,
                                context: context,
                                builder: (context) {
                                  return Padding(
                                    padding: MediaQuery.viewInsetsOf(context),
                                    child: CompSaleDeleteWidget(
                                      pageType: 'remove',
                                      saleid: widget!.saleId!,
                                    ),
                                  );
                                },
                              ).then((value) => safeSetState(() {}));
                            } else {
                              if (widget!.pageType == 'sold') {
                                await SaleTable().update(
                                  data: {
                                    'e_sale_type': 'sold',
                                  },
                                  matchingRows: (rows) => rows
                                      .eqOrNull(
                                        'id',
                                        widget!.saleId,
                                      )
                                      .eqOrNull(
                                        'community_id',
                                        FFAppState().communityId,
                                      ),
                                );
                                Navigator.pop(context);
                                await showModalBottomSheet(
                                  isScrollControlled: true,
                                  backgroundColor: Colors.transparent,
                                  isDismissible: false,
                                  enableDrag: false,
                                  context: context,
                                  builder: (context) {
                                    return Padding(
                                      padding: MediaQuery.viewInsetsOf(context),
                                      child: CompSaleDeleteWidget(
                                        pageType: 'sold',
                                        saleid: widget!.saleId!,
                                      ),
                                    );
                                  },
                                ).then((value) => safeSetState(() {}));
                              } else {
                                await SaleTable().update(
                                  data: {
                                    'e_sale_type': 'selling',
                                  },
                                  matchingRows: (rows) => rows
                                      .eqOrNull(
                                        'id',
                                        widget!.saleId,
                                      )
                                      .eqOrNull(
                                        'community_id',
                                        FFAppState().communityId,
                                      ),
                                );
                                Navigator.pop(context);
                                await showModalBottomSheet(
                                  isScrollControlled: true,
                                  backgroundColor: Colors.transparent,
                                  isDismissible: false,
                                  enableDrag: false,
                                  context: context,
                                  builder: (context) {
                                    return Padding(
                                      padding: MediaQuery.viewInsetsOf(context),
                                      child: CompSaleDeleteWidget(
                                        pageType: 'sell',
                                        saleid: widget!.saleId!,
                                      ),
                                    );
                                  },
                                ).then((value) => safeSetState(() {}));
                              }
                            }
                          },
                          child: Text(
                            widget!.pageType == 'remove' ? 'Remove' : 'Yes',
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
                        ),
                      ].divide(SizedBox(width: 15.0)),
                    ),
                  ),
                ].divide(SizedBox(height: 10.0)),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
