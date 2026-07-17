import '/auth/supabase_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_timer.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/custom_code/widgets/index.dart' as custom_widgets;
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'comp_verify_model.dart';
export 'comp_verify_model.dart';

class CompVerifyWidget extends StatefulWidget {
  const CompVerifyWidget({
    super.key,
    this.content,
  });

  final String? content;

  @override
  State<CompVerifyWidget> createState() => _CompVerifyWidgetState();
}

class _CompVerifyWidgetState extends State<CompVerifyWidget> {
  late CompVerifyModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => CompVerifyModel());

    // On component load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      _model.timerController.onStartTimer();
      if (FFAppState().AsEmail != 'null') {
        _model.apiResultr3q1Copy12 = await SendOtpCall.call(
          anonKey: FFDevEnvironmentValues().AnonKey,
          email: FFAppState().AsEmail,
          mobileNoCc:
              '${FFAppState().AsCountryCode}${FFAppState().AsMobileNumer}',
        );

        if ((_model.apiResultr3q1Copy12?.succeeded ?? true)) {
          _model.showError = false;
          safeSetState(() {});
        } else {
          _model.errorMessage = 'OTP limit reached';
          _model.showError = true;
          safeSetState(() {});
        }
      } else {
        _model.mobileOtpCopy34 = await SendOtpCall.call(
          anonKey: FFDevEnvironmentValues().AnonKey,
          mobileNoCc:
              '${FFAppState().AsCountryCode}${FFAppState().AsMobileNumer}',
          email: currentUserEmail,
        );

        if ((_model.mobileOtpCopy34?.succeeded ?? true)) {
          _model.showError = false;
          safeSetState(() {});
        } else {
          _model.showError = true;
          _model.errorMessage = 'OTP limit reached';
          safeSetState(() {});
        }
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
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
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      InkWell(
                        splashColor: Colors.transparent,
                        focusColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onTap: () async {
                          Navigator.pop(context);
                        },
                        child: Icon(
                          Icons.arrow_back,
                          color: FlutterFlowTheme.of(context).primaryText,
                          size: 24.0,
                        ),
                      ),
                      Text(
                        'Delete Account',
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
                  RichText(
                    textScaler: MediaQuery.of(context).textScaler,
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text:
                              'To delete this account, you have to enter the code we have sent to ',
                          style: GoogleFonts.manrope(
                            color: FlutterFlowTheme.of(context).greyL4,
                            fontWeight: FontWeight.w600,
                            fontSize: 16.0,
                            height: 1.4,
                          ),
                        ),
                        TextSpan(
                          text: valueOrDefault<String>(
                            functions.maskContactInfo(
                                FFAppState().AsEmail != 'null'
                                    ? FFAppState().AsEmail
                                    : FFAppState().AsMobileNumer),
                            'Email Or Moblie',
                          ),
                          style: GoogleFonts.manrope(
                            color: FlutterFlowTheme.of(context).extraBlack,
                            fontWeight: FontWeight.w600,
                            fontSize: 16.0,
                            height: 1.4,
                          ),
                        ),
                        TextSpan(
                          text:
                              '. You will not be able to access the contents of this account after deleting.',
                          style: GoogleFonts.manrope(
                            color: FlutterFlowTheme.of(context).greyL4,
                            fontWeight: FontWeight.w600,
                            fontSize: 16.0,
                            height: 1.4,
                          ),
                        )
                      ],
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            font: GoogleFonts.inter(
                              fontWeight: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .fontWeight,
                              fontStyle: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .fontStyle,
                            ),
                            letterSpacing: 0.0,
                            fontWeight: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .fontWeight,
                            fontStyle: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .fontStyle,
                          ),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Container(
                        width: double.infinity,
                        height: 50.0,
                        child: custom_widgets.CustomPinCode(
                          width: double.infinity,
                          height: 50.0,
                        ),
                      ),
                      if (_model.showError)
                        Align(
                          alignment: AlignmentDirectional(-1.0, 0.0),
                          child: Text(
                            valueOrDefault<String>(
                              _model.errorMessage,
                              'Error',
                            ),
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  font: GoogleFonts.manrope(
                                    fontWeight: FontWeight.w500,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontStyle,
                                  ),
                                  color: FlutterFlowTheme.of(context).redColor2,
                                  letterSpacing: 0.0,
                                  fontWeight: FontWeight.w500,
                                  fontStyle: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .fontStyle,
                                  lineHeight: 1.4,
                                ),
                          ),
                        ),
                    ],
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Text(
                        'Didn’t receive OTP yet?',
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              font: GoogleFonts.manrope(
                                fontWeight: FontWeight.w600,
                                fontStyle: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .fontStyle,
                              ),
                              color: FlutterFlowTheme.of(context).greyL4,
                              letterSpacing: 0.0,
                              fontWeight: FontWeight.w600,
                              fontStyle: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .fontStyle,
                              lineHeight: 1.4,
                            ),
                      ),
                      Stack(
                        alignment: AlignmentDirectional(0.0, 0.0),
                        children: [
                          if (_model.timerOn == false)
                            InkWell(
                              splashColor: Colors.transparent,
                              focusColor: Colors.transparent,
                              hoverColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              onTap: () async {
                                _model.timerOn = true;
                                safeSetState(() {});
                                _model.timerController.onResetTimer();

                                _model.timerController.onStartTimer();
                                if (FFAppState().AsEmail != null &&
                                    FFAppState().AsEmail != '') {
                                  _model.apiResultr3q1 = await SendOtpCall.call(
                                    anonKey: FFDevEnvironmentValues().AnonKey,
                                    email: FFAppState().AsEmail,
                                    mobileNoCc:
                                        '${FFAppState().AsCountryCode}${FFAppState().AsMobileNumer}',
                                  );

                                  if ((_model.apiResultr3q1?.succeeded ??
                                      true)) {
                                    _model.showError = false;
                                    safeSetState(() {});
                                  } else {
                                    _model.errorMessage = 'OTP limit reached';
                                    _model.showError = true;
                                    safeSetState(() {});
                                  }
                                } else {
                                  _model.mobileOtp = await SendOtpCall.call(
                                    anonKey: FFDevEnvironmentValues().AnonKey,
                                    mobileNoCc:
                                        '${FFAppState().AsCountryCode}${FFAppState().AsMobileNumer}',
                                    email: currentUserEmail,
                                  );

                                  if ((_model.mobileOtp?.succeeded ?? true)) {
                                    _model.showError = false;
                                    safeSetState(() {});
                                  } else {
                                    _model.showError = true;
                                    _model.errorMessage = 'OTP limit reached';
                                    safeSetState(() {});
                                  }
                                }

                                safeSetState(() {});
                              },
                              child: Text(
                                'Resend Code',
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                      font: GoogleFonts.manrope(
                                        fontWeight: FontWeight.w500,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .fontStyle,
                                      ),
                                      color: FlutterFlowTheme.of(context)
                                          .extraBlack,
                                      letterSpacing: 0.0,
                                      fontWeight: FontWeight.w500,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontStyle,
                                      decoration: TextDecoration.underline,
                                      lineHeight: 1.3,
                                    ),
                              ),
                            ),
                          if (_model.timerOn)
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Resend OTP in ',
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
                                            FlutterFlowTheme.of(context).greyD1,
                                        letterSpacing: 0.0,
                                        fontWeight: FontWeight.w500,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .fontStyle,
                                        lineHeight: 1.4,
                                      ),
                                ),
                                FlutterFlowTimer(
                                  initialTime: _model.timerInitialTimeMs,
                                  getDisplayTime: (value) =>
                                      StopWatchTimer.getDisplayTime(
                                    value,
                                    hours: false,
                                    minute: false,
                                    milliSecond: false,
                                  ),
                                  controller: _model.timerController,
                                  updateStateInterval:
                                      Duration(milliseconds: 1000),
                                  onChanged:
                                      (value, displayTime, shouldUpdate) {
                                    _model.timerMilliseconds = value;
                                    _model.timerValue = displayTime;
                                    if (shouldUpdate) safeSetState(() {});
                                  },
                                  onEnded: () async {
                                    _model.timerOn = false;
                                    safeSetState(() {});
                                  },
                                  textAlign: TextAlign.start,
                                  style: FlutterFlowTheme.of(context)
                                      .headlineSmall
                                      .override(
                                        font: GoogleFonts.interTight(
                                          fontWeight: FontWeight.w500,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .headlineSmall
                                                  .fontStyle,
                                        ),
                                        fontSize: 14.0,
                                        letterSpacing: 0.0,
                                        fontWeight: FontWeight.w500,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .headlineSmall
                                            .fontStyle,
                                      ),
                                ),
                                Text(
                                  's ',
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
                                            FlutterFlowTheme.of(context).greyD1,
                                        letterSpacing: 0.0,
                                        fontWeight: FontWeight.w500,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .fontStyle,
                                        lineHeight: 1.4,
                                      ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ].divide(SizedBox(height: 12.0)),
                  ),
                  Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(0.0, 8.0, 0.0, 0.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Expanded(
                          child: FFButtonWidget(
                            onPressed: () async {
                              Function() _navigate = () {};
                              if (FFAppState().Otp != null &&
                                  FFAppState().Otp != '') {
                                _model.errorMessage = null;
                                _model.showError = false;
                                safeSetState(() {});
                                if (FFAppState().AsEmail != 'null') {
                                  _model.apiResulth23 =
                                      await VerifiOtpCall.call(
                                    anonKey: FFDevEnvironmentValues().AnonKey,
                                    email: FFAppState().AsEmail,
                                    otp: FFAppState().Otp,
                                  );

                                  if ((_model.apiResulth23?.succeeded ??
                                      true)) {
                                    await UserTable().update(
                                      data: {
                                        'is_deleted': true,
                                        'reason': widget!.content,
                                        'status': 'removed',
                                      },
                                      matchingRows: (rows) => rows.eqOrNull(
                                        'id',
                                        currentUserUid,
                                      ),
                                    );
                                    GoRouter.of(context).prepareAuthEvent();
                                    await authManager.signOut();
                                    GoRouter.of(context)
                                        .clearRedirectLocation();

                                    _navigate = () => context.goNamedAuth(
                                        SplashWidget.routeName,
                                        context.mounted);
                                  } else {
                                    _model.errorMessage = VerifiOtpCall.error(
                                      (_model.apiResulth23?.jsonBody ?? ''),
                                    );
                                    _model.showError = true;
                                    safeSetState(() {});
                                  }
                                } else {
                                  _model.apiResulthvx234 =
                                      await VerifiOtpCall.call(
                                    anonKey: FFDevEnvironmentValues().AnonKey,
                                    mobileNoCc:
                                        '${FFAppState().AsCountryCode}${FFAppState().AsMobileNumer}',
                                    otp: FFAppState().Otp,
                                  );

                                  if ((_model.apiResulthvx234?.succeeded ??
                                      true)) {
                                    await UserTable().update(
                                      data: {
                                        'is_deleted': true,
                                        'reason': widget!.content,
                                        'status': 'removed',
                                      },
                                      matchingRows: (rows) => rows.eqOrNull(
                                        'id',
                                        currentUserUid,
                                      ),
                                    );
                                    GoRouter.of(context).prepareAuthEvent();
                                    await authManager.signOut();
                                    GoRouter.of(context)
                                        .clearRedirectLocation();

                                    _navigate = () => context.goNamedAuth(
                                        SplashWidget.routeName,
                                        context.mounted);
                                  } else {
                                    _model.errorMessage = VerifiOtpCall.error(
                                      (_model.apiResulthvx234?.jsonBody ?? ''),
                                    );
                                    _model.showError = true;
                                    safeSetState(() {});
                                  }
                                }
                              } else {
                                _model.errorMessage = 'Field is requird';
                                _model.showError = true;
                                safeSetState(() {});
                              }

                              _navigate();

                              safeSetState(() {});
                            },
                            text: 'continue?',
                            options: FFButtonOptions(
                              height: 40.0,
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  16.0, 0.0, 16.0, 0.0),
                              iconPadding: EdgeInsetsDirectional.fromSTEB(
                                  0.0, 0.0, 0.0, 0.0),
                              color: FlutterFlowTheme.of(context).greyL2,
                              textStyle: FlutterFlowTheme.of(context)
                                  .titleSmall
                                  .override(
                                    font: GoogleFonts.manrope(
                                      fontWeight: FlutterFlowTheme.of(context)
                                          .titleSmall
                                          .fontWeight,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .titleSmall
                                          .fontStyle,
                                    ),
                                    color:
                                        FlutterFlowTheme.of(context).extraBlack,
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
                        Expanded(
                          child: FFButtonWidget(
                            onPressed: () async {
                              Navigator.pop(context);
                            },
                            text: 'cancel',
                            options: FFButtonOptions(
                              height: 40.0,
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  16.0, 0.0, 16.0, 0.0),
                              iconPadding: EdgeInsetsDirectional.fromSTEB(
                                  0.0, 0.0, 0.0, 0.0),
                              color: FlutterFlowTheme.of(context).primaryD4,
                              textStyle: FlutterFlowTheme.of(context)
                                  .titleSmall
                                  .override(
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
                      ].divide(SizedBox(width: 12.0)),
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
