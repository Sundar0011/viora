import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/custom_code/actions/index.dart' as actions;
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'comp_invite_model.dart';
export 'comp_invite_model.dart';

class CompInviteWidget extends StatefulWidget {
  const CompInviteWidget({super.key});

  @override
  State<CompInviteWidget> createState() => _CompInviteWidgetState();
}

class _CompInviteWidgetState extends State<CompInviteWidget> {
  late CompInviteModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => CompInviteModel());

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
                        'Invite using',
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              font: GoogleFonts.manrope(
                                fontWeight: FontWeight.w600,
                                fontStyle: FlutterFlowTheme.of(
                                  context,
                                ).bodyMedium.fontStyle,
                              ),
                              color: FlutterFlowTheme.of(context).extraBlack,
                              fontSize: 18.0,
                              letterSpacing: 0.0,
                              fontWeight: FontWeight.w600,
                              fontStyle: FlutterFlowTheme.of(
                                context,
                              ).bodyMedium.fontStyle,
                              lineHeight: 1.4,
                            ),
                      ),
                    ].divide(SizedBox(width: 10.0)),
                  ),
                ),
                Form(
                  key: _model.formKey,
                  autovalidateMode: AutovalidateMode.disabled,
                  child: Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(
                      20.0,
                      0.0,
                      20.0,
                      0.0,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Expanded(
                          child: Container(
                            width: 200.0,
                            child: TextFormField(
                              controller: _model.textController,
                              focusNode: _model.textFieldFocusNode,
                              onChanged: (_) => EasyDebounce.debounce(
                                '_model.textController',
                                Duration(milliseconds: 2000),
                                () async {
                                  if (_model.formKey.currentState != null) {
                                    _model.formKey.currentState!.validate();
                                  }
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
                                        fontStyle: FlutterFlowTheme.of(
                                          context,
                                        ).labelMedium.fontStyle,
                                      ),
                                      color: FlutterFlowTheme.of(
                                        context,
                                      ).greyL4,
                                      letterSpacing: 0.0,
                                      fontWeight: FontWeight.w500,
                                      fontStyle: FlutterFlowTheme.of(
                                        context,
                                      ).labelMedium.fontStyle,
                                      lineHeight: 1.3,
                                    ),
                                hintText: 'Enter email Address',
                                hintStyle: FlutterFlowTheme.of(context)
                                    .labelMedium
                                    .override(
                                      font: GoogleFonts.manrope(
                                        fontWeight: FontWeight.w500,
                                        fontStyle: FlutterFlowTheme.of(
                                          context,
                                        ).labelMedium.fontStyle,
                                      ),
                                      color: FlutterFlowTheme.of(
                                        context,
                                      ).greyL4,
                                      letterSpacing: 0.0,
                                      fontWeight: FontWeight.w500,
                                      fontStyle: FlutterFlowTheme.of(
                                        context,
                                      ).labelMedium.fontStyle,
                                      lineHeight: 1.3,
                                    ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: FlutterFlowTheme.of(context).greyL2,
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
                                fillColor:
                                    FlutterFlowTheme.of(context).alternate,
                                contentPadding: EdgeInsetsDirectional.fromSTEB(
                                  12.0,
                                  16.0,
                                  12.0,
                                  16.0,
                                ),
                              ),
                              style: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                    font: GoogleFonts.manrope(
                                      fontWeight: FontWeight.w500,
                                      fontStyle: FlutterFlowTheme.of(
                                        context,
                                      ).bodyMedium.fontStyle,
                                    ),
                                    color: FlutterFlowTheme.of(
                                      context,
                                    ).primaryText,
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.w500,
                                    fontStyle: FlutterFlowTheme.of(
                                      context,
                                    ).bodyMedium.fontStyle,
                                    lineHeight: 1.3,
                                  ),
                              cursorColor: FlutterFlowTheme.of(
                                context,
                              ).primaryText,
                              validator: _model.textControllerValidator
                                  .asValidator(context),
                            ),
                          ),
                        ),
                        FFButtonWidget(
                          onPressed: () async {
                            if (_model.formKey.currentState == null ||
                                !_model.formKey.currentState!.validate()) {
                              return;
                            }
                            _model.ostype = await actions.findOsAction();
                            if (_model.ostype == 'iOS') {
                              await launchUrl(
                                Uri(
                                  scheme: 'mailto',
                                  path: _model.textController.text,
                                  query: {
                                    'subject':
                                        'hey ,I found this amazing application called Flock',
                                    'body':
                                        'Here , is the download link . https://apps.apple.com/app/squadd/id6752684914',
                                  }
                                      .entries
                                      .map(
                                        (MapEntry<String, String> e) =>
                                            '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}',
                                      )
                                      .join('&'),
                                ),
                              );
                            } else {
                              await launchUrl(
                                Uri(
                                  scheme: 'mailto',
                                  path: _model.textController.text,
                                  query: {
                                    'subject':
                                        'hey ,I found this amazing application called Flock',
                                    'body':
                                        'Here , is the download link . https://play.google.com/store/apps/details?id=com.viora.app',
                                  }
                                      .entries
                                      .map(
                                        (MapEntry<String, String> e) =>
                                            '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}',
                                      )
                                      .join('&'),
                                ),
                              );
                            }

                            safeSetState(() {});
                          },
                          text: 'Send',
                          options: FFButtonOptions(
                            height: 40.0,
                            padding: EdgeInsetsDirectional.fromSTEB(
                              16.0,
                              12.0,
                              16.0,
                              12.0,
                            ),
                            iconPadding: EdgeInsetsDirectional.fromSTEB(
                              0.0,
                              0.0,
                              0.0,
                              0.0,
                            ),
                            color: FlutterFlowTheme.of(context).primary,
                            textStyle: FlutterFlowTheme.of(context)
                                .titleSmall
                                .override(
                                  font: GoogleFonts.manrope(
                                    fontWeight: FlutterFlowTheme.of(
                                      context,
                                    ).titleSmall.fontWeight,
                                    fontStyle: FlutterFlowTheme.of(
                                      context,
                                    ).titleSmall.fontStyle,
                                  ),
                                  color: Colors.white,
                                  letterSpacing: 0.0,
                                  fontWeight: FlutterFlowTheme.of(
                                    context,
                                  ).titleSmall.fontWeight,
                                  fontStyle: FlutterFlowTheme.of(
                                    context,
                                  ).titleSmall.fontStyle,
                                  lineHeight: 1.4,
                                ),
                            elevation: 0.0,
                            borderRadius: BorderRadius.circular(24.0),
                          ),
                        ),
                      ].divide(SizedBox(width: 10.0)),
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
                                fontStyle: FlutterFlowTheme.of(
                                  context,
                                ).bodyMedium.fontStyle,
                              ),
                              color: FlutterFlowTheme.of(context).greyD1,
                              letterSpacing: 0.0,
                              fontWeight: FontWeight.w500,
                              fontStyle: FlutterFlowTheme.of(
                                context,
                              ).bodyMedium.fontStyle,
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
                      _model.findos4 = await actions.findOsAction();
                      await Share.share(
                        _model.findos4 == 'iOS'
                            ? 'https://apps.apple.com/app/squadd/id6752684914'
                            : 'https://play.google.com/store/apps/details?id=com.viora.app',
                        sharePositionOrigin: getWidgetBoundingBox(context),
                      );

                      safeSetState(() {});
                    },
                    text: 'Share via',
                    options: FFButtonOptions(
                      height: 40.0,
                      padding: EdgeInsetsDirectional.fromSTEB(
                        16.0,
                        0.0,
                        16.0,
                        0.0,
                      ),
                      iconPadding: EdgeInsetsDirectional.fromSTEB(
                        0.0,
                        0.0,
                        0.0,
                        0.0,
                      ),
                      color: FlutterFlowTheme.of(context).primary,
                      textStyle:
                          FlutterFlowTheme.of(context).titleSmall.override(
                                font: GoogleFonts.manrope(
                                  fontWeight: FlutterFlowTheme.of(
                                    context,
                                  ).titleSmall.fontWeight,
                                  fontStyle: FlutterFlowTheme.of(
                                    context,
                                  ).titleSmall.fontStyle,
                                ),
                                color: Colors.white,
                                letterSpacing: 0.0,
                                fontWeight: FlutterFlowTheme.of(
                                  context,
                                ).titleSmall.fontWeight,
                                fontStyle: FlutterFlowTheme.of(
                                  context,
                                ).titleSmall.fontStyle,
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
