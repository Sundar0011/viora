import '/auth/supabase_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_radio_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/form_field_controller.dart';
import '/flutter_flow/upload_data.dart';
import '/pages/events/comp_select_date_time/comp_select_date_time_widget.dart';
import 'dart:ui';
import '/custom_code/actions/index.dart' as actions;
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'edit_event_model.dart';
export 'edit_event_model.dart';

class EditEventWidget extends StatefulWidget {
  const EditEventWidget({
    super.key,
    required this.eventId,
  });

  final String? eventId;

  static String routeName = 'EditEvent';
  static String routePath = 'editEvent';

  @override
  State<EditEventWidget> createState() => _EditEventWidgetState();
}

class _EditEventWidgetState extends State<EditEventWidget> {
  late EditEventModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => EditEventModel());

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      _model.row2 = await EventPageTable().queryRows(
        queryFn: (q) => q.eqOrNull(
          'id',
          widget!.eventId,
        ),
      );
      FFAppState().ChoosedStartEventDate =
          _model.row2?.firstOrNull?.startDateTime;
      FFAppState().ChoosedEndEventDate = _model.row2?.firstOrNull?.endDateTime;
      safeSetState(() {});
      _model.latitude = _model.row2?.firstOrNull?.latitude;
      _model.logitude = _model.row2?.firstOrNull?.logitude;
      _model.choosedPlace = _model.row2?.firstOrNull?.address;
      safeSetState(() {});
      safeSetState(() {
        _model.locationTextFieldTextController?.text =
            _model.row2!.firstOrNull!.address!;
      });
    });

    _model.textFieldFocusNode1 ??= FocusNode();

    _model.textFieldFocusNode2 ??= FocusNode();

    _model.locationTextFieldTextController ??=
        TextEditingController(text: _model.choosedPlace);
    _model.locationTextFieldFocusNode ??= FocusNode();
    _model.locationTextFieldFocusNode!.addListener(
      () async {
        if (!(_model.choosedPlace != null && _model.choosedPlace != '')) {
          _model.showSuggestion = false;
          _model.choosedPlace = null;
          _model.showLocationError = true;
          safeSetState(() {});
          safeSetState(() {
            _model.locationTextFieldTextController?.text = _model.choosedPlace!;
          });
        }
      },
    );

    _model.textFieldFocusNode3 ??= FocusNode();
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
        body: SafeArea(
          top: true,
          child: FutureBuilder<List<EventPageRow>>(
            future: EventPageTable().querySingleRow(
              queryFn: (q) => q.eqOrNull(
                'id',
                widget!.eventId,
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
                      valueColor: AlwaysStoppedAnimation<Color>(
                        FlutterFlowTheme.of(context).primary,
                      ),
                    ),
                  ),
                );
              }
              List<EventPageRow> containerEventPageRowList = snapshot.data!;

              final containerEventPageRow = containerEventPageRowList.isNotEmpty
                  ? containerEventPageRowList.first
                  : null;

              return Container(
                decoration: BoxDecoration(
                  color: FlutterFlowTheme.of(context).pageBack,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Container(
                        width: double.infinity,
                        height: 56.0,
                        decoration: BoxDecoration(
                          color:
                              FlutterFlowTheme.of(context).secondaryBackground,
                        ),
                        child: Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              10.0, 0.0, 20.0, 0.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              FlutterFlowIconButton(
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
                              Text(
                                'Edit Event',
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                      font: GoogleFonts.manrope(
                                        fontWeight: FontWeight.w600,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .fontStyle,
                                      ),
                                      color: FlutterFlowTheme.of(context)
                                          .extraBlack,
                                      fontSize: 18.0,
                                      letterSpacing: 0.0,
                                      fontWeight: FontWeight.w600,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontStyle,
                                      lineHeight: 1.4,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 240.0,
                            child: Stack(
                              alignment: AlignmentDirectional(1.0, 1.0),
                              children: [
                                Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(0.0),
                                      child: Image.network(
                                        containerEventPageRow!.coverImage,
                                        width: double.infinity,
                                        height: 240.0,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    if (_model.uploadedLocalFile_editEventImage !=
                                            null &&
                                        (_model.uploadedLocalFile_editEventImage
                                                .bytes?.isNotEmpty ??
                                            false))
                                      ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(0.0),
                                        child: Image.memory(
                                          _model.uploadedLocalFile_editEventImage
                                                  .bytes ??
                                              Uint8List.fromList([]),
                                          width: double.infinity,
                                          height: 240.0,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                  ],
                                ),
                                Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      0.0, 0.0, 16.0, 16.0),
                                  child: Container(
                                    width: 34.0,
                                    height: 34.0,
                                    decoration: BoxDecoration(
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryBackground,
                                      borderRadius: BorderRadius.circular(24.0),
                                    ),
                                    child: InkWell(
                                      splashColor: Colors.transparent,
                                      focusColor: Colors.transparent,
                                      hoverColor: Colors.transparent,
                                      highlightColor: Colors.transparent,
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
                                                  .isDataUploading_editEventImage =
                                              true);
                                          var selectedUploadedFiles =
                                              <FFUploadedFile>[];

                                          try {
                                            selectedUploadedFiles =
                                                selectedMedia
                                                    .map((m) => FFUploadedFile(
                                                          name: m.storagePath
                                                              .split('/')
                                                              .last,
                                                          bytes: m.bytes,
                                                          height: m.dimensions
                                                              ?.height,
                                                          width: m.dimensions
                                                              ?.width,
                                                          blurHash: m.blurHash,
                                                          originalFilename: m
                                                              .originalFilename,
                                                        ))
                                                    .toList();
                                          } finally {
                                            _model.isDataUploading_editEventImage =
                                                false;
                                          }
                                          if (selectedUploadedFiles.length ==
                                              selectedMedia.length) {
                                            safeSetState(() {
                                              _model.uploadedLocalFile_editEventImage =
                                                  selectedUploadedFiles.first;
                                            });
                                          } else {
                                            safeSetState(() {});
                                            return;
                                          }
                                        }
                                      },
                                      child: Icon(
                                        Icons.edit_sharp,
                                        color: FlutterFlowTheme.of(context)
                                            .primary,
                                        size: 24.0,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: FlutterFlowTheme.of(context).white,
                        ),
                        child: Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              20.0, 0.0, 20.0, 0.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Form(
                                key: _model.formKey3,
                                autovalidateMode: AutovalidateMode.disabled,
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Align(
                                      alignment:
                                          AlignmentDirectional(-1.0, 0.0),
                                      child: Text(
                                        'Event Name *',
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
                                                      .extraBlack,
                                              letterSpacing: 0.0,
                                              fontWeight: FontWeight.w500,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontStyle,
                                              lineHeight: 1.3,
                                            ),
                                      ),
                                    ),
                                    Container(
                                      width: double.infinity,
                                      child: TextFormField(
                                        controller: _model.textController1 ??=
                                            TextEditingController(
                                          text: containerEventPageRow?.name,
                                        ),
                                        focusNode: _model.textFieldFocusNode1,
                                        onChanged: (_) => EasyDebounce.debounce(
                                          '_model.textController1',
                                          Duration(milliseconds: 2000),
                                          () async {
                                            if (_model.formKey3.currentState ==
                                                    null ||
                                                !_model.formKey3.currentState!
                                                    .validate()) {
                                              return;
                                            }
                                          },
                                        ),
                                        autofocus: false,
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
                                          hintText: 'Enter Name',
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
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .greyD1,
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
                                          fillColor: Color(0xFFF7F9FC),
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
                                                      .primaryText,
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
                                            .textController1Validator
                                            .asValidator(context),
                                      ),
                                    ),
                                  ].divide(SizedBox(height: 8.0)),
                                ),
                              ),
                              Form(
                                key: _model.formKey2,
                                autovalidateMode: AutovalidateMode.disabled,
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Align(
                                      alignment:
                                          AlignmentDirectional(-1.0, 0.0),
                                      child: Text(
                                        'Event Type *',
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
                                                      .extraBlack,
                                              letterSpacing: 0.0,
                                              fontWeight: FontWeight.w500,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontStyle,
                                              lineHeight: 1.3,
                                            ),
                                      ),
                                    ),
                                    FlutterFlowRadioButton(
                                      options: ['Online', 'Offline'].toList(),
                                      onChanged: (val) => safeSetState(() {}),
                                      controller: _model
                                              .radioButtonValueController ??=
                                          FormFieldController<String>(
                                              containerEventPageRow!.eventType),
                                      optionHeight: 32.0,
                                      textStyle: FlutterFlowTheme.of(context)
                                          .labelMedium
                                          .override(
                                            font: GoogleFonts.inter(
                                              fontWeight:
                                                  FlutterFlowTheme.of(context)
                                                      .labelMedium
                                                      .fontWeight,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .labelMedium
                                                      .fontStyle,
                                            ),
                                            letterSpacing: 0.0,
                                            fontWeight:
                                                FlutterFlowTheme.of(context)
                                                    .labelMedium
                                                    .fontWeight,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .labelMedium
                                                    .fontStyle,
                                          ),
                                      selectedTextStyle: FlutterFlowTheme.of(
                                              context)
                                          .bodyMedium
                                          .override(
                                            font: GoogleFonts.inter(
                                              fontWeight:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontWeight,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontStyle,
                                            ),
                                            letterSpacing: 0.0,
                                            fontWeight:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMedium
                                                    .fontWeight,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMedium
                                                    .fontStyle,
                                          ),
                                      buttonPosition: RadioButtonPosition.left,
                                      direction: Axis.vertical,
                                      radioButtonColor:
                                          FlutterFlowTheme.of(context).primary,
                                      inactiveRadioButtonColor:
                                          FlutterFlowTheme.of(context)
                                              .secondaryText,
                                      toggleable: false,
                                      horizontalAlignment: WrapAlignment.start,
                                      verticalAlignment:
                                          WrapCrossAlignment.start,
                                    ),
                                    if (_model.showEventError)
                                      Text(
                                        'Event type is required',
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
                                  ].divide(SizedBox(height: 8.0)),
                                ),
                              ),
                              Form(
                                key: _model.formKey4,
                                autovalidateMode: AutovalidateMode.disabled,
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Align(
                                      alignment:
                                          AlignmentDirectional(-1.0, 0.0),
                                      child: Text(
                                        'Video Call link (if online event)',
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
                                                      .extraBlack,
                                              letterSpacing: 0.0,
                                              fontWeight: FontWeight.w500,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontStyle,
                                              lineHeight: 1.3,
                                            ),
                                      ),
                                    ),
                                    Container(
                                      width: double.infinity,
                                      child: TextFormField(
                                        controller: _model.textController2 ??=
                                            TextEditingController(
                                          text: containerEventPageRow
                                                      ?.eventType ==
                                                  'Online'
                                              ? containerEventPageRow
                                                  ?.videoCallLink
                                              : '',
                                        ),
                                        focusNode: _model.textFieldFocusNode2,
                                        onChanged: (_) => EasyDebounce.debounce(
                                          '_model.textController2',
                                          Duration(milliseconds: 2000),
                                          () async {
                                            if (_model.radioButtonValue ==
                                                'Online') {
                                              if (_model.textController2.text ==
                                                      null ||
                                                  _model.textController2.text ==
                                                      '') {
                                                _model.showLinkError = true;
                                                safeSetState(() {});
                                              } else {
                                                _model.link6 = await actions
                                                    .validateMeetLink(
                                                  _model.textController2.text,
                                                );
                                                if (_model.link6!) {
                                                  _model.showLinkError = false;
                                                  safeSetState(() {});
                                                } else {
                                                  _model.showLinkError = true;
                                                  safeSetState(() {});
                                                }
                                              }
                                            } else {
                                              _model.showLinkError = false;
                                              safeSetState(() {});
                                            }

                                            safeSetState(() {});
                                          },
                                        ),
                                        autofocus: false,
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
                                          hintText: 'Enter link',
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
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .greyD1,
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
                                          fillColor: Color(0xFFF7F9FC),
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
                                                      .primaryText,
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
                                            .textController2Validator
                                            .asValidator(context),
                                      ),
                                    ),
                                    if ((_model.showLinkError == true) &&
                                        (_model.radioButtonValue == 'Online'))
                                      Text(
                                        'Link is not valid',
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
                                  ].divide(SizedBox(height: 8.0)),
                                ),
                              ),
                              Column(
                                mainAxisSize: MainAxisSize.max,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Align(
                                    alignment: AlignmentDirectional(-1.0, 0.0),
                                    child: Text(
                                      'Location *',
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
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMedium
                                                    .fontStyle,
                                            lineHeight: 1.3,
                                          ),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        0.0, 8.0, 0.0, 0.0),
                                    child: Stack(
                                      children: [
                                        Container(
                                          width: double.infinity,
                                          child: TextFormField(
                                            controller: _model
                                                .locationTextFieldTextController,
                                            focusNode: _model
                                                .locationTextFieldFocusNode,
                                            onChanged: (_) =>
                                                EasyDebounce.debounce(
                                              '_model.locationTextFieldTextController',
                                              Duration(milliseconds: 2000),
                                              () async {
                                                if ((String var1) {
                                                  return var1.length >= 3;
                                                }(_model
                                                    .locationTextFieldTextController
                                                    .text)) {
                                                  _model.places =
                                                      await ShowSuggestionsCall
                                                          .call(
                                                    input: _model
                                                        .locationTextFieldTextController
                                                        .text,
                                                  );

                                                  _model.placesList =
                                                      ShowSuggestionsCall
                                                              .places(
                                                    (_model.places?.jsonBody ??
                                                        ''),
                                                  )!
                                                          .toList()
                                                          .cast<String>();
                                                  _model.showSuggestion = true;
                                                  _model.choosedPlace = null;
                                                  _model.showLocationError =
                                                      false;
                                                  _model.placeId =
                                                      ShowSuggestionsCall
                                                              .placeId(
                                                    (_model.places?.jsonBody ??
                                                        ''),
                                                  )!
                                                          .toList()
                                                          .cast<String>();
                                                  safeSetState(() {});
                                                } else {
                                                  if (_model
                                                          .locationTextFieldTextController
                                                          .text
                                                          .length ==
                                                      3) {
                                                    _model.showSuggestion =
                                                        false;
                                                    _model.choosedPlace = null;
                                                    _model.showLocationError =
                                                        true;
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
                                              labelStyle: FlutterFlowTheme.of(
                                                      context)
                                                  .labelMedium
                                                  .override(
                                                    font: GoogleFonts.manrope(
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontStyle:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .labelMedium
                                                              .fontStyle,
                                                    ),
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .greyL4,
                                                    letterSpacing: 0.0,
                                                    fontWeight: FontWeight.w500,
                                                    fontStyle:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .labelMedium
                                                            .fontStyle,
                                                    lineHeight: 1.3,
                                                  ),
                                              hintText: 'Enter location',
                                              hintStyle: FlutterFlowTheme.of(
                                                      context)
                                                  .labelMedium
                                                  .override(
                                                    font: GoogleFonts.manrope(
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontStyle:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .labelMedium
                                                              .fontStyle,
                                                    ),
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .greyL4,
                                                    letterSpacing: 0.0,
                                                    fontWeight: FontWeight.w500,
                                                    fontStyle:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .labelMedium
                                                            .fontStyle,
                                                    lineHeight: 1.3,
                                                  ),
                                              enabledBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .greyL2,
                                                  width: 1.0,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(4.0),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .greyD1,
                                                  width: 1.0,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(4.0),
                                              ),
                                              errorBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .error,
                                                  width: 1.0,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(4.0),
                                              ),
                                              focusedErrorBorder:
                                                  OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .error,
                                                  width: 1.0,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(4.0),
                                              ),
                                              filled: true,
                                              fillColor: Color(0xFFF7F9FC),
                                              contentPadding:
                                                  EdgeInsetsDirectional
                                                      .fromSTEB(12.0, 16.0,
                                                          15.0, 16.0),
                                            ),
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
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .primaryText,
                                                  letterSpacing: 0.0,
                                                  fontWeight: FontWeight.w500,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMedium
                                                          .fontStyle,
                                                  lineHeight: 1.3,
                                                ),
                                            cursorColor:
                                                FlutterFlowTheme.of(context)
                                                    .primaryText,
                                            validator: _model
                                                .locationTextFieldTextControllerValidator
                                                .asValidator(context),
                                          ),
                                        ),
                                        Align(
                                          alignment:
                                              AlignmentDirectional(1.0, 0.0),
                                          child: Padding(
                                            padding:
                                                EdgeInsetsDirectional.fromSTEB(
                                                    0.0, 12.0, 10.0, 0.0),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(0.0),
                                              child: Image.asset(
                                                'assets/images/Icon_(1).webp',
                                                width: 20.0,
                                                height: 20.0,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (_model.showSuggestion)
                                    Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          0.0, 8.0, 0.0, 0.0),
                                      child: Container(
                                        height: 150.0,
                                        decoration: BoxDecoration(),
                                        child: Builder(
                                          builder: (context) {
                                            final searchplaces =
                                                _model.placesList.toList();

                                            return ListView.builder(
                                              padding: EdgeInsets.zero,
                                              shrinkWrap: true,
                                              scrollDirection: Axis.vertical,
                                              itemCount: searchplaces.length,
                                              itemBuilder:
                                                  (context, searchplacesIndex) {
                                                final searchplacesItem =
                                                    searchplaces[
                                                        searchplacesIndex];
                                                return InkWell(
                                                  splashColor:
                                                      Colors.transparent,
                                                  focusColor:
                                                      Colors.transparent,
                                                  hoverColor:
                                                      Colors.transparent,
                                                  highlightColor:
                                                      Colors.transparent,
                                                  onTap: () async {
                                                    _model.choosedPlace =
                                                        searchplacesItem;
                                                    _model.showLocationError =
                                                        false;
                                                    _model.showSuggestion =
                                                        false;
                                                    safeSetState(() {});
                                                    safeSetState(() {
                                                      _model.locationTextFieldTextController
                                                              ?.text =
                                                          searchplacesItem;
                                                    });
                                                    _model.apiResult5e7 =
                                                        await GetPlaceDetailsCall
                                                            .call(
                                                      placeId: _model.placeId
                                                          .elementAtOrNull(
                                                              searchplacesIndex),
                                                    );

                                                    _model.latitude =
                                                        GetPlaceDetailsCall
                                                            .latitude(
                                                      (_model.apiResult5e7
                                                              ?.jsonBody ??
                                                          ''),
                                                    );
                                                    _model.logitude =
                                                        GetPlaceDetailsCall
                                                            .longitude(
                                                      (_model.apiResult5e7
                                                              ?.jsonBody ??
                                                          ''),
                                                    );
                                                    safeSetState(() {});

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
                                                              searchplacesItem,
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
                                                );
                                              },
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  if ((_model.showLocationError == true) &&
                                      (_model.radioButtonValue == 'Offline'))
                                    Text(
                                      'Location is required',
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
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMedium
                                                    .fontStyle,
                                            lineHeight: 1.4,
                                          ),
                                    ),
                                ],
                              ),
                              Column(
                                mainAxisSize: MainAxisSize.max,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Align(
                                    alignment: AlignmentDirectional(-1.0, 0.0),
                                    child: Text(
                                      'Start Date & Time *',
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
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMedium
                                                    .fontStyle,
                                            lineHeight: 1.3,
                                          ),
                                    ),
                                  ),
                                  InkWell(
                                    splashColor: Colors.transparent,
                                    focusColor: Colors.transparent,
                                    hoverColor: Colors.transparent,
                                    highlightColor: Colors.transparent,
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
                                              padding: MediaQuery.viewInsetsOf(
                                                  context),
                                              child: CompSelectDateTimeWidget(
                                                pageName: 'start',
                                              ),
                                            ),
                                          );
                                        },
                                      ).then((value) => safeSetState(() {}));
                                    },
                                    child: Container(
                                      width: double.infinity,
                                      height: 50.0,
                                      decoration: BoxDecoration(
                                        color: Color(0xFFF7F9FC),
                                        borderRadius:
                                            BorderRadius.circular(4.0),
                                        border: Border.all(
                                          color: FlutterFlowTheme.of(context)
                                              .greyL2,
                                        ),
                                      ),
                                      child: Align(
                                        alignment:
                                            AlignmentDirectional(-1.0, 0.0),
                                        child: Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  12.0, 0.0, 0.0, 0.0),
                                          child: Text(
                                            FFAppState().ChoosedStartEventDate !=
                                                    null
                                                ? '${valueOrDefault<String>(
                                                    dateTimeFormat(
                                                        "d/M/y",
                                                        FFAppState()
                                                            .ChoosedStartEventDate),
                                                    'Date & Time',
                                                  )},${FFAppState().EventChoosedTime}'
                                                : 'Date & Time',
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
                                                      FFAppState().ChoosedStartEventDate ==
                                                              null
                                                          ? FlutterFlowTheme.of(
                                                                  context)
                                                              .greyL4
                                                          : FlutterFlowTheme.of(
                                                                  context)
                                                              .primaryText,
                                                  letterSpacing: 0.0,
                                                  fontWeight: FontWeight.w500,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMedium
                                                          .fontStyle,
                                                  lineHeight: 1.3,
                                                ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  if (_model.showStartDateError)
                                    Text(
                                      'Start date and time is required',
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
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMedium
                                                    .fontStyle,
                                            lineHeight: 1.4,
                                          ),
                                    ),
                                ].divide(SizedBox(height: 8.0)),
                              ),
                              Column(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Align(
                                    alignment: AlignmentDirectional(-1.0, 0.0),
                                    child: Text(
                                      'End Date & Time (Optional)',
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
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMedium
                                                    .fontStyle,
                                            lineHeight: 1.3,
                                          ),
                                    ),
                                  ),
                                  InkWell(
                                    splashColor: Colors.transparent,
                                    focusColor: Colors.transparent,
                                    hoverColor: Colors.transparent,
                                    highlightColor: Colors.transparent,
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
                                              padding: MediaQuery.viewInsetsOf(
                                                  context),
                                              child: CompSelectDateTimeWidget(
                                                pageName: 'end',
                                              ),
                                            ),
                                          );
                                        },
                                      ).then((value) => safeSetState(() {}));
                                    },
                                    child: Container(
                                      width: double.infinity,
                                      height: 50.0,
                                      decoration: BoxDecoration(
                                        color: Color(0xFFF7F9FC),
                                        borderRadius:
                                            BorderRadius.circular(4.0),
                                        border: Border.all(
                                          color: FlutterFlowTheme.of(context)
                                              .greyL2,
                                        ),
                                      ),
                                      child: Align(
                                        alignment:
                                            AlignmentDirectional(-1.0, 0.0),
                                        child: Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  12.0, 0.0, 0.0, 0.0),
                                          child: Text(
                                            FFAppState().ChoosedEndEventDate !=
                                                    null
                                                ? '${dateTimeFormat("d/M/y", FFAppState().ChoosedEndEventDate)},${FFAppState().EventChoosedTimeEnd}'
                                                : 'Date & Time',
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
                                                      FFAppState().ChoosedEndEventDate ==
                                                              null
                                                          ? FlutterFlowTheme.of(
                                                                  context)
                                                              .greyL4
                                                          : FlutterFlowTheme.of(
                                                                  context)
                                                              .primaryText,
                                                  letterSpacing: 0.0,
                                                  fontWeight: FontWeight.w500,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMedium
                                                          .fontStyle,
                                                  lineHeight: 1.3,
                                                ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ].divide(SizedBox(height: 8.0)),
                              ),
                              Form(
                                key: _model.formKey1,
                                autovalidateMode: AutovalidateMode.disabled,
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Align(
                                      alignment:
                                          AlignmentDirectional(-1.0, 0.0),
                                      child: Text(
                                        'Description *',
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
                                                      .extraBlack,
                                              letterSpacing: 0.0,
                                              fontWeight: FontWeight.w500,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontStyle,
                                              lineHeight: 1.3,
                                            ),
                                      ),
                                    ),
                                    Container(
                                      width: double.infinity,
                                      child: TextFormField(
                                        controller: _model.textController4 ??=
                                            TextEditingController(
                                          text: containerEventPageRow
                                              ?.description,
                                        ),
                                        focusNode: _model.textFieldFocusNode3,
                                        onChanged: (_) => EasyDebounce.debounce(
                                          '_model.textController4',
                                          Duration(milliseconds: 2000),
                                          () async {
                                            if (_model.formKey1.currentState ==
                                                    null ||
                                                !_model.formKey1.currentState!
                                                    .validate()) {
                                              return;
                                            }
                                          },
                                        ),
                                        autofocus: false,
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
                                          hintText: 'Enter description',
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
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .greyD1,
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
                                          fillColor: Color(0xFFF7F9FC),
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
                                                      .primaryText,
                                              letterSpacing: 0.0,
                                              fontWeight: FontWeight.w500,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontStyle,
                                              lineHeight: 1.3,
                                            ),
                                        maxLines: 5,
                                        cursorColor:
                                            FlutterFlowTheme.of(context)
                                                .primaryText,
                                        validator: _model
                                            .textController4Validator
                                            .asValidator(context),
                                      ),
                                    ),
                                  ].divide(SizedBox(height: 8.0)),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    0.0, 4.0, 0.0, 24.0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Theme(
                                      data: ThemeData(
                                        checkboxTheme: CheckboxThemeData(
                                          visualDensity: VisualDensity.compact,
                                          materialTapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(2.0),
                                          ),
                                        ),
                                        unselectedWidgetColor: _model.checkbox
                                            ? FlutterFlowTheme.of(context)
                                                .redColor2
                                            : FlutterFlowTheme.of(context)
                                                .extraBlack,
                                      ),
                                      child: Checkbox(
                                        value: _model.checkboxValue ??= false,
                                        onChanged: (newValue) async {
                                          safeSetState(() =>
                                              _model.checkboxValue = newValue!);
                                          if (newValue!) {
                                            _model.checkbox = true;
                                            safeSetState(() {});
                                          } else {
                                            _model.checkbox = false;
                                            safeSetState(() {});
                                          }
                                        },
                                        side: ((_model.checkbox
                                                    ? FlutterFlowTheme.of(
                                                            context)
                                                        .redColor2
                                                    : FlutterFlowTheme.of(
                                                            context)
                                                        .extraBlack) !=
                                                null)
                                            ? BorderSide(
                                                width: 2,
                                                color: (_model.checkbox
                                                    ? FlutterFlowTheme.of(
                                                            context)
                                                        .redColor2
                                                    : FlutterFlowTheme.of(
                                                            context)
                                                        .extraBlack)!,
                                              )
                                            : null,
                                        activeColor:
                                            FlutterFlowTheme.of(context)
                                                .primary,
                                        checkColor:
                                            FlutterFlowTheme.of(context).info,
                                      ),
                                    ),
                                    Flexible(
                                      child: InkWell(
                                        splashColor: Colors.transparent,
                                        focusColor: Colors.transparent,
                                        hoverColor: Colors.transparent,
                                        highlightColor: Colors.transparent,
                                        onTap: () async {
                                          context.pushNamed(
                                              TermsAndConditionsWidget
                                                  .routeName);
                                        },
                                        child: RichText(
                                          textScaler:
                                              MediaQuery.of(context).textScaler,
                                          text: TextSpan(
                                            children: [
                                              TextSpan(
                                                text:
                                                    'By continuing, you agree with ',
                                                style: FlutterFlowTheme.of(
                                                        context)
                                                    .bodyMedium
                                                    .override(
                                                      font: GoogleFonts.inter(
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
                                                    ),
                                              ),
                                              TextSpan(
                                                text: 'SquaDD’s event policy.',
                                                style: TextStyle(
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .primary,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 14.0,
                                                ),
                                              )
                                            ],
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                                  font: GoogleFonts.inter(
                                                    fontWeight:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .bodyMedium
                                                            .fontWeight,
                                                    fontStyle:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .bodyMedium
                                                            .fontStyle,
                                                  ),
                                                  letterSpacing: 0.0,
                                                  fontWeight:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMedium
                                                          .fontWeight,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMedium
                                                          .fontStyle,
                                                ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ].divide(SizedBox(width: 4.0)),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    0.0, 8.0, 0.0, 0.0),
                                child: FFButtonWidget(
                                  onPressed: (_model.checkbox == false)
                                      ? null
                                      : () async {
                                          _model.name = true;
                                          if (_model.formKey3.currentState ==
                                                  null ||
                                              !_model.formKey3.currentState!
                                                  .validate()) {
                                            _model.name = false;
                                          }
                                          if (_model.name!) {
                                            if (_model.radioButtonValue !=
                                                    null &&
                                                _model.radioButtonValue != '') {
                                              _model.showEventError = false;
                                              safeSetState(() {});
                                              if ((_model.choosedPlace !=
                                                          null &&
                                                      _model.choosedPlace !=
                                                          '') ||
                                                  (_model.radioButtonValue ==
                                                      'Online')) {
                                                _model.showLocationError =
                                                    false;
                                                safeSetState(() {});
                                                if (FFAppState()
                                                        .ChoosedStartEventDate !=
                                                    null) {
                                                  _model.showStartDateError =
                                                      false;
                                                  safeSetState(() {});
                                                  if (true) {
                                                    _model.showImageError =
                                                        false;
                                                    safeSetState(() {});
                                                    _model.link9 = await actions
                                                        .validateMeetLink(
                                                      _model
                                                          .textController2.text,
                                                    );
                                                    if ((_model.link9 ==
                                                            true) ||
                                                        (_model.radioButtonValue ==
                                                            'Offline')) {
                                                      _model.showLinkError =
                                                          false;
                                                      safeSetState(() {});
                                                      if (FFAppState()
                                                              .ChoosedEndEventDate !=
                                                          null) {
                                                        await EventPageTable()
                                                            .update(
                                                          data: {
                                                            'end_date_time': supaSerialize<
                                                                    DateTime>(
                                                                functions.returnTimeStamp(
                                                                    FFAppState()
                                                                        .ChoosedEndEventDate!,
                                                                    FFAppState()
                                                                        .EventChoosedTimeEnd)),
                                                          },
                                                          matchingRows:
                                                              (rows) =>
                                                                  rows.eqOrNull(
                                                            'id',
                                                            widget!.eventId,
                                                          ),
                                                        );
                                                      }
                                                      await EventPageTable()
                                                          .update(
                                                        data: {
                                                          'name': _model
                                                              .textController1
                                                              .text,
                                                          'event_type': _model
                                                              .radioButtonValue,
                                                          'video_call_link':
                                                              _model
                                                                  .textController2
                                                                  .text,
                                                          'start_date_time': supaSerialize<
                                                                  DateTime>(
                                                              functions.returnTimeStamp(
                                                                  FFAppState()
                                                                      .ChoosedStartEventDate!,
                                                                  FFAppState()
                                                                      .EventChoosedTime)),
                                                          'description':
                                                              containerEventPageRow
                                                                  ?.description,
                                                          'Address': _model
                                                              .locationTextFieldTextController
                                                              .text,
                                                          'latitude':
                                                              _model.latitude,
                                                          'logitude':
                                                              _model.logitude,
                                                        },
                                                        matchingRows: (rows) =>
                                                            rows.eqOrNull(
                                                          'id',
                                                          widget!.eventId,
                                                        ),
                                                      );
                                                      if (_model.uploadedLocalFile_editEventImage !=
                                                              null &&
                                                          (_model
                                                                  .uploadedLocalFile_editEventImage
                                                                  .bytes
                                                                  ?.isNotEmpty ??
                                                              false)) {
                                                        await deleteSupabaseFileFromPublicUrl(
                                                            containerEventPageRow!
                                                                .coverImage);
                                                        {
                                                          safeSetState(() =>
                                                              _model.isDataUploading_eventimage2 =
                                                                  true);
                                                          var selectedUploadedFiles =
                                                              <FFUploadedFile>[];
                                                          var selectedMedia =
                                                              <SelectedFile>[];
                                                          var downloadUrls =
                                                              <String>[];
                                                          try {
                                                            selectedUploadedFiles = _model
                                                                    .uploadedLocalFile_editEventImage
                                                                    .bytes!
                                                                    .isNotEmpty
                                                                ? [
                                                                    _model
                                                                        .uploadedLocalFile_editEventImage
                                                                  ]
                                                                : <FFUploadedFile>[];
                                                            selectedMedia =
                                                                selectedFilesFromUploadedFiles(
                                                              selectedUploadedFiles,
                                                              storageFolderPath:
                                                                  widget!
                                                                      .eventId,
                                                            );
                                                            downloadUrls =
                                                                await uploadSupabaseStorageFiles(
                                                              bucketName:
                                                                  'event',
                                                              selectedFiles:
                                                                  selectedMedia,
                                                            );
                                                          } finally {
                                                            _model.isDataUploading_eventimage2 =
                                                                false;
                                                          }
                                                          if (selectedUploadedFiles
                                                                      .length ==
                                                                  selectedMedia
                                                                      .length &&
                                                              downloadUrls
                                                                      .length ==
                                                                  selectedMedia
                                                                      .length) {
                                                            safeSetState(() {
                                                              _model.uploadedLocalFile_eventimage2 =
                                                                  selectedUploadedFiles
                                                                      .first;
                                                              _model.uploadedFileUrl_eventimage2 =
                                                                  downloadUrls
                                                                      .first;
                                                            });
                                                          } else {
                                                            safeSetState(() {});
                                                            return;
                                                          }
                                                        }

                                                        await EventPageTable()
                                                            .update(
                                                          data: {
                                                            'cover_image': _model
                                                                .uploadedFileUrl_eventimage2,
                                                          },
                                                          matchingRows:
                                                              (rows) =>
                                                                  rows.eqOrNull(
                                                            'id',
                                                            widget!.eventId,
                                                          ),
                                                        );
                                                      }
                                                      _model.locati =
                                                          await UpdateEventLocationCall
                                                              .call(
                                                        id: widget!.eventId,
                                                        latitude: _model
                                                            .latitude
                                                            ?.toString(),
                                                        longitude: _model
                                                            .logitude
                                                            ?.toString(),
                                                        token: currentJwtToken,
                                                      );

                                                      context.safePop();
                                                    } else {
                                                      _model.showLinkError =
                                                          true;
                                                      safeSetState(() {});
                                                    }
                                                  } else {
                                                    _model.showImageError =
                                                        true;
                                                    safeSetState(() {});
                                                    if (_model
                                                            .radioButtonValue ==
                                                        'Online') {
                                                      if (_model.textController2
                                                                  .text ==
                                                              null ||
                                                          _model.textController2
                                                                  .text ==
                                                              '') {
                                                        _model.showLinkError =
                                                            true;
                                                        safeSetState(() {});
                                                      } else {
                                                        _model.showLinkError =
                                                            false;
                                                        safeSetState(() {});
                                                      }
                                                    } else {
                                                      _model.showLinkError =
                                                          false;
                                                      safeSetState(() {});
                                                    }
                                                  }
                                                } else {
                                                  _model.showStartDateError =
                                                      true;
                                                  safeSetState(() {});
                                                  if (_model.formKey1
                                                              .currentState ==
                                                          null ||
                                                      !_model.formKey1
                                                          .currentState!
                                                          .validate()) {
                                                    return;
                                                  }
                                                  if (true) {
                                                    _model.showImageError =
                                                        false;
                                                    safeSetState(() {});
                                                    if (_model
                                                            .radioButtonValue ==
                                                        'Online') {
                                                      if (_model.textController2
                                                                  .text ==
                                                              null ||
                                                          _model.textController2
                                                                  .text ==
                                                              '') {
                                                        _model.showLinkError =
                                                            true;
                                                        safeSetState(() {});
                                                      } else {
                                                        _model.showLinkError =
                                                            false;
                                                        safeSetState(() {});
                                                      }
                                                    } else {
                                                      _model.showLinkError =
                                                          false;
                                                      safeSetState(() {});
                                                    }
                                                  } else {
                                                    _model.showImageError =
                                                        true;
                                                    safeSetState(() {});
                                                    if (_model
                                                            .radioButtonValue ==
                                                        'Online') {
                                                      if (_model.textController2
                                                                  .text ==
                                                              null ||
                                                          _model.textController2
                                                                  .text ==
                                                              '') {
                                                        _model.showLinkError =
                                                            true;
                                                        safeSetState(() {});
                                                      } else {
                                                        _model.showLinkError =
                                                            false;
                                                        safeSetState(() {});
                                                      }
                                                    } else {
                                                      _model.showLinkError =
                                                          false;
                                                      safeSetState(() {});
                                                    }
                                                  }
                                                }
                                              } else {
                                                _model.showLocationError = true;
                                                safeSetState(() {});
                                                if (FFAppState()
                                                        .ChoosedStartEventDate !=
                                                    null) {
                                                  _model.showStartDateError =
                                                      false;
                                                  safeSetState(() {});
                                                  if (_model.formKey1
                                                              .currentState ==
                                                          null ||
                                                      !_model.formKey1
                                                          .currentState!
                                                          .validate()) {
                                                    return;
                                                  }
                                                  if (_model.uploadedLocalFile_editEventImage !=
                                                          null &&
                                                      (_model
                                                              .uploadedLocalFile_editEventImage
                                                              .bytes
                                                              ?.isNotEmpty ??
                                                          false)) {
                                                    _model.showImageError =
                                                        false;
                                                    safeSetState(() {});
                                                    if (_model
                                                            .radioButtonValue ==
                                                        'Online') {
                                                      if (_model.textController2
                                                                  .text ==
                                                              null ||
                                                          _model.textController2
                                                                  .text ==
                                                              '') {
                                                        _model.showLinkError =
                                                            true;
                                                        safeSetState(() {});
                                                      } else {
                                                        _model.showLinkError =
                                                            false;
                                                        safeSetState(() {});
                                                      }
                                                    } else {
                                                      _model.showLinkError =
                                                          false;
                                                      safeSetState(() {});
                                                    }
                                                  } else {
                                                    _model.showImageError =
                                                        true;
                                                    safeSetState(() {});
                                                    if (_model
                                                            .radioButtonValue ==
                                                        'Online') {
                                                      if (_model.textController2
                                                                  .text ==
                                                              null ||
                                                          _model.textController2
                                                                  .text ==
                                                              '') {
                                                        _model.showLinkError =
                                                            true;
                                                        safeSetState(() {});
                                                      } else {
                                                        _model.showLinkError =
                                                            false;
                                                        safeSetState(() {});
                                                      }
                                                    } else {
                                                      _model.showLinkError =
                                                          false;
                                                      safeSetState(() {});
                                                    }
                                                  }
                                                } else {
                                                  _model.showStartDateError =
                                                      true;
                                                  safeSetState(() {});
                                                  if (_model.formKey1
                                                              .currentState ==
                                                          null ||
                                                      !_model.formKey1
                                                          .currentState!
                                                          .validate()) {
                                                    return;
                                                  }
                                                  if (_model.uploadedLocalFile_editEventImage !=
                                                          null &&
                                                      (_model
                                                              .uploadedLocalFile_editEventImage
                                                              .bytes
                                                              ?.isNotEmpty ??
                                                          false)) {
                                                    _model.showImageError =
                                                        false;
                                                    safeSetState(() {});
                                                    if (_model
                                                            .radioButtonValue ==
                                                        'Online') {
                                                      if (_model.textController2
                                                                  .text ==
                                                              null ||
                                                          _model.textController2
                                                                  .text ==
                                                              '') {
                                                        _model.showLinkError =
                                                            true;
                                                        safeSetState(() {});
                                                      } else {
                                                        _model.showLinkError =
                                                            false;
                                                        safeSetState(() {});
                                                      }
                                                    } else {
                                                      _model.showLinkError =
                                                          false;
                                                      safeSetState(() {});
                                                    }
                                                  } else {
                                                    _model.showImageError =
                                                        true;
                                                    safeSetState(() {});
                                                    if (_model
                                                            .radioButtonValue ==
                                                        'Online') {
                                                      if (_model.textController2
                                                                  .text ==
                                                              null ||
                                                          _model.textController2
                                                                  .text ==
                                                              '') {
                                                        _model.showLinkError =
                                                            true;
                                                        safeSetState(() {});
                                                      } else {
                                                        _model.showLinkError =
                                                            false;
                                                        safeSetState(() {});
                                                      }
                                                    } else {
                                                      _model.showLinkError =
                                                          false;
                                                      safeSetState(() {});
                                                    }
                                                  }
                                                }
                                              }
                                            } else {
                                              _model.showEventError = true;
                                              safeSetState(() {});
                                              if ((_model.choosedPlace !=
                                                          null &&
                                                      _model.choosedPlace !=
                                                          '') &&
                                                  (_model.radioButtonValue ==
                                                      'Online')) {
                                                _model.showLocationError =
                                                    false;
                                                safeSetState(() {});
                                                if (FFAppState()
                                                        .ChoosedStartEventDate !=
                                                    null) {
                                                  _model.showStartDateError =
                                                      false;
                                                  safeSetState(() {});
                                                  if (_model.formKey1
                                                              .currentState ==
                                                          null ||
                                                      !_model.formKey1
                                                          .currentState!
                                                          .validate()) {
                                                    return;
                                                  }
                                                  if (_model.uploadedLocalFile_editEventImage !=
                                                          null &&
                                                      (_model
                                                              .uploadedLocalFile_editEventImage
                                                              .bytes
                                                              ?.isNotEmpty ??
                                                          false)) {
                                                    _model.showImageError =
                                                        false;
                                                    safeSetState(() {});
                                                    if (_model
                                                            .radioButtonValue ==
                                                        'Online') {
                                                      if (_model.textController2
                                                                  .text ==
                                                              null ||
                                                          _model.textController2
                                                                  .text ==
                                                              '') {
                                                        _model.showLinkError =
                                                            true;
                                                        safeSetState(() {});
                                                      } else {
                                                        _model.showLinkError =
                                                            false;
                                                        safeSetState(() {});
                                                      }
                                                    } else {
                                                      _model.showLinkError =
                                                          false;
                                                      safeSetState(() {});
                                                    }
                                                  } else {
                                                    _model.showImageError =
                                                        true;
                                                    safeSetState(() {});
                                                    if (_model
                                                            .radioButtonValue ==
                                                        'Online') {
                                                      if (_model.textController2
                                                                  .text ==
                                                              null ||
                                                          _model.textController2
                                                                  .text ==
                                                              '') {
                                                        _model.showLinkError =
                                                            true;
                                                        safeSetState(() {});
                                                      } else {
                                                        _model.showLinkError =
                                                            false;
                                                        safeSetState(() {});
                                                      }
                                                    } else {
                                                      _model.showLinkError =
                                                          false;
                                                      safeSetState(() {});
                                                    }
                                                  }
                                                } else {
                                                  _model.showStartDateError =
                                                      true;
                                                  safeSetState(() {});
                                                  if (_model.formKey1
                                                              .currentState ==
                                                          null ||
                                                      !_model.formKey1
                                                          .currentState!
                                                          .validate()) {
                                                    return;
                                                  }
                                                  if (_model.uploadedLocalFile_editEventImage !=
                                                          null &&
                                                      (_model
                                                              .uploadedLocalFile_editEventImage
                                                              .bytes
                                                              ?.isNotEmpty ??
                                                          false)) {
                                                    _model.showImageError =
                                                        false;
                                                    safeSetState(() {});
                                                    if (_model
                                                            .radioButtonValue ==
                                                        'Online') {
                                                      if (_model.textController2
                                                                  .text ==
                                                              null ||
                                                          _model.textController2
                                                                  .text ==
                                                              '') {
                                                        _model.showLinkError =
                                                            true;
                                                        safeSetState(() {});
                                                      } else {
                                                        _model.showLinkError =
                                                            false;
                                                        safeSetState(() {});
                                                      }
                                                    } else {
                                                      _model.showLinkError =
                                                          false;
                                                      safeSetState(() {});
                                                    }
                                                  } else {
                                                    _model.showImageError =
                                                        true;
                                                    safeSetState(() {});
                                                    if (_model
                                                            .radioButtonValue ==
                                                        'Online') {
                                                      if (_model.textController2
                                                                  .text ==
                                                              null ||
                                                          _model.textController2
                                                                  .text ==
                                                              '') {
                                                        _model.showLinkError =
                                                            true;
                                                        safeSetState(() {});
                                                      } else {
                                                        _model.showLinkError =
                                                            false;
                                                        safeSetState(() {});
                                                      }
                                                    } else {
                                                      _model.showLinkError =
                                                          false;
                                                      safeSetState(() {});
                                                    }
                                                  }
                                                }
                                              } else {
                                                _model.showLocationError = true;
                                                safeSetState(() {});
                                                if (FFAppState()
                                                        .ChoosedStartEventDate !=
                                                    null) {
                                                  _model.showStartDateError =
                                                      false;
                                                  safeSetState(() {});
                                                  if (_model.formKey1
                                                              .currentState ==
                                                          null ||
                                                      !_model.formKey1
                                                          .currentState!
                                                          .validate()) {
                                                    return;
                                                  }
                                                  if (_model.uploadedLocalFile_editEventImage !=
                                                          null &&
                                                      (_model
                                                              .uploadedLocalFile_editEventImage
                                                              .bytes
                                                              ?.isNotEmpty ??
                                                          false)) {
                                                    _model.showImageError =
                                                        false;
                                                    safeSetState(() {});
                                                    if (_model
                                                            .radioButtonValue ==
                                                        'Online') {
                                                      if (_model.textController2
                                                                  .text ==
                                                              null ||
                                                          _model.textController2
                                                                  .text ==
                                                              '') {
                                                        _model.showLinkError =
                                                            true;
                                                        safeSetState(() {});
                                                      } else {
                                                        _model.showLinkError =
                                                            false;
                                                        safeSetState(() {});
                                                      }
                                                    } else {
                                                      _model.showLinkError =
                                                          false;
                                                      safeSetState(() {});
                                                    }
                                                  } else {
                                                    _model.showImageError =
                                                        true;
                                                    safeSetState(() {});
                                                    if (_model
                                                            .radioButtonValue ==
                                                        'Online') {
                                                      if (_model.textController2
                                                                  .text ==
                                                              null ||
                                                          _model.textController2
                                                                  .text ==
                                                              '') {
                                                        _model.showLinkError =
                                                            true;
                                                        safeSetState(() {});
                                                      } else {
                                                        _model.showLinkError =
                                                            false;
                                                        safeSetState(() {});
                                                      }
                                                    } else {
                                                      _model.showLinkError =
                                                          false;
                                                      safeSetState(() {});
                                                    }
                                                  }
                                                } else {
                                                  _model.showStartDateError =
                                                      true;
                                                  safeSetState(() {});
                                                  if (_model.formKey1
                                                              .currentState ==
                                                          null ||
                                                      !_model.formKey1
                                                          .currentState!
                                                          .validate()) {
                                                    return;
                                                  }
                                                  if (_model.uploadedLocalFile_editEventImage !=
                                                          null &&
                                                      (_model
                                                              .uploadedLocalFile_editEventImage
                                                              .bytes
                                                              ?.isNotEmpty ??
                                                          false)) {
                                                    _model.showImageError =
                                                        false;
                                                    safeSetState(() {});
                                                    if (_model
                                                            .radioButtonValue ==
                                                        'Online') {
                                                      if (_model.textController2
                                                                  .text ==
                                                              null ||
                                                          _model.textController2
                                                                  .text ==
                                                              '') {
                                                        _model.showLinkError =
                                                            true;
                                                        safeSetState(() {});
                                                      } else {
                                                        _model.showLinkError =
                                                            false;
                                                        safeSetState(() {});
                                                      }
                                                    } else {
                                                      _model.showLinkError =
                                                          false;
                                                      safeSetState(() {});
                                                    }
                                                  } else {
                                                    _model.showImageError =
                                                        true;
                                                    safeSetState(() {});
                                                    if (_model
                                                            .radioButtonValue ==
                                                        'Online') {
                                                      if (_model.textController2
                                                                  .text ==
                                                              null ||
                                                          _model.textController2
                                                                  .text ==
                                                              '') {
                                                        _model.showLinkError =
                                                            true;
                                                        safeSetState(() {});
                                                      } else {
                                                        _model.showLinkError =
                                                            false;
                                                        safeSetState(() {});
                                                      }
                                                    } else {
                                                      _model.showLinkError =
                                                          false;
                                                      safeSetState(() {});
                                                    }
                                                  }
                                                }
                                              }
                                            }
                                          } else {
                                            if (_model.radioButtonValue !=
                                                    null &&
                                                _model.radioButtonValue != '') {
                                              _model.showEventError = false;
                                              safeSetState(() {});
                                              if ((_model.choosedPlace !=
                                                          null &&
                                                      _model.choosedPlace !=
                                                          '') &&
                                                  (_model.radioButtonValue ==
                                                      'Online')) {
                                                _model.showLocationError =
                                                    false;
                                                safeSetState(() {});
                                                if (FFAppState()
                                                        .ChoosedStartEventDate !=
                                                    null) {
                                                  _model.showStartDateError =
                                                      false;
                                                  safeSetState(() {});
                                                  if (_model.formKey1
                                                              .currentState ==
                                                          null ||
                                                      !_model.formKey1
                                                          .currentState!
                                                          .validate()) {
                                                    return;
                                                  }
                                                  if (_model.uploadedLocalFile_editEventImage !=
                                                          null &&
                                                      (_model
                                                              .uploadedLocalFile_editEventImage
                                                              .bytes
                                                              ?.isNotEmpty ??
                                                          false)) {
                                                    _model.showImageError =
                                                        false;
                                                    safeSetState(() {});
                                                    if (_model
                                                            .radioButtonValue ==
                                                        'Online') {
                                                      if (_model.textController2
                                                                  .text ==
                                                              null ||
                                                          _model.textController2
                                                                  .text ==
                                                              '') {
                                                        _model.showLinkError =
                                                            true;
                                                        safeSetState(() {});
                                                      } else {
                                                        _model.showLinkError =
                                                            false;
                                                        safeSetState(() {});
                                                      }
                                                    } else {
                                                      _model.showLinkError =
                                                          false;
                                                      safeSetState(() {});
                                                    }
                                                  } else {
                                                    _model.showImageError =
                                                        true;
                                                    safeSetState(() {});
                                                    if (_model
                                                            .radioButtonValue ==
                                                        'Online') {
                                                      if (_model.textController2
                                                                  .text ==
                                                              null ||
                                                          _model.textController2
                                                                  .text ==
                                                              '') {
                                                        _model.showLinkError =
                                                            true;
                                                        safeSetState(() {});
                                                      } else {
                                                        _model.showLinkError =
                                                            false;
                                                        safeSetState(() {});
                                                      }
                                                    } else {
                                                      _model.showLinkError =
                                                          false;
                                                      safeSetState(() {});
                                                    }
                                                  }
                                                } else {
                                                  _model.showStartDateError =
                                                      true;
                                                  safeSetState(() {});
                                                  if (_model.formKey1
                                                              .currentState ==
                                                          null ||
                                                      !_model.formKey1
                                                          .currentState!
                                                          .validate()) {
                                                    return;
                                                  }
                                                  if (_model.uploadedLocalFile_editEventImage !=
                                                          null &&
                                                      (_model
                                                              .uploadedLocalFile_editEventImage
                                                              .bytes
                                                              ?.isNotEmpty ??
                                                          false)) {
                                                    _model.showImageError =
                                                        false;
                                                    safeSetState(() {});
                                                    if (_model
                                                            .radioButtonValue ==
                                                        'Online') {
                                                      if (_model.textController2
                                                                  .text ==
                                                              null ||
                                                          _model.textController2
                                                                  .text ==
                                                              '') {
                                                        _model.showLinkError =
                                                            true;
                                                        safeSetState(() {});
                                                      } else {
                                                        _model.showLinkError =
                                                            false;
                                                        safeSetState(() {});
                                                      }
                                                    } else {
                                                      _model.showLinkError =
                                                          false;
                                                      safeSetState(() {});
                                                    }
                                                  } else {
                                                    _model.showImageError =
                                                        true;
                                                    safeSetState(() {});
                                                    if (_model
                                                            .radioButtonValue ==
                                                        'Online') {
                                                      if (_model.textController2
                                                                  .text ==
                                                              null ||
                                                          _model.textController2
                                                                  .text ==
                                                              '') {
                                                        _model.showLinkError =
                                                            true;
                                                        safeSetState(() {});
                                                      } else {
                                                        _model.showLinkError =
                                                            false;
                                                        safeSetState(() {});
                                                      }
                                                    } else {
                                                      _model.showLinkError =
                                                          false;
                                                      safeSetState(() {});
                                                    }
                                                  }
                                                }
                                              } else {
                                                _model.showLocationError = true;
                                                safeSetState(() {});
                                                if (FFAppState()
                                                        .ChoosedStartEventDate !=
                                                    null) {
                                                  _model.showStartDateError =
                                                      false;
                                                  safeSetState(() {});
                                                  if (_model.formKey1
                                                              .currentState ==
                                                          null ||
                                                      !_model.formKey1
                                                          .currentState!
                                                          .validate()) {
                                                    return;
                                                  }
                                                  if (_model.uploadedLocalFile_editEventImage !=
                                                          null &&
                                                      (_model
                                                              .uploadedLocalFile_editEventImage
                                                              .bytes
                                                              ?.isNotEmpty ??
                                                          false)) {
                                                    _model.showImageError =
                                                        false;
                                                    safeSetState(() {});
                                                    if (_model
                                                            .radioButtonValue ==
                                                        'Online') {
                                                      if (_model.textController2
                                                                  .text ==
                                                              null ||
                                                          _model.textController2
                                                                  .text ==
                                                              '') {
                                                        _model.showLinkError =
                                                            true;
                                                        safeSetState(() {});
                                                      } else {
                                                        _model.showLinkError =
                                                            false;
                                                        safeSetState(() {});
                                                      }
                                                    } else {
                                                      _model.showLinkError =
                                                          false;
                                                      safeSetState(() {});
                                                    }
                                                  } else {
                                                    _model.showImageError =
                                                        true;
                                                    safeSetState(() {});
                                                    if (_model
                                                            .radioButtonValue ==
                                                        'Online') {
                                                      if (_model.textController2
                                                                  .text ==
                                                              null ||
                                                          _model.textController2
                                                                  .text ==
                                                              '') {
                                                        _model.showLinkError =
                                                            true;
                                                        safeSetState(() {});
                                                      } else {
                                                        _model.showLinkError =
                                                            false;
                                                        safeSetState(() {});
                                                      }
                                                    } else {
                                                      _model.showLinkError =
                                                          false;
                                                      safeSetState(() {});
                                                    }
                                                  }
                                                } else {
                                                  _model.showStartDateError =
                                                      true;
                                                  safeSetState(() {});
                                                  if (_model.formKey1
                                                              .currentState ==
                                                          null ||
                                                      !_model.formKey1
                                                          .currentState!
                                                          .validate()) {
                                                    return;
                                                  }
                                                  if (_model.uploadedLocalFile_editEventImage !=
                                                          null &&
                                                      (_model
                                                              .uploadedLocalFile_editEventImage
                                                              .bytes
                                                              ?.isNotEmpty ??
                                                          false)) {
                                                    _model.showImageError =
                                                        false;
                                                    safeSetState(() {});
                                                    if (_model
                                                            .radioButtonValue ==
                                                        'Online') {
                                                      if (_model.textController2
                                                                  .text ==
                                                              null ||
                                                          _model.textController2
                                                                  .text ==
                                                              '') {
                                                        _model.showLinkError =
                                                            true;
                                                        safeSetState(() {});
                                                      } else {
                                                        _model.showLinkError =
                                                            false;
                                                        safeSetState(() {});
                                                      }
                                                    } else {
                                                      _model.showLinkError =
                                                          false;
                                                      safeSetState(() {});
                                                    }
                                                  } else {
                                                    _model.showImageError =
                                                        true;
                                                    safeSetState(() {});
                                                    if (_model
                                                            .radioButtonValue ==
                                                        'Online') {
                                                      if (_model.textController2
                                                                  .text ==
                                                              null ||
                                                          _model.textController2
                                                                  .text ==
                                                              '') {
                                                        _model.showLinkError =
                                                            true;
                                                        safeSetState(() {});
                                                      } else {
                                                        _model.showLinkError =
                                                            false;
                                                        safeSetState(() {});
                                                      }
                                                    } else {
                                                      _model.showLinkError =
                                                          false;
                                                      safeSetState(() {});
                                                    }
                                                  }
                                                }
                                              }
                                            } else {
                                              _model.showEventError = true;
                                              safeSetState(() {});
                                              if ((_model.choosedPlace !=
                                                          null &&
                                                      _model.choosedPlace !=
                                                          '') &&
                                                  (_model.radioButtonValue ==
                                                      'Online')) {
                                                _model.showLocationError =
                                                    false;
                                                safeSetState(() {});
                                                if (FFAppState()
                                                        .ChoosedStartEventDate !=
                                                    null) {
                                                  _model.showStartDateError =
                                                      false;
                                                  safeSetState(() {});
                                                  if (_model.formKey1
                                                              .currentState ==
                                                          null ||
                                                      !_model.formKey1
                                                          .currentState!
                                                          .validate()) {
                                                    return;
                                                  }
                                                  if (_model.uploadedLocalFile_editEventImage !=
                                                          null &&
                                                      (_model
                                                              .uploadedLocalFile_editEventImage
                                                              .bytes
                                                              ?.isNotEmpty ??
                                                          false)) {
                                                    _model.showImageError =
                                                        false;
                                                    safeSetState(() {});
                                                    if (_model
                                                            .radioButtonValue ==
                                                        'Online') {
                                                      if (_model.textController2
                                                                  .text ==
                                                              null ||
                                                          _model.textController2
                                                                  .text ==
                                                              '') {
                                                        _model.showLinkError =
                                                            true;
                                                        safeSetState(() {});
                                                      } else {
                                                        _model.showLinkError =
                                                            false;
                                                        safeSetState(() {});
                                                      }
                                                    } else {
                                                      _model.showLinkError =
                                                          false;
                                                      safeSetState(() {});
                                                    }
                                                  } else {
                                                    _model.showImageError =
                                                        true;
                                                    safeSetState(() {});
                                                    if (_model
                                                            .radioButtonValue ==
                                                        'Online') {
                                                      if (_model.textController2
                                                                  .text ==
                                                              null ||
                                                          _model.textController2
                                                                  .text ==
                                                              '') {
                                                        _model.showLinkError =
                                                            true;
                                                        safeSetState(() {});
                                                      } else {
                                                        _model.showLinkError =
                                                            false;
                                                        safeSetState(() {});
                                                      }
                                                    } else {
                                                      _model.showLinkError =
                                                          false;
                                                      safeSetState(() {});
                                                    }
                                                  }
                                                } else {
                                                  _model.showStartDateError =
                                                      true;
                                                  safeSetState(() {});
                                                  if (_model.formKey1
                                                              .currentState ==
                                                          null ||
                                                      !_model.formKey1
                                                          .currentState!
                                                          .validate()) {
                                                    return;
                                                  }
                                                  if (_model.uploadedLocalFile_editEventImage !=
                                                          null &&
                                                      (_model
                                                              .uploadedLocalFile_editEventImage
                                                              .bytes
                                                              ?.isNotEmpty ??
                                                          false)) {
                                                    _model.showImageError =
                                                        false;
                                                    safeSetState(() {});
                                                    if (_model
                                                            .radioButtonValue ==
                                                        'Online') {
                                                      if (_model.textController2
                                                                  .text ==
                                                              null ||
                                                          _model.textController2
                                                                  .text ==
                                                              '') {
                                                        _model.showLinkError =
                                                            true;
                                                        safeSetState(() {});
                                                      } else {
                                                        _model.showLinkError =
                                                            false;
                                                        safeSetState(() {});
                                                      }
                                                    } else {
                                                      _model.showLinkError =
                                                          false;
                                                      safeSetState(() {});
                                                    }
                                                  } else {
                                                    _model.showImageError =
                                                        true;
                                                    safeSetState(() {});
                                                    if (_model
                                                            .radioButtonValue ==
                                                        'Online') {
                                                      if (_model.textController2
                                                                  .text ==
                                                              null ||
                                                          _model.textController2
                                                                  .text ==
                                                              '') {
                                                        _model.showLinkError =
                                                            true;
                                                        safeSetState(() {});
                                                      } else {
                                                        _model.showLinkError =
                                                            false;
                                                        safeSetState(() {});
                                                      }
                                                    } else {
                                                      _model.showLinkError =
                                                          false;
                                                      safeSetState(() {});
                                                    }
                                                  }
                                                }
                                              } else {
                                                _model.showLocationError = true;
                                                safeSetState(() {});
                                                if (FFAppState()
                                                        .ChoosedStartEventDate !=
                                                    null) {
                                                  _model.showStartDateError =
                                                      false;
                                                  safeSetState(() {});
                                                  if (_model.formKey1
                                                              .currentState ==
                                                          null ||
                                                      !_model.formKey1
                                                          .currentState!
                                                          .validate()) {
                                                    return;
                                                  }
                                                  if (_model.uploadedLocalFile_editEventImage !=
                                                          null &&
                                                      (_model
                                                              .uploadedLocalFile_editEventImage
                                                              .bytes
                                                              ?.isNotEmpty ??
                                                          false)) {
                                                    _model.showImageError =
                                                        false;
                                                    safeSetState(() {});
                                                    if (_model
                                                            .radioButtonValue ==
                                                        'Online') {
                                                      if (_model.textController2
                                                                  .text ==
                                                              null ||
                                                          _model.textController2
                                                                  .text ==
                                                              '') {
                                                        _model.showLinkError =
                                                            true;
                                                        safeSetState(() {});
                                                      } else {
                                                        _model.showLinkError =
                                                            false;
                                                        safeSetState(() {});
                                                      }
                                                    } else {
                                                      _model.showLinkError =
                                                          false;
                                                      safeSetState(() {});
                                                    }
                                                  } else {
                                                    _model.showImageError =
                                                        true;
                                                    safeSetState(() {});
                                                    if (_model
                                                            .radioButtonValue ==
                                                        'Online') {
                                                      if (_model.textController2
                                                                  .text ==
                                                              null ||
                                                          _model.textController2
                                                                  .text ==
                                                              '') {
                                                        _model.showLinkError =
                                                            true;
                                                        safeSetState(() {});
                                                      } else {
                                                        _model.showLinkError =
                                                            false;
                                                        safeSetState(() {});
                                                      }
                                                    } else {
                                                      _model.showLinkError =
                                                          false;
                                                      safeSetState(() {});
                                                    }
                                                  }
                                                } else {
                                                  _model.showStartDateError =
                                                      true;
                                                  safeSetState(() {});
                                                  if (_model.formKey1
                                                              .currentState ==
                                                          null ||
                                                      !_model.formKey1
                                                          .currentState!
                                                          .validate()) {
                                                    return;
                                                  }
                                                  if (_model.uploadedLocalFile_editEventImage !=
                                                          null &&
                                                      (_model
                                                              .uploadedLocalFile_editEventImage
                                                              .bytes
                                                              ?.isNotEmpty ??
                                                          false)) {
                                                    _model.showImageError =
                                                        false;
                                                    safeSetState(() {});
                                                    if (_model
                                                            .radioButtonValue ==
                                                        'Online') {
                                                      if (_model.textController2
                                                                  .text ==
                                                              null ||
                                                          _model.textController2
                                                                  .text ==
                                                              '') {
                                                        _model.showLinkError =
                                                            true;
                                                        safeSetState(() {});
                                                      } else {
                                                        _model.showLinkError =
                                                            false;
                                                        safeSetState(() {});
                                                      }
                                                    } else {
                                                      _model.showLinkError =
                                                          false;
                                                      safeSetState(() {});
                                                    }
                                                  } else {
                                                    _model.showImageError =
                                                        true;
                                                    safeSetState(() {});
                                                    if (_model
                                                            .radioButtonValue ==
                                                        'Online') {
                                                      if (_model.textController2
                                                                  .text ==
                                                              null ||
                                                          _model.textController2
                                                                  .text ==
                                                              '') {
                                                        _model.showLinkError =
                                                            true;
                                                        safeSetState(() {});
                                                      } else {
                                                        _model.showLinkError =
                                                            false;
                                                        safeSetState(() {});
                                                      }
                                                    } else {
                                                      _model.showLinkError =
                                                          false;
                                                      safeSetState(() {});
                                                    }
                                                  }
                                                }
                                              }

                                              _model.showEventError = false;
                                              safeSetState(() {});
                                            }
                                          }

                                          safeSetState(() {});
                                        },
                                  text: 'Update',
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
                                    disabledColor:
                                        FlutterFlowTheme.of(context).greyL2,
                                    disabledTextColor:
                                        FlutterFlowTheme.of(context).greyL3,
                                  ),
                                ),
                              ),
                            ]
                                .divide(SizedBox(height: 12.0))
                                .addToStart(SizedBox(height: 12.0)),
                          ),
                        ),
                      ),
                    ].addToEnd(SizedBox(height: 20.0)),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
