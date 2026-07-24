import '/auth/supabase_auth/auth_util.dart';
import '/app_constants.dart';
import '/backend/api_requests/api_calls.dart';
import '/components/app_icon_button.dart';
import '/components/app_network_image.dart';
import '/components/comp_no_data_found_widget.dart';
import '/components/empty_state.dart';
import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/custom_code/widgets/index.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/pages/components/comp_navbar/comp_navbar_widget.dart';
import '/pages/sale/comp_category_filter/comp_category_filter_widget.dart';
import '/pages/sale/comp_create_listing/comp_create_listing_widget.dart';
import '/pages/sale/comp_kms_filter/comp_kms_filter_widget.dart';
import '/pages/sale/comp_sales_sort/comp_sales_sort_widget.dart';
import 'dart:math';
import 'dart:ui';
import '/custom_code/actions/index.dart' as actions;
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'sale_model.dart';
export 'sale_model.dart';

class SaleWidget extends StatefulWidget {
  const SaleWidget({
    super.key,
    required this.pageType,
  });

  final String? pageType;

  static String routeName = 'Sale';
  static String routePath = 'sale';

  @override
  State<SaleWidget> createState() => _SaleWidgetState();
}

class _SaleWidgetState extends State<SaleWidget> with TickerProviderStateMixin {
  late SaleModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  final animationsMap = <String, AnimationInfo>{};

  /// True when the last marketplace fetch failed, so the screen shows a real
  /// error state with a retry instead of "no listings available".
  bool _loadFailed = false;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => SaleModel());

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      if (widget!.pageType == 'yours') {
        _model.switchOption = 'yours';
        safeSetState(() {});
      }
      FFAppState().SalesTypeFilter = 'Fixed';
      FFAppState().SalesKmFilter = 10;
      FFAppState().SalesFilter = 'All categories';
      FFAppState().SalesSort = 'Newest';
      safeSetState(() {});
      // Guarded: getSaleHomePage throws on a non-200 and would otherwise leave
      // the page stuck on its skeleton forever with no way back.
      try {
        _model.customActionOutput = await actions.getSaleHomePage(
          FFDevEnvironmentValues().AnonKey,
          currentJwtToken!,
          currentUserUid,
          FFAppState().SalesFilter,
          FFAppState().SalesTypeFilter,
          FFAppState().SalesKmFilter,
          FFAppState().SalesSort,
          FFAppState().communityId,
        );
        FFAppState().SalesHomePageData =
            _model.customActionOutput!.toList().cast<dynamic>();
        safeSetState(() {});
        _model.salesDataOnload = await GetSalesDataCall.call(
          pUserid: currentUserUid,
          pFilter: 'all',
          token: currentJwtToken,
        );

        _model.salesListing =
            (_model.salesDataOnload?.jsonBody ?? '').toList().cast<dynamic>();
        _loadFailed = false;
      } catch (_) {
        _loadFailed = true;
      }
      _model.show = true;
      safeSetState(() {});
    });

    animationsMap.addAll({
      'containerOnPageLoadAnimation1': AnimationInfo(
        loop: true,
        trigger: AnimationTrigger.onPageLoad,
        effectsBuilder: () => [
          ShimmerEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            color: FlutterFlowTheme.of(context).shimmerHighlight,
            angle: 0.524,
          ),
        ],
      ),
      'containerOnPageLoadAnimation2': AnimationInfo(
        loop: true,
        trigger: AnimationTrigger.onPageLoad,
        effectsBuilder: () => [
          ShimmerEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            color: FlutterFlowTheme.of(context).shimmerHighlight,
            angle: 0.524,
          ),
        ],
      ),
      'containerOnPageLoadAnimation3': AnimationInfo(
        loop: true,
        trigger: AnimationTrigger.onPageLoad,
        effectsBuilder: () => [
          ShimmerEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            color: FlutterFlowTheme.of(context).shimmerHighlight,
            angle: 0.524,
          ),
        ],
      ),
    });
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  /// Re-fetches whichever marketplace tab is on screen, honouring the
  /// filters the user already picked. Used by pull-to-refresh.
  /// `getSaleHomePage` throws on a non-200, so every path is guarded: an
  /// uncaught throw inside `onRefresh` would leave the spinner stuck.
  Future<void> _refreshSale() async {
    try {
      if (_model.switchOption == 'yours') {
        final String pFilter = _model.opt == 'sell' ? 'selling' : _model.opt;
        final ApiCallResponse listings = await GetSalesDataCall.call(
          pUserid: currentUserUid,
          pFilter: pFilter,
          token: currentJwtToken,
        );
        if (!listings.succeeded) {
          throw Exception('GetSalesData failed');
        }
        _model.salesListing =
            (listings.jsonBody ?? '').toList().cast<dynamic>();
      } else {
        final List<dynamic> homeData = await actions.getSaleHomePage(
          FFDevEnvironmentValues().AnonKey,
          currentJwtToken!,
          currentUserUid,
          FFAppState().SalesFilter,
          FFAppState().SalesTypeFilter,
          FFAppState().SalesKmFilter,
          FFAppState().SalesSort,
          FFAppState().communityId,
        );
        FFAppState().SalesHomePageData = homeData.toList().cast<dynamic>();
      }
      _loadFailed = false;
    } catch (_) {
      _loadFailed = true;
    }
    _model.show = true;
    safeSetState(() {});
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
            decoration: BoxDecoration(
              color: FlutterFlowTheme.of(context).pageBack,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color:
                              FlutterFlowTheme.of(context).secondaryBackground,
                        ),
                        child: Padding(
                          // 9 (not 12) because the Messages button's 44dp tap
                          // target is now the tallest child: 44 + 9 + 9 ==
                          // 38 + 12 + 12, so the bar stays 62dp and every child
                          // keeps its exact y position.
                          padding: EdgeInsetsDirectional.fromSTEB(
                              0.0, 9.0, 0.0, 9.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              InkWell(
                                splashColor: FlutterFlowTheme.of(context)
                                    .primary
                                    .withAlpha(0x14),
                                focusColor: Colors.transparent,
                                hoverColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                onTap: () async {
                                  HapticFeedback.lightImpact();
                                  context.pushNamed(ProfileWidget.routeName);
                                },
                                // Shared top-bar avatar spec - keep in sync with
                                // home/community/notification. Was a plain
                                // ClipRRect with no gradient ring.
                                child: GradientAvatarRing(
                                  diameter: 38.0,
                                  ringWidth: 2.0,
                                  child: AppNetworkImage(
                                    url: FFAppState().AsProfilePicture,
                                    fit: BoxFit.cover,
                                    fallbackIcon: Icons.person_rounded,
                                    semanticLabel: 'Your profile photo',
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
                                          'listing',
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
                                      borderRadius: BorderRadius.circular(
                                          FlutterFlowTheme.of(context)
                                              .designToken
                                              .radius
                                              .md),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        Icon(
                                          Icons.search,
                                          color: FlutterFlowTheme.of(context)
                                              .greyL4,
                                          size: 20.0,
                                        ),
                                        Text(
                                          'Search',
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
                                                        .greyL4,
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
                                          .divide(SizedBox(width: 12.0))
                                          .addToStart(SizedBox(width: 12.0))
                                          .addToEnd(SizedBox(width: 12.0)),
                                    ),
                                  ),
                                ),
                              ),
                              AppIconButton(
                                semanticLabel: 'Messages',
                                tooltip: 'Messages',
                                onTap: () async {
                                  context.pushNamed(
                                    ChatWidget.routeName,
                                    queryParameters: {
                                      'selectMessage': serializeParam(
                                        false,
                                        ParamType.bool,
                                      ),
                                    }.withoutNulls,
                                  );
                                },
                                // The 34dp grey disc is unchanged; AppIconButton
                                // only grows the invisible hit area out to 44dp.
                                iconWidget: Container(
                                  width: 34.0,
                                  height: 34.0,
                                  decoration: BoxDecoration(
                                    color: FlutterFlowTheme.of(context).greyL2,
                                    shape: BoxShape.circle,
                                  ),
                                  alignment: AlignmentDirectional(0.0, 0.0),
                                  child: Stack(
                                    alignment: AlignmentDirectional(0.0, 0.0),
                                    children: [
                                      Icon(
                                        Icons.message_rounded,
                                        color: FlutterFlowTheme.of(context)
                                            .primaryText,
                                        size: 18.0,
                                      ),
                                      if (('${getJsonField(
                                                FFAppState().matchedUsers,
                                                r'''$[0].total_unread_message_count''',
                                              ).toString()}' !=
                                              '0') &&
                                          ('${getJsonField(
                                                FFAppState().matchedUsers,
                                                r'''$''',
                                              ).toString()}' !=
                                              '[]'))
                                        Align(
                                          alignment:
                                              AlignmentDirectional(1.0, -1.0),
                                          child: Padding(
                                            padding:
                                                EdgeInsetsDirectional.fromSTEB(
                                                    0.0, 5.0, 5.0, 0.0),
                                            child: Container(
                                              width: 10.0,
                                              height: 10.0,
                                              decoration: BoxDecoration(
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .greyL2,
                                                borderRadius:
                                                    BorderRadius.circular(24.0),
                                              ),
                                              alignment: AlignmentDirectional(
                                                  0.0, 0.0),
                                              child: Container(
                                                width: 5.0,
                                                height: 5.0,
                                                decoration: BoxDecoration(
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .primary,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          24.0),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ]
                                .divide(SizedBox(width: 10.0))
                                .addToStart(SizedBox(width: 20.0))
                                .addToEnd(SizedBox(width: 20.0)),
                          ),
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Expanded(
                            child: InkWell(
                              splashColor: FlutterFlowTheme.of(context)
                                  .primary
                                  .withAlpha(0x14),
                              focusColor: Colors.transparent,
                              hoverColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              onTap: () async {
                                HapticFeedback.lightImpact();
                                _model.switchOption = 'all';
                                safeSetState(() {});
                              },
                              child: AnimatedContainer(
                                duration: Duration(milliseconds: 300),
                                curve: Curves.easeOut,
                                height: 48.0,
                                decoration: BoxDecoration(
                                  color: _model.switchTouch == 'all'
                                      ? FlutterFlowTheme.of(context)
                                          .primary
                                          .withAlpha(0x13)
                                      : FlutterFlowTheme.of(context).white,
                                ),
                                child: SingleChildScrollView(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      Container(
                                        height: 46.0,
                                        decoration: BoxDecoration(),
                                        child: Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  0.0, 12.0, 0.0, 10.0),
                                          child: Stack(
                                            children: [
                                              if (_model.switchOption != 'all')
                                                Text(
                                                  'All',
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
                                                                .greyL4,
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
                                              if (_model.switchOption == 'all')
                                                Text(
                                                  'All',
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
                                                                .primary,
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
                                            ],
                                          ),
                                        ),
                                      ),
                                      if (_model.switchOption == 'all')
                                        Container(
                                          width: double.infinity,
                                          height: 2.0,
                                          decoration: BoxDecoration(
                                            color: FlutterFlowTheme.of(context)
                                                .primary,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
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
                                HapticFeedback.lightImpact();
                                _model.switchOption = 'yours';
                                safeSetState(() {});
                              },
                              child: AnimatedContainer(
                                duration: Duration(milliseconds: 300),
                                curve: Curves.easeOut,
                                height: 48.0,
                                decoration: BoxDecoration(
                                  color: _model.switchTouch == 'yours'
                                      ? FlutterFlowTheme.of(context)
                                          .primary
                                          .withAlpha(0x13)
                                      : FlutterFlowTheme.of(context)
                                          .secondaryBackground,
                                ),
                                child: SingleChildScrollView(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Container(
                                        height: 46.0,
                                        decoration: BoxDecoration(),
                                        child: Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  0.0, 12.0, 0.0, 10.0),
                                          child: Stack(
                                            children: [
                                              if (_model.switchOption !=
                                                  'yours')
                                                Text(
                                                  'Yours',
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
                                                                .greyL4,
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
                                              if (_model.switchOption ==
                                                  'yours')
                                                Text(
                                                  'Yours',
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
                                                                .primary,
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
                                            ],
                                          ),
                                        ),
                                      ),
                                      if (_model.switchOption == 'yours')
                                        Container(
                                          width: double.infinity,
                                          height: 2.0,
                                          decoration: BoxDecoration(
                                            color: FlutterFlowTheme.of(context)
                                                .primary,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (_loadFailed)
                        Expanded(
                          child: EmptyState(
                            icon: Icons.wifi_off_rounded,
                            title: 'Couldn\'t load listings',
                            body:
                                'Check your connection and try again — your filters are still set.',
                            actionLabel: 'Try again',
                            onAction: () => _refreshSale(),
                          ),
                        ),
                      if ((_model.switchOption == 'all') && !_loadFailed)
                        Expanded(
                          child: Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                0.0, 8.0, 0.0, 0.0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: FlutterFlowTheme.of(context).white,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        0.0, 4.0, 0.0, 0.0),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color:
                                            FlutterFlowTheme.of(context).white,
                                      ),
                                      child: Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            0.0, 8.0, 0.0, 8.0),
                                        child: SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                          child: Row(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
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
                                                  await showModalBottomSheet(
                                                    isScrollControlled: true,
                                                    backgroundColor:
                                                        Colors.transparent,
                                                    context: context,
                                                    builder: (context) {
                                                      return GestureDetector(
                                                        onTap: () {
                                                          FocusScope.of(context)
                                                              .unfocus();
                                                          FocusManager.instance
                                                              .primaryFocus
                                                              ?.unfocus();
                                                        },
                                                        child: Padding(
                                                          padding: MediaQuery
                                                              .viewInsetsOf(
                                                                  context),
                                                          child:
                                                              CompCreateListingWidget(),
                                                        ),
                                                      );
                                                    },
                                                  ).then((value) =>
                                                      safeSetState(() {}));
                                                },
                                                child: Container(
                                                  height: 36.0,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            24.0),
                                                    border: Border.all(
                                                      color:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .greyL4,
                                                    ),
                                                  ),
                                                  child: Align(
                                                    alignment:
                                                        AlignmentDirectional(
                                                            0.0, 0.0),
                                                    child: Padding(
                                                      padding:
                                                          EdgeInsetsDirectional
                                                              .fromSTEB(
                                                                  24.0,
                                                                  0.0,
                                                                  24.0,
                                                                  0.0),
                                                      child: Text(
                                                        'Create Listing',
                                                        style:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyMedium
                                                                .override(
                                                                  font: GoogleFonts
                                                                      .manrope(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                    fontStyle: FlutterFlowTheme.of(
                                                                            context)
                                                                        .bodyMedium
                                                                        .fontStyle,
                                                                  ),
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .greyL4,
                                                                  letterSpacing:
                                                                      0.0,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  fontStyle: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMedium
                                                                      .fontStyle,
                                                                  lineHeight:
                                                                      1.4,
                                                                ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
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
                                                  await showModalBottomSheet(
                                                    isScrollControlled: true,
                                                    backgroundColor:
                                                        Colors.transparent,
                                                    useSafeArea: true,
                                                    context: context,
                                                    builder: (context) {
                                                      return GestureDetector(
                                                        onTap: () {
                                                          FocusScope.of(context)
                                                              .unfocus();
                                                          FocusManager.instance
                                                              .primaryFocus
                                                              ?.unfocus();
                                                        },
                                                        child: Padding(
                                                          padding: MediaQuery
                                                              .viewInsetsOf(
                                                                  context),
                                                          child:
                                                              CompCategoryFilterWidget(
                                                            pageType: 'sale',
                                                            searhText: '',
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  ).then((value) =>
                                                      safeSetState(() {}));
                                                },
                                                child: Container(
                                                  height: 36.0,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            24.0),
                                                    border: Border.all(
                                                      color:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .greyL4,
                                                    ),
                                                  ),
                                                  child: Padding(
                                                    padding:
                                                        EdgeInsetsDirectional
                                                            .fromSTEB(24.0, 0.0,
                                                                24.0, 0.0),
                                                    child: Row(
                                                      mainAxisSize:
                                                          MainAxisSize.max,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Align(
                                                          alignment:
                                                              AlignmentDirectional(
                                                                  0.0, 0.0),
                                                          child: Text(
                                                            FFAppState()
                                                                .SalesFilter,
                                                            style: FlutterFlowTheme
                                                                    .of(context)
                                                                .bodyMedium
                                                                .override(
                                                                  font: GoogleFonts
                                                                      .manrope(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                    fontStyle: FlutterFlowTheme.of(
                                                                            context)
                                                                        .bodyMedium
                                                                        .fontStyle,
                                                                  ),
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .greyL4,
                                                                  letterSpacing:
                                                                      0.0,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  fontStyle: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMedium
                                                                      .fontStyle,
                                                                  lineHeight:
                                                                      1.0,
                                                                ),
                                                          ),
                                                        ),
                                                        Icon(
                                                          Icons
                                                              .arrow_drop_down_sharp,
                                                          color: _model.opt ==
                                                                  'categories'
                                                              ? FlutterFlowTheme
                                                                      .of(
                                                                          context)
                                                                  .primary
                                                              : FlutterFlowTheme
                                                                      .of(context)
                                                                  .greyL4,
                                                          size: 20.0,
                                                        ),
                                                      ].divide(
                                                          SizedBox(width: 6.0)),
                                                    ),
                                                  ),
                                                ),
                                              ),
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
                                                  HapticFeedback.lightImpact();
                                                  if (FFAppState()
                                                          .SalesTypeFilter ==
                                                      'Free') {
                                                    FFAppState()
                                                            .SalesTypeFilter =
                                                        'Fixed';
                                                    safeSetState(() {});
                                                    _model.customActionOutput1 =
                                                        await actions
                                                            .getSaleHomePage(
                                                      FFDevEnvironmentValues()
                                                          .AnonKey,
                                                      currentJwtToken!,
                                                      currentUserUid,
                                                      FFAppState().SalesFilter,
                                                      FFAppState()
                                                          .SalesTypeFilter,
                                                      FFAppState()
                                                          .SalesKmFilter,
                                                      FFAppState().SalesSort,
                                                      FFAppState().communityId,
                                                    );
                                                    FFAppState()
                                                            .SalesHomePageData =
                                                        _model
                                                            .customActionOutput1!
                                                            .toList()
                                                            .cast<dynamic>();
                                                    safeSetState(() {});
                                                  } else {
                                                    FFAppState()
                                                            .SalesTypeFilter =
                                                        'Free';
                                                    safeSetState(() {});
                                                    _model.customActionOutput2 =
                                                        await actions
                                                            .getSaleHomePage(
                                                      FFDevEnvironmentValues()
                                                          .AnonKey,
                                                      currentJwtToken!,
                                                      currentUserUid,
                                                      FFAppState().SalesFilter,
                                                      FFAppState()
                                                          .SalesTypeFilter,
                                                      FFAppState()
                                                          .SalesKmFilter,
                                                      FFAppState().SalesSort,
                                                      FFAppState().communityId,
                                                    );
                                                    FFAppState()
                                                            .SalesHomePageData =
                                                        _model
                                                            .customActionOutput2!
                                                            .toList()
                                                            .cast<dynamic>();
                                                    safeSetState(() {});
                                                  }

                                                  safeSetState(() {});
                                                },
                                                child: AnimatedContainer(
                                                  duration: Duration(
                                                      milliseconds: 180),
                                                  curve: Curves.easeOut,
                                                  height: 36.0,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            24.0),
                                                    border: Border.all(
                                                      color: _model.opt !=
                                                              'Free'
                                                          ? FlutterFlowTheme.of(
                                                                  context)
                                                              .greyL4
                                                          : FlutterFlowTheme.of(
                                                                  context)
                                                              .extraBlack,
                                                    ),
                                                  ),
                                                  child: Align(
                                                    alignment:
                                                        AlignmentDirectional(
                                                            0.0, 0.0),
                                                    child: Padding(
                                                      padding:
                                                          EdgeInsetsDirectional
                                                              .fromSTEB(
                                                                  24.0,
                                                                  0.0,
                                                                  24.0,
                                                                  0.0),
                                                      child: Text(
                                                        'Free',
                                                        style: FlutterFlowTheme
                                                                .of(context)
                                                            .bodyMedium
                                                            .override(
                                                              font: GoogleFonts
                                                                  .manrope(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                fontStyle: FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .fontStyle,
                                                              ),
                                                              color: FFAppState()
                                                                          .SalesTypeFilter ==
                                                                      'Free'
                                                                  ? FlutterFlowTheme.of(
                                                                          context)
                                                                      .extraBlack
                                                                  : FlutterFlowTheme.of(
                                                                          context)
                                                                      .greyL4,
                                                              letterSpacing:
                                                                  0.0,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
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
                                                ),
                                              ),
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
                                                  await showModalBottomSheet(
                                                    isScrollControlled: true,
                                                    backgroundColor:
                                                        Colors.transparent,
                                                    context: context,
                                                    builder: (context) {
                                                      return GestureDetector(
                                                        onTap: () {
                                                          FocusScope.of(context)
                                                              .unfocus();
                                                          FocusManager.instance
                                                              .primaryFocus
                                                              ?.unfocus();
                                                        },
                                                        child: Padding(
                                                          padding: MediaQuery
                                                              .viewInsetsOf(
                                                                  context),
                                                          child:
                                                              CompKmsFilterWidget(
                                                            pageType: 'sale',
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  ).then((value) =>
                                                      safeSetState(() {}));
                                                },
                                                child: Container(
                                                  height: 36.0,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            24.0),
                                                    border: Border.all(
                                                      color:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .greyL4,
                                                    ),
                                                  ),
                                                  child: Padding(
                                                    padding:
                                                        EdgeInsetsDirectional
                                                            .fromSTEB(24.0, 0.0,
                                                                24.0, 0.0),
                                                    child: Row(
                                                      mainAxisSize:
                                                          MainAxisSize.max,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Align(
                                                          alignment:
                                                              AlignmentDirectional(
                                                                  0.0, 0.0),
                                                          child: Text(
                                                            'Distance ${FFAppState().SalesKmFilter.toString()}Km',
                                                            style: FlutterFlowTheme
                                                                    .of(context)
                                                                .bodyMedium
                                                                .override(
                                                                  font: GoogleFonts
                                                                      .manrope(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                    fontStyle: FlutterFlowTheme.of(
                                                                            context)
                                                                        .bodyMedium
                                                                        .fontStyle,
                                                                  ),
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .greyL4,
                                                                  letterSpacing:
                                                                      0.0,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  fontStyle: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMedium
                                                                      .fontStyle,
                                                                  lineHeight:
                                                                      1.0,
                                                                ),
                                                          ),
                                                        ),
                                                        Icon(
                                                          Icons
                                                              .arrow_drop_down_sharp,
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .greyL4,
                                                          size: 20.0,
                                                        ),
                                                      ].divide(
                                                          SizedBox(width: 6.0)),
                                                    ),
                                                  ),
                                                ),
                                              ),
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
                                                  await showModalBottomSheet(
                                                    isScrollControlled: true,
                                                    backgroundColor:
                                                        Colors.transparent,
                                                    context: context,
                                                    builder: (context) {
                                                      return GestureDetector(
                                                        onTap: () {
                                                          FocusScope.of(context)
                                                              .unfocus();
                                                          FocusManager.instance
                                                              .primaryFocus
                                                              ?.unfocus();
                                                        },
                                                        child: Padding(
                                                          padding: MediaQuery
                                                              .viewInsetsOf(
                                                                  context),
                                                          child:
                                                              CompSalesSortWidget(
                                                            pageType: 'sale',
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  ).then((value) =>
                                                      safeSetState(() {}));
                                                },
                                                child: Container(
                                                  height: 36.0,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            24.0),
                                                    border: Border.all(
                                                      color:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .greyL4,
                                                    ),
                                                  ),
                                                  child: Padding(
                                                    padding:
                                                        EdgeInsetsDirectional
                                                            .fromSTEB(24.0, 0.0,
                                                                24.0, 0.0),
                                                    child: Row(
                                                      mainAxisSize:
                                                          MainAxisSize.max,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Align(
                                                          alignment:
                                                              AlignmentDirectional(
                                                                  0.0, 0.0),
                                                          child: Text(
                                                            'SortBy',
                                                            style: FlutterFlowTheme
                                                                    .of(context)
                                                                .bodyMedium
                                                                .override(
                                                                  font: GoogleFonts
                                                                      .manrope(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                    fontStyle: FlutterFlowTheme.of(
                                                                            context)
                                                                        .bodyMedium
                                                                        .fontStyle,
                                                                  ),
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .greyL4,
                                                                  letterSpacing:
                                                                      0.0,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  fontStyle: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMedium
                                                                      .fontStyle,
                                                                  lineHeight:
                                                                      1.0,
                                                                ),
                                                          ),
                                                        ),
                                                        Icon(
                                                          Icons
                                                              .arrow_drop_down_sharp,
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .greyL4,
                                                          size: 20.0,
                                                        ),
                                                      ].divide(
                                                          SizedBox(width: 6.0)),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ]
                                                .divide(SizedBox(width: 8.0))
                                                .addToStart(
                                                    SizedBox(width: 20.0))
                                                .addToEnd(
                                                    SizedBox(width: 20.0)),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  if (((FFAppState()
                                              .SalesHomePageData
                                              .isNotEmpty) ==
                                          true) &&
                                      _model.show)
                                    Expanded(
                                      // Pull-to-refresh re-runs exactly the query
                                      // the active filters/tab already use.
                                      child: RefreshIndicator(
                                        onRefresh: _refreshSale,
                                        color: FlutterFlowTheme.of(context)
                                            .primary,
                                        backgroundColor:
                                            FlutterFlowTheme.of(context)
                                                .secondaryBackground,
                                        child: SingleChildScrollView(
                                          physics:
                                              const AlwaysScrollableScrollPhysics(),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Builder(
                                                builder: (context) {
                                                  final salesHomePageData =
                                                      FFAppState()
                                                          .SalesHomePageData
                                                          .toList();

                                                  return ListView.builder(
                                                    padding:
                                                        EdgeInsets.fromLTRB(
                                                      0,
                                                      0,
                                                      0,
                                                      20.0,
                                                    ),
                                                    primary: false,
                                                    shrinkWrap: true,
                                                    scrollDirection:
                                                        Axis.vertical,
                                                    itemCount: salesHomePageData
                                                        .length,
                                                    itemBuilder: (context,
                                                        salesHomePageDataIndex) {
                                                      final salesHomePageDataItem =
                                                          salesHomePageData[
                                                              salesHomePageDataIndex];
                                                      // One merged semantics node
                                                      // so the card announces as a
                                                      // single button, not as loose
                                                      // fragments of text.
                                                      return MergeSemantics(
                                                          child: Semantics(
                                                              button: true,
                                                              child: InkWell(
                                                                splashColor: FlutterFlowTheme.of(
                                                                        context)
                                                                    .primary
                                                                    .withAlpha(
                                                                        0x14),
                                                                focusColor: Colors
                                                                    .transparent,
                                                                hoverColor: Colors
                                                                    .transparent,
                                                                highlightColor:
                                                                    Colors
                                                                        .transparent,
                                                                onTap:
                                                                    () async {
                                                                  HapticFeedback
                                                                      .lightImpact();
                                                                  context
                                                                      .pushNamed(
                                                                    SaleDetailsWidget
                                                                        .routeName,
                                                                    queryParameters:
                                                                        {
                                                                      'saleId':
                                                                          serializeParam(
                                                                        getJsonField(
                                                                          salesHomePageDataItem,
                                                                          r'''$.id''',
                                                                        ).toString(),
                                                                        ParamType
                                                                            .String,
                                                                      ),
                                                                    }.withoutNulls,
                                                                  );
                                                                },
                                                                child:
                                                                    Container(
                                                                  width: double
                                                                      .infinity,
                                                                  // Was a hard height: 120
                                                                  // (~1.6dp of slack at 12px);
                                                                  // min-height lets the card
                                                                  // grow with the text scale.
                                                                  constraints:
                                                                      const BoxConstraints(
                                                                          minHeight:
                                                                              120.0),
                                                                  margin: EdgeInsetsDirectional
                                                                      .fromSTEB(
                                                                          12.0,
                                                                          6.0,
                                                                          12.0,
                                                                          6.0),
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: FlutterFlowTheme.of(
                                                                            context)
                                                                        .secondaryBackground,
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            20.0),
                                                                    boxShadow: [
                                                                      FFShadows(
                                                                              FlutterFlowTheme.of(context))
                                                                          .sm,
                                                                    ],
                                                                  ),
                                                                  child: Column(
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .max,
                                                                    children: [
                                                                      Padding(
                                                                        padding: EdgeInsetsDirectional.fromSTEB(
                                                                            20.0,
                                                                            20.0,
                                                                            20.0,
                                                                            19.0),
                                                                        child:
                                                                            Row(
                                                                          mainAxisSize:
                                                                              MainAxisSize.max,
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.spaceBetween,
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.start,
                                                                          children:
                                                                              [
                                                                            Stack(
                                                                              alignment: AlignmentDirectional(-1.0, 1.0),
                                                                              children: [
                                                                                if (((String var1) {
                                                                                      return var1 != "null";
                                                                                    }(getJsonField(
                                                                                      salesHomePageDataItem,
                                                                                      r'''$.image''',
                                                                                    ).toString())) ==
                                                                                    true)
                                                                                  AppNetworkImage(
                                                                                    url: getJsonField(
                                                                                      salesHomePageDataItem,
                                                                                      r'''$.image''',
                                                                                    ).toString(),
                                                                                    width: 120.0,
                                                                                    height: 80.0,
                                                                                    fit: BoxFit.cover,
                                                                                    borderRadius: BorderRadius.circular(2.0),
                                                                                  ),
                                                                                if (((String var1) {
                                                                                      return var1 == "null";
                                                                                    }(getJsonField(
                                                                                      salesHomePageDataItem,
                                                                                      r'''$.image''',
                                                                                    ).toString())) ==
                                                                                    true)
                                                                                  Container(
                                                                                    width: 120.0,
                                                                                    height: 80.0,
                                                                                    decoration: BoxDecoration(
                                                                                      color: FlutterFlowTheme.of(context).secondaryBackground,
                                                                                    ),
                                                                                  ),
                                                                              ],
                                                                            ),
                                                                            Expanded(
                                                                              child: Container(
                                                                                // Min-height, not a
                                                                                // hard 80, so the
                                                                                // title/meta column
                                                                                // can grow.
                                                                                constraints: const BoxConstraints(minHeight: 80.0),
                                                                                decoration: BoxDecoration(),
                                                                                child: Column(
                                                                                  mainAxisSize: MainAxisSize.max,
                                                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                  children: [
                                                                                    Row(
                                                                                      mainAxisSize: MainAxisSize.max,
                                                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                                                      children: [
                                                                                        Expanded(
                                                                                          child: Column(
                                                                                            mainAxisSize: MainAxisSize.max,
                                                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                                                            children: [
                                                                                              Text(
                                                                                                getJsonField(
                                                                                                  salesHomePageDataItem,
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
                                                                                      mainAxisSize: MainAxisSize.max,
                                                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                                                      children: [
                                                                                        Flexible(
                                                                                          child: Wrap(
                                                                                            spacing: 2.0,
                                                                                            runSpacing: 0.0,
                                                                                            alignment: WrapAlignment.start,
                                                                                            crossAxisAlignment: WrapCrossAlignment.start,
                                                                                            direction: Axis.horizontal,
                                                                                            runAlignment: WrapAlignment.start,
                                                                                            verticalDirection: VerticalDirection.down,
                                                                                            clipBehavior: Clip.none,
                                                                                            children: [
                                                                                              Text(
                                                                                                valueOrDefault<String>(
                                                                                                  functions.returnRelativeTIme(getJsonField(
                                                                                                    salesHomePageDataItem,
                                                                                                    r'''$.created_at''',
                                                                                                  ).toString()),
                                                                                                  'a hour ago',
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
                                                                                              Padding(
                                                                                                padding: EdgeInsetsDirectional.fromSTEB(0.0, 6.0, 0.0, 0.0),
                                                                                                child: Container(
                                                                                                  width: 2.0,
                                                                                                  height: 2.0,
                                                                                                  decoration: BoxDecoration(
                                                                                                    color: FlutterFlowTheme.of(context).greyL4,
                                                                                                    borderRadius: BorderRadius.circular(24.0),
                                                                                                  ),
                                                                                                ),
                                                                                              ),
                                                                                              Text(
                                                                                                '${valueOrDefault<String>(
                                                                                                  getJsonField(
                                                                                                    salesHomePageDataItem,
                                                                                                    r'''$.distance_km''',
                                                                                                  )?.toString(),
                                                                                                  '1',
                                                                                                )}kms',
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
                                                                                              Padding(
                                                                                                padding: EdgeInsetsDirectional.fromSTEB(0.0, 6.0, 0.0, 0.0),
                                                                                                child: Container(
                                                                                                  width: 2.0,
                                                                                                  height: 2.0,
                                                                                                  decoration: BoxDecoration(
                                                                                                    color: FlutterFlowTheme.of(context).greyL4,
                                                                                                    borderRadius: BorderRadius.circular(24.0),
                                                                                                  ),
                                                                                                ),
                                                                                              ),
                                                                                              Text(
                                                                                                getJsonField(
                                                                                                  salesHomePageDataItem,
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
                                                                                            ],
                                                                                          ),
                                                                                        ),
                                                                                        if (((String var1) {
                                                                                              return var1 != "null";
                                                                                            }(getJsonField(
                                                                                              salesHomePageDataItem,
                                                                                              r'''$.price''',
                                                                                            ).toString())) ==
                                                                                            true)
                                                                                          Text(
                                                                                            '$kCurrencySymbol${getJsonField(
                                                                                              salesHomePageDataItem,
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
                                                                            ),
                                                                          ].divide(SizedBox(width: 8.0)),
                                                                        ),
                                                                      ),
                                                                      Container(
                                                                        width: double
                                                                            .infinity,
                                                                        height:
                                                                            1.0,
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          color:
                                                                              FlutterFlowTheme.of(context).greyL2,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              )
                                                                  .animate()
                                                                  .fadeIn(
                                                                    duration:
                                                                        260.ms,
                                                                    delay: (40 *
                                                                            (salesHomePageDataIndex %
                                                                                8))
                                                                        .ms,
                                                                  )
                                                                  .slideY(
                                                                    begin: 0.06,
                                                                    end: 0,
                                                                    curve: Curves
                                                                        .easeOutCubic,
                                                                  )));
                                                    },
                                                  );
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  if (_model.show == false)
                                    Expanded(
                                      child: Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            20.0, 0.0, 20.0, 0.0),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.max,
                                          children: [
                                            Align(
                                              alignment: AlignmentDirectional(
                                                  0.0, -1.0),
                                              child: Container(
                                                width: double.infinity,
                                                height: 120.0,
                                                decoration: BoxDecoration(
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .greyL2,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          4.0),
                                                ),
                                              ).animateOnPageLoad(animationsMap[
                                                  'containerOnPageLoadAnimation1']!),
                                            ),
                                            Align(
                                              alignment: AlignmentDirectional(
                                                  0.0, -1.0),
                                              child: Container(
                                                width: double.infinity,
                                                height: 120.0,
                                                decoration: BoxDecoration(
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .greyL2,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          4.0),
                                                ),
                                              ).animateOnPageLoad(animationsMap[
                                                  'containerOnPageLoadAnimation2']!),
                                            ),
                                            Align(
                                              alignment: AlignmentDirectional(
                                                  0.0, -1.0),
                                              child: Container(
                                                width: double.infinity,
                                                height: 120.0,
                                                decoration: BoxDecoration(
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .greyL2,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          4.0),
                                                ),
                                              ).animateOnPageLoad(animationsMap[
                                                  'containerOnPageLoadAnimation3']!),
                                            ),
                                          ].divide(SizedBox(height: 10.0)),
                                        ),
                                      ),
                                    ),
                                  if (valueOrDefault<bool>(
                                    ((FFAppState()
                                                .SalesHomePageData
                                                .isNotEmpty) ==
                                            false) &&
                                        (FFAppState().SalesTypeFilter ==
                                            'Fixed') &&
                                        _model.show,
                                    false,
                                  ))
                                    Expanded(
                                      child: wrapWithModel(
                                        model: _model.compNoDataFoundModel1,
                                        updateCallback: () =>
                                            safeSetState(() {}),
                                        child: CompNoDataFoundWidget(
                                          pageName: 'sales',
                                          text1: 'No listings available',
                                          text2:
                                              'Items for sale or giveaway will appear here once users start posting.',
                                        ),
                                      ),
                                    ),
                                  if (valueOrDefault<bool>(
                                    ((FFAppState().SalesHomePageData.isNotEmpty) ==
                                            false) &&
                                        (FFAppState().SalesTypeFilter ==
                                            'Free') &&
                                        _model.show,
                                    false,
                                  ))
                                    Expanded(
                                      child: wrapWithModel(
                                        model: _model.compNoDataFoundModel2,
                                        updateCallback: () =>
                                            safeSetState(() {}),
                                        child: CompNoDataFoundWidget(
                                          pageName: 'salesfree',
                                          text1: 'No free items right now',
                                          text2:
                                              'Free giveaways will appear here as soon as someone lists them.',
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      if ((_model.switchOption == 'yours') && !_loadFailed)
                        Expanded(
                          child: Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                0.0, 8.0, 0.0, 0.0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: FlutterFlowTheme.of(context).white,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        0.0, 4.0, 0.0, 0.0),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color:
                                            FlutterFlowTheme.of(context).white,
                                      ),
                                      child: Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            0.0, 8.0, 0.0, 8.0),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.max,
                                          children: [
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
                                                HapticFeedback.lightImpact();
                                                _model.opt = 'all';
                                                safeSetState(() {});
                                                _model.salesDataAll =
                                                    await GetSalesDataCall.call(
                                                  pUserid: currentUserUid,
                                                  pFilter: 'all',
                                                  token: currentJwtToken,
                                                );

                                                if ((_model.salesDataAll
                                                        ?.succeeded ??
                                                    true)) {
                                                  _model.salesListing = (_model
                                                              .salesDataAll
                                                              ?.jsonBody ??
                                                          '')
                                                      .toList()
                                                      .cast<dynamic>();
                                                  safeSetState(() {});
                                                }

                                                safeSetState(() {});
                                              },
                                              child: AnimatedContainer(
                                                duration:
                                                    Duration(milliseconds: 180),
                                                curve: Curves.easeOut,
                                                height: 36.0,
                                                decoration: BoxDecoration(
                                                  color: _model.opt == 'all'
                                                      ? FlutterFlowTheme.of(
                                                              context)
                                                          .primary
                                                      : Colors.transparent,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          24.0),
                                                  border: Border.all(
                                                    color: _model.opt != 'all'
                                                        ? FlutterFlowTheme.of(
                                                                context)
                                                            .greyL4
                                                        : Colors.transparent,
                                                  ),
                                                ),
                                                child: Align(
                                                  alignment:
                                                      AlignmentDirectional(
                                                          0.0, 0.0),
                                                  child: Padding(
                                                    padding:
                                                        EdgeInsetsDirectional
                                                            .fromSTEB(24.0, 0.0,
                                                                24.0, 0.0),
                                                    child: Text(
                                                      'All',
                                                      style: FlutterFlowTheme
                                                              .of(context)
                                                          .bodyMedium
                                                          .override(
                                                            font: GoogleFonts
                                                                .manrope(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              fontStyle:
                                                                  FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMedium
                                                                      .fontStyle,
                                                            ),
                                                            color: _model.opt ==
                                                                    'all'
                                                                ? Colors.white
                                                                : FlutterFlowTheme.of(
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
                                              ),
                                            ),
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
                                                HapticFeedback.lightImpact();
                                                _model.opt = 'sell';
                                                safeSetState(() {});
                                                _model.salesDataSelling =
                                                    await GetSalesDataCall.call(
                                                  pUserid: currentUserUid,
                                                  pFilter: 'selling',
                                                  token: currentJwtToken,
                                                );

                                                if ((_model.salesDataSelling
                                                        ?.succeeded ??
                                                    true)) {
                                                  _model.salesListing = (_model
                                                              .salesDataSelling
                                                              ?.jsonBody ??
                                                          '')
                                                      .toList()
                                                      .cast<dynamic>();
                                                  safeSetState(() {});
                                                }

                                                safeSetState(() {});
                                              },
                                              child: AnimatedContainer(
                                                duration:
                                                    Duration(milliseconds: 180),
                                                curve: Curves.easeOut,
                                                height: 36.0,
                                                decoration: BoxDecoration(
                                                  color: _model.opt == 'sell'
                                                      ? FlutterFlowTheme.of(
                                                              context)
                                                          .primary
                                                      : Colors.transparent,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          24.0),
                                                  border: Border.all(
                                                    color: _model.opt != 'sell'
                                                        ? FlutterFlowTheme.of(
                                                                context)
                                                            .greyL4
                                                        : Colors.transparent,
                                                  ),
                                                ),
                                                child: Align(
                                                  alignment:
                                                      AlignmentDirectional(
                                                          0.0, 0.0),
                                                  child: Padding(
                                                    padding:
                                                        EdgeInsetsDirectional
                                                            .fromSTEB(24.0, 0.0,
                                                                24.0, 0.0),
                                                    child: Text(
                                                      'Selling',
                                                      style: FlutterFlowTheme
                                                              .of(context)
                                                          .bodyMedium
                                                          .override(
                                                            font: GoogleFonts
                                                                .manrope(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              fontStyle:
                                                                  FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMedium
                                                                      .fontStyle,
                                                            ),
                                                            color: _model.opt ==
                                                                    'sell'
                                                                ? Colors.white
                                                                : FlutterFlowTheme.of(
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
                                              ),
                                            ),
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
                                                HapticFeedback.lightImpact();
                                                _model.opt = 'sold';
                                                safeSetState(() {});
                                                _model.salesDataSold =
                                                    await GetSalesDataCall.call(
                                                  pUserid: currentUserUid,
                                                  pFilter: 'sold',
                                                  token: currentJwtToken,
                                                );

                                                if ((_model.salesDataSold
                                                        ?.succeeded ??
                                                    true)) {
                                                  _model.salesListing = (_model
                                                              .salesDataSold
                                                              ?.jsonBody ??
                                                          '')
                                                      .toList()
                                                      .cast<dynamic>();
                                                  safeSetState(() {});
                                                }

                                                safeSetState(() {});
                                              },
                                              child: AnimatedContainer(
                                                duration:
                                                    Duration(milliseconds: 180),
                                                curve: Curves.easeOut,
                                                height: 36.0,
                                                decoration: BoxDecoration(
                                                  color: _model.opt == 'sold'
                                                      ? FlutterFlowTheme.of(
                                                              context)
                                                          .primary
                                                      : Colors.transparent,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          24.0),
                                                  border: Border.all(
                                                    color: _model.opt != 'sold'
                                                        ? FlutterFlowTheme.of(
                                                                context)
                                                            .greyL4
                                                        : Colors.transparent,
                                                  ),
                                                ),
                                                child: Align(
                                                  alignment:
                                                      AlignmentDirectional(
                                                          0.0, 0.0),
                                                  child: Padding(
                                                    padding:
                                                        EdgeInsetsDirectional
                                                            .fromSTEB(24.0, 0.0,
                                                                24.0, 0.0),
                                                    child: Text(
                                                      'Sold',
                                                      style: FlutterFlowTheme
                                                              .of(context)
                                                          .bodyMedium
                                                          .override(
                                                            font: GoogleFonts
                                                                .manrope(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              fontStyle:
                                                                  FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMedium
                                                                      .fontStyle,
                                                            ),
                                                            color: _model.opt ==
                                                                    'sold'
                                                                ? Colors.white
                                                                : FlutterFlowTheme.of(
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
                                              ),
                                            ),
                                          ]
                                              .divide(SizedBox(width: 8.0))
                                              .addToStart(SizedBox(width: 20.0))
                                              .addToEnd(SizedBox(width: 20.0)),
                                        ),
                                      ),
                                    ),
                                  ),
                                  if ((_model.salesListing.isNotEmpty) == true)
                                    Expanded(
                                      // Pull-to-refresh re-runs exactly the query
                                      // the active filters/tab already use.
                                      child: RefreshIndicator(
                                        onRefresh: _refreshSale,
                                        color: FlutterFlowTheme.of(context)
                                            .primary,
                                        backgroundColor:
                                            FlutterFlowTheme.of(context)
                                                .secondaryBackground,
                                        child: SingleChildScrollView(
                                          physics:
                                              const AlwaysScrollableScrollPhysics(),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Builder(
                                                builder: (context) {
                                                  final sales = _model
                                                      .salesListing
                                                      .toList();

                                                  return ListView.builder(
                                                    padding:
                                                        EdgeInsets.fromLTRB(
                                                      0,
                                                      0,
                                                      0,
                                                      20.0,
                                                    ),
                                                    primary: false,
                                                    shrinkWrap: true,
                                                    scrollDirection:
                                                        Axis.vertical,
                                                    itemCount: sales.length,
                                                    itemBuilder:
                                                        (context, salesIndex) {
                                                      final salesItem =
                                                          sales[salesIndex];
                                                      // One merged semantics node
                                                      // so the card announces as a
                                                      // single button, not as loose
                                                      // fragments of text.
                                                      return MergeSemantics(
                                                          child: Semantics(
                                                              button: true,
                                                              child: InkWell(
                                                                splashColor: FlutterFlowTheme.of(
                                                                        context)
                                                                    .primary
                                                                    .withAlpha(
                                                                        0x14),
                                                                focusColor: Colors
                                                                    .transparent,
                                                                hoverColor: Colors
                                                                    .transparent,
                                                                highlightColor:
                                                                    Colors
                                                                        .transparent,
                                                                onTap:
                                                                    () async {
                                                                  HapticFeedback
                                                                      .lightImpact();
                                                                  context
                                                                      .pushNamed(
                                                                    SaleDetailsWidget
                                                                        .routeName,
                                                                    queryParameters:
                                                                        {
                                                                      'saleId':
                                                                          serializeParam(
                                                                        getJsonField(
                                                                          salesItem,
                                                                          r'''$.id''',
                                                                        ).toString(),
                                                                        ParamType
                                                                            .String,
                                                                      ),
                                                                    }.withoutNulls,
                                                                  );
                                                                },
                                                                child:
                                                                    Container(
                                                                  width: double
                                                                      .infinity,
                                                                  // Was a hard height: 120
                                                                  // (~1.6dp of slack at 12px);
                                                                  // min-height lets the card
                                                                  // grow with the text scale.
                                                                  constraints:
                                                                      const BoxConstraints(
                                                                          minHeight:
                                                                              120.0),
                                                                  margin: EdgeInsetsDirectional
                                                                      .fromSTEB(
                                                                          12.0,
                                                                          6.0,
                                                                          12.0,
                                                                          6.0),
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: FlutterFlowTheme.of(
                                                                            context)
                                                                        .secondaryBackground,
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            20.0),
                                                                    boxShadow: [
                                                                      FFShadows(
                                                                              FlutterFlowTheme.of(context))
                                                                          .sm,
                                                                    ],
                                                                  ),
                                                                  child: Column(
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .max,
                                                                    children: [
                                                                      Padding(
                                                                        padding: EdgeInsetsDirectional.fromSTEB(
                                                                            20.0,
                                                                            20.0,
                                                                            20.0,
                                                                            19.0),
                                                                        child:
                                                                            Row(
                                                                          mainAxisSize:
                                                                              MainAxisSize.max,
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.spaceBetween,
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.start,
                                                                          children:
                                                                              [
                                                                            Stack(
                                                                              children: [
                                                                                if (((String var1) {
                                                                                      return var1 != "null";
                                                                                    }(getJsonField(
                                                                                      salesItem,
                                                                                      r'''$.first_image''',
                                                                                    ).toString())) ==
                                                                                    true)
                                                                                  Stack(
                                                                                    alignment: AlignmentDirectional(-1.0, 1.0),
                                                                                    children: [
                                                                                      if (((String var1) {
                                                                                            return var1 != "selling";
                                                                                          }(getJsonField(
                                                                                            salesItem,
                                                                                            r'''$.e_sale_type''',
                                                                                          ).toString())) ==
                                                                                          true)
                                                                                        Padding(
                                                                                          padding: EdgeInsetsDirectional.fromSTEB(4.0, 0.0, 0.0, 4.0),
                                                                                          child: ClipRRect(
                                                                                            borderRadius: BorderRadius.circular(4.0),
                                                                                            child: BackdropFilter(
                                                                                              filter: ImageFilter.blur(
                                                                                                sigmaX: 3.0,
                                                                                                sigmaY: 3.0,
                                                                                              ),
                                                                                              child: Container(
                                                                                                // Min-size + padding (was a fixed 52x18 box) so the 12px
                                                                                                // label can grow instead of wrapping/clipping.
                                                                                                constraints: BoxConstraints(
                                                                                                  minWidth: 52.0,
                                                                                                  minHeight: 18.0,
                                                                                                ),
                                                                                                padding: EdgeInsetsDirectional.fromSTEB(4.0, 2.0, 4.0, 2.0),
                                                                                                decoration: BoxDecoration(
                                                                                                  color: Color(0x19FFFFFF),
                                                                                                  borderRadius: BorderRadius.circular(4.0),
                                                                                                ),
                                                                                                child: Text(
                                                                                                  'Sold out',
                                                                                                  textAlign: TextAlign.center,
                                                                                                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                                        font: GoogleFonts.manrope(
                                                                                                          fontWeight: FontWeight.bold,
                                                                                                          fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                        ),
                                                                                                        color: Colors.white,
                                                                                                        fontSize: 12.0,
                                                                                                        letterSpacing: 0.0,
                                                                                                        fontWeight: FontWeight.bold,
                                                                                                        fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                      ),
                                                                                                ),
                                                                                              ),
                                                                                            ),
                                                                                          ),
                                                                                        ),
                                                                                      AppNetworkImage(
                                                                                        url: getJsonField(
                                                                                          salesItem,
                                                                                          r'''$.first_image''',
                                                                                        ).toString(),
                                                                                        width: 120.0,
                                                                                        height: 80.0,
                                                                                        fit: BoxFit.cover,
                                                                                        borderRadius: BorderRadius.circular(2.0),
                                                                                      ),
                                                                                    ],
                                                                                  ),
                                                                                if (((String var1) {
                                                                                      return var1 == "null";
                                                                                    }(getJsonField(
                                                                                      salesItem,
                                                                                      r'''$.first_image''',
                                                                                    ).toString())) ==
                                                                                    true)
                                                                                  Container(
                                                                                    width: 120.0,
                                                                                    height: 80.0,
                                                                                    decoration: BoxDecoration(
                                                                                      color: FlutterFlowTheme.of(context).white,
                                                                                    ),
                                                                                    alignment: AlignmentDirectional(-1.0, 1.0),
                                                                                    child: Visibility(
                                                                                      visible: ((String var1) {
                                                                                            return var1 != "selling";
                                                                                          }(getJsonField(
                                                                                            salesItem,
                                                                                            r'''$.e_sale_type''',
                                                                                          ).toString())) ==
                                                                                          true,
                                                                                      child: Padding(
                                                                                        padding: EdgeInsetsDirectional.fromSTEB(4.0, 0.0, 0.0, 4.0),
                                                                                        child: ClipRRect(
                                                                                          borderRadius: BorderRadius.circular(4.0),
                                                                                          child: BackdropFilter(
                                                                                            filter: ImageFilter.blur(
                                                                                              sigmaX: 3.0,
                                                                                              sigmaY: 3.0,
                                                                                            ),
                                                                                            child: Container(
                                                                                              // Min-size + padding (was a fixed 52x18 box) so the 12px
                                                                                              // label can grow instead of wrapping/clipping.
                                                                                              constraints: BoxConstraints(
                                                                                                minWidth: 52.0,
                                                                                                minHeight: 18.0,
                                                                                              ),
                                                                                              padding: EdgeInsetsDirectional.fromSTEB(4.0, 2.0, 4.0, 2.0),
                                                                                              decoration: BoxDecoration(
                                                                                                color: Color(0x19FFFFFF),
                                                                                                borderRadius: BorderRadius.circular(4.0),
                                                                                              ),
                                                                                              child: Text(
                                                                                                'Sold out',
                                                                                                textAlign: TextAlign.center,
                                                                                                style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                                      font: GoogleFonts.manrope(
                                                                                                        fontWeight: FontWeight.bold,
                                                                                                        fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                      ),
                                                                                                      color: Colors.white,
                                                                                                      fontSize: 12.0,
                                                                                                      letterSpacing: 0.0,
                                                                                                      fontWeight: FontWeight.bold,
                                                                                                      fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                    ),
                                                                                              ),
                                                                                            ),
                                                                                          ),
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                              ],
                                                                            ),
                                                                            Flexible(
                                                                              child: Container(
                                                                                // Min-height, not a
                                                                                // hard 80, so the
                                                                                // title/meta column
                                                                                // can grow.
                                                                                constraints: const BoxConstraints(minHeight: 80.0),
                                                                                decoration: BoxDecoration(),
                                                                                child: Column(
                                                                                  mainAxisSize: MainAxisSize.max,
                                                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                                  children: [
                                                                                    Text(
                                                                                      getJsonField(
                                                                                        salesItem,
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
                                                                                    Row(
                                                                                      mainAxisSize: MainAxisSize.max,
                                                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                                                      children: [
                                                                                        Flexible(
                                                                                          child: Wrap(
                                                                                            spacing: 2.0,
                                                                                            runSpacing: 0.0,
                                                                                            alignment: WrapAlignment.start,
                                                                                            crossAxisAlignment: WrapCrossAlignment.start,
                                                                                            direction: Axis.horizontal,
                                                                                            runAlignment: WrapAlignment.start,
                                                                                            verticalDirection: VerticalDirection.down,
                                                                                            clipBehavior: Clip.none,
                                                                                            children: [
                                                                                              Text(
                                                                                                valueOrDefault<String>(
                                                                                                  functions.returnRelativeTIme(getJsonField(
                                                                                                    salesItem,
                                                                                                    r'''$.created_at''',
                                                                                                  ).toString()),
                                                                                                  'a hour ago ',
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
                                                                                              Padding(
                                                                                                padding: EdgeInsetsDirectional.fromSTEB(0.0, 6.0, 0.0, 0.0),
                                                                                                child: Container(
                                                                                                  width: 2.0,
                                                                                                  height: 2.0,
                                                                                                  decoration: BoxDecoration(
                                                                                                    color: FlutterFlowTheme.of(context).greyL4,
                                                                                                    borderRadius: BorderRadius.circular(24.0),
                                                                                                  ),
                                                                                                ),
                                                                                              ),
                                                                                              Text(
                                                                                                '${valueOrDefault<String>(
                                                                                                  getJsonField(
                                                                                                    salesItem,
                                                                                                    r'''$.distance_km''',
                                                                                                  )?.toString(),
                                                                                                  '1',
                                                                                                )}kms',
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
                                                                                              Padding(
                                                                                                padding: EdgeInsetsDirectional.fromSTEB(0.0, 6.0, 0.0, 0.0),
                                                                                                child: Container(
                                                                                                  width: 2.0,
                                                                                                  height: 2.0,
                                                                                                  decoration: BoxDecoration(
                                                                                                    color: FlutterFlowTheme.of(context).greyL4,
                                                                                                    borderRadius: BorderRadius.circular(24.0),
                                                                                                  ),
                                                                                                ),
                                                                                              ),
                                                                                              Text(
                                                                                                getJsonField(
                                                                                                  salesItem,
                                                                                                  r'''$.location''',
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
                                                                                            ],
                                                                                          ),
                                                                                        ),
                                                                                        if (((String var1) {
                                                                                              return var1 != "null";
                                                                                            }(getJsonField(
                                                                                              salesItem,
                                                                                              r'''$.price''',
                                                                                            ).toString())) ==
                                                                                            true)
                                                                                          Text(
                                                                                            '$kCurrencySymbol${getJsonField(
                                                                                              salesItem,
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
                                                                            ),
                                                                          ].divide(SizedBox(width: 8.0)),
                                                                        ),
                                                                      ),
                                                                      Container(
                                                                        width: double
                                                                            .infinity,
                                                                        height:
                                                                            1.0,
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          color:
                                                                              FlutterFlowTheme.of(context).greyL2,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              )
                                                                  .animate()
                                                                  .fadeIn(
                                                                    duration:
                                                                        260.ms,
                                                                    delay: (40 *
                                                                            (salesIndex %
                                                                                8))
                                                                        .ms,
                                                                  )
                                                                  .slideY(
                                                                    begin: 0.06,
                                                                    end: 0,
                                                                    curve: Curves
                                                                        .easeOutCubic,
                                                                  )));
                                                    },
                                                  );
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  if (valueOrDefault<bool>(
                                    ((_model.salesListing.isNotEmpty) ==
                                            false) &&
                                        (_model.opt == 'all'),
                                    false,
                                  ))
                                    Expanded(
                                      child: wrapWithModel(
                                        model: _model.compNoDataFoundModel3,
                                        updateCallback: () =>
                                            safeSetState(() {}),
                                        child: CompNoDataFoundWidget(
                                          pageName: 'yourslisting',
                                          text1:
                                              'You haven’t listed anything yet',
                                          text2:
                                              'List an item to sell or give away — it’ll show up here.',
                                        ),
                                      ),
                                    ),
                                  if (valueOrDefault<bool>(
                                    ((_model.salesListing.isNotEmpty) ==
                                            false) &&
                                        (_model.opt == 'sell'),
                                    false,
                                  ))
                                    Expanded(
                                      child: wrapWithModel(
                                        model: _model.compNoDataFoundModel4,
                                        updateCallback: () =>
                                            safeSetState(() {}),
                                        child: CompNoDataFoundWidget(
                                          pageName: 'yourslisting',
                                          text1:
                                              'You haven’t listed anything yet',
                                          text2:
                                              'List an item to sell or give away — it’ll show up here.',
                                        ),
                                      ),
                                    ),
                                  if (valueOrDefault<bool>(
                                    ((_model.salesListing.isNotEmpty) ==
                                            false) &&
                                        (_model.opt == 'sold'),
                                    false,
                                  ))
                                    Expanded(
                                      child: wrapWithModel(
                                        model: _model.compNoDataFoundModel5,
                                        updateCallback: () =>
                                            safeSetState(() {}),
                                        child: CompNoDataFoundWidget(
                                          pageName: 'yourslisting',
                                          text1:
                                              'You haven’t listed anything yet',
                                          text2:
                                              'List an item to sell or give away — it’ll show up here.',
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
                wrapWithModel(
                  model: _model.compNavbarModel,
                  updateCallback: () => safeSetState(() {}),
                  child: CompNavbarWidget(
                    pagename: 'sale',
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
