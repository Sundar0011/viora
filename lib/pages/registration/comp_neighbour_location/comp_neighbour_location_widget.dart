import '/auth/supabase_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/index.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'comp_neighbour_location_model.dart';
export 'comp_neighbour_location_model.dart';

class CompNeighbourLocationWidget extends StatefulWidget {
  const CompNeighbourLocationWidget({
    super.key,
    required this.pageName,
  });

  final String? pageName;

  @override
  State<CompNeighbourLocationWidget> createState() =>
      _CompNeighbourLocationWidgetState();
}

class _CompNeighbourLocationWidgetState
    extends State<CompNeighbourLocationWidget> {
  late CompNeighbourLocationModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => CompNeighbourLocationModel());

    _model.textController1 ??= TextEditingController();
    _model.textFieldFocusNode1 ??= FocusNode();
    _model.textFieldFocusNode1!.addListener(
      () async {
        if (_model.choosedPlace == null || _model.choosedPlace == '') {
          safeSetState(() {
            _model.textController1?.clear();
          });
        } else {
          _model.showAddressError = false;
          _model.showSuggestions = false;
          safeSetState(() {});
        }
      },
    );
    _model.flatTextFieldTextController ??= TextEditingController();
    _model.flatTextFieldFocusNode ??= FocusNode();

    _model.cityTextFieldTextController ??= TextEditingController();
    _model.cityTextFieldFocusNode ??= FocusNode();

    _model.textController4 ??= TextEditingController();
    _model.textFieldFocusNode2 ??= FocusNode();
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
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.0),
          topRight: Radius.circular(24.0),
        ),
      ),
      child: Padding(
        padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 20.0),
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
                padding: EdgeInsetsDirectional.fromSTEB(0.0, 16.0, 16.0, 0.0),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              6.0, 0.0, 16.0, 0.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Align(
                                alignment: AlignmentDirectional(-1.0, 0.0),
                                child: FlutterFlowIconButton(
                                  borderRadius: 100.0,
                                  icon: Icon(
                                    Icons.arrow_back,
                                    color:
                                        FlutterFlowTheme.of(context).extraBlack,
                                    size: 24.0,
                                  ),
                                  onPressed: () async {
                                    context.safePop();
                                  },
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Neighbourhood Location',
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
                                    Text(
                                      'Your home address is used to place you in the right neighbourhood. We won\'t share it without your permission.',
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
                                                .greyL5,
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
                                  ],
                                ),
                              ),
                            ].divide(SizedBox(width: 10.0)),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              16.0, 0.0, 0.0, 0.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Address line 1 *',
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
                                      lineHeight: 1.3,
                                    ),
                              ),
                              Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    0.0, 8.0, 0.0, 0.0),
                                child: Container(
                                  width: double.infinity,
                                  child: TextFormField(
                                    controller: _model.textController1,
                                    focusNode: _model.textFieldFocusNode1,
                                    onChanged: (_) => EasyDebounce.debounce(
                                      '_model.textController1',
                                      Duration(milliseconds: 2000),
                                      () async {
                                        if (_model.choosedPlace != null &&
                                            _model.choosedPlace != '') {
                                          _model.showAddressError = false;
                                          safeSetState(() {});
                                        } else {
                                          _model.showAddressError = true;
                                          safeSetState(() {});
                                        }

                                        if (_model.textController1.text.length >
                                            3) {
                                          _model.suggestedPlaces =
                                              await ShowSuggestionsCall.call(
                                            input: _model.textController1.text,
                                          );

                                          _model.placeId =
                                              ShowSuggestionsCall.placeId(
                                            (_model.suggestedPlaces?.jsonBody ??
                                                ''),
                                          )!
                                                  .toList()
                                                  .cast<String>();
                                          _model.places =
                                              ShowSuggestionsCall.places(
                                            (_model.suggestedPlaces?.jsonBody ??
                                                ''),
                                          )!
                                                  .toList()
                                                  .cast<String>();
                                          _model.choosedPlace = null;
                                          safeSetState(() {});
                                          _model.showSuggestions = true;
                                          safeSetState(() {});
                                        } else {
                                          if (_model.textController1.text
                                                  .length ==
                                              0) {
                                            _model.showSuggestions = false;
                                            _model.showAddressError = true;
                                            _model.choosedPlace = null;
                                            _model.choosedPlaceId = null;
                                            _model.latitude = null;
                                            _model.longitude = null;
                                            safeSetState(() {});
                                          }
                                        }

                                        safeSetState(() {});
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
                                      hintText: 'Enter here...',
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
                                          color: FlutterFlowTheme.of(context)
                                              .greyL2,
                                          width: 1.0,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(4.0),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: FlutterFlowTheme.of(context)
                                              .greyD1,
                                          width: 1.0,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(4.0),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: FlutterFlowTheme.of(context)
                                              .error,
                                          width: 1.0,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(4.0),
                                      ),
                                      focusedErrorBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: FlutterFlowTheme.of(context)
                                              .error,
                                          width: 1.0,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(4.0),
                                      ),
                                      filled: true,
                                      fillColor: FlutterFlowTheme.of(context)
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
                                          color: FlutterFlowTheme.of(context)
                                              .primaryText,
                                          letterSpacing: 0.0,
                                          fontWeight: FontWeight.w500,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .bodyMedium
                                                  .fontStyle,
                                          lineHeight: 1.3,
                                        ),
                                    cursorColor: FlutterFlowTheme.of(context)
                                        .primaryText,
                                    validator: _model.textController1Validator
                                        .asValidator(context),
                                  ),
                                ),
                              ),
                              if (_model.showSuggestions)
                                Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      0.0, 5.0, 0.0, 0.0),
                                  child: Container(
                                    width: double.infinity,
                                    height: 200.0,
                                    decoration: BoxDecoration(
                                      color: FlutterFlowTheme.of(context)
                                          .alternate,
                                      border: Border.all(
                                        color:
                                            FlutterFlowTheme.of(context).greyL2,
                                      ),
                                    ),
                                    child: Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          10.0, 10.0, 10.0, 10.0),
                                      child: Builder(
                                        builder: (context) {
                                          final shownPlaces =
                                              ShowSuggestionsCall.places(
                                                    (_model.suggestedPlaces
                                                            ?.jsonBody ??
                                                        ''),
                                                  )?.toList() ??
                                                  [];

                                          return SingleChildScrollView(
                                            child: Column(
                                              mainAxisSize: MainAxisSize.max,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: List.generate(
                                                  shownPlaces.length,
                                                  (shownPlacesIndex) {
                                                final shownPlacesItem =
                                                    shownPlaces[
                                                        shownPlacesIndex];
                                                return InkWell(
                                                  splashColor:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .primary
                                                          .withAlpha(0x14),
                                                  focusColor:
                                                      Colors.transparent,
                                                  hoverColor:
                                                      Colors.transparent,
                                                  highlightColor:
                                                      Colors.transparent,
                                                  onTap: () async {
                                                    HapticFeedback
                                                        .lightImpact();
                                                    _model.choosedPlace =
                                                        shownPlacesItem;
                                                    _model.choosedPlaceId = _model
                                                        .placeId
                                                        .elementAtOrNull(
                                                            shownPlacesIndex);
                                                    _model.showSuggestions =
                                                        false;
                                                    safeSetState(() {});
                                                    safeSetState(() {
                                                      _model.textController1
                                                              ?.text =
                                                          _model.choosedPlace!;
                                                    });
                                                    _model.placeDetails =
                                                        await GetPlaceDetailsCall
                                                            .call(
                                                      placeId:
                                                          _model.choosedPlaceId,
                                                    );

                                                    _model.latitude =
                                                        GetPlaceDetailsCall
                                                            .latitude(
                                                      (_model.placeDetails
                                                              ?.jsonBody ??
                                                          ''),
                                                    );
                                                    _model.longitude =
                                                        GetPlaceDetailsCall
                                                            .longitude(
                                                      (_model.placeDetails
                                                              ?.jsonBody ??
                                                          ''),
                                                    );
                                                    _model.showAddressError =
                                                        false;
                                                    _model.country =
                                                        GetPlaceDetailsCall
                                                            .country(
                                                      (_model.placeDetails
                                                              ?.jsonBody ??
                                                          ''),
                                                    );
                                                    _model.city =
                                                        GetPlaceDetailsCall
                                                            .city(
                                                      (_model.placeDetails
                                                              ?.jsonBody ??
                                                          ''),
                                                    );
                                                    safeSetState(() {});
                                                    safeSetState(() {
                                                      _model.cityTextFieldTextController
                                                              ?.text =
                                                          GetPlaceDetailsCall
                                                              .city(
                                                        (_model.placeDetails
                                                                ?.jsonBody ??
                                                            ''),
                                                      )!;
                                                    });
                                                    if (_model.formKey1
                                                            .currentState !=
                                                        null) {
                                                      _model.formKey1
                                                          .currentState!
                                                          .validate();
                                                    }

                                                    safeSetState(() {});
                                                  },
                                                  child: Container(
                                                    decoration: BoxDecoration(),
                                                    child: Padding(
                                                      padding:
                                                          EdgeInsetsDirectional
                                                              .fromSTEB(
                                                                  0.0,
                                                                  10.0,
                                                                  0.0,
                                                                  10.0),
                                                      child: Row(
                                                        mainAxisSize:
                                                            MainAxisSize.max,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: [
                                                          Icon(
                                                            Icons
                                                                .location_on_sharp,
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .primary,
                                                            size: 16.0,
                                                          ),
                                                          Flexible(
                                                            child: Text(
                                                              shownPlacesItem,
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
                                                                        .extraBlack,
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
                                                                        1.3,
                                                                  ),
                                                            ),
                                                          ),
                                                        ].divide(SizedBox(
                                                            width: 5.0)),
                                                      ),
                                                    ),
                                                  ),
                                                )
                                                    .animate()
                                                    .fadeIn(
                                                      duration: 260.ms,
                                                      delay: (40 *
                                                              (shownPlacesIndex %
                                                                  8))
                                                          .ms,
                                                    )
                                                    .slideY(
                                                      begin: 0.06,
                                                      end: 0,
                                                      curve:
                                                          Curves.easeOutCubic,
                                                    );
                                              }),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              if (_model.showAddressError)
                                Text(
                                  'Address is Required',
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
                                            .redColor2,
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
                        ),
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              16.0, 0.0, 0.0, 0.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Flat',
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
                                      lineHeight: 1.3,
                                    ),
                              ),
                              Container(
                                width: double.infinity,
                                child: TextFormField(
                                  controller:
                                      _model.flatTextFieldTextController,
                                  focusNode: _model.flatTextFieldFocusNode,
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
                                    hintText: 'Enter here...',
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
                                        color:
                                            FlutterFlowTheme.of(context).greyL2,
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
                                  validator: _model
                                      .flatTextFieldTextControllerValidator
                                      .asValidator(context),
                                ),
                              ),
                            ].divide(SizedBox(height: 8.0)),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              16.0, 0.0, 0.0, 0.0),
                          child: Form(
                            key: _model.formKey1,
                            autovalidateMode: AutovalidateMode.disabled,
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'City/Town *',
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
                                            .extraBlack,
                                        letterSpacing: 0.0,
                                        fontWeight: FontWeight.w500,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .fontStyle,
                                        lineHeight: 1.3,
                                      ),
                                ),
                                Container(
                                  width: double.infinity,
                                  child: TextFormField(
                                    controller:
                                        _model.cityTextFieldTextController,
                                    focusNode: _model.cityTextFieldFocusNode,
                                    onChanged: (_) => EasyDebounce.debounce(
                                      '_model.cityTextFieldTextController',
                                      Duration(milliseconds: 2000),
                                      () async {
                                        if (_model.formKey1.currentState !=
                                            null) {
                                          _model.formKey1.currentState!
                                              .validate();
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
                                      hintText: 'Enter here...',
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
                                          color: FlutterFlowTheme.of(context)
                                              .greyL2,
                                          width: 1.0,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(4.0),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: FlutterFlowTheme.of(context)
                                              .greyD1,
                                          width: 1.0,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(4.0),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: FlutterFlowTheme.of(context)
                                              .error,
                                          width: 1.0,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(4.0),
                                      ),
                                      focusedErrorBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: FlutterFlowTheme.of(context)
                                              .error,
                                          width: 1.0,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(4.0),
                                      ),
                                      filled: true,
                                      fillColor: FlutterFlowTheme.of(context)
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
                                          color: FlutterFlowTheme.of(context)
                                              .primaryText,
                                          letterSpacing: 0.0,
                                          fontWeight: FontWeight.w500,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .bodyMedium
                                                  .fontStyle,
                                          lineHeight: 1.3,
                                        ),
                                    cursorColor: FlutterFlowTheme.of(context)
                                        .primaryText,
                                    validator: _model
                                        .cityTextFieldTextControllerValidator
                                        .asValidator(context),
                                  ),
                                ),
                              ].divide(SizedBox(height: 8.0)),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              16.0, 0.0, 0.0, 0.0),
                          child: Form(
                            key: _model.formKey2,
                            autovalidateMode: AutovalidateMode.disabled,
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Postal code *',
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
                                            .extraBlack,
                                        letterSpacing: 0.0,
                                        fontWeight: FontWeight.w500,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .fontStyle,
                                        lineHeight: 1.3,
                                      ),
                                ),
                                Container(
                                  width: double.infinity,
                                  child: TextFormField(
                                    controller: _model.textController4,
                                    focusNode: _model.textFieldFocusNode2,
                                    onChanged: (_) => EasyDebounce.debounce(
                                      '_model.textController4',
                                      Duration(milliseconds: 2000),
                                      () async {
                                        if (_model.formKey2.currentState !=
                                            null) {
                                          _model.formKey2.currentState!
                                              .validate();
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
                                      hintText: 'Enter here...',
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
                                          color: FlutterFlowTheme.of(context)
                                              .greyL2,
                                          width: 1.0,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(4.0),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: FlutterFlowTheme.of(context)
                                              .greyD1,
                                          width: 1.0,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(4.0),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: FlutterFlowTheme.of(context)
                                              .error,
                                          width: 1.0,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(4.0),
                                      ),
                                      focusedErrorBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: FlutterFlowTheme.of(context)
                                              .error,
                                          width: 1.0,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(4.0),
                                      ),
                                      filled: true,
                                      fillColor: FlutterFlowTheme.of(context)
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
                                          color: FlutterFlowTheme.of(context)
                                              .primaryText,
                                          letterSpacing: 0.0,
                                          fontWeight: FontWeight.w500,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .bodyMedium
                                                  .fontStyle,
                                          lineHeight: 1.3,
                                        ),
                                    cursorColor: FlutterFlowTheme.of(context)
                                        .primaryText,
                                    validator: _model.textController4Validator
                                        .asValidator(context),
                                  ),
                                ),
                              ].divide(SizedBox(height: 8.0)),
                            ),
                          ),
                        ),
                      ].divide(SizedBox(height: 24.0)),
                    ),
                    Padding(
                      padding:
                          EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 0.0, 0.0),
                      child: FFButtonWidget(
                        onPressed: () async {
                          if (_model.choosedPlace != null &&
                              _model.choosedPlace != '') {
                            HapticFeedback.lightImpact();
                            _model.showAddressError = false;
                            safeSetState(() {});
                            _model.city1 = true;
                            if (_model.formKey1.currentState == null ||
                                !_model.formKey1.currentState!.validate()) {
                              _model.city1 = false;
                            }
                            if (_model.city1 == true) {
                              _model.postal1 = true;
                              if (_model.formKey2.currentState == null ||
                                  !_model.formKey2.currentState!.validate()) {
                                _model.postal1 = false;
                              }
                              if (_model.postal1 == true) {
                                if (_model.flatTextFieldTextController.text !=
                                        null &&
                                    _model.flatTextFieldTextController.text !=
                                        '') {
                                  FFAppState().AsFlat =
                                      _model.flatTextFieldTextController.text;
                                  safeSetState(() {});
                                  FFAppState().AsAddress = _model.choosedPlace!;
                                  FFAppState().AsCity =
                                      _model.cityTextFieldTextController.text;
                                  FFAppState().AsPostalCode =
                                      _model.textController4.text;
                                  FFAppState().AsLatitude = _model.latitude!;
                                  FFAppState().AsLongitude = _model.longitude!;
                                  FFAppState().AsCountry = _model.country!;
                                  safeSetState(() {});
                                  if (widget!.pageName == 'google') {
                                    _model.locationResult =
                                        await InsertUserLocationCall.call(
                                      lat: FFAppState().AsLatitude.toString(),
                                      lng: FFAppState().AsLongitude.toString(),
                                      placeName: FFAppState().AsCity,
                                      apikey: FFDevEnvironmentValues().AnonKey,
                                      token: currentJwtToken,
                                      pType: 'create',
                                    );

                                    await UserTable().update(
                                      data: {
                                        'address': FFAppState().AsAddress,
                                        'city': FFAppState().AsCity,
                                        'flat': FFAppState().AsFlat,
                                      },
                                      matchingRows: (rows) => rows.eqOrNull(
                                        'id',
                                        currentUserUid,
                                      ),
                                    );
                                    await PublicUserProfileTable().update(
                                      data: {
                                        'city': FFAppState().AsCity,
                                      },
                                      matchingRows: (rows) => rows.eqOrNull(
                                        'id',
                                        currentUserUid,
                                      ),
                                    );

                                    context
                                        .pushNamed(LoadingPageWidget.routeName);
                                  } else {
                                    context.pushNamed(
                                        FinalStepsPhonePageWidget.routeName);
                                  }
                                }
                              }
                            } else {
                              _model.postal2 = true;
                              if (_model.formKey2.currentState == null ||
                                  !_model.formKey2.currentState!.validate()) {
                                _model.postal2 = false;
                              }
                            }
                          } else {
                            HapticFeedback.lightImpact();
                            _model.showAddressError = true;
                            safeSetState(() {});
                            if (_model.formKey1.currentState != null) {
                              _model.formKey1.currentState!.validate();
                            }
                            if (_model.formKey2.currentState != null) {
                              _model.formKey2.currentState!.validate();
                            }
                          }

                          safeSetState(() {});
                        },
                        text: 'Continue',
                        options: FFButtonOptions(
                          width: double.infinity,
                          height: 46.0,
                          padding: EdgeInsetsDirectional.fromSTEB(
                              16.0, 12.0, 16.0, 12.0),
                          iconPadding: EdgeInsetsDirectional.fromSTEB(
                              0.0, 0.0, 0.0, 0.0),
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
              ),
            ].addToStart(SizedBox(height: 8.0)),
          ),
        ),
      ),
    );
  }
}
