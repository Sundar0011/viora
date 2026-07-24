// message_page_widget.dart
// Flock message thread: realtime message list, image attachments, block/unblock
// banners and the composer. Icon-only controls route through AppIconButton so
// they carry a screen-reader label and a >=44dp tap target; remote images route
// through AppNetworkImage; the "no messages yet" branch uses the shared EmptyState.
import '/auth/supabase_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/backend/supabase/supabase.dart';
import '/components/app_icon_button.dart';
import '/components/app_network_image.dart';
import '/components/empty_state.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/upload_data.dart';
import '/pages/group/comp_unblock_user/comp_unblock_user_widget.dart';
import '/pages/home/comp_loading/comp_loading_widget.dart';
import '/pages/home/comp_three_dot_block_user/comp_three_dot_block_user_widget.dart';
import 'dart:ui';
import '/custom_code/actions/index.dart' as actions;
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';
import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'message_page_model.dart';
export 'message_page_model.dart';

class MessagePageWidget extends StatefulWidget {
  const MessagePageWidget({
    super.key,
    required this.chatId,
    required this.userId,
    this.previousName,
  });

  final String? chatId;
  final String? userId;
  final String? previousName;

  static String routeName = 'MessagePage';
  static String routePath = 'messagePage';

  @override
  State<MessagePageWidget> createState() => _MessagePageWidgetState();
}

class _MessagePageWidgetState extends State<MessagePageWidget> {
  late MessagePageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => MessagePageModel());

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      await actions.subscribeToMessagesAndMarkAsRead(
        widget!.chatId!,
        currentUserUid,
      );
      await actions.unsubscribe(
        'messages',
      );
      await Future.delayed(
        Duration(
          milliseconds: 1000,
        ),
      );
      await actions.subscribe(
        'messages',
        () async {
          safeSetState(() => _model.requestCompleter = null);
          await _model.waitForRequestCompleted();
          await _model.columnController?.animateTo(
            _model.columnController!.position.maxScrollExtent,
            duration: Duration(milliseconds: 100),
            curve: Curves.ease,
          );
        },
      );
      safeSetState(() => _model.requestCompleter = null);
      await _model.waitForRequestCompleted();
      await _model.columnController?.animateTo(
        _model.columnController!.position.maxScrollExtent,
        duration: Duration(milliseconds: 500),
        curve: Curves.ease,
      );
    });

    _model.textController ??= TextEditingController();
    _model.textFieldFocusNode ??= FocusNode();
  }

  @override
  void dispose() {
    // On page dispose action.
    () async {
      await actions.cancelMessageSubscription(
        widget!.chatId!,
      );
    }();

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
        backgroundColor: FlutterFlowTheme.of(context).white,
        body: SafeArea(
          top: true,
          bottom: true,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              if (!_model.selectImage)
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: FlutterFlowTheme.of(context).white,
                        ),
                        child: Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              0.0, 12.0, 0.0, 12.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              // FlutterFlowIconButton already meets the 48dp
                              // IconButton minimum; it just has no label.
                              Semantics(
                                label: 'Back',
                                button: true,
                                child: FlutterFlowIconButton(
                                  borderRadius: 100.0,
                                  icon: Icon(
                                    Icons.arrow_back,
                                    color:
                                        FlutterFlowTheme.of(context).extraBlack,
                                    size: 24.0,
                                  ),
                                  onPressed: () async {
                                    if (widget!.previousName == 'loading') {
                                      context.pushNamed(
                                        ChatWidget.routeName,
                                        queryParameters: {
                                          'selectMessage': serializeParam(
                                            false,
                                            ParamType.bool,
                                          ),
                                          'previousPage': serializeParam(
                                            'loading',
                                            ParamType.String,
                                          ),
                                        }.withoutNulls,
                                      );

                                      await actions.cancelMessageSubscription(
                                        widget!.chatId!,
                                      );
                                    } else {
                                      if (widget!.previousName == 'chat') {
                                        _model.userChat12 =
                                            await GetChatCall.call(
                                          apiKey:
                                              FFDevEnvironmentValues().AnonKey,
                                          token: currentJwtToken,
                                          searchQuery: ' ',
                                        );

                                        FFAppState().matchedUsers =
                                            getJsonField(
                                          (_model.userChat12?.jsonBody ?? ''),
                                          r'''$''',
                                        );
                                        safeSetState(() {});
                                        context.safePop();
                                        await actions.cancelMessageSubscription(
                                          widget!.chatId!,
                                        );
                                      } else {
                                        context.safePop();
                                        await actions.cancelMessageSubscription(
                                          widget!.chatId!,
                                        );
                                      }
                                    }

                                    safeSetState(() {});
                                  },
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  height: 36.0,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4.0),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        0.0, 0.0, 10.0, 0.0),
                                    child: FutureBuilder<
                                        List<PublicUserProfileRow>>(
                                      future: PublicUserProfileTable()
                                          .querySingleRow(
                                        queryFn: (q) => q.eqOrNull(
                                          'id',
                                          widget!.userId,
                                        ),
                                      ),
                                      builder: (context, snapshot) {
                                        // Customize what your widget looks like when it's loading.
                                        if (!snapshot.hasData) {
                                          return CompLoadingWidget(
                                            name: 'profile',
                                          );
                                        }
                                        List<PublicUserProfileRow>
                                            rowPublicUserProfileRowList =
                                            snapshot.data!;

                                        final rowPublicUserProfileRow =
                                            rowPublicUserProfileRowList
                                                    .isNotEmpty
                                                ? rowPublicUserProfileRowList
                                                    .first
                                                : null;

                                        return Row(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Align(
                                              alignment: AlignmentDirectional(
                                                  0.0, -1.0),
                                              child: AppNetworkImage(
                                                url: rowPublicUserProfileRow
                                                    ?.profilePicture,
                                                width: 32.0,
                                                height: 32.0,
                                                isAvatar: true,
                                                semanticLabel:
                                                    '${valueOrDefault<String>(
                                                  rowPublicUserProfileRow?.name,
                                                  'Neighbour',
                                                )}\'s profile photo',
                                              ),
                                            ),
                                            Expanded(
                                              child: Text(
                                                valueOrDefault<String>(
                                                  rowPublicUserProfileRow?.name,
                                                  'name',
                                                ),
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
                                                      fontSize: 16.0,
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
                                            ),
                                            // Conversation options (report /
                                            // block). Visual disc stays 34dp;
                                            // only the hit area grows to 44dp.
                                            AppIconButton(
                                              semanticLabel:
                                                  'Conversation options',
                                              tooltip: 'Conversation options',
                                              iconSize: 16.0,
                                              iconWidget: Container(
                                                width: 34.0,
                                                height: 34.0,
                                                decoration: BoxDecoration(
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .greyL2,
                                                  borderRadius:
                                                      BorderRadius.only(
                                                    topLeft:
                                                        Radius.circular(100.0),
                                                    topRight:
                                                        Radius.circular(100.0),
                                                    bottomLeft:
                                                        Radius.circular(100.0),
                                                    bottomRight:
                                                        Radius.circular(100.0),
                                                  ),
                                                ),
                                                alignment: AlignmentDirectional(
                                                    0.0, 0.0),
                                                child: Transform.rotate(
                                                  angle: 90.0 * (math.pi / 180),
                                                  child: Icon(
                                                    Icons.keyboard_control,
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .primaryText,
                                                    size: 16.0,
                                                  ),
                                                ),
                                              ),
                                              onTap: () async {
                                                await showModalBottomSheet(
                                                  isScrollControlled: true,
                                                  backgroundColor:
                                                      Colors.transparent,
                                                  context: context,
                                                  builder: (context) {
                                                    return GestureDetector(
                                                      onTap: () {
                                                        FocusScope.of(context)
                                                            .unfocus();
                                                        FocusManager.instance
                                                            .primaryFocus
                                                            ?.unfocus();
                                                      },
                                                      child: Padding(
                                                        padding: MediaQuery
                                                            .viewInsetsOf(
                                                                context),
                                                        child:
                                                            CompThreeDotBlockUserWidget(
                                                          reportedByUserId:
                                                              currentUserUid,
                                                          reportedUserId:
                                                              widget!.userId!,
                                                          blockedUserName:
                                                              rowPublicUserProfileRow!
                                                                  .name!,
                                                          reportType: 'message',
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ).then((value) =>
                                                    safeSetState(() {}));
                                              },
                                            ),
                                          ].divide(SizedBox(width: 8.0)),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ]
                                .addToStart(SizedBox(width: 10.0))
                                .addToEnd(SizedBox(width: 20.0)),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: FlutterFlowTheme.of(context).greyL2,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Expanded(
                                child: SingleChildScrollView(
                                  primary: false,
                                  controller: _model.columnController,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      FutureBuilder<List<MessagesRow>>(
                                        future: (_model.requestCompleter ??=
                                                Completer<List<MessagesRow>>()
                                                  ..complete(
                                                      MessagesTable().queryRows(
                                                    queryFn: (q) => q
                                                        .eqOrNull(
                                                          'chat_id',
                                                          widget!.chatId,
                                                        )
                                                        .order('created_at',
                                                            ascending: true),
                                                  )))
                                            .future,
                                        builder: (context, snapshot) {
                                          // Customize what your widget looks like when it's loading.
                                          if (!snapshot.hasData) {
                                            return CompLoadingWidget(
                                              name: 'chat',
                                            );
                                          }
                                          List<MessagesRow>
                                              listViewMessagesRowList =
                                              snapshot.data!;

                                          return ListView.separated(
                                            padding: EdgeInsets.fromLTRB(
                                              0,
                                              32.0,
                                              0,
                                              32.0,
                                            ),
                                            primary: false,
                                            shrinkWrap: true,
                                            scrollDirection: Axis.vertical,
                                            itemCount:
                                                listViewMessagesRowList.length,
                                            separatorBuilder: (_, __) =>
                                                SizedBox(height: 8.0),
                                            itemBuilder:
                                                (context, listViewIndex) {
                                              final listViewMessagesRow =
                                                  listViewMessagesRowList[
                                                      listViewIndex];
                                              return Padding(
                                                padding: EdgeInsetsDirectional
                                                    .fromSTEB(
                                                        20.0, 0.0, 20.0, 0.0),
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Stack(
                                                      children: [
                                                        if ((listViewMessagesRow
                                                                    .senderId !=
                                                                currentUserUid) &&
                                                            (listViewMessagesRow
                                                                    .eMessageType ==
                                                                'text'))
                                                          Container(
                                                            decoration:
                                                                BoxDecoration(
                                                              color: FlutterFlowTheme
                                                                      .of(context)
                                                                  .secondaryBackground,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          4.0),
                                                            ),
                                                            child: Padding(
                                                              padding:
                                                                  EdgeInsetsDirectional
                                                                      .fromSTEB(
                                                                          8.0,
                                                                          8.0,
                                                                          8.0,
                                                                          8.0),
                                                              child: Column(
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .max,
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  InkWell(
                                                                    splashColor:
                                                                        Colors
                                                                            .transparent,
                                                                    focusColor:
                                                                        Colors
                                                                            .transparent,
                                                                    hoverColor:
                                                                        Colors
                                                                            .transparent,
                                                                    highlightColor:
                                                                        Colors
                                                                            .transparent,
                                                                    onTap:
                                                                        () async {
                                                                      if (listViewMessagesRow
                                                                              .islink ==
                                                                          true) {
                                                                        await launchURL(
                                                                            listViewMessagesRow.message);
                                                                      }
                                                                    },
                                                                    child: Text(
                                                                      listViewMessagesRow
                                                                          .message,
                                                                      style: FlutterFlowTheme.of(
                                                                              context)
                                                                          .bodyMedium
                                                                          .override(
                                                                            font:
                                                                                GoogleFonts.manrope(
                                                                              fontWeight: FontWeight.w500,
                                                                              fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                            ),
                                                                            color: listViewMessagesRow.islink == true
                                                                                ? FlutterFlowTheme.of(context).primary
                                                                                : FlutterFlowTheme.of(context).extraBlack,
                                                                            letterSpacing:
                                                                                0.0,
                                                                            fontWeight:
                                                                                FontWeight.w500,
                                                                            fontStyle:
                                                                                FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                            lineHeight:
                                                                                1.3,
                                                                          ),
                                                                    ),
                                                                  ),
                                                                  Container(
                                                                    width:
                                                                        100.0,
                                                                    decoration:
                                                                        BoxDecoration(),
                                                                    child: Text(
                                                                      dateTimeFormat(
                                                                          "jm",
                                                                          listViewMessagesRow
                                                                              .createdAt),
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
                                                                                FlutterFlowTheme.of(context).greyL5,
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
                                                                  ),
                                                                ].divide(SizedBox(
                                                                    height:
                                                                        6.0)),
                                                              ),
                                                            ),
                                                          ),
                                                        if ((listViewMessagesRow
                                                                    .senderId !=
                                                                currentUserUid) &&
                                                            (listViewMessagesRow
                                                                    .eMessageType ==
                                                                'image'))
                                                          Align(
                                                            alignment:
                                                                AlignmentDirectional(
                                                                    -1.0, 0.0),
                                                            child: Padding(
                                                              padding:
                                                                  EdgeInsetsDirectional
                                                                      .fromSTEB(
                                                                          0.0,
                                                                          0.0,
                                                                          100.0,
                                                                          0.0),
                                                              child: Container(
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .white,
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              4.0),
                                                                ),
                                                                child: Padding(
                                                                  padding: EdgeInsetsDirectional
                                                                      .fromSTEB(
                                                                          2.0,
                                                                          2.0,
                                                                          2.0,
                                                                          2.0),
                                                                  child: Stack(
                                                                    alignment:
                                                                        AlignmentDirectional(
                                                                            1.0,
                                                                            1.0),
                                                                    children: [
                                                                      if ((listViewMessagesRow.senderId !=
                                                                              currentUserUid) &&
                                                                          (listViewMessagesRow.eMessageType ==
                                                                              'image'))
                                                                        AppNetworkImage(
                                                                          url: listViewMessagesRow
                                                                              .fileUrl,
                                                                          borderRadius:
                                                                              BorderRadius.circular(4.0),
                                                                          semanticLabel:
                                                                              'Photo received',
                                                                        ),
                                                                      Padding(
                                                                        padding: EdgeInsetsDirectional.fromSTEB(
                                                                            4.0,
                                                                            0.0,
                                                                            0.0,
                                                                            4.0),
                                                                        child:
                                                                            Row(
                                                                          mainAxisSize:
                                                                              MainAxisSize.max,
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.spaceBetween,
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.end,
                                                                          children: [
                                                                            AppIconButton(
                                                                              icon: Icons.downloading_rounded,
                                                                              semanticLabel: 'Download photo',
                                                                              tooltip: 'Download',
                                                                              iconSize: 24.0,
                                                                              color: FlutterFlowTheme.of(context).greyL4,
                                                                              onTap: () async {
                                                                                await downloadFile(
                                                                                  filename: 'image',
                                                                                  url: valueOrDefault<String>(
                                                                                    listViewMessagesRow.fileUrl,
                                                                                    'no',
                                                                                  ),
                                                                                );
                                                                              },
                                                                            ),
                                                                            Padding(
                                                                              padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 4.0, 0.0),
                                                                              child: Text(
                                                                                dateTimeFormat("jm", listViewMessagesRow.createdAt),
                                                                                style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                      font: GoogleFonts.manrope(
                                                                                        fontWeight: FontWeight.w500,
                                                                                        fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                      ),
                                                                                      color: Colors.white,
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
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                      ],
                                                    ),
                                                    Stack(
                                                      children: [
                                                        if ((listViewMessagesRow
                                                                    .senderId ==
                                                                currentUserUid) &&
                                                            (listViewMessagesRow
                                                                    .eMessageType ==
                                                                'text'))
                                                          Align(
                                                            alignment:
                                                                AlignmentDirectional(
                                                                    1.0, 0.0),
                                                            child: Container(
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .primaryL1,
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            4.0),
                                                              ),
                                                              child: Padding(
                                                                padding:
                                                                    EdgeInsetsDirectional
                                                                        .fromSTEB(
                                                                            8.0,
                                                                            8.0,
                                                                            8.0,
                                                                            8.0),
                                                                child: Column(
                                                                  mainAxisSize:
                                                                      MainAxisSize
                                                                          .max,
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .end,
                                                                  children: [
                                                                    InkWell(
                                                                      splashColor:
                                                                          Colors
                                                                              .transparent,
                                                                      focusColor:
                                                                          Colors
                                                                              .transparent,
                                                                      hoverColor:
                                                                          Colors
                                                                              .transparent,
                                                                      highlightColor:
                                                                          Colors
                                                                              .transparent,
                                                                      onTap:
                                                                          () async {
                                                                        if (listViewMessagesRow.islink ==
                                                                            true) {
                                                                          await launchURL(
                                                                              listViewMessagesRow.message);
                                                                        }
                                                                      },
                                                                      child:
                                                                          Text(
                                                                        listViewMessagesRow
                                                                            .message,
                                                                        style: FlutterFlowTheme.of(context)
                                                                            .bodyMedium
                                                                            .override(
                                                                              font: GoogleFonts.manrope(
                                                                                fontWeight: FontWeight.w500,
                                                                                fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                              ),
                                                                              color: listViewMessagesRow.islink == true ? FlutterFlowTheme.of(context).primary : FlutterFlowTheme.of(context).extraBlack,
                                                                              letterSpacing: 0.0,
                                                                              fontWeight: FontWeight.w500,
                                                                              fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                              lineHeight: 1.3,
                                                                            ),
                                                                      ),
                                                                    ),
                                                                    Container(
                                                                      width:
                                                                          100.0,
                                                                      decoration:
                                                                          BoxDecoration(),
                                                                      child:
                                                                          Row(
                                                                        mainAxisSize:
                                                                            MainAxisSize.max,
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.end,
                                                                        children:
                                                                            [
                                                                          Text(
                                                                            dateTimeFormat("jm",
                                                                                listViewMessagesRow.createdAt),
                                                                            style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                  font: GoogleFonts.manrope(
                                                                                    fontWeight: FontWeight.w500,
                                                                                    fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                  ),
                                                                                  color: FlutterFlowTheme.of(context).greyL5,
                                                                                  fontSize: 12.0,
                                                                                  letterSpacing: 0.0,
                                                                                  fontWeight: FontWeight.w500,
                                                                                  fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                  lineHeight: 1.4,
                                                                                ),
                                                                          ),
                                                                          Stack(
                                                                            children: [
                                                                              if (listViewMessagesRow.isRead)
                                                                                Icon(
                                                                                  Icons.done_all,
                                                                                  color: FlutterFlowTheme.of(context).primary,
                                                                                  size: 16.0,
                                                                                ),
                                                                              if (!listViewMessagesRow.isRead)
                                                                                Icon(
                                                                                  Icons.done_sharp,
                                                                                  color: FlutterFlowTheme.of(context).primary,
                                                                                  size: 16.0,
                                                                                ),
                                                                            ],
                                                                          ),
                                                                        ].divide(SizedBox(width: 2.0)),
                                                                      ),
                                                                    ),
                                                                  ].divide(SizedBox(
                                                                      height:
                                                                          6.0)),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        if ((listViewMessagesRow
                                                                    .senderId ==
                                                                currentUserUid) &&
                                                            (listViewMessagesRow
                                                                    .eMessageType ==
                                                                'image'))
                                                          Align(
                                                            alignment:
                                                                AlignmentDirectional(
                                                                    1.0, 0.0),
                                                            child: Padding(
                                                              padding:
                                                                  EdgeInsetsDirectional
                                                                      .fromSTEB(
                                                                          100.0,
                                                                          0.0,
                                                                          0.0,
                                                                          0.0),
                                                              child: Container(
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .white,
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              4.0),
                                                                ),
                                                                child: Padding(
                                                                  padding: EdgeInsetsDirectional
                                                                      .fromSTEB(
                                                                          2.0,
                                                                          2.0,
                                                                          2.0,
                                                                          2.0),
                                                                  child: Stack(
                                                                    alignment:
                                                                        AlignmentDirectional(
                                                                            1.0,
                                                                            1.0),
                                                                    children: [
                                                                      if ((listViewMessagesRow.senderId ==
                                                                              currentUserUid) &&
                                                                          (listViewMessagesRow.eMessageType ==
                                                                              'image'))
                                                                        AppNetworkImage(
                                                                          url: listViewMessagesRow
                                                                              .fileUrl,
                                                                          borderRadius:
                                                                              BorderRadius.circular(4.0),
                                                                          semanticLabel:
                                                                              'Photo you sent',
                                                                        ),
                                                                      Container(
                                                                        constraints:
                                                                            BoxConstraints(
                                                                          minWidth:
                                                                              100.0,
                                                                        ),
                                                                        decoration:
                                                                            BoxDecoration(),
                                                                        alignment: AlignmentDirectional(
                                                                            1.0,
                                                                            0.0),
                                                                        child:
                                                                            Padding(
                                                                          padding: EdgeInsetsDirectional.fromSTEB(
                                                                              4.0,
                                                                              0.0,
                                                                              4.0,
                                                                              4.0),
                                                                          child:
                                                                              Row(
                                                                            mainAxisSize:
                                                                                MainAxisSize.max,
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.spaceBetween,
                                                                            crossAxisAlignment:
                                                                                CrossAxisAlignment.end,
                                                                            children:
                                                                                [
                                                                              AppIconButton(
                                                                                icon: Icons.downloading_rounded,
                                                                                semanticLabel: 'Download photo',
                                                                                tooltip: 'Download',
                                                                                iconSize: 24.0,
                                                                                color: FlutterFlowTheme.of(context).greyL4,
                                                                                onTap: () async {
                                                                                  await downloadFile(
                                                                                    filename: 'image',
                                                                                    url: valueOrDefault<String>(
                                                                                      listViewMessagesRow.fileUrl,
                                                                                      'no',
                                                                                    ),
                                                                                  );
                                                                                },
                                                                              ),
                                                                              Row(
                                                                                mainAxisSize: MainAxisSize.max,
                                                                                children: [
                                                                                  Text(
                                                                                    dateTimeFormat("jm", listViewMessagesRow.createdAt),
                                                                                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                          font: GoogleFonts.manrope(
                                                                                            fontWeight: FontWeight.w500,
                                                                                            fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                          ),
                                                                                          color: Colors.white,
                                                                                          fontSize: 12.0,
                                                                                          letterSpacing: 0.0,
                                                                                          fontWeight: FontWeight.w500,
                                                                                          fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                          lineHeight: 1.4,
                                                                                        ),
                                                                                  ),
                                                                                  Stack(
                                                                                    children: [
                                                                                      if (listViewMessagesRow.isRead)
                                                                                        Icon(
                                                                                          Icons.done_all,
                                                                                          color: FlutterFlowTheme.of(context).primary,
                                                                                          size: 16.0,
                                                                                        ),
                                                                                      if (!listViewMessagesRow.isRead)
                                                                                        Icon(
                                                                                          Icons.done_sharp,
                                                                                          color: FlutterFlowTheme.of(context).primary,
                                                                                          size: 16.0,
                                                                                        ),
                                                                                    ],
                                                                                  ),
                                                                                ].divide(SizedBox(width: 2.0)),
                                                                              ),
                                                                            ].divide(SizedBox(width: 2.0)),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                      ],
                                                    ),
                                                  ].divide(
                                                      SizedBox(height: 12.0)),
                                                ),
                                              );
                                            },
                                            controller:
                                                _model.listViewController,
                                          );
                                        },
                                      ),
                                    ].addToEnd(SizedBox(height: 60.0)),
                                  ),
                                ),
                              ),
                              FutureBuilder<List<MessagesRow>>(
                                future: MessagesTable().querySingleRow(
                                  queryFn: (q) => q.eqOrNull(
                                    'chat_id',
                                    widget!.chatId,
                                  ),
                                ),
                                builder: (context, snapshot) {
                                  // Customize what your widget looks like when it's loading.
                                  if (!snapshot.hasData) {
                                    return CompLoadingWidget(
                                      name: 'noChat',
                                    );
                                  }
                                  List<MessagesRow> containerMessagesRowList =
                                      snapshot.data!;

                                  final containerMessagesRow =
                                      containerMessagesRowList.isNotEmpty
                                          ? containerMessagesRowList.first
                                          : null;

                                  return Container(
                                    decoration: BoxDecoration(),
                                    child: Visibility(
                                      visible:
                                          containerMessagesRow?.id == null ||
                                              containerMessagesRow?.id == '',
                                      // Empty thread. Compact so it sits above
                                      // the composer without pushing it off.
                                      child: EmptyState(
                                        compact: true,
                                        icon: Icons.waving_hand_outlined,
                                        title: 'No messages yet',
                                        body:
                                            'Say hi, drop a message, or just send a 👋 to get things going.',
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      Stack(
                        children: [
                          Container(
                            width: double.infinity,
                            height: 66.0,
                            decoration: BoxDecoration(
                              color: FlutterFlowTheme.of(context)
                                  .secondaryBackground,
                            ),
                            child: Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  16.0, 0.0, 16.0, 0.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  AppIconButton(
                                    icon: Icons.add,
                                    semanticLabel: 'Attach a photo',
                                    tooltip: 'Attach a photo',
                                    iconSize: 24.0,
                                    color: FlutterFlowTheme.of(context).greyL5,
                                    onTap: () async {
                                      final selectedMedia =
                                          await selectMediaWithSourceBottomSheet(
                                        context: context,
                                        allowPhoto: true,
                                      );
                                      if (selectedMedia != null &&
                                          selectedMedia.every((m) =>
                                              validateFileFormat(
                                                  m.storagePath, context))) {
                                        safeSetState(() => _model
                                                .isDataUploading_uploadDataIvk =
                                            true);
                                        var selectedUploadedFiles =
                                            <FFUploadedFile>[];

                                        try {
                                          selectedUploadedFiles = selectedMedia
                                              .map((m) => FFUploadedFile(
                                                    name: m.storagePath
                                                        .split('/')
                                                        .last,
                                                    bytes: m.bytes,
                                                    height:
                                                        m.dimensions?.height,
                                                    width: m.dimensions?.width,
                                                    blurHash: m.blurHash,
                                                    originalFilename:
                                                        m.originalFilename,
                                                  ))
                                              .toList();
                                        } finally {
                                          _model.isDataUploading_uploadDataIvk =
                                              false;
                                        }
                                        if (selectedUploadedFiles.length ==
                                            selectedMedia.length) {
                                          safeSetState(() {
                                            _model.uploadedLocalFile_uploadDataIvk =
                                                selectedUploadedFiles.first;
                                          });
                                        } else {
                                          safeSetState(() {});
                                          return;
                                        }
                                      }

                                      if (_model.uploadedLocalFile_uploadDataIvk !=
                                              null &&
                                          (_model.uploadedLocalFile_uploadDataIvk
                                                  .bytes?.isNotEmpty ??
                                              false)) {
                                        _model.selectImage = true;
                                        safeSetState(() {});
                                      } else {
                                        _model.selectImage = false;
                                        safeSetState(() {});
                                      }
                                    },
                                  ),
                                  Expanded(
                                    child: Container(
                                      width: double.infinity,
                                      child: TextFormField(
                                        controller: _model.textController,
                                        focusNode: _model.textFieldFocusNode,
                                        onFieldSubmitted: (_) async {
                                          _model.valid =
                                              await actions.isMessageValid(
                                            _model.textController.text,
                                          );
                                          if (_model.valid == true) {
                                            await MessagesTable().insert({
                                              'chat_id': widget!.chatId,
                                              'community_id': 1,
                                              'sender_id': currentUserUid,
                                              'message':
                                                  _model.textController.text,
                                              'e_message_type': 'text',
                                              'is_read': false,
                                            });
                                            await ChatTable().update(
                                              data: {
                                                'last_message':
                                                    _model.textController.text,
                                                'last_message_date':
                                                    supaSerialize<DateTime>(
                                                        functions
                                                            .getCurrentUtcTime()),
                                                'last_message_user':
                                                    currentUserUid,
                                              },
                                              matchingRows: (rows) =>
                                                  rows.eqOrNull(
                                                'id',
                                                widget!.chatId,
                                              ),
                                            );
                                            safeSetState(() {
                                              _model.textController?.clear();
                                            });
                                          }

                                          safeSetState(() {});
                                        },
                                        autofocus: false,
                                        textInputAction: TextInputAction.send,
                                        obscureText: false,
                                        decoration: InputDecoration(
                                          isDense: true,
                                          labelStyle: FlutterFlowTheme.of(
                                                  context)
                                              .labelMedium
                                              .override(
                                                font: GoogleFonts.manrope(
                                                  fontWeight: FontWeight.w500,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .labelMedium
                                                          .fontStyle,
                                                ),
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .greyL4,
                                                letterSpacing: 0.0,
                                                fontWeight: FontWeight.w500,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .labelMedium
                                                        .fontStyle,
                                                lineHeight: 1.3,
                                              ),
                                          hintText: 'Type your message here...',
                                          hintStyle: FlutterFlowTheme.of(
                                                  context)
                                              .labelMedium
                                              .override(
                                                font: GoogleFonts.manrope(
                                                  fontWeight: FontWeight.w500,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .labelMedium
                                                          .fontStyle,
                                                ),
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .greyL4,
                                                letterSpacing: 0.0,
                                                fontWeight: FontWeight.w500,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .labelMedium
                                                        .fontStyle,
                                                lineHeight: 1.3,
                                              ),
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .greyL2,
                                              width: 1.0,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(4.0),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color: Colors.transparent,
                                              width: 1.0,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(4.0),
                                          ),
                                          errorBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .error,
                                              width: 1.0,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(4.0),
                                          ),
                                          focusedErrorBorder:
                                              OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .error,
                                              width: 1.0,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(4.0),
                                          ),
                                          filled: true,
                                          fillColor:
                                              FlutterFlowTheme.of(context)
                                                  .alternate,
                                          contentPadding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  12.0, 16.0, 12.0, 16.0),
                                        ),
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
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .greyL4,
                                              letterSpacing: 0.0,
                                              fontWeight: FontWeight.w500,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontStyle,
                                              lineHeight: 1.3,
                                            ),
                                        cursorColor:
                                            FlutterFlowTheme.of(context)
                                                .primaryText,
                                        validator: _model
                                            .textControllerValidator
                                            .asValidator(context),
                                      ),
                                    ),
                                  ),
                                ].divide(SizedBox(width: 8.0)),
                              ),
                            ),
                          ),
                          FutureBuilder<List<BlocksRow>>(
                            future: BlocksTable().querySingleRow(
                              queryFn: (q) => q
                                  .eqOrNull(
                                    'blocked_id',
                                    widget!.userId,
                                  )
                                  .eqOrNull(
                                    'blocker_id',
                                    currentUserUid,
                                  ),
                            ),
                            builder: (context, snapshot) {
                              // Customize what your widget looks like when it's loading.
                              if (!snapshot.hasData) {
                                return CompLoadingWidget(
                                  name: '',
                                );
                              }
                              List<BlocksRow> containerBlocksRowList =
                                  snapshot.data!;

                              // Return an empty Container when the item does not exist.
                              if (snapshot.data!.isEmpty) {
                                return Container();
                              }
                              final containerBlocksRow =
                                  containerBlocksRowList.isNotEmpty
                                      ? containerBlocksRowList.first
                                      : null;

                              return Container(
                                width: double.infinity,
                                height: 66.0,
                                decoration: BoxDecoration(
                                  color: FlutterFlowTheme.of(context)
                                      .secondaryBackground,
                                ),
                                child:
                                    FutureBuilder<List<PublicUserProfileRow>>(
                                  future:
                                      PublicUserProfileTable().querySingleRow(
                                    queryFn: (q) => q.eqOrNull(
                                      'id',
                                      widget!.userId,
                                    ),
                                  ),
                                  builder: (context, snapshot) {
                                    // Customize what your widget looks like when it's loading.
                                    if (!snapshot.hasData) {
                                      return Center(
                                        child: SizedBox(
                                          width: 50.0,
                                          height: 50.0,
                                          child: CircularProgressIndicator(
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                              FlutterFlowTheme.of(context)
                                                  .primary,
                                            ),
                                          ),
                                        ),
                                      );
                                    }
                                    List<PublicUserProfileRow>
                                        rowPublicUserProfileRowList =
                                        snapshot.data!;

                                    final rowPublicUserProfileRow =
                                        rowPublicUserProfileRowList.isNotEmpty
                                            ? rowPublicUserProfileRowList.first
                                            : null;

                                    return InkWell(
                                      splashColor: FlutterFlowTheme.of(context)
                                          .primary
                                          .withAlpha(0x14),
                                      focusColor: Colors.transparent,
                                      hoverColor: Colors.transparent,
                                      highlightColor: Colors.transparent,
                                      onTap: () async {
                                        await showModalBottomSheet(
                                          isScrollControlled: true,
                                          backgroundColor: Colors.transparent,
                                          enableDrag: false,
                                          context: context,
                                          builder: (context) {
                                            return GestureDetector(
                                              onTap: () {
                                                FocusScope.of(context)
                                                    .unfocus();
                                                FocusManager
                                                    .instance.primaryFocus
                                                    ?.unfocus();
                                              },
                                              child: Padding(
                                                padding:
                                                    MediaQuery.viewInsetsOf(
                                                        context),
                                                child: CompUnblockUserWidget(
                                                  unBlockUserId:
                                                      widget!.userId!,
                                                  unBlockUserName:
                                                      rowPublicUserProfileRow!
                                                          .name!,
                                                ),
                                              ),
                                            );
                                          },
                                        ).then((value) => safeSetState(() {}));
                                      },
                                      child: Row(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.block_sharp,
                                            color: FlutterFlowTheme.of(context)
                                                .greyL5,
                                            size: 24.0,
                                          ),
                                          Text(
                                            'Unblock',
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
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .greyL5,
                                                  fontSize: 16.0,
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
                                          Text(
                                            valueOrDefault<String>(
                                              rowPublicUserProfileRow?.name,
                                              'name',
                                            ),
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
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .greyL5,
                                                  fontSize: 16.0,
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
                                        ].divide(SizedBox(width: 10.0)),
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                          FutureBuilder<List<BlocksRow>>(
                            future: BlocksTable().querySingleRow(
                              queryFn: (q) => q
                                  .eqOrNull(
                                    'blocked_id',
                                    currentUserUid,
                                  )
                                  .eqOrNull(
                                    'blocker_id',
                                    widget!.userId,
                                  ),
                            ),
                            builder: (context, snapshot) {
                              // Customize what your widget looks like when it's loading.
                              if (!snapshot.hasData) {
                                return CompLoadingWidget(
                                  name: '',
                                );
                              }
                              List<BlocksRow> containerBlocksRowList =
                                  snapshot.data!;

                              // Return an empty Container when the item does not exist.
                              if (snapshot.data!.isEmpty) {
                                return Container();
                              }
                              final containerBlocksRow =
                                  containerBlocksRowList.isNotEmpty
                                      ? containerBlocksRowList.first
                                      : null;

                              return Container(
                                width: double.infinity,
                                height: 66.0,
                                decoration: BoxDecoration(
                                  color: FlutterFlowTheme.of(context)
                                      .secondaryBackground,
                                ),
                                child:
                                    FutureBuilder<List<PublicUserProfileRow>>(
                                  future:
                                      PublicUserProfileTable().querySingleRow(
                                    queryFn: (q) => q.eqOrNull(
                                      'id',
                                      widget!.userId,
                                    ),
                                  ),
                                  builder: (context, snapshot) {
                                    // Customize what your widget looks like when it's loading.
                                    if (!snapshot.hasData) {
                                      return Center(
                                        child: SizedBox(
                                          width: 50.0,
                                          height: 50.0,
                                          child: CircularProgressIndicator(
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                              FlutterFlowTheme.of(context)
                                                  .primary,
                                            ),
                                          ),
                                        ),
                                      );
                                    }
                                    List<PublicUserProfileRow>
                                        rowPublicUserProfileRowList =
                                        snapshot.data!;

                                    final rowPublicUserProfileRow =
                                        rowPublicUserProfileRowList.isNotEmpty
                                            ? rowPublicUserProfileRowList.first
                                            : null;

                                    return Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.block_sharp,
                                          color: FlutterFlowTheme.of(context)
                                              .greyL5,
                                          size: 24.0,
                                        ),
                                        Row(
                                          mainAxisSize: MainAxisSize.max,
                                          children: [
                                            Text(
                                              valueOrDefault<String>(
                                                rowPublicUserProfileRow?.name,
                                                'name',
                                              ),
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
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .greyL5,
                                                    fontSize: 16.0,
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
                                            Text(
                                              'blocked you',
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
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .greyL5,
                                                    fontSize: 16.0,
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
                                          ].divide(SizedBox(width: 2.0)),
                                        ),
                                      ].divide(SizedBox(width: 10.0)),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              if (_model.selectImage)
                Expanded(
                  child: Stack(
                    alignment: AlignmentDirectional(1.0, 1.0),
                    children: [
                      Align(
                        alignment: AlignmentDirectional(0.0, 0.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Container(
                              width: double.infinity,
                              height: 56.0,
                              decoration: BoxDecoration(
                                color: FlutterFlowTheme.of(context)
                                    .secondaryBackground,
                              ),
                              child: Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    10.0, 0.0, 20.0, 0.0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Semantics(
                                      label: 'Discard photo',
                                      button: true,
                                      child: FlutterFlowIconButton(
                                        borderRadius: 100.0,
                                        fillColor:
                                            FlutterFlowTheme.of(context).greyL2,
                                        icon: Icon(
                                          Icons.close,
                                          color: FlutterFlowTheme.of(context)
                                              .extraBlack,
                                          size: 24.0,
                                        ),
                                        onPressed: () async {
                                          _model.selectImage = false;
                                          safeSetState(() {});
                                          safeSetState(() {
                                            _model.isDataUploading_uploadDataIvk =
                                                false;
                                            _model.uploadedLocalFile_uploadDataIvk =
                                                FFUploadedFile(
                                                    bytes:
                                                        Uint8List.fromList([]),
                                                    originalFilename: '');
                                          });
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Expanded(
                              child: Align(
                                alignment: AlignmentDirectional(0.0, 0.0),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8.0),
                                  child: Image.memory(
                                    _model.uploadedLocalFile_uploadDataIvk
                                            .bytes ??
                                        Uint8List.fromList([]),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(
                            0.0, 0.0, 20.0, 40.0),
                        // Highest-traffic control on this screen: 48dp target,
                        // explicit 'Send message' label for TalkBack/VoiceOver.
                        child: AppIconButton(
                          icon: Icons.send_sharp,
                          semanticLabel: 'Send message',
                          tooltip: 'Send',
                          iconSize: 20.0,
                          minTapTarget: 48.0,
                          color: Colors.white,
                          backgroundColor: FlutterFlowTheme.of(context).primary,
                          borderRadius: BorderRadius.circular(100.0),
                          onTap: () async {
                            {
                              safeSetState(() =>
                                  _model.isDataUploading_uploadData9nm = true);
                              var selectedUploadedFiles = <FFUploadedFile>[];
                              var selectedMedia = <SelectedFile>[];
                              var downloadUrls = <String>[];
                              try {
                                selectedUploadedFiles = _model
                                        .uploadedLocalFile_uploadDataIvk
                                        .bytes!
                                        .isNotEmpty
                                    ? [_model.uploadedLocalFile_uploadDataIvk]
                                    : <FFUploadedFile>[];
                                selectedMedia = selectedFilesFromUploadedFiles(
                                  selectedUploadedFiles,
                                  storageFolderPath: widget!.chatId,
                                );
                                downloadUrls = await uploadSupabaseStorageFiles(
                                  bucketName: 'chat-images',
                                  selectedFiles: selectedMedia,
                                );
                              } finally {
                                _model.isDataUploading_uploadData9nm = false;
                              }
                              if (selectedUploadedFiles.length ==
                                      selectedMedia.length &&
                                  downloadUrls.length == selectedMedia.length) {
                                safeSetState(() {
                                  _model.uploadedLocalFile_uploadData9nm =
                                      selectedUploadedFiles.first;
                                  _model.uploadedFileUrl_uploadData9nm =
                                      downloadUrls.first;
                                });
                              } else {
                                safeSetState(() {});
                                return;
                              }
                            }

                            await MessagesTable().insert({
                              'chat_id': widget!.chatId,
                              'sender_id': currentUserUid,
                              'e_message_type': 'image',
                              'is_read': false,
                              'file_url': _model.uploadedFileUrl_uploadData9nm,
                              'community_id': 1,
                              'message': 'image',
                            });
                            await ChatTable().update(
                              data: {
                                'last_message_date': supaSerialize<DateTime>(
                                    functions.getCurrentUtcTime()),
                                'last_message_user': currentUserUid,
                                'last_message': 'image',
                              },
                              matchingRows: (rows) => rows.eqOrNull(
                                'id',
                                widget!.chatId,
                              ),
                            );
                            _model.selectImage = false;
                            safeSetState(() {});
                            safeSetState(() {
                              _model.isDataUploading_uploadDataIvk = false;
                              _model.uploadedLocalFile_uploadDataIvk =
                                  FFUploadedFile(
                                      bytes: Uint8List.fromList([]),
                                      originalFilename: '');
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
