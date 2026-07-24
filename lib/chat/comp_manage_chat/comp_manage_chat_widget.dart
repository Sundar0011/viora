import '/chat/comp_new_message/comp_new_message_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'comp_manage_chat_model.dart';
export 'comp_manage_chat_model.dart';

class CompManageChatWidget extends StatefulWidget {
  const CompManageChatWidget({
    super.key,
    required this.opt,
  });

  final String? opt;

  @override
  State<CompManageChatWidget> createState() => _CompManageChatWidgetState();
}

class _CompManageChatWidgetState extends State<CompManageChatWidget> {
  late CompManageChatModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => CompManageChatModel());
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
            Align(
              alignment: AlignmentDirectional(0.0, 1.0),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if ((('${getJsonField(
                                FFAppState().matchedUsers,
                                r'''$''',
                              ).toString()}' !=
                              '[]') &&
                          (widget!.opt == 'all')) ||
                      ((widget!.opt == 'dms') &&
                          ('${getJsonField(
                                FFAppState().matchedUsers,
                                r'''$[0].total_dm_chats''',
                              ).toString()}' !=
                              '0')) ||
                      ((widget!.opt == 'forsale') &&
                          ('${getJsonField(
                                FFAppState().matchedUsers,
                                r'''$[0].total_sale_chats''',
                              ).toString()}' !=
                              '0')))
                    InkWell(
                      splashColor:
                          FlutterFlowTheme.of(context).primary.withAlpha(0x14),
                      focusColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onTap: () async {
                        context.pushNamed(
                          ChatWidget.routeName,
                          queryParameters: {
                            'selectMessage': serializeParam(
                              true,
                              ParamType.bool,
                            ),
                          }.withoutNulls,
                        );

                        Navigator.pop(context);
                      },
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(),
                        child: Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              16.0, 7.0, 16.0, 7.0),
                          child: Text(
                            'Select chats',
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
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
                        ),
                      ),
                    ),
                  InkWell(
                    splashColor:
                        FlutterFlowTheme.of(context).primary.withAlpha(0x14),
                    focusColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onTap: () async {
                      await showModalBottomSheet(
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        context: context,
                        builder: (context) {
                          return Padding(
                            padding: MediaQuery.viewInsetsOf(context),
                            child: CompNewMessageWidget(),
                          );
                        },
                      ).then((value) => safeSetState(() {}));

                      Navigator.pop(context);
                    },
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(),
                      child: Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(
                            16.0, 7.0, 16.0, 7.0),
                        child: Text(
                          'New Chat',
                          style:
                              FlutterFlowTheme.of(context).bodyMedium.override(
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
                      ),
                    ),
                  ),
                ].addToStart(SizedBox(height: 16.0)),
              ),
            ),
          ].addToStart(SizedBox(height: 8.0)).addToEnd(SizedBox(height: 24.0)),
        ),
      ),
    );
  }
}
