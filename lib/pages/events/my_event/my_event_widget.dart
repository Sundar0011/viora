import '/auth/supabase_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/pages/home/comp_loading/comp_loading_widget.dart';
import 'dart:ui';
import '/custom_code/actions/index.dart' as actions;
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'my_event_model.dart';
export 'my_event_model.dart';

class MyEventWidget extends StatefulWidget {
  const MyEventWidget({
    super.key,
    required this.btnOption,
  });

  final String? btnOption;

  static String routeName = 'MyEvent';
  static String routePath = 'myEvent';

  @override
  State<MyEventWidget> createState() => _MyEventWidgetState();
}

class _MyEventWidgetState extends State<MyEventWidget> {
  late MyEventModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => MyEventModel());

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      _model.opt = widget!.btnOption;
      safeSetState(() {});
      await Future.delayed(
        Duration(
          milliseconds: 4000,
        ),
      );
      await actions.unsubscribe(
        'event_page',
      );
      await Future.delayed(
        Duration(
          milliseconds: 1000,
        ),
      );
      await actions.subscribe(
        'event_page',
        () async {
          safeSetState(() => _model.requestCompleter2 = null);
          await _model.waitForRequestCompleted2();
        },
      );
      _model.showEmpty = true;
      safeSetState(() {});
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
          safeSetState(() => _model.requestCompleter1 = null);
          await _model.waitForRequestCompleted1();
        },
      );
    });
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        body: SafeArea(
          top: true,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
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
                          color:
                              FlutterFlowTheme.of(context).secondaryBackground,
                        ),
                        child: Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              10.0, 0.0, 20.0, 0.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  FlutterFlowIconButton(
                                    borderRadius: 100.0,
                                    icon: Icon(
                                      Icons.arrow_back,
                                      color: FlutterFlowTheme.of(context)
                                          .extraBlack,
                                      size: 24.0,
                                    ),
                                    onPressed: () async {
                                      context.safePop();
                                    },
                                  ),
                                  Text(
                                    'My Events',
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
                                          color: FlutterFlowTheme.of(context)
                                              .extraBlack,
                                          fontSize: 18.0,
                                          letterSpacing: 0.0,
                                          fontWeight: FontWeight.w600,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .bodyMedium
                                                  .fontStyle,
                                          lineHeight: 1.4,
                                        ),
                                  ),
                                ].divide(SizedBox(width: 10.0)),
                              ),
                              Container(
                                width: 82.0,
                                height: 32.0,
                                decoration: BoxDecoration(
                                  color: FlutterFlowTheme.of(context).primary,
                                  borderRadius: BorderRadius.circular(24.0),
                                ),
                                child: InkWell(
                                  splashColor: Colors.transparent,
                                  focusColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  onTap: () async {
                                    context
                                        .pushNamed(CreateEventWidget.routeName);
                                  },
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.add,
                                        color:
                                            FlutterFlowTheme.of(context).white,
                                        size: 16.0,
                                      ),
                                      Text(
                                        'New',
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
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .white,
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
                                    ].divide(SizedBox(width: 4.0)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        height: 48.0,
                        decoration: BoxDecoration(
                          color:
                              FlutterFlowTheme.of(context).secondaryBackground,
                        ),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              InkWell(
                                splashColor: Colors.transparent,
                                focusColor: Colors.transparent,
                                hoverColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                onTap: () async {
                                  _model.opt = 'all';
                                  safeSetState(() {});
                                },
                                child: Container(
                                  height: 28.0,
                                  decoration: BoxDecoration(
                                    color: _model.opt == 'all'
                                        ? Color(0xFF0F8849)
                                        : Color(0x00000000),
                                    borderRadius: BorderRadius.circular(24.0),
                                    border: Border.all(
                                      color: _model.opt != 'all'
                                          ? FlutterFlowTheme.of(context).greyL4
                                          : Color(0x00000000),
                                    ),
                                  ),
                                  child: Align(
                                    alignment: AlignmentDirectional(0.0, 0.0),
                                    child: Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          16.0, 0.0, 16.0, 0.0),
                                      child: Text(
                                        'All',
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
                                              color: _model.opt == 'all'
                                                  ? FlutterFlowTheme.of(context)
                                                      .white
                                                  : FlutterFlowTheme.of(context)
                                                      .greyL4,
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
                                ),
                              ),
                              FutureBuilder<List<EventAttendingRow>>(
                                future: (_model.requestCompleter1 ??=
                                        Completer<List<EventAttendingRow>>()
                                          ..complete(
                                              EventAttendingTable().queryRows(
                                            queryFn: (q) => q
                                                .eqOrNull(
                                                  'attending_id',
                                                  currentUserUid,
                                                )
                                                .eqOrNull(
                                                  'is_invited',
                                                  true,
                                                )
                                                .eqOrNull(
                                                  'is_attending',
                                                  false,
                                                )
                                                .gtOrNull(
                                                  'end_date_time',
                                                  supaSerialize<DateTime>(
                                                      getCurrentTimestamp),
                                                )
                                                .eqOrNull(
                                                  'is_group_deleted',
                                                  false,
                                                ),
                                          )))
                                    .future,
                                builder: (context, snapshot) {
                                  // Customize what your widget looks like when it's loading.
                                  if (!snapshot.hasData) {
                                    return CompLoadingWidget(
                                      name: 'invitations',
                                    );
                                  }
                                  List<EventAttendingRow>
                                      containerEventAttendingRowList =
                                      snapshot.data!;

                                  return InkWell(
                                    splashColor: Colors.transparent,
                                    focusColor: Colors.transparent,
                                    hoverColor: Colors.transparent,
                                    highlightColor: Colors.transparent,
                                    onTap: () async {
                                      _model.opt = 'invitations';
                                      safeSetState(() {});
                                    },
                                    child: Container(
                                      height: 28.0,
                                      decoration: BoxDecoration(
                                        color: _model.opt == 'invitations'
                                            ? Color(0xFF0F8849)
                                            : Color(0x00000000),
                                        borderRadius:
                                            BorderRadius.circular(24.0),
                                        border: Border.all(
                                          color: _model.opt != 'invitations'
                                              ? FlutterFlowTheme.of(context)
                                                  .greyL4
                                              : Color(0x00000000),
                                        ),
                                      ),
                                      child: Align(
                                        alignment:
                                            AlignmentDirectional(0.0, 0.0),
                                        child: Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  16.0, 0.0, 16.0, 0.0),
                                          child: Text(
                                            'Invitations (${containerEventAttendingRowList.length.toString()})',
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                                  font: GoogleFonts.manrope(
                                                    fontWeight: FontWeight.w600,
                                                    fontStyle:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .bodyMedium
                                                            .fontStyle,
                                                  ),
                                                  color: _model.opt ==
                                                          'invitations'
                                                      ? FlutterFlowTheme.of(
                                                              context)
                                                          .white
                                                      : FlutterFlowTheme.of(
                                                              context)
                                                          .greyL4,
                                                  fontSize: 12.0,
                                                  letterSpacing: 0.0,
                                                  fontWeight: FontWeight.w600,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMedium
                                                          .fontStyle,
                                                  lineHeight: 1.4,
                                                ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                              InkWell(
                                splashColor: Colors.transparent,
                                focusColor: Colors.transparent,
                                hoverColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                onTap: () async {
                                  _model.opt = 'host';
                                  safeSetState(() {});
                                },
                                child: Container(
                                  height: 28.0,
                                  decoration: BoxDecoration(
                                    color: _model.opt == 'host'
                                        ? Color(0xFF0F8849)
                                        : Color(0x00000000),
                                    borderRadius: BorderRadius.circular(24.0),
                                    border: Border.all(
                                      color: _model.opt != 'host'
                                          ? FlutterFlowTheme.of(context).greyL4
                                          : Color(0x00000000),
                                    ),
                                  ),
                                  child: Align(
                                    alignment: AlignmentDirectional(0.0, 0.0),
                                    child: Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          16.0, 0.0, 16.0, 0.0),
                                      child: Text(
                                        'Host',
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
                                              color: _model.opt == 'host'
                                                  ? FlutterFlowTheme.of(context)
                                                      .white
                                                  : FlutterFlowTheme.of(context)
                                                      .greyL4,
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
                                ),
                              ),
                              InkWell(
                                splashColor: Colors.transparent,
                                focusColor: Colors.transparent,
                                hoverColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                onTap: () async {
                                  _model.opt = 'attending';
                                  safeSetState(() {});
                                },
                                child: Container(
                                  height: 28.0,
                                  decoration: BoxDecoration(
                                    color: _model.opt == 'attending'
                                        ? Color(0xFF0F8849)
                                        : Color(0x00000000),
                                    borderRadius: BorderRadius.circular(24.0),
                                    border: Border.all(
                                      color: _model.opt != 'attending'
                                          ? FlutterFlowTheme.of(context).greyL4
                                          : Color(0x00000000),
                                    ),
                                  ),
                                  child: Align(
                                    alignment: AlignmentDirectional(0.0, 0.0),
                                    child: Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          16.0, 0.0, 16.0, 0.0),
                                      child: Text(
                                        'Attending',
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
                                              color: _model.opt == 'attending'
                                                  ? FlutterFlowTheme.of(context)
                                                      .white
                                                  : FlutterFlowTheme.of(context)
                                                      .greyL4,
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
                                ),
                              ),
                            ]
                                .divide(SizedBox(width: 8.0))
                                .addToStart(SizedBox(width: 20.0))
                                .addToEnd(SizedBox(width: 20.0)),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              0.0, 4.0, 0.0, 0.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: FlutterFlowTheme.of(context)
                                  .secondaryBackground,
                            ),
                            child: SingleChildScrollView(
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Stack(
                                    children: [
                                      if (_model.showEmpty)
                                        Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  20.0, 60.0, 20.0, 0.0),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Text(
                                                'No events to show',
                                                style: FlutterFlowTheme.of(
                                                        context)
                                                    .bodyMedium
                                                    .override(
                                                      font: GoogleFonts.manrope(
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyMedium
                                                                .fontStyle,
                                                      ),
                                                      color:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .extraBlack,
                                                      fontSize: 20.0,
                                                      letterSpacing: 0.0,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontStyle:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .bodyMedium
                                                              .fontStyle,
                                                      lineHeight: 1.4,
                                                    ),
                                              ),
                                              Text(
                                                'Looks like no one has uploaded anything yet. Check back soon!',
                                                textAlign: TextAlign.center,
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
                                                      color:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .greyL5,
                                                      fontSize: 14.0,
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
                                            ].divide(SizedBox(height: 6.0)),
                                          ),
                                        ),
                                      Align(
                                        alignment:
                                            AlignmentDirectional(0.0, 0.0),
                                        child:
                                            FutureBuilder<List<EventPageRow>>(
                                          future: (_model.requestCompleter2 ??=
                                                  Completer<
                                                      List<EventPageRow>>()
                                                    ..complete(EventPageTable()
                                                        .queryRows(
                                                      queryFn: (q) => q
                                                          .eqOrNull(
                                                            'is_deleted',
                                                            false,
                                                          )
                                                          .gtOrNull(
                                                            'end_date_time',
                                                            supaSerialize<
                                                                    DateTime>(
                                                                getCurrentTimestamp),
                                                          )
                                                          .order('created_at'),
                                                    )))
                                              .future,
                                          builder: (context, snapshot) {
                                            // Customize what your widget looks like when it's loading.
                                            if (!snapshot.hasData) {
                                              return CompLoadingWidget(
                                                name: 'eventList',
                                              );
                                            }
                                            List<EventPageRow>
                                                allEventsListViewEventPageRowList =
                                                snapshot.data!;

                                            return InkWell(
                                              splashColor: Colors.transparent,
                                              focusColor: Colors.transparent,
                                              hoverColor: Colors.transparent,
                                              highlightColor:
                                                  Colors.transparent,
                                              onTap: () async {
                                                safeSetState(() => _model
                                                    .requestCompleter2 = null);
                                                await _model
                                                    .waitForRequestCompleted2();
                                              },
                                              child: ListView.separated(
                                                padding: EdgeInsets.fromLTRB(
                                                  0,
                                                  0,
                                                  0,
                                                  20.0,
                                                ),
                                                primary: false,
                                                shrinkWrap: true,
                                                scrollDirection: Axis.vertical,
                                                itemCount:
                                                    allEventsListViewEventPageRowList
                                                        .length,
                                                separatorBuilder: (_, __) =>
                                                    SizedBox(height: 12.0),
                                                itemBuilder: (context,
                                                    allEventsListViewIndex) {
                                                  final allEventsListViewEventPageRow =
                                                      allEventsListViewEventPageRowList[
                                                          allEventsListViewIndex];
                                                  return Container(
                                                    decoration: BoxDecoration(
                                                      color:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .white,
                                                    ),
                                                    child: FutureBuilder<
                                                        List<
                                                            EventAttendingRow>>(
                                                      future:
                                                          EventAttendingTable()
                                                              .querySingleRow(
                                                        queryFn: (q) => q
                                                            .eqOrNull(
                                                              'event_id',
                                                              allEventsListViewEventPageRow
                                                                  .id,
                                                            )
                                                            .eqOrNull(
                                                              'attending_id',
                                                              currentUserUid,
                                                            ),
                                                      ),
                                                      builder:
                                                          (context, snapshot) {
                                                        // Customize what your widget looks like when it's loading.
                                                        if (!snapshot.hasData) {
                                                          return CompLoadingWidget(
                                                            name: 'eventCard2',
                                                          );
                                                        }
                                                        List<EventAttendingRow>
                                                            columnEventAttendingRowList =
                                                            snapshot.data!;

                                                        final columnEventAttendingRow =
                                                            columnEventAttendingRowList
                                                                    .isNotEmpty
                                                                ? columnEventAttendingRowList
                                                                    .first
                                                                : null;

                                                        return Column(
                                                          mainAxisSize:
                                                              MainAxisSize.max,
                                                          children: [
                                                            if ((_model.opt ==
                                                                    'all') ||
                                                                ((_model.opt ==
                                                                        'invitations') &&
                                                                    ((columnEventAttendingRow
                                                                                ?.eventId ==
                                                                            allEventsListViewEventPageRow
                                                                                .id) &&
                                                                        (columnEventAttendingRow
                                                                                ?.attendingId ==
                                                                            currentUserUid) &&
                                                                        columnEventAttendingRow!
                                                                            .isInvited &&
                                                                        (columnEventAttendingRow
                                                                                ?.isAttending ==
                                                                            false))) ||
                                                                ((_model.opt ==
                                                                        'host') &&
                                                                    (allEventsListViewEventPageRow
                                                                            .adminUser ==
                                                                        currentUserUid)) ||
                                                                ((_model.opt ==
                                                                        'attending') &&
                                                                    ((columnEventAttendingRow
                                                                                ?.eventId ==
                                                                            allEventsListViewEventPageRow
                                                                                .id) &&
                                                                        (columnEventAttendingRow?.attendingId ==
                                                                            currentUserUid) &&
                                                                        (columnEventAttendingRow?.isAttending ==
                                                                            true))))
                                                              Padding(
                                                                padding: EdgeInsetsDirectional
                                                                    .fromSTEB(
                                                                        20.0,
                                                                        0.0,
                                                                        20.0,
                                                                        0.0),
                                                                child: InkWell(
                                                                  splashColor:
                                                                      Colors
                                                                          .transparent,
                                                                  focusColor: Colors
                                                                      .transparent,
                                                                  hoverColor: Colors
                                                                      .transparent,
                                                                  highlightColor:
                                                                      Colors
                                                                          .transparent,
                                                                  onTap:
                                                                      () async {
                                                                    context
                                                                        .pushNamed(
                                                                      EventDetailsWidget
                                                                          .routeName,
                                                                      queryParameters:
                                                                          {
                                                                        'eventId':
                                                                            serializeParam(
                                                                          allEventsListViewEventPageRow
                                                                              .id,
                                                                          ParamType
                                                                              .String,
                                                                        ),
                                                                      }.withoutNulls,
                                                                    );
                                                                  },
                                                                  child:
                                                                      Container(
                                                                    height:
                                                                        188.0,
                                                                    decoration:
                                                                        BoxDecoration(),
                                                                    child:
                                                                        Padding(
                                                                      padding: EdgeInsetsDirectional.fromSTEB(
                                                                          0.0,
                                                                          8.0,
                                                                          0.0,
                                                                          8.0),
                                                                      child:
                                                                          Row(
                                                                        mainAxisSize:
                                                                            MainAxisSize.max,
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.start,
                                                                        children:
                                                                            [
                                                                          ClipRRect(
                                                                            borderRadius:
                                                                                BorderRadius.circular(2.0),
                                                                            child:
                                                                                Image.network(
                                                                              allEventsListViewEventPageRow.coverImage,
                                                                              width: 120.0,
                                                                              height: 120.0,
                                                                              fit: BoxFit.cover,
                                                                            ),
                                                                          ),
                                                                          Expanded(
                                                                            child:
                                                                                Column(
                                                                              mainAxisSize: MainAxisSize.max,
                                                                              children: [
                                                                                Expanded(
                                                                                  child: Column(
                                                                                    mainAxisSize: MainAxisSize.max,
                                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                                    children: [
                                                                                      if ((columnEventAttendingRow?.id != null && columnEventAttendingRow?.id != '') && (columnEventAttendingRow?.isInvited == true) && (columnEventAttendingRow?.isAttending == false))
                                                                                        FutureBuilder<List<PublicUserProfileRow>>(
                                                                                          future: PublicUserProfileTable().querySingleRow(
                                                                                            queryFn: (q) => q.eqOrNull(
                                                                                              'id',
                                                                                              columnEventAttendingRow?.invitedBy,
                                                                                            ),
                                                                                          ),
                                                                                          builder: (context, snapshot) {
                                                                                            // Customize what your widget looks like when it's loading.
                                                                                            if (!snapshot.hasData) {
                                                                                              return CompLoadingWidget(
                                                                                                name: 'loadingInvite',
                                                                                              );
                                                                                            }
                                                                                            List<PublicUserProfileRow> rowPublicUserProfileRowList = snapshot.data!;

                                                                                            // Return an empty Container when the item does not exist.
                                                                                            if (snapshot.data!.isEmpty) {
                                                                                              return Container();
                                                                                            }
                                                                                            final rowPublicUserProfileRow = rowPublicUserProfileRowList.isNotEmpty ? rowPublicUserProfileRowList.first : null;

                                                                                            return Row(
                                                                                              mainAxisSize: MainAxisSize.max,
                                                                                              children: [
                                                                                                Container(
                                                                                                  width: 12.0,
                                                                                                  height: 12.0,
                                                                                                  clipBehavior: Clip.antiAlias,
                                                                                                  decoration: BoxDecoration(
                                                                                                    shape: BoxShape.circle,
                                                                                                  ),
                                                                                                  child: Image.network(
                                                                                                    rowPublicUserProfileRow!.profilePicture!,
                                                                                                    fit: BoxFit.cover,
                                                                                                  ),
                                                                                                ),
                                                                                                Expanded(
                                                                                                  child: Row(
                                                                                                    mainAxisSize: MainAxisSize.max,
                                                                                                    children: [
                                                                                                      Text(
                                                                                                        valueOrDefault<String>(
                                                                                                          rowPublicUserProfileRow?.name,
                                                                                                          'name  jjhgjh jhjhjh jhjhjhj',
                                                                                                        ),
                                                                                                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                                              font: GoogleFonts.manrope(
                                                                                                                fontWeight: FontWeight.w500,
                                                                                                                fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                              ),
                                                                                                              color: FlutterFlowTheme.of(context).greyL4,
                                                                                                              fontSize: 10.0,
                                                                                                              letterSpacing: 0.0,
                                                                                                              fontWeight: FontWeight.w500,
                                                                                                              fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                              lineHeight: 1.4,
                                                                                                            ),
                                                                                                      ),
                                                                                                      Expanded(
                                                                                                        child: Text(
                                                                                                          ' invited you to join this event',
                                                                                                          maxLines: 1,
                                                                                                          style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                                                font: GoogleFonts.manrope(
                                                                                                                  fontWeight: FontWeight.w500,
                                                                                                                  fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                                ),
                                                                                                                color: FlutterFlowTheme.of(context).greyL4,
                                                                                                                fontSize: 10.0,
                                                                                                                letterSpacing: 0.0,
                                                                                                                fontWeight: FontWeight.w500,
                                                                                                                fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                                lineHeight: 1.4,
                                                                                                              ),
                                                                                                        ),
                                                                                                      ),
                                                                                                    ],
                                                                                                  ),
                                                                                                ),
                                                                                              ].divide(SizedBox(width: 10.0)),
                                                                                            );
                                                                                          },
                                                                                        ),
                                                                                      Column(
                                                                                        mainAxisSize: MainAxisSize.max,
                                                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                                                        children: [
                                                                                          Text(
                                                                                            allEventsListViewEventPageRow.name,
                                                                                            maxLines: 2,
                                                                                            style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                                  font: GoogleFonts.manrope(
                                                                                                    fontWeight: FontWeight.w600,
                                                                                                    fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                  ),
                                                                                                  color: FlutterFlowTheme.of(context).extraBlack,
                                                                                                  fontSize: 16.0,
                                                                                                  letterSpacing: 0.0,
                                                                                                  fontWeight: FontWeight.w600,
                                                                                                  fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                  lineHeight: 1.4,
                                                                                                ),
                                                                                          ),
                                                                                          Text(
                                                                                            allEventsListViewEventPageRow.description,
                                                                                            maxLines: 2,
                                                                                            style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                                  font: GoogleFonts.manrope(
                                                                                                    fontWeight: FontWeight.w500,
                                                                                                    fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                  ),
                                                                                                  color: FlutterFlowTheme.of(context).greyL4,
                                                                                                  fontSize: 10.0,
                                                                                                  letterSpacing: 0.0,
                                                                                                  fontWeight: FontWeight.w500,
                                                                                                  fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                  lineHeight: 1.4,
                                                                                                ),
                                                                                          ),
                                                                                        ].divide(SizedBox(height: 2.0)),
                                                                                      ),
                                                                                      Padding(
                                                                                        padding: EdgeInsetsDirectional.fromSTEB(0.0, 4.0, 0.0, 0.0),
                                                                                        child: Column(
                                                                                          mainAxisSize: MainAxisSize.max,
                                                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                                                          children: [
                                                                                            Row(
                                                                                              mainAxisSize: MainAxisSize.max,
                                                                                              children: [
                                                                                                ClipRRect(
                                                                                                  borderRadius: BorderRadius.circular(0.0),
                                                                                                  child: Image.asset(
                                                                                                    'assets/images/calendar_clock.png',
                                                                                                    width: 16.0,
                                                                                                    height: 16.0,
                                                                                                    fit: BoxFit.cover,
                                                                                                  ),
                                                                                                ),
                                                                                                Text(
                                                                                                  valueOrDefault<String>(
                                                                                                    functions.eventDate(allEventsListViewEventPageRow.startDateTime),
                                                                                                    'date',
                                                                                                  ),
                                                                                                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                                        font: GoogleFonts.manrope(
                                                                                                          fontWeight: FontWeight.w500,
                                                                                                          fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                        ),
                                                                                                        color: FlutterFlowTheme.of(context).greyL4,
                                                                                                        fontSize: 10.0,
                                                                                                        letterSpacing: 0.0,
                                                                                                        fontWeight: FontWeight.w500,
                                                                                                        fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                        lineHeight: 1.4,
                                                                                                      ),
                                                                                                ),
                                                                                              ].divide(SizedBox(width: 6.0)),
                                                                                            ),
                                                                                            Row(
                                                                                              mainAxisSize: MainAxisSize.max,
                                                                                              children: [
                                                                                                ClipRRect(
                                                                                                  borderRadius: BorderRadius.circular(0.0),
                                                                                                  child: Image.asset(
                                                                                                    'assets/images/explore.png',
                                                                                                    width: 16.0,
                                                                                                    height: 16.0,
                                                                                                    fit: BoxFit.cover,
                                                                                                  ),
                                                                                                ),
                                                                                                Expanded(
                                                                                                  child: Text(
                                                                                                    valueOrDefault<String>(
                                                                                                      allEventsListViewEventPageRow.address,
                                                                                                      'Address',
                                                                                                    ),
                                                                                                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                                          font: GoogleFonts.manrope(
                                                                                                            fontWeight: FontWeight.w500,
                                                                                                            fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                          ),
                                                                                                          color: FlutterFlowTheme.of(context).greyL4,
                                                                                                          fontSize: 10.0,
                                                                                                          letterSpacing: 0.0,
                                                                                                          fontWeight: FontWeight.w500,
                                                                                                          fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                          lineHeight: 1.4,
                                                                                                        ),
                                                                                                  ),
                                                                                                ),
                                                                                              ].divide(SizedBox(width: 6.0)),
                                                                                            ),
                                                                                            Row(
                                                                                              mainAxisSize: MainAxisSize.max,
                                                                                              children: [
                                                                                                ClipRRect(
                                                                                                  borderRadius: BorderRadius.circular(0.0),
                                                                                                  child: Image.asset(
                                                                                                    'assets/images/crowdsource_(1).png',
                                                                                                    width: 16.0,
                                                                                                    height: 16.0,
                                                                                                    fit: BoxFit.cover,
                                                                                                  ),
                                                                                                ),
                                                                                                Text(
                                                                                                  '${allEventsListViewEventPageRow.attendeeCount.toString()} attending',
                                                                                                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                                        font: GoogleFonts.manrope(
                                                                                                          fontWeight: FontWeight.w500,
                                                                                                          fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                        ),
                                                                                                        color: FlutterFlowTheme.of(context).greyL4,
                                                                                                        fontSize: 10.0,
                                                                                                        letterSpacing: 0.0,
                                                                                                        fontWeight: FontWeight.w500,
                                                                                                        fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                        lineHeight: 1.4,
                                                                                                      ),
                                                                                                ),
                                                                                              ].divide(SizedBox(width: 6.0)),
                                                                                            ),
                                                                                          ].divide(SizedBox(height: 4.0)),
                                                                                        ),
                                                                                      ),
                                                                                    ],
                                                                                  ),
                                                                                ),
                                                                                if (allEventsListViewEventPageRow.adminUser != currentUserUid)
                                                                                  Stack(
                                                                                    children: [
                                                                                      FFButtonWidget(
                                                                                        onPressed: () async {
                                                                                          await EventAttendingTable().insert({
                                                                                            'community_id': FFAppState().communityId,
                                                                                            'event_id': allEventsListViewEventPageRow.id,
                                                                                            'attending_id': currentUserUid,
                                                                                            'is_invited': false,
                                                                                            'is_attending': true,
                                                                                          });
                                                                                          _model.apiResultryklop09115 = await UpdateEventAttendeeCountCall.call(
                                                                                            token: currentJwtToken,
                                                                                            eventId: allEventsListViewEventPageRow.id,
                                                                                          );

                                                                                          safeSetState(() {});
                                                                                        },
                                                                                        text: 'Attend',
                                                                                        icon: Icon(
                                                                                          Icons.edit_calendar_outlined,
                                                                                          size: 15.0,
                                                                                        ),
                                                                                        options: FFButtonOptions(
                                                                                          width: double.infinity,
                                                                                          height: 24.0,
                                                                                          padding: EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                                                                                          iconPadding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                                                                                          color: FlutterFlowTheme.of(context).white,
                                                                                          textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                                                                                                font: GoogleFonts.interTight(
                                                                                                  fontWeight: FlutterFlowTheme.of(context).titleSmall.fontWeight,
                                                                                                  fontStyle: FlutterFlowTheme.of(context).titleSmall.fontStyle,
                                                                                                ),
                                                                                                color: FlutterFlowTheme.of(context).primaryD3,
                                                                                                fontSize: 12.0,
                                                                                                letterSpacing: 0.0,
                                                                                                fontWeight: FlutterFlowTheme.of(context).titleSmall.fontWeight,
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
                                                                                      if ((columnEventAttendingRow?.id != null && columnEventAttendingRow?.id != '') && (columnEventAttendingRow?.isAttending == false))
                                                                                        FFButtonWidget(
                                                                                          onPressed: () async {
                                                                                            await EventAttendingTable().update(
                                                                                              data: {
                                                                                                'is_attending': true,
                                                                                              },
                                                                                              matchingRows: (rows) => rows
                                                                                                  .eqOrNull(
                                                                                                    'event_id',
                                                                                                    allEventsListViewEventPageRow.id,
                                                                                                  )
                                                                                                  .eqOrNull(
                                                                                                    'attending_id',
                                                                                                    currentUserUid,
                                                                                                  ),
                                                                                            );
                                                                                            _model.apiResultryklop0911 = await UpdateEventAttendeeCountCall.call(
                                                                                              token: currentJwtToken,
                                                                                              eventId: allEventsListViewEventPageRow.id,
                                                                                            );

                                                                                            safeSetState(() {});
                                                                                          },
                                                                                          text: 'Attend',
                                                                                          icon: Icon(
                                                                                            Icons.edit_calendar_outlined,
                                                                                            size: 15.0,
                                                                                          ),
                                                                                          options: FFButtonOptions(
                                                                                            width: double.infinity,
                                                                                            height: 24.0,
                                                                                            padding: EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                                                                                            iconPadding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                                                                                            color: FlutterFlowTheme.of(context).white,
                                                                                            textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                                                                                                  font: GoogleFonts.interTight(
                                                                                                    fontWeight: FlutterFlowTheme.of(context).titleSmall.fontWeight,
                                                                                                    fontStyle: FlutterFlowTheme.of(context).titleSmall.fontStyle,
                                                                                                  ),
                                                                                                  color: FlutterFlowTheme.of(context).primaryD3,
                                                                                                  fontSize: 12.0,
                                                                                                  letterSpacing: 0.0,
                                                                                                  fontWeight: FlutterFlowTheme.of(context).titleSmall.fontWeight,
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
                                                                                      if ((columnEventAttendingRow?.id != null && columnEventAttendingRow?.id != '') && (columnEventAttendingRow?.isAttending == true))
                                                                                        FFButtonWidget(
                                                                                          onPressed: () async {
                                                                                            await EventAttendingTable().update(
                                                                                              data: {
                                                                                                'is_attending': false,
                                                                                              },
                                                                                              matchingRows: (rows) => rows
                                                                                                  .eqOrNull(
                                                                                                    'event_id',
                                                                                                    allEventsListViewEventPageRow.id,
                                                                                                  )
                                                                                                  .eqOrNull(
                                                                                                    'attending_id',
                                                                                                    currentUserUid,
                                                                                                  ),
                                                                                            );
                                                                                            _model.apiResultryklop0900 = await UpdateEventAttendeeCountCall.call(
                                                                                              token: currentJwtToken,
                                                                                              eventId: allEventsListViewEventPageRow.id,
                                                                                            );

                                                                                            safeSetState(() {});
                                                                                          },
                                                                                          text: 'Attending',
                                                                                          icon: Icon(
                                                                                            Icons.edit_calendar_outlined,
                                                                                            size: 15.0,
                                                                                          ),
                                                                                          options: FFButtonOptions(
                                                                                            width: double.infinity,
                                                                                            height: 24.0,
                                                                                            padding: EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                                                                                            iconPadding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                                                                                            color: FlutterFlowTheme.of(context).white,
                                                                                            textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                                                                                                  font: GoogleFonts.interTight(
                                                                                                    fontWeight: FlutterFlowTheme.of(context).titleSmall.fontWeight,
                                                                                                    fontStyle: FlutterFlowTheme.of(context).titleSmall.fontStyle,
                                                                                                  ),
                                                                                                  color: FlutterFlowTheme.of(context).greyL4,
                                                                                                  fontSize: 12.0,
                                                                                                  letterSpacing: 0.0,
                                                                                                  fontWeight: FlutterFlowTheme.of(context).titleSmall.fontWeight,
                                                                                                  fontStyle: FlutterFlowTheme.of(context).titleSmall.fontStyle,
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
                                                                                        ),
                                                                                    ],
                                                                                  ),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                        ].divide(SizedBox(width: 8.0)),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                          ],
                                                        );
                                                      },
                                                    ),
                                                  );
                                                },
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
