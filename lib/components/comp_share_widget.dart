import '/auth/supabase_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'comp_share_model.dart';
export 'comp_share_model.dart';

class CompShareWidget extends StatefulWidget {
  const CompShareWidget({
    super.key,
    required this.pagename,
    required this.id,
  });

  final String? pagename;
  final String? id;

  @override
  State<CompShareWidget> createState() => _CompShareWidgetState();
}

class _CompShareWidgetState extends State<CompShareWidget> {
  late CompShareModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => CompShareModel());

    // On component load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      _model.internalShareUsers = await InternalShareCall.call(
        token: currentJwtToken,
        pUserid: currentUserUid,
      );

      _model.userdata = (_model.internalShareUsers?.jsonBody ?? '');
      _model.showUserData = (_model.internalShareUsers?.jsonBody ?? '');
      safeSetState(() {});
    });

    _model.textController ??= TextEditingController();
    _model.textFieldFocusNode ??= FocusNode();
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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 134.0,
              height: 5.0,
              decoration: BoxDecoration(
                color: FlutterFlowTheme.of(context).extraBlack,
                borderRadius: BorderRadius.circular(24.0),
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(10.0, 16.0, 0.0, 0.0),
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
                        'Share Post',
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
                ),
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                  child: Container(
                    width: double.infinity,
                    child: TextFormField(
                      controller: _model.textController,
                      focusNode: _model.textFieldFocusNode,
                      onChanged: (_) => EasyDebounce.debounce(
                        '_model.textController',
                        Duration(milliseconds: 2000),
                        () async {
                          if ((_model.textController.text.length == 0) ==
                              true) {
                            _model.showUserData = _model.userdata;
                            safeSetState(() {});
                          } else {
                            _model.showUserData =
                                functions.returnSearchedInternalShareUser(
                                    _model.userdata!,
                                    _model.textController.text);
                            safeSetState(() {});
                          }
                        },
                      ),
                      autofocus: false,
                      obscureText: false,
                      decoration: InputDecoration(
                        isDense: true,
                        labelStyle:
                            FlutterFlowTheme.of(context).labelMedium.override(
                                  font: GoogleFonts.manrope(
                                    fontWeight: FontWeight.w500,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .labelMedium
                                        .fontStyle,
                                  ),
                                  color: FlutterFlowTheme.of(context).greyL4,
                                  letterSpacing: 0.0,
                                  fontWeight: FontWeight.w500,
                                  fontStyle: FlutterFlowTheme.of(context)
                                      .labelMedium
                                      .fontStyle,
                                  lineHeight: 1.3,
                                ),
                        hintText: 'Search....',
                        hintStyle:
                            FlutterFlowTheme.of(context).labelMedium.override(
                                  font: GoogleFonts.manrope(
                                    fontWeight: FontWeight.w500,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .labelMedium
                                        .fontStyle,
                                  ),
                                  color: FlutterFlowTheme.of(context).greyL4,
                                  letterSpacing: 0.0,
                                  fontWeight: FontWeight.w500,
                                  fontStyle: FlutterFlowTheme.of(context)
                                      .labelMedium
                                      .fontStyle,
                                  lineHeight: 1.3,
                                ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Color(0x00000000),
                            width: 1.0,
                          ),
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: FlutterFlowTheme.of(context).greyD1,
                            width: 1.0,
                          ),
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: FlutterFlowTheme.of(context).error,
                            width: 1.0,
                          ),
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: FlutterFlowTheme.of(context).error,
                            width: 1.0,
                          ),
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                        filled: true,
                        fillColor: Color(0xFFF7F9FC),
                        contentPadding: EdgeInsetsDirectional.fromSTEB(
                            12.0, 8.0, 12.0, 8.0),
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          color: FlutterFlowTheme.of(context).greyL4,
                          size: 20.0,
                        ),
                      ),
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
                      cursorColor: FlutterFlowTheme.of(context).primaryText,
                      validator:
                          _model.textControllerValidator.asValidator(context),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                  child: Container(
                    width: double.infinity,
                    height: 120.0,
                    child: Builder(
                      builder: (context) {
                        final users = _model.showUserData?.toList() ?? [];

                        return ListView.separated(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          itemCount: users.length,
                          separatorBuilder: (_, __) => SizedBox(width: 20.0),
                          itemBuilder: (context, usersIndex) {
                            final usersItem = users[usersIndex];
                            return InkWell(
                              splashColor: Colors.transparent,
                              focusColor: Colors.transparent,
                              hoverColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              onTap: () async {
                                _model.chatFoundShare =
                                    await FindCommonChatCall.call(
                                  anonKey: FFDevEnvironmentValues().AnonKey,
                                  token: currentJwtToken,
                                  user1: currentUserUid,
                                  user2: getJsonField(
                                    usersItem,
                                    r'''$.id''',
                                  ).toString(),
                                );

                                await UpdatePostShareCountCall.call(
                                  token: currentJwtToken,
                                  pCommunityid:
                                      FFAppState().communityId.toString(),
                                  pUserid: currentUserUid,
                                  pPostid: widget!.id,
                                );

                                if (FindCommonChatCall.chatFound(
                                      (_model.chatFoundShare?.jsonBody ?? ''),
                                    ) ==
                                    true) {
                                  await RestoreChatUserCall.call(
                                    pChatId: FindCommonChatCall.chatId(
                                      (_model.chatFoundShare?.jsonBody ?? ''),
                                    ),
                                    pUserId: getJsonField(
                                      usersItem,
                                      r'''$.id''',
                                    ).toString(),
                                    anonKey: FFDevEnvironmentValues().AnonKey,
                                    token: currentJwtToken,
                                  );

                                  await MessagesTable().insert({
                                    'chat_id': FindCommonChatCall.chatId(
                                      (_model.chatFoundShare?.jsonBody ?? ''),
                                    ),
                                    'community_id': FFAppState().communityId,
                                    'sender_id': currentUserUid,
                                    'message':
                                        '${FFAppState().URL}${'pagename=${widget!.pagename}'}${'&id=${widget!.id}'}',
                                    'e_message_type': 'text',
                                    'islink': true,
                                    'is_read': false,
                                  });
                                  await ChatTable().update(
                                    data: {
                                      'last_message_user': currentUserUid,
                                      'last_message_date':
                                          supaSerialize<DateTime>(
                                              functions.getCurrentUtcTime()),
                                      'last_message':
                                          '${FFAppState().URL}${'pagename=${widget!.pagename}'}${'&id=${widget!.id}'}',
                                    },
                                    matchingRows: (rows) => rows.eqOrNull(
                                      'id',
                                      FindCommonChatCall.chatId(
                                        (_model.chatFoundShare?.jsonBody ?? ''),
                                      ),
                                    ),
                                  );

                                  context.pushNamed(
                                    MessagePageWidget.routeName,
                                    queryParameters: {
                                      'chatId': serializeParam(
                                        FindCommonChatCall.chatId(
                                          (_model.chatFoundShare?.jsonBody ??
                                              ''),
                                        ),
                                        ParamType.String,
                                      ),
                                      'userId': serializeParam(
                                        getJsonField(
                                          usersItem,
                                          r'''$.id''',
                                        ).toString(),
                                        ParamType.String,
                                      ),
                                    }.withoutNulls,
                                  );
                                } else {
                                  _model.chat = await ChatTable().insert({
                                    'community_id': 1,
                                    'first_message_date':
                                        supaSerialize<DateTime>(
                                            functions.getCurrentUtcTime()),
                                    'created_by': currentUserUid,
                                    'chat_type': 'dm',
                                  });
                                  await MessagesTable().insert({
                                    'chat_id': _model.chat?.id,
                                    'community_id': FFAppState().communityId,
                                    'sender_id': currentUserUid,
                                    'message':
                                        '${FFAppState().URL}${'pagename=${widget!.pagename}'}${'&id=${widget!.id}'}',
                                    'e_message_type': 'text',
                                    'islink': true,
                                    'is_read': false,
                                  });
                                  await ChatTable().update(
                                    data: {
                                      'last_message_user': currentUserUid,
                                      'last_message_date':
                                          supaSerialize<DateTime>(
                                              functions.getCurrentUtcTime()),
                                      'last_message':
                                          '${FFAppState().URL}${'pagename=${widget!.pagename}'}${'&id=${widget!.id}'}',
                                    },
                                    matchingRows: (rows) => rows.eqOrNull(
                                      'id',
                                      _model.chat?.id,
                                    ),
                                  );
                                  await AddChatUsersCall.call(
                                    user2: getJsonField(
                                      usersItem,
                                      r'''$.id''',
                                    ).toString(),
                                    communityId: '1',
                                    chatId: _model.chat?.id,
                                    anonKey: FFDevEnvironmentValues().AnonKey,
                                    token: currentJwtToken,
                                  );

                                  context.pushNamed(
                                    MessagePageWidget.routeName,
                                    queryParameters: {
                                      'chatId': serializeParam(
                                        _model.chat?.id,
                                        ParamType.String,
                                      ),
                                      'userId': serializeParam(
                                        getJsonField(
                                          usersItem,
                                          r'''$.id''',
                                        ).toString(),
                                        ParamType.String,
                                      ),
                                    }.withoutNulls,
                                  );
                                }

                                safeSetState(() {});
                              },
                              child: Container(
                                width: 64.0,
                                height: 120.0,
                                decoration: BoxDecoration(),
                                child: Container(
                                  decoration: BoxDecoration(),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 64.0,
                                        height: 64.0,
                                        clipBehavior: Clip.antiAlias,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                        ),
                                        child: Image.network(
                                          getJsonField(
                                            usersItem,
                                            r'''$.profile_picture''',
                                          ).toString(),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      Text(
                                        getJsonField(
                                          usersItem,
                                          r'''$.name''',
                                        ).toString(),
                                        textAlign: TextAlign.center,
                                        maxLines: 2,
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
                                                      .greyD1,
                                              fontSize: 12.0,
                                              letterSpacing: 0.0,
                                              fontWeight: FontWeight.w500,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontStyle,
                                              lineHeight: 1.3,
                                            ),
                                      ),
                                    ]
                                        .divide(SizedBox(height: 2.0))
                                        .addToStart(SizedBox(height: 5.0))
                                        .addToEnd(SizedBox(height: 5.0)),
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Expanded(
                        child: Container(
                          height: 1.0,
                          decoration: BoxDecoration(
                            color: FlutterFlowTheme.of(context).greyL2,
                          ),
                        ),
                      ),
                      Text(
                        'or',
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
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
                      Expanded(
                        child: Container(
                          height: 1.0,
                          decoration: BoxDecoration(
                            color: FlutterFlowTheme.of(context).greyL2,
                          ),
                        ),
                      ),
                    ].divide(SizedBox(width: 12.0)),
                  ),
                ),
                Builder(
                  builder: (context) => FFButtonWidget(
                    onPressed: () async {
                      await UpdatePostShareCountCall.call(
                        token: currentJwtToken,
                        pCommunityid: FFAppState().communityId.toString(),
                        pUserid: currentUserUid,
                        pPostid: widget!.id,
                      );

                      await Share.share(
                        '${FFAppState().URL}${'pagename=${widget!.pagename}'}${'&id=${widget!.id}'}',
                        sharePositionOrigin: getWidgetBoundingBox(context),
                      );
                    },
                    text: 'Share via',
                    options: FFButtonOptions(
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
                ),
              ].divide(SizedBox(height: 24.0)),
            ),
          ].addToStart(SizedBox(height: 8.0)).addToEnd(SizedBox(height: 24.0)),
        ),
      ),
    );
  }
}
