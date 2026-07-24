import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'comp_home_text_model.dart';
export 'comp_home_text_model.dart';

class CompHomeTextWidget extends StatefulWidget {
  const CompHomeTextWidget({
    super.key,
    String? text,
  }) : this.text = text ?? '';

  final String text;

  @override
  State<CompHomeTextWidget> createState() => _CompHomeTextWidgetState();
}

class _CompHomeTextWidgetState extends State<CompHomeTextWidget> {
  late CompHomeTextModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => CompHomeTextModel());
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(20.0, 0.0, 20.0, 0.0),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Stack(
            alignment: AlignmentDirectional(1.0, 1.0),
            children: [
              if (!_model.showText)
                Text(
                  widget!.text.maybeHandleOverflow(
                    maxChars: 90,
                    replacement: '…',
                  ),
                  textAlign: TextAlign.start,
                  maxLines: 2,
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                        font: GoogleFonts.manrope(
                          fontWeight: FontWeight.w500,
                          fontStyle:
                              FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                        ),
                        color: FlutterFlowTheme.of(context).extraBlack,
                        letterSpacing: 0.0,
                        fontWeight: FontWeight.w500,
                        fontStyle:
                            FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                        lineHeight: 1.3,
                      ),
                ),
              if (_model.showText)
                Text(
                  widget!.text,
                  textAlign: TextAlign.start,
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                        font: GoogleFonts.manrope(
                          fontWeight: FontWeight.w500,
                          fontStyle:
                              FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                        ),
                        color: FlutterFlowTheme.of(context).extraBlack,
                        letterSpacing: 0.0,
                        fontWeight: FontWeight.w500,
                        fontStyle:
                            FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                        lineHeight: 1.3,
                      ),
                ),
              if (!_model.showText)
                InkWell(
                  splashColor:
                      FlutterFlowTheme.of(context).primary.withAlpha(0x14),
                  focusColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: () async {
                    _model.showText = true;
                    safeSetState(() {});
                  },
                  child: Text(
                    'Read More',
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          font: GoogleFonts.manrope(
                            fontWeight: FontWeight.w500,
                            fontStyle: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .fontStyle,
                          ),
                          color: FlutterFlowTheme.of(context).greyL4,
                          fontSize: 12.0,
                          letterSpacing: 0.0,
                          fontWeight: FontWeight.w500,
                          fontStyle:
                              FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                          lineHeight: 1.4,
                        ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
