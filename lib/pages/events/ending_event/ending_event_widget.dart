import '/auth/supabase_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/backend/supabase/supabase.dart';
import '/components/app_network_image.dart';
import '/components/comp_no_data_found_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/pages/home/comp_loading/comp_loading_widget.dart';
import 'dart:ui';
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'ending_event_model.dart';
export 'ending_event_model.dart';

class EndingEventWidget extends StatefulWidget {
  const EndingEventWidget({super.key});

  static String routeName = 'Ending_Event';
  static String routePath = 'endingEvent';

  @override
  State<EndingEventWidget> createState() => _EndingEventWidgetState();
}

class _EndingEventWidgetState extends State<EndingEventWidget> {
  late EndingEventModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => EndingEventModel());
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
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        body: SafeArea(
          top: true,
          bottom: true,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Container(
                width: double.infinity,
                height: 56.0,
                decoration: BoxDecoration(
                  color: FlutterFlowTheme.of(context).secondaryBackground,
                ),
                child: Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(10.0, 0.0, 20.0, 0.0),
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
                              color: FlutterFlowTheme.of(context).extraBlack,
                              size: 24.0,
                            ),
                            onPressed: () async {
                              context.safePop();
                            },
                          ),
                          Text(
                            'Ending soon',
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  font: GoogleFonts.manrope(
                                    fontWeight: FontWeight.w600,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontStyle,
                                  ),
                                  color:
                                      FlutterFlowTheme.of(context).extraBlack,
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
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(0.0, 4.0, 0.0, 0.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: FlutterFlowTheme.of(context).secondaryBackground,
                    ),
                    child: Padding(
                      padding:
                          EdgeInsetsDirectional.fromSTEB(20.0, 8.0, 20.0, 0.0),
                      child: FutureBuilder<List<EventPageRow>>(
                        future: EventPageTable().queryRows(
                          queryFn: (q) => q
                              .eqOrNull(
                                'is_deleted',
                                false,
                              )
                              .gtOrNull(
                                'end_date_time',
                                supaSerialize<DateTime>(getCurrentTimestamp),
                              )
                              .order('end_date_time'),
                        ),
                        builder: (context, snapshot) {
                          // Customize what your widget looks like when it's loading.
                          if (!snapshot.hasData) {
                            return CompLoadingWidget(
                              name: 'eventGrid',
                            );
                          }
                          List<EventPageRow>
                              endingEventGridViewEventPageRowList =
                              snapshot.data!;

                          if (endingEventGridViewEventPageRowList.isEmpty) {
                            return CompNoDataFoundWidget(
                              pageName: 'events',
                              text1: 'No events to show',
                              text2:
                                  'Looks like no one has uploaded anything yet. Check back soon!',
                            );
                          }

                          return GridView.builder(
                            padding: EdgeInsets.fromLTRB(
                              0,
                              0,
                              0,
                              24.0,
                            ),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 10.0,
                              mainAxisSpacing: 10.0,
                              // Grid cells get TIGHT constraints, so the card's
                              // `height:` below is dead code — this ratio is the
                              // only real height lever. At 360dp: cell width
                              // (360-40-10)/2 = 155 -> 155/0.47 = 329.8dp, minus
                              // 16 padding + 120 image + 24 CTA + 16 dividers =
                              // 153.8dp for the text block, which needs 137.2dp
                              // at 12px/1.4. ~16dp of headroom.
                              childAspectRatio: 0.47,
                            ),
                            shrinkWrap: true,
                            scrollDirection: Axis.vertical,
                            itemCount:
                                endingEventGridViewEventPageRowList.length,
                            itemBuilder: (context, endingEventGridViewIndex) {
                              final endingEventGridViewEventPageRow =
                                  endingEventGridViewEventPageRowList[
                                      endingEventGridViewIndex];
                              return FutureBuilder<List<EventAttendingRow>>(
                                future: EventAttendingTable().querySingleRow(
                                  queryFn: (q) => q
                                      .eqOrNull(
                                        'event_id',
                                        endingEventGridViewEventPageRow.id,
                                      )
                                      .eqOrNull(
                                        'attending_id',
                                        currentUserUid,
                                      ),
                                ),
                                builder: (context, snapshot) {
                                  // Customize what your widget looks like when it's loading.
                                  if (!snapshot.hasData) {
                                    return CompLoadingWidget(
                                      name: 'eventCard',
                                    );
                                  }
                                  List<EventAttendingRow>
                                      containerEventAttendingRowList =
                                      snapshot.data!;

                                  final containerEventAttendingRow =
                                      containerEventAttendingRowList.isNotEmpty
                                          ? containerEventAttendingRowList.first
                                          : null;

                                  return Semantics(
                                    button: true,
                                    label:
                                        'Event: ${endingEventGridViewEventPageRow.name}. Opens event details.',
                                    child: InkWell(
                                      splashColor: FlutterFlowTheme.of(context)
                                          .primary
                                          .withAlpha(0x14),
                                      focusColor: Colors.transparent,
                                      hoverColor: Colors.transparent,
                                      highlightColor: Colors.transparent,
                                      onTap: () async {
                                        context.pushNamed(
                                          EventDetailsWidget.routeName,
                                          queryParameters: {
                                            'eventId': serializeParam(
                                              endingEventGridViewEventPageRow
                                                  .id,
                                              ParamType.String,
                                            ),
                                          }.withoutNulls,
                                        );
                                      },
                                      child: Container(
                                        height: 320.0,
                                        decoration: BoxDecoration(
                                          color: FlutterFlowTheme.of(context)
                                              .secondaryBackground,
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                          border: Border.all(
                                            color: FlutterFlowTheme.of(context)
                                                .greyL2,
                                          ),
                                        ),
                                        child: Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  8.0, 8.0, 8.0, 8.0),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.max,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Stack(
                                                alignment: AlignmentDirectional(
                                                    -1.0, 1.0),
                                                children: [
                                                  AppNetworkImage(
                                                    url:
                                                        endingEventGridViewEventPageRow
                                                            .coverImage,
                                                    width: double.infinity,
                                                    height: 120.0,
                                                    fit: BoxFit.cover,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            2.0),
                                                    semanticLabel:
                                                        'Cover photo for ${endingEventGridViewEventPageRow.name}',
                                                  ),
                                                  if (functions.endSoon(
                                                      endingEventGridViewEventPageRow
                                                          .endDateTime!))
                                                    Padding(
                                                      padding:
                                                          EdgeInsetsDirectional
                                                              .fromSTEB(
                                                                  8.0,
                                                                  0.0,
                                                                  0.0,
                                                                  8.0),
                                                      child: ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(4.0),
                                                        child: BackdropFilter(
                                                          filter:
                                                              ImageFilter.blur(
                                                            sigmaX: 2.0,
                                                            sigmaY: 2.0,
                                                          ),
                                                          child: Container(
                                                            // Min-size + padding
                                                            // so the badge label
                                                            // can grow with the
                                                            // platform font scale
                                                            // instead of clipping.
                                                            constraints:
                                                                BoxConstraints(
                                                              minWidth: 70.0,
                                                              minHeight: 18.0,
                                                            ),
                                                            padding:
                                                                EdgeInsetsDirectional
                                                                    .fromSTEB(
                                                                        6.0,
                                                                        2.0,
                                                                        6.0,
                                                                        2.0),
                                                            decoration:
                                                                BoxDecoration(
                                                              color: Color(
                                                                  0x1AFFFFFF),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          4.0),
                                                            ),
                                                            alignment:
                                                                AlignmentDirectional(
                                                                    0.0, 0.0),
                                                            child: Text(
                                                              'Ending Soon',
                                                              style: FlutterFlowTheme
                                                                      .of(context)
                                                                  .bodyMedium
                                                                  .override(
                                                                    font: GoogleFonts
                                                                        .manrope(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600,
                                                                      fontStyle: FlutterFlowTheme.of(
                                                                              context)
                                                                          .bodyMedium
                                                                          .fontStyle,
                                                                    ),
                                                                    color: Colors
                                                                        .white,
                                                                    fontSize:
                                                                        12.0,
                                                                    letterSpacing:
                                                                        0.0,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                    fontStyle: FlutterFlowTheme.of(
                                                                            context)
                                                                        .bodyMedium
                                                                        .fontStyle,
                                                                    lineHeight:
                                                                        1.4,
                                                                  ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                ],
                                              ),
                                              Expanded(
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    if ((containerEventAttendingRow
                                                                    ?.id !=
                                                                null &&
                                                            containerEventAttendingRow
                                                                    ?.id !=
                                                                '') &&
                                                        (containerEventAttendingRow
                                                                ?.isInvited ==
                                                            true) &&
                                                        (containerEventAttendingRow
                                                                ?.isAttending ==
                                                            false))
                                                      FutureBuilder<
                                                          List<
                                                              PublicUserProfileRow>>(
                                                        future:
                                                            PublicUserProfileTable()
                                                                .querySingleRow(
                                                          queryFn: (q) =>
                                                              q.eqOrNull(
                                                            'id',
                                                            containerEventAttendingRow
                                                                ?.invitedBy,
                                                          ),
                                                        ),
                                                        builder: (context,
                                                            snapshot) {
                                                          // Customize what your widget looks like when it's loading.
                                                          if (!snapshot
                                                              .hasData) {
                                                            return CompLoadingWidget(
                                                              name:
                                                                  'loadingInvite',
                                                            );
                                                          }
                                                          List<PublicUserProfileRow>
                                                              rowPublicUserProfileRowList =
                                                              snapshot.data!;

                                                          // Return an empty Container when the item does not exist.
                                                          if (snapshot
                                                              .data!.isEmpty) {
                                                            return Container();
                                                          }
                                                          final rowPublicUserProfileRow =
                                                              rowPublicUserProfileRowList
                                                                      .isNotEmpty
                                                                  ? rowPublicUserProfileRowList
                                                                      .first
                                                                  : null;

                                                          return Row(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .max,
                                                            children: [
                                                              AppNetworkImage(
                                                                url: rowPublicUserProfileRow
                                                                    ?.profilePicture,
                                                                width: 12.0,
                                                                height: 12.0,
                                                                fit: BoxFit
                                                                    .cover,
                                                                isAvatar: true,
                                                                semanticLabel:
                                                                    'Profile photo of ${rowPublicUserProfileRow?.name ?? 'a neighbour'}',
                                                              ),
                                                              Expanded(
                                                                child: Row(
                                                                  mainAxisSize:
                                                                      MainAxisSize
                                                                          .max,
                                                                  children: [
                                                                    Text(
                                                                      valueOrDefault<
                                                                          String>(
                                                                        rowPublicUserProfileRow
                                                                            ?.name,
                                                                        'name  jjhgjh jhjhjh jhjhjhj',
                                                                      ),
                                                                      style: FlutterFlowTheme.of(
                                                                              context)
                                                                          .bodyMedium
                                                                          .override(
                                                                            font:
                                                                                GoogleFonts.manrope(
                                                                              fontWeight: FontWeight.w500,
                                                                              fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                            ),
                                                                            color:
                                                                                FlutterFlowTheme.of(context).greyL4,
                                                                            fontSize:
                                                                                12.0,
                                                                            letterSpacing:
                                                                                0.0,
                                                                            fontWeight:
                                                                                FontWeight.w500,
                                                                            fontStyle:
                                                                                FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                            lineHeight:
                                                                                1.4,
                                                                          ),
                                                                    ),
                                                                    Expanded(
                                                                      child:
                                                                          Text(
                                                                        ' invited you to join this event',
                                                                        maxLines:
                                                                            1,
                                                                        style: FlutterFlowTheme.of(context)
                                                                            .bodyMedium
                                                                            .override(
                                                                              font: GoogleFonts.manrope(
                                                                                fontWeight: FontWeight.w500,
                                                                                fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                              ),
                                                                              color: FlutterFlowTheme.of(context).greyL4,
                                                                              fontSize: 12.0,
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
                                                            ].divide(SizedBox(
                                                                width: 10.0)),
                                                          );
                                                        },
                                                      ),
                                                    Column(
                                                      mainAxisSize:
                                                          MainAxisSize.max,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          endingEventGridViewEventPageRow
                                                              .name,
                                                          style: FlutterFlowTheme
                                                                  .of(context)
                                                              .bodyMedium
                                                              .override(
                                                                font: GoogleFonts
                                                                    .manrope(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  fontStyle: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMedium
                                                                      .fontStyle,
                                                                ),
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .extraBlack,
                                                                fontSize: 16.0,
                                                                letterSpacing:
                                                                    0.0,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                fontStyle: FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .fontStyle,
                                                                lineHeight: 1.4,
                                                              ),
                                                        ),
                                                        Text(
                                                          endingEventGridViewEventPageRow
                                                              .description,
                                                          maxLines:
                                                              containerEventAttendingRow
                                                                          ?.isInvited ==
                                                                      true
                                                                  ? 2
                                                                  : 3,
                                                          style: FlutterFlowTheme
                                                                  .of(context)
                                                              .bodyMedium
                                                              .override(
                                                                font: GoogleFonts
                                                                    .manrope(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  fontStyle: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMedium
                                                                      .fontStyle,
                                                                ),
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .greyL4,
                                                                fontSize: 12.0,
                                                                letterSpacing:
                                                                    0.0,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                fontStyle: FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .fontStyle,
                                                                lineHeight: 1.4,
                                                              ),
                                                        ),
                                                      ].divide(SizedBox(
                                                          height: 2.0)),
                                                    ),
                                                    Column(
                                                      mainAxisSize:
                                                          MainAxisSize.max,
                                                      children: [
                                                        Row(
                                                          mainAxisSize:
                                                              MainAxisSize.max,
                                                          children: [
                                                            ClipRRect(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          0.0),
                                                              child:
                                                                  Image.asset(
                                                                'assets/images/calendar_clock.png',
                                                                width: 16.0,
                                                                height: 16.0,
                                                                fit: BoxFit
                                                                    .cover,
                                                              ),
                                                            ),
                                                            Text(
                                                              valueOrDefault<
                                                                  String>(
                                                                functions.eventDate(
                                                                    endingEventGridViewEventPageRow
                                                                        .startDateTime),
                                                                'May 23, 6:00 PM UTC',
                                                              ),
                                                              style: FlutterFlowTheme
                                                                      .of(context)
                                                                  .bodyMedium
                                                                  .override(
                                                                    font: GoogleFonts
                                                                        .manrope(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500,
                                                                      fontStyle: FlutterFlowTheme.of(
                                                                              context)
                                                                          .bodyMedium
                                                                          .fontStyle,
                                                                    ),
                                                                    color: FlutterFlowTheme.of(
                                                                            context)
                                                                        .greyL4,
                                                                    fontSize:
                                                                        12.0,
                                                                    letterSpacing:
                                                                        0.0,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                    fontStyle: FlutterFlowTheme.of(
                                                                            context)
                                                                        .bodyMedium
                                                                        .fontStyle,
                                                                    lineHeight:
                                                                        1.4,
                                                                  ),
                                                            ),
                                                          ].divide(SizedBox(
                                                              width: 6.0)),
                                                        ),
                                                        Row(
                                                          mainAxisSize:
                                                              MainAxisSize.max,
                                                          children: [
                                                            ClipRRect(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          0.0),
                                                              child:
                                                                  Image.asset(
                                                                'assets/images/explore.png',
                                                                width: 16.0,
                                                                height: 16.0,
                                                                fit: BoxFit
                                                                    .cover,
                                                              ),
                                                            ),
                                                            Flexible(
                                                              child: Text(
                                                                valueOrDefault<
                                                                    String>(
                                                                  endingEventGridViewEventPageRow
                                                                      .address,
                                                                  'Address',
                                                                ),
                                                                style: FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .override(
                                                                      font: GoogleFonts
                                                                          .manrope(
                                                                        fontWeight:
                                                                            FontWeight.w500,
                                                                        fontStyle: FlutterFlowTheme.of(context)
                                                                            .bodyMedium
                                                                            .fontStyle,
                                                                      ),
                                                                      color: FlutterFlowTheme.of(
                                                                              context)
                                                                          .greyL4,
                                                                      fontSize:
                                                                          12.0,
                                                                      letterSpacing:
                                                                          0.0,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500,
                                                                      fontStyle: FlutterFlowTheme.of(
                                                                              context)
                                                                          .bodyMedium
                                                                          .fontStyle,
                                                                      lineHeight:
                                                                          1.4,
                                                                    ),
                                                              ),
                                                            ),
                                                          ].divide(SizedBox(
                                                              width: 6.0)),
                                                        ),
                                                        Row(
                                                          mainAxisSize:
                                                              MainAxisSize.max,
                                                          children: [
                                                            ClipRRect(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          0.0),
                                                              child:
                                                                  Image.asset(
                                                                'assets/images/crowdsource_(1).png',
                                                                width: 16.0,
                                                                height: 16.0,
                                                                fit: BoxFit
                                                                    .cover,
                                                              ),
                                                            ),
                                                            Text(
                                                              '${endingEventGridViewEventPageRow.attendeeCount.toString()} attending',
                                                              style: FlutterFlowTheme
                                                                      .of(context)
                                                                  .bodyMedium
                                                                  .override(
                                                                    font: GoogleFonts
                                                                        .manrope(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500,
                                                                      fontStyle: FlutterFlowTheme.of(
                                                                              context)
                                                                          .bodyMedium
                                                                          .fontStyle,
                                                                    ),
                                                                    color: FlutterFlowTheme.of(
                                                                            context)
                                                                        .greyL4,
                                                                    fontSize:
                                                                        12.0,
                                                                    letterSpacing:
                                                                        0.0,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                    fontStyle: FlutterFlowTheme.of(
                                                                            context)
                                                                        .bodyMedium
                                                                        .fontStyle,
                                                                    lineHeight:
                                                                        1.4,
                                                                  ),
                                                            ),
                                                          ].divide(SizedBox(
                                                              width: 6.0)),
                                                        ),
                                                      ].divide(SizedBox(
                                                          height: 4.0)),
                                                    ),
                                                  ].divide(
                                                      SizedBox(height: 4.0)),
                                                ),
                                              ),
                                              if (endingEventGridViewEventPageRow
                                                      .adminUser !=
                                                  currentUserUid)
                                                Stack(
                                                  children: [
                                                    FFButtonWidget(
                                                      onPressed: () async {
                                                        await EventAttendingTable()
                                                            .insert({
                                                          'community_id':
                                                              endingEventGridViewEventPageRow
                                                                  .communityId,
                                                          'event_id':
                                                              endingEventGridViewEventPageRow
                                                                  .id,
                                                          'attending_id':
                                                              currentUserUid,
                                                          'is_invited': false,
                                                          'is_attending': true,
                                                        });
                                                        _model.apiResultrykmlk =
                                                            await UpdateEventAttendeeCountCall
                                                                .call(
                                                          token:
                                                              currentJwtToken,
                                                          eventId:
                                                              endingEventGridViewEventPageRow
                                                                  .id,
                                                        );

                                                        safeSetState(() {});
                                                      },
                                                      text: 'Attend',
                                                      icon: Icon(
                                                        Icons
                                                            .edit_calendar_outlined,
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .primaryD3,
                                                        size: 15.0,
                                                      ),
                                                      options: FFButtonOptions(
                                                        width: double.infinity,
                                                        height: 24.0,
                                                        padding:
                                                            EdgeInsetsDirectional
                                                                .fromSTEB(
                                                                    16.0,
                                                                    0.0,
                                                                    16.0,
                                                                    0.0),
                                                        iconPadding:
                                                            EdgeInsetsDirectional
                                                                .fromSTEB(
                                                                    0.0,
                                                                    0.0,
                                                                    0.0,
                                                                    0.0),
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .white,
                                                        textStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .titleSmall
                                                                .override(
                                                                  font: GoogleFonts
                                                                      .manrope(
                                                                    fontWeight: FlutterFlowTheme.of(
                                                                            context)
                                                                        .titleSmall
                                                                        .fontWeight,
                                                                    fontStyle: FlutterFlowTheme.of(
                                                                            context)
                                                                        .titleSmall
                                                                        .fontStyle,
                                                                  ),
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .primaryD3,
                                                                  fontSize:
                                                                      12.0,
                                                                  letterSpacing:
                                                                      0.0,
                                                                  fontWeight: FlutterFlowTheme.of(
                                                                          context)
                                                                      .titleSmall
                                                                      .fontWeight,
                                                                  fontStyle: FlutterFlowTheme.of(
                                                                          context)
                                                                      .titleSmall
                                                                      .fontStyle,
                                                                ),
                                                        elevation: 0.0,
                                                        borderSide: BorderSide(
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .primaryD3,
                                                          width: 1.0,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius.only(
                                                          topLeft:
                                                              Radius.circular(
                                                                  100.0),
                                                          topRight:
                                                              Radius.circular(
                                                                  100.0),
                                                          bottomLeft:
                                                              Radius.circular(
                                                                  100.0),
                                                          bottomRight:
                                                              Radius.circular(
                                                                  100.0),
                                                        ),
                                                      ),
                                                    ),
                                                    if ((containerEventAttendingRow
                                                                    ?.id !=
                                                                null &&
                                                            containerEventAttendingRow
                                                                    ?.id !=
                                                                '') &&
                                                        (containerEventAttendingRow
                                                                ?.isAttending ==
                                                            false))
                                                      FFButtonWidget(
                                                        onPressed: () async {
                                                          await EventAttendingTable()
                                                              .update(
                                                            data: {
                                                              'is_attending':
                                                                  true,
                                                            },
                                                            matchingRows:
                                                                (rows) => rows
                                                                    .eqOrNull(
                                                                      'event_id',
                                                                      endingEventGridViewEventPageRow
                                                                          .id,
                                                                    )
                                                                    .eqOrNull(
                                                                      'attending_id',
                                                                      currentUserUid,
                                                                    ),
                                                          );
                                                          _model.apiResultryklop =
                                                              await UpdateEventAttendeeCountCall
                                                                  .call(
                                                            token:
                                                                currentJwtToken,
                                                            eventId:
                                                                endingEventGridViewEventPageRow
                                                                    .id,
                                                          );

                                                          safeSetState(() {});
                                                        },
                                                        text: 'Attend',
                                                        icon: Icon(
                                                          Icons
                                                              .edit_calendar_outlined,
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .primaryD3,
                                                          size: 15.0,
                                                        ),
                                                        options:
                                                            FFButtonOptions(
                                                          width:
                                                              double.infinity,
                                                          height: 24.0,
                                                          padding:
                                                              EdgeInsetsDirectional
                                                                  .fromSTEB(
                                                                      16.0,
                                                                      0.0,
                                                                      16.0,
                                                                      0.0),
                                                          iconPadding:
                                                              EdgeInsetsDirectional
                                                                  .fromSTEB(
                                                                      0.0,
                                                                      0.0,
                                                                      0.0,
                                                                      0.0),
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .white,
                                                          textStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .titleSmall
                                                                  .override(
                                                                    font: GoogleFonts
                                                                        .manrope(
                                                                      fontWeight: FlutterFlowTheme.of(
                                                                              context)
                                                                          .titleSmall
                                                                          .fontWeight,
                                                                      fontStyle: FlutterFlowTheme.of(
                                                                              context)
                                                                          .titleSmall
                                                                          .fontStyle,
                                                                    ),
                                                                    color: FlutterFlowTheme.of(
                                                                            context)
                                                                        .primaryD3,
                                                                    fontSize:
                                                                        12.0,
                                                                    letterSpacing:
                                                                        0.0,
                                                                    fontWeight: FlutterFlowTheme.of(
                                                                            context)
                                                                        .titleSmall
                                                                        .fontWeight,
                                                                    fontStyle: FlutterFlowTheme.of(
                                                                            context)
                                                                        .titleSmall
                                                                        .fontStyle,
                                                                  ),
                                                          elevation: 0.0,
                                                          borderSide:
                                                              BorderSide(
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .primaryD3,
                                                            width: 1.0,
                                                          ),
                                                          borderRadius:
                                                              BorderRadius.only(
                                                            topLeft:
                                                                Radius.circular(
                                                                    100.0),
                                                            topRight:
                                                                Radius.circular(
                                                                    100.0),
                                                            bottomLeft:
                                                                Radius.circular(
                                                                    100.0),
                                                            bottomRight:
                                                                Radius.circular(
                                                                    100.0),
                                                          ),
                                                        ),
                                                      ),
                                                    if ((containerEventAttendingRow
                                                                    ?.id !=
                                                                null &&
                                                            containerEventAttendingRow
                                                                    ?.id !=
                                                                '') &&
                                                        (containerEventAttendingRow
                                                                ?.isAttending ==
                                                            true))
                                                      FFButtonWidget(
                                                        onPressed: () async {
                                                          await EventAttendingTable()
                                                              .update(
                                                            data: {
                                                              'is_attending':
                                                                  false,
                                                            },
                                                            matchingRows:
                                                                (rows) => rows
                                                                    .eqOrNull(
                                                                      'event_id',
                                                                      endingEventGridViewEventPageRow
                                                                          .id,
                                                                    )
                                                                    .eqOrNull(
                                                                      'attending_id',
                                                                      currentUserUid,
                                                                    ),
                                                          );
                                                          _model.apiResultrykkl =
                                                              await UpdateEventAttendeeCountCall
                                                                  .call(
                                                            token:
                                                                currentJwtToken,
                                                            eventId:
                                                                endingEventGridViewEventPageRow
                                                                    .id,
                                                          );

                                                          safeSetState(() {});
                                                        },
                                                        text: 'Attending',
                                                        icon: Icon(
                                                          Icons
                                                              .edit_calendar_outlined,
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .greyL4,
                                                          size: 15.0,
                                                        ),
                                                        options:
                                                            FFButtonOptions(
                                                          width:
                                                              double.infinity,
                                                          height: 24.0,
                                                          padding:
                                                              EdgeInsetsDirectional
                                                                  .fromSTEB(
                                                                      16.0,
                                                                      0.0,
                                                                      16.0,
                                                                      0.0),
                                                          iconPadding:
                                                              EdgeInsetsDirectional
                                                                  .fromSTEB(
                                                                      0.0,
                                                                      0.0,
                                                                      0.0,
                                                                      0.0),
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .white,
                                                          textStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .titleSmall
                                                                  .override(
                                                                    font: GoogleFonts
                                                                        .manrope(
                                                                      fontWeight: FlutterFlowTheme.of(
                                                                              context)
                                                                          .titleSmall
                                                                          .fontWeight,
                                                                      fontStyle: FlutterFlowTheme.of(
                                                                              context)
                                                                          .titleSmall
                                                                          .fontStyle,
                                                                    ),
                                                                    color: FlutterFlowTheme.of(
                                                                            context)
                                                                        .greyL4,
                                                                    fontSize:
                                                                        12.0,
                                                                    letterSpacing:
                                                                        0.0,
                                                                    fontWeight: FlutterFlowTheme.of(
                                                                            context)
                                                                        .titleSmall
                                                                        .fontWeight,
                                                                    fontStyle: FlutterFlowTheme.of(
                                                                            context)
                                                                        .titleSmall
                                                                        .fontStyle,
                                                                  ),
                                                          elevation: 0.0,
                                                          borderSide:
                                                              BorderSide(
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .greyL4,
                                                            width: 1.0,
                                                          ),
                                                          borderRadius:
                                                              BorderRadius.only(
                                                            topLeft:
                                                                Radius.circular(
                                                                    100.0),
                                                            topRight:
                                                                Radius.circular(
                                                                    100.0),
                                                            bottomLeft:
                                                                Radius.circular(
                                                                    100.0),
                                                            bottomRight:
                                                                Radius.circular(
                                                                    100.0),
                                                          ),
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                            ].divide(SizedBox(height: 8.0)),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              )
                                  .animate()
                                  .fadeIn(
                                      duration: 260.ms,
                                      delay:
                                          (40 * (endingEventGridViewIndex % 8))
                                              .ms)
                                  .slideY(
                                      begin: 0.06,
                                      end: 0,
                                      curve: Curves.easeOutCubic);
                            },
                          );
                        },
                      ),
                    ),
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
