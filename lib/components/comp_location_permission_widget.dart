import '/auth/supabase_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/custom_code/actions/index.dart' as actions;
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'comp_location_permission_model.dart';
export 'comp_location_permission_model.dart';

class CompLocationPermissionWidget extends StatefulWidget {
  const CompLocationPermissionWidget({super.key});

  @override
  State<CompLocationPermissionWidget> createState() =>
      _CompLocationPermissionWidgetState();
}

class _CompLocationPermissionWidgetState
    extends State<CompLocationPermissionWidget> {
  late CompLocationPermissionModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => CompLocationPermissionModel());
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
      height: 400.0,
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.0),
          topRight: Radius.circular(24.0),
        ),
      ),
      child: Padding(
        padding: EdgeInsetsDirectional.fromSTEB(0.0, 20.0, 0.0, 0.0),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Align(
              alignment: AlignmentDirectional(-1.0, 0.0),
              child: Padding(
                padding: EdgeInsetsDirectional.fromSTEB(10.0, 0.0, 0.0, 12.0),
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
                padding: EdgeInsetsDirectional.fromSTEB(20.0, 0.0, 20.0, 10.0),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(0.0),
                      child: Image.asset(
                        'assets/images/_https___app.lottiefiles.com_animation_9579b23c-d344-48bf-9c62-d6eac9f62f09.gif',
                        width: 140.0,
                        height: 140.0,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Text(
                      'Your home address is used to place you in the right neighbourhood. We won\'t share it without your permission.',
                      textAlign: TextAlign.center,
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            font: GoogleFonts.manrope(
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
                    FFButtonWidget(
                      onPressed: () async {
                        _model.userGiveAccess = await actions.userLocation();
                        if (_model.userGiveAccess == true) {
                          _model.locationResult =
                              await InsertUserLocationCall.call(
                            lat: FFAppState().AsLatitude.toString(),
                            lng: FFAppState().AsLongitude.toString(),
                            placeName: FFAppState().AsCity,
                            apikey: FFDevEnvironmentValues().AnonKey,
                            token: currentJwtToken,
                            pType: 'update',
                          );

                          _model.following =
                              await GetNeighborhoodPeoplesCall.call(
                            pUserid: currentUserUid,
                            token: currentJwtToken,
                            pCommunityid: FFAppState().communityId,
                          );

                          await PublicUserProfileTable().update(
                            data: {
                              'city': FFAppState().AsCity,
                              'country': FFAppState().AsCountry,
                            },
                            matchingRows: (rows) => rows.eqOrNull(
                              'id',
                              currentUserUid,
                            ),
                          );
                          FFAppState().neighbourhoodUsers =
                              (_model.following?.jsonBody ?? '');
                          _model.updatePage(() {});

                          context.goNamed(NeighborhoodsWidget.routeName);
                        }

                        safeSetState(() {});
                      },
                      text: 'Allow Location Access',
                      options: FFButtonOptions(
                        width: double.infinity,
                        height: 46.0,
                        padding: EdgeInsetsDirectional.fromSTEB(
                            16.0, 12.0, 16.0, 12.0),
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
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
