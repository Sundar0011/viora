import '/auth/supabase_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_timer.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/custom_code/actions/index.dart' as actions;
import '/custom_code/widgets/index.dart' as custom_widgets;
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'verify_page_model.dart';
export 'verify_page_model.dart';

class VerifyPageWidget extends StatefulWidget {
  const VerifyPageWidget({
    super.key,
    required this.verifiedByEmailOrMobile,
    required this.emailOrMobileNumber,
    required this.verifyType,
  });

  final String? verifiedByEmailOrMobile;
  final String? emailOrMobileNumber;
  final String? verifyType;

  static String routeName = 'VerifyPage';
  static String routePath = 'verifyPage';

  @override
  State<VerifyPageWidget> createState() => _VerifyPageWidgetState();
}

class _VerifyPageWidgetState extends State<VerifyPageWidget> {
  late VerifyPageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => VerifyPageModel());

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      _model.timerController.onStartTimer();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
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
        backgroundColor: FlutterFlowTheme.of(context).white,
        body: Container(
          decoration: BoxDecoration(),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: FlutterFlowTheme.of(context).white,
                  ),
                  child: SafeArea(
                    top: true,
                    bottom: true,
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Align(
                          alignment: AlignmentDirectional(-1.0, 0.0),
                          child: Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                10.0, 0.0, 0.0, 12.0),
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
                        ),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                20.0, 0.0, 20.0, 0.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Column(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Text(
                                      'VERIFY CODE',
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                            font: GoogleFonts.manrope(
                                              fontWeight: FontWeight.bold,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontStyle,
                                            ),
                                            color: FlutterFlowTheme.of(context)
                                                .extraBlack,
                                            fontSize: 24.0,
                                            letterSpacing: 0.0,
                                            fontWeight: FontWeight.bold,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMedium
                                                    .fontStyle,
                                            lineHeight: 1.4,
                                          ),
                                    ),
                                    Column(
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        Text(
                                          'Please enter code we just sent to',
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
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .greyL4,
                                                letterSpacing: 0.0,
                                                fontWeight: FontWeight.w600,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontStyle,
                                                lineHeight: 1.4,
                                              ),
                                        ),
                                        Text(
                                          valueOrDefault<String>(
                                            functions.maskContactInfo(
                                                widget!.emailOrMobileNumber!),
                                            '+919003985212',
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
                                                color:
                                                    FlutterFlowTheme.of(context)
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
                                      ],
                                    ),
                                  ].divide(SizedBox(height: 12.0)),
                                ),
                                Column(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Container(
                                      width: double.infinity,
                                      height: 52.0,
                                      child: custom_widgets.CustomPinCode(
                                        width: double.infinity,
                                        height: 52.0,
                                      ),
                                    ),
                                    if (_model.pinCodeError)
                                      Align(
                                        alignment:
                                            AlignmentDirectional(-1.0, 0.0),
                                        child: Text(
                                          _model.errorMessage,
                                          style: FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .override(
                                                font: GoogleFonts.manrope(
                                                  fontWeight: FontWeight.w500,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMedium
                                                          .fontStyle,
                                                ),
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .redColor2,
                                                letterSpacing: 0.0,
                                                fontWeight: FontWeight.w500,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
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
                                                .greyL4,
                                            letterSpacing: 0.0,
                                            fontWeight: FontWeight.w600,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
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
                                            splashColor:
                                                FlutterFlowTheme.of(context)
                                                    .primary
                                                    .withAlpha(0x14),
                                            focusColor: Colors.transparent,
                                            hoverColor: Colors.transparent,
                                            highlightColor: Colors.transparent,
                                            onTap: () async {
                                              HapticFeedback.lightImpact();
                                              _model.timerOn = true;
                                              safeSetState(() {});
                                              FFAppState().Otp = '';
                                              safeSetState(() {});
                                              _model.timerController
                                                  .onResetTimer();

                                              _model.timerController
                                                  .onStartTimer();
                                              if (widget!
                                                      .verifiedByEmailOrMobile ==
                                                  'email') {
                                                _model.apiResultr3q1 =
                                                    await SendOtpCall.call(
                                                  anonKey:
                                                      FFDevEnvironmentValues()
                                                          .AnonKey,
                                                  email: widget!
                                                      .emailOrMobileNumber,
                                                  mobileNoCc: '',
                                                );

                                                if ((_model.apiResultr3q1
                                                        ?.succeeded ??
                                                    true)) {
                                                  _model.pinCodeError = false;
                                                  safeSetState(() {});
                                                } else {
                                                  _model.pinCodeError = true;
                                                  _model.errorMessage =
                                                      'OTP limit reached';
                                                  safeSetState(() {});
                                                }
                                              } else {
                                                _model.apiResultr3q =
                                                    await SendOtpCall.call(
                                                  anonKey:
                                                      FFDevEnvironmentValues()
                                                          .AnonKey,
                                                  mobileNoCc: widget!
                                                      .emailOrMobileNumber,
                                                  email: '',
                                                );

                                                if ((_model.apiResultr3q
                                                        ?.succeeded ??
                                                    true)) {
                                                  _model.pinCodeError = false;
                                                  safeSetState(() {});
                                                } else {
                                                  _model.pinCodeError = true;
                                                  _model.errorMessage =
                                                      'OTP limit reached';
                                                  safeSetState(() {});
                                                }
                                              }

                                              safeSetState(() {});
                                            },
                                            child: Text(
                                              'Resend Code',
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
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .extraBlack,
                                                    letterSpacing: 0.0,
                                                    fontWeight: FontWeight.w500,
                                                    fontStyle:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .bodyMedium
                                                            .fontStyle,
                                                    decoration: TextDecoration
                                                        .underline,
                                                    lineHeight: 1.3,
                                                  ),
                                            ),
                                          ),
                                        if (_model.timerOn)
                                          Row(
                                            mainAxisSize: MainAxisSize.max,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                'Resend OTP in ',
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
                                                              .greyD1,
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
                                              FlutterFlowTimer(
                                                initialTime:
                                                    _model.timerInitialTimeMs,
                                                getDisplayTime: (value) =>
                                                    StopWatchTimer
                                                        .getDisplayTime(
                                                  value,
                                                  hours: false,
                                                  minute: false,
                                                  milliSecond: false,
                                                ),
                                                controller:
                                                    _model.timerController,
                                                updateStateInterval: Duration(
                                                    milliseconds: 1000),
                                                onChanged: (value, displayTime,
                                                    shouldUpdate) {
                                                  _model.timerMilliseconds =
                                                      value;
                                                  _model.timerValue =
                                                      displayTime;
                                                  if (shouldUpdate)
                                                    safeSetState(() {});
                                                },
                                                onEnded: () async {
                                                  _model.timerOn = false;
                                                  safeSetState(() {});
                                                },
                                                textAlign: TextAlign.start,
                                                style: FlutterFlowTheme.of(
                                                        context)
                                                    .headlineSmall
                                                    .override(
                                                      font: GoogleFonts.manrope(
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .headlineSmall
                                                                .fontStyle,
                                                      ),
                                                      fontSize: 14.0,
                                                      letterSpacing: 0.0,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontStyle:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .headlineSmall
                                                              .fontStyle,
                                                    ),
                                              ),
                                              Text(
                                                's ',
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
                                                              .greyD1,
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
                                            ],
                                          ),
                                      ],
                                    ),
                                  ].divide(SizedBox(height: 12.0)),
                                ),
                                FFButtonWidget(
                                  onPressed: () async {
                                    if (FFAppState().Otp != null &&
                                        FFAppState().Otp != '') {
                                      HapticFeedback.lightImpact();
                                      _model.pinCodeError = false;
                                      _model.errorMessage = 'Field is requird';
                                      safeSetState(() {});
                                      if (widget!.verifiedByEmailOrMobile ==
                                          'email') {
                                        _model.apiResulth =
                                            await VerifiOtpCall.call(
                                          anonKey:
                                              FFDevEnvironmentValues().AnonKey,
                                          email: widget!.emailOrMobileNumber,
                                          otp: FFAppState().Otp,
                                        );

                                        if ((_model.apiResulth?.succeeded ??
                                            true)) {
                                          if (widget!.verifyType ==
                                              'ForgetPassword') {
                                            context.pushNamed(
                                              ResetPasswordWidget.routeName,
                                              queryParameters: {
                                                'emailOrMobileNumber':
                                                    serializeParam(
                                                  widget!.emailOrMobileNumber,
                                                  ParamType.String,
                                                ),
                                                'isMobile': serializeParam(
                                                  false,
                                                  ParamType.bool,
                                                ),
                                              }.withoutNulls,
                                            );
                                          } else {
                                            await actions.signUpWithEmail(
                                              FFAppState().AsEmail,
                                              FFAppState().AsPassword,
                                              FFAppState().AsPassword,
                                            );
                                            await Future.delayed(
                                              Duration(
                                                milliseconds: 3000,
                                              ),
                                            );
                                            _model.userTable =
                                                await UserTable().insert({
                                              'first_name':
                                                  FFAppState().AsFirstName,
                                              'last_name':
                                                  FFAppState().AsLastName,
                                              'email': FFAppState().AsEmail,
                                              'address': FFAppState().AsAddress,
                                              'city': FFAppState().AsCity,
                                              'flat': FFAppState().AsFlat,
                                              'postal_code':
                                                  FFAppState().AsPostalCode,
                                              'id': currentUserUid,
                                              'onboarding_completed': true,
                                            });
                                            _model.userRole =
                                                await UserRolesTable().insert({
                                              'id': currentUserUid,
                                              'role': 'customer',
                                              'community_id': 1,
                                            });
                                            _model.publicProfile =
                                                await PublicUserProfileTable()
                                                    .insert({
                                              'id': currentUserUid,
                                              'name':
                                                  '${FFAppState().AsFirstName} ${FFAppState().AsLastName}',
                                              'profile_picture':
                                                  FFAppState().AsProfilePicture,
                                              'city': FFAppState().AsCity,
                                              'community_id': 1,
                                              'country': FFAppState().AsCountry,
                                              'cover_image':
                                                  FFAppState().AsCoverImage,
                                            });
                                            _model.locationResult =
                                                await InsertUserLocationCall
                                                    .call(
                                              lat: FFAppState()
                                                  .AsLatitude
                                                  .toString(),
                                              lng: FFAppState()
                                                  .AsLongitude
                                                  .toString(),
                                              placeName: FFAppState().AsCity,
                                              apikey: FFDevEnvironmentValues()
                                                  .AnonKey,
                                              token: currentJwtToken,
                                              pType: 'create',
                                            );

                                            await actions
                                                .setFCMTokenAndUpdateDatabase(
                                              FFDevEnvironmentValues().AnonKey,
                                            );

                                            context.pushNamed(
                                                LoadingPageWidget.routeName);
                                          }

                                          FFAppState().AsPassword = '';
                                          safeSetState(() {});
                                        } else {
                                          _model.pinCodeError = true;
                                          _model.errorMessage =
                                              VerifiOtpCall.error(
                                            (_model.apiResulth?.jsonBody ?? ''),
                                          )!;
                                          safeSetState(() {});
                                        }
                                      } else {
                                        _model.apiResulthvx =
                                            await VerifiOtpCall.call(
                                          anonKey:
                                              FFDevEnvironmentValues().AnonKey,
                                          mobileNoCc:
                                              widget!.emailOrMobileNumber,
                                          otp: FFAppState().Otp,
                                        );

                                        if ((_model.apiResulthvx?.succeeded ??
                                            true)) {
                                          if (widget!.verifyType ==
                                              'ForgetPassword') {
                                            context.pushNamed(
                                              ResetPasswordWidget.routeName,
                                              queryParameters: {
                                                'emailOrMobileNumber':
                                                    serializeParam(
                                                  widget!.emailOrMobileNumber,
                                                  ParamType.String,
                                                ),
                                                'isMobile': serializeParam(
                                                  true,
                                                  ParamType.bool,
                                                ),
                                              }.withoutNulls,
                                            );
                                          } else {
                                            _model.phoneSignUp =
                                                await PhoneSignupCall.call(
                                              phone:
                                                  '${FFAppState().AsCountryCode}${FFAppState().AsMobileNumer}',
                                              password: FFAppState().AsPassword,
                                              confiremPassword:
                                                  FFAppState().AsPassword,
                                            );

                                            await Future.delayed(
                                              Duration(
                                                milliseconds: 1000,
                                              ),
                                            );
                                            _model.phoneLogin =
                                                await actions.signInWithPhone(
                                              '${FFAppState().AsCountryCode}${FFAppState().AsMobileNumer}',
                                              FFAppState().AsPassword,
                                            );
                                            await Future.delayed(
                                              Duration(
                                                milliseconds: 3000,
                                              ),
                                            );
                                            _model.user =
                                                await UserTable().insert({
                                              'first_name':
                                                  FFAppState().AsFirstName,
                                              'last_name':
                                                  FFAppState().AsLastName,
                                              'address': FFAppState().AsAddress,
                                              'city': FFAppState().AsCity,
                                              'flat': FFAppState().AsFlat,
                                              'postal_code':
                                                  FFAppState().AsPostalCode,
                                              'id': currentUserUid,
                                              'mobile_number':
                                                  FFAppState().AsMobileNumer,
                                              'mobile_number_cc':
                                                  '${FFAppState().AsCountryCode}${FFAppState().AsMobileNumer}',
                                              'onboarding_completed': true,
                                            });
                                            _model.role =
                                                await UserRolesTable().insert({
                                              'id': currentUserUid,
                                              'role': 'customer',
                                              'community_id': 1,
                                            });
                                            _model.profile =
                                                await PublicUserProfileTable()
                                                    .insert({
                                              'id': currentUserUid,
                                              'name':
                                                  '${FFAppState().AsFirstName} ${FFAppState().AsLastName}',
                                              'profile_picture':
                                                  FFAppState().AsProfilePicture,
                                              'city': FFAppState().AsCity,
                                              'community_id': 1,
                                              'country': FFAppState().AsCountry,
                                            });
                                            _model.locationResult3 =
                                                await InsertUserLocationCall
                                                    .call(
                                              lat: FFAppState()
                                                  .AsLatitude
                                                  .toString(),
                                              lng: FFAppState()
                                                  .AsLongitude
                                                  .toString(),
                                              placeName: FFAppState().AsCity,
                                              apikey: FFDevEnvironmentValues()
                                                  .AnonKey,
                                              token: currentJwtToken,
                                              pType: 'create',
                                            );

                                            await actions
                                                .setFCMTokenAndUpdateDatabase(
                                              FFDevEnvironmentValues().AnonKey,
                                            );

                                            context.pushNamed(
                                                LoadingPageWidget.routeName);
                                          }

                                          FFAppState().AsPassword = '';
                                          safeSetState(() {});
                                        } else {
                                          _model.pinCodeError = true;
                                          _model.errorMessage =
                                              VerifiOtpCall.error(
                                            (_model.apiResulthvx?.jsonBody ??
                                                ''),
                                          )!;
                                          safeSetState(() {});
                                        }
                                      }
                                    } else {
                                      HapticFeedback.lightImpact();
                                      _model.pinCodeError = true;
                                      _model.errorMessage = 'Field is requird';
                                      safeSetState(() {});
                                    }

                                    safeSetState(() {});
                                  },
                                  text: 'Verify',
                                  options: FFButtonOptions(
                                    width: double.infinity,
                                    height: 46.0,
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        16.0, 12.0, 16.0, 12.0),
                                    iconPadding: EdgeInsetsDirectional.fromSTEB(
                                        0.0, 0.0, 0.0, 0.0),
                                    color: FlutterFlowTheme.of(context).primary,
                                    textStyle: FlutterFlowTheme.of(context)
                                        .titleSmall
                                        .override(
                                          font: GoogleFonts.manrope(
                                            fontWeight:
                                                FlutterFlowTheme.of(context)
                                                    .titleSmall
                                                    .fontWeight,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .titleSmall
                                                    .fontStyle,
                                          ),
                                          color: Colors.white,
                                          letterSpacing: 0.0,
                                          fontWeight:
                                              FlutterFlowTheme.of(context)
                                                  .titleSmall
                                                  .fontWeight,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .titleSmall
                                                  .fontStyle,
                                          lineHeight: 1.4,
                                        ),
                                    elevation: 0.0,
                                    borderRadius: BorderRadius.circular(24.0),
                                  ),
                                ),
                              ]
                                  .divide(SizedBox(height: 36.0))
                                  .addToStart(SizedBox(height: 40.0)),
                            ),
                          ),
                        ),
                      ],
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
