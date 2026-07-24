import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'comp_no_data_found_model.dart';
export 'comp_no_data_found_model.dart';

class CompNoDataFoundWidget extends StatefulWidget {
  const CompNoDataFoundWidget({
    super.key,
    String? pageName,
    required this.text1,
    required this.text2,
  }) : this.pageName = pageName ?? '';

  final String pageName;
  final String? text1;
  final String? text2;

  @override
  State<CompNoDataFoundWidget> createState() => _CompNoDataFoundWidgetState();
}

class _CompNoDataFoundWidgetState extends State<CompNoDataFoundWidget> {
  late CompNoDataFoundModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => CompNoDataFoundModel());
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
      decoration: BoxDecoration(),
      child: Padding(
        padding: EdgeInsetsDirectional.fromSTEB(20.0, 0.0, 20.0, 20.0),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              children: [
                if (widget!.pageName == 'no')
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.asset(
                      'assets/images/empty_feed.png',
                      width: 160.0,
                      height: 160.0,
                      fit: BoxFit.cover,
                    ),
                  ),
                if (widget!.pageName == 'events')
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.asset(
                      'assets/images/empty_events.png',
                      width: 160.0,
                      height: 160.0,
                      fit: BoxFit.cover,
                    ),
                  ),
                if (widget!.pageName == 'group')
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.asset(
                      'assets/images/Line.webp',
                      width: 160.0,
                      height: 160.0,
                      fit: BoxFit.cover,
                    ),
                  ),
                if (widget!.pageName == 'invitation')
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.asset(
                      'assets/images/Layer_1_(1).webp',
                      width: 160.0,
                      height: 160.0,
                      fit: BoxFit.cover,
                    ),
                  ),
                if (widget!.pageName == 'neighbourhood')
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.asset(
                      'assets/images/Frame.webp',
                      width: 160.0,
                      height: 160.0,
                      fit: BoxFit.cover,
                    ),
                  ),
                if (widget!.pageName == 'sales')
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.asset(
                      'assets/images/empty_market.png',
                      width: 160.0,
                      height: 160.0,
                      fit: BoxFit.cover,
                    ),
                  ),
                if (widget!.pageName == 'posts')
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.asset(
                      'assets/images/nopost.webp',
                      width: 160.0,
                      height: 160.0,
                      fit: BoxFit.cover,
                    ),
                  ),
                if (widget!.pageName == 'neighbour')
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.asset(
                      'assets/images/Frame_(1).webp',
                      width: 160.0,
                      height: 160.0,
                      fit: BoxFit.cover,
                    ),
                  ),
                if (widget!.pageName == 'salesfree')
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.asset(
                      'assets/images/empty_market.png',
                      width: 160.0,
                      height: 160.0,
                      fit: BoxFit.cover,
                    ),
                  ),
                if (widget!.pageName == 'yourslisting')
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.asset(
                      'assets/images/empty_market.png',
                      width: 160.0,
                      height: 160.0,
                      fit: BoxFit.cover,
                    ),
                  ),
                if (widget!.pageName == 'following')
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.asset(
                      'assets/images/following.png',
                      width: 160.0,
                      height: 160.0,
                      fit: BoxFit.cover,
                    ),
                  ),
                if (widget!.pageName == 'followers')
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.asset(
                      'assets/images/followers.webp',
                      width: 160.0,
                      height: 160.0,
                      fit: BoxFit.cover,
                    ),
                  ),
                if (widget!.pageName == 'block')
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.asset(
                      'assets/images/block.webp',
                      width: 160.0,
                      height: 160.0,
                      fit: BoxFit.cover,
                    ),
                  ),
              ],
            ).animate().fadeIn(duration: 400.ms).scale(
                  begin: Offset(0.92, 0.92),
                  end: Offset(1, 1),
                  curve: Curves.easeOutBack,
                ),
            Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Text(
                  valueOrDefault<String>(
                    widget!.text1,
                    'text',
                  ),
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                        font: GoogleFonts.manrope(
                          fontWeight: FontWeight.w600,
                          fontStyle:
                              FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                        ),
                        color: FlutterFlowTheme.of(context).extraBlack,
                        fontSize: 16.0,
                        letterSpacing: 0.0,
                        fontWeight: FontWeight.w600,
                        fontStyle:
                            FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                        lineHeight: 1.4,
                      ),
                ),
                Text(
                  valueOrDefault<String>(
                    widget!.text2,
                    'text2',
                  ),
                  textAlign: TextAlign.center,
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                        font: GoogleFonts.manrope(
                          fontWeight: FontWeight.w500,
                          fontStyle:
                              FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                        ),
                        color: FlutterFlowTheme.of(context).greyL5,
                        fontSize: 14.0,
                        letterSpacing: 0.0,
                        fontWeight: FontWeight.w500,
                        fontStyle:
                            FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                        lineHeight: 1.4,
                      ),
                ),
              ].divide(SizedBox(height: 6.0)),
            ),
          ].divide(SizedBox(height: 16.0)),
        ),
      ),
    );
  }
}
