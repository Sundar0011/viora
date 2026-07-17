import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/custom_code/widgets/index.dart' as custom_widgets;
import '/flutter_flow/custom_functions.dart' as functions;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'comp_select_date_time_model.dart';
export 'comp_select_date_time_model.dart';

class CompSelectDateTimeWidget extends StatefulWidget {
  const CompSelectDateTimeWidget({
    super.key,
    required this.pageName,
  });

  final String? pageName;

  @override
  State<CompSelectDateTimeWidget> createState() =>
      _CompSelectDateTimeWidgetState();
}

class _CompSelectDateTimeWidgetState extends State<CompSelectDateTimeWidget> {
  late CompSelectDateTimeModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => CompSelectDateTimeModel());

    // On component load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      if (widget!.pageName == 'start') {
        _model.selectTime = FFAppState().EventChoosedTime;
        safeSetState(() {});
      } else {
        _model.selectTime = FFAppState().EventChoosedTimeEnd;
        safeSetState(() {});
      }
    });
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
        color: FlutterFlowTheme.of(context).white,
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
                crossAxisAlignment: CrossAxisAlignment.start,
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
                          'Select Date & Time',
                          style: FlutterFlowTheme.of(context)
                              .bodyMedium
                              .override(
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
                  Padding(
                    padding:
                        EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                    child: Container(
                      width: double.infinity,
                      height: 128.0,
                      child: custom_widgets.HorizontalDatePicker(
                        width: double.infinity,
                        height: 128.0,
                        pageName: widget!.pageName!,
                      ),
                    ),
                  ),
                  Divider(
                    height: 1.0,
                    thickness: 1.0,
                    indent: 16.0,
                    endIndent: 16.0,
                    color: FlutterFlowTheme.of(context).greayL1,
                  ),
                  Padding(
                    padding:
                        EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 0.0, 0.0),
                    child: Text(
                      'Time',
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            font: GoogleFonts.manrope(
                              fontWeight: FontWeight.w500,
                              fontStyle: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .fontStyle,
                            ),
                            color: FlutterFlowTheme.of(context).extraBlack,
                            letterSpacing: 0.0,
                            fontWeight: FontWeight.w500,
                            fontStyle: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .fontStyle,
                            lineHeight: 1.3,
                          ),
                    ),
                  ),
                  if ((FFAppState().ChoosedStartEventDate ==
                          FFAppState().ChoosedEndEventDate) &&
                      (widget!.pageName == 'end'))
                    Builder(
                      builder: (context) {
                        final time = _model.stringTimeArray.toList();

                        return SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            children: List.generate(time.length, (timeIndex) {
                              final timeItem = time[timeIndex];
                              return Visibility(
                                visible: (functions.validDate(timeItem,
                                            FFAppState().EventChoosedTime) ==
                                        true) ||
                                    (widget!.pageName == 'start'),
                                child: InkWell(
                                  splashColor: Colors.transparent,
                                  focusColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  onTap: () async {
                                    _model.selectTime = timeItem;
                                    safeSetState(() {});
                                  },
                                  child: Container(
                                    width: 80.0,
                                    height: 28.0,
                                    decoration: BoxDecoration(
                                      color: timeItem == _model.selectTime
                                          ? Color(0xFF516EFF)
                                          : Color(0x00FFFFFF),
                                      borderRadius: BorderRadius.circular(4.0),
                                      border: Border.all(
                                        color: timeItem == _model.selectTime
                                            ? Colors.transparent
                                            : FlutterFlowTheme.of(context)
                                                .primaryL1,
                                      ),
                                    ),
                                    alignment: AlignmentDirectional(0.0, 0.0),
                                    child: Text(
                                      timeItem,
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
                                            color: timeItem == _model.selectTime
                                                ? FlutterFlowTheme.of(context)
                                                    .white
                                                : FlutterFlowTheme.of(context)
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
                                  ),
                                ),
                              );
                            })
                                .divide(
                                  SizedBox(width: 10.0),
                                  filterFn: (timeIndex) {
                                    final timeItem = time[timeIndex];
                                    return (functions.validDate(
                                                timeItem,
                                                FFAppState()
                                                    .EventChoosedTime) ==
                                            true) ||
                                        (widget!.pageName == 'start');
                                  },
                                )
                                .addToStart(SizedBox(width: 16.0))
                                .addToEnd(SizedBox(width: 16.0)),
                          ),
                        );
                      },
                    ),
                  if ((FFAppState().ChoosedStartEventDate !=
                          FFAppState().ChoosedEndEventDate) ||
                      (widget!.pageName == 'start'))
                    Builder(
                      builder: (context) {
                        final time = _model.stringTimeArray.toList();

                        return SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            children: List.generate(time.length, (timeIndex) {
                              final timeItem = time[timeIndex];
                              return InkWell(
                                splashColor: Colors.transparent,
                                focusColor: Colors.transparent,
                                hoverColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                onTap: () async {
                                  _model.selectTime = timeItem;
                                  safeSetState(() {});
                                },
                                child: Container(
                                  width: 80.0,
                                  height: 28.0,
                                  decoration: BoxDecoration(
                                    color: timeItem == _model.selectTime
                                        ? Color(0xFF516EFF)
                                        : Color(0x00FFFFFF),
                                    borderRadius: BorderRadius.circular(4.0),
                                    border: Border.all(
                                      color: timeItem == _model.selectTime
                                          ? Colors.transparent
                                          : FlutterFlowTheme.of(context)
                                              .primaryL1,
                                    ),
                                  ),
                                  alignment: AlignmentDirectional(0.0, 0.0),
                                  child: Text(
                                    timeItem,
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
                                          color: timeItem == _model.selectTime
                                              ? FlutterFlowTheme.of(context)
                                                  .white
                                              : FlutterFlowTheme.of(context)
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
                                ),
                              );
                            })
                                .divide(SizedBox(width: 10.0))
                                .addToStart(SizedBox(width: 16.0))
                                .addToEnd(SizedBox(width: 16.0)),
                          ),
                        );
                      },
                    ),
                  Padding(
                    padding:
                        EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                    child: FFButtonWidget(
                      onPressed: () async {
                        if (widget!.pageName == 'start') {
                          FFAppState().EventChoosedTime = _model.selectTime;
                          FFAppState().ChoosedEndEventDate = null;
                          FFAppState().EventChoosedTimeEnd = '';
                          safeSetState(() {});
                          Navigator.pop(context);
                        } else {
                          if (FFAppState().EventChoosedTimeEnd == null ||
                              FFAppState().EventChoosedTimeEnd == '') {
                            FFAppState().EventChoosedTimeEnd =
                                FFAppState().EventChoosedTime;
                            safeSetState(() {});
                          } else {
                            FFAppState().EventChoosedTimeEnd =
                                _model.selectTime;
                            safeSetState(() {});
                          }

                          Navigator.pop(context);
                        }
                      },
                      text: 'Confirm',
                      options: FFButtonOptions(
                        width: double.infinity,
                        height: 40.0,
                        padding: EdgeInsetsDirectional.fromSTEB(
                            16.0, 12.0, 16.0, 12.0),
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
