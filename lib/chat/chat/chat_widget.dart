// chat_widget.dart
// Flock conversation list (All / DMs / For sale tabs, multi-select delete mode).
// Shared components: AppNetworkImage for avatars, AppIconButton for the icon-only
// toolbar controls, EmptyState for the "no conversations yet" branch.
import '/auth/supabase_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/chat/comp_manage_chat/comp_manage_chat_widget.dart';
import '/chat/comp_new_message/comp_new_message_widget.dart';
import '/components/app_icon_button.dart';
import '/components/app_network_image.dart';
import '/components/empty_state.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/custom_code/actions/index.dart' as actions;
import '/custom_code/widgets/index.dart' as custom_widgets;
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';
import 'dart:math' as math;
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'chat_model.dart';
export 'chat_model.dart';

class ChatWidget extends StatefulWidget {
  const ChatWidget({
    super.key,
    required this.selectMessage,
    this.previousPage,
  });

  final bool? selectMessage;
  final String? previousPage;

  static String routeName = 'Chat';
  static String routePath = 'chat';

  @override
  State<ChatWidget> createState() => _ChatWidgetState();
}

class _ChatWidgetState extends State<ChatWidget> {
  late ChatModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ChatModel());

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      _model.selectChat = widget!.selectMessage;
      _model.opt = 'all';
      safeSetState(() {});
      _model.userChat22 = await GetChatCall.call(
        apiKey: FFDevEnvironmentValues().AnonKey,
        token: currentJwtToken,
        searchQuery: ' ',
      );

      FFAppState().matchedUsers = getJsonField(
        (_model.userChat22?.jsonBody ?? ''),
        r'''$''',
      );
      safeSetState(() {});
    });

    _model.textController ??= TextEditingController();
    _model.textFieldFocusNode ??= FocusNode();
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  /// Opens the "New Chat" bottom sheet (shared by the FAB and the empty-state CTA).
  Future<void> _openNewChatSheet() async {
    await showModalBottomSheet(
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      context: context,
      builder: (BuildContext context) {
        return GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: Padding(
            padding: MediaQuery.viewInsetsOf(context),
            child: CompNewMessageWidget(),
          ),
        );
      },
    ).then((dynamic value) => safeSetState(() {}));
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
        backgroundColor: FlutterFlowTheme.of(context).white,
        body: SafeArea(
          top: true,
          bottom: true,
          child: Container(
            decoration: BoxDecoration(
              color: FlutterFlowTheme.of(context).pageBack,
            ),
            child: Stack(
              children: [
                Column(
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
                                  if (widget!.previousPage == 'loading') {
                                    context.pushNamed(HomePageWidget.routeName);
                                  } else {
                                    context.safePop();
                                  }
                                },
                              ),
                            ),
                            Expanded(
                              child: Container(
                                width: double.infinity,
                                child: TextFormField(
                                  controller: _model.textController,
                                  focusNode: _model.textFieldFocusNode,
                                  onChanged: (_) => EasyDebounce.debounce(
                                    '_model.textController',
                                    Duration(milliseconds: 2000),
                                    () async {
                                      await actions.fetchMatchedUsersRealtime(
                                        _model.textController.text,
                                      );
                                    },
                                  ),
                                  autofocus: false,
                                  obscureText: false,
                                  decoration: InputDecoration(
                                    isDense: true,
                                    labelStyle: FlutterFlowTheme.of(context)
                                        .labelMedium
                                        .override(
                                          font: GoogleFonts.manrope(
                                            fontWeight: FontWeight.w500,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .labelMedium
                                                    .fontStyle,
                                          ),
                                          color: FlutterFlowTheme.of(context)
                                              .greyL4,
                                          letterSpacing: 0.0,
                                          fontWeight: FontWeight.w500,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .labelMedium
                                                  .fontStyle,
                                          lineHeight: 1.3,
                                        ),
                                    hintText: 'Search',
                                    hintStyle: FlutterFlowTheme.of(context)
                                        .labelMedium
                                        .override(
                                          font: GoogleFonts.manrope(
                                            fontWeight: FontWeight.w500,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .labelMedium
                                                    .fontStyle,
                                          ),
                                          color: FlutterFlowTheme.of(context)
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
                                        color: Colors.transparent,
                                        width: 1.0,
                                      ),
                                      borderRadius: BorderRadius.circular(4.0),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color:
                                            FlutterFlowTheme.of(context).greyD1,
                                        width: 1.0,
                                      ),
                                      borderRadius: BorderRadius.circular(4.0),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color:
                                            FlutterFlowTheme.of(context).error,
                                        width: 1.0,
                                      ),
                                      borderRadius: BorderRadius.circular(4.0),
                                    ),
                                    focusedErrorBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color:
                                            FlutterFlowTheme.of(context).error,
                                        width: 1.0,
                                      ),
                                      borderRadius: BorderRadius.circular(4.0),
                                    ),
                                    filled: true,
                                    fillColor:
                                        FlutterFlowTheme.of(context).alternate,
                                    contentPadding:
                                        EdgeInsetsDirectional.fromSTEB(
                                            12.0, 8.0, 12.0, 8.0),
                                    prefixIcon: Icon(
                                      Icons.search_rounded,
                                      color:
                                          FlutterFlowTheme.of(context).greyL4,
                                      size: 20.0,
                                    ),
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
                                        color: FlutterFlowTheme.of(context)
                                            .primaryText,
                                        letterSpacing: 0.0,
                                        fontWeight: FontWeight.w500,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .fontStyle,
                                        lineHeight: 1.3,
                                      ),
                                  cursorColor:
                                      FlutterFlowTheme.of(context).primaryText,
                                  validator: _model.textControllerValidator
                                      .asValidator(context),
                                ),
                              ),
                            ),
                            // Chat options. The 34dp grey disc is kept as the
                            // visual; AppIconButton only grows the hit area to
                            // 44dp and adds the missing screen-reader label.
                            AppIconButton(
                              semanticLabel: 'Chat options',
                              tooltip: 'Chat options',
                              iconSize: 16.0,
                              iconWidget: Container(
                                width: 34.0,
                                height: 34.0,
                                decoration: BoxDecoration(
                                  color: FlutterFlowTheme.of(context).greyL2,
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(100.0),
                                    topRight: Radius.circular(100.0),
                                    bottomLeft: Radius.circular(100.0),
                                    bottomRight: Radius.circular(100.0),
                                  ),
                                ),
                                alignment: AlignmentDirectional(0.0, 0.0),
                                child: Transform.rotate(
                                  angle: 90.0 * (math.pi / 180),
                                  child: Icon(
                                    Icons.keyboard_control,
                                    color: FlutterFlowTheme.of(context)
                                        .primaryText,
                                    size: 16.0,
                                  ),
                                ),
                              ),
                              onTap: () async {
                                await showModalBottomSheet(
                                  isScrollControlled: true,
                                  backgroundColor: Colors.transparent,
                                  context: context,
                                  builder: (context) {
                                    return GestureDetector(
                                      onTap: () {
                                        FocusScope.of(context).unfocus();
                                        FocusManager.instance.primaryFocus
                                            ?.unfocus();
                                      },
                                      child: Padding(
                                        padding:
                                            MediaQuery.viewInsetsOf(context),
                                        child: CompManageChatWidget(
                                          opt: _model.opt!,
                                        ),
                                      ),
                                    );
                                  },
                                ).then((value) => safeSetState(() {}));
                              },
                            ),
                          ]
                              .divide(SizedBox(width: 10.0))
                              .addToStart(SizedBox(width: 10.0))
                              .addToEnd(SizedBox(width: 20.0)),
                        ),
                      ),
                    ),
                    Stack(
                      children: [
                        if (!_model.selectChat!)
                          Container(
                            width: double.infinity,
                            height: 48.0,
                            decoration: BoxDecoration(
                              color: FlutterFlowTheme.of(context)
                                  .secondaryBackground,
                            ),
                            child: Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  20.0, 0.0, 20.0, 0.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  InkWell(
                                    splashColor: FlutterFlowTheme.of(context)
                                        .primary
                                        .withAlpha(0x14),
                                    focusColor: Colors.transparent,
                                    hoverColor: Colors.transparent,
                                    highlightColor: Colors.transparent,
                                    onTap: () async {
                                      HapticFeedback.lightImpact();
                                      _model.opt = 'all';
                                      safeSetState(() {});
                                    },
                                    child: AnimatedContainer(
                                      duration: 180.ms,
                                      curve: Curves.easeOut,
                                      height: 28.0,
                                      decoration: BoxDecoration(
                                        color: _model.opt == 'all'
                                            ? FlutterFlowTheme.of(context)
                                                .primary
                                            : Colors.transparent,
                                        borderRadius:
                                            BorderRadius.circular(24.0),
                                        border: Border.all(
                                          color: _model.opt != 'all'
                                              ? FlutterFlowTheme.of(context)
                                                  .greyL4
                                              : Colors.transparent,
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
                                            'All',
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
                                                  color: _model.opt == 'all'
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
                                  ),
                                  InkWell(
                                    splashColor: FlutterFlowTheme.of(context)
                                        .primary
                                        .withAlpha(0x14),
                                    focusColor: Colors.transparent,
                                    hoverColor: Colors.transparent,
                                    highlightColor: Colors.transparent,
                                    onTap: () async {
                                      HapticFeedback.lightImpact();
                                      _model.opt = 'dms';
                                      safeSetState(() {});
                                    },
                                    child: AnimatedContainer(
                                      duration: 180.ms,
                                      curve: Curves.easeOut,
                                      height: 28.0,
                                      decoration: BoxDecoration(
                                        color: _model.opt == 'dms'
                                            ? FlutterFlowTheme.of(context)
                                                .primary
                                            : Colors.transparent,
                                        borderRadius:
                                            BorderRadius.circular(24.0),
                                        border: Border.all(
                                          color: _model.opt != 'dms'
                                              ? FlutterFlowTheme.of(context)
                                                  .greyL4
                                              : Colors.transparent,
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
                                            'DMs',
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
                                                  color: _model.opt == 'dms'
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
                                  ),
                                  InkWell(
                                    splashColor: FlutterFlowTheme.of(context)
                                        .primary
                                        .withAlpha(0x14),
                                    focusColor: Colors.transparent,
                                    hoverColor: Colors.transparent,
                                    highlightColor: Colors.transparent,
                                    onTap: () async {
                                      HapticFeedback.lightImpact();
                                      _model.opt = 'forsale';
                                      safeSetState(() {});
                                    },
                                    child: AnimatedContainer(
                                      duration: 180.ms,
                                      curve: Curves.easeOut,
                                      height: 28.0,
                                      decoration: BoxDecoration(
                                        color: _model.opt == 'forsale'
                                            ? FlutterFlowTheme.of(context)
                                                .primary
                                            : Colors.transparent,
                                        borderRadius:
                                            BorderRadius.circular(24.0),
                                        border: Border.all(
                                          color: _model.opt != 'forsale'
                                              ? FlutterFlowTheme.of(context)
                                                  .greyL4
                                              : Colors.transparent,
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
                                            'For Sale',
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
                                                  color: _model.opt == 'forsale'
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
                                  ),
                                ].divide(SizedBox(width: 8.0)),
                              ),
                            ),
                          ),
                        if (_model.selectChat ?? true)
                          Container(
                            width: double.infinity,
                            height: 56.0,
                            decoration: BoxDecoration(
                              color: FlutterFlowTheme.of(context).greayL1,
                            ),
                            child: Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  20.0, 0.0, 20.0, 0.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  AppIconButton(
                                    icon: Icons.close,
                                    semanticLabel: 'Exit selection mode',
                                    tooltip: 'Cancel',
                                    iconSize: 24.0,
                                    color: FlutterFlowTheme.of(context)
                                        .primaryText,
                                    onTap: () async {
                                      _model.selectChat = false;
                                      safeSetState(() {});
                                      FFAppState().userIds = [];
                                      safeSetState(() {});
                                    },
                                  ),
                                  Expanded(
                                    child: Text(
                                      '${FFAppState().userIds.length.toString()} selected',
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
                                            fontSize: 16.0,
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
                                  AppIconButton(
                                    semanticLabel: _model.selectAll
                                        ? 'Deselect all chats'
                                        : 'Select all chats',
                                    tooltip: 'Select all',
                                    iconSize: 24.0,
                                    iconWidget: Image.asset(
                                      'assets/images/select_all.png',
                                      width: 24.0,
                                      height: 24.0,
                                      fit: BoxFit.cover,
                                    ),
                                    onTap: () async {
                                      if (_model.selectAll) {
                                        _model.selectAll = false;
                                        safeSetState(() {});
                                        FFAppState().userIds = [];
                                        safeSetState(() {});
                                      } else {
                                        _model.selectAll = true;
                                        safeSetState(() {});
                                        await actions.selectAllUsers();
                                      }
                                    },
                                  ),
                                  AppIconButton(
                                    semanticLabel: 'Delete selected chats',
                                    tooltip: 'Delete',
                                    iconSize: 24.0,
                                    iconWidget: Image.asset(
                                      'assets/images/delete.webp',
                                      width: 24.0,
                                      height: 24.0,
                                      fit: BoxFit.cover,
                                    ),
                                    onTap: () async {
                                      _model.apiResultvo9 =
                                          await SoftdeletechatusersCall.call(
                                        userIdsList: FFAppState().userIds,
                                        anonKey:
                                            FFDevEnvironmentValues().AnonKey,
                                        token: currentJwtToken,
                                      );

                                      _model.selectChat = false;
                                      safeSetState(() {});

                                      safeSetState(() {});
                                    },
                                  ),
                                ].divide(SizedBox(width: 8.0)),
                              ),
                            ),
                          ),
                      ],
                    ),
                    if (((_model.opt == 'dms') &&
                            ('${getJsonField(
                                  FFAppState().matchedUsers,
                                  r'''$[0].total_dm_chats''',
                                ).toString()}' !=
                                '0') &&
                            ('${getJsonField(
                                  FFAppState().matchedUsers,
                                  r'''$''',
                                ).toString()}' !=
                                '[]')) ||
                        ((_model.opt == 'forsale') &&
                            ('${getJsonField(
                                  FFAppState().matchedUsers,
                                  r'''$[0].total_sale_chats''',
                                ).toString()}' !=
                                '0') &&
                            ('${getJsonField(
                                  FFAppState().matchedUsers,
                                  r'''$''',
                                ).toString()}' !=
                                '[]')) ||
                        ((_model.opt == 'all') &&
                            ('${getJsonField(
                                  FFAppState().matchedUsers,
                                  r'''$''',
                                ).toString()}' !=
                                '[]')))
                      Expanded(
                        child: Builder(
                          builder: (context) {
                            final chat = getJsonField(
                              FFAppState().matchedUsers,
                              r'''$''',
                            ).toList();

                            return RefreshIndicator(
                              onRefresh: () async {
                                _model.userChat2 = await GetChatCall.call(
                                  apiKey: FFDevEnvironmentValues().AnonKey,
                                  token: currentJwtToken,
                                  searchQuery: ' ',
                                );

                                FFAppState().matchedUsers = getJsonField(
                                  (_model.userChat2?.jsonBody ?? ''),
                                  r'''$''',
                                );
                                safeSetState(() {});
                              },
                              child: ListView.builder(
                                padding: EdgeInsets.fromLTRB(
                                  0,
                                  0,
                                  0,
                                  20.0,
                                ),
                                shrinkWrap: true,
                                scrollDirection: Axis.vertical,
                                itemCount: chat.length,
                                itemBuilder: (context, chatIndex) {
                                  final chatItem = chat[chatIndex];
                                  return Visibility(
                                    visible: (_model.opt == 'all') ||
                                        ((_model.opt == 'dms') &&
                                            ('${getJsonField(
                                                  chatItem,
                                                  r'''$.chat_type''',
                                                ).toString()}' ==
                                                'dm')) ||
                                        ((_model.opt == 'forsale') &&
                                            ('${getJsonField(
                                                  chatItem,
                                                  r'''$.chat_type''',
                                                ).toString()}' ==
                                                'sale')),
                                    // Whole-row target: annotate rather than
                                    // convert, so the row keeps its own layout
                                    // and the InkWell keeps its tap action.
                                    child: Semantics(
                                      button: true,
                                      label:
                                          'Open conversation with ${valueOrDefault<String>(
                                        getJsonField(
                                          chatItem,
                                          r'''$.name''',
                                        )?.toString(),
                                        'this neighbour',
                                      )}',
                                      child: InkWell(
                                        splashColor:
                                            FlutterFlowTheme.of(context)
                                                .primary
                                                .withAlpha(0x14),
                                        focusColor: Colors.transparent,
                                        hoverColor: Colors.transparent,
                                        highlightColor: Colors.transparent,
                                        onTap: () async {
                                          context.pushNamed(
                                            MessagePageWidget.routeName,
                                            queryParameters: {
                                              'chatId': serializeParam(
                                                getJsonField(
                                                  chatItem,
                                                  r'''$.chat_id''',
                                                ).toString(),
                                                ParamType.String,
                                              ),
                                              'userId': serializeParam(
                                                getJsonField(
                                                  chatItem,
                                                  r'''$.user_id''',
                                                ).toString(),
                                                ParamType.String,
                                              ),
                                            }.withoutNulls,
                                          );
                                        },
                                        child: Container(
                                          width: double.infinity,
                                          height: 76.0,
                                          decoration: BoxDecoration(
                                            color: FlutterFlowTheme.of(context)
                                                .secondaryBackground,
                                          ),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Expanded(
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Expanded(
                                                      child: Padding(
                                                        padding:
                                                            EdgeInsetsDirectional
                                                                .fromSTEB(
                                                                    20.0,
                                                                    16.0,
                                                                    20.0,
                                                                    15.0),
                                                        child: Row(
                                                          mainAxisSize:
                                                              MainAxisSize.max,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Expanded(
                                                              child: Row(
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .max,
                                                                children: [
                                                                  Container(
                                                                    width: 40.0,
                                                                    height:
                                                                        40.0,
                                                                    child:
                                                                        Stack(
                                                                      alignment:
                                                                          AlignmentDirectional(
                                                                              0.0,
                                                                              0.0),
                                                                      children: [
                                                                        Stack(
                                                                          alignment: AlignmentDirectional(
                                                                              0.0,
                                                                              0.0),
                                                                          children: [
                                                                            if (!_model.selectChat!)
                                                                              AppNetworkImage(
                                                                                url: getJsonField(
                                                                                  chatItem,
                                                                                  r'''$.profile_picture''',
                                                                                ).toString(),
                                                                                width: 40.0,
                                                                                height: 40.0,
                                                                                isAvatar: true,
                                                                                // No semanticLabel: the row's own
                                                                                // Semantics already announces the
                                                                                // contact name, and a second label
                                                                                // would be merged into it.
                                                                              ),
                                                                            if (_model.selectChat ??
                                                                                true)
                                                                              Container(
                                                                                width: 20.0,
                                                                                height: 20.0,
                                                                                child: custom_widgets.ConditionalCheckbox(
                                                                                  width: 20.0,
                                                                                  height: 20.0,
                                                                                  userId: getJsonField(
                                                                                    chatItem,
                                                                                    r'''$.user_id''',
                                                                                  ).toString(),
                                                                                ),
                                                                              ),
                                                                          ],
                                                                        ),
                                                                        if (false)
                                                                          Stack(
                                                                            children: [
                                                                              Align(
                                                                                alignment: AlignmentDirectional(1.0, 1.0),
                                                                                child: Container(
                                                                                  width: 8.0,
                                                                                  height: 8.0,
                                                                                  decoration: BoxDecoration(
                                                                                    color: FlutterFlowTheme.of(context).greenColor2,
                                                                                    borderRadius: BorderRadius.circular(24.0),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                  Expanded(
                                                                    child:
                                                                        Column(
                                                                      mainAxisSize:
                                                                          MainAxisSize
                                                                              .max,
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children:
                                                                          [
                                                                        Expanded(
                                                                          child:
                                                                              Text(
                                                                            valueOrDefault<String>(
                                                                              getJsonField(
                                                                                chatItem,
                                                                                r'''$.name''',
                                                                              )?.toString(),
                                                                              'name',
                                                                            ),
                                                                            maxLines:
                                                                                1,
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
                                                                        ),
                                                                        Stack(
                                                                          children: [
                                                                            if ('${getJsonField(
                                                                                  chatItem,
                                                                                  r'''$.last_message''',
                                                                                ).toString()}' !=
                                                                                'null')
                                                                              Text(
                                                                                getJsonField(
                                                                                  chatItem,
                                                                                  r'''$.last_message''',
                                                                                ).toString(),
                                                                                maxLines: 1,
                                                                                style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                      font: GoogleFonts.manrope(
                                                                                        fontWeight: FontWeight.w600,
                                                                                        fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                      ),
                                                                                      color: FlutterFlowTheme.of(context).greyL5,
                                                                                      fontSize: 12.0,
                                                                                      letterSpacing: 0.0,
                                                                                      fontWeight: FontWeight.w600,
                                                                                      fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                      lineHeight: 1.4,
                                                                                    ),
                                                                              ),
                                                                            if (false)
                                                                              Text(
                                                                                'Typing...',
                                                                                style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                      font: GoogleFonts.manrope(
                                                                                        fontWeight: FontWeight.w600,
                                                                                        fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                      ),
                                                                                      color: FlutterFlowTheme.of(context).greenColor1,
                                                                                      fontSize: 12.0,
                                                                                      letterSpacing: 0.0,
                                                                                      fontWeight: FontWeight.w600,
                                                                                      fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                      lineHeight: 1.4,
                                                                                    ),
                                                                              ),
                                                                          ],
                                                                        ),
                                                                      ].divide(SizedBox(
                                                                              height: 4.0)),
                                                                    ),
                                                                  ),
                                                                ].divide(SizedBox(
                                                                    width:
                                                                        8.0)),
                                                              ),
                                                            ),
                                                            Column(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .max,
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .end,
                                                              children: [
                                                                if ('${getJsonField(
                                                                      chatItem,
                                                                      r'''$.last_message_date''',
                                                                    ).toString()}' !=
                                                                    'null')
                                                                  Text(
                                                                    valueOrDefault<
                                                                        String>(
                                                                      functions
                                                                          .lastMessageDate(
                                                                              getJsonField(
                                                                        chatItem,
                                                                        r'''$.last_message_date''',
                                                                      ).toString()),
                                                                      '8:01 Pm',
                                                                    ),
                                                                    style: FlutterFlowTheme.of(
                                                                            context)
                                                                        .bodyMedium
                                                                        .override(
                                                                          font:
                                                                              GoogleFonts.manrope(
                                                                            fontWeight:
                                                                                FontWeight.w500,
                                                                            fontStyle:
                                                                                FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                          ),
                                                                          color:
                                                                              FlutterFlowTheme.of(context).greyL4,
                                                                          fontSize:
                                                                              12.0,
                                                                          letterSpacing:
                                                                              0.0,
                                                                          fontWeight:
                                                                              FontWeight.w500,
                                                                          fontStyle: FlutterFlowTheme.of(context)
                                                                              .bodyMedium
                                                                              .fontStyle,
                                                                          lineHeight:
                                                                              1.4,
                                                                        ),
                                                                  ),
                                                                if ('${getJsonField(
                                                                      chatItem,
                                                                      r'''$.unread_message_count''',
                                                                    ).toString()}' !=
                                                                    '0')
                                                                  Container(
                                                                    width: 22.0,
                                                                    height:
                                                                        22.0,
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      color: FlutterFlowTheme.of(
                                                                              context)
                                                                          .greenColor2,
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              24.0),
                                                                    ),
                                                                    alignment:
                                                                        AlignmentDirectional(
                                                                            0.0,
                                                                            0.0),
                                                                    child: Text(
                                                                      valueOrDefault<
                                                                          String>(
                                                                        getJsonField(
                                                                          chatItem,
                                                                          r'''$.unread_message_count''',
                                                                        )?.toString(),
                                                                        '0',
                                                                      ),
                                                                      style: FlutterFlowTheme.of(
                                                                              context)
                                                                          .bodyMedium
                                                                          .override(
                                                                            font:
                                                                                GoogleFonts.manrope(
                                                                              fontWeight: FontWeight.w600,
                                                                              fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                            ),
                                                                            color:
                                                                                Colors.white,
                                                                            fontSize:
                                                                                12.0,
                                                                            letterSpacing:
                                                                                0.0,
                                                                            fontWeight:
                                                                                FontWeight.w600,
                                                                            fontStyle:
                                                                                FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                            lineHeight:
                                                                                1.4,
                                                                          ),
                                                                    ),
                                                                  ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                    if (false)
                                                      Container(
                                                        width: 4.0,
                                                        height: 76.0,
                                                        decoration:
                                                            BoxDecoration(
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .greenColor2,
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                              ),
                                              Container(
                                                width: double.infinity,
                                                height: 1.0,
                                                decoration: BoxDecoration(
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .greyL2,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                      .animate()
                                      .fadeIn(
                                          duration: 260.ms,
                                          delay: (40 * (chatIndex % 8)).ms)
                                      .slideY(
                                          begin: 0.06,
                                          end: 0,
                                          curve: Curves.easeOutCubic);
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    if (('${getJsonField(
                              FFAppState().matchedUsers,
                              r'''$''',
                            ).toString()}' ==
                            '[]') ||
                        ((_model.opt == 'dms') &&
                            ('${getJsonField(
                                  FFAppState().matchedUsers,
                                  r'''$[0].total_dm_chats''',
                                ).toString()}' ==
                                '0')) ||
                        ((_model.opt == 'forsale') &&
                            ('${getJsonField(
                                  FFAppState().matchedUsers,
                                  r'''$[0].total_sale_chats''',
                                ).toString()}' ==
                                '0')))
                      // Shared empty state: keeps the existing illustration and
                      // adds the CTA that starts a new conversation.
                      Expanded(
                        child: EmptyState(
                          illustrationAsset: 'assets/images/empty_chat.png',
                          title: 'No messages yet',
                          body: 'Start the conversation and break the silence.',
                          actionLabel: 'Start a chat',
                          onAction: () => _openNewChatSheet(),
                        ),
                      ),
                  ],
                ),
                Align(
                  alignment: AlignmentDirectional(1.0, 1.0),
                  child: Padding(
                    padding:
                        EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 20.0, 20.0),
                    child: AppIconButton(
                      semanticLabel: 'New chat',
                      tooltip: 'New chat',
                      iconSize: 20.0,
                      minTapTarget: 48.0,
                      backgroundColor: FlutterFlowTheme.of(context).primaryD4,
                      borderRadius: BorderRadius.circular(24.0),
                      iconWidget: Image.asset(
                        'assets/images/edit_square_(1).png',
                        width: 20.0,
                        height: 20.0,
                        fit: BoxFit.cover,
                      ),
                      onTap: () => _openNewChatSheet(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
