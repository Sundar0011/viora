import '/auth/supabase_auth/auth_util.dart';
import '/app_constants.dart';
import '/backend/api_requests/api_calls.dart';
import '/backend/supabase/supabase.dart';
import '/components/app_icon_button.dart';
import '/components/app_network_image.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/pages/home/comp_loading/comp_loading_widget.dart';
import '/pages/sale/comp_sold_delete/comp_sold_delete_widget.dart';
import '/pages/sale/comp_three_dot_report_sale/comp_three_dot_report_sale_widget.dart';
import 'dart:ui';
import '/custom_code/widgets/index.dart' as custom_widgets;
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';
import 'dart:async';
import 'dart:math' as math;
import 'package:smooth_page_indicator/smooth_page_indicator.dart'
    as smooth_page_indicator;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'sale_details_model.dart';
export 'sale_details_model.dart';

class SaleDetailsWidget extends StatefulWidget {
  const SaleDetailsWidget({
    super.key,
    required this.saleId,
  });

  final String? saleId;

  static String routeName = 'SaleDetails';
  static String routePath = 'saleDetails';

  @override
  State<SaleDetailsWidget> createState() => _SaleDetailsWidgetState();
}

class _SaleDetailsWidgetState extends State<SaleDetailsWidget> {
  late SaleDetailsModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => SaleDetailsModel());

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      _model.showData = false;
      safeSetState(() {});
      _model.apiResultgxl = await GetSalesDetailsCall.call(
        pSalesid: widget!.saleId,
        pUserid: currentUserUid,
        token: currentJwtToken,
      );

      _model.saleDetails = await GetSaleHomePageSalesCall.call(
        pUserid: currentUserUid,
        pCommunityid: FFAppState().communityId,
        pSaleid: widget!.saleId,
        token: currentJwtToken,
      );

      _model.saleData = (_model.apiResultgxl?.jsonBody ?? '');
      _model.adminLng = getJsonField(
        _model.saleData,
        r'''$.seller_profile.longitude''',
      );
      _model.adminLat = getJsonField(
        _model.saleData,
        r'''$.seller_profile.latitude''',
      );
      _model.sales = (_model.saleDetails?.jsonBody ?? '');
      safeSetState(() {});
      _model.showData = true;
      safeSetState(() {});
    });

    _model.textController ??=
        TextEditingController(text: 'Hi, is this available?');
    _model.textFieldFocusNode ??= FocusNode();
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
          bottom: true,
          child: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              color: FlutterFlowTheme.of(context).pageBack,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                if (_model.showData)
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.start,
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
                                  MergeSemantics(
                                    child: Semantics(
                                      button: true,
                                      label: 'Back',
                                      child: FlutterFlowIconButton(
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
                                    ),
                                  ),
                                  Expanded(
                                    child: InkWell(
                                      splashColor: FlutterFlowTheme.of(context)
                                          .primary
                                          .withAlpha(0x14),
                                      focusColor: Colors.transparent,
                                      hoverColor: Colors.transparent,
                                      highlightColor: Colors.transparent,
                                      onTap: () async {
                                        context.pushNamed(
                                          SearchWidget.routeName,
                                          queryParameters: {
                                            'searchName': serializeParam(
                                              '',
                                              ParamType.String,
                                            ),
                                          }.withoutNulls,
                                        );
                                      },
                                      child: Container(
                                        height: 36.0,
                                        decoration: BoxDecoration(
                                          color: FlutterFlowTheme.of(context)
                                              .alternate,
                                          borderRadius:
                                              BorderRadius.circular(4.0),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.max,
                                          children: [
                                            Icon(
                                              Icons.search,
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .greyL4,
                                              size: 20.0,
                                            ),
                                            Text(
                                              'Search',
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
                                                        .greyL4,
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
                                          ]
                                              .divide(SizedBox(width: 12.0))
                                              .addToStart(SizedBox(width: 12.0))
                                              .addToEnd(SizedBox(width: 12.0)),
                                        ),
                                      ),
                                    ),
                                  ),
                                  AppIconButton(
                                    semanticLabel: 'Listing options',
                                    tooltip: 'Listing options',
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
                                              child:
                                                  CompThreeDotReportSaleWidget(
                                                saleId: widget!.saleId!,
                                                reportUserId: currentUserUid,
                                                type: getJsonField(
                                                  _model.saleData,
                                                  r'''$.created_by''',
                                                ).toString(),
                                                imageCount: getJsonField(
                                                  _model.saleData,
                                                  r'''$.image_count''',
                                                ),
                                                reportedUserId: getJsonField(
                                                  _model.saleData,
                                                  r'''$.created_by''',
                                                ).toString(),
                                              ),
                                            ),
                                          );
                                        },
                                      ).then((value) => safeSetState(() {}));
                                    },
                                    // The 34dp grey disc is unchanged; the hit
                                    // area alone grows out to 44dp.
                                    iconWidget: Container(
                                      width: 34.0,
                                      height: 34.0,
                                      decoration: BoxDecoration(
                                        color:
                                            FlutterFlowTheme.of(context).greyL2,
                                        shape: BoxShape.circle,
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
                                  ),
                                ]
                                    .divide(SizedBox(width: 10.0))
                                    .addToStart(SizedBox(width: 10.0))
                                    .addToEnd(SizedBox(width: 20.0)),
                              ),
                            ),
                          ),
                          if ((getJsonField(
                                    _model.saleData,
                                    r'''$.image_count''',
                                  ) >
                                  1) ==
                              true)
                            Container(
                              width: double.infinity,
                              height: 320.0,
                              decoration: BoxDecoration(
                                color: FlutterFlowTheme.of(context)
                                    .secondaryBackground,
                              ),
                              child: Container(
                                height: 320.0,
                                child: Builder(
                                  builder: (context) {
                                    final images = getJsonField(
                                      _model.saleData,
                                      r'''$.images''',
                                    ).toList();

                                    return Container(
                                      width: double.infinity,
                                      height: 320.0,
                                      child: Stack(
                                        children: [
                                          PageView.builder(
                                            controller:
                                                _model.pageViewController ??=
                                                    PageController(
                                                        initialPage: max(
                                                            0,
                                                            min(
                                                                0,
                                                                images.length -
                                                                    1))),
                                            scrollDirection: Axis.horizontal,
                                            itemCount: images.length,
                                            itemBuilder:
                                                (context, imagesIndex) {
                                              final imagesItem =
                                                  images[imagesIndex];
                                              return AppNetworkImage(
                                                url: imagesItem.toString(),
                                                width: double.infinity,
                                                height: double.infinity,
                                                fit: BoxFit.cover,
                                                semanticLabel: 'Listing photo',
                                              );
                                            },
                                          ),
                                          Align(
                                            alignment:
                                                AlignmentDirectional(0.0, 1.0),
                                            child: Padding(
                                              padding: EdgeInsetsDirectional
                                                  .fromSTEB(
                                                      0.0, 0.0, 0.0, 10.0),
                                              child: smooth_page_indicator
                                                  .SmoothPageIndicator(
                                                controller: _model
                                                        .pageViewController ??=
                                                    PageController(
                                                        initialPage: max(
                                                            0,
                                                            min(
                                                                0,
                                                                images.length -
                                                                    1))),
                                                count: images.length,
                                                axisDirection: Axis.horizontal,
                                                onDotClicked: (i) async {
                                                  await _model
                                                      .pageViewController!
                                                      .animateToPage(
                                                    i,
                                                    duration: Duration(
                                                        milliseconds: 500),
                                                    curve: Curves.ease,
                                                  );
                                                  safeSetState(() {});
                                                },
                                                effect: smooth_page_indicator
                                                    .ExpandingDotsEffect(
                                                  expansionFactor: 4.0,
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
                                                      PaintingStyle.fill,
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
                            ),
                          if ((getJsonField(
                                    _model.saleData,
                                    r'''$.image_count''',
                                  ) ==
                                  0) ==
                              true)
                            Container(
                              width: double.infinity,
                              height: 320.0,
                              decoration: BoxDecoration(
                                color: FlutterFlowTheme.of(context)
                                    .secondaryBackground,
                                image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: Image.asset(
                                    'assets/images/caarousel.webp',
                                  ).image,
                                ),
                              ),
                              alignment: AlignmentDirectional(0.0, 0.0),
                            ),
                          if ((getJsonField(
                                    _model.saleData,
                                    r'''$.image_count''',
                                  ) ==
                                  1) ==
                              true)
                            Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  0.0, 4.0, 0.0, 0.0),
                              child: AppNetworkImage(
                                url: getJsonField(
                                  _model.saleData,
                                  r'''$.images[0]''',
                                ).toString(),
                                width: double.infinity,
                                height: 320.0,
                                fit: BoxFit.cover,
                                semanticLabel: 'Listing photo',
                              ),
                            ),
                          Container(
                            decoration: BoxDecoration(
                              color: FlutterFlowTheme.of(context).white,
                            ),
                            child: Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  20.0, 12.0, 20.0, 0.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Column(
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      Align(
                                        alignment:
                                            AlignmentDirectional(-1.0, -1.0),
                                        child: Text(
                                          getJsonField(
                                            _model.saleData,
                                            r'''$.title''',
                                          ).toString(),
                                          style: FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .override(
                                                font: GoogleFonts.manrope(
                                                  fontWeight: FontWeight.bold,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMedium
                                                          .fontStyle,
                                                ),
                                                color:
                                                    FlutterFlowTheme.of(context)
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
                                      ),
                                      if (((String var1) {
                                            return var1 != "null";
                                          }(getJsonField(
                                            _model.saleData,
                                            r'''$.price''',
                                          ).toString())) ==
                                          true)
                                        Align(
                                          alignment:
                                              AlignmentDirectional(-1.0, 0.0),
                                          child: Text(
                                            '$kCurrencySymbol${getJsonField(
                                              _model.saleData,
                                              r'''$.price''',
                                            ).toString()}',
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
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .extraBlack,
                                                  fontSize: 16.0,
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
                                    ].divide(SizedBox(height: 8.0)),
                                  ),
                                  if (((String var1, String var2) {
                                        return var1 != var2;
                                      }(
                                          getJsonField(
                                            _model.saleData,
                                            r'''$.created_by''',
                                          ).toString(),
                                          currentUserUid)) ==
                                      true)
                                    Container(
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: FlutterFlowTheme.of(context)
                                            .secondaryBackground,
                                        borderRadius:
                                            BorderRadius.circular(4.0),
                                        border: Border.all(
                                          color: FlutterFlowTheme.of(context)
                                              .greayL1,
                                        ),
                                      ),
                                      child: Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            12.0, 0.0, 12.0, 0.0),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.max,
                                          children: [
                                            Row(
                                              mainAxisSize: MainAxisSize.max,
                                              children: [
                                                Icon(
                                                  Icons.forum_outlined,
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .primary,
                                                  size: 24.0,
                                                ),
                                                Text(
                                                  'Send ${getJsonField(
                                                    _model.saleData,
                                                    r'''$.seller_profile.name''',
                                                  ).toString()} a message',
                                                  style: FlutterFlowTheme.of(
                                                          context)
                                                      .bodyMedium
                                                      .override(
                                                        font:
                                                            GoogleFonts.manrope(
                                                          fontWeight:
                                                              FontWeight.w600,
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
                                                        fontSize: 18.0,
                                                        letterSpacing: 0.0,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyMedium
                                                                .fontStyle,
                                                        lineHeight: 1.4,
                                                      ),
                                                ),
                                              ].divide(SizedBox(width: 10.0)),
                                            ),
                                            Row(
                                              mainAxisSize: MainAxisSize.max,
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Expanded(
                                                  child: Container(
                                                    width: double.infinity,
                                                    child: TextFormField(
                                                      controller:
                                                          _model.textController,
                                                      focusNode: _model
                                                          .textFieldFocusNode,
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
                                                                      .extraBlack,
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
                                                                      .extraBlack,
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
                                                            color: Color(
                                                                0x00000000),
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
                                                            color: Color(
                                                                0x00000000),
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
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .greayL1,
                                                        contentPadding:
                                                            EdgeInsetsDirectional
                                                                .fromSTEB(
                                                                    12.0,
                                                                    8.0,
                                                                    12.0,
                                                                    8.0),
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
                                                                lineHeight: 1.3,
                                                              ),
                                                      cursorColor:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .primaryText,
                                                      validator: _model
                                                          .textControllerValidator
                                                          .asValidator(context),
                                                    ),
                                                  ),
                                                ),
                                                FFButtonWidget(
                                                  onPressed: () async {
                                                    _model.chatFoundSale =
                                                        await FindCommonChatCall
                                                            .call(
                                                      anonKey:
                                                          FFDevEnvironmentValues()
                                                              .AnonKey,
                                                      token: currentJwtToken,
                                                      user1: currentUserUid,
                                                      user2: getJsonField(
                                                        _model.saleData,
                                                        r'''$.created_by''',
                                                      ).toString(),
                                                    );

                                                    if (FindCommonChatCall
                                                            .chatFound(
                                                          (_model.chatFoundSale
                                                                  ?.jsonBody ??
                                                              ''),
                                                        ) ==
                                                        true) {
                                                      _model.jgjg =
                                                          await RestoreChatUserCall
                                                              .call(
                                                        pChatId:
                                                            FindCommonChatCall
                                                                .chatId(
                                                          (_model.chatFoundSale
                                                                  ?.jsonBody ??
                                                              ''),
                                                        ),
                                                        pUserId: getJsonField(
                                                          _model.saleData,
                                                          r'''$.created_by''',
                                                        ).toString(),
                                                        anonKey:
                                                            FFDevEnvironmentValues()
                                                                .AnonKey,
                                                        token: currentJwtToken,
                                                      );

                                                      await MessagesTable()
                                                          .insert({
                                                        'chat_id':
                                                            FindCommonChatCall
                                                                .chatId(
                                                          (_model.chatFoundSale
                                                                  ?.jsonBody ??
                                                              ''),
                                                        ),
                                                        'sender_id':
                                                            currentUserUid,
                                                        'e_message_type':
                                                            'image',
                                                        'is_read': false,
                                                        'file_url':
                                                            getJsonField(
                                                          _model.saleData,
                                                          r'''$.images[0]''',
                                                        ).toString(),
                                                        'community_id':
                                                            FFAppState()
                                                                .communityId,
                                                        'message': 'image',
                                                      });
                                                      await MessagesTable()
                                                          .insert({
                                                        'chat_id':
                                                            FindCommonChatCall
                                                                .chatId(
                                                          (_model.chatFoundSale
                                                                  ?.jsonBody ??
                                                              ''),
                                                        ),
                                                        'sender_id':
                                                            currentUserUid,
                                                        'e_message_type':
                                                            'text',
                                                        'is_read': false,
                                                        'community_id':
                                                            FFAppState()
                                                                .communityId,
                                                        'message': getJsonField(
                                                          _model.saleData,
                                                          r'''$.title''',
                                                        ).toString(),
                                                      });
                                                      await MessagesTable()
                                                          .insert({
                                                        'chat_id':
                                                            FindCommonChatCall
                                                                .chatId(
                                                          (_model.chatFoundSale
                                                                  ?.jsonBody ??
                                                              ''),
                                                        ),
                                                        'sender_id':
                                                            currentUserUid,
                                                        'e_message_type':
                                                            'text',
                                                        'is_read': false,
                                                        'community_id':
                                                            FFAppState()
                                                                .communityId,
                                                        'message': _model
                                                            .textController
                                                            .text,
                                                      });
                                                      await ChatTable().update(
                                                        data: {
                                                          'last_message_date':
                                                              supaSerialize<
                                                                      DateTime>(
                                                                  functions
                                                                      .getCurrentUtcTime()),
                                                          'last_message_user':
                                                              currentUserUid,
                                                          'last_message': _model
                                                              .textController
                                                              .text,
                                                        },
                                                        matchingRows: (rows) =>
                                                            rows.eqOrNull(
                                                          'id',
                                                          FindCommonChatCall
                                                              .chatId(
                                                            (_model.chatFoundSale
                                                                    ?.jsonBody ??
                                                                ''),
                                                          ),
                                                        ),
                                                      );

                                                      context.pushNamed(
                                                        MessagePageWidget
                                                            .routeName,
                                                        queryParameters: {
                                                          'chatId':
                                                              serializeParam(
                                                            FindCommonChatCall
                                                                .chatId(
                                                              (_model.chatFoundSale
                                                                      ?.jsonBody ??
                                                                  ''),
                                                            ),
                                                            ParamType.String,
                                                          ),
                                                          'userId':
                                                              serializeParam(
                                                            getJsonField(
                                                              _model.saleData,
                                                              r'''$.created_by''',
                                                            ).toString(),
                                                            ParamType.String,
                                                          ),
                                                        }.withoutNulls,
                                                      );
                                                    } else {
                                                      _model.chatsale =
                                                          await ChatTable()
                                                              .insert({
                                                        'community_id': 1,
                                                        'first_message_date':
                                                            supaSerialize<
                                                                    DateTime>(
                                                                functions
                                                                    .getCurrentUtcTime()),
                                                        'created_by':
                                                            currentUserUid,
                                                        'chat_type': 'sale',
                                                      });
                                                      await AddChatUsersCall
                                                          .call(
                                                        user2: getJsonField(
                                                          _model.saleData,
                                                          r'''$.created_by''',
                                                        ).toString(),
                                                        communityId: '1',
                                                        chatId:
                                                            _model.chatsale?.id,
                                                        anonKey:
                                                            FFDevEnvironmentValues()
                                                                .AnonKey,
                                                        token: currentJwtToken,
                                                      );

                                                      await MessagesTable()
                                                          .insert({
                                                        'chat_id':
                                                            _model.chatsale?.id,
                                                        'sender_id':
                                                            currentUserUid,
                                                        'e_message_type':
                                                            'image',
                                                        'is_read': false,
                                                        'file_url':
                                                            getJsonField(
                                                          _model.saleData,
                                                          r'''$.images[0]''',
                                                        ).toString(),
                                                        'community_id':
                                                            FFAppState()
                                                                .communityId,
                                                        'message': 'image',
                                                      });
                                                      await MessagesTable()
                                                          .insert({
                                                        'chat_id':
                                                            _model.chatsale?.id,
                                                        'sender_id':
                                                            currentUserUid,
                                                        'e_message_type':
                                                            'text',
                                                        'is_read': false,
                                                        'community_id':
                                                            FFAppState()
                                                                .communityId,
                                                        'message': getJsonField(
                                                          _model.saleData,
                                                          r'''$.title''',
                                                        ).toString(),
                                                      });
                                                      await MessagesTable()
                                                          .insert({
                                                        'chat_id':
                                                            _model.chatsale?.id,
                                                        'sender_id':
                                                            currentUserUid,
                                                        'e_message_type':
                                                            'text',
                                                        'is_read': false,
                                                        'community_id':
                                                            FFAppState()
                                                                .communityId,
                                                        'message': _model
                                                            .textController
                                                            .text,
                                                      });
                                                      await ChatTable().update(
                                                        data: {
                                                          'last_message_date':
                                                              supaSerialize<
                                                                      DateTime>(
                                                                  functions
                                                                      .getCurrentUtcTime()),
                                                          'last_message_user':
                                                              currentUserUid,
                                                          'last_message': _model
                                                              .textController
                                                              .text,
                                                        },
                                                        matchingRows: (rows) =>
                                                            rows.eqOrNull(
                                                          'id',
                                                          _model.chatsale?.id,
                                                        ),
                                                      );

                                                      context.pushNamed(
                                                        MessagePageWidget
                                                            .routeName,
                                                        queryParameters: {
                                                          'chatId':
                                                              serializeParam(
                                                            _model.chatsale?.id,
                                                            ParamType.String,
                                                          ),
                                                          'userId':
                                                              serializeParam(
                                                            getJsonField(
                                                              _model.saleData,
                                                              r'''$.created_by''',
                                                            ).toString(),
                                                            ParamType.String,
                                                          ),
                                                        }.withoutNulls,
                                                      );
                                                    }

                                                    safeSetState(() {});
                                                  },
                                                  text: 'Send',
                                                  options: FFButtonOptions(
                                                    height: 32.0,
                                                    padding:
                                                        EdgeInsetsDirectional
                                                            .fromSTEB(16.0, 0.0,
                                                                16.0, 0.0),
                                                    iconPadding:
                                                        EdgeInsetsDirectional
                                                            .fromSTEB(0.0, 0.0,
                                                                0.0, 0.0),
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .primary,
                                                    textStyle: FlutterFlowTheme
                                                            .of(context)
                                                        .titleSmall
                                                        .override(
                                                          font: GoogleFonts
                                                              .manrope(
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
                                                          fontSize: 14.0,
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
                                                        ),
                                                    elevation: 0.0,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            24.0),
                                                  ),
                                                ),
                                              ].divide(SizedBox(width: 10.0)),
                                            ),
                                          ]
                                              .divide(SizedBox(height: 12.0))
                                              .addToStart(
                                                  SizedBox(height: 12.0))
                                              .addToEnd(SizedBox(height: 12.0)),
                                        ),
                                      ),
                                    ),
                                  if (((String var1, String var2) {
                                        return var1 != var2;
                                      }(
                                          getJsonField(
                                            _model.saleData,
                                            r'''$.created_by''',
                                          ).toString(),
                                          currentUserUid)) ==
                                      false)
                                    Row(
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        Expanded(
                                          child: FFButtonWidget(
                                            onPressed: () async {
                                              await showModalBottomSheet(
                                                isScrollControlled: true,
                                                backgroundColor:
                                                    Colors.transparent,
                                                isDismissible: false,
                                                enableDrag: false,
                                                context: context,
                                                builder: (context) {
                                                  return GestureDetector(
                                                    onTap: () {
                                                      FocusScope.of(context)
                                                          .unfocus();
                                                      FocusManager
                                                          .instance.primaryFocus
                                                          ?.unfocus();
                                                    },
                                                    child: Padding(
                                                      padding: MediaQuery
                                                          .viewInsetsOf(
                                                              context),
                                                      child:
                                                          CompSoldDeleteWidget(
                                                        pageType: ((String
                                                                    var1) {
                                                                  return var1 ==
                                                                      "sold";
                                                                }(getJsonField(
                                                                  _model
                                                                      .saleData,
                                                                  r'''$.e_sale_type''',
                                                                ).toString())) ==
                                                                true
                                                            ? 'sell'
                                                            : 'sold',
                                                        saleId: widget!.saleId!,
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ).then((value) =>
                                                  safeSetState(() {}));
                                            },
                                            text: ((String var1) {
                                                      return var1 == "sold";
                                                    }(getJsonField(
                                                      _model.saleData,
                                                      r'''$.e_sale_type''',
                                                    ).toString())) ==
                                                    true
                                                ? 'Mark it for Sale'
                                                : 'Mark it as Sold',
                                            options: FFButtonOptions(
                                              height: 40.0,
                                              padding: EdgeInsetsDirectional
                                                  .fromSTEB(
                                                      16.0, 12.0, 16.0, 12.0),
                                              iconPadding: EdgeInsetsDirectional
                                                  .fromSTEB(0.0, 0.0, 0.0, 0.0),
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .primary,
                                              textStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .titleSmall
                                                      .override(
                                                        font:
                                                            GoogleFonts.manrope(
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
                                        Expanded(
                                          child: FFButtonWidget(
                                            onPressed: () async {
                                              await showModalBottomSheet(
                                                isScrollControlled: true,
                                                backgroundColor:
                                                    Colors.transparent,
                                                enableDrag: false,
                                                context: context,
                                                builder: (context) {
                                                  return GestureDetector(
                                                    onTap: () {
                                                      FocusScope.of(context)
                                                          .unfocus();
                                                      FocusManager
                                                          .instance.primaryFocus
                                                          ?.unfocus();
                                                    },
                                                    child: Padding(
                                                      padding: MediaQuery
                                                          .viewInsetsOf(
                                                              context),
                                                      child:
                                                          CompSoldDeleteWidget(
                                                        pageType: 'remove',
                                                        saleId: widget!.saleId!,
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ).then((value) =>
                                                  safeSetState(() {}));
                                            },
                                            text: 'Remove Product',
                                            options: FFButtonOptions(
                                              height: 40.0,
                                              padding: EdgeInsetsDirectional
                                                  .fromSTEB(
                                                      16.0, 12.0, 16.0, 12.0),
                                              iconPadding: EdgeInsetsDirectional
                                                  .fromSTEB(0.0, 0.0, 0.0, 0.0),
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .greyL2,
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
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .extraBlack,
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
                                      ].divide(SizedBox(width: 10.0)),
                                    ),
                                ]
                                    .divide(SizedBox(height: 16.0))
                                    .addToEnd(SizedBox(height: 12.0)),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                0.0, 8.0, 0.0, 0.0),
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: FlutterFlowTheme.of(context)
                                    .secondaryBackground,
                              ),
                              child: Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    20.0, 0.0, 20.0, 0.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          0.0, 12.0, 0.0, 12.0),
                                      child: Text(
                                        'Description',
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
                                    ),
                                    Column(
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        if ((getJsonField(
                                                  _model.saleData,
                                                  r'''$.description''',
                                                ).toString().length <
                                                100) ==
                                            true)
                                          Align(
                                            alignment: AlignmentDirectional(
                                                -1.0, -1.0),
                                            child: Text(
                                              getJsonField(
                                                _model.saleData,
                                                r'''$.description''',
                                              ).toString().maybeHandleOverflow(
                                                    maxChars: 99,
                                                    replacement: '…',
                                                  ),
                                              textAlign: TextAlign.justify,
                                              maxLines: 3,
                                              style: FlutterFlowTheme.of(
                                                      context)
                                                  .bodyMedium
                                                  .override(
                                                    font: GoogleFonts.manrope(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontStyle:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .bodyMedium
                                                              .fontStyle,
                                                    ),
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .greyL5,
                                                    fontSize: 16.0,
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
                                        if ((getJsonField(
                                                  _model.saleData,
                                                  r'''$.description''',
                                                ).toString().length >
                                                99) ==
                                            true)
                                          Align(
                                            alignment: AlignmentDirectional(
                                                -1.0, -1.0),
                                            child: Text(
                                              getJsonField(
                                                _model.saleData,
                                                r'''$.description''',
                                              ).toString(),
                                              textAlign: TextAlign.justify,
                                              maxLines: 3,
                                              style: FlutterFlowTheme.of(
                                                      context)
                                                  .bodyMedium
                                                  .override(
                                                    font: GoogleFonts.manrope(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontStyle:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .bodyMedium
                                                              .fontStyle,
                                                    ),
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .greyL5,
                                                    fontSize: 16.0,
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
                                        if ((getJsonField(
                                                  _model.saleData,
                                                  r'''$.description''',
                                                ).toString().length >
                                                99) ==
                                            true)
                                          Align(
                                            alignment:
                                                AlignmentDirectional(1.0, 0.0),
                                            child: InkWell(
                                              splashColor:
                                                  FlutterFlowTheme.of(context)
                                                      .primary
                                                      .withAlpha(0x14),
                                              focusColor: Colors.transparent,
                                              hoverColor: Colors.transparent,
                                              highlightColor:
                                                  Colors.transparent,
                                              onTap: () async {
                                                if (_model.readMore == true) {
                                                  _model.readMore = false;
                                                  safeSetState(() {});
                                                } else {
                                                  _model.readMore = true;
                                                  safeSetState(() {});
                                                }
                                              },
                                              child: Text(
                                                _model.readMore == true
                                                    ? 'Read More'
                                                    : 'Read Less',
                                                style: FlutterFlowTheme.of(
                                                        context)
                                                    .bodyMedium
                                                    .override(
                                                      font: GoogleFonts.manrope(
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyMedium
                                                                .fontStyle,
                                                      ),
                                                      color:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .greyL4,
                                                      letterSpacing: 0.0,
                                                      fontWeight:
                                                          FontWeight.w600,
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
                                      ].divide(SizedBox(height: 4.0)),
                                    ),
                                  ].addToEnd(SizedBox(height: 12.0)),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                0.0, 8.0, 0.0, 0.0),
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: FlutterFlowTheme.of(context)
                                    .secondaryBackground,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        20.0, 0.0, 20.0, 0.0),
                                    child: Text(
                                      'Seller information',
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
                                  ),
                                  Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        20.0, 0.0, 20.0, 0.0),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          mainAxisSize: MainAxisSize.max,
                                          children: [
                                            AppNetworkImage(
                                              url: getJsonField(
                                                _model.saleData,
                                                r'''$.seller_profile.profile_picture''',
                                              ).toString(),
                                              width: 32.0,
                                              height: 32.0,
                                              fit: BoxFit.cover,
                                              isAvatar: true,
                                              semanticLabel:
                                                  'Profile photo of ${getJsonField(
                                                _model.saleData,
                                                r'''$.seller_profile.name''',
                                              ).toString()}',
                                            ),
                                            Column(
                                              mainAxisSize: MainAxisSize.max,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  getJsonField(
                                                    _model.saleData,
                                                    r'''$.seller_profile.name''',
                                                  ).toString(),
                                                  style: FlutterFlowTheme.of(
                                                          context)
                                                      .bodyMedium
                                                      .override(
                                                        font:
                                                            GoogleFonts.manrope(
                                                          fontWeight:
                                                              FontWeight.w600,
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
                                                        fontSize: 16.0,
                                                        letterSpacing: 0.0,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyMedium
                                                                .fontStyle,
                                                        lineHeight: 1.4,
                                                      ),
                                                ),
                                                Row(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  children: [
                                                    Text(
                                                      getJsonField(
                                                        _model.saleData,
                                                        r'''$.seller_profile.city''',
                                                      ).toString(),
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
                                                                    .greyL4,
                                                                fontSize: 12.0,
                                                                letterSpacing:
                                                                    0.0,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                fontStyle: FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .fontStyle,
                                                                lineHeight: 1.4,
                                                              ),
                                                    ),
                                                    Container(
                                                      width: 2.0,
                                                      height: 2.0,
                                                      decoration: BoxDecoration(
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .greyL4,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(24.0),
                                                      ),
                                                    ),
                                                    Text(
                                                      '${getJsonField(
                                                        _model.saleData,
                                                        r'''$.distance_km''',
                                                      ).toString()} km',
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
                                                                    .greyL4,
                                                                fontSize: 12.0,
                                                                letterSpacing:
                                                                    0.0,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                fontStyle: FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .fontStyle,
                                                                lineHeight: 1.4,
                                                              ),
                                                    ),
                                                  ].divide(
                                                      SizedBox(width: 4.0)),
                                                ),
                                              ],
                                            ),
                                          ].divide(SizedBox(width: 8.0)),
                                        ),
                                        Row(
                                          mainAxisSize: MainAxisSize.max,
                                          children: [
                                            if (((String var1, String var2) {
                                                  return var1 != var2;
                                                }(
                                                    getJsonField(
                                                      _model.saleData,
                                                      r'''$.created_by''',
                                                    ).toString(),
                                                    currentUserUid)) ==
                                                true)
                                              InkWell(
                                                splashColor:
                                                    FlutterFlowTheme.of(context)
                                                        .primary
                                                        .withAlpha(0x14),
                                                focusColor: Colors.transparent,
                                                hoverColor: Colors.transparent,
                                                highlightColor:
                                                    Colors.transparent,
                                                onTap: () async {
                                                  await AddFollowCall.call(
                                                    pFollowerid: currentUserUid,
                                                    pFollowingid: getJsonField(
                                                      _model.saleData,
                                                      r'''$.created_by''',
                                                    ).toString(),
                                                    pCommunityid: FFAppState()
                                                        .communityId,
                                                    token: currentJwtToken,
                                                  );

                                                  safeSetState(() => _model
                                                      .requestCompleter = null);
                                                  await _model
                                                      .waitForRequestCompleted();
                                                },
                                                child: Container(
                                                  width: 100.0,
                                                  height: 30.0,
                                                  decoration: BoxDecoration(),
                                                  child: FutureBuilder<
                                                      List<FollowsRow>>(
                                                    future: (_model
                                                                .requestCompleter ??=
                                                            Completer<
                                                                List<
                                                                    FollowsRow>>()
                                                              ..complete(
                                                                  FollowsTable()
                                                                      .querySingleRow(
                                                                queryFn: (q) => q
                                                                    .eqOrNull(
                                                                      'follower_id',
                                                                      currentUserUid,
                                                                    )
                                                                    .eqOrNull(
                                                                      'following_id',
                                                                      getJsonField(
                                                                        _model
                                                                            .saleData,
                                                                        r'''$.created_by''',
                                                                      ).toString(),
                                                                    ),
                                                              )))
                                                        .future,
                                                    builder:
                                                        (context, snapshot) {
                                                      // Customize what your widget looks like when it's loading.
                                                      if (!snapshot.hasData) {
                                                        return CompLoadingWidget(
                                                          name: 'followPost',
                                                        );
                                                      }
                                                      List<FollowsRow>
                                                          stackFollowsRowList =
                                                          snapshot.data!;

                                                      final stackFollowsRow =
                                                          stackFollowsRowList
                                                                  .isNotEmpty
                                                              ? stackFollowsRowList
                                                                  .first
                                                              : null;

                                                      return Stack(
                                                        alignment:
                                                            AlignmentDirectional(
                                                                0.0, 0.0),
                                                        children: [
                                                          if (stackFollowsRow
                                                                      ?.id ==
                                                                  null ||
                                                              stackFollowsRow
                                                                      ?.id ==
                                                                  '')
                                                            Row(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .max,
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                Icon(
                                                                  Icons.add,
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .primaryD3,
                                                                  size: 14.0,
                                                                ),
                                                                Text(
                                                                  'Follow',
                                                                  style: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMedium
                                                                      .override(
                                                                        font: GoogleFonts
                                                                            .manrope(
                                                                          fontWeight:
                                                                              FontWeight.w600,
                                                                          fontStyle: FlutterFlowTheme.of(context)
                                                                              .bodyMedium
                                                                              .fontStyle,
                                                                        ),
                                                                        color: FlutterFlowTheme.of(context)
                                                                            .primaryD3,
                                                                        fontSize:
                                                                            12.0,
                                                                        letterSpacing:
                                                                            0.0,
                                                                        fontWeight:
                                                                            FontWeight.w600,
                                                                        fontStyle: FlutterFlowTheme.of(context)
                                                                            .bodyMedium
                                                                            .fontStyle,
                                                                        lineHeight:
                                                                            1.4,
                                                                      ),
                                                                ),
                                                              ].divide(SizedBox(
                                                                  width: 6.0)),
                                                            ),
                                                          if (stackFollowsRow
                                                                      ?.id !=
                                                                  null &&
                                                              stackFollowsRow
                                                                      ?.id !=
                                                                  '')
                                                            Row(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .max,
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                ClipRRect(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              8.0),
                                                                  child: Image
                                                                      .asset(
                                                                    'assets/images/check.png',
                                                                    width: 12.0,
                                                                    height:
                                                                        12.0,
                                                                    fit: BoxFit
                                                                        .cover,
                                                                  ),
                                                                ),
                                                                Text(
                                                                  'Following',
                                                                  style: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMedium
                                                                      .override(
                                                                        font: GoogleFonts
                                                                            .manrope(
                                                                          fontWeight:
                                                                              FontWeight.w600,
                                                                          fontStyle: FlutterFlowTheme.of(context)
                                                                              .bodyMedium
                                                                              .fontStyle,
                                                                        ),
                                                                        color: FlutterFlowTheme.of(context)
                                                                            .greyL4,
                                                                        letterSpacing:
                                                                            0.0,
                                                                        fontWeight:
                                                                            FontWeight.w600,
                                                                        fontStyle: FlutterFlowTheme.of(context)
                                                                            .bodyMedium
                                                                            .fontStyle,
                                                                        lineHeight:
                                                                            1.4,
                                                                      ),
                                                                ),
                                                              ].divide(SizedBox(
                                                                  width: 6.0)),
                                                            ),
                                                        ],
                                                      );
                                                    },
                                                  ),
                                                ),
                                              ),
                                            if (false)
                                              Container(
                                                width: 30.0,
                                                height: 30.0,
                                                decoration: BoxDecoration(),
                                                alignment: AlignmentDirectional(
                                                    0.0, 0.0),
                                                child: Transform.rotate(
                                                  angle: 90.0 * (math.pi / 180),
                                                  child: Icon(
                                                    Icons.keyboard_control,
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .primaryText,
                                                    size: 16.0,
                                                  ),
                                                ),
                                              ),
                                          ].divide(SizedBox(width: 12.0)),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width: double.infinity,
                                    height: 140.0,
                                    decoration: BoxDecoration(
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryBackground,
                                    ),
                                    child: Container(
                                      width: double.infinity,
                                      height: 140.0,
                                      child: custom_widgets.CustomGoogleMaps(
                                        width: double.infinity,
                                        height: 140.0,
                                        latLng:
                                            functions.returnlatitudeLongitude(
                                                _model.adminLat!,
                                                _model.adminLng!),
                                      ),
                                    ),
                                  ),
                                ]
                                    .divide(SizedBox(height: 12.0))
                                    .addToStart(SizedBox(height: 12.0))
                                    .addToEnd(SizedBox(height: 12.0)),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                0.0, 8.0, 0.0, 0.0),
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: FlutterFlowTheme.of(context)
                                    .secondaryBackground,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        20.0, 12.0, 0.0, 12.0),
                                    child: Text(
                                      'More Listings',
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
                                  ),
                                  if (_model.sales != null)
                                    Builder(
                                      builder: (context) {
                                        final salesData =
                                            _model.sales?.toList() ?? [];

                                        return ListView.builder(
                                          padding: EdgeInsets.zero,
                                          primary: false,
                                          shrinkWrap: true,
                                          scrollDirection: Axis.vertical,
                                          itemCount: salesData.length,
                                          itemBuilder:
                                              (context, salesDataIndex) {
                                            final salesDataItem =
                                                salesData[salesDataIndex];
                                            // One merged semantics node so the
                                            // card announces as a single button.
                                            return MergeSemantics(
                                                child: Semantics(
                                                    button: true,
                                                    child: InkWell(
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
                                                        context.pushNamed(
                                                          SaleDetailsWidget
                                                              .routeName,
                                                          queryParameters: {
                                                            'saleId':
                                                                serializeParam(
                                                              getJsonField(
                                                                salesDataItem,
                                                                r'''$.id''',
                                                              ).toString(),
                                                              ParamType.String,
                                                            ),
                                                          }.withoutNulls,
                                                        );
                                                      },
                                                      child: Column(
                                                        mainAxisSize:
                                                            MainAxisSize.max,
                                                        children: [
                                                          Padding(
                                                            padding:
                                                                EdgeInsetsDirectional
                                                                    .fromSTEB(
                                                                        20.0,
                                                                        20.0,
                                                                        20.0,
                                                                        20.0),
                                                            child: Container(
                                                              width: double
                                                                  .infinity,
                                                              // Min-height, not a hard 80,
                                                              // so the row grows with the
                                                              // system text scale.
                                                              constraints:
                                                                  const BoxConstraints(
                                                                      minHeight:
                                                                          80.0),
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .secondaryBackground,
                                                              ),
                                                              child: Row(
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .max,
                                                                children: [
                                                                  Stack(
                                                                    alignment:
                                                                        AlignmentDirectional(
                                                                            -1.0,
                                                                            1.0),
                                                                    children: [
                                                                      if (((String
                                                                              var1) {
                                                                            return var1 !=
                                                                                "null";
                                                                          }(getJsonField(
                                                                            salesDataItem,
                                                                            r'''$.image''',
                                                                          ).toString())) ==
                                                                          true)
                                                                        AppNetworkImage(
                                                                          url:
                                                                              getJsonField(
                                                                            salesDataItem,
                                                                            r'''$.image''',
                                                                          ).toString(),
                                                                          width:
                                                                              120.0,
                                                                          height:
                                                                              80.0,
                                                                          fit: BoxFit
                                                                              .cover,
                                                                          borderRadius:
                                                                              BorderRadius.circular(2.0),
                                                                        ),
                                                                      if (((String
                                                                              var1) {
                                                                            return var1 !=
                                                                                "null";
                                                                          }(getJsonField(
                                                                            salesDataItem,
                                                                            r'''$.image''',
                                                                          ).toString())) ==
                                                                          false)
                                                                        Container(
                                                                          width:
                                                                              120.0,
                                                                          height:
                                                                              80.0,
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            color:
                                                                                FlutterFlowTheme.of(context).secondaryBackground,
                                                                          ),
                                                                        ),
                                                                    ],
                                                                  ),
                                                                  Expanded(
                                                                    child:
                                                                        Column(
                                                                      mainAxisSize:
                                                                          MainAxisSize
                                                                              .max,
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .spaceBetween,
                                                                      children: [
                                                                        Row(
                                                                          mainAxisSize:
                                                                              MainAxisSize.max,
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.spaceBetween,
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.start,
                                                                          children: [
                                                                            Expanded(
                                                                              child: Column(
                                                                                mainAxisSize: MainAxisSize.max,
                                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                                children: [
                                                                                  Text(
                                                                                    getJsonField(
                                                                                      salesDataItem,
                                                                                      r'''$.title''',
                                                                                    ).toString(),
                                                                                    maxLines: 2,
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
                                                                                ],
                                                                              ),
                                                                            ),
                                                                            if (false)
                                                                              Icon(
                                                                                Icons.bookmark_border,
                                                                                color: FlutterFlowTheme.of(context).extraBlack,
                                                                                size: 24.0,
                                                                              ),
                                                                          ],
                                                                        ),
                                                                        Row(
                                                                          mainAxisSize:
                                                                              MainAxisSize.max,
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.spaceBetween,
                                                                          children: [
                                                                            Row(
                                                                              mainAxisSize: MainAxisSize.max,
                                                                              children: [
                                                                                Text(
                                                                                  valueOrDefault<String>(
                                                                                    functions.returnRelativeTIme(getJsonField(
                                                                                      salesDataItem,
                                                                                      r'''$.created_at''',
                                                                                    ).toString()),
                                                                                    'a moment ago',
                                                                                  ),
                                                                                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                        font: GoogleFonts.manrope(
                                                                                          fontWeight: FontWeight.w500,
                                                                                          fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                        ),
                                                                                        color: FlutterFlowTheme.of(context).greyL4,
                                                                                        fontSize: 12.0,
                                                                                        letterSpacing: 0.0,
                                                                                        fontWeight: FontWeight.w500,
                                                                                        fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                        lineHeight: 1.4,
                                                                                      ),
                                                                                ),
                                                                                Container(
                                                                                  width: 2.0,
                                                                                  height: 2.0,
                                                                                  decoration: BoxDecoration(
                                                                                    color: FlutterFlowTheme.of(context).greyL4,
                                                                                    borderRadius: BorderRadius.circular(24.0),
                                                                                  ),
                                                                                ),
                                                                                Text(
                                                                                  '${getJsonField(
                                                                                    salesDataItem,
                                                                                    r'''$.distance_km''',
                                                                                  ).toString()} kms',
                                                                                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                        font: GoogleFonts.manrope(
                                                                                          fontWeight: FontWeight.w500,
                                                                                          fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                        ),
                                                                                        color: FlutterFlowTheme.of(context).greyL4,
                                                                                        fontSize: 12.0,
                                                                                        letterSpacing: 0.0,
                                                                                        fontWeight: FontWeight.w500,
                                                                                        fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                        lineHeight: 1.4,
                                                                                      ),
                                                                                ),
                                                                                Container(
                                                                                  width: 2.0,
                                                                                  height: 2.0,
                                                                                  decoration: BoxDecoration(
                                                                                    color: FlutterFlowTheme.of(context).greyL4,
                                                                                    borderRadius: BorderRadius.circular(24.0),
                                                                                  ),
                                                                                ),
                                                                                Text(
                                                                                  getJsonField(
                                                                                    salesDataItem,
                                                                                    r'''$.city''',
                                                                                  ).toString(),
                                                                                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                        font: GoogleFonts.manrope(
                                                                                          fontWeight: FontWeight.w500,
                                                                                          fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                        ),
                                                                                        color: FlutterFlowTheme.of(context).greyL4,
                                                                                        fontSize: 12.0,
                                                                                        letterSpacing: 0.0,
                                                                                        fontWeight: FontWeight.w500,
                                                                                        fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                        lineHeight: 1.4,
                                                                                      ),
                                                                                ),
                                                                              ].divide(SizedBox(width: 4.0)),
                                                                            ),
                                                                            if (((String var1) {
                                                                                  return var1 != "null";
                                                                                }(getJsonField(
                                                                                  salesDataItem,
                                                                                  r'''$.price''',
                                                                                ).toString())) ==
                                                                                true)
                                                                              Text(
                                                                                '$kCurrencySymbol${getJsonField(
                                                                                  salesDataItem,
                                                                                  r'''$.price''',
                                                                                ).toString()}',
                                                                                style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                      font: GoogleFonts.manrope(
                                                                                        fontWeight: FontWeight.w600,
                                                                                        fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                      ),
                                                                                      color: FlutterFlowTheme.of(context).extraBlack,
                                                                                      fontSize: 12.0,
                                                                                      letterSpacing: 0.0,
                                                                                      fontWeight: FontWeight.w600,
                                                                                      fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                      lineHeight: 1.4,
                                                                                    ),
                                                                              ),
                                                                          ],
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ].divide(SizedBox(
                                                                    width:
                                                                        8.0)),
                                                              ),
                                                            ),
                                                          ),
                                                          Divider(
                                                            height: 0.0,
                                                            thickness: 2.0,
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .alternate,
                                                          ),
                                                        ],
                                                      ),
                                                    )));
                                          },
                                        );
                                      },
                                    ),
                                  if (valueOrDefault<bool>(
                                    _model.sales == null,
                                    false,
                                  ))
                                    Container(
                                      width: double.infinity,
                                      height: 280.0,
                                      decoration: BoxDecoration(),
                                      child: Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            16.0, 0.0, 16.0, 0.0),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              'No more listings available',
                                              style: FlutterFlowTheme.of(
                                                      context)
                                                  .bodyMedium
                                                  .override(
                                                    font: GoogleFonts.manrope(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontStyle:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .bodyMedium
                                                              .fontStyle,
                                                    ),
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .extraBlack,
                                                    fontSize: 20.0,
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
                                            Text(
                                              'Items for sale or giveaway will appear here once users start posting.',
                                              textAlign: TextAlign.center,
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
                                                        .greyL5,
                                                    fontSize: 14.0,
                                                    letterSpacing: 0.0,
                                                    fontWeight: FontWeight.w500,
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
                                      ),
                                    ),
                                ],
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
  }
}
