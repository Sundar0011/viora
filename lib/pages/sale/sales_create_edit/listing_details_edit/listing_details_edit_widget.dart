import '/auth/supabase_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_drop_down.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_radio_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/form_field_controller.dart';
import '/flutter_flow/upload_data.dart';
import 'dart:ui';
import '/custom_code/actions/index.dart' as actions;
import '/custom_code/widgets/index.dart' as custom_widgets;
import '/index.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart'
    as smooth_page_indicator;
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'listing_details_edit_model.dart';
export 'listing_details_edit_model.dart';

class ListingDetailsEditWidget extends StatefulWidget {
  const ListingDetailsEditWidget({
    super.key,
    required this.saleId,
  });

  final String? saleId;

  static String routeName = 'ListingDetailsEdit';
  static String routePath = 'listingDetailsEdit';

  @override
  State<ListingDetailsEditWidget> createState() =>
      _ListingDetailsEditWidgetState();
}

class _ListingDetailsEditWidgetState extends State<ListingDetailsEditWidget> {
  late ListingDetailsEditModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ListingDetailsEditModel());

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      _model.saleRow = await SaleTable().queryRows(
        queryFn: (q) => q.eqOrNull(
          'id',
          widget!.saleId,
        ),
      );
      _model.uploadedimages = await GetSalesImagesCall.call(
        pSaleid: widget!.saleId,
        token: currentJwtToken,
      );

      _model.choosedPlace = _model.saleRow?.firstOrNull?.location;
      _model.latitude = _model.saleRow?.firstOrNull?.latitude;
      _model.longitude = _model.saleRow?.firstOrNull?.longitude;
      _model.city = _model.saleRow?.firstOrNull?.city;
      _model.imagesuplaoded = (getJsonField(
        (_model.uploadedimages?.jsonBody ?? ''),
        r'''$.images''',
        true,
      ) as List?)!
          .map<String>((e) => e.toString())
          .toList()
          .cast<String>()
          .toList()
          .cast<String>();
      _model.imageCount = getJsonField(
        (_model.uploadedimages?.jsonBody ?? ''),
        r'''$.images_count''',
      );
      _model.imageSet = false;
      safeSetState(() {});
      safeSetState(() {
        _model.locationTextFieldTextController?.text =
            _model.saleRow!.firstOrNull!.location;
      });
      _model.showData = true;
      safeSetState(() {});
    });

    _model.textFieldFocusNode1 ??= FocusNode();

    _model.textFieldFocusNode2 ??= FocusNode();

    _model.textFieldFocusNode3 ??= FocusNode();

    _model.locationTextFieldTextController ??= TextEditingController();
    _model.locationTextFieldFocusNode ??= FocusNode();
    _model.locationTextFieldFocusNode!.addListener(
      () async {
        if (!(_model.choosedPlace != null && _model.choosedPlace != '')) {
          _model.showSuggestions = false;
          _model.choosedPlace = null;
          _model.showLocationError = true;
          safeSetState(() {});
          safeSetState(() {
            _model.locationTextFieldTextController?.clear();
          });
        }
      },
    );
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    return FutureBuilder<List<SaleCategoryRow>>(
      future: SaleCategoryTable().queryRows(
        queryFn: (q) => q,
      ),
      builder: (context, snapshot) {
        // Customize what your widget looks like when it's loading.
        if (!snapshot.hasData) {
          return Scaffold(
            backgroundColor: FlutterFlowTheme.of(context).white,
            body: Center(
              child: SizedBox(
                width: 50.0,
                height: 50.0,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    FlutterFlowTheme.of(context).primary,
                  ),
                ),
              ),
            ),
          );
        }
        List<SaleCategoryRow> listingDetailsEditSaleCategoryRowList =
            snapshot.data!;

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
              child: Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  color: FlutterFlowTheme.of(context).pageBack,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    if (_model.showData)
                      Expanded(
                        child: SingleChildScrollView(
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
                                      FlutterFlowIconButton(
                                        borderRadius: 100.0,
                                        icon: Icon(
                                          Icons.arrow_back,
                                          color: FlutterFlowTheme.of(context)
                                              .extraBlack,
                                          size: 24.0,
                                        ),
                                        onPressed: () async {
                                          context.safePop();
                                        },
                                      ),
                                      Text(
                                        'Listing Details',
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
                                              color:
                                                  FlutterFlowTheme.of(context)
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
                                    ],
                                  ),
                                ),
                              ),
                              Stack(
                                alignment: AlignmentDirectional(1.0, 1.0),
                                children: [
                                  if ((_model.uploadedLocalFiles_uploadDataGq211
                                          .isNotEmpty) ==
                                      false)
                                    Container(
                                      width: double.infinity,
                                      height: 320.0,
                                      child: Stack(
                                        children: [
                                          Container(
                                            width: double.infinity,
                                            height: double.infinity,
                                            decoration: BoxDecoration(),
                                            alignment:
                                                AlignmentDirectional(0.0, 0.0),
                                            child: Padding(
                                              padding: EdgeInsetsDirectional
                                                  .fromSTEB(0.0, 4.0, 0.0, 8.0),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(0.0),
                                                child: Image.asset(
                                                  'assets/images/Group.webp',
                                                  width: 160.0,
                                                  height: 145.0,
                                                  fit: BoxFit.contain,
                                                ),
                                              ),
                                            ),
                                          ),
                                          if (_model.imageCount! > 1)
                                            Container(
                                              width: double.infinity,
                                              height: double.infinity,
                                              child: Builder(
                                                builder: (context) {
                                                  final images = _model
                                                      .imagesuplaoded
                                                      .toList();

                                                  return Container(
                                                    width: double.infinity,
                                                    height: 320.0,
                                                    child: Stack(
                                                      children: [
                                                        PageView.builder(
                                                          controller: _model
                                                                  .pageViewController1 ??=
                                                              PageController(
                                                                  initialPage: max(
                                                                      0,
                                                                      min(
                                                                          0,
                                                                          images.length -
                                                                              1))),
                                                          scrollDirection:
                                                              Axis.horizontal,
                                                          itemCount:
                                                              images.length,
                                                          itemBuilder: (context,
                                                              imagesIndex) {
                                                            final imagesItem =
                                                                images[
                                                                    imagesIndex];
                                                            return ClipRRect(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          0.0),
                                                              child:
                                                                  Image.network(
                                                                imagesItem,
                                                                width: double
                                                                    .infinity,
                                                                height: double
                                                                    .infinity,
                                                                fit: BoxFit
                                                                    .cover,
                                                              ),
                                                            );
                                                          },
                                                        ),
                                                        Align(
                                                          alignment:
                                                              AlignmentDirectional(
                                                                  0.0, 1.0),
                                                          child: Padding(
                                                            padding:
                                                                EdgeInsetsDirectional
                                                                    .fromSTEB(
                                                                        0.0,
                                                                        0.0,
                                                                        0.0,
                                                                        10.0),
                                                            child: smooth_page_indicator
                                                                .SmoothPageIndicator(
                                                              controller: _model
                                                                      .pageViewController1 ??=
                                                                  PageController(
                                                                      initialPage: max(
                                                                          0,
                                                                          min(0,
                                                                              images.length - 1))),
                                                              count:
                                                                  images.length,
                                                              axisDirection: Axis
                                                                  .horizontal,
                                                              onDotClicked:
                                                                  (i) async {
                                                                await _model
                                                                    .pageViewController1!
                                                                    .animateToPage(
                                                                  i,
                                                                  duration: Duration(
                                                                      milliseconds:
                                                                          500),
                                                                  curve: Curves
                                                                      .ease,
                                                                );
                                                                safeSetState(
                                                                    () {});
                                                              },
                                                              effect: smooth_page_indicator
                                                                  .ExpandingDotsEffect(
                                                                expansionFactor:
                                                                    4.0,
                                                                spacing: 4.0,
                                                                radius: 8.0,
                                                                dotWidth: 8.0,
                                                                dotHeight: 4.0,
                                                                dotColor: FlutterFlowTheme.of(
                                                                        context)
                                                                    .secondaryBackground,
                                                                activeDotColor:
                                                                    FlutterFlowTheme.of(
                                                                            context)
                                                                        .secondaryBackground,
                                                                paintStyle:
                                                                    PaintingStyle
                                                                        .fill,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                          if (_model.imageCount == 1)
                                            Container(
                                              width: double.infinity,
                                              height: double.infinity,
                                              decoration: BoxDecoration(),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                                child: Image.network(
                                                  _model.imagesuplaoded
                                                      .firstOrNull!,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  if ((_model.uploadedLocalFiles_uploadDataGq211
                                          .isNotEmpty) ==
                                      true)
                                    Container(
                                      width: double.infinity,
                                      height: 320.0,
                                      child: Stack(
                                        children: [
                                          Container(
                                            width: double.infinity,
                                            height: double.infinity,
                                            decoration: BoxDecoration(),
                                            alignment:
                                                AlignmentDirectional(0.0, 0.0),
                                            child: Padding(
                                              padding: EdgeInsetsDirectional
                                                  .fromSTEB(0.0, 4.0, 0.0, 8.0),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(0.0),
                                                child: Image.asset(
                                                  'assets/images/Group.webp',
                                                  width: 160.0,
                                                  height: 145.0,
                                                  fit: BoxFit.contain,
                                                ),
                                              ),
                                            ),
                                          ),
                                          if (_model
                                                  .uploadedLocalFiles_uploadDataGq211
                                                  .length >
                                              1)
                                            Container(
                                              width: double.infinity,
                                              height: double.infinity,
                                              child: Builder(
                                                builder: (context) {
                                                  final images = _model
                                                      .uploadedLocalFiles_uploadDataGq211
                                                      .toList();

                                                  return Container(
                                                    width: double.infinity,
                                                    height: 320.0,
                                                    child: Stack(
                                                      children: [
                                                        PageView.builder(
                                                          controller: _model
                                                                  .pageViewController2 ??=
                                                              PageController(
                                                                  initialPage: max(
                                                                      0,
                                                                      min(
                                                                          0,
                                                                          images.length -
                                                                              1))),
                                                          scrollDirection:
                                                              Axis.horizontal,
                                                          itemCount:
                                                              images.length,
                                                          itemBuilder: (context,
                                                              imagesIndex) {
                                                            final imagesItem =
                                                                images[
                                                                    imagesIndex];
                                                            return ClipRRect(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          0.0),
                                                              child:
                                                                  Image.memory(
                                                                imagesItem
                                                                        .bytes ??
                                                                    Uint8List
                                                                        .fromList(
                                                                            []),
                                                                width: double
                                                                    .infinity,
                                                                height: double
                                                                    .infinity,
                                                                fit: BoxFit
                                                                    .cover,
                                                              ),
                                                            );
                                                          },
                                                        ),
                                                        Align(
                                                          alignment:
                                                              AlignmentDirectional(
                                                                  0.0, 1.0),
                                                          child: Padding(
                                                            padding:
                                                                EdgeInsetsDirectional
                                                                    .fromSTEB(
                                                                        0.0,
                                                                        0.0,
                                                                        0.0,
                                                                        10.0),
                                                            child: smooth_page_indicator
                                                                .SmoothPageIndicator(
                                                              controller: _model
                                                                      .pageViewController2 ??=
                                                                  PageController(
                                                                      initialPage: max(
                                                                          0,
                                                                          min(0,
                                                                              images.length - 1))),
                                                              count:
                                                                  images.length,
                                                              axisDirection: Axis
                                                                  .horizontal,
                                                              onDotClicked:
                                                                  (i) async {
                                                                await _model
                                                                    .pageViewController2!
                                                                    .animateToPage(
                                                                  i,
                                                                  duration: Duration(
                                                                      milliseconds:
                                                                          500),
                                                                  curve: Curves
                                                                      .ease,
                                                                );
                                                                safeSetState(
                                                                    () {});
                                                              },
                                                              effect: smooth_page_indicator
                                                                  .ExpandingDotsEffect(
                                                                expansionFactor:
                                                                    4.0,
                                                                spacing: 4.0,
                                                                radius: 8.0,
                                                                dotWidth: 8.0,
                                                                dotHeight: 4.0,
                                                                dotColor: FlutterFlowTheme.of(
                                                                        context)
                                                                    .secondaryBackground,
                                                                activeDotColor:
                                                                    FlutterFlowTheme.of(
                                                                            context)
                                                                        .secondaryBackground,
                                                                paintStyle:
                                                                    PaintingStyle
                                                                        .fill,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                          if (_model
                                                  .uploadedLocalFiles_uploadDataGq211
                                                  .length ==
                                              1)
                                            Container(
                                              width: double.infinity,
                                              height: double.infinity,
                                              decoration: BoxDecoration(),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                                child: Image.memory(
                                                  _model.uploadedLocalFiles_uploadDataGq211
                                                          .firstOrNull?.bytes ??
                                                      Uint8List.fromList([]),
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  Align(
                                    alignment: AlignmentDirectional(1.0, 1.0),
                                    child: Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          0.0, 0.0, 16.0, 16.0),
                                      child: Container(
                                        width: 50.0,
                                        height: 50.0,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(24.0),
                                        ),
                                        alignment:
                                            AlignmentDirectional(0.0, 0.0),
                                        child: Container(
                                          width: 34.0,
                                          height: 34.0,
                                          decoration: BoxDecoration(
                                            color: FlutterFlowTheme.of(context)
                                                .white,
                                            borderRadius:
                                                BorderRadius.circular(100.0),
                                          ),
                                          child: InkWell(
                                            splashColor: Colors.transparent,
                                            focusColor: Colors.transparent,
                                            hoverColor: Colors.transparent,
                                            highlightColor: Colors.transparent,
                                            onTap: () async {
                                              final selectedMedia =
                                                  await selectMedia(
                                                mediaSource:
                                                    MediaSource.photoGallery,
                                                multiImage: true,
                                              );
                                              if (selectedMedia != null &&
                                                  selectedMedia.every((m) =>
                                                      validateFileFormat(
                                                          m.storagePath,
                                                          context))) {
                                                safeSetState(() => _model
                                                        .isDataUploading_uploadDataGq211 =
                                                    true);
                                                var selectedUploadedFiles =
                                                    <FFUploadedFile>[];

                                                try {
                                                  selectedUploadedFiles =
                                                      selectedMedia
                                                          .map((m) =>
                                                              FFUploadedFile(
                                                                name: m
                                                                    .storagePath
                                                                    .split('/')
                                                                    .last,
                                                                bytes: m.bytes,
                                                                height: m
                                                                    .dimensions
                                                                    ?.height,
                                                                width: m
                                                                    .dimensions
                                                                    ?.width,
                                                                blurHash:
                                                                    m.blurHash,
                                                                originalFilename:
                                                                    m.originalFilename,
                                                              ))
                                                          .toList();
                                                } finally {
                                                  _model.isDataUploading_uploadDataGq211 =
                                                      false;
                                                }
                                                if (selectedUploadedFiles
                                                        .length ==
                                                    selectedMedia.length) {
                                                  safeSetState(() {
                                                    _model.uploadedLocalFiles_uploadDataGq211 =
                                                        selectedUploadedFiles;
                                                  });
                                                } else {
                                                  safeSetState(() {});
                                                  return;
                                                }
                                              }

                                              if ((_model
                                                      .uploadedLocalFiles_uploadDataGq211
                                                      .isNotEmpty) ==
                                                  true) {
                                                _model.imageSet = false;
                                                _model.uploadedImageSet = true;
                                                _model.imagesuplaoded = [];
                                                _model.imageCount = 0;
                                                safeSetState(() {});
                                              }
                                            },
                                            child: Icon(
                                              Icons.edit_sharp,
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .primary,
                                              size: 24.0,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              if (_model.imageSet)
                                Align(
                                  alignment: AlignmentDirectional(-1.0, -1.0),
                                  child: Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        20.0, 0.0, 0.0, 0.0),
                                    child: Text(
                                      'Image is required',
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
                                  ),
                                ),
                              Container(
                                decoration: BoxDecoration(
                                  color: FlutterFlowTheme.of(context).white,
                                ),
                                child: Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      20.0, 0.0, 20.0, 0.0),
                                  child: FutureBuilder<List<SaleRow>>(
                                    future: SaleTable().querySingleRow(
                                      queryFn: (q) => q.eqOrNull(
                                        'id',
                                        widget!.saleId,
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
                                      List<SaleRow> columnSaleRowList =
                                          snapshot.data!;

                                      final columnSaleRow =
                                          columnSaleRowList.isNotEmpty
                                              ? columnSaleRowList.first
                                              : null;

                                      return Column(
                                        mainAxisSize: MainAxisSize.max,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Column(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Align(
                                                alignment: AlignmentDirectional(
                                                    -1.0, 0.0),
                                                child: Text(
                                                  'Title *',
                                                  style: FlutterFlowTheme.of(
                                                          context)
                                                      .bodyMedium
                                                      .override(
                                                        font:
                                                            GoogleFonts.manrope(
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
                                                                .extraBlack,
                                                        letterSpacing: 0.0,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyMedium
                                                                .fontStyle,
                                                        lineHeight: 1.3,
                                                      ),
                                                ),
                                              ),
                                              Form(
                                                key: _model.formKey1,
                                                autovalidateMode:
                                                    AutovalidateMode.disabled,
                                                child: Container(
                                                  width: double.infinity,
                                                  child: TextFormField(
                                                    controller: _model
                                                            .textController1 ??=
                                                        TextEditingController(
                                                      text:
                                                          columnSaleRow?.title,
                                                    ),
                                                    focusNode: _model
                                                        .textFieldFocusNode1,
                                                    onChanged: (_) =>
                                                        EasyDebounce.debounce(
                                                      '_model.textController1',
                                                      Duration(
                                                          milliseconds: 2000),
                                                      () async {
                                                        if (_model.formKey1
                                                                .currentState !=
                                                            null) {
                                                          _model.formKey1
                                                              .currentState!
                                                              .validate();
                                                        }
                                                      },
                                                    ),
                                                    autofocus: false,
                                                    obscureText: false,
                                                    decoration: InputDecoration(
                                                      isDense: true,
                                                      labelStyle:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .labelMedium
                                                              .override(
                                                                font: GoogleFonts
                                                                    .manrope(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  fontStyle: FlutterFlowTheme.of(
                                                                          context)
                                                                      .labelMedium
                                                                      .fontStyle,
                                                                ),
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .greyL4,
                                                                letterSpacing:
                                                                    0.0,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                fontStyle: FlutterFlowTheme.of(
                                                                        context)
                                                                    .labelMedium
                                                                    .fontStyle,
                                                                lineHeight: 1.3,
                                                              ),
                                                      hintText: 'Enter Title',
                                                      hintStyle:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .labelMedium
                                                              .override(
                                                                font: GoogleFonts
                                                                    .manrope(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  fontStyle: FlutterFlowTheme.of(
                                                                          context)
                                                                      .labelMedium
                                                                      .fontStyle,
                                                                ),
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .greyL4,
                                                                letterSpacing:
                                                                    0.0,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                fontStyle: FlutterFlowTheme.of(
                                                                        context)
                                                                    .labelMedium
                                                                    .fontStyle,
                                                                lineHeight: 1.3,
                                                              ),
                                                      enabledBorder:
                                                          OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .greyL2,
                                                          width: 1.0,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(4.0),
                                                      ),
                                                      focusedBorder:
                                                          OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .greyD1,
                                                          width: 1.0,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(4.0),
                                                      ),
                                                      errorBorder:
                                                          OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .error,
                                                          width: 1.0,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(4.0),
                                                      ),
                                                      focusedErrorBorder:
                                                          OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .error,
                                                          width: 1.0,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(4.0),
                                                      ),
                                                      filled: true,
                                                      fillColor:
                                                          Color(0xFFF7F9FC),
                                                      contentPadding:
                                                          EdgeInsetsDirectional
                                                              .fromSTEB(
                                                                  12.0,
                                                                  16.0,
                                                                  12.0,
                                                                  16.0),
                                                    ),
                                                    style: FlutterFlowTheme.of(
                                                            context)
                                                        .bodyMedium
                                                        .override(
                                                          font: GoogleFonts
                                                              .manrope(
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            fontStyle:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .fontStyle,
                                                          ),
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .primaryText,
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMedium
                                                                  .fontStyle,
                                                          lineHeight: 1.3,
                                                        ),
                                                    cursorColor:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .primaryText,
                                                    validator: _model
                                                        .textController1Validator
                                                        .asValidator(context),
                                                  ),
                                                ),
                                              ),
                                            ].divide(SizedBox(height: 8.0)),
                                          ),
                                          Column(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Align(
                                                alignment: AlignmentDirectional(
                                                    -1.0, 0.0),
                                                child: Text(
                                                  'Description *',
                                                  style: FlutterFlowTheme.of(
                                                          context)
                                                      .bodyMedium
                                                      .override(
                                                        font:
                                                            GoogleFonts.manrope(
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
                                                                .extraBlack,
                                                        letterSpacing: 0.0,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyMedium
                                                                .fontStyle,
                                                        lineHeight: 1.3,
                                                      ),
                                                ),
                                              ),
                                              Form(
                                                key: _model.formKey2,
                                                autovalidateMode:
                                                    AutovalidateMode.disabled,
                                                child: Container(
                                                  width: double.infinity,
                                                  child: TextFormField(
                                                    controller: _model
                                                            .textFieldTextController ??=
                                                        TextEditingController(
                                                      text: columnSaleRow
                                                          ?.description,
                                                    ),
                                                    focusNode: _model
                                                        .textFieldFocusNode2,
                                                    onChanged: (_) =>
                                                        EasyDebounce.debounce(
                                                      '_model.textFieldTextController',
                                                      Duration(
                                                          milliseconds: 2000),
                                                      () async {
                                                        if (_model.formKey2
                                                                .currentState !=
                                                            null) {
                                                          _model.formKey2
                                                              .currentState!
                                                              .validate();
                                                        }
                                                      },
                                                    ),
                                                    autofocus: false,
                                                    obscureText: false,
                                                    decoration: InputDecoration(
                                                      isDense: true,
                                                      labelStyle:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .labelMedium
                                                              .override(
                                                                font: GoogleFonts
                                                                    .manrope(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  fontStyle: FlutterFlowTheme.of(
                                                                          context)
                                                                      .labelMedium
                                                                      .fontStyle,
                                                                ),
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .greyL4,
                                                                letterSpacing:
                                                                    0.0,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                fontStyle: FlutterFlowTheme.of(
                                                                        context)
                                                                    .labelMedium
                                                                    .fontStyle,
                                                                lineHeight: 1.3,
                                                              ),
                                                      hintText:
                                                          'Enter description',
                                                      hintStyle:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .labelMedium
                                                              .override(
                                                                font: GoogleFonts
                                                                    .manrope(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  fontStyle: FlutterFlowTheme.of(
                                                                          context)
                                                                      .labelMedium
                                                                      .fontStyle,
                                                                ),
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .greyL4,
                                                                letterSpacing:
                                                                    0.0,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                fontStyle: FlutterFlowTheme.of(
                                                                        context)
                                                                    .labelMedium
                                                                    .fontStyle,
                                                                lineHeight: 1.3,
                                                              ),
                                                      enabledBorder:
                                                          OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .greyL2,
                                                          width: 1.0,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(4.0),
                                                      ),
                                                      focusedBorder:
                                                          OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .greyD1,
                                                          width: 1.0,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(4.0),
                                                      ),
                                                      errorBorder:
                                                          OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .error,
                                                          width: 1.0,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(4.0),
                                                      ),
                                                      focusedErrorBorder:
                                                          OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .error,
                                                          width: 1.0,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(4.0),
                                                      ),
                                                      filled: true,
                                                      fillColor:
                                                          Color(0xFFF7F9FC),
                                                      contentPadding:
                                                          EdgeInsetsDirectional
                                                              .fromSTEB(
                                                                  12.0,
                                                                  16.0,
                                                                  12.0,
                                                                  16.0),
                                                    ),
                                                    style: FlutterFlowTheme.of(
                                                            context)
                                                        .bodyMedium
                                                        .override(
                                                          font: GoogleFonts
                                                              .manrope(
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            fontStyle:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .fontStyle,
                                                          ),
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .primaryText,
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMedium
                                                                  .fontStyle,
                                                          lineHeight: 1.3,
                                                        ),
                                                    maxLines: 3,
                                                    cursorColor:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .primaryText,
                                                    validator: _model
                                                        .textFieldTextControllerValidator
                                                        .asValidator(context),
                                                  ),
                                                ),
                                              ),
                                            ].divide(SizedBox(height: 8.0)),
                                          ),
                                          Column(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Align(
                                                alignment: AlignmentDirectional(
                                                    -1.0, 0.0),
                                                child: Text(
                                                  'Category *',
                                                  style: FlutterFlowTheme.of(
                                                          context)
                                                      .bodyMedium
                                                      .override(
                                                        font:
                                                            GoogleFonts.manrope(
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
                                                                .extraBlack,
                                                        letterSpacing: 0.0,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyMedium
                                                                .fontStyle,
                                                        lineHeight: 1.3,
                                                      ),
                                                ),
                                              ),
                                              FlutterFlowDropDown<String>(
                                                controller: _model
                                                        .dropDownValueController ??=
                                                    FormFieldController<String>(
                                                  _model.dropDownValue ??=
                                                      columnSaleRow
                                                          ?.saleCategory,
                                                ),
                                                options: List<String>.from(
                                                    listingDetailsEditSaleCategoryRowList
                                                        .map((e) => e.id)
                                                        .toList()),
                                                optionLabels:
                                                    listingDetailsEditSaleCategoryRowList
                                                        .map((e) => e.name)
                                                        .withoutNulls
                                                        .toList(),
                                                onChanged: (val) async {
                                                  safeSetState(() => _model
                                                      .dropDownValue = val);
                                                  _model.categoryChoosed =
                                                      false;
                                                  safeSetState(() {});
                                                },
                                                width: double.infinity,
                                                height: 50.0,
                                                textStyle: FlutterFlowTheme.of(
                                                        context)
                                                    .bodyMedium
                                                    .override(
                                                      font: GoogleFonts.manrope(
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
                                                      color:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .primaryText,
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
                                                hintText: 'Select Category',
                                                icon: Icon(
                                                  Icons
                                                      .keyboard_arrow_down_rounded,
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryText,
                                                  size: 24.0,
                                                ),
                                                fillColor: Color(0xFFF7F9FC),
                                                elevation: 2.0,
                                                borderColor:
                                                    FlutterFlowTheme.of(context)
                                                        .greyL2,
                                                borderWidth: 0.0,
                                                borderRadius: 8.0,
                                                margin: EdgeInsetsDirectional
                                                    .fromSTEB(
                                                        12.0, 0.0, 12.0, 0.0),
                                                hidesUnderline: true,
                                                isOverButton: true,
                                                isSearchable: false,
                                                isMultiSelect: false,
                                              ),
                                              if (_model.categoryChoosed)
                                                Align(
                                                  alignment:
                                                      AlignmentDirectional(
                                                          -1.0, -1.0),
                                                  child: Text(
                                                    'Category is required',
                                                    style: FlutterFlowTheme.of(
                                                            context)
                                                        .bodyMedium
                                                        .override(
                                                          font: GoogleFonts
                                                              .manrope(
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            fontStyle:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .fontStyle,
                                                          ),
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .secondaryNormal,
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMedium
                                                                  .fontStyle,
                                                          lineHeight: 1.3,
                                                        ),
                                                  ),
                                                ),
                                            ].divide(SizedBox(height: 8.0)),
                                          ),
                                          Column(
                                            mainAxisSize: MainAxisSize.max,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Align(
                                                alignment: AlignmentDirectional(
                                                    -1.0, 0.0),
                                                child: Text(
                                                  'Price *',
                                                  style: FlutterFlowTheme.of(
                                                          context)
                                                      .bodyMedium
                                                      .override(
                                                        font:
                                                            GoogleFonts.manrope(
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
                                                                .extraBlack,
                                                        letterSpacing: 0.0,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyMedium
                                                                .fontStyle,
                                                        lineHeight: 1.3,
                                                      ),
                                                ),
                                              ),
                                              FlutterFlowRadioButton(
                                                options:
                                                    ['Free', 'Fixed'].toList(),
                                                onChanged: (val) async {
                                                  safeSetState(() {});
                                                  _model.price =
                                                      _model.radioButtonValue!;
                                                  safeSetState(() {});
                                                },
                                                controller: _model
                                                        .radioButtonValueController ??=
                                                    FormFieldController<String>(
                                                        columnSaleRow!
                                                            .ePriceType),
                                                optionHeight: 32.0,
                                                textStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .labelMedium
                                                        .override(
                                                          font:
                                                              GoogleFonts.inter(
                                                            fontWeight:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .labelMedium
                                                                    .fontWeight,
                                                            fontStyle:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .labelMedium
                                                                    .fontStyle,
                                                          ),
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelMedium
                                                                  .fontWeight,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelMedium
                                                                  .fontStyle,
                                                        ),
                                                selectedTextStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .override(
                                                          font: GoogleFonts
                                                              .manrope(
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            fontStyle:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .fontStyle,
                                                          ),
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .greyD1,
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMedium
                                                                  .fontStyle,
                                                          lineHeight: 1.3,
                                                        ),
                                                buttonPosition:
                                                    RadioButtonPosition.left,
                                                direction: Axis.vertical,
                                                radioButtonColor:
                                                    FlutterFlowTheme.of(context)
                                                        .primary,
                                                inactiveRadioButtonColor:
                                                    FlutterFlowTheme.of(context)
                                                        .secondaryText,
                                                toggleable: false,
                                                horizontalAlignment:
                                                    WrapAlignment.start,
                                                verticalAlignment:
                                                    WrapCrossAlignment.start,
                                              ),
                                              if (_model.radioButtonValue ==
                                                  'Fixed')
                                                Form(
                                                  key: _model.formKey3,
                                                  autovalidateMode:
                                                      AutovalidateMode.disabled,
                                                  child: Container(
                                                    width: double.infinity,
                                                    child: TextFormField(
                                                      controller: _model
                                                              .textController3 ??=
                                                          TextEditingController(
                                                        text: columnSaleRow
                                                            ?.price
                                                            ?.toString(),
                                                      ),
                                                      focusNode: _model
                                                          .textFieldFocusNode3,
                                                      onChanged: (_) =>
                                                          EasyDebounce.debounce(
                                                        '_model.textController3',
                                                        Duration(
                                                            milliseconds: 2000),
                                                        () async {
                                                          if (_model.formKey3
                                                                  .currentState !=
                                                              null) {
                                                            _model.formKey3
                                                                .currentState!
                                                                .validate();
                                                          }
                                                        },
                                                      ),
                                                      autofocus: false,
                                                      obscureText: false,
                                                      decoration:
                                                          InputDecoration(
                                                        isDense: true,
                                                        labelStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .labelMedium
                                                                .override(
                                                                  font: GoogleFonts
                                                                      .manrope(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                    fontStyle: FlutterFlowTheme.of(
                                                                            context)
                                                                        .labelMedium
                                                                        .fontStyle,
                                                                  ),
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .greyL4,
                                                                  letterSpacing:
                                                                      0.0,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  fontStyle: FlutterFlowTheme.of(
                                                                          context)
                                                                      .labelMedium
                                                                      .fontStyle,
                                                                  lineHeight:
                                                                      1.3,
                                                                ),
                                                        hintText:
                                                            'Selling price',
                                                        hintStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .labelMedium
                                                                .override(
                                                                  font: GoogleFonts
                                                                      .manrope(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                    fontStyle: FlutterFlowTheme.of(
                                                                            context)
                                                                        .labelMedium
                                                                        .fontStyle,
                                                                  ),
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .greyL4,
                                                                  letterSpacing:
                                                                      0.0,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  fontStyle: FlutterFlowTheme.of(
                                                                          context)
                                                                      .labelMedium
                                                                      .fontStyle,
                                                                  lineHeight:
                                                                      1.3,
                                                                ),
                                                        enabledBorder:
                                                            OutlineInputBorder(
                                                          borderSide:
                                                              BorderSide(
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .greyL2,
                                                            width: 1.0,
                                                          ),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      4.0),
                                                        ),
                                                        focusedBorder:
                                                            OutlineInputBorder(
                                                          borderSide:
                                                              BorderSide(
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .greyD1,
                                                            width: 1.0,
                                                          ),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      4.0),
                                                        ),
                                                        errorBorder:
                                                            OutlineInputBorder(
                                                          borderSide:
                                                              BorderSide(
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .error,
                                                            width: 1.0,
                                                          ),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      4.0),
                                                        ),
                                                        focusedErrorBorder:
                                                            OutlineInputBorder(
                                                          borderSide:
                                                              BorderSide(
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .error,
                                                            width: 1.0,
                                                          ),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      4.0),
                                                        ),
                                                        filled: true,
                                                        fillColor:
                                                            Color(0xFFF7F9FC),
                                                        contentPadding:
                                                            EdgeInsetsDirectional
                                                                .fromSTEB(
                                                                    12.0,
                                                                    16.0,
                                                                    12.0,
                                                                    16.0),
                                                      ),
                                                      style:
                                                          FlutterFlowTheme.of(
                                                                  context)
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
                                                                    .primaryText,
                                                                letterSpacing:
                                                                    0.0,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                fontStyle: FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .fontStyle,
                                                                lineHeight: 1.3,
                                                              ),
                                                      keyboardType:
                                                          TextInputType.number,
                                                      cursorColor:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .primaryText,
                                                      validator: _model
                                                          .textController3Validator
                                                          .asValidator(context),
                                                      inputFormatters: [
                                                        FilteringTextInputFormatter
                                                            .allow(
                                                                RegExp('[0-9]'))
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                            ].divide(SizedBox(height: 8.0)),
                                          ),
                                          Column(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Align(
                                                alignment: AlignmentDirectional(
                                                    -1.0, 0.0),
                                                child: Text(
                                                  'Location *',
                                                  style: FlutterFlowTheme.of(
                                                          context)
                                                      .bodyMedium
                                                      .override(
                                                        font:
                                                            GoogleFonts.manrope(
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
                                                                .extraBlack,
                                                        letterSpacing: 0.0,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyMedium
                                                                .fontStyle,
                                                        lineHeight: 1.3,
                                                      ),
                                                ),
                                              ),
                                              Padding(
                                                padding: EdgeInsetsDirectional
                                                    .fromSTEB(
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
                                                            EasyDebounce
                                                                .debounce(
                                                          '_model.locationTextFieldTextController',
                                                          Duration(
                                                              milliseconds:
                                                                  2000),
                                                          () async {
                                                            if ((String var1) {
                                                              return var1
                                                                      .length >=
                                                                  3;
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
                                                                (_model.places
                                                                        ?.jsonBody ??
                                                                    ''),
                                                              )!
                                                                      .toList()
                                                                      .cast<
                                                                          String>();
                                                              _model.choosedPlace =
                                                                  null;
                                                              _model.placesId =
                                                                  ShowSuggestionsCall
                                                                          .placeId(
                                                                (_model.places
                                                                        ?.jsonBody ??
                                                                    ''),
                                                              )!
                                                                      .toList()
                                                                      .cast<
                                                                          String>();
                                                              safeSetState(
                                                                  () {});
                                                              _model.showSuggestions =
                                                                  true;
                                                              safeSetState(
                                                                  () {});
                                                            } else {
                                                              if (_model
                                                                      .locationTextFieldTextController
                                                                      .text
                                                                      .length ==
                                                                  3) {
                                                                _model.showSuggestions =
                                                                    false;
                                                                _model.choosedPlace =
                                                                    null;
                                                                _model.showLocationError =
                                                                    true;
                                                                safeSetState(
                                                                    () {});
                                                              }
                                                            }

                                                            safeSetState(() {});
                                                          },
                                                        ),
                                                        autofocus: false,
                                                        obscureText: false,
                                                        decoration:
                                                            InputDecoration(
                                                          isDense: true,
                                                          labelStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelMedium
                                                                  .override(
                                                                    font: GoogleFonts
                                                                        .manrope(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500,
                                                                      fontStyle: FlutterFlowTheme.of(
                                                                              context)
                                                                          .labelMedium
                                                                          .fontStyle,
                                                                    ),
                                                                    color: FlutterFlowTheme.of(
                                                                            context)
                                                                        .greyL4,
                                                                    letterSpacing:
                                                                        0.0,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                    fontStyle: FlutterFlowTheme.of(
                                                                            context)
                                                                        .labelMedium
                                                                        .fontStyle,
                                                                    lineHeight:
                                                                        1.3,
                                                                  ),
                                                          hintText:
                                                              'Enter location',
                                                          hintStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelMedium
                                                                  .override(
                                                                    font: GoogleFonts
                                                                        .manrope(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500,
                                                                      fontStyle: FlutterFlowTheme.of(
                                                                              context)
                                                                          .labelMedium
                                                                          .fontStyle,
                                                                    ),
                                                                    color: FlutterFlowTheme.of(
                                                                            context)
                                                                        .greyL4,
                                                                    letterSpacing:
                                                                        0.0,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                    fontStyle: FlutterFlowTheme.of(
                                                                            context)
                                                                        .labelMedium
                                                                        .fontStyle,
                                                                    lineHeight:
                                                                        1.3,
                                                                  ),
                                                          enabledBorder:
                                                              OutlineInputBorder(
                                                            borderSide:
                                                                BorderSide(
                                                              color: FlutterFlowTheme
                                                                      .of(context)
                                                                  .greyL2,
                                                              width: 1.0,
                                                            ),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        4.0),
                                                          ),
                                                          focusedBorder:
                                                              OutlineInputBorder(
                                                            borderSide:
                                                                BorderSide(
                                                              color: FlutterFlowTheme
                                                                      .of(context)
                                                                  .greyD1,
                                                              width: 1.0,
                                                            ),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        4.0),
                                                          ),
                                                          errorBorder:
                                                              OutlineInputBorder(
                                                            borderSide:
                                                                BorderSide(
                                                              color: FlutterFlowTheme
                                                                      .of(context)
                                                                  .error,
                                                              width: 1.0,
                                                            ),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        4.0),
                                                          ),
                                                          focusedErrorBorder:
                                                              OutlineInputBorder(
                                                            borderSide:
                                                                BorderSide(
                                                              color: FlutterFlowTheme
                                                                      .of(context)
                                                                  .error,
                                                              width: 1.0,
                                                            ),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        4.0),
                                                          ),
                                                          filled: true,
                                                          fillColor:
                                                              Color(0xFFF7F9FC),
                                                          contentPadding:
                                                              EdgeInsetsDirectional
                                                                  .fromSTEB(
                                                                      12.0,
                                                                      16.0,
                                                                      15.0,
                                                                      16.0),
                                                        ),
                                                        style:
                                                            FlutterFlowTheme.of(
                                                                    context)
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
                                                                      .primaryText,
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
                                                        cursorColor:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .primaryText,
                                                        validator: _model
                                                            .locationTextFieldTextControllerValidator
                                                            .asValidator(
                                                                context),
                                                      ),
                                                    ),
                                                    Align(
                                                      alignment:
                                                          AlignmentDirectional(
                                                              1.0, 0.0),
                                                      child: Padding(
                                                        padding:
                                                            EdgeInsetsDirectional
                                                                .fromSTEB(
                                                                    0.0,
                                                                    12.0,
                                                                    10.0,
                                                                    0.0),
                                                        child: ClipRRect(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      0.0),
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
                                              if (_model.showSuggestions)
                                                Padding(
                                                  padding: EdgeInsetsDirectional
                                                      .fromSTEB(
                                                          0.0, 8.0, 0.0, 0.0),
                                                  child: Container(
                                                    height: 150.0,
                                                    decoration: BoxDecoration(),
                                                    child: Builder(
                                                      builder: (context) {
                                                        final searchplaces =
                                                            _model.placesList
                                                                .toList();

                                                        return ListView.builder(
                                                          padding:
                                                              EdgeInsets.zero,
                                                          shrinkWrap: true,
                                                          scrollDirection:
                                                              Axis.vertical,
                                                          itemCount:
                                                              searchplaces
                                                                  .length,
                                                          itemBuilder: (context,
                                                              searchplacesIndex) {
                                                            final searchplacesItem =
                                                                searchplaces[
                                                                    searchplacesIndex];
                                                            return InkWell(
                                                              splashColor: Colors
                                                                  .transparent,
                                                              focusColor: Colors
                                                                  .transparent,
                                                              hoverColor: Colors
                                                                  .transparent,
                                                              highlightColor:
                                                                  Colors
                                                                      .transparent,
                                                              onTap: () async {
                                                                _model.choosedPlace =
                                                                    searchplacesItem;
                                                                _model.showLocationError =
                                                                    false;
                                                                safeSetState(
                                                                    () {});
                                                                safeSetState(
                                                                    () {
                                                                  _model.locationTextFieldTextController
                                                                          ?.text =
                                                                      searchplacesItem;
                                                                });
                                                                _model.placeDetails =
                                                                    await GetPlaceDetailsCall
                                                                        .call(
                                                                  placeId: _model
                                                                      .placesId
                                                                      .elementAtOrNull(
                                                                          searchplacesIndex),
                                                                );

                                                                _model.showSuggestions =
                                                                    false;
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
                                                                _model.city =
                                                                    GetPlaceDetailsCall
                                                                        .city(
                                                                  (_model.placeDetails
                                                                          ?.jsonBody ??
                                                                      ''),
                                                                );
                                                                safeSetState(
                                                                    () {});

                                                                safeSetState(
                                                                    () {});
                                                              },
                                                              child: Container(
                                                                decoration:
                                                                    BoxDecoration(),
                                                                child: Padding(
                                                                  padding: EdgeInsetsDirectional
                                                                      .fromSTEB(
                                                                          0.0,
                                                                          10.0,
                                                                          0.0,
                                                                          10.0),
                                                                  child: Row(
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .max,
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
                                                                        color: FlutterFlowTheme.of(context)
                                                                            .primary,
                                                                        size:
                                                                            16.0,
                                                                      ),
                                                                      Flexible(
                                                                        child:
                                                                            Text(
                                                                          searchplacesItem,
                                                                          style: FlutterFlowTheme.of(context)
                                                                              .bodyMedium
                                                                              .override(
                                                                                font: GoogleFonts.manrope(
                                                                                  fontWeight: FontWeight.w500,
                                                                                  fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                ),
                                                                                color: FlutterFlowTheme.of(context).extraBlack,
                                                                                letterSpacing: 0.0,
                                                                                fontWeight: FontWeight.w500,
                                                                                fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                lineHeight: 1.3,
                                                                              ),
                                                                        ),
                                                                      ),
                                                                    ].divide(SizedBox(
                                                                        width:
                                                                            5.0)),
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
                                              if (_model.showLocationError)
                                                Align(
                                                  alignment:
                                                      AlignmentDirectional(
                                                          -1.0, -1.0),
                                                  child: Text(
                                                    'Location is Required',
                                                    style: FlutterFlowTheme.of(
                                                            context)
                                                        .bodyMedium
                                                        .override(
                                                          font: GoogleFonts
                                                              .manrope(
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            fontStyle:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .fontStyle,
                                                          ),
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .redColor2,
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
                                                ),
                                            ],
                                          ),
                                          Padding(
                                            padding:
                                                EdgeInsetsDirectional.fromSTEB(
                                                    0.0, 8.0, 0.0, 0.0),
                                            child: FFButtonWidget(
                                              onPressed: () async {
                                                var _shouldSetState = false;
                                                _model.titleform1 = true;
                                                if (_model.formKey1
                                                            .currentState ==
                                                        null ||
                                                    !_model
                                                        .formKey1.currentState!
                                                        .validate()) {
                                                  _model.titleform1 = false;
                                                }
                                                _shouldSetState = true;
                                                if (_model.titleform1 == true) {
                                                  _model.descriptionform1 =
                                                      true;
                                                  if (_model.formKey2
                                                              .currentState ==
                                                          null ||
                                                      !_model.formKey2
                                                          .currentState!
                                                          .validate()) {
                                                    _model.descriptionform1 =
                                                        false;
                                                  }
                                                  _shouldSetState = true;
                                                  if (_model.descriptionform1 ==
                                                      true) {
                                                    if (_model.price ==
                                                        'Free') {
                                                      if (_model.dropDownValue !=
                                                              null &&
                                                          _model.dropDownValue !=
                                                              '') {
                                                        _model.categoryChoosed =
                                                            false;
                                                        safeSetState(() {});
                                                        if ((_model
                                                                .uploadedLocalFiles_uploadDataGq211
                                                                .isNotEmpty) ==
                                                            true) {
                                                          _model.imageSet =
                                                              false;
                                                          safeSetState(() {});
                                                          if (_model.choosedPlace !=
                                                                  null &&
                                                              _model.choosedPlace !=
                                                                  '') {
                                                            _model.showLocationError =
                                                                false;
                                                            safeSetState(() {});
                                                            _model.insert1 =
                                                                await UpdateSaleWithoutImageCall
                                                                    .call(
                                                              title: _model
                                                                  .textController1
                                                                  .text,
                                                              description: _model
                                                                  .textFieldTextController
                                                                  .text,
                                                              saleCategory: _model
                                                                  .dropDownValue,
                                                              ePriceType: _model
                                                                  .radioButtonValue,
                                                              price: int.tryParse(
                                                                  _model
                                                                      .textController3
                                                                      .text),
                                                              location: _model
                                                                  .choosedPlace,
                                                              saleId: widget!
                                                                  .saleId,
                                                              lat: _model
                                                                  .latitude,
                                                              lng: columnSaleRow
                                                                  ?.longitude,
                                                              token:
                                                                  currentJwtToken,
                                                              city: _model.city,
                                                            );

                                                            _shouldSetState =
                                                                true;
                                                            await SaleImagesTable()
                                                                .delete(
                                                              matchingRows:
                                                                  (rows) => rows
                                                                      .eqOrNull(
                                                                'sale_id',
                                                                widget!.saleId,
                                                              ),
                                                            );
                                                            await actions
                                                                .uploadSalesImages(
                                                              _model
                                                                  .uploadedLocalFiles_uploadDataGq211
                                                                  .toList(),
                                                              widget!.saleId!,
                                                              currentUserUid,
                                                              FFAppState()
                                                                  .communityId
                                                                  .toString(),
                                                            );

                                                            context.pushNamed(
                                                              SaleWidget
                                                                  .routeName,
                                                              queryParameters: {
                                                                'pageType':
                                                                    serializeParam(
                                                                  'yours',
                                                                  ParamType
                                                                      .String,
                                                                ),
                                                              }.withoutNulls,
                                                            );
                                                          } else {
                                                            _model.showLocationError =
                                                                true;
                                                            safeSetState(() {});
                                                          }
                                                        } else {
                                                          if (_model
                                                                  .imageCount! >
                                                              0) {
                                                            _model.imageSet =
                                                                false;
                                                            safeSetState(() {});
                                                            if (_model.choosedPlace !=
                                                                    null &&
                                                                _model.choosedPlace !=
                                                                    '') {
                                                              _model.showLocationError =
                                                                  false;
                                                              safeSetState(
                                                                  () {});
                                                              _model.insert2 =
                                                                  await UpdateSaleWithoutImageCall
                                                                      .call(
                                                                title: _model
                                                                    .textController1
                                                                    .text,
                                                                description: _model
                                                                    .textFieldTextController
                                                                    .text,
                                                                saleCategory: _model
                                                                    .dropDownValue,
                                                                ePriceType: _model
                                                                    .radioButtonValue,
                                                                price: int.tryParse(
                                                                    _model
                                                                        .textController3
                                                                        .text),
                                                                location: _model
                                                                    .choosedPlace,
                                                                saleId: widget!
                                                                    .saleId,
                                                                lat: _model
                                                                    .latitude,
                                                                lng: columnSaleRow
                                                                    ?.longitude,
                                                                token:
                                                                    currentJwtToken,
                                                                city:
                                                                    _model.city,
                                                              );

                                                              _shouldSetState =
                                                                  true;

                                                              context.pushNamed(
                                                                SaleWidget
                                                                    .routeName,
                                                                queryParameters:
                                                                    {
                                                                  'pageType':
                                                                      serializeParam(
                                                                    'yours',
                                                                    ParamType
                                                                        .String,
                                                                  ),
                                                                }.withoutNulls,
                                                              );
                                                            } else {
                                                              _model.showLocationError =
                                                                  true;
                                                              safeSetState(
                                                                  () {});
                                                            }
                                                          } else {
                                                            _model.imageSet =
                                                                true;
                                                            safeSetState(() {});
                                                            if (_shouldSetState)
                                                              safeSetState(
                                                                  () {});
                                                            return;
                                                          }
                                                        }
                                                      } else {
                                                        _model.categoryChoosed =
                                                            true;
                                                        safeSetState(() {});
                                                        if ((_model
                                                                .uploadedLocalFiles_uploadDataGq211
                                                                .isNotEmpty) ==
                                                            true) {
                                                          _model.imageSet =
                                                              false;
                                                          safeSetState(() {});
                                                        } else {
                                                          if (_model
                                                                  .imageCount ==
                                                              0) {
                                                            _model.imageSet =
                                                                true;
                                                            safeSetState(() {});
                                                          } else {
                                                            _model.imageSet =
                                                                false;
                                                            safeSetState(() {});
                                                          }

                                                          if (_model.choosedPlace !=
                                                                  null &&
                                                              _model.choosedPlace !=
                                                                  '') {
                                                            _model.showLocationError =
                                                                false;
                                                            safeSetState(() {});
                                                          } else {
                                                            _model.showLocationError =
                                                                true;
                                                            safeSetState(() {});
                                                          }
                                                        }
                                                      }
                                                    } else {
                                                      _model.priceform1 = true;
                                                      if (_model.formKey3
                                                                  .currentState ==
                                                              null ||
                                                          !_model.formKey3
                                                              .currentState!
                                                              .validate()) {
                                                        _model.priceform1 =
                                                            false;
                                                      }
                                                      _shouldSetState = true;
                                                      if (_model.priceform1 ==
                                                          true) {
                                                        if (_model.dropDownValue !=
                                                                null &&
                                                            _model.dropDownValue !=
                                                                '') {
                                                          _model.categoryChoosed =
                                                              false;
                                                          safeSetState(() {});
                                                          if ((_model
                                                                  .uploadedLocalFiles_uploadDataGq211
                                                                  .isNotEmpty) ==
                                                              true) {
                                                            _model.imageSet =
                                                                false;
                                                            safeSetState(() {});
                                                            if (_model.choosedPlace !=
                                                                    null &&
                                                                _model.choosedPlace !=
                                                                    '') {
                                                              _model.showLocationError =
                                                                  false;
                                                              safeSetState(
                                                                  () {});
                                                              _model.insert3 =
                                                                  await UpdateSaleWithoutImageCall
                                                                      .call(
                                                                title: _model
                                                                    .textController1
                                                                    .text,
                                                                description: _model
                                                                    .textFieldTextController
                                                                    .text,
                                                                saleCategory: _model
                                                                    .dropDownValue,
                                                                ePriceType: _model
                                                                    .radioButtonValue,
                                                                price: int.tryParse(
                                                                    _model
                                                                        .textController3
                                                                        .text),
                                                                location: _model
                                                                    .choosedPlace,
                                                                saleId: widget!
                                                                    .saleId,
                                                                lat: _model
                                                                    .latitude,
                                                                lng: columnSaleRow
                                                                    ?.longitude,
                                                                token:
                                                                    currentJwtToken,
                                                                city:
                                                                    _model.city,
                                                              );

                                                              _shouldSetState =
                                                                  true;
                                                              await SaleImagesTable()
                                                                  .delete(
                                                                matchingRows:
                                                                    (rows) => rows
                                                                        .eqOrNull(
                                                                  'sale_id',
                                                                  widget!
                                                                      .saleId,
                                                                ),
                                                              );
                                                              await actions
                                                                  .uploadSalesImages(
                                                                _model
                                                                    .uploadedLocalFiles_uploadDataGq211
                                                                    .toList(),
                                                                widget!.saleId!,
                                                                currentUserUid,
                                                                FFAppState()
                                                                    .communityId
                                                                    .toString(),
                                                              );

                                                              context.pushNamed(
                                                                SaleWidget
                                                                    .routeName,
                                                                queryParameters:
                                                                    {
                                                                  'pageType':
                                                                      serializeParam(
                                                                    'yours',
                                                                    ParamType
                                                                        .String,
                                                                  ),
                                                                }.withoutNulls,
                                                              );
                                                            } else {
                                                              _model.showLocationError =
                                                                  true;
                                                              safeSetState(
                                                                  () {});
                                                            }
                                                          } else {
                                                            if (_model
                                                                    .imageCount ==
                                                                0) {
                                                              _model.imageSet =
                                                                  true;
                                                              safeSetState(
                                                                  () {});
                                                            } else {
                                                              _model.imageSet =
                                                                  false;
                                                              safeSetState(
                                                                  () {});
                                                              _model.insert4 =
                                                                  await UpdateSaleWithoutImageCall
                                                                      .call(
                                                                title: _model
                                                                    .textController1
                                                                    .text,
                                                                description: _model
                                                                    .textFieldTextController
                                                                    .text,
                                                                saleCategory: _model
                                                                    .dropDownValue,
                                                                ePriceType: _model
                                                                    .radioButtonValue,
                                                                price: int.tryParse(
                                                                    _model
                                                                        .textController3
                                                                        .text),
                                                                location: _model
                                                                    .choosedPlace,
                                                                saleId: widget!
                                                                    .saleId,
                                                                lat: _model
                                                                    .latitude,
                                                                lng: columnSaleRow
                                                                    ?.longitude,
                                                                token:
                                                                    currentJwtToken,
                                                                city:
                                                                    _model.city,
                                                              );

                                                              _shouldSetState =
                                                                  true;

                                                              context.pushNamed(
                                                                SaleWidget
                                                                    .routeName,
                                                                queryParameters:
                                                                    {
                                                                  'pageType':
                                                                      serializeParam(
                                                                    'yours',
                                                                    ParamType
                                                                        .String,
                                                                  ),
                                                                }.withoutNulls,
                                                              );
                                                            }
                                                          }
                                                        } else {
                                                          _model.categoryChoosed =
                                                              true;
                                                          safeSetState(() {});
                                                          if ((_model
                                                                  .uploadedLocalFiles_uploadDataGq211
                                                                  .isNotEmpty) ==
                                                              true) {
                                                            _model.imageSet =
                                                                false;
                                                            safeSetState(() {});
                                                          } else {
                                                            if (_model
                                                                    .imageCount ==
                                                                0) {
                                                              _model.imageSet =
                                                                  true;
                                                              safeSetState(
                                                                  () {});
                                                            } else {
                                                              _model.imageSet =
                                                                  false;
                                                              safeSetState(
                                                                  () {});
                                                            }
                                                          }

                                                          if (_model.choosedPlace !=
                                                                  null &&
                                                              _model.choosedPlace !=
                                                                  '') {
                                                            _model.showLocationError =
                                                                false;
                                                            safeSetState(() {});
                                                          } else {
                                                            _model.showLocationError =
                                                                true;
                                                            safeSetState(() {});
                                                          }

                                                          if (_shouldSetState)
                                                            safeSetState(() {});
                                                          return;
                                                        }
                                                      } else {
                                                        if (_model.dropDownValue !=
                                                                null &&
                                                            _model.dropDownValue !=
                                                                '') {
                                                          _model.categoryChoosed =
                                                              false;
                                                          safeSetState(() {});
                                                        } else {
                                                          _model.categoryChoosed =
                                                              true;
                                                          safeSetState(() {});
                                                        }

                                                        if ((_model
                                                                .uploadedLocalFiles_uploadDataGq211
                                                                .isNotEmpty) ==
                                                            true) {
                                                          _model.imageSet =
                                                              false;
                                                          safeSetState(() {});
                                                        } else {
                                                          if (_model
                                                                  .imageCount ==
                                                              0) {
                                                            _model.imageSet =
                                                                true;
                                                            safeSetState(() {});
                                                          } else {
                                                            _model.imageSet =
                                                                false;
                                                            safeSetState(() {});
                                                          }
                                                        }

                                                        if (_model.choosedPlace !=
                                                                null &&
                                                            _model.choosedPlace !=
                                                                '') {
                                                          _model.showLocationError =
                                                              false;
                                                          safeSetState(() {});
                                                        } else {
                                                          _model.showLocationError =
                                                              true;
                                                          safeSetState(() {});
                                                        }

                                                        if (_shouldSetState)
                                                          safeSetState(() {});
                                                        return;
                                                      }
                                                    }
                                                  } else {
                                                    if (_model.formKey3
                                                            .currentState !=
                                                        null) {
                                                      _model.formKey3
                                                          .currentState!
                                                          .validate();
                                                    }
                                                    if (_model.dropDownValue !=
                                                            null &&
                                                        _model.dropDownValue !=
                                                            '') {
                                                      _model.categoryChoosed =
                                                          false;
                                                      safeSetState(() {});
                                                    } else {
                                                      _model.categoryChoosed =
                                                          true;
                                                      safeSetState(() {});
                                                    }

                                                    if ((_model
                                                            .uploadedLocalFiles_uploadDataGq211
                                                            .isNotEmpty) ==
                                                        true) {
                                                      _model.imageSet = false;
                                                      safeSetState(() {});
                                                    } else {
                                                      if (_model.imageCount ==
                                                          0) {
                                                        _model.imageSet = true;
                                                        safeSetState(() {});
                                                      } else {
                                                        _model.imageSet = false;
                                                        safeSetState(() {});
                                                      }
                                                    }

                                                    if (_model.choosedPlace !=
                                                            null &&
                                                        _model.choosedPlace !=
                                                            '') {
                                                      _model.showLocationError =
                                                          false;
                                                      safeSetState(() {});
                                                    } else {
                                                      _model.showLocationError =
                                                          true;
                                                      safeSetState(() {});
                                                    }

                                                    if (_shouldSetState)
                                                      safeSetState(() {});
                                                    return;
                                                  }
                                                } else {
                                                  if (_model.formKey2
                                                          .currentState !=
                                                      null) {
                                                    _model
                                                        .formKey2.currentState!
                                                        .validate();
                                                  }
                                                  if (_model.formKey3
                                                          .currentState !=
                                                      null) {
                                                    _model
                                                        .formKey3.currentState!
                                                        .validate();
                                                  }
                                                  if (_model.dropDownValue !=
                                                          null &&
                                                      _model.dropDownValue !=
                                                          '') {
                                                    _model.categoryChoosed =
                                                        false;
                                                    safeSetState(() {});
                                                  } else {
                                                    _model.categoryChoosed =
                                                        true;
                                                    safeSetState(() {});
                                                  }

                                                  if ((_model
                                                          .uploadedLocalFiles_uploadDataGq211
                                                          .isNotEmpty) ==
                                                      true) {
                                                    _model.imageSet = false;
                                                    safeSetState(() {});
                                                  } else {
                                                    if (_model.imageCount ==
                                                        0) {
                                                      _model.imageSet = true;
                                                      safeSetState(() {});
                                                    } else {
                                                      _model.imageSet = false;
                                                      safeSetState(() {});
                                                    }
                                                  }

                                                  if (_model.choosedPlace !=
                                                          null &&
                                                      _model.choosedPlace !=
                                                          '') {
                                                    _model.showLocationError =
                                                        false;
                                                    safeSetState(() {});
                                                  } else {
                                                    _model.showLocationError =
                                                        true;
                                                    safeSetState(() {});
                                                  }
                                                }

                                                if (_shouldSetState)
                                                  safeSetState(() {});
                                              },
                                              text: 'Save',
                                              options: FFButtonOptions(
                                                width: double.infinity,
                                                height: 46.0,
                                                padding: EdgeInsetsDirectional
                                                    .fromSTEB(
                                                        16.0, 12.0, 16.0, 12.0),
                                                iconPadding:
                                                    EdgeInsetsDirectional
                                                        .fromSTEB(
                                                            0.0, 0.0, 0.0, 0.0),
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .primary,
                                                textStyle: FlutterFlowTheme.of(
                                                        context)
                                                    .titleSmall
                                                    .override(
                                                      font: GoogleFonts.manrope(
                                                        fontWeight:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .titleSmall
                                                                .fontWeight,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .titleSmall
                                                                .fontStyle,
                                                      ),
                                                      color: Colors.white,
                                                      letterSpacing: 0.0,
                                                      fontWeight:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .titleSmall
                                                              .fontWeight,
                                                      fontStyle:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .titleSmall
                                                              .fontStyle,
                                                      lineHeight: 1.4,
                                                    ),
                                                elevation: 0.0,
                                                borderRadius:
                                                    BorderRadius.circular(24.0),
                                              ),
                                            ),
                                          ),
                                        ]
                                            .divide(SizedBox(height: 12.0))
                                            .addToStart(SizedBox(height: 12.0)),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ].addToEnd(SizedBox(height: 20.0)),
                          ),
                        ),
                      ),
                    if (!_model.showData)
                      Expanded(
                        child: Align(
                          alignment: AlignmentDirectional(0.0, 0.0),
                          child: Container(
                            width: 50.0,
                            height: 50.0,
                            child: custom_widgets.SimpleLoader(
                              width: 50.0,
                              height: 50.0,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
