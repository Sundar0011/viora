import '/components/app_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'comp_promotion_ended_model.dart';
export 'comp_promotion_ended_model.dart';

class CompPromotionEndedWidget extends StatefulWidget {
  const CompPromotionEndedWidget({
    super.key,
    required this.type,
    required this.businessId,
  });

  final String? type;
  final String? businessId;

  @override
  State<CompPromotionEndedWidget> createState() =>
      _CompPromotionEndedWidgetState();
}

class _CompPromotionEndedWidgetState extends State<CompPromotionEndedWidget> {
  late CompPromotionEndedModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => CompPromotionEndedModel());
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
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      AppIconButton(
                        icon: Icons.arrow_back,
                        iconSize: 24.0,
                        color: FlutterFlowTheme.of(context).primaryText,
                        semanticLabel: 'Go back',
                        onTap: () {
                          if (widget!.type != 'home') {
                            context.goNamed(MyPagesWidget.routeName);
                          }
                        },
                      ),
                      Text(
                        'Promotion Ended',
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
                  Text(
                    'Your promotion has ended. You can renew or create a new promotion anytime.',
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          font: GoogleFonts.manrope(
                            fontWeight: FontWeight.w600,
                            fontStyle: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .fontStyle,
                          ),
                          color: FlutterFlowTheme.of(context).greyL5,
                          fontSize: 16.0,
                          letterSpacing: 0.0,
                          fontWeight: FontWeight.w600,
                          fontStyle:
                              FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                          lineHeight: 1.4,
                        ),
                  ),
                  FFButtonWidget(
                    onPressed: () async {
                      context.pushNamed(
                        PromoteBusinessWidget.routeName,
                        queryParameters: {
                          'businessId': serializeParam(
                            widget!.businessId,
                            ParamType.String,
                          ),
                          'pagetype': serializeParam(
                            widget!.type,
                            ParamType.String,
                          ),
                        }.withoutNulls,
                      );
                    },
                    text: 'Renew Now',
                    options: FFButtonOptions(
                      width: double.infinity,
                      height: 40.0,
                      padding:
                          EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                      iconPadding:
                          EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                      color: FlutterFlowTheme.of(context).primary,
                      textStyle:
                          FlutterFlowTheme.of(context).titleSmall.override(
                                font: GoogleFonts.manrope(
                                  fontWeight: FlutterFlowTheme.of(context)
                                      .titleSmall
                                      .fontWeight,
                                  fontStyle: FlutterFlowTheme.of(context)
                                      .titleSmall
                                      .fontStyle,
                                ),
                                color: Colors.white,
                                letterSpacing: 0.0,
                                fontWeight: FlutterFlowTheme.of(context)
                                    .titleSmall
                                    .fontWeight,
                                fontStyle: FlutterFlowTheme.of(context)
                                    .titleSmall
                                    .fontStyle,
                                lineHeight: 1.4,
                              ),
                      elevation: 0.0,
                      borderRadius: BorderRadius.circular(24.0),
                    ),
                  ),
                ]
                    .divide(SizedBox(height: 24.0))
                    .addToStart(SizedBox(height: 16.0)),
              ),
            ),
          ].addToStart(SizedBox(height: 8.0)).addToEnd(SizedBox(height: 24.0)),
        ),
      ),
    );
  }
}
