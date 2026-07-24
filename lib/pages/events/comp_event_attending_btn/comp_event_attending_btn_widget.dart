import '/auth/supabase_auth/auth_util.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/custom_code/actions/index.dart' as actions;
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'comp_event_attending_btn_model.dart';
export 'comp_event_attending_btn_model.dart';

class CompEventAttendingBtnWidget extends StatefulWidget {
  const CompEventAttendingBtnWidget({
    super.key,
    this.parameter1,
    this.eventId,
  });

  final int? parameter1;
  final String? eventId;

  @override
  State<CompEventAttendingBtnWidget> createState() =>
      _CompEventAttendingBtnWidgetState();
}

class _CompEventAttendingBtnWidgetState
    extends State<CompEventAttendingBtnWidget> {
  late CompEventAttendingBtnModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => CompEventAttendingBtnModel());

    // On component load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      await actions.unsubscribe(
        'event_attending',
      );
      await Future.delayed(
        Duration(
          milliseconds: 1000,
        ),
      );
      await actions.subscribe(
        'event_attending',
        () async {
          safeSetState(() => _model.requestCompleter2 = null);
          await _model.waitForRequestCompleted2();
          safeSetState(() => _model.requestCompleter1 = null);
          await _model.waitForRequestCompleted1();
        },
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
    return Stack(
      children: [
        FFButtonWidget(
          onPressed: () async {
            HapticFeedback.lightImpact();
            await EventAttendingTable().insert({
              'community_id': widget!.parameter1,
              'event_id': widget!.eventId,
              'attending_id': currentUserUid,
              'is_invited': false,
              'is_attending': true,
            });
          },
          text: 'Attend',
          icon: Icon(
            Icons.edit_calendar_outlined,
            color: FlutterFlowTheme.of(context).primaryD3,
            size: 15.0,
          ),
          options: FFButtonOptions(
            width: double.infinity,
            height: 24.0,
            padding: EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
            iconPadding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
            color: FlutterFlowTheme.of(context).white,
            textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                  font: GoogleFonts.manrope(
                    fontWeight:
                        FlutterFlowTheme.of(context).titleSmall.fontWeight,
                    fontStyle:
                        FlutterFlowTheme.of(context).titleSmall.fontStyle,
                  ),
                  color: FlutterFlowTheme.of(context).primaryD3,
                  fontSize: 12.0,
                  letterSpacing: 0.0,
                  fontWeight:
                      FlutterFlowTheme.of(context).titleSmall.fontWeight,
                  fontStyle: FlutterFlowTheme.of(context).titleSmall.fontStyle,
                ),
            elevation: 0.0,
            borderSide: BorderSide(
              color: FlutterFlowTheme.of(context).primaryD3,
              width: 1.0,
            ),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(100.0),
              topRight: Radius.circular(100.0),
              bottomLeft: Radius.circular(100.0),
              bottomRight: Radius.circular(100.0),
            ),
          ),
        ),
        FutureBuilder<List<EventAttendingRow>>(
          future:
              (_model.requestCompleter2 ??= Completer<List<EventAttendingRow>>()
                    ..complete(EventAttendingTable().querySingleRow(
                      queryFn: (q) => q
                          .eqOrNull(
                            'event_id',
                            widget!.eventId,
                          )
                          .eqOrNull(
                            'attending_id',
                            currentUserUid,
                          )
                          .eqOrNull(
                            'is_attending',
                            false,
                          ),
                    )))
                  .future,
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
            List<EventAttendingRow> invitedEventAttendingRowList =
                snapshot.data!;

            // Return an empty Container when the item does not exist.
            if (snapshot.data!.isEmpty) {
              return Container();
            }
            final invitedEventAttendingRow =
                invitedEventAttendingRowList.isNotEmpty
                    ? invitedEventAttendingRowList.first
                    : null;

            return FFButtonWidget(
              onPressed: () async {
                HapticFeedback.lightImpact();
                await EventAttendingTable().update(
                  data: {
                    'is_attending': true,
                  },
                  matchingRows: (rows) => rows
                      .eqOrNull(
                        'event_id',
                        widget!.eventId,
                      )
                      .eqOrNull(
                        'attending_id',
                        currentUserUid,
                      ),
                );
                safeSetState(() => _model.requestCompleter2 = null);
                await _model.waitForRequestCompleted2();
                safeSetState(() => _model.requestCompleter1 = null);
                await _model.waitForRequestCompleted1();
              },
              text: 'Attend',
              icon: Icon(
                Icons.edit_calendar_outlined,
                color: FlutterFlowTheme.of(context).primaryD3,
                size: 15.0,
              ),
              options: FFButtonOptions(
                width: double.infinity,
                height: 24.0,
                padding: EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                iconPadding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                color: FlutterFlowTheme.of(context).white,
                textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                      font: GoogleFonts.manrope(
                        fontWeight:
                            FlutterFlowTheme.of(context).titleSmall.fontWeight,
                        fontStyle:
                            FlutterFlowTheme.of(context).titleSmall.fontStyle,
                      ),
                      color: FlutterFlowTheme.of(context).primaryD3,
                      fontSize: 12.0,
                      letterSpacing: 0.0,
                      fontWeight:
                          FlutterFlowTheme.of(context).titleSmall.fontWeight,
                      fontStyle:
                          FlutterFlowTheme.of(context).titleSmall.fontStyle,
                    ),
                elevation: 0.0,
                borderSide: BorderSide(
                  color: FlutterFlowTheme.of(context).primaryD3,
                  width: 1.0,
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(100.0),
                  topRight: Radius.circular(100.0),
                  bottomLeft: Radius.circular(100.0),
                  bottomRight: Radius.circular(100.0),
                ),
              ),
            );
          },
        ),
        FutureBuilder<List<EventAttendingRow>>(
          future:
              (_model.requestCompleter1 ??= Completer<List<EventAttendingRow>>()
                    ..complete(EventAttendingTable().querySingleRow(
                      queryFn: (q) => q
                          .eqOrNull(
                            'attending_id',
                            currentUserUid,
                          )
                          .eqOrNull(
                            'event_id',
                            widget!.eventId,
                          )
                          .eqOrNull(
                            'is_attending',
                            true,
                          ),
                    )))
                  .future,
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
            List<EventAttendingRow> attendingEventAttendingRowList =
                snapshot.data!;

            // Return an empty Container when the item does not exist.
            if (snapshot.data!.isEmpty) {
              return Container();
            }
            final attendingEventAttendingRow =
                attendingEventAttendingRowList.isNotEmpty
                    ? attendingEventAttendingRowList.first
                    : null;

            return FFButtonWidget(
              onPressed: () async {
                HapticFeedback.lightImpact();
                await EventAttendingTable().update(
                  data: {
                    'is_attending': false,
                  },
                  matchingRows: (rows) => rows
                      .eqOrNull(
                        'event_id',
                        widget!.eventId,
                      )
                      .eqOrNull(
                        'attending_id',
                        currentUserUid,
                      ),
                );
                safeSetState(() => _model.requestCompleter2 = null);
                await _model.waitForRequestCompleted2();
                safeSetState(() => _model.requestCompleter1 = null);
                await _model.waitForRequestCompleted1();
              },
              text: 'Attending',
              icon: Icon(
                Icons.edit_calendar_outlined,
                color: FlutterFlowTheme.of(context).greyL4,
                size: 15.0,
              ),
              options: FFButtonOptions(
                width: double.infinity,
                height: 24.0,
                padding: EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                iconPadding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                color: FlutterFlowTheme.of(context).white,
                textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                      font: GoogleFonts.manrope(
                        fontWeight:
                            FlutterFlowTheme.of(context).titleSmall.fontWeight,
                        fontStyle:
                            FlutterFlowTheme.of(context).titleSmall.fontStyle,
                      ),
                      color: FlutterFlowTheme.of(context).greyL4,
                      fontSize: 12.0,
                      letterSpacing: 0.0,
                      fontWeight:
                          FlutterFlowTheme.of(context).titleSmall.fontWeight,
                      fontStyle:
                          FlutterFlowTheme.of(context).titleSmall.fontStyle,
                    ),
                elevation: 0.0,
                borderSide: BorderSide(
                  color: FlutterFlowTheme.of(context).greyL4,
                  width: 1.0,
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(100.0),
                  topRight: Radius.circular(100.0),
                  bottomLeft: Radius.circular(100.0),
                  bottomRight: Radius.circular(100.0),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
