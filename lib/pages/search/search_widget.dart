import '/auth/supabase_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/backend/supabase/supabase.dart';
import '/components/comp_no_data_found_widget.dart';
import '/components/comp_share_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/pages/business/comp_business_contact/comp_business_contact_widget.dart';
import '/pages/group/comp_share_group/comp_share_group_widget.dart';
import '/pages/home/comp_likes/comp_likes_widget.dart';
import '/pages/home/comp_loading/comp_loading_widget.dart';
import '/pages/home/comp_three_dot_block_user/comp_three_dot_block_user_widget.dart';
import '/pages/home/comp_three_dot_edit_post/comp_three_dot_edit_post_widget.dart';
import '/pages/loder_components/shimmer_loader/shimmer_loader_widget.dart';
import '/pages/sale/comp_category_filter/comp_category_filter_widget.dart';
import '/pages/sale/comp_kms_filter/comp_kms_filter_widget.dart';
import '/pages/sale/comp_sales_sort/comp_sales_sort_widget.dart';
import 'dart:ui';
import '/custom_code/actions/index.dart' as actions;
import '/custom_code/widgets/index.dart' as custom_widgets;
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';
import 'dart:async';
import 'dart:math' as math;
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'search_model.dart';
export 'search_model.dart';

class SearchWidget extends StatefulWidget {
  const SearchWidget({
    super.key,
    required this.searchName,
  });

  final String? searchName;

  static String routeName = 'Search';
  static String routePath = 'search';

  @override
  State<SearchWidget> createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchWidget> {
  late SearchModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => SearchModel());

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      _model.isSearchHistoryPresent = await SearchHistoryTable().queryRows(
        queryFn: (q) => q
            .eqOrNull(
              'community_id',
              FFAppState().communityId,
            )
            .eqOrNull(
              'searched_by',
              currentUserUid,
            ),
      );
      _model.isSearchHistory = (_model.isSearchHistoryPresent != null &&
                  (_model.isSearchHistoryPresent)!.isNotEmpty) ==
              true
          ? true
          : false;
      safeSetState(() {});
      FFAppState().SalesSort = 'Newest';
      FFAppState().SalesFilter = 'All categories';
      FFAppState().SalesKmFilter = 10;
      FFAppState().SalesTypeFilter = 'Fixed';
      FFAppState().SearchData = null;
      safeSetState(() {});
      await actions.unsubscribe(
        'post',
      );
      await Future.delayed(
        Duration(
          milliseconds: 1000,
        ),
      );
      await actions.subscribe(
        'post',
        () async {
          safeSetState(() => _model.apiRequestCompleter1 = null);
          await _model.waitForApiRequestCompleted1();
        },
      );
      await actions.unsubscribe(
        'event_page',
      );
      await Future.delayed(
        Duration(
          milliseconds: 1000,
        ),
      );
      await actions.subscribe(
        'event_page',
        () async {
          safeSetState(() => _model.apiRequestCompleter2 = null);
          await _model.waitForApiRequestCompleted2();
          safeSetState(() => _model.apiRequestCompleter3 = null);
          await _model.waitForApiRequestCompleted3();
        },
      );
      await actions.unsubscribe(
        'event_attending',
      );
      await Future.delayed(
        Duration(
          milliseconds: 1000,
        ),
      );
      await actions.subscribe(
        'event_attending',
        () async {
          safeSetState(() => _model.apiRequestCompleter2 = null);
          await _model.waitForApiRequestCompleted2();
          safeSetState(() => _model.apiRequestCompleter3 = null);
          await _model.waitForApiRequestCompleted3();
        },
      );
    });

    _model.textController ??= TextEditingController();
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
          child: Container(
            decoration: BoxDecoration(
              color: FlutterFlowTheme.of(context).pageBack,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: FlutterFlowTheme.of(context).white,
                  ),
                  child: Padding(
                    padding:
                        EdgeInsetsDirectional.fromSTEB(0.0, 12.0, 0.0, 12.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        FlutterFlowIconButton(
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
                        Expanded(
                          child: Container(
                            height: 36.0,
                            decoration: BoxDecoration(
                              color: Color(0xFFF7F9FC),
                              borderRadius: BorderRadius.circular(4.0),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Expanded(
                                  child: Container(
                                    width: double.infinity,
                                    child: TextFormField(
                                      controller: _model.textController,
                                      focusNode: _model.textFieldFocusNode,
                                      onChanged: (_) => EasyDebounce.debounce(
                                        '_model.textController',
                                        Duration(milliseconds: 2000),
                                        () async {
                                          if ((String var1) {
                                            return var1.length >= 3;
                                          }(_model.textController.text)) {
                                            _model.searchEmpty = false;
                                            _model.showData = true;
                                            safeSetState(() {});
                                            _model.apiResulth6n =
                                                await GetAllSearchCall.call(
                                              pSearchText:
                                                  _model.textController.text,
                                              pUserid: currentUserUid,
                                              pCommunityid:
                                                  FFAppState().communityId,
                                              token: currentJwtToken,
                                              pType: _model.optionChoosed,
                                              pCategory:
                                                  FFAppState().SalesFilter,
                                              pSaleType:
                                                  FFAppState().SalesTypeFilter,
                                              pSort: FFAppState().SalesSort,
                                              pDistance:
                                                  FFAppState().SalesKmFilter,
                                            );

                                            if ((_model
                                                    .apiResulth6n?.succeeded ??
                                                true)) {
                                              FFAppState().SearchData = (_model
                                                      .apiResulth6n?.jsonBody ??
                                                  '');
                                              safeSetState(() {});
                                            }
                                          } else {
                                            if (_model.textController.text
                                                    .length ==
                                                0) {
                                              _model.searchEmpty = true;
                                              safeSetState(() {});
                                            } else {
                                              _model.searchEmpty = false;
                                              safeSetState(() {});
                                            }
                                          }

                                          safeSetState(() {});
                                        },
                                      ),
                                      onFieldSubmitted: (_) async {
                                        _model.apiResultskh =
                                            await UpdateSearchHistoryCall.call(
                                          token: currentJwtToken,
                                          pUserid: currentUserUid,
                                          pCommunityId:
                                              FFAppState().communityId,
                                          pSearchText:
                                              _model.textController.text,
                                        );

                                        safeSetState(() {});
                                      },
                                      autofocus: true,
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
                                        hintText: 'Search',
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
                                            color: Color(0x00000000),
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
                                        fillColor: Color(0xFFF7F9FC),
                                        contentPadding:
                                            EdgeInsetsDirectional.fromSTEB(
                                                12.0, 8.0, 12.0, 8.0),
                                        prefixIcon: Icon(
                                          Icons.search_rounded,
                                          color: FlutterFlowTheme.of(context)
                                              .greyL4,
                                          size: 20.0,
                                        ),
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
                                      validator: _model.textControllerValidator
                                          .asValidator(context),
                                    ),
                                  ),
                                ),
                              ],
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
                if (_model.showData)
                  Container(
                    width: double.infinity,
                    height: 48.0,
                    decoration: BoxDecoration(
                      color: FlutterFlowTheme.of(context).secondaryBackground,
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          InkWell(
                            splashColor: Colors.transparent,
                            focusColor: Colors.transparent,
                            hoverColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            onTap: () async {
                              FFAppState().SalesSort = 'Newest';
                              FFAppState().SalesFilter = 'All categories';
                              FFAppState().SalesKmFilter = 10;
                              FFAppState().SalesTypeFilter = 'Fixed';
                              FFAppState().SearchData = null;
                              safeSetState(() {});
                              _model.optionChoosed = 'all';
                              safeSetState(() {});
                              _model.allData = await GetAllSearchCall.call(
                                pSearchText: _model.textController.text,
                                pUserid: currentUserUid,
                                pCommunityid: FFAppState().communityId,
                                token: currentJwtToken,
                                pType: _model.optionChoosed,
                                pCategory: FFAppState().SalesFilter,
                                pSaleType: FFAppState().SalesTypeFilter,
                                pSort: FFAppState().SalesSort,
                                pDistance: FFAppState().SalesKmFilter,
                              );

                              FFAppState().SearchData =
                                  (_model.allData?.jsonBody ?? '');
                              safeSetState(() {});

                              safeSetState(() {});
                            },
                            child: Container(
                              height: 28.0,
                              decoration: BoxDecoration(
                                color: _model.optionChoosed == 'all'
                                    ? FlutterFlowTheme.of(context).greenColor1
                                    : Color(0x00000000),
                                borderRadius: BorderRadius.circular(24.0),
                                border: Border.all(
                                  color: _model.optionChoosed != 'all'
                                      ? FlutterFlowTheme.of(context).greyL4
                                      : Color(0x00000000),
                                ),
                              ),
                              child: Align(
                                alignment: AlignmentDirectional(0.0, 0.0),
                                child: Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      16.0, 0.0, 16.0, 0.0),
                                  child: Text(
                                    'All',
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
                                          color: _model.optionChoosed == 'all'
                                              ? FlutterFlowTheme.of(context)
                                                  .white
                                              : FlutterFlowTheme.of(context)
                                                  .greyL4,
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
                                ),
                              ),
                            ),
                          ),
                          InkWell(
                            splashColor: Colors.transparent,
                            focusColor: Colors.transparent,
                            hoverColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            onTap: () async {
                              _model.optionChoosed = 'post';
                              safeSetState(() {});
                              _model.posts = await GetAllSearchCall.call(
                                pSearchText: _model.textController.text,
                                pUserid: currentUserUid,
                                pCommunityid: FFAppState().communityId,
                                token: currentJwtToken,
                                pType: _model.optionChoosed,
                                pCategory: FFAppState().SalesFilter,
                                pSaleType: FFAppState().SalesTypeFilter,
                                pSort: FFAppState().SalesSort,
                                pDistance: FFAppState().SalesKmFilter,
                              );

                              FFAppState().SearchData =
                                  (_model.posts?.jsonBody ?? '');
                              safeSetState(() {});

                              safeSetState(() {});
                            },
                            child: Container(
                              height: 28.0,
                              decoration: BoxDecoration(
                                color: _model.optionChoosed == 'post'
                                    ? FlutterFlowTheme.of(context).greenColor1
                                    : Color(0x00000000),
                                borderRadius: BorderRadius.circular(24.0),
                                border: Border.all(
                                  color: _model.optionChoosed != 'post'
                                      ? FlutterFlowTheme.of(context).greyL4
                                      : Color(0x00000000),
                                ),
                              ),
                              child: Align(
                                alignment: AlignmentDirectional(0.0, 0.0),
                                child: Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      16.0, 0.0, 16.0, 0.0),
                                  child: Text(
                                    'Posts',
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
                                          color: _model.optionChoosed == 'post'
                                              ? FlutterFlowTheme.of(context)
                                                  .white
                                              : FlutterFlowTheme.of(context)
                                                  .greyL4,
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
                                ),
                              ),
                            ),
                          ),
                          InkWell(
                            splashColor: Colors.transparent,
                            focusColor: Colors.transparent,
                            hoverColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            onTap: () async {
                              _model.optionChoosed = 'neighbourhood';
                              safeSetState(() {});
                              _model.neighbourhood =
                                  await GetAllSearchCall.call(
                                pSearchText: _model.textController.text,
                                pUserid: currentUserUid,
                                pCommunityid: FFAppState().communityId,
                                token: currentJwtToken,
                                pType: _model.optionChoosed,
                                pCategory: FFAppState().SalesFilter,
                                pSaleType: FFAppState().SalesTypeFilter,
                                pSort: FFAppState().SalesSort,
                                pDistance: FFAppState().SalesKmFilter,
                              );

                              FFAppState().SearchData =
                                  (_model.neighbourhood?.jsonBody ?? '');
                              safeSetState(() {});

                              safeSetState(() {});
                            },
                            child: Container(
                              height: 28.0,
                              decoration: BoxDecoration(
                                color: _model.optionChoosed == 'neighbourhood'
                                    ? FlutterFlowTheme.of(context).greenColor1
                                    : Color(0x00000000),
                                borderRadius: BorderRadius.circular(24.0),
                                border: Border.all(
                                  color: _model.optionChoosed != 'neighbourhood'
                                      ? FlutterFlowTheme.of(context).greyL4
                                      : Color(0x00000000),
                                ),
                              ),
                              child: Align(
                                alignment: AlignmentDirectional(0.0, 0.0),
                                child: Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      16.0, 0.0, 16.0, 0.0),
                                  child: Text(
                                    'People',
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
                                          color: _model.optionChoosed ==
                                                  'neighbourhood'
                                              ? FlutterFlowTheme.of(context)
                                                  .white
                                              : FlutterFlowTheme.of(context)
                                                  .greyL4,
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
                                ),
                              ),
                            ),
                          ),
                          InkWell(
                            splashColor: Colors.transparent,
                            focusColor: Colors.transparent,
                            hoverColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            onTap: () async {
                              _model.optionChoosed = 'business';
                              safeSetState(() {});
                              _model.businessHome = await GetAllSearchCall.call(
                                pSearchText: _model.textController.text,
                                pUserid: currentUserUid,
                                pCommunityid: FFAppState().communityId,
                                token: currentJwtToken,
                                pType: _model.optionChoosed,
                                pCategory: FFAppState().SalesFilter,
                                pSaleType: FFAppState().SalesTypeFilter,
                                pSort: FFAppState().SalesSort,
                                pDistance: FFAppState().SalesKmFilter,
                              );

                              FFAppState().SearchData =
                                  (_model.businessHome?.jsonBody ?? '');
                              safeSetState(() {});

                              safeSetState(() {});
                            },
                            child: Container(
                              height: 28.0,
                              decoration: BoxDecoration(
                                color: _model.optionChoosed == 'business'
                                    ? FlutterFlowTheme.of(context).greenColor1
                                    : Color(0x00000000),
                                borderRadius: BorderRadius.circular(24.0),
                                border: Border.all(
                                  color: _model.optionChoosed != 'business'
                                      ? FlutterFlowTheme.of(context).greyL4
                                      : Color(0x00000000),
                                ),
                              ),
                              child: Align(
                                alignment: AlignmentDirectional(0.0, 0.0),
                                child: Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      16.0, 0.0, 16.0, 0.0),
                                  child: Text(
                                    'Businesses',
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
                                              _model.optionChoosed == 'business'
                                                  ? FlutterFlowTheme.of(context)
                                                      .white
                                                  : FlutterFlowTheme.of(context)
                                                      .greyL4,
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
                                ),
                              ),
                            ),
                          ),
                          InkWell(
                            splashColor: Colors.transparent,
                            focusColor: Colors.transparent,
                            hoverColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            onTap: () async {
                              _model.optionChoosed = 'group';
                              safeSetState(() {});
                              _model.group = await GetAllSearchCall.call(
                                pSearchText: _model.textController.text,
                                pUserid: currentUserUid,
                                pCommunityid: FFAppState().communityId,
                                token: currentJwtToken,
                                pType: _model.optionChoosed,
                                pCategory: FFAppState().SalesFilter,
                                pSaleType: FFAppState().SalesTypeFilter,
                                pSort: FFAppState().SalesSort,
                                pDistance: FFAppState().SalesKmFilter,
                              );

                              FFAppState().SearchData =
                                  (_model.group?.jsonBody ?? '');
                              safeSetState(() {});

                              safeSetState(() {});
                            },
                            child: Container(
                              height: 28.0,
                              decoration: BoxDecoration(
                                color: _model.optionChoosed == 'group'
                                    ? FlutterFlowTheme.of(context).greenColor1
                                    : Color(0x00000000),
                                borderRadius: BorderRadius.circular(24.0),
                                border: Border.all(
                                  color: _model.optionChoosed != 'group'
                                      ? FlutterFlowTheme.of(context).greyL4
                                      : Color(0x00000000),
                                ),
                              ),
                              child: Align(
                                alignment: AlignmentDirectional(0.0, 0.0),
                                child: Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      16.0, 0.0, 16.0, 0.0),
                                  child: Text(
                                    'Groups ',
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
                                          color: _model.optionChoosed == 'group'
                                              ? FlutterFlowTheme.of(context)
                                                  .white
                                              : FlutterFlowTheme.of(context)
                                                  .greyL4,
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
                                ),
                              ),
                            ),
                          ),
                          InkWell(
                            splashColor: Colors.transparent,
                            focusColor: Colors.transparent,
                            hoverColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            onTap: () async {
                              _model.optionChoosed = 'event';
                              safeSetState(() {});
                              _model.event = await GetAllSearchCall.call(
                                pSearchText: _model.textController.text,
                                pUserid: currentUserUid,
                                pCommunityid: FFAppState().communityId,
                                token: currentJwtToken,
                                pType: _model.optionChoosed,
                                pCategory: FFAppState().SalesFilter,
                                pSaleType: FFAppState().SalesTypeFilter,
                                pSort: FFAppState().SalesSort,
                                pDistance: FFAppState().SalesKmFilter,
                              );

                              FFAppState().SearchData =
                                  (_model.event?.jsonBody ?? '');
                              safeSetState(() {});

                              safeSetState(() {});
                            },
                            child: Container(
                              height: 28.0,
                              decoration: BoxDecoration(
                                color: _model.optionChoosed == 'event'
                                    ? FlutterFlowTheme.of(context).greenColor1
                                    : Color(0x00000000),
                                borderRadius: BorderRadius.circular(24.0),
                                border: Border.all(
                                  color: _model.optionChoosed != 'event'
                                      ? FlutterFlowTheme.of(context).greyL4
                                      : Color(0x00000000),
                                ),
                              ),
                              child: Align(
                                alignment: AlignmentDirectional(0.0, 0.0),
                                child: Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      16.0, 0.0, 16.0, 0.0),
                                  child: Text(
                                    'Events',
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
                                          color: _model.optionChoosed == 'event'
                                              ? FlutterFlowTheme.of(context)
                                                  .white
                                              : FlutterFlowTheme.of(context)
                                                  .greyL4,
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
                                ),
                              ),
                            ),
                          ),
                          InkWell(
                            splashColor: Colors.transparent,
                            focusColor: Colors.transparent,
                            hoverColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            onTap: () async {
                              _model.optionChoosed = 'sale';
                              safeSetState(() {});
                              _model.sale = await GetAllSearchCall.call(
                                pSearchText: _model.textController.text,
                                pUserid: currentUserUid,
                                pCommunityid: FFAppState().communityId,
                                token: currentJwtToken,
                                pType: _model.optionChoosed,
                                pCategory: FFAppState().SalesFilter,
                                pSaleType: FFAppState().SalesTypeFilter,
                                pSort: FFAppState().SalesSort,
                                pDistance: FFAppState().SalesKmFilter,
                              );

                              FFAppState().SearchData =
                                  (_model.sale?.jsonBody ?? '');
                              safeSetState(() {});

                              safeSetState(() {});
                            },
                            child: Container(
                              height: 28.0,
                              decoration: BoxDecoration(
                                color: _model.optionChoosed == 'sale'
                                    ? FlutterFlowTheme.of(context).greenColor1
                                    : Color(0x00000000),
                                borderRadius: BorderRadius.circular(24.0),
                                border: Border.all(
                                  color: _model.optionChoosed != 'sale'
                                      ? FlutterFlowTheme.of(context).greyL4
                                      : Color(0x00000000),
                                ),
                              ),
                              child: Align(
                                alignment: AlignmentDirectional(0.0, 0.0),
                                child: Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      16.0, 0.0, 16.0, 0.0),
                                  child: Text(
                                    'For Sales',
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
                                          color: _model.optionChoosed == 'sale'
                                              ? FlutterFlowTheme.of(context)
                                                  .white
                                              : FlutterFlowTheme.of(context)
                                                  .greyL4,
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
                if (_model.optionChoosed == 'sale')
                  Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(0.0, 4.0, 0.0, 0.0),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: FlutterFlowTheme.of(context).secondaryBackground,
                      ),
                      child: Padding(
                        padding:
                            EdgeInsetsDirectional.fromSTEB(0.0, 8.0, 0.0, 8.0),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              InkWell(
                                splashColor: Colors.transparent,
                                focusColor: Colors.transparent,
                                hoverColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                onTap: () async {
                                  await showModalBottomSheet(
                                    isScrollControlled: true,
                                    backgroundColor: Colors.transparent,
                                    useSafeArea: true,
                                    context: context,
                                    builder: (context) {
                                      return GestureDetector(
                                        onTap: () {
                                          FocusScope.of(context).unfocus();
                                          FocusManager.instance.primaryFocus
                                              ?.unfocus();
                                        },
                                        child: Padding(
                                          padding:
                                              MediaQuery.viewInsetsOf(context),
                                          child: CompCategoryFilterWidget(
                                            pageType: 'search',
                                            searhText:
                                                _model.textController.text,
                                          ),
                                        ),
                                      );
                                    },
                                  ).then((value) => safeSetState(() {}));
                                },
                                child: Container(
                                  height: 36.0,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(24.0),
                                    border: Border.all(
                                      color:
                                          FlutterFlowTheme.of(context).greyL4,
                                    ),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        24.0, 0.0, 24.0, 0.0),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Align(
                                          alignment:
                                              AlignmentDirectional(0.0, 0.0),
                                          child: Text(
                                            FFAppState().SalesFilter,
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
                                                      .greyL4,
                                                  letterSpacing: 0.0,
                                                  fontWeight: FontWeight.w600,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMedium
                                                          .fontStyle,
                                                  lineHeight: 1.0,
                                                ),
                                          ),
                                        ),
                                        Icon(
                                          Icons.arrow_drop_down_sharp,
                                          color: FlutterFlowTheme.of(context)
                                              .greyL4,
                                          size: 20.0,
                                        ),
                                      ].divide(SizedBox(width: 6.0)),
                                    ),
                                  ),
                                ),
                              ),
                              InkWell(
                                splashColor: Colors.transparent,
                                focusColor: Colors.transparent,
                                hoverColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                onTap: () async {
                                  if (FFAppState().SalesTypeFilter == 'Fixed') {
                                    FFAppState().SalesTypeFilter = 'Free';
                                    safeSetState(() {});
                                  } else {
                                    FFAppState().SalesTypeFilter = 'Fixed';
                                    safeSetState(() {});
                                  }

                                  _model.priceFilter =
                                      await GetAllSearchCall.call(
                                    pSearchText: _model.textController.text,
                                    pUserid: currentUserUid,
                                    pCommunityid: FFAppState().communityId,
                                    token: currentJwtToken,
                                    pType: _model.optionChoosed,
                                    pCategory: FFAppState().SalesFilter,
                                    pSaleType: FFAppState().SalesTypeFilter,
                                    pSort: FFAppState().SalesSort,
                                    pDistance: FFAppState().SalesKmFilter,
                                  );

                                  if ((_model.priceFilter?.succeeded ?? true)) {
                                    FFAppState().SearchData =
                                        (_model.priceFilter?.jsonBody ?? '');
                                    safeSetState(() {});
                                  }

                                  safeSetState(() {});
                                },
                                child: Container(
                                  height: 36.0,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(24.0),
                                    border: Border.all(
                                      color: FFAppState().SalesTypeFilter ==
                                              'Fixed'
                                          ? FlutterFlowTheme.of(context).greyL4
                                          : FlutterFlowTheme.of(context)
                                              .extraBlack,
                                    ),
                                  ),
                                  child: Align(
                                    alignment: AlignmentDirectional(0.0, 0.0),
                                    child: Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          24.0, 0.0, 24.0, 0.0),
                                      child: Text(
                                        'Free',
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
                                              color: FFAppState()
                                                          .SalesTypeFilter ==
                                                      'Free'
                                                  ? FlutterFlowTheme.of(context)
                                                      .extraBlack
                                                  : FlutterFlowTheme.of(context)
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
                                    ),
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
                                          padding:
                                              MediaQuery.viewInsetsOf(context),
                                          child: CompKmsFilterWidget(
                                            pageType: 'search',
                                          ),
                                        ),
                                      );
                                    },
                                  ).then((value) => safeSetState(() {}));
                                },
                                child: Container(
                                  height: 36.0,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(24.0),
                                    border: Border.all(
                                      color:
                                          FlutterFlowTheme.of(context).greyL4,
                                    ),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        24.0, 0.0, 24.0, 0.0),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Align(
                                          alignment:
                                              AlignmentDirectional(0.0, 0.0),
                                          child: Text(
                                            'Distance ${FFAppState().SalesKmFilter.toString()}Km',
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
                                                      .greyL4,
                                                  letterSpacing: 0.0,
                                                  fontWeight: FontWeight.w600,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMedium
                                                          .fontStyle,
                                                  lineHeight: 1.0,
                                                ),
                                          ),
                                        ),
                                        Icon(
                                          Icons.arrow_drop_down_sharp,
                                          color: FlutterFlowTheme.of(context)
                                              .greyL4,
                                          size: 20.0,
                                        ),
                                      ].divide(SizedBox(width: 6.0)),
                                    ),
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
                                          padding:
                                              MediaQuery.viewInsetsOf(context),
                                          child: CompSalesSortWidget(
                                            pageType: 'search',
                                          ),
                                        ),
                                      );
                                    },
                                  ).then((value) => safeSetState(() {}));
                                },
                                child: Container(
                                  height: 36.0,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(24.0),
                                    border: Border.all(
                                      color:
                                          FlutterFlowTheme.of(context).greyL4,
                                    ),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        24.0, 0.0, 24.0, 0.0),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Align(
                                          alignment:
                                              AlignmentDirectional(0.0, 0.0),
                                          child: Text(
                                            'SortBy',
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
                                                      .greyL4,
                                                  letterSpacing: 0.0,
                                                  fontWeight: FontWeight.w600,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMedium
                                                          .fontStyle,
                                                  lineHeight: 1.0,
                                                ),
                                          ),
                                        ),
                                        Icon(
                                          Icons.arrow_drop_down_sharp,
                                          color: FlutterFlowTheme.of(context)
                                              .greyL4,
                                          size: 20.0,
                                        ),
                                      ].divide(SizedBox(width: 6.0)),
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
                  ),
                if (_model.showData)
                  Expanded(
                    child: Padding(
                      padding:
                          EdgeInsetsDirectional.fromSTEB(0.0, 4.0, 0.0, 0.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (_model.optionChoosed == 'all')
                            Expanded(
                              child: SingleChildScrollView(
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    if (((String var1) {
                                          return var1 != "null";
                                        }(getJsonField(
                                          FFAppState().SearchData,
                                          r'''$.groups''',
                                        ).toString())) ==
                                        true)
                                      Container(
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          color: FlutterFlowTheme.of(context)
                                              .white,
                                        ),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.max,
                                          children: [
                                            Container(
                                              width: double.infinity,
                                              decoration: BoxDecoration(),
                                              alignment: AlignmentDirectional(
                                                  0.0, 0.0),
                                              child: Padding(
                                                padding: EdgeInsetsDirectional
                                                    .fromSTEB(
                                                        0.0, 12.0, 0.0, 8.0),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        'Groups',
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
                                                              color: FlutterFlowTheme
                                                                      .of(context)
                                                                  .extraBlack,
                                                              fontSize: 18.0,
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
                                                    InkWell(
                                                      splashColor:
                                                          Colors.transparent,
                                                      focusColor:
                                                          Colors.transparent,
                                                      hoverColor:
                                                          Colors.transparent,
                                                      highlightColor:
                                                          Colors.transparent,
                                                      onTap: () async {
                                                        _model.goToGroup =
                                                            await GetAllSearchCall
                                                                .call(
                                                          pSearchText: _model
                                                              .textController
                                                              .text,
                                                          pUserid:
                                                              currentUserUid,
                                                          pCommunityid:
                                                              FFAppState()
                                                                  .communityId,
                                                          token:
                                                              currentJwtToken,
                                                          pType: _model
                                                              .optionChoosed,
                                                          pCategory:
                                                              FFAppState()
                                                                  .SalesFilter,
                                                          pSaleType: FFAppState()
                                                              .SalesTypeFilter,
                                                          pSort: FFAppState()
                                                              .SalesSort,
                                                          pDistance: FFAppState()
                                                              .SalesKmFilter,
                                                        );

                                                        if ((_model.goToGroup
                                                                ?.succeeded ??
                                                            true)) {
                                                          FFAppState()
                                                              .SearchData = (_model
                                                                  .goToGroup
                                                                  ?.jsonBody ??
                                                              '');
                                                          safeSetState(() {});
                                                        }
                                                        _model.optionChoosed =
                                                            'group';
                                                        safeSetState(() {});

                                                        safeSetState(() {});
                                                      },
                                                      child: Icon(
                                                        Icons.arrow_forward,
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .primaryText,
                                                        size: 24.0,
                                                      ),
                                                    ),
                                                  ]
                                                      .addToStart(
                                                          SizedBox(width: 20.0))
                                                      .addToEnd(SizedBox(
                                                          width: 20.0)),
                                                ),
                                              ),
                                            ),
                                            Divider(
                                              height: 0.0,
                                              thickness: 2.0,
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .alternate,
                                            ),
                                            Padding(
                                              padding: EdgeInsetsDirectional
                                                  .fromSTEB(
                                                      0.0, 12.0, 0.0, 0.0),
                                              child: Builder(
                                                builder: (context) {
                                                  final groups = getJsonField(
                                                    FFAppState().SearchData,
                                                    r'''$.groups''',
                                                  ).toList();

                                                  return ListView.separated(
                                                    padding:
                                                        EdgeInsets.fromLTRB(
                                                      0,
                                                      12.0,
                                                      0,
                                                      12.0,
                                                    ),
                                                    primary: false,
                                                    shrinkWrap: true,
                                                    scrollDirection:
                                                        Axis.vertical,
                                                    itemCount: groups.length,
                                                    separatorBuilder: (_, __) =>
                                                        SizedBox(height: 12.0),
                                                    itemBuilder:
                                                        (context, groupsIndex) {
                                                      final groupsItem =
                                                          groups[groupsIndex];
                                                      return FutureBuilder<
                                                          ApiCallResponse>(
                                                        future:
                                                            SpecificGroupCall
                                                                .call(
                                                          apiKey:
                                                              FFDevEnvironmentValues()
                                                                  .AnonKey,
                                                          token:
                                                              currentJwtToken,
                                                          pGroupId:
                                                              getJsonField(
                                                            groupsItem,
                                                            r'''$.id''',
                                                          ).toString(),
                                                        ),
                                                        builder: (context,
                                                            snapshot) {
                                                          // Customize what your widget looks like when it's loading.
                                                          if (!snapshot
                                                              .hasData) {
                                                            return CompLoadingWidget(
                                                              name: 'group',
                                                            );
                                                          }
                                                          final containerSpecificGroupResponse =
                                                              snapshot.data!;

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
                                                              context.pushNamed(
                                                                GroupDetailsWidget
                                                                    .routeName,
                                                                queryParameters:
                                                                    {
                                                                  'groupId':
                                                                      serializeParam(
                                                                    getJsonField(
                                                                      groupsItem,
                                                                      r'''$.group_id''',
                                                                    ).toString(),
                                                                    ParamType
                                                                        .String,
                                                                  ),
                                                                }.withoutNulls,
                                                              );
                                                            },
                                                            child: Container(
                                                              width: double
                                                                  .infinity,
                                                              height: 56.0,
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .secondaryBackground,
                                                              ),
                                                              child: Padding(
                                                                padding: EdgeInsetsDirectional
                                                                    .fromSTEB(
                                                                        20.0,
                                                                        8.0,
                                                                        20.0,
                                                                        8.0),
                                                                child: Row(
                                                                  mainAxisSize:
                                                                      MainAxisSize
                                                                          .max,
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceBetween,
                                                                  children: [
                                                                    Expanded(
                                                                      child:
                                                                          Row(
                                                                        mainAxisSize:
                                                                            MainAxisSize.max,
                                                                        children:
                                                                            [
                                                                          ClipRRect(
                                                                            borderRadius:
                                                                                BorderRadius.circular(2.0),
                                                                            child:
                                                                                Image.network(
                                                                              SpecificGroupCall.profilepicture(
                                                                                containerSpecificGroupResponse.jsonBody,
                                                                              )!,
                                                                              width: 40.0,
                                                                              height: 40.0,
                                                                              fit: BoxFit.cover,
                                                                            ),
                                                                          ),
                                                                          Expanded(
                                                                            child:
                                                                                Column(
                                                                              mainAxisSize: MainAxisSize.max,
                                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                                              children: [
                                                                                if (('${getJsonField(
                                                                                          containerSpecificGroupResponse.jsonBody,
                                                                                          r'''$[:].invited_by_user_id''',
                                                                                        ).toString()}' !=
                                                                                        'null') &&
                                                                                    ('${getJsonField(
                                                                                          containerSpecificGroupResponse.jsonBody,
                                                                                          r'''$[:].user_status''',
                                                                                        ).toString()}' ==
                                                                                        'invite'))
                                                                                  Row(
                                                                                    mainAxisSize: MainAxisSize.max,
                                                                                    children: [
                                                                                      Container(
                                                                                        width: 12.0,
                                                                                        height: 12.0,
                                                                                        clipBehavior: Clip.antiAlias,
                                                                                        decoration: BoxDecoration(
                                                                                          shape: BoxShape.circle,
                                                                                        ),
                                                                                        child: Image.network(
                                                                                          getJsonField(
                                                                                            containerSpecificGroupResponse.jsonBody,
                                                                                            r'''$[:].invited_by_profile_picture''',
                                                                                          ).toString(),
                                                                                          fit: BoxFit.cover,
                                                                                        ),
                                                                                      ),
                                                                                      Expanded(
                                                                                        child: Text(
                                                                                          '${getJsonField(
                                                                                            containerSpecificGroupResponse.jsonBody,
                                                                                            r'''$[:].invited_by_name''',
                                                                                          ).toString()} invited you to join this group ',
                                                                                          maxLines: 1,
                                                                                          style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                                font: GoogleFonts.manrope(
                                                                                                  fontWeight: FontWeight.w500,
                                                                                                  fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                ),
                                                                                                color: FlutterFlowTheme.of(context).greyL4,
                                                                                                fontSize: 10.0,
                                                                                                letterSpacing: 0.0,
                                                                                                fontWeight: FontWeight.w500,
                                                                                                fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                lineHeight: 1.4,
                                                                                              ),
                                                                                        ),
                                                                                      ),
                                                                                    ].divide(SizedBox(width: 6.0)),
                                                                                  ),
                                                                                Text(
                                                                                  getJsonField(
                                                                                    containerSpecificGroupResponse.jsonBody,
                                                                                    r'''$[:].name''',
                                                                                  ).toString(),
                                                                                  maxLines: 1,
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
                                                                                if ('${getJsonField(
                                                                                      containerSpecificGroupResponse.jsonBody,
                                                                                      r'''$[:].user_status''',
                                                                                    ).toString()}' !=
                                                                                    'invite')
                                                                                  Text(
                                                                                    '${getJsonField(
                                                                                      containerSpecificGroupResponse.jsonBody,
                                                                                      r'''$[:].total_members''',
                                                                                    ).toString()} ${'${getJsonField(
                                                                                          containerSpecificGroupResponse.jsonBody,
                                                                                          r'''$[:].total_members''',
                                                                                        ).toString()}' == '1' ? 'member' : 'members'}',
                                                                                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                          font: GoogleFonts.manrope(
                                                                                            fontWeight: FontWeight.w500,
                                                                                            fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                          ),
                                                                                          color: FlutterFlowTheme.of(context).greyL4,
                                                                                          fontSize: 10.0,
                                                                                          letterSpacing: 0.0,
                                                                                          fontWeight: FontWeight.w500,
                                                                                          fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                          lineHeight: 1.4,
                                                                                        ),
                                                                                  ),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                        ].divide(SizedBox(width: 8.0)),
                                                                      ),
                                                                    ),
                                                                    Stack(
                                                                      children: [
                                                                        if ('${getJsonField(
                                                                              containerSpecificGroupResponse.jsonBody,
                                                                              r'''$[:].user_status''',
                                                                            ).toString()}' ==
                                                                            'join')
                                                                          FFButtonWidget(
                                                                            onPressed:
                                                                                () async {
                                                                              await GroupMembersTable().insert({
                                                                                'community_id': FFAppState().communityId,
                                                                                'user_id': currentUserUid,
                                                                                'group_id': getJsonField(
                                                                                  containerSpecificGroupResponse.jsonBody,
                                                                                  r'''$[:].group_id''',
                                                                                ).toString(),
                                                                                'is_requested': false,
                                                                                'requested_date': supaSerialize<DateTime>(functions.getCurrentUtcTime()),
                                                                                'is_approved': true,
                                                                                'approved_by': currentUserUid,
                                                                                'joined_at': supaSerialize<DateTime>(functions.getCurrentUtcTime()),
                                                                              });
                                                                              await GroupUserStatusTable().insert({
                                                                                'community_id': FFAppState().communityId,
                                                                                'user_id': currentUserUid,
                                                                                'group_id': getJsonField(
                                                                                  containerSpecificGroupResponse.jsonBody,
                                                                                  r'''$[:].group_id''',
                                                                                ).toString(),
                                                                                'is_requested': false,
                                                                                'is_invited': false,
                                                                                'is_member': true,
                                                                                'joined_at': supaSerialize<DateTime>(functions.getCurrentUtcTime()),
                                                                              });
                                                                              _model.apiResultd2p5 = await UpdateTotalGroupMembersCall.call(
                                                                                token: currentJwtToken,
                                                                                anonKey: FFDevEnvironmentValues().AnonKey,
                                                                                groupId: getJsonField(
                                                                                  containerSpecificGroupResponse.jsonBody,
                                                                                  r'''$[:].group_id''',
                                                                                ).toString(),
                                                                              );

                                                                              if ((String var1) {
                                                                                return var1.length >= 3;
                                                                              }(_model.textController.text)) {
                                                                                _model.searchEmpty = false;
                                                                                safeSetState(() {});
                                                                                _model.apiResulth6ntt = await GetAllSearchCall.call(
                                                                                  pSearchText: _model.textController.text,
                                                                                  pUserid: currentUserUid,
                                                                                  pCommunityid: FFAppState().communityId,
                                                                                  token: currentJwtToken,
                                                                                  pType: _model.optionChoosed,
                                                                                  pCategory: FFAppState().SalesFilter,
                                                                                  pSaleType: FFAppState().SalesTypeFilter,
                                                                                  pSort: FFAppState().SalesSort,
                                                                                  pDistance: FFAppState().SalesKmFilter,
                                                                                );

                                                                                if ((_model.apiResulth6n?.succeeded ?? true)) {
                                                                                  FFAppState().SearchData = (_model.apiResulth6n?.jsonBody ?? '');
                                                                                  safeSetState(() {});
                                                                                }
                                                                              } else {
                                                                                if (_model.textController.text.length == 0) {
                                                                                  _model.searchEmpty = true;
                                                                                  safeSetState(() {});
                                                                                } else {
                                                                                  _model.searchEmpty = false;
                                                                                  safeSetState(() {});
                                                                                }
                                                                              }

                                                                              safeSetState(() {});
                                                                            },
                                                                            text:
                                                                                'Join',
                                                                            options:
                                                                                FFButtonOptions(
                                                                              height: 24.0,
                                                                              padding: EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                                                                              iconPadding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                                                                              color: Color(0x00264AFF),
                                                                              textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                                                                                    font: GoogleFonts.interTight(
                                                                                      fontWeight: FlutterFlowTheme.of(context).titleSmall.fontWeight,
                                                                                      fontStyle: FlutterFlowTheme.of(context).titleSmall.fontStyle,
                                                                                    ),
                                                                                    color: FlutterFlowTheme.of(context).primaryD3,
                                                                                    fontSize: 12.0,
                                                                                    letterSpacing: 0.0,
                                                                                    fontWeight: FlutterFlowTheme.of(context).titleSmall.fontWeight,
                                                                                    fontStyle: FlutterFlowTheme.of(context).titleSmall.fontStyle,
                                                                                  ),
                                                                              elevation: 0.0,
                                                                              borderSide: BorderSide(
                                                                                color: FlutterFlowTheme.of(context).primaryD3,
                                                                                width: 1.0,
                                                                              ),
                                                                              borderRadius: BorderRadius.only(
                                                                                topLeft: Radius.circular(100.0),
                                                                                topRight: Radius.circular(100.0),
                                                                                bottomLeft: Radius.circular(100.0),
                                                                                bottomRight: Radius.circular(100.0),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        if ('${getJsonField(
                                                                              containerSpecificGroupResponse.jsonBody,
                                                                              r'''$[:].user_status''',
                                                                            ).toString()}' ==
                                                                            'joined')
                                                                          FFButtonWidget(
                                                                            onPressed:
                                                                                () {
                                                                              print('Joined pressed ...');
                                                                            },
                                                                            text:
                                                                                'Joined',
                                                                            icon:
                                                                                Icon(
                                                                              Icons.done_all,
                                                                              size: 15.0,
                                                                            ),
                                                                            options:
                                                                                FFButtonOptions(
                                                                              height: 24.0,
                                                                              padding: EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                                                                              iconPadding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                                                                              iconColor: FlutterFlowTheme.of(context).greyL4,
                                                                              color: Color(0x00264AFF),
                                                                              textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                                                                                    font: GoogleFonts.interTight(
                                                                                      fontWeight: FlutterFlowTheme.of(context).titleSmall.fontWeight,
                                                                                      fontStyle: FlutterFlowTheme.of(context).titleSmall.fontStyle,
                                                                                    ),
                                                                                    color: FlutterFlowTheme.of(context).greyL4,
                                                                                    fontSize: 12.0,
                                                                                    letterSpacing: 0.0,
                                                                                    fontWeight: FlutterFlowTheme.of(context).titleSmall.fontWeight,
                                                                                    fontStyle: FlutterFlowTheme.of(context).titleSmall.fontStyle,
                                                                                  ),
                                                                              elevation: 0.0,
                                                                              borderSide: BorderSide(
                                                                                color: FlutterFlowTheme.of(context).greyL4,
                                                                                width: 1.0,
                                                                              ),
                                                                              borderRadius: BorderRadius.only(
                                                                                topLeft: Radius.circular(100.0),
                                                                                topRight: Radius.circular(100.0),
                                                                                bottomLeft: Radius.circular(100.0),
                                                                                bottomRight: Radius.circular(100.0),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        if ('${getJsonField(
                                                                              containerSpecificGroupResponse.jsonBody,
                                                                              r'''$[:].user_status''',
                                                                            ).toString()}' ==
                                                                            'requested')
                                                                          FFButtonWidget(
                                                                            onPressed:
                                                                                () {
                                                                              print('Requested pressed ...');
                                                                            },
                                                                            text:
                                                                                'Requested',
                                                                            options:
                                                                                FFButtonOptions(
                                                                              height: 24.0,
                                                                              padding: EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                                                                              iconPadding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                                                                              color: FlutterFlowTheme.of(context).greyL2,
                                                                              textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                                                                                    font: GoogleFonts.interTight(
                                                                                      fontWeight: FlutterFlowTheme.of(context).titleSmall.fontWeight,
                                                                                      fontStyle: FlutterFlowTheme.of(context).titleSmall.fontStyle,
                                                                                    ),
                                                                                    color: FlutterFlowTheme.of(context).greyL3,
                                                                                    fontSize: 12.0,
                                                                                    letterSpacing: 0.0,
                                                                                    fontWeight: FlutterFlowTheme.of(context).titleSmall.fontWeight,
                                                                                    fontStyle: FlutterFlowTheme.of(context).titleSmall.fontStyle,
                                                                                  ),
                                                                              elevation: 0.0,
                                                                              borderRadius: BorderRadius.only(
                                                                                topLeft: Radius.circular(100.0),
                                                                                topRight: Radius.circular(100.0),
                                                                                bottomLeft: Radius.circular(100.0),
                                                                                bottomRight: Radius.circular(100.0),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        if ('${getJsonField(
                                                                              containerSpecificGroupResponse.jsonBody,
                                                                              r'''$[:].user_status''',
                                                                            ).toString()}' ==
                                                                            'request')
                                                                          FFButtonWidget(
                                                                            onPressed:
                                                                                () async {
                                                                              await GroupUserStatusTable().insert({
                                                                                'community_id': FFAppState().communityId,
                                                                                'user_id': currentUserUid,
                                                                                'group_id': getJsonField(
                                                                                  containerSpecificGroupResponse.jsonBody,
                                                                                  r'''$[:].group_id''',
                                                                                ).toString(),
                                                                                'is_requested': true,
                                                                                'is_invited': false,
                                                                                'is_member': false,
                                                                                'is_approved': false,
                                                                                'requested_date': supaSerialize<DateTime>(functions.getCurrentUtcTime()),
                                                                              });
                                                                              if ((String var1) {
                                                                                return var1.length >= 3;
                                                                              }(_model.textController.text)) {
                                                                                _model.searchEmpty = false;
                                                                                safeSetState(() {});
                                                                                _model.apiResulth6nttdsfdfcxf = await GetAllSearchCall.call(
                                                                                  pSearchText: _model.textController.text,
                                                                                  pUserid: currentUserUid,
                                                                                  pCommunityid: FFAppState().communityId,
                                                                                  token: currentJwtToken,
                                                                                  pType: _model.optionChoosed,
                                                                                  pCategory: FFAppState().SalesFilter,
                                                                                  pSaleType: FFAppState().SalesTypeFilter,
                                                                                  pSort: FFAppState().SalesSort,
                                                                                  pDistance: FFAppState().SalesKmFilter,
                                                                                );

                                                                                if ((_model.apiResulth6n?.succeeded ?? true)) {
                                                                                  FFAppState().SearchData = (_model.apiResulth6n?.jsonBody ?? '');
                                                                                  safeSetState(() {});
                                                                                }
                                                                              } else {
                                                                                if (_model.textController.text.length == 0) {
                                                                                  _model.searchEmpty = true;
                                                                                  safeSetState(() {});
                                                                                } else {
                                                                                  _model.searchEmpty = false;
                                                                                  safeSetState(() {});
                                                                                }
                                                                              }

                                                                              safeSetState(() {});
                                                                            },
                                                                            text:
                                                                                'Request',
                                                                            icon:
                                                                                Icon(
                                                                              Icons.lock_outline_sharp,
                                                                              size: 15.0,
                                                                            ),
                                                                            options:
                                                                                FFButtonOptions(
                                                                              height: 24.0,
                                                                              padding: EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                                                                              iconPadding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                                                                              iconColor: FlutterFlowTheme.of(context).primaryD3,
                                                                              color: Color(0x00264AFF),
                                                                              textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                                                                                    font: GoogleFonts.interTight(
                                                                                      fontWeight: FlutterFlowTheme.of(context).titleSmall.fontWeight,
                                                                                      fontStyle: FlutterFlowTheme.of(context).titleSmall.fontStyle,
                                                                                    ),
                                                                                    color: FlutterFlowTheme.of(context).primaryD3,
                                                                                    fontSize: 12.0,
                                                                                    letterSpacing: 0.0,
                                                                                    fontWeight: FlutterFlowTheme.of(context).titleSmall.fontWeight,
                                                                                    fontStyle: FlutterFlowTheme.of(context).titleSmall.fontStyle,
                                                                                  ),
                                                                              elevation: 0.0,
                                                                              borderSide: BorderSide(
                                                                                color: FlutterFlowTheme.of(context).primaryD3,
                                                                                width: 1.0,
                                                                              ),
                                                                              borderRadius: BorderRadius.only(
                                                                                topLeft: Radius.circular(100.0),
                                                                                topRight: Radius.circular(100.0),
                                                                                bottomLeft: Radius.circular(100.0),
                                                                                bottomRight: Radius.circular(100.0),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        if ('${getJsonField(
                                                                              containerSpecificGroupResponse.jsonBody,
                                                                              r'''$[:].user_status''',
                                                                            ).toString()}' ==
                                                                            'admin')
                                                                          FFButtonWidget(
                                                                            onPressed:
                                                                                () {
                                                                              print('Button pressed ...');
                                                                            },
                                                                            text:
                                                                                'Admin',
                                                                            options:
                                                                                FFButtonOptions(
                                                                              height: 24.0,
                                                                              padding: EdgeInsetsDirectional.fromSTEB(12.0, 0.0, 12.0, 0.0),
                                                                              iconPadding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                                                                              color: Color(0xFF23B3A6),
                                                                              textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                                                                                    font: GoogleFonts.interTight(
                                                                                      fontWeight: FlutterFlowTheme.of(context).titleSmall.fontWeight,
                                                                                      fontStyle: FlutterFlowTheme.of(context).titleSmall.fontStyle,
                                                                                    ),
                                                                                    color: Colors.white,
                                                                                    fontSize: 12.0,
                                                                                    letterSpacing: 0.0,
                                                                                    fontWeight: FlutterFlowTheme.of(context).titleSmall.fontWeight,
                                                                                    fontStyle: FlutterFlowTheme.of(context).titleSmall.fontStyle,
                                                                                  ),
                                                                              elevation: 0.0,
                                                                              borderRadius: BorderRadius.only(
                                                                                topLeft: Radius.circular(100.0),
                                                                                topRight: Radius.circular(100.0),
                                                                                bottomLeft: Radius.circular(100.0),
                                                                                bottomRight: Radius.circular(100.0),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        if (('${getJsonField(
                                                                                  containerSpecificGroupResponse.jsonBody,
                                                                                  r'''$[:].user_status''',
                                                                                ).toString()}' ==
                                                                                'invite') &&
                                                                            ('${getJsonField(
                                                                                  containerSpecificGroupResponse.jsonBody,
                                                                                  r'''$[:].e_group_type''',
                                                                                ).toString()}' ==
                                                                                'open'))
                                                                          FFButtonWidget(
                                                                            onPressed:
                                                                                () async {
                                                                              await GroupMembersTable().insert({
                                                                                'community_id': FFAppState().communityId,
                                                                                'user_id': currentUserUid,
                                                                                'group_id': getJsonField(
                                                                                  containerSpecificGroupResponse.jsonBody,
                                                                                  r'''$[:].group_id''',
                                                                                ).toString(),
                                                                                'is_requested': false,
                                                                                'is_approved': true,
                                                                                'approved_by': getJsonField(
                                                                                  containerSpecificGroupResponse.jsonBody,
                                                                                  r'''$[:].invited_by_user_id''',
                                                                                ).toString(),
                                                                                'joined_at': supaSerialize<DateTime>(functions.getCurrentUtcTime()),
                                                                              });
                                                                              await GroupUserStatusTable().insert({
                                                                                'community_id': FFAppState().communityId,
                                                                                'user_id': currentUserUid,
                                                                                'group_id': getJsonField(
                                                                                  containerSpecificGroupResponse.jsonBody,
                                                                                  r'''$[:].group_id''',
                                                                                ).toString(),
                                                                                'is_requested': false,
                                                                                'is_invited': true,
                                                                                'is_member': true,
                                                                                'joined_at': supaSerialize<DateTime>(functions.getCurrentUtcTime()),
                                                                                'is_approved': true,
                                                                                'invited_by': getJsonField(
                                                                                  containerSpecificGroupResponse.jsonBody,
                                                                                  r'''$[:].invited_by_user_id''',
                                                                                ).toString(),
                                                                              });
                                                                              await GroupMembersInviteTable().update(
                                                                                data: {
                                                                                  'is_member': true,
                                                                                },
                                                                                matchingRows: (rows) => rows
                                                                                    .eqOrNull(
                                                                                      'group_id',
                                                                                      getJsonField(
                                                                                        containerSpecificGroupResponse.jsonBody,
                                                                                        r'''$[:].group_id''',
                                                                                      ).toString(),
                                                                                    )
                                                                                    .eqOrNull(
                                                                                      'invited_by',
                                                                                      getJsonField(
                                                                                        containerSpecificGroupResponse.jsonBody,
                                                                                        r'''$[:].invited_by_user_id''',
                                                                                      ).toString(),
                                                                                    )
                                                                                    .eqOrNull(
                                                                                      'invited_user',
                                                                                      currentUserUid,
                                                                                    ),
                                                                              );
                                                                              _model.apiResultd2pp23zxz = await UpdateTotalGroupMembersCall.call(
                                                                                token: currentJwtToken,
                                                                                anonKey: FFDevEnvironmentValues().AnonKey,
                                                                                groupId: getJsonField(
                                                                                  containerSpecificGroupResponse.jsonBody,
                                                                                  r'''$[:].group_id''',
                                                                                ).toString(),
                                                                              );

                                                                              if ((String var1) {
                                                                                return var1.length >= 3;
                                                                              }(_model.textController.text)) {
                                                                                _model.searchEmpty = false;
                                                                                safeSetState(() {});
                                                                                _model.apiResulth6nttcvvcvv = await GetAllSearchCall.call(
                                                                                  pSearchText: _model.textController.text,
                                                                                  pUserid: currentUserUid,
                                                                                  pCommunityid: FFAppState().communityId,
                                                                                  token: currentJwtToken,
                                                                                  pType: _model.optionChoosed,
                                                                                  pCategory: FFAppState().SalesFilter,
                                                                                  pSaleType: FFAppState().SalesTypeFilter,
                                                                                  pSort: FFAppState().SalesSort,
                                                                                  pDistance: FFAppState().SalesKmFilter,
                                                                                );

                                                                                if ((_model.apiResulth6n?.succeeded ?? true)) {
                                                                                  FFAppState().SearchData = (_model.apiResulth6n?.jsonBody ?? '');
                                                                                  safeSetState(() {});
                                                                                }
                                                                              } else {
                                                                                if (_model.textController.text.length == 0) {
                                                                                  _model.searchEmpty = true;
                                                                                  safeSetState(() {});
                                                                                } else {
                                                                                  _model.searchEmpty = false;
                                                                                  safeSetState(() {});
                                                                                }
                                                                              }

                                                                              safeSetState(() {});
                                                                            },
                                                                            text:
                                                                                'Join',
                                                                            options:
                                                                                FFButtonOptions(
                                                                              height: 24.0,
                                                                              padding: EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                                                                              iconPadding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                                                                              color: Color(0x00264AFF),
                                                                              textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                                                                                    font: GoogleFonts.interTight(
                                                                                      fontWeight: FlutterFlowTheme.of(context).titleSmall.fontWeight,
                                                                                      fontStyle: FlutterFlowTheme.of(context).titleSmall.fontStyle,
                                                                                    ),
                                                                                    color: FlutterFlowTheme.of(context).primaryD3,
                                                                                    fontSize: 12.0,
                                                                                    letterSpacing: 0.0,
                                                                                    fontWeight: FlutterFlowTheme.of(context).titleSmall.fontWeight,
                                                                                    fontStyle: FlutterFlowTheme.of(context).titleSmall.fontStyle,
                                                                                  ),
                                                                              elevation: 0.0,
                                                                              borderSide: BorderSide(
                                                                                color: FlutterFlowTheme.of(context).primaryD3,
                                                                                width: 1.0,
                                                                              ),
                                                                              borderRadius: BorderRadius.only(
                                                                                topLeft: Radius.circular(100.0),
                                                                                topRight: Radius.circular(100.0),
                                                                                bottomLeft: Radius.circular(100.0),
                                                                                bottomRight: Radius.circular(100.0),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        if (('${getJsonField(
                                                                                  containerSpecificGroupResponse.jsonBody,
                                                                                  r'''$[:].user_status''',
                                                                                ).toString()}' ==
                                                                                'invite') &&
                                                                            ('${getJsonField(
                                                                                  containerSpecificGroupResponse.jsonBody,
                                                                                  r'''$[:].e_group_type''',
                                                                                ).toString()}' ==
                                                                                'private'))
                                                                          FFButtonWidget(
                                                                            onPressed:
                                                                                () async {
                                                                              await GroupUserStatusTable().update(
                                                                                data: {
                                                                                  'is_requested': true,
                                                                                  'requested_date': supaSerialize<DateTime>(functions.getCurrentUtcTime()),
                                                                                },
                                                                                matchingRows: (rows) => rows
                                                                                    .eqOrNull(
                                                                                      'group_id',
                                                                                      getJsonField(
                                                                                        containerSpecificGroupResponse.jsonBody,
                                                                                        r'''$[:].group_id''',
                                                                                      ).toString(),
                                                                                    )
                                                                                    .eqOrNull(
                                                                                      'user_id',
                                                                                      currentUserUid,
                                                                                    )
                                                                                    .eqOrNull(
                                                                                      'invited_by',
                                                                                      getJsonField(
                                                                                        containerSpecificGroupResponse.jsonBody,
                                                                                        r'''$[:].invited_by_user_id''',
                                                                                      ).toString(),
                                                                                    ),
                                                                              );
                                                                              if ((String var1) {
                                                                                return var1.length >= 3;
                                                                              }(_model.textController.text)) {
                                                                                _model.searchEmpty = false;
                                                                                safeSetState(() {});
                                                                                _model.apiResulth6nttff = await GetAllSearchCall.call(
                                                                                  pSearchText: _model.textController.text,
                                                                                  pUserid: currentUserUid,
                                                                                  pCommunityid: FFAppState().communityId,
                                                                                  token: currentJwtToken,
                                                                                  pType: _model.optionChoosed,
                                                                                  pCategory: FFAppState().SalesFilter,
                                                                                  pSaleType: FFAppState().SalesTypeFilter,
                                                                                  pSort: FFAppState().SalesSort,
                                                                                  pDistance: FFAppState().SalesKmFilter,
                                                                                );

                                                                                if ((_model.apiResulth6n?.succeeded ?? true)) {
                                                                                  FFAppState().SearchData = (_model.apiResulth6n?.jsonBody ?? '');
                                                                                  safeSetState(() {});
                                                                                }
                                                                              } else {
                                                                                if (_model.textController.text.length == 0) {
                                                                                  _model.searchEmpty = true;
                                                                                  safeSetState(() {});
                                                                                } else {
                                                                                  _model.searchEmpty = false;
                                                                                  safeSetState(() {});
                                                                                }
                                                                              }

                                                                              safeSetState(() {});
                                                                            },
                                                                            text:
                                                                                'Request',
                                                                            icon:
                                                                                Icon(
                                                                              Icons.lock_outline_sharp,
                                                                              size: 15.0,
                                                                            ),
                                                                            options:
                                                                                FFButtonOptions(
                                                                              height: 24.0,
                                                                              padding: EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                                                                              iconPadding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                                                                              iconColor: FlutterFlowTheme.of(context).primaryD3,
                                                                              color: Color(0x00264AFF),
                                                                              textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                                                                                    font: GoogleFonts.interTight(
                                                                                      fontWeight: FlutterFlowTheme.of(context).titleSmall.fontWeight,
                                                                                      fontStyle: FlutterFlowTheme.of(context).titleSmall.fontStyle,
                                                                                    ),
                                                                                    color: FlutterFlowTheme.of(context).primaryD3,
                                                                                    fontSize: 12.0,
                                                                                    letterSpacing: 0.0,
                                                                                    fontWeight: FlutterFlowTheme.of(context).titleSmall.fontWeight,
                                                                                    fontStyle: FlutterFlowTheme.of(context).titleSmall.fontStyle,
                                                                                  ),
                                                                              elevation: 0.0,
                                                                              borderSide: BorderSide(
                                                                                color: FlutterFlowTheme.of(context).primaryD3,
                                                                                width: 1.0,
                                                                              ),
                                                                              borderRadius: BorderRadius.only(
                                                                                topLeft: Radius.circular(100.0),
                                                                                topRight: Radius.circular(100.0),
                                                                                bottomLeft: Radius.circular(100.0),
                                                                                bottomRight: Radius.circular(100.0),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                      ],
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                      );
                                                    },
                                                  );
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    if (((String var1) {
                                          return var1 != "null";
                                        }(getJsonField(
                                          FFAppState().SearchData,
                                          r'''$.events''',
                                        ).toString())) ==
                                        true)
                                      Container(
                                        decoration: BoxDecoration(
                                          color: FlutterFlowTheme.of(context)
                                              .white,
                                        ),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.max,
                                          children: [
                                            Container(
                                              width: double.infinity,
                                              decoration: BoxDecoration(),
                                              alignment: AlignmentDirectional(
                                                  0.0, 0.0),
                                              child: Padding(
                                                padding: EdgeInsetsDirectional
                                                    .fromSTEB(
                                                        0.0, 12.0, 0.0, 8.0),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        'Events',
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
                                                              color: FlutterFlowTheme
                                                                      .of(context)
                                                                  .extraBlack,
                                                              fontSize: 18.0,
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
                                                    InkWell(
                                                      splashColor:
                                                          Colors.transparent,
                                                      focusColor:
                                                          Colors.transparent,
                                                      hoverColor:
                                                          Colors.transparent,
                                                      highlightColor:
                                                          Colors.transparent,
                                                      onTap: () async {
                                                        _model.goToEvent =
                                                            await GetAllSearchCall
                                                                .call(
                                                          pSearchText: _model
                                                              .textController
                                                              .text,
                                                          pUserid:
                                                              currentUserUid,
                                                          pCommunityid:
                                                              FFAppState()
                                                                  .communityId,
                                                          token:
                                                              currentJwtToken,
                                                          pType: _model
                                                              .optionChoosed,
                                                          pCategory:
                                                              FFAppState()
                                                                  .SalesFilter,
                                                          pSaleType: FFAppState()
                                                              .SalesTypeFilter,
                                                          pSort: FFAppState()
                                                              .SalesSort,
                                                          pDistance: FFAppState()
                                                              .SalesKmFilter,
                                                        );

                                                        if ((_model.goToEvent
                                                                ?.succeeded ??
                                                            true)) {
                                                          FFAppState()
                                                              .SearchData = (_model
                                                                  .goToEvent
                                                                  ?.jsonBody ??
                                                              '');
                                                          safeSetState(() {});
                                                        }
                                                        _model.optionChoosed =
                                                            'event';
                                                        safeSetState(() {});

                                                        safeSetState(() {});
                                                      },
                                                      child: Icon(
                                                        Icons.arrow_forward,
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .primaryText,
                                                        size: 24.0,
                                                      ),
                                                    ),
                                                  ]
                                                      .addToStart(
                                                          SizedBox(width: 20.0))
                                                      .addToEnd(SizedBox(
                                                          width: 20.0)),
                                                ),
                                              ),
                                            ),
                                            Divider(
                                              height: 0.0,
                                              thickness: 2.0,
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .alternate,
                                            ),
                                            FutureBuilder<ApiCallResponse>(
                                              future: (_model
                                                          .apiRequestCompleter2 ??=
                                                      Completer<
                                                          ApiCallResponse>()
                                                        ..complete(
                                                            GetSpecifFilterSearchCall
                                                                .call(
                                                          pUserid:
                                                              currentUserUid,
                                                          pCommunityid:
                                                              FFAppState()
                                                                  .communityId,
                                                          token:
                                                              currentJwtToken,
                                                          pType: 'event',
                                                          pIdsList: functions
                                                              .returnIdsSearch(
                                                                  FFAppState()
                                                                      .SearchData,
                                                                  'events'),
                                                        )))
                                                  .future,
                                              builder: (context, snapshot) {
                                                // Customize what your widget looks like when it's loading.
                                                if (!snapshot.hasData) {
                                                  return CompLoadingWidget(
                                                    name: 'eventList',
                                                  );
                                                }
                                                final allEventsListViewGetSpecifFilterSearchResponse =
                                                    snapshot.data!;

                                                return Builder(
                                                  builder: (context) {
                                                    final events =
                                                        GetSpecifFilterSearchCall
                                                                .eventData(
                                                              allEventsListViewGetSpecifFilterSearchResponse
                                                                  .jsonBody,
                                                            )?.toList() ??
                                                            [];

                                                    return ListView.separated(
                                                      padding:
                                                          EdgeInsets.fromLTRB(
                                                        0,
                                                        0,
                                                        0,
                                                        20.0,
                                                      ),
                                                      shrinkWrap: true,
                                                      scrollDirection:
                                                          Axis.vertical,
                                                      itemCount: events.length,
                                                      separatorBuilder:
                                                          (_, __) => SizedBox(
                                                              height: 12.0),
                                                      itemBuilder: (context,
                                                          eventsIndex) {
                                                        final eventsItem =
                                                            events[eventsIndex];
                                                        return Padding(
                                                          padding:
                                                              EdgeInsetsDirectional
                                                                  .fromSTEB(
                                                                      20.0,
                                                                      0.0,
                                                                      20.0,
                                                                      0.0),
                                                          child: FutureBuilder<
                                                              List<
                                                                  EventAttendingRow>>(
                                                            future: EventAttendingTable()
                                                                .querySingleRow(
                                                              queryFn: (q) => q
                                                                  .eqOrNull(
                                                                    'event_id',
                                                                    getJsonField(
                                                                      eventsItem,
                                                                      r'''$.id''',
                                                                    ).toString(),
                                                                  )
                                                                  .eqOrNull(
                                                                    'attending_id',
                                                                    currentUserUid,
                                                                  ),
                                                            ),
                                                            builder: (context,
                                                                snapshot) {
                                                              // Customize what your widget looks like when it's loading.
                                                              if (!snapshot
                                                                  .hasData) {
                                                                return Center(
                                                                  child:
                                                                      SizedBox(
                                                                    width: 50.0,
                                                                    height:
                                                                        50.0,
                                                                    child:
                                                                        CircularProgressIndicator(
                                                                      valueColor:
                                                                          AlwaysStoppedAnimation<
                                                                              Color>(
                                                                        FlutterFlowTheme.of(context)
                                                                            .primary,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                );
                                                              }
                                                              List<EventAttendingRow>
                                                                  containerEventAttendingRowList =
                                                                  snapshot
                                                                      .data!;

                                                              final containerEventAttendingRow =
                                                                  containerEventAttendingRowList
                                                                          .isNotEmpty
                                                                      ? containerEventAttendingRowList
                                                                          .first
                                                                      : null;

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
                                                                onTap:
                                                                    () async {
                                                                  context
                                                                      .pushNamed(
                                                                    EventDetailsWidget
                                                                        .routeName,
                                                                    queryParameters:
                                                                        {
                                                                      'eventId':
                                                                          serializeParam(
                                                                        getJsonField(
                                                                          eventsItem,
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
                                                                  height: 188.0,
                                                                  decoration:
                                                                      BoxDecoration(),
                                                                  child:
                                                                      Padding(
                                                                    padding: EdgeInsetsDirectional
                                                                        .fromSTEB(
                                                                            0.0,
                                                                            8.0,
                                                                            0.0,
                                                                            8.0),
                                                                    child: Row(
                                                                      mainAxisSize:
                                                                          MainAxisSize
                                                                              .max,
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children:
                                                                          [
                                                                        ClipRRect(
                                                                          borderRadius:
                                                                              BorderRadius.circular(2.0),
                                                                          child:
                                                                              Image.network(
                                                                            getJsonField(
                                                                              eventsItem,
                                                                              r'''$.cover_image''',
                                                                            ).toString(),
                                                                            width:
                                                                                120.0,
                                                                            height:
                                                                                120.0,
                                                                            fit:
                                                                                BoxFit.cover,
                                                                          ),
                                                                        ),
                                                                        Expanded(
                                                                          child:
                                                                              Column(
                                                                            mainAxisSize:
                                                                                MainAxisSize.max,
                                                                            children: [
                                                                              Expanded(
                                                                                child: Column(
                                                                                  mainAxisSize: MainAxisSize.max,
                                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                                  children: [
                                                                                    if ((containerEventAttendingRow?.id != null && containerEventAttendingRow?.id != '') && (containerEventAttendingRow?.isInvited == true))
                                                                                      FutureBuilder<List<PublicUserProfileRow>>(
                                                                                        future: PublicUserProfileTable().querySingleRow(
                                                                                          queryFn: (q) => q.eqOrNull(
                                                                                            'id',
                                                                                            containerEventAttendingRow?.invitedBy,
                                                                                          ),
                                                                                        ),
                                                                                        builder: (context, snapshot) {
                                                                                          // Customize what your widget looks like when it's loading.
                                                                                          if (!snapshot.hasData) {
                                                                                            return CompLoadingWidget(
                                                                                              name: 'loading',
                                                                                            );
                                                                                          }
                                                                                          List<PublicUserProfileRow> rowPublicUserProfileRowList = snapshot.data!;

                                                                                          // Return an empty Container when the item does not exist.
                                                                                          if (snapshot.data!.isEmpty) {
                                                                                            return Container();
                                                                                          }
                                                                                          final rowPublicUserProfileRow = rowPublicUserProfileRowList.isNotEmpty ? rowPublicUserProfileRowList.first : null;

                                                                                          return Row(
                                                                                            mainAxisSize: MainAxisSize.max,
                                                                                            children: [
                                                                                              Container(
                                                                                                width: 12.0,
                                                                                                height: 12.0,
                                                                                                clipBehavior: Clip.antiAlias,
                                                                                                decoration: BoxDecoration(
                                                                                                  shape: BoxShape.circle,
                                                                                                ),
                                                                                                child: Image.network(
                                                                                                  rowPublicUserProfileRow!.profilePicture!,
                                                                                                  fit: BoxFit.cover,
                                                                                                ),
                                                                                              ),
                                                                                              Expanded(
                                                                                                child: Row(
                                                                                                  mainAxisSize: MainAxisSize.max,
                                                                                                  children: [
                                                                                                    Text(
                                                                                                      valueOrDefault<String>(
                                                                                                        rowPublicUserProfileRow?.name,
                                                                                                        'name  jjhgjh jhjhjh jhjhjhj',
                                                                                                      ),
                                                                                                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                                            font: GoogleFonts.manrope(
                                                                                                              fontWeight: FontWeight.w500,
                                                                                                              fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                            ),
                                                                                                            color: FlutterFlowTheme.of(context).greyL4,
                                                                                                            fontSize: 10.0,
                                                                                                            letterSpacing: 0.0,
                                                                                                            fontWeight: FontWeight.w500,
                                                                                                            fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                            lineHeight: 1.4,
                                                                                                          ),
                                                                                                    ),
                                                                                                    Expanded(
                                                                                                      child: Text(
                                                                                                        ' invited you to join this event',
                                                                                                        maxLines: 1,
                                                                                                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                                              font: GoogleFonts.manrope(
                                                                                                                fontWeight: FontWeight.w500,
                                                                                                                fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                              ),
                                                                                                              color: FlutterFlowTheme.of(context).greyL4,
                                                                                                              fontSize: 10.0,
                                                                                                              letterSpacing: 0.0,
                                                                                                              fontWeight: FontWeight.w500,
                                                                                                              fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                              lineHeight: 1.4,
                                                                                                            ),
                                                                                                      ),
                                                                                                    ),
                                                                                                  ],
                                                                                                ),
                                                                                              ),
                                                                                            ].divide(SizedBox(width: 10.0)),
                                                                                          );
                                                                                        },
                                                                                      ),
                                                                                    Column(
                                                                                      mainAxisSize: MainAxisSize.max,
                                                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                                                      children: [
                                                                                        Text(
                                                                                          getJsonField(
                                                                                            eventsItem,
                                                                                            r'''$.name''',
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
                                                                                        Text(
                                                                                          getJsonField(
                                                                                            eventsItem,
                                                                                            r'''$.description''',
                                                                                          ).toString(),
                                                                                          maxLines: 2,
                                                                                          style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                                font: GoogleFonts.manrope(
                                                                                                  fontWeight: FontWeight.w500,
                                                                                                  fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                ),
                                                                                                color: FlutterFlowTheme.of(context).greyL4,
                                                                                                fontSize: 10.0,
                                                                                                letterSpacing: 0.0,
                                                                                                fontWeight: FontWeight.w500,
                                                                                                fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                lineHeight: 1.4,
                                                                                              ),
                                                                                        ),
                                                                                      ].divide(SizedBox(height: 2.0)),
                                                                                    ),
                                                                                    Padding(
                                                                                      padding: EdgeInsetsDirectional.fromSTEB(0.0, 4.0, 0.0, 0.0),
                                                                                      child: Column(
                                                                                        mainAxisSize: MainAxisSize.max,
                                                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                                                        children: [
                                                                                          Row(
                                                                                            mainAxisSize: MainAxisSize.max,
                                                                                            children: [
                                                                                              ClipRRect(
                                                                                                borderRadius: BorderRadius.circular(0.0),
                                                                                                child: Image.asset(
                                                                                                  'assets/images/calendar_clock.png',
                                                                                                  width: 16.0,
                                                                                                  height: 16.0,
                                                                                                  fit: BoxFit.cover,
                                                                                                ),
                                                                                              ),
                                                                                              Text(
                                                                                                getJsonField(
                                                                                                  eventsItem,
                                                                                                  r'''$.start_date_time''',
                                                                                                ).toString(),
                                                                                                style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                                      font: GoogleFonts.manrope(
                                                                                                        fontWeight: FontWeight.w500,
                                                                                                        fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                      ),
                                                                                                      color: FlutterFlowTheme.of(context).greyL4,
                                                                                                      fontSize: 10.0,
                                                                                                      letterSpacing: 0.0,
                                                                                                      fontWeight: FontWeight.w500,
                                                                                                      fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                      lineHeight: 1.4,
                                                                                                    ),
                                                                                              ),
                                                                                            ].divide(SizedBox(width: 6.0)),
                                                                                          ),
                                                                                          Row(
                                                                                            mainAxisSize: MainAxisSize.max,
                                                                                            children: [
                                                                                              ClipRRect(
                                                                                                borderRadius: BorderRadius.circular(0.0),
                                                                                                child: Image.asset(
                                                                                                  'assets/images/explore.png',
                                                                                                  width: 16.0,
                                                                                                  height: 16.0,
                                                                                                  fit: BoxFit.cover,
                                                                                                ),
                                                                                              ),
                                                                                              Expanded(
                                                                                                child: Text(
                                                                                                  getJsonField(
                                                                                                    eventsItem,
                                                                                                    r'''$.Adderss''',
                                                                                                  ).toString(),
                                                                                                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                                        font: GoogleFonts.manrope(
                                                                                                          fontWeight: FontWeight.w500,
                                                                                                          fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                        ),
                                                                                                        color: FlutterFlowTheme.of(context).greyL4,
                                                                                                        fontSize: 10.0,
                                                                                                        letterSpacing: 0.0,
                                                                                                        fontWeight: FontWeight.w500,
                                                                                                        fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                        lineHeight: 1.4,
                                                                                                      ),
                                                                                                ),
                                                                                              ),
                                                                                            ].divide(SizedBox(width: 6.0)),
                                                                                          ),
                                                                                          Row(
                                                                                            mainAxisSize: MainAxisSize.max,
                                                                                            children: [
                                                                                              ClipRRect(
                                                                                                borderRadius: BorderRadius.circular(0.0),
                                                                                                child: Image.asset(
                                                                                                  'assets/images/crowdsource_(1).png',
                                                                                                  width: 16.0,
                                                                                                  height: 16.0,
                                                                                                  fit: BoxFit.cover,
                                                                                                ),
                                                                                              ),
                                                                                              Text(
                                                                                                '${getJsonField(
                                                                                                  eventsItem,
                                                                                                  r'''$.attendee_count''',
                                                                                                ).toString()}  attending',
                                                                                                style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                                      font: GoogleFonts.manrope(
                                                                                                        fontWeight: FontWeight.w500,
                                                                                                        fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                      ),
                                                                                                      color: FlutterFlowTheme.of(context).greyL4,
                                                                                                      fontSize: 10.0,
                                                                                                      letterSpacing: 0.0,
                                                                                                      fontWeight: FontWeight.w500,
                                                                                                      fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                      lineHeight: 1.4,
                                                                                                    ),
                                                                                              ),
                                                                                            ].divide(SizedBox(width: 6.0)),
                                                                                          ),
                                                                                        ].divide(SizedBox(height: 4.0)),
                                                                                      ),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                              ),
                                                                              Stack(
                                                                                children: [
                                                                                  FFButtonWidget(
                                                                                    onPressed: () async {
                                                                                      await EventAttendingTable().insert({
                                                                                        'community_id': FFAppState().communityId,
                                                                                        'event_id': getJsonField(
                                                                                          eventsItem,
                                                                                          r'''$.id''',
                                                                                        ).toString(),
                                                                                        'attending_id': currentUserUid,
                                                                                        'is_invited': false,
                                                                                        'is_attending': true,
                                                                                      });
                                                                                      _model.apiResultrykre = await UpdateEventAttendeeCountCall.call(
                                                                                        token: currentJwtToken,
                                                                                        eventId: containerEventAttendingRow?.id,
                                                                                      );

                                                                                      safeSetState(() {});
                                                                                    },
                                                                                    text: 'Attend',
                                                                                    icon: Icon(
                                                                                      Icons.edit_calendar_outlined,
                                                                                      size: 15.0,
                                                                                    ),
                                                                                    options: FFButtonOptions(
                                                                                      width: double.infinity,
                                                                                      height: 24.0,
                                                                                      padding: EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                                                                                      iconPadding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                                                                                      color: FlutterFlowTheme.of(context).white,
                                                                                      textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                                                                                            font: GoogleFonts.interTight(
                                                                                              fontWeight: FlutterFlowTheme.of(context).titleSmall.fontWeight,
                                                                                              fontStyle: FlutterFlowTheme.of(context).titleSmall.fontStyle,
                                                                                            ),
                                                                                            color: FlutterFlowTheme.of(context).primaryD3,
                                                                                            fontSize: 12.0,
                                                                                            letterSpacing: 0.0,
                                                                                            fontWeight: FlutterFlowTheme.of(context).titleSmall.fontWeight,
                                                                                            fontStyle: FlutterFlowTheme.of(context).titleSmall.fontStyle,
                                                                                          ),
                                                                                      elevation: 0.0,
                                                                                      borderSide: BorderSide(
                                                                                        color: FlutterFlowTheme.of(context).primaryD3,
                                                                                        width: 1.0,
                                                                                      ),
                                                                                      borderRadius: BorderRadius.only(
                                                                                        topLeft: Radius.circular(100.0),
                                                                                        topRight: Radius.circular(100.0),
                                                                                        bottomLeft: Radius.circular(100.0),
                                                                                        bottomRight: Radius.circular(100.0),
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                  if ((containerEventAttendingRow?.id != null && containerEventAttendingRow?.id != '') && (containerEventAttendingRow?.isAttending == false))
                                                                                    FFButtonWidget(
                                                                                      onPressed: () async {
                                                                                        await EventAttendingTable().update(
                                                                                          data: {
                                                                                            'is_attending': true,
                                                                                          },
                                                                                          matchingRows: (rows) => rows
                                                                                              .eqOrNull(
                                                                                                'event_id',
                                                                                                getJsonField(
                                                                                                  eventsItem,
                                                                                                  r'''$.id''',
                                                                                                ).toString(),
                                                                                              )
                                                                                              .eqOrNull(
                                                                                                'attending_id',
                                                                                                currentUserUid,
                                                                                              ),
                                                                                        );
                                                                                        _model.apiResultrykuuoo = await UpdateEventAttendeeCountCall.call(
                                                                                          token: currentJwtToken,
                                                                                          eventId: containerEventAttendingRow?.id,
                                                                                        );

                                                                                        safeSetState(() {});
                                                                                      },
                                                                                      text: 'Attend',
                                                                                      icon: Icon(
                                                                                        Icons.edit_calendar_outlined,
                                                                                        size: 15.0,
                                                                                      ),
                                                                                      options: FFButtonOptions(
                                                                                        width: double.infinity,
                                                                                        height: 24.0,
                                                                                        padding: EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                                                                                        iconPadding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                                                                                        color: FlutterFlowTheme.of(context).white,
                                                                                        textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                                                                                              font: GoogleFonts.interTight(
                                                                                                fontWeight: FlutterFlowTheme.of(context).titleSmall.fontWeight,
                                                                                                fontStyle: FlutterFlowTheme.of(context).titleSmall.fontStyle,
                                                                                              ),
                                                                                              color: FlutterFlowTheme.of(context).primaryD3,
                                                                                              fontSize: 12.0,
                                                                                              letterSpacing: 0.0,
                                                                                              fontWeight: FlutterFlowTheme.of(context).titleSmall.fontWeight,
                                                                                              fontStyle: FlutterFlowTheme.of(context).titleSmall.fontStyle,
                                                                                            ),
                                                                                        elevation: 0.0,
                                                                                        borderSide: BorderSide(
                                                                                          color: FlutterFlowTheme.of(context).primaryD3,
                                                                                          width: 1.0,
                                                                                        ),
                                                                                        borderRadius: BorderRadius.only(
                                                                                          topLeft: Radius.circular(100.0),
                                                                                          topRight: Radius.circular(100.0),
                                                                                          bottomLeft: Radius.circular(100.0),
                                                                                          bottomRight: Radius.circular(100.0),
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                  if ((containerEventAttendingRow?.id != null && containerEventAttendingRow?.id != '') && (containerEventAttendingRow?.isAttending == true))
                                                                                    FFButtonWidget(
                                                                                      onPressed: () async {
                                                                                        await EventAttendingTable().update(
                                                                                          data: {
                                                                                            'is_attending': false,
                                                                                          },
                                                                                          matchingRows: (rows) => rows
                                                                                              .eqOrNull(
                                                                                                'event_id',
                                                                                                getJsonField(
                                                                                                  eventsItem,
                                                                                                  r'''$.id''',
                                                                                                ).toString(),
                                                                                              )
                                                                                              .eqOrNull(
                                                                                                'attending_id',
                                                                                                currentUserUid,
                                                                                              ),
                                                                                        );
                                                                                        _model.kkkj = await UpdateEventAttendeeCountCall.call(
                                                                                          token: currentJwtToken,
                                                                                          eventId: containerEventAttendingRow?.id,
                                                                                        );

                                                                                        safeSetState(() {});
                                                                                      },
                                                                                      text: 'Attending',
                                                                                      icon: Icon(
                                                                                        Icons.edit_calendar_outlined,
                                                                                        size: 15.0,
                                                                                      ),
                                                                                      options: FFButtonOptions(
                                                                                        width: double.infinity,
                                                                                        height: 24.0,
                                                                                        padding: EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                                                                                        iconPadding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                                                                                        color: FlutterFlowTheme.of(context).white,
                                                                                        textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                                                                                              font: GoogleFonts.interTight(
                                                                                                fontWeight: FlutterFlowTheme.of(context).titleSmall.fontWeight,
                                                                                                fontStyle: FlutterFlowTheme.of(context).titleSmall.fontStyle,
                                                                                              ),
                                                                                              color: FlutterFlowTheme.of(context).greyL4,
                                                                                              fontSize: 12.0,
                                                                                              letterSpacing: 0.0,
                                                                                              fontWeight: FlutterFlowTheme.of(context).titleSmall.fontWeight,
                                                                                              fontStyle: FlutterFlowTheme.of(context).titleSmall.fontStyle,
                                                                                            ),
                                                                                        elevation: 0.0,
                                                                                        borderSide: BorderSide(
                                                                                          color: FlutterFlowTheme.of(context).greyL4,
                                                                                          width: 1.0,
                                                                                        ),
                                                                                        borderRadius: BorderRadius.only(
                                                                                          topLeft: Radius.circular(100.0),
                                                                                          topRight: Radius.circular(100.0),
                                                                                          bottomLeft: Radius.circular(100.0),
                                                                                          bottomRight: Radius.circular(100.0),
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                ],
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ].divide(SizedBox(
                                                                              width: 8.0)),
                                                                    ),
                                                                  ),
                                                                ),
                                                              );
                                                            },
                                                          ),
                                                        );
                                                      },
                                                    );
                                                  },
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    if (((String var1) {
                                          return var1 != "null";
                                        }(getJsonField(
                                          FFAppState().SearchData,
                                          r'''$.nearby_users''',
                                        ).toString())) ==
                                        true)
                                      Container(
                                        decoration: BoxDecoration(
                                          color: FlutterFlowTheme.of(context)
                                              .white,
                                        ),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.max,
                                          children: [
                                            Container(
                                              width: double.infinity,
                                              decoration: BoxDecoration(),
                                              alignment: AlignmentDirectional(
                                                  0.0, 0.0),
                                              child: Padding(
                                                padding: EdgeInsetsDirectional
                                                    .fromSTEB(
                                                        0.0, 12.0, 0.0, 8.0),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        'Neighbours',
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
                                                              color: FlutterFlowTheme
                                                                      .of(context)
                                                                  .extraBlack,
                                                              fontSize: 18.0,
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
                                                    InkWell(
                                                      splashColor:
                                                          Colors.transparent,
                                                      focusColor:
                                                          Colors.transparent,
                                                      hoverColor:
                                                          Colors.transparent,
                                                      highlightColor:
                                                          Colors.transparent,
                                                      onTap: () async {
                                                        _model.goToNeighbourhood =
                                                            await GetAllSearchCall
                                                                .call(
                                                          pSearchText: _model
                                                              .textController
                                                              .text,
                                                          pUserid:
                                                              currentUserUid,
                                                          pCommunityid:
                                                              FFAppState()
                                                                  .communityId,
                                                          token:
                                                              currentJwtToken,
                                                          pType: _model
                                                              .optionChoosed,
                                                          pCategory:
                                                              FFAppState()
                                                                  .SalesFilter,
                                                          pSaleType: FFAppState()
                                                              .SalesTypeFilter,
                                                          pSort: FFAppState()
                                                              .SalesSort,
                                                          pDistance: FFAppState()
                                                              .SalesKmFilter,
                                                        );

                                                        if ((_model
                                                                .goToNeighbourhood
                                                                ?.succeeded ??
                                                            true)) {
                                                          FFAppState()
                                                              .SearchData = (_model
                                                                  .goToNeighbourhood
                                                                  ?.jsonBody ??
                                                              '');
                                                          safeSetState(() {});
                                                        }
                                                        _model.optionChoosed =
                                                            'neighbourhood';
                                                        safeSetState(() {});

                                                        safeSetState(() {});
                                                      },
                                                      child: Icon(
                                                        Icons.arrow_forward,
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .primaryText,
                                                        size: 24.0,
                                                      ),
                                                    ),
                                                  ]
                                                      .addToStart(
                                                          SizedBox(width: 20.0))
                                                      .addToEnd(SizedBox(
                                                          width: 20.0)),
                                                ),
                                              ),
                                            ),
                                            Divider(
                                              height: 0.0,
                                              thickness: 2.0,
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .alternate,
                                            ),
                                            Container(
                                              child: Visibility(
                                                visible: ((String var1) {
                                                      return var1 == "null";
                                                    }(getJsonField(
                                                      FFAppState().SearchData,
                                                      r'''$.nearby_users''',
                                                    ).toString())) ==
                                                    false,
                                                child: Padding(
                                                  padding: EdgeInsetsDirectional
                                                      .fromSTEB(
                                                          0.0, 12.0, 0.0, 0.0),
                                                  child: FutureBuilder<
                                                      ApiCallResponse>(
                                                    future:
                                                        GetSpecifFilterSearchCall
                                                            .call(
                                                      pUserid: currentUserUid,
                                                      pCommunityid: FFAppState()
                                                          .communityId,
                                                      token: currentJwtToken,
                                                      pType: 'neighbourhood',
                                                      pIdsList: functions
                                                          .returnIdsSearch(
                                                              FFAppState()
                                                                  .SearchData,
                                                              'nearby_users'),
                                                    ),
                                                    builder:
                                                        (context, snapshot) {
                                                      // Customize what your widget looks like when it's loading.
                                                      if (!snapshot.hasData) {
                                                        return Center(
                                                          child: SizedBox(
                                                            width: 50.0,
                                                            height: 50.0,
                                                            child:
                                                                CircularProgressIndicator(
                                                              valueColor:
                                                                  AlwaysStoppedAnimation<
                                                                      Color>(
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .primary,
                                                              ),
                                                            ),
                                                          ),
                                                        );
                                                      }
                                                      final neighbourhoodListViewGetSpecifFilterSearchResponse =
                                                          snapshot.data!;

                                                      return Builder(
                                                        builder: (context) {
                                                          final neighbourhoodData =
                                                              neighbourhoodListViewGetSpecifFilterSearchResponse
                                                                  .jsonBody
                                                                  .toList();

                                                          return ListView
                                                              .separated(
                                                            padding: EdgeInsets
                                                                .fromLTRB(
                                                              0,
                                                              12.0,
                                                              0,
                                                              12.0,
                                                            ),
                                                            primary: false,
                                                            shrinkWrap: true,
                                                            scrollDirection:
                                                                Axis.vertical,
                                                            itemCount:
                                                                neighbourhoodData
                                                                    .length,
                                                            separatorBuilder: (_,
                                                                    __) =>
                                                                SizedBox(
                                                                    height:
                                                                        12.0),
                                                            itemBuilder: (context,
                                                                neighbourhoodDataIndex) {
                                                              final neighbourhoodDataItem =
                                                                  neighbourhoodData[
                                                                      neighbourhoodDataIndex];
                                                              return Column(
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .max,
                                                                children: [
                                                                  Padding(
                                                                    padding: EdgeInsetsDirectional
                                                                        .fromSTEB(
                                                                            20.0,
                                                                            12.0,
                                                                            20.0,
                                                                            12.0),
                                                                    child: Row(
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
                                                                          children:
                                                                              [
                                                                            Container(
                                                                              width: 32.0,
                                                                              height: 32.0,
                                                                              clipBehavior: Clip.antiAlias,
                                                                              decoration: BoxDecoration(
                                                                                shape: BoxShape.circle,
                                                                              ),
                                                                              child: Image.network(
                                                                                getJsonField(
                                                                                  neighbourhoodDataItem,
                                                                                  r'''$.profile_picture''',
                                                                                ).toString(),
                                                                                fit: BoxFit.cover,
                                                                              ),
                                                                            ),
                                                                            Column(
                                                                              mainAxisSize: MainAxisSize.max,
                                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                                              children: [
                                                                                Text(
                                                                                  getJsonField(
                                                                                    neighbourhoodDataItem,
                                                                                    r'''$.name''',
                                                                                  ).toString(),
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
                                                                                Text(
                                                                                  getJsonField(
                                                                                    neighbourhoodDataItem,
                                                                                    r'''$.city''',
                                                                                  ).toString(),
                                                                                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                        font: GoogleFonts.manrope(
                                                                                          fontWeight: FontWeight.w500,
                                                                                          fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                        ),
                                                                                        color: FlutterFlowTheme.of(context).greyL4,
                                                                                        fontSize: 10.0,
                                                                                        letterSpacing: 0.0,
                                                                                        fontWeight: FontWeight.w500,
                                                                                        fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                        lineHeight: 1.4,
                                                                                      ),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ].divide(SizedBox(width: 8.0)),
                                                                        ),
                                                                        InkWell(
                                                                          splashColor:
                                                                              Colors.transparent,
                                                                          focusColor:
                                                                              Colors.transparent,
                                                                          hoverColor:
                                                                              Colors.transparent,
                                                                          highlightColor:
                                                                              Colors.transparent,
                                                                          onTap:
                                                                              () async {
                                                                            await AddFollowCall.call(
                                                                              pFollowerid: currentUserUid,
                                                                              pFollowingid: getJsonField(
                                                                                neighbourhoodDataItem,
                                                                                r'''$.id''',
                                                                              ).toString(),
                                                                              pCommunityid: FFAppState().communityId,
                                                                              token: currentJwtToken,
                                                                            );
                                                                          },
                                                                          child:
                                                                              Container(
                                                                            width:
                                                                                100.0,
                                                                            height:
                                                                                30.0,
                                                                            decoration:
                                                                                BoxDecoration(),
                                                                            alignment:
                                                                                AlignmentDirectional(0.0, 0.0),
                                                                            child:
                                                                                FutureBuilder<List<FollowsRow>>(
                                                                              future: FollowsTable().querySingleRow(
                                                                                queryFn: (q) => q
                                                                                    .eqOrNull(
                                                                                      'follower_id',
                                                                                      currentUserUid,
                                                                                    )
                                                                                    .eqOrNull(
                                                                                      'following_id',
                                                                                      getJsonField(
                                                                                        neighbourhoodDataItem,
                                                                                        r'''$.id''',
                                                                                      ).toString(),
                                                                                    )
                                                                                    .order('created_at', ascending: true),
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
                                                                                List<FollowsRow> stackFollowsRowList = snapshot.data!;

                                                                                final stackFollowsRow = stackFollowsRowList.isNotEmpty ? stackFollowsRowList.first : null;

                                                                                return Stack(
                                                                                  children: [
                                                                                    if (stackFollowsRow?.id == null || stackFollowsRow?.id == '')
                                                                                      Row(
                                                                                        mainAxisSize: MainAxisSize.max,
                                                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                                                        children: [
                                                                                          Icon(
                                                                                            Icons.add,
                                                                                            color: FlutterFlowTheme.of(context).primaryD3,
                                                                                            size: 14.0,
                                                                                          ),
                                                                                          Text(
                                                                                            'Follow',
                                                                                            style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                                  font: GoogleFonts.manrope(
                                                                                                    fontWeight: FontWeight.w600,
                                                                                                    fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                  ),
                                                                                                  color: FlutterFlowTheme.of(context).primaryD3,
                                                                                                  fontSize: 12.0,
                                                                                                  letterSpacing: 0.0,
                                                                                                  fontWeight: FontWeight.w600,
                                                                                                  fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                  lineHeight: 1.4,
                                                                                                ),
                                                                                          ),
                                                                                        ].divide(SizedBox(width: 6.0)),
                                                                                      ),
                                                                                    if (stackFollowsRow?.id != null && stackFollowsRow?.id != '')
                                                                                      Row(
                                                                                        mainAxisSize: MainAxisSize.max,
                                                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                                                        children: [
                                                                                          ClipRRect(
                                                                                            borderRadius: BorderRadius.circular(8.0),
                                                                                            child: Image.asset(
                                                                                              'assets/images/check.png',
                                                                                              width: 12.0,
                                                                                              height: 12.0,
                                                                                              fit: BoxFit.cover,
                                                                                            ),
                                                                                          ),
                                                                                          Text(
                                                                                            'Following',
                                                                                            style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                                  font: GoogleFonts.manrope(
                                                                                                    fontWeight: FontWeight.w600,
                                                                                                    fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                  ),
                                                                                                  color: FlutterFlowTheme.of(context).greyL4,
                                                                                                  letterSpacing: 0.0,
                                                                                                  fontWeight: FontWeight.w600,
                                                                                                  fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                  lineHeight: 1.4,
                                                                                                ),
                                                                                          ),
                                                                                        ].divide(SizedBox(width: 6.0)),
                                                                                      ),
                                                                                  ],
                                                                                );
                                                                              },
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                  Container(
                                                                    width: double
                                                                        .infinity,
                                                                    height: 1.0,
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      color: FlutterFlowTheme.of(
                                                                              context)
                                                                          .greayL1,
                                                                    ),
                                                                  ),
                                                                ],
                                                              );
                                                            },
                                                          );
                                                        },
                                                      );
                                                    },
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    if (((String var1) {
                                          return var1 != "null";
                                        }(getJsonField(
                                          FFAppState().SearchData,
                                          r'''$.sales''',
                                        ).toString())) ==
                                        true)
                                      Container(
                                        decoration: BoxDecoration(
                                          color: FlutterFlowTheme.of(context)
                                              .white,
                                        ),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.max,
                                          children: [
                                            Container(
                                              width: double.infinity,
                                              decoration: BoxDecoration(),
                                              alignment: AlignmentDirectional(
                                                  0.0, 0.0),
                                              child: Padding(
                                                padding: EdgeInsetsDirectional
                                                    .fromSTEB(
                                                        0.0, 12.0, 0.0, 8.0),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        'Shops',
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
                                                              color: FlutterFlowTheme
                                                                      .of(context)
                                                                  .extraBlack,
                                                              fontSize: 18.0,
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
                                                    InkWell(
                                                      splashColor:
                                                          Colors.transparent,
                                                      focusColor:
                                                          Colors.transparent,
                                                      hoverColor:
                                                          Colors.transparent,
                                                      highlightColor:
                                                          Colors.transparent,
                                                      onTap: () async {
                                                        _model.goToSale =
                                                            await GetAllSearchCall
                                                                .call(
                                                          pSearchText: _model
                                                              .textController
                                                              .text,
                                                          pUserid:
                                                              currentUserUid,
                                                          pCommunityid:
                                                              FFAppState()
                                                                  .communityId,
                                                          token:
                                                              currentJwtToken,
                                                          pType: _model
                                                              .optionChoosed,
                                                          pCategory:
                                                              FFAppState()
                                                                  .SalesFilter,
                                                          pSaleType: FFAppState()
                                                              .SalesTypeFilter,
                                                          pSort: FFAppState()
                                                              .SalesSort,
                                                          pDistance: FFAppState()
                                                              .SalesKmFilter,
                                                        );

                                                        if ((_model.goToSale
                                                                ?.succeeded ??
                                                            true)) {
                                                          FFAppState()
                                                              .SearchData = (_model
                                                                  .goToSale
                                                                  ?.jsonBody ??
                                                              '');
                                                          safeSetState(() {});
                                                        }
                                                        _model.optionChoosed =
                                                            'sale';
                                                        safeSetState(() {});

                                                        safeSetState(() {});
                                                      },
                                                      child: Icon(
                                                        Icons.arrow_forward,
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .primaryText,
                                                        size: 24.0,
                                                      ),
                                                    ),
                                                  ]
                                                      .addToStart(
                                                          SizedBox(width: 20.0))
                                                      .addToEnd(SizedBox(
                                                          width: 20.0)),
                                                ),
                                              ),
                                            ),
                                            Divider(
                                              height: 0.0,
                                              thickness: 2.0,
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .alternate,
                                            ),
                                            FutureBuilder<ApiCallResponse>(
                                              future: GetSpecifFilterSearchCall
                                                  .call(
                                                pUserid: currentUserUid,
                                                pCommunityid:
                                                    FFAppState().communityId,
                                                token: currentJwtToken,
                                                pType: 'sale',
                                                pIdsList:
                                                    functions.returnIdsSearch(
                                                        FFAppState().SearchData,
                                                        'sales'),
                                              ),
                                              builder: (context, snapshot) {
                                                // Customize what your widget looks like when it's loading.
                                                if (!snapshot.hasData) {
                                                  return Center(
                                                    child: SizedBox(
                                                      width: 50.0,
                                                      height: 50.0,
                                                      child:
                                                          CircularProgressIndicator(
                                                        valueColor:
                                                            AlwaysStoppedAnimation<
                                                                Color>(
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .primary,
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                }
                                                final saleListViewGetSpecifFilterSearchResponse =
                                                    snapshot.data!;

                                                return Builder(
                                                  builder: (context) {
                                                    final salesHomePageData =
                                                        saleListViewGetSpecifFilterSearchResponse
                                                            .jsonBody
                                                            .toList();

                                                    return ListView.builder(
                                                      padding:
                                                          EdgeInsets.fromLTRB(
                                                        0,
                                                        0,
                                                        0,
                                                        20.0,
                                                      ),
                                                      shrinkWrap: true,
                                                      scrollDirection:
                                                          Axis.vertical,
                                                      itemCount:
                                                          salesHomePageData
                                                              .length,
                                                      itemBuilder: (context,
                                                          salesHomePageDataIndex) {
                                                        final salesHomePageDataItem =
                                                            salesHomePageData[
                                                                salesHomePageDataIndex];
                                                        return InkWell(
                                                          splashColor: Colors
                                                              .transparent,
                                                          focusColor: Colors
                                                              .transparent,
                                                          hoverColor: Colors
                                                              .transparent,
                                                          highlightColor: Colors
                                                              .transparent,
                                                          onTap: () async {
                                                            context.pushNamed(
                                                              SaleDetailsWidget
                                                                  .routeName,
                                                              queryParameters: {
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
                                                          child: Container(
                                                            width:
                                                                double.infinity,
                                                            height: 120.0,
                                                            decoration:
                                                                BoxDecoration(
                                                              color: FlutterFlowTheme
                                                                      .of(context)
                                                                  .secondaryBackground,
                                                            ),
                                                            child: Column(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .max,
                                                              children: [
                                                                Padding(
                                                                  padding: EdgeInsetsDirectional
                                                                      .fromSTEB(
                                                                          20.0,
                                                                          20.0,
                                                                          20.0,
                                                                          19.0),
                                                                  child: Row(
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .max,
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .spaceBetween,
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Stack(
                                                                        alignment: AlignmentDirectional(
                                                                            -1.0,
                                                                            1.0),
                                                                        children: [
                                                                          if (((String var1) {
                                                                                return var1 != "null";
                                                                              }(getJsonField(
                                                                                salesHomePageDataItem,
                                                                                r'''$.image''',
                                                                              ).toString())) ==
                                                                              true)
                                                                            ClipRRect(
                                                                              borderRadius: BorderRadius.circular(2.0),
                                                                              child: Image.network(
                                                                                getJsonField(
                                                                                  salesHomePageDataItem,
                                                                                  r'''$.image''',
                                                                                ).toString(),
                                                                                width: 120.0,
                                                                                height: 80.0,
                                                                                fit: BoxFit.cover,
                                                                              ),
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
                                                                        child:
                                                                            Container(
                                                                          height:
                                                                              80.0,
                                                                          decoration:
                                                                              BoxDecoration(),
                                                                          child:
                                                                              Column(
                                                                            mainAxisSize:
                                                                                MainAxisSize.max,
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.spaceBetween,
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
                                                                                    child: Row(
                                                                                      mainAxisSize: MainAxisSize.max,
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
                                                                                                fontSize: 10.0,
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
                                                                                                fontSize: 10.0,
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
                                                                                            salesHomePageDataItem,
                                                                                            r'''$.city''',
                                                                                          ).toString(),
                                                                                          style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                                font: GoogleFonts.manrope(
                                                                                                  fontWeight: FontWeight.w500,
                                                                                                  fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                ),
                                                                                                color: FlutterFlowTheme.of(context).greyL4,
                                                                                                fontSize: 10.0,
                                                                                                letterSpacing: 0.0,
                                                                                                fontWeight: FontWeight.w500,
                                                                                                fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                lineHeight: 1.4,
                                                                                              ),
                                                                                        ),
                                                                                      ].divide(SizedBox(width: 4.0)),
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
                                                                                      '£${getJsonField(
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
                                                                    ].divide(SizedBox(
                                                                        width:
                                                                            8.0)),
                                                                  ),
                                                                ),
                                                                Container(
                                                                  width: double
                                                                      .infinity,
                                                                  height: 1.0,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: FlutterFlowTheme.of(
                                                                            context)
                                                                        .greyL2,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    );
                                                  },
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    if (((String var1) {
                                          return var1 != "null";
                                        }(getJsonField(
                                          FFAppState().SearchData,
                                          r'''$.posts''',
                                        ).toString())) ==
                                        true)
                                      Container(
                                        decoration: BoxDecoration(
                                          color: FlutterFlowTheme.of(context)
                                              .white,
                                        ),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.max,
                                          children: [
                                            Container(
                                              width: double.infinity,
                                              decoration: BoxDecoration(),
                                              alignment: AlignmentDirectional(
                                                  0.0, 0.0),
                                              child: Padding(
                                                padding: EdgeInsetsDirectional
                                                    .fromSTEB(
                                                        0.0, 12.0, 0.0, 8.0),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        'Posts',
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
                                                              color: FlutterFlowTheme
                                                                      .of(context)
                                                                  .extraBlack,
                                                              fontSize: 18.0,
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
                                                    InkWell(
                                                      splashColor:
                                                          Colors.transparent,
                                                      focusColor:
                                                          Colors.transparent,
                                                      hoverColor:
                                                          Colors.transparent,
                                                      highlightColor:
                                                          Colors.transparent,
                                                      onTap: () async {
                                                        _model.goToPost =
                                                            await GetAllSearchCall
                                                                .call(
                                                          pSearchText: _model
                                                              .textController
                                                              .text,
                                                          pUserid:
                                                              currentUserUid,
                                                          pCommunityid:
                                                              FFAppState()
                                                                  .communityId,
                                                          token:
                                                              currentJwtToken,
                                                          pType: _model
                                                              .optionChoosed,
                                                          pCategory:
                                                              FFAppState()
                                                                  .SalesFilter,
                                                          pSaleType: FFAppState()
                                                              .SalesTypeFilter,
                                                          pSort: FFAppState()
                                                              .SalesSort,
                                                          pDistance: FFAppState()
                                                              .SalesKmFilter,
                                                        );

                                                        FFAppState()
                                                            .SearchData = (_model
                                                                .goToPost
                                                                ?.jsonBody ??
                                                            '');
                                                        safeSetState(() {});
                                                        _model.optionChoosed =
                                                            'post';
                                                        safeSetState(() {});

                                                        safeSetState(() {});
                                                      },
                                                      child: Icon(
                                                        Icons.arrow_forward,
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .primaryText,
                                                        size: 24.0,
                                                      ),
                                                    ),
                                                  ]
                                                      .addToStart(
                                                          SizedBox(width: 20.0))
                                                      .addToEnd(SizedBox(
                                                          width: 20.0)),
                                                ),
                                              ),
                                            ),
                                            Divider(
                                              height: 0.0,
                                              thickness: 2.0,
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .alternate,
                                            ),
                                            if (((String var1) {
                                                  return var1 != "null";
                                                }(getJsonField(
                                                  FFAppState().SearchData,
                                                  r'''$.posts''',
                                                ).toString())) ==
                                                true)
                                              FutureBuilder<ApiCallResponse>(
                                                future: (_model
                                                            .apiRequestCompleter1 ??=
                                                        Completer<
                                                            ApiCallResponse>()
                                                          ..complete(
                                                              GetSpecifFilterSearchCall
                                                                  .call(
                                                            pUserid:
                                                                currentUserUid,
                                                            pCommunityid:
                                                                FFAppState()
                                                                    .communityId,
                                                            token:
                                                                currentJwtToken,
                                                            pType: 'post',
                                                            pIdsList: functions
                                                                .returnIdsSearch(
                                                                    FFAppState()
                                                                        .SearchData,
                                                                    'posts'),
                                                          )))
                                                    .future,
                                                builder: (context, snapshot) {
                                                  // Customize what your widget looks like when it's loading.
                                                  if (!snapshot.hasData) {
                                                    return Container(
                                                      width: double.infinity,
                                                      height: double.infinity,
                                                      child:
                                                          ShimmerLoaderWidget(),
                                                    );
                                                  }
                                                  final postListViewGetSpecifFilterSearchResponse =
                                                      snapshot.data!;

                                                  return Builder(
                                                    builder: (context) {
                                                      final posts =
                                                          postListViewGetSpecifFilterSearchResponse
                                                              .jsonBody
                                                              .toList();

                                                      return SingleChildScrollView(
                                                        child: Column(
                                                          mainAxisSize:
                                                              MainAxisSize.max,
                                                          children:
                                                              List.generate(
                                                                  posts.length,
                                                                  (postsIndex) {
                                                            final postsItem =
                                                                posts[
                                                                    postsIndex];
                                                            return Container(
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .white,
                                                              ),
                                                              child: Column(
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .max,
                                                                children: [
                                                                  Column(
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .max,
                                                                    children: [
                                                                      Padding(
                                                                        padding: EdgeInsetsDirectional.fromSTEB(
                                                                            20.0,
                                                                            0.0,
                                                                            14.0,
                                                                            0.0),
                                                                        child:
                                                                            Row(
                                                                          mainAxisSize:
                                                                              MainAxisSize.max,
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.spaceBetween,
                                                                          children: [
                                                                            InkWell(
                                                                              splashColor: Colors.transparent,
                                                                              focusColor: Colors.transparent,
                                                                              hoverColor: Colors.transparent,
                                                                              highlightColor: Colors.transparent,
                                                                              onTap: () async {
                                                                                if (getJsonField(
                                                                                      postsItem,
                                                                                      r'''$.user_id''',
                                                                                    ) !=
                                                                                    currentUserUid) {
                                                                                  context.pushNamed(
                                                                                    OtherProfileWidget.routeName,
                                                                                    queryParameters: {
                                                                                      'userid': serializeParam(
                                                                                        getJsonField(
                                                                                          postsItem,
                                                                                          r'''$.user_id''',
                                                                                        ).toString(),
                                                                                        ParamType.String,
                                                                                      ),
                                                                                    }.withoutNulls,
                                                                                  );
                                                                                } else {
                                                                                  context.pushNamed(UserProfileWidget.routeName);
                                                                                }
                                                                              },
                                                                              child: Row(
                                                                                mainAxisSize: MainAxisSize.max,
                                                                                children: [
                                                                                  Container(
                                                                                    width: 32.0,
                                                                                    height: 32.0,
                                                                                    clipBehavior: Clip.antiAlias,
                                                                                    decoration: BoxDecoration(
                                                                                      shape: BoxShape.circle,
                                                                                    ),
                                                                                    child: Image.network(
                                                                                      getJsonField(
                                                                                        postsItem,
                                                                                        r'''$.profile_picture''',
                                                                                      ).toString(),
                                                                                      fit: BoxFit.cover,
                                                                                    ),
                                                                                  ),
                                                                                  Column(
                                                                                    mainAxisSize: MainAxisSize.max,
                                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                                    children: [
                                                                                      Text(
                                                                                        getJsonField(
                                                                                          postsItem,
                                                                                          r'''$.name''',
                                                                                        ).toString(),
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
                                                                                        children: [
                                                                                          Text(
                                                                                            getJsonField(
                                                                                              postsItem,
                                                                                              r'''$.city''',
                                                                                            ).toString(),
                                                                                            style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                                  font: GoogleFonts.manrope(
                                                                                                    fontWeight: FontWeight.w500,
                                                                                                    fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                  ),
                                                                                                  color: FlutterFlowTheme.of(context).greyL4,
                                                                                                  fontSize: 10.0,
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
                                                                                            functions.returnRelativeTIme(getJsonField(
                                                                                              postsItem,
                                                                                              r'''$.created_at''',
                                                                                            ).toString()),
                                                                                            style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                                  font: GoogleFonts.manrope(
                                                                                                    fontWeight: FontWeight.w500,
                                                                                                    fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                  ),
                                                                                                  color: FlutterFlowTheme.of(context).greyL4,
                                                                                                  fontSize: 10.0,
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
                                                                                          Container(
                                                                                            width: 8.0,
                                                                                            height: 8.0,
                                                                                            clipBehavior: Clip.antiAlias,
                                                                                            decoration: BoxDecoration(
                                                                                              shape: BoxShape.circle,
                                                                                            ),
                                                                                            child: Image.asset(
                                                                                              'assets/images/public.png',
                                                                                              fit: BoxFit.cover,
                                                                                            ),
                                                                                          ),
                                                                                        ].divide(SizedBox(width: 4.0)),
                                                                                      ),
                                                                                    ],
                                                                                  ),
                                                                                ].divide(SizedBox(width: 8.0)),
                                                                              ),
                                                                            ),
                                                                            Row(
                                                                              mainAxisSize: MainAxisSize.max,
                                                                              children: [
                                                                                InkWell(
                                                                                  splashColor: Colors.transparent,
                                                                                  focusColor: Colors.transparent,
                                                                                  hoverColor: Colors.transparent,
                                                                                  highlightColor: Colors.transparent,
                                                                                  onTap: () async {
                                                                                    await AddFollowCall.call(
                                                                                      pFollowerid: currentUserUid,
                                                                                      pFollowingid: getJsonField(
                                                                                        postsItem,
                                                                                        r'''$.user_id''',
                                                                                      ).toString(),
                                                                                      pCommunityid: FFAppState().communityId,
                                                                                      token: currentJwtToken,
                                                                                    );
                                                                                  },
                                                                                  child: Container(
                                                                                    decoration: BoxDecoration(),
                                                                                    child: Padding(
                                                                                      padding: EdgeInsetsDirectional.fromSTEB(6.0, 6.0, 6.0, 6.0),
                                                                                      child: FutureBuilder<List<FollowsRow>>(
                                                                                        future: FollowsTable().querySingleRow(
                                                                                          queryFn: (q) => q
                                                                                              .eqOrNull(
                                                                                                'follower_id',
                                                                                                currentUserUid,
                                                                                              )
                                                                                              .eqOrNull(
                                                                                                'following_id',
                                                                                                getJsonField(
                                                                                                  postsItem,
                                                                                                  r'''$.user_id''',
                                                                                                ).toString(),
                                                                                              ),
                                                                                        ),
                                                                                        builder: (context, snapshot) {
                                                                                          // Customize what your widget looks like when it's loading.
                                                                                          if (!snapshot.hasData) {
                                                                                            return CompLoadingWidget(
                                                                                              name: 'followPost',
                                                                                            );
                                                                                          }
                                                                                          List<FollowsRow> stackFollowsRowList = snapshot.data!;

                                                                                          final stackFollowsRow = stackFollowsRowList.isNotEmpty ? stackFollowsRowList.first : null;

                                                                                          return Stack(
                                                                                            children: [
                                                                                              if ((stackFollowsRow?.id == null || stackFollowsRow?.id == '') &&
                                                                                                  (getJsonField(
                                                                                                        postsItem,
                                                                                                        r'''$.user_id''',
                                                                                                      ) !=
                                                                                                      currentUserUid))
                                                                                                Row(
                                                                                                  mainAxisSize: MainAxisSize.max,
                                                                                                  children: [
                                                                                                    Icon(
                                                                                                      Icons.add,
                                                                                                      color: FlutterFlowTheme.of(context).primaryD3,
                                                                                                      size: 14.0,
                                                                                                    ),
                                                                                                    Text(
                                                                                                      'Follow',
                                                                                                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                                            font: GoogleFonts.manrope(
                                                                                                              fontWeight: FontWeight.w600,
                                                                                                              fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                            ),
                                                                                                            color: FlutterFlowTheme.of(context).primaryD3,
                                                                                                            fontSize: 12.0,
                                                                                                            letterSpacing: 0.0,
                                                                                                            fontWeight: FontWeight.w600,
                                                                                                            fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                            lineHeight: 1.4,
                                                                                                          ),
                                                                                                    ),
                                                                                                  ].divide(SizedBox(width: 6.0)),
                                                                                                ),
                                                                                              if ((stackFollowsRow?.followingId != null && stackFollowsRow?.followingId != '') &&
                                                                                                  (getJsonField(
                                                                                                        postsItem,
                                                                                                        r'''$.user_id''',
                                                                                                      ) !=
                                                                                                      currentUserUid))
                                                                                                Row(
                                                                                                  mainAxisSize: MainAxisSize.max,
                                                                                                  children: [
                                                                                                    ClipRRect(
                                                                                                      borderRadius: BorderRadius.circular(8.0),
                                                                                                      child: Image.asset(
                                                                                                        'assets/images/check.png',
                                                                                                        width: 12.0,
                                                                                                        height: 12.0,
                                                                                                        fit: BoxFit.cover,
                                                                                                      ),
                                                                                                    ),
                                                                                                    Text(
                                                                                                      'Following',
                                                                                                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                                            font: GoogleFonts.manrope(
                                                                                                              fontWeight: FontWeight.w600,
                                                                                                              fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                            ),
                                                                                                            color: FlutterFlowTheme.of(context).greyL4,
                                                                                                            letterSpacing: 0.0,
                                                                                                            fontWeight: FontWeight.w600,
                                                                                                            fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                            lineHeight: 1.4,
                                                                                                          ),
                                                                                                    ),
                                                                                                  ].divide(SizedBox(width: 6.0)),
                                                                                                ),
                                                                                            ],
                                                                                          );
                                                                                        },
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                                Transform.rotate(
                                                                                  angle: 90.0 * (math.pi / 180),
                                                                                  child: InkWell(
                                                                                    splashColor: Colors.transparent,
                                                                                    focusColor: Colors.transparent,
                                                                                    hoverColor: Colors.transparent,
                                                                                    highlightColor: Colors.transparent,
                                                                                    onTap: () async {
                                                                                      if (getJsonField(
                                                                                            postsItem,
                                                                                            r'''$.user_id''',
                                                                                          ) ==
                                                                                          currentUserUid) {
                                                                                        await showModalBottomSheet(
                                                                                          isScrollControlled: true,
                                                                                          backgroundColor: Colors.transparent,
                                                                                          context: context,
                                                                                          builder: (context) {
                                                                                            return GestureDetector(
                                                                                              onTap: () {
                                                                                                FocusScope.of(context).unfocus();
                                                                                                FocusManager.instance.primaryFocus?.unfocus();
                                                                                              },
                                                                                              child: Padding(
                                                                                                padding: MediaQuery.viewInsetsOf(context),
                                                                                                child: CompThreeDotEditPostWidget(
                                                                                                  postId: getJsonField(
                                                                                                    postsItem,
                                                                                                    r'''$.id''',
                                                                                                  ).toString(),
                                                                                                  groupId: getJsonField(
                                                                                                    postsItem,
                                                                                                    r'''$.group_id''',
                                                                                                  ).toString(),
                                                                                                ),
                                                                                              ),
                                                                                            );
                                                                                          },
                                                                                        ).then((value) => safeSetState(() {}));
                                                                                      } else {
                                                                                        await showModalBottomSheet(
                                                                                          isScrollControlled: true,
                                                                                          backgroundColor: Colors.transparent,
                                                                                          context: context,
                                                                                          builder: (context) {
                                                                                            return GestureDetector(
                                                                                              onTap: () {
                                                                                                FocusScope.of(context).unfocus();
                                                                                                FocusManager.instance.primaryFocus?.unfocus();
                                                                                              },
                                                                                              child: Padding(
                                                                                                padding: MediaQuery.viewInsetsOf(context),
                                                                                                child: CompThreeDotBlockUserWidget(
                                                                                                  reportedByUserId: currentUserUid,
                                                                                                  reportedUserId: getJsonField(
                                                                                                    postsItem,
                                                                                                    r'''$.user_id''',
                                                                                                  ).toString(),
                                                                                                  blockedUserName: getJsonField(
                                                                                                    postsItem,
                                                                                                    r'''$.user_name''',
                                                                                                  ).toString(),
                                                                                                  reportType: 'post',
                                                                                                ),
                                                                                              ),
                                                                                            );
                                                                                          },
                                                                                        ).then((value) => safeSetState(() {}));
                                                                                      }
                                                                                    },
                                                                                    child: Container(
                                                                                      decoration: BoxDecoration(),
                                                                                      child: Padding(
                                                                                        padding: EdgeInsetsDirectional.fromSTEB(6.0, 6.0, 6.0, 6.0),
                                                                                        child: Icon(
                                                                                          Icons.keyboard_control,
                                                                                          color: FlutterFlowTheme.of(context).primaryText,
                                                                                          size: 16.0,
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                      if (false)
                                                                        Padding(
                                                                          padding: EdgeInsetsDirectional.fromSTEB(
                                                                              20.0,
                                                                              0.0,
                                                                              20.0,
                                                                              0.0),
                                                                          child:
                                                                              Column(
                                                                            mainAxisSize:
                                                                                MainAxisSize.max,
                                                                            children: [
                                                                              Row(
                                                                                mainAxisSize: MainAxisSize.max,
                                                                                crossAxisAlignment: CrossAxisAlignment.end,
                                                                                children: [
                                                                                  if (_model.postReadId !=
                                                                                      getJsonField(
                                                                                        postsItem,
                                                                                        r'''$.id''',
                                                                                      ).toString())
                                                                                    Expanded(
                                                                                      child: Text(
                                                                                        getJsonField(
                                                                                          postsItem,
                                                                                          r'''$.content''',
                                                                                        ).toString().maybeHandleOverflow(
                                                                                              maxChars: 99,
                                                                                              replacement: '…',
                                                                                            ),
                                                                                        textAlign: TextAlign.start,
                                                                                        maxLines: 2,
                                                                                        style: FlutterFlowTheme.of(context).bodyMedium.override(
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
                                                                                  if (_model.postReadId ==
                                                                                      getJsonField(
                                                                                        postsItem,
                                                                                        r'''$.id''',
                                                                                      ).toString())
                                                                                    Expanded(
                                                                                      child: Text(
                                                                                        getJsonField(
                                                                                          postsItem,
                                                                                          r'''$.content''',
                                                                                        ).toString(),
                                                                                        textAlign: TextAlign.start,
                                                                                        style: FlutterFlowTheme.of(context).bodyMedium.override(
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
                                                                                ],
                                                                              ),
                                                                              if ((getJsonField(
                                                                                        postsItem,
                                                                                        r'''$.content''',
                                                                                      ).toString().length >
                                                                                      100) ==
                                                                                  true)
                                                                                Align(
                                                                                  alignment: AlignmentDirectional(1.0, -1.0),
                                                                                  child: Column(
                                                                                    mainAxisSize: MainAxisSize.max,
                                                                                    children: [
                                                                                      InkWell(
                                                                                        splashColor: Colors.transparent,
                                                                                        focusColor: Colors.transparent,
                                                                                        hoverColor: Colors.transparent,
                                                                                        highlightColor: Colors.transparent,
                                                                                        onTap: () async {
                                                                                          if (_model.postReadId ==
                                                                                              getJsonField(
                                                                                                postsItem,
                                                                                                r'''$.id''',
                                                                                              ).toString()) {
                                                                                            _model.postReadId = null;
                                                                                            safeSetState(() {});
                                                                                          } else {
                                                                                            _model.postReadId = getJsonField(
                                                                                              postsItem,
                                                                                              r'''$.id''',
                                                                                            ).toString();
                                                                                            safeSetState(() {});
                                                                                          }
                                                                                        },
                                                                                        child: Container(
                                                                                          decoration: BoxDecoration(),
                                                                                          child: Padding(
                                                                                            padding: EdgeInsetsDirectional.fromSTEB(6.0, 6.0, 6.0, 6.0),
                                                                                            child: Text(
                                                                                              valueOrDefault<String>(
                                                                                                _model.postReadId !=
                                                                                                        getJsonField(
                                                                                                          postsItem,
                                                                                                          r'''$.id''',
                                                                                                        ).toString()
                                                                                                    ? 'Read More'
                                                                                                    : 'Read Less',
                                                                                                'Read More',
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
                                                                                          ),
                                                                                        ),
                                                                                      ),
                                                                                    ],
                                                                                  ),
                                                                                ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      if (((String
                                                                              var1) {
                                                                            return var1 !=
                                                                                "null";
                                                                          }(getJsonField(
                                                                            postsItem,
                                                                            r'''$.images''',
                                                                          ).toString())) ==
                                                                          true)
                                                                        Stack(
                                                                          children: [
                                                                            if (((getJsonField(
                                                                                      postsItem,
                                                                                      r'''$.images''',
                                                                                      true,
                                                                                    ) as List?)!
                                                                                        .map<String>((e) => e.toString())
                                                                                        .toList()
                                                                                        .cast<String>()
                                                                                        .length ==
                                                                                    1) ==
                                                                                true)
                                                                              ClipRRect(
                                                                                borderRadius: BorderRadius.circular(0.0),
                                                                                child: Image.network(
                                                                                  getJsonField(
                                                                                    postsItem,
                                                                                    r'''$.images[0]''',
                                                                                  ).toString(),
                                                                                  width: double.infinity,
                                                                                  fit: BoxFit.contain,
                                                                                ),
                                                                              ),
                                                                          ],
                                                                        ),
                                                                      Padding(
                                                                        padding: EdgeInsetsDirectional.fromSTEB(
                                                                            20.0,
                                                                            0.0,
                                                                            20.0,
                                                                            0.0),
                                                                        child: custom_widgets
                                                                            .ShowContent(
                                                                          width:
                                                                              double.infinity,
                                                                          height:
                                                                              200.0,
                                                                          currentUserId:
                                                                              currentUserUid,
                                                                          richTextContent:
                                                                              getJsonField(
                                                                            postsItem,
                                                                            r'''$.content''',
                                                                          ),
                                                                          tldrContent:
                                                                              getJsonField(
                                                                            postsItem,
                                                                            r'''$.tldr''',
                                                                          ).toString(),
                                                                        ),
                                                                      ),
                                                                    ].divide(SizedBox(
                                                                        height:
                                                                            10.0)),
                                                                  ),
                                                                  Padding(
                                                                    padding: EdgeInsetsDirectional
                                                                        .fromSTEB(
                                                                            14.0,
                                                                            0.0,
                                                                            14.0,
                                                                            0.0),
                                                                    child: Row(
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
                                                                          children: [
                                                                            InkWell(
                                                                              splashColor: Colors.transparent,
                                                                              focusColor: Colors.transparent,
                                                                              hoverColor: Colors.transparent,
                                                                              highlightColor: Colors.transparent,
                                                                              onTap: () async {
                                                                                _model.addlike2 = await AddLikeCall.call(
                                                                                  pCommunityid: FFAppState().communityId.toString(),
                                                                                  pUserid: currentUserUid,
                                                                                  pPostid: getJsonField(
                                                                                    postsItem,
                                                                                    r'''$.id''',
                                                                                  ).toString(),
                                                                                  token: currentJwtToken,
                                                                                );

                                                                                safeSetState(() {});
                                                                              },
                                                                              child: Container(
                                                                                decoration: BoxDecoration(),
                                                                                child: Padding(
                                                                                  padding: EdgeInsetsDirectional.fromSTEB(6.0, 6.0, 4.0, 6.0),
                                                                                  child: Stack(
                                                                                    children: [
                                                                                      Icon(
                                                                                        Icons.favorite_border,
                                                                                        color: FlutterFlowTheme.of(context).greyL4,
                                                                                        size: 22.0,
                                                                                      ),
                                                                                      FutureBuilder<List<PostLikeRow>>(
                                                                                        future: PostLikeTable().querySingleRow(
                                                                                          queryFn: (q) => q
                                                                                              .eqOrNull(
                                                                                                'post_id',
                                                                                                getJsonField(
                                                                                                  postsItem,
                                                                                                  r'''$.id''',
                                                                                                ).toString(),
                                                                                              )
                                                                                              .eqOrNull(
                                                                                                'user_id',
                                                                                                currentUserUid,
                                                                                              ),
                                                                                        ),
                                                                                        builder: (context, snapshot) {
                                                                                          // Customize what your widget looks like when it's loading.
                                                                                          if (!snapshot.hasData) {
                                                                                            return Container(
                                                                                              width: 22.0,
                                                                                              height: 22.0,
                                                                                              child: CompLoadingWidget(
                                                                                                name: 'like',
                                                                                              ),
                                                                                            );
                                                                                          }
                                                                                          List<PostLikeRow> iconPostLikeRowList = snapshot.data!;

                                                                                          // Return an empty Container when the item does not exist.
                                                                                          if (snapshot.data!.isEmpty) {
                                                                                            return Container();
                                                                                          }
                                                                                          final iconPostLikeRow = iconPostLikeRowList.isNotEmpty ? iconPostLikeRowList.first : null;

                                                                                          return Icon(
                                                                                            Icons.favorite,
                                                                                            color: FlutterFlowTheme.of(context).redColor2,
                                                                                            size: 22.0,
                                                                                          );
                                                                                        },
                                                                                      ),
                                                                                    ],
                                                                                  ),
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
                                                                                        FocusManager.instance.primaryFocus?.unfocus();
                                                                                      },
                                                                                      child: Padding(
                                                                                        padding: MediaQuery.viewInsetsOf(context),
                                                                                        child: CompLikesWidget(
                                                                                          postId: getJsonField(
                                                                                            postsItem,
                                                                                            r'''$.id''',
                                                                                          ).toString(),
                                                                                          postUserid: getJsonField(
                                                                                            postsItem,
                                                                                            r'''$.user_id''',
                                                                                          ).toString(),
                                                                                        ),
                                                                                      ),
                                                                                    );
                                                                                  },
                                                                                ).then((value) => safeSetState(() {}));
                                                                              },
                                                                              child: Container(
                                                                                decoration: BoxDecoration(),
                                                                                child: Padding(
                                                                                  padding: EdgeInsetsDirectional.fromSTEB(0.0, 9.0, 16.0, 9.0),
                                                                                  child: Text(
                                                                                    valueOrDefault<String>(
                                                                                      getJsonField(
                                                                                        postsItem,
                                                                                        r'''$.likes_count''',
                                                                                      )?.toString(),
                                                                                      '0',
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
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                        InkWell(
                                                                          splashColor:
                                                                              Colors.transparent,
                                                                          focusColor:
                                                                              Colors.transparent,
                                                                          hoverColor:
                                                                              Colors.transparent,
                                                                          highlightColor:
                                                                              Colors.transparent,
                                                                          onTap:
                                                                              () async {
                                                                            _model.apiResultpio =
                                                                                await GetPostAllCommentsCall.call(
                                                                              pPostId: getJsonField(
                                                                                postsItem,
                                                                                r'''$.id''',
                                                                              ).toString(),
                                                                              token: currentJwtToken,
                                                                            );

                                                                            FFAppState().AsComments =
                                                                                getJsonField(
                                                                              (_model.apiResultpio?.jsonBody ?? ''),
                                                                              r'''$.comments''',
                                                                            );
                                                                            FFAppState().AsCommentReplies =
                                                                                getJsonField(
                                                                              (_model.apiResultpio?.jsonBody ?? ''),
                                                                              r'''$.replies''',
                                                                            );
                                                                            safeSetState(() {});

                                                                            context.pushNamed(
                                                                              CommentsPageWidget.routeName,
                                                                              queryParameters: {
                                                                                'postId': serializeParam(
                                                                                  getJsonField(
                                                                                    postsItem,
                                                                                    r'''$.id''',
                                                                                  ).toString(),
                                                                                  ParamType.String,
                                                                                ),
                                                                              }.withoutNulls,
                                                                            );

                                                                            safeSetState(() {});
                                                                          },
                                                                          child:
                                                                              Container(
                                                                            decoration:
                                                                                BoxDecoration(),
                                                                            child:
                                                                                Padding(
                                                                              padding: EdgeInsetsDirectional.fromSTEB(6.0, 6.0, 6.0, 6.0),
                                                                              child: Row(
                                                                                mainAxisSize: MainAxisSize.max,
                                                                                children: [
                                                                                  ClipRRect(
                                                                                    borderRadius: BorderRadius.circular(0.0),
                                                                                    child: Image.asset(
                                                                                      'assets/images/forum.png',
                                                                                      width: 22.0,
                                                                                      height: 22.0,
                                                                                      fit: BoxFit.cover,
                                                                                    ),
                                                                                  ),
                                                                                  Text(
                                                                                    valueOrDefault<String>(
                                                                                      getJsonField(
                                                                                        postsItem,
                                                                                        r'''$.comment_count''',
                                                                                      )?.toString(),
                                                                                      '0',
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
                                                                                ].divide(SizedBox(width: 4.0)),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        InkWell(
                                                                          splashColor:
                                                                              Colors.transparent,
                                                                          focusColor:
                                                                              Colors.transparent,
                                                                          hoverColor:
                                                                              Colors.transparent,
                                                                          highlightColor:
                                                                              Colors.transparent,
                                                                          onTap:
                                                                              () async {
                                                                            await showModalBottomSheet(
                                                                              isScrollControlled: true,
                                                                              backgroundColor: Colors.transparent,
                                                                              context: context,
                                                                              builder: (context) {
                                                                                return GestureDetector(
                                                                                  onTap: () {
                                                                                    FocusScope.of(context).unfocus();
                                                                                    FocusManager.instance.primaryFocus?.unfocus();
                                                                                  },
                                                                                  child: Padding(
                                                                                    padding: MediaQuery.viewInsetsOf(context),
                                                                                    child: CompShareWidget(
                                                                                      pagename: '',
                                                                                      id: '',
                                                                                    ),
                                                                                  ),
                                                                                );
                                                                              },
                                                                            ).then((value) =>
                                                                                safeSetState(() {}));
                                                                          },
                                                                          child:
                                                                              Container(
                                                                            decoration:
                                                                                BoxDecoration(),
                                                                            child:
                                                                                Padding(
                                                                              padding: EdgeInsetsDirectional.fromSTEB(6.0, 6.0, 6.0, 6.0),
                                                                              child: Row(
                                                                                mainAxisSize: MainAxisSize.max,
                                                                                children: [
                                                                                  InkWell(
                                                                                    splashColor: Colors.transparent,
                                                                                    focusColor: Colors.transparent,
                                                                                    hoverColor: Colors.transparent,
                                                                                    highlightColor: Colors.transparent,
                                                                                    onTap: () async {},
                                                                                    child: ClipRRect(
                                                                                      borderRadius: BorderRadius.circular(0.0),
                                                                                      child: Image.asset(
                                                                                        'assets/images/share_windows.png',
                                                                                        width: 22.0,
                                                                                        height: 22.0,
                                                                                        fit: BoxFit.cover,
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                  Text(
                                                                                    valueOrDefault<String>(
                                                                                      getJsonField(
                                                                                        postsItem,
                                                                                        r'''$.share_count''',
                                                                                      )?.toString(),
                                                                                      '0',
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
                                                                                ].divide(SizedBox(width: 4.0)),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ]
                                                                    .divide(SizedBox(
                                                                        height:
                                                                            4.0))
                                                                    .addToStart(
                                                                        SizedBox(
                                                                            height:
                                                                                12.0))
                                                                    .addToEnd(SizedBox(
                                                                        height:
                                                                            6.0)),
                                                              ),
                                                            );
                                                          }).divide(SizedBox(
                                                                  height: 8.0)),
                                                        ),
                                                      );
                                                    },
                                                  );
                                                },
                                              ),
                                          ],
                                        ),
                                      ),
                                    if (((String var1) {
                                          return var1 != "null";
                                        }(getJsonField(
                                          FFAppState().SearchData,
                                          r'''$.business_pages''',
                                        ).toString())) ==
                                        true)
                                      Container(
                                        decoration: BoxDecoration(
                                          color: FlutterFlowTheme.of(context)
                                              .white,
                                        ),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.max,
                                          children: [
                                            Container(
                                              width: double.infinity,
                                              decoration: BoxDecoration(),
                                              alignment: AlignmentDirectional(
                                                  0.0, 0.0),
                                              child: Padding(
                                                padding: EdgeInsetsDirectional
                                                    .fromSTEB(
                                                        0.0, 12.0, 0.0, 8.0),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        'Business',
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
                                                              color: FlutterFlowTheme
                                                                      .of(context)
                                                                  .extraBlack,
                                                              fontSize: 18.0,
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
                                                    InkWell(
                                                      splashColor:
                                                          Colors.transparent,
                                                      focusColor:
                                                          Colors.transparent,
                                                      hoverColor:
                                                          Colors.transparent,
                                                      highlightColor:
                                                          Colors.transparent,
                                                      onTap: () async {
                                                        _model.gotToBusiness =
                                                            await GetAllSearchCall
                                                                .call(
                                                          pSearchText: _model
                                                              .textController
                                                              .text,
                                                          pUserid:
                                                              currentUserUid,
                                                          pCommunityid:
                                                              FFAppState()
                                                                  .communityId,
                                                          token:
                                                              currentJwtToken,
                                                          pType: _model
                                                              .optionChoosed,
                                                          pCategory:
                                                              FFAppState()
                                                                  .SalesFilter,
                                                          pSaleType: FFAppState()
                                                              .SalesTypeFilter,
                                                          pSort: FFAppState()
                                                              .SalesSort,
                                                          pDistance: FFAppState()
                                                              .SalesKmFilter,
                                                        );

                                                        FFAppState()
                                                            .SearchData = (_model
                                                                .gotToBusiness
                                                                ?.jsonBody ??
                                                            '');
                                                        safeSetState(() {});
                                                        _model.optionChoosed =
                                                            'business';
                                                        safeSetState(() {});

                                                        safeSetState(() {});
                                                      },
                                                      child: Icon(
                                                        Icons.arrow_forward,
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .primaryText,
                                                        size: 24.0,
                                                      ),
                                                    ),
                                                  ]
                                                      .addToStart(
                                                          SizedBox(width: 20.0))
                                                      .addToEnd(SizedBox(
                                                          width: 20.0)),
                                                ),
                                              ),
                                            ),
                                            Divider(
                                              height: 0.0,
                                              thickness: 2.0,
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .alternate,
                                            ),
                                            Container(
                                              child: FutureBuilder<
                                                  ApiCallResponse>(
                                                future:
                                                    GetSpecifFilterSearchCall
                                                        .call(
                                                  pUserid: currentUserUid,
                                                  pCommunityid:
                                                      FFAppState().communityId,
                                                  token: currentJwtToken,
                                                  pType: 'business',
                                                  pIdsList:
                                                      functions.returnIdsSearch(
                                                          FFAppState()
                                                              .SearchData,
                                                          'business_pages'),
                                                ),
                                                builder: (context, snapshot) {
                                                  // Customize what your widget looks like when it's loading.
                                                  if (!snapshot.hasData) {
                                                    return Center(
                                                      child: SizedBox(
                                                        width: 50.0,
                                                        height: 50.0,
                                                        child:
                                                            CircularProgressIndicator(
                                                          valueColor:
                                                              AlwaysStoppedAnimation<
                                                                  Color>(
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .primary,
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                  }
                                                  final listViewGetSpecifFilterSearchResponse =
                                                      snapshot.data!;

                                                  return Builder(
                                                    builder: (context) {
                                                      final business =
                                                          listViewGetSpecifFilterSearchResponse
                                                              .jsonBody
                                                              .toList();

                                                      return ListView.separated(
                                                        padding:
                                                            EdgeInsets.zero,
                                                        primary: false,
                                                        shrinkWrap: true,
                                                        scrollDirection:
                                                            Axis.vertical,
                                                        itemCount:
                                                            business.length,
                                                        separatorBuilder:
                                                            (_, __) => SizedBox(
                                                                height: 5.0),
                                                        itemBuilder: (context,
                                                            businessIndex) {
                                                          final businessItem =
                                                              business[
                                                                  businessIndex];
                                                          return Column(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .max,
                                                            children: [
                                                              InkWell(
                                                                splashColor: Colors
                                                                    .transparent,
                                                                focusColor: Colors
                                                                    .transparent,
                                                                hoverColor: Colors
                                                                    .transparent,
                                                                highlightColor:
                                                                    Colors
                                                                        .transparent,
                                                                onTap:
                                                                    () async {
                                                                  context
                                                                      .pushNamed(
                                                                    BusinessHomePageWidget
                                                                        .routeName,
                                                                    queryParameters:
                                                                        {
                                                                      'businessId':
                                                                          serializeParam(
                                                                        getJsonField(
                                                                          businessItem,
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
                                                                  decoration:
                                                                      BoxDecoration(),
                                                                  child:
                                                                      Padding(
                                                                    padding: EdgeInsetsDirectional
                                                                        .fromSTEB(
                                                                            20.0,
                                                                            16.0,
                                                                            20.0,
                                                                            16.0),
                                                                    child: Row(
                                                                      mainAxisSize:
                                                                          MainAxisSize
                                                                              .max,
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children:
                                                                          [
                                                                        ClipRRect(
                                                                          borderRadius:
                                                                              BorderRadius.circular(8.0),
                                                                          child:
                                                                              Image.network(
                                                                            getJsonField(
                                                                              businessItem,
                                                                              r'''$.profile_picture''',
                                                                            ).toString(),
                                                                            width:
                                                                                64.0,
                                                                            height:
                                                                                64.0,
                                                                            fit:
                                                                                BoxFit.cover,
                                                                          ),
                                                                        ),
                                                                        Flexible(
                                                                          child:
                                                                              Column(
                                                                            mainAxisSize:
                                                                                MainAxisSize.max,
                                                                            crossAxisAlignment:
                                                                                CrossAxisAlignment.start,
                                                                            children: [
                                                                              Text(
                                                                                getJsonField(
                                                                                  businessItem,
                                                                                  r'''$.name''',
                                                                                ).toString(),
                                                                                maxLines: 1,
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
                                                                              Text(
                                                                                '${getJsonField(
                                                                                  businessItem,
                                                                                  r'''$.contacted_count''',
                                                                                ).toString()} people contacted this business',
                                                                                style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                      font: GoogleFonts.manrope(
                                                                                        fontWeight: FontWeight.w500,
                                                                                        fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                      ),
                                                                                      color: FlutterFlowTheme.of(context).greyL4,
                                                                                      fontSize: 10.0,
                                                                                      letterSpacing: 0.0,
                                                                                      fontWeight: FontWeight.w500,
                                                                                      fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                      lineHeight: 1.4,
                                                                                    ),
                                                                              ),
                                                                              Padding(
                                                                                padding: EdgeInsetsDirectional.fromSTEB(0.0, 8.0, 0.0, 0.0),
                                                                                child: Row(
                                                                                  mainAxisSize: MainAxisSize.max,
                                                                                  children: [
                                                                                    Expanded(
                                                                                      child: FFButtonWidget(
                                                                                        onPressed: () async {
                                                                                          await showModalBottomSheet(
                                                                                            isScrollControlled: true,
                                                                                            backgroundColor: Colors.transparent,
                                                                                            context: context,
                                                                                            builder: (context) {
                                                                                              return GestureDetector(
                                                                                                onTap: () {
                                                                                                  FocusScope.of(context).unfocus();
                                                                                                  FocusManager.instance.primaryFocus?.unfocus();
                                                                                                },
                                                                                                child: Padding(
                                                                                                  padding: MediaQuery.viewInsetsOf(context),
                                                                                                  child: CompBusinessContactWidget(
                                                                                                    website: getJsonField(
                                                                                                      businessItem,
                                                                                                      r'''$.website_link''',
                                                                                                    ).toString(),
                                                                                                    email: getJsonField(
                                                                                                      businessItem,
                                                                                                      r'''$.email''',
                                                                                                    ).toString(),
                                                                                                    mobile: getJsonField(
                                                                                                      businessItem,
                                                                                                      r'''$.phonenumber''',
                                                                                                    ).toString(),
                                                                                                    userid: getJsonField(
                                                                                                      businessItem,
                                                                                                      r'''$.admin_user''',
                                                                                                    ).toString(),
                                                                                                    businessid: getJsonField(
                                                                                                      businessItem,
                                                                                                      r'''$.id''',
                                                                                                    ).toString(),
                                                                                                  ),
                                                                                                ),
                                                                                              );
                                                                                            },
                                                                                          ).then((value) => safeSetState(() {}));
                                                                                        },
                                                                                        text: 'Contact',
                                                                                        icon: Icon(
                                                                                          Icons.arrow_drop_down,
                                                                                          size: 15.0,
                                                                                        ),
                                                                                        options: FFButtonOptions(
                                                                                          height: 24.0,
                                                                                          padding: EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                                                                                          iconAlignment: IconAlignment.end,
                                                                                          iconPadding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                                                                                          iconColor: FlutterFlowTheme.of(context).white,
                                                                                          color: FlutterFlowTheme.of(context).primary,
                                                                                          textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                                                                                                font: GoogleFonts.interTight(
                                                                                                  fontWeight: FlutterFlowTheme.of(context).titleSmall.fontWeight,
                                                                                                  fontStyle: FlutterFlowTheme.of(context).titleSmall.fontStyle,
                                                                                                ),
                                                                                                color: Colors.white,
                                                                                                fontSize: 12.0,
                                                                                                letterSpacing: 0.0,
                                                                                                fontWeight: FlutterFlowTheme.of(context).titleSmall.fontWeight,
                                                                                                fontStyle: FlutterFlowTheme.of(context).titleSmall.fontStyle,
                                                                                              ),
                                                                                          elevation: 0.0,
                                                                                          borderRadius: BorderRadius.circular(24.0),
                                                                                        ),
                                                                                        showLoadingIndicator: false,
                                                                                      ),
                                                                                    ),
                                                                                    Expanded(
                                                                                      child: FFButtonWidget(
                                                                                        onPressed: () async {
                                                                                          await showModalBottomSheet(
                                                                                            isScrollControlled: true,
                                                                                            backgroundColor: Colors.transparent,
                                                                                            context: context,
                                                                                            builder: (context) {
                                                                                              return GestureDetector(
                                                                                                onTap: () {
                                                                                                  FocusScope.of(context).unfocus();
                                                                                                  FocusManager.instance.primaryFocus?.unfocus();
                                                                                                },
                                                                                                child: Padding(
                                                                                                  padding: MediaQuery.viewInsetsOf(context),
                                                                                                  child: CompShareGroupWidget(),
                                                                                                ),
                                                                                              );
                                                                                            },
                                                                                          ).then((value) => safeSetState(() {}));
                                                                                        },
                                                                                        text: 'Share',
                                                                                        options: FFButtonOptions(
                                                                                          height: 24.0,
                                                                                          padding: EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                                                                                          iconAlignment: IconAlignment.end,
                                                                                          iconPadding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                                                                                          color: FlutterFlowTheme.of(context).greyL2,
                                                                                          textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                                                                                                font: GoogleFonts.interTight(
                                                                                                  fontWeight: FlutterFlowTheme.of(context).titleSmall.fontWeight,
                                                                                                  fontStyle: FlutterFlowTheme.of(context).titleSmall.fontStyle,
                                                                                                ),
                                                                                                color: FlutterFlowTheme.of(context).greyD1,
                                                                                                fontSize: 12.0,
                                                                                                letterSpacing: 0.0,
                                                                                                fontWeight: FlutterFlowTheme.of(context).titleSmall.fontWeight,
                                                                                                fontStyle: FlutterFlowTheme.of(context).titleSmall.fontStyle,
                                                                                              ),
                                                                                          elevation: 0.0,
                                                                                          borderRadius: BorderRadius.circular(24.0),
                                                                                        ),
                                                                                        showLoadingIndicator: false,
                                                                                      ),
                                                                                    ),
                                                                                  ].divide(SizedBox(width: 10.0)),
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ].divide(SizedBox(
                                                                              width: 10.0)),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                              Divider(
                                                                height: 0.0,
                                                                thickness: 2.0,
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .alternate,
                                                              ),
                                                            ],
                                                          );
                                                        },
                                                      );
                                                    },
                                                  );
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                  ].divide(SizedBox(height: 8.0)),
                                ),
                              ),
                            ),
                          if (_model.optionChoosed == 'sale')
                            Expanded(
                              child: Align(
                                alignment: AlignmentDirectional(0.0, 0.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    if (((String var1) {
                                          return var1 != "null";
                                        }(getJsonField(
                                          FFAppState().SearchData,
                                          r'''$.sales''',
                                        ).toString())) ==
                                        false)
                                      wrapWithModel(
                                        model: _model.compNoDataFoundModel1,
                                        updateCallback: () =>
                                            safeSetState(() {}),
                                        child: CompNoDataFoundWidget(
                                          pageName: 'sales',
                                          text1: 'No listings found',
                                          text2:
                                              'Nothing matched your search. Try different keywords or filters.',
                                        ),
                                      ),
                                    if (((String var1) {
                                          return var1 != "null";
                                        }(getJsonField(
                                          FFAppState().SearchData,
                                          r'''$.sales''',
                                        ).toString())) ==
                                        true)
                                      Expanded(
                                        child: SingleChildScrollView(
                                          child: Column(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              FutureBuilder<ApiCallResponse>(
                                                future:
                                                    GetSpecifFilterSearchCall
                                                        .call(
                                                  pUserid: currentUserUid,
                                                  pCommunityid:
                                                      FFAppState().communityId,
                                                  token: currentJwtToken,
                                                  pType: 'sale',
                                                  pIdsList:
                                                      functions.returnIdsSearch(
                                                          FFAppState()
                                                              .SearchData,
                                                          'sales'),
                                                ),
                                                builder: (context, snapshot) {
                                                  // Customize what your widget looks like when it's loading.
                                                  if (!snapshot.hasData) {
                                                    return Center(
                                                      child: SizedBox(
                                                        width: 50.0,
                                                        height: 50.0,
                                                        child:
                                                            CircularProgressIndicator(
                                                          valueColor:
                                                              AlwaysStoppedAnimation<
                                                                  Color>(
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .primary,
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                  }
                                                  final saleListViewGetSpecifFilterSearchResponse =
                                                      snapshot.data!;

                                                  return Builder(
                                                    builder: (context) {
                                                      final salesHomePageData =
                                                          saleListViewGetSpecifFilterSearchResponse
                                                              .jsonBody
                                                              .toList();

                                                      return ListView.builder(
                                                        padding:
                                                            EdgeInsets.fromLTRB(
                                                          0,
                                                          0,
                                                          0,
                                                          20.0,
                                                        ),
                                                        shrinkWrap: true,
                                                        scrollDirection:
                                                            Axis.vertical,
                                                        itemCount:
                                                            salesHomePageData
                                                                .length,
                                                        itemBuilder: (context,
                                                            salesHomePageDataIndex) {
                                                          final salesHomePageDataItem =
                                                              salesHomePageData[
                                                                  salesHomePageDataIndex];
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
                                                              context.pushNamed(
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
                                                            child: Container(
                                                              width: double
                                                                  .infinity,
                                                              height: 120.0,
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .secondaryBackground,
                                                              ),
                                                              child: Column(
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .max,
                                                                children: [
                                                                  Padding(
                                                                    padding: EdgeInsetsDirectional
                                                                        .fromSTEB(
                                                                            20.0,
                                                                            20.0,
                                                                            20.0,
                                                                            19.0),
                                                                    child: Row(
                                                                      mainAxisSize:
                                                                          MainAxisSize
                                                                              .max,
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .spaceBetween,
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children:
                                                                          [
                                                                        Stack(
                                                                          alignment: AlignmentDirectional(
                                                                              -1.0,
                                                                              1.0),
                                                                          children: [
                                                                            if (((String var1) {
                                                                                  return var1 != "null";
                                                                                }(getJsonField(
                                                                                  salesHomePageDataItem,
                                                                                  r'''$.image''',
                                                                                ).toString())) ==
                                                                                true)
                                                                              ClipRRect(
                                                                                borderRadius: BorderRadius.circular(2.0),
                                                                                child: Image.network(
                                                                                  getJsonField(
                                                                                    salesHomePageDataItem,
                                                                                    r'''$.image''',
                                                                                  ).toString(),
                                                                                  width: 120.0,
                                                                                  height: 80.0,
                                                                                  fit: BoxFit.cover,
                                                                                ),
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
                                                                          child:
                                                                              Container(
                                                                            height:
                                                                                80.0,
                                                                            decoration:
                                                                                BoxDecoration(),
                                                                            child:
                                                                                Column(
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
                                                                                      child: Row(
                                                                                        mainAxisSize: MainAxisSize.max,
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
                                                                                                  fontSize: 10.0,
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
                                                                                                  fontSize: 10.0,
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
                                                                                              salesHomePageDataItem,
                                                                                              r'''$.city''',
                                                                                            ).toString(),
                                                                                            style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                                  font: GoogleFonts.manrope(
                                                                                                    fontWeight: FontWeight.w500,
                                                                                                    fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                  ),
                                                                                                  color: FlutterFlowTheme.of(context).greyL4,
                                                                                                  fontSize: 10.0,
                                                                                                  letterSpacing: 0.0,
                                                                                                  fontWeight: FontWeight.w500,
                                                                                                  fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                  lineHeight: 1.4,
                                                                                                ),
                                                                                          ),
                                                                                        ].divide(SizedBox(width: 4.0)),
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
                                                                                        '£${getJsonField(
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
                                                                      ].divide(SizedBox(
                                                                              width: 8.0)),
                                                                    ),
                                                                  ),
                                                                  Container(
                                                                    width: double
                                                                        .infinity,
                                                                    height: 1.0,
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      color: FlutterFlowTheme.of(
                                                                              context)
                                                                          .greyL2,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                      );
                                                    },
                                                  );
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                  ].divide(SizedBox(height: 16.0)),
                                ),
                              ),
                            ),
                          if (_model.optionChoosed == 'post')
                            Expanded(
                              child: Align(
                                alignment: AlignmentDirectional(0.0, 0.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    if (((String var1) {
                                          return var1 != "null";
                                        }(getJsonField(
                                          FFAppState().SearchData,
                                          r'''$.posts''',
                                        ).toString())) ==
                                        false)
                                      wrapWithModel(
                                        model: _model.compNoDataFoundModel2,
                                        updateCallback: () =>
                                            safeSetState(() {}),
                                        child: CompNoDataFoundWidget(
                                          pageName: 'posts',
                                          text1: 'No posts found',
                                          text2:
                                              'Try a different keyword — we couldn’t find anything matching your search.',
                                        ),
                                      ),
                                    if (((String var1) {
                                          return var1 != "null";
                                        }(getJsonField(
                                          FFAppState().SearchData,
                                          r'''$.posts''',
                                        ).toString())) ==
                                        true)
                                      Expanded(
                                        child: FutureBuilder<ApiCallResponse>(
                                          future:
                                              GetSpecifFilterSearchCall.call(
                                            pUserid: currentUserUid,
                                            pCommunityid:
                                                FFAppState().communityId,
                                            token: currentJwtToken,
                                            pType: 'post',
                                            pIdsList: functions.returnIdsSearch(
                                                FFAppState().SearchData,
                                                'posts'),
                                          ),
                                          builder: (context, snapshot) {
                                            // Customize what your widget looks like when it's loading.
                                            if (!snapshot.hasData) {
                                              return Container(
                                                width: double.infinity,
                                                height: double.infinity,
                                                child: ShimmerLoaderWidget(),
                                              );
                                            }
                                            final postListViewGetSpecifFilterSearchResponse =
                                                snapshot.data!;

                                            return Builder(
                                              builder: (context) {
                                                final posts =
                                                    postListViewGetSpecifFilterSearchResponse
                                                        .jsonBody
                                                        .toList();

                                                return SingleChildScrollView(
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    children: List.generate(
                                                        posts.length,
                                                        (postsIndex) {
                                                      final postsItem =
                                                          posts[postsIndex];
                                                      return Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .white,
                                                        ),
                                                        child: Column(
                                                          mainAxisSize:
                                                              MainAxisSize.max,
                                                          children: [
                                                            Column(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .max,
                                                              children: [
                                                                Padding(
                                                                  padding: EdgeInsetsDirectional
                                                                      .fromSTEB(
                                                                          20.0,
                                                                          0.0,
                                                                          14.0,
                                                                          0.0),
                                                                  child: Row(
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .max,
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .spaceBetween,
                                                                    children: [
                                                                      InkWell(
                                                                        splashColor:
                                                                            Colors.transparent,
                                                                        focusColor:
                                                                            Colors.transparent,
                                                                        hoverColor:
                                                                            Colors.transparent,
                                                                        highlightColor:
                                                                            Colors.transparent,
                                                                        onTap:
                                                                            () async {
                                                                          if (getJsonField(
                                                                                postsItem,
                                                                                r'''$.user_id''',
                                                                              ) !=
                                                                              currentUserUid) {
                                                                            context.pushNamed(
                                                                              OtherProfileWidget.routeName,
                                                                              queryParameters: {
                                                                                'userid': serializeParam(
                                                                                  getJsonField(
                                                                                    postsItem,
                                                                                    r'''$.user_id''',
                                                                                  ).toString(),
                                                                                  ParamType.String,
                                                                                ),
                                                                              }.withoutNulls,
                                                                            );
                                                                          } else {
                                                                            context.pushNamed(UserProfileWidget.routeName);
                                                                          }
                                                                        },
                                                                        child:
                                                                            Row(
                                                                          mainAxisSize:
                                                                              MainAxisSize.max,
                                                                          children:
                                                                              [
                                                                            Container(
                                                                              width: 32.0,
                                                                              height: 32.0,
                                                                              clipBehavior: Clip.antiAlias,
                                                                              decoration: BoxDecoration(
                                                                                shape: BoxShape.circle,
                                                                              ),
                                                                              child: Image.network(
                                                                                getJsonField(
                                                                                  postsItem,
                                                                                  r'''$.profile_picture''',
                                                                                ).toString(),
                                                                                fit: BoxFit.cover,
                                                                              ),
                                                                            ),
                                                                            Column(
                                                                              mainAxisSize: MainAxisSize.max,
                                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                                              children: [
                                                                                Text(
                                                                                  getJsonField(
                                                                                    postsItem,
                                                                                    r'''$.name''',
                                                                                  ).toString(),
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
                                                                                  children: [
                                                                                    Text(
                                                                                      getJsonField(
                                                                                        postsItem,
                                                                                        r'''$.city''',
                                                                                      ).toString(),
                                                                                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                            font: GoogleFonts.manrope(
                                                                                              fontWeight: FontWeight.w500,
                                                                                              fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                            ),
                                                                                            color: FlutterFlowTheme.of(context).greyL4,
                                                                                            fontSize: 10.0,
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
                                                                                      functions.returnRelativeTIme(getJsonField(
                                                                                        postsItem,
                                                                                        r'''$.created_at''',
                                                                                      ).toString()),
                                                                                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                            font: GoogleFonts.manrope(
                                                                                              fontWeight: FontWeight.w500,
                                                                                              fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                            ),
                                                                                            color: FlutterFlowTheme.of(context).greyL4,
                                                                                            fontSize: 10.0,
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
                                                                                    Container(
                                                                                      width: 8.0,
                                                                                      height: 8.0,
                                                                                      clipBehavior: Clip.antiAlias,
                                                                                      decoration: BoxDecoration(
                                                                                        shape: BoxShape.circle,
                                                                                      ),
                                                                                      child: Image.asset(
                                                                                        'assets/images/public.png',
                                                                                        fit: BoxFit.cover,
                                                                                      ),
                                                                                    ),
                                                                                  ].divide(SizedBox(width: 4.0)),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ].divide(SizedBox(width: 8.0)),
                                                                        ),
                                                                      ),
                                                                      Row(
                                                                        mainAxisSize:
                                                                            MainAxisSize.max,
                                                                        children: [
                                                                          InkWell(
                                                                            splashColor:
                                                                                Colors.transparent,
                                                                            focusColor:
                                                                                Colors.transparent,
                                                                            hoverColor:
                                                                                Colors.transparent,
                                                                            highlightColor:
                                                                                Colors.transparent,
                                                                            onTap:
                                                                                () async {
                                                                              await AddFollowCall.call(
                                                                                pFollowerid: currentUserUid,
                                                                                pFollowingid: getJsonField(
                                                                                  postsItem,
                                                                                  r'''$.user_id''',
                                                                                ).toString(),
                                                                                pCommunityid: FFAppState().communityId,
                                                                                token: currentJwtToken,
                                                                              );
                                                                            },
                                                                            child:
                                                                                Container(
                                                                              decoration: BoxDecoration(),
                                                                              child: Padding(
                                                                                padding: EdgeInsetsDirectional.fromSTEB(6.0, 6.0, 6.0, 6.0),
                                                                                child: FutureBuilder<List<FollowsRow>>(
                                                                                  future: FollowsTable().querySingleRow(
                                                                                    queryFn: (q) => q
                                                                                        .eqOrNull(
                                                                                          'follower_id',
                                                                                          currentUserUid,
                                                                                        )
                                                                                        .eqOrNull(
                                                                                          'following_id',
                                                                                          getJsonField(
                                                                                            postsItem,
                                                                                            r'''$.user_id''',
                                                                                          ).toString(),
                                                                                        ),
                                                                                  ),
                                                                                  builder: (context, snapshot) {
                                                                                    // Customize what your widget looks like when it's loading.
                                                                                    if (!snapshot.hasData) {
                                                                                      return CompLoadingWidget(
                                                                                        name: 'followPost',
                                                                                      );
                                                                                    }
                                                                                    List<FollowsRow> stackFollowsRowList = snapshot.data!;

                                                                                    final stackFollowsRow = stackFollowsRowList.isNotEmpty ? stackFollowsRowList.first : null;

                                                                                    return Stack(
                                                                                      children: [
                                                                                        if ((stackFollowsRow?.id == null || stackFollowsRow?.id == '') &&
                                                                                            (getJsonField(
                                                                                                  postsItem,
                                                                                                  r'''$.user_id''',
                                                                                                ) !=
                                                                                                currentUserUid))
                                                                                          Row(
                                                                                            mainAxisSize: MainAxisSize.max,
                                                                                            children: [
                                                                                              Icon(
                                                                                                Icons.add,
                                                                                                color: FlutterFlowTheme.of(context).primaryD3,
                                                                                                size: 14.0,
                                                                                              ),
                                                                                              Text(
                                                                                                'Follow',
                                                                                                style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                                      font: GoogleFonts.manrope(
                                                                                                        fontWeight: FontWeight.w600,
                                                                                                        fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                      ),
                                                                                                      color: FlutterFlowTheme.of(context).primaryD3,
                                                                                                      fontSize: 12.0,
                                                                                                      letterSpacing: 0.0,
                                                                                                      fontWeight: FontWeight.w600,
                                                                                                      fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                      lineHeight: 1.4,
                                                                                                    ),
                                                                                              ),
                                                                                            ].divide(SizedBox(width: 6.0)),
                                                                                          ),
                                                                                        if ((stackFollowsRow?.followingId != null && stackFollowsRow?.followingId != '') &&
                                                                                            (getJsonField(
                                                                                                  postsItem,
                                                                                                  r'''$.user_id''',
                                                                                                ) !=
                                                                                                currentUserUid))
                                                                                          Row(
                                                                                            mainAxisSize: MainAxisSize.max,
                                                                                            children: [
                                                                                              ClipRRect(
                                                                                                borderRadius: BorderRadius.circular(8.0),
                                                                                                child: Image.asset(
                                                                                                  'assets/images/check.png',
                                                                                                  width: 12.0,
                                                                                                  height: 12.0,
                                                                                                  fit: BoxFit.cover,
                                                                                                ),
                                                                                              ),
                                                                                              Text(
                                                                                                'Following',
                                                                                                style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                                      font: GoogleFonts.manrope(
                                                                                                        fontWeight: FontWeight.w600,
                                                                                                        fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                      ),
                                                                                                      color: FlutterFlowTheme.of(context).greyL4,
                                                                                                      letterSpacing: 0.0,
                                                                                                      fontWeight: FontWeight.w600,
                                                                                                      fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                      lineHeight: 1.4,
                                                                                                    ),
                                                                                              ),
                                                                                            ].divide(SizedBox(width: 6.0)),
                                                                                          ),
                                                                                      ],
                                                                                    );
                                                                                  },
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          Transform
                                                                              .rotate(
                                                                            angle:
                                                                                90.0 * (math.pi / 180),
                                                                            child:
                                                                                InkWell(
                                                                              splashColor: Colors.transparent,
                                                                              focusColor: Colors.transparent,
                                                                              hoverColor: Colors.transparent,
                                                                              highlightColor: Colors.transparent,
                                                                              onTap: () async {
                                                                                if (getJsonField(
                                                                                      postsItem,
                                                                                      r'''$.user_id''',
                                                                                    ) ==
                                                                                    currentUserUid) {
                                                                                  await showModalBottomSheet(
                                                                                    isScrollControlled: true,
                                                                                    backgroundColor: Colors.transparent,
                                                                                    context: context,
                                                                                    builder: (context) {
                                                                                      return GestureDetector(
                                                                                        onTap: () {
                                                                                          FocusScope.of(context).unfocus();
                                                                                          FocusManager.instance.primaryFocus?.unfocus();
                                                                                        },
                                                                                        child: Padding(
                                                                                          padding: MediaQuery.viewInsetsOf(context),
                                                                                          child: CompThreeDotEditPostWidget(
                                                                                            postId: getJsonField(
                                                                                              postsItem,
                                                                                              r'''$.id''',
                                                                                            ).toString(),
                                                                                            groupId: getJsonField(
                                                                                              postsItem,
                                                                                              r'''$.group_id''',
                                                                                            ).toString(),
                                                                                          ),
                                                                                        ),
                                                                                      );
                                                                                    },
                                                                                  ).then((value) => safeSetState(() {}));
                                                                                } else {
                                                                                  await showModalBottomSheet(
                                                                                    isScrollControlled: true,
                                                                                    backgroundColor: Colors.transparent,
                                                                                    context: context,
                                                                                    builder: (context) {
                                                                                      return GestureDetector(
                                                                                        onTap: () {
                                                                                          FocusScope.of(context).unfocus();
                                                                                          FocusManager.instance.primaryFocus?.unfocus();
                                                                                        },
                                                                                        child: Padding(
                                                                                          padding: MediaQuery.viewInsetsOf(context),
                                                                                          child: CompThreeDotBlockUserWidget(
                                                                                            reportedByUserId: currentUserUid,
                                                                                            reportedUserId: getJsonField(
                                                                                              postsItem,
                                                                                              r'''$.user_id''',
                                                                                            ).toString(),
                                                                                            blockedUserName: getJsonField(
                                                                                              postsItem,
                                                                                              r'''$.user_name''',
                                                                                            ).toString(),
                                                                                            reportType: 'post',
                                                                                          ),
                                                                                        ),
                                                                                      );
                                                                                    },
                                                                                  ).then((value) => safeSetState(() {}));
                                                                                }
                                                                              },
                                                                              child: Container(
                                                                                decoration: BoxDecoration(),
                                                                                child: Padding(
                                                                                  padding: EdgeInsetsDirectional.fromSTEB(6.0, 6.0, 6.0, 6.0),
                                                                                  child: Icon(
                                                                                    Icons.keyboard_control,
                                                                                    color: FlutterFlowTheme.of(context).primaryText,
                                                                                    size: 16.0,
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                                if (false)
                                                                  Padding(
                                                                    padding: EdgeInsetsDirectional
                                                                        .fromSTEB(
                                                                            20.0,
                                                                            0.0,
                                                                            20.0,
                                                                            0.0),
                                                                    child:
                                                                        Column(
                                                                      mainAxisSize:
                                                                          MainAxisSize
                                                                              .max,
                                                                      children: [
                                                                        Row(
                                                                          mainAxisSize:
                                                                              MainAxisSize.max,
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.end,
                                                                          children: [
                                                                            if (_model.postReadId !=
                                                                                getJsonField(
                                                                                  postsItem,
                                                                                  r'''$.id''',
                                                                                ).toString())
                                                                              Expanded(
                                                                                child: Text(
                                                                                  getJsonField(
                                                                                    postsItem,
                                                                                    r'''$.content''',
                                                                                  ).toString().maybeHandleOverflow(
                                                                                        maxChars: 99,
                                                                                        replacement: '…',
                                                                                      ),
                                                                                  textAlign: TextAlign.start,
                                                                                  maxLines: 2,
                                                                                  style: FlutterFlowTheme.of(context).bodyMedium.override(
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
                                                                            if (_model.postReadId ==
                                                                                getJsonField(
                                                                                  postsItem,
                                                                                  r'''$.id''',
                                                                                ).toString())
                                                                              Expanded(
                                                                                child: Text(
                                                                                  getJsonField(
                                                                                    postsItem,
                                                                                    r'''$.content''',
                                                                                  ).toString(),
                                                                                  textAlign: TextAlign.start,
                                                                                  style: FlutterFlowTheme.of(context).bodyMedium.override(
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
                                                                          ],
                                                                        ),
                                                                        if ((getJsonField(
                                                                                  postsItem,
                                                                                  r'''$.content''',
                                                                                ).toString().length >
                                                                                100) ==
                                                                            true)
                                                                          Align(
                                                                            alignment:
                                                                                AlignmentDirectional(1.0, -1.0),
                                                                            child:
                                                                                Column(
                                                                              mainAxisSize: MainAxisSize.max,
                                                                              children: [
                                                                                InkWell(
                                                                                  splashColor: Colors.transparent,
                                                                                  focusColor: Colors.transparent,
                                                                                  hoverColor: Colors.transparent,
                                                                                  highlightColor: Colors.transparent,
                                                                                  onTap: () async {
                                                                                    if (_model.postReadId ==
                                                                                        getJsonField(
                                                                                          postsItem,
                                                                                          r'''$.id''',
                                                                                        ).toString()) {
                                                                                      _model.postReadId = null;
                                                                                      safeSetState(() {});
                                                                                    } else {
                                                                                      _model.postReadId = getJsonField(
                                                                                        postsItem,
                                                                                        r'''$.id''',
                                                                                      ).toString();
                                                                                      safeSetState(() {});
                                                                                    }
                                                                                  },
                                                                                  child: Container(
                                                                                    decoration: BoxDecoration(),
                                                                                    child: Padding(
                                                                                      padding: EdgeInsetsDirectional.fromSTEB(6.0, 6.0, 6.0, 6.0),
                                                                                      child: Text(
                                                                                        valueOrDefault<String>(
                                                                                          _model.postReadId !=
                                                                                                  getJsonField(
                                                                                                    postsItem,
                                                                                                    r'''$.id''',
                                                                                                  ).toString()
                                                                                              ? 'Read More'
                                                                                              : 'Read Less',
                                                                                          'Read More',
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
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                Padding(
                                                                  padding: EdgeInsetsDirectional
                                                                      .fromSTEB(
                                                                          20.0,
                                                                          0.0,
                                                                          20.0,
                                                                          0.0),
                                                                  child: custom_widgets
                                                                      .ShowContent(
                                                                    width: double
                                                                        .infinity,
                                                                    height:
                                                                        200.0,
                                                                    currentUserId:
                                                                        currentUserUid,
                                                                    richTextContent:
                                                                        getJsonField(
                                                                      postsItem,
                                                                      r'''$.content''',
                                                                    ),
                                                                    tldrContent:
                                                                        getJsonField(
                                                                      postsItem,
                                                                      r'''$.tldr''',
                                                                    ).toString(),
                                                                  ),
                                                                ),
                                                                if (((String
                                                                        var1) {
                                                                      return var1 !=
                                                                          "null";
                                                                    }(getJsonField(
                                                                      postsItem,
                                                                      r'''$.images''',
                                                                    ).toString())) ==
                                                                    true)
                                                                  Stack(
                                                                    children: [
                                                                      if (((getJsonField(
                                                                                postsItem,
                                                                                r'''$.images''',
                                                                                true,
                                                                              ) as List?)!
                                                                                  .map<String>((e) => e.toString())
                                                                                  .toList()
                                                                                  .cast<String>()
                                                                                  .length ==
                                                                              1) ==
                                                                          true)
                                                                        ClipRRect(
                                                                          borderRadius:
                                                                              BorderRadius.circular(0.0),
                                                                          child:
                                                                              Image.network(
                                                                            getJsonField(
                                                                              postsItem,
                                                                              r'''$.images[0]''',
                                                                            ).toString(),
                                                                            width:
                                                                                double.infinity,
                                                                            fit:
                                                                                BoxFit.contain,
                                                                          ),
                                                                        ),
                                                                    ],
                                                                  ),
                                                              ].divide(SizedBox(
                                                                  height:
                                                                      10.0)),
                                                            ),
                                                            Padding(
                                                              padding:
                                                                  EdgeInsetsDirectional
                                                                      .fromSTEB(
                                                                          14.0,
                                                                          0.0,
                                                                          14.0,
                                                                          0.0),
                                                              child: Row(
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .max,
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                children: [
                                                                  Row(
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .max,
                                                                    children: [
                                                                      InkWell(
                                                                        splashColor:
                                                                            Colors.transparent,
                                                                        focusColor:
                                                                            Colors.transparent,
                                                                        hoverColor:
                                                                            Colors.transparent,
                                                                        highlightColor:
                                                                            Colors.transparent,
                                                                        onTap:
                                                                            () async {
                                                                          _model.addlike222 =
                                                                              await AddLikeCall.call(
                                                                            pCommunityid:
                                                                                FFAppState().communityId.toString(),
                                                                            pUserid:
                                                                                currentUserUid,
                                                                            pPostid:
                                                                                getJsonField(
                                                                              postsItem,
                                                                              r'''$.id''',
                                                                            ).toString(),
                                                                            token:
                                                                                currentJwtToken,
                                                                          );

                                                                          safeSetState(
                                                                              () {});
                                                                        },
                                                                        child:
                                                                            Container(
                                                                          decoration:
                                                                              BoxDecoration(),
                                                                          child:
                                                                              Padding(
                                                                            padding: EdgeInsetsDirectional.fromSTEB(
                                                                                6.0,
                                                                                6.0,
                                                                                4.0,
                                                                                6.0),
                                                                            child:
                                                                                Stack(
                                                                              children: [
                                                                                Icon(
                                                                                  Icons.favorite_border,
                                                                                  color: FlutterFlowTheme.of(context).greyL4,
                                                                                  size: 22.0,
                                                                                ),
                                                                                FutureBuilder<List<PostLikeRow>>(
                                                                                  future: PostLikeTable().querySingleRow(
                                                                                    queryFn: (q) => q
                                                                                        .eqOrNull(
                                                                                          'post_id',
                                                                                          getJsonField(
                                                                                            postsItem,
                                                                                            r'''$.id''',
                                                                                          ).toString(),
                                                                                        )
                                                                                        .eqOrNull(
                                                                                          'user_id',
                                                                                          currentUserUid,
                                                                                        ),
                                                                                  ),
                                                                                  builder: (context, snapshot) {
                                                                                    // Customize what your widget looks like when it's loading.
                                                                                    if (!snapshot.hasData) {
                                                                                      return Container(
                                                                                        width: 22.0,
                                                                                        height: 22.0,
                                                                                        child: CompLoadingWidget(
                                                                                          name: 'like',
                                                                                        ),
                                                                                      );
                                                                                    }
                                                                                    List<PostLikeRow> iconPostLikeRowList = snapshot.data!;

                                                                                    // Return an empty Container when the item does not exist.
                                                                                    if (snapshot.data!.isEmpty) {
                                                                                      return Container();
                                                                                    }
                                                                                    final iconPostLikeRow = iconPostLikeRowList.isNotEmpty ? iconPostLikeRowList.first : null;

                                                                                    return Icon(
                                                                                      Icons.favorite,
                                                                                      color: FlutterFlowTheme.of(context).redColor2,
                                                                                      size: 22.0,
                                                                                    );
                                                                                  },
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      InkWell(
                                                                        splashColor:
                                                                            Colors.transparent,
                                                                        focusColor:
                                                                            Colors.transparent,
                                                                        hoverColor:
                                                                            Colors.transparent,
                                                                        highlightColor:
                                                                            Colors.transparent,
                                                                        onTap:
                                                                            () async {
                                                                          await showModalBottomSheet(
                                                                            isScrollControlled:
                                                                                true,
                                                                            backgroundColor:
                                                                                Colors.transparent,
                                                                            context:
                                                                                context,
                                                                            builder:
                                                                                (context) {
                                                                              return GestureDetector(
                                                                                onTap: () {
                                                                                  FocusScope.of(context).unfocus();
                                                                                  FocusManager.instance.primaryFocus?.unfocus();
                                                                                },
                                                                                child: Padding(
                                                                                  padding: MediaQuery.viewInsetsOf(context),
                                                                                  child: CompLikesWidget(
                                                                                    postId: getJsonField(
                                                                                      postsItem,
                                                                                      r'''$.id''',
                                                                                    ).toString(),
                                                                                    postUserid: getJsonField(
                                                                                      postsItem,
                                                                                      r'''$.user_id''',
                                                                                    ).toString(),
                                                                                  ),
                                                                                ),
                                                                              );
                                                                            },
                                                                          ).then((value) =>
                                                                              safeSetState(() {}));
                                                                        },
                                                                        child:
                                                                            Container(
                                                                          decoration:
                                                                              BoxDecoration(),
                                                                          child:
                                                                              Padding(
                                                                            padding: EdgeInsetsDirectional.fromSTEB(
                                                                                0.0,
                                                                                9.0,
                                                                                16.0,
                                                                                9.0),
                                                                            child:
                                                                                Text(
                                                                              valueOrDefault<String>(
                                                                                getJsonField(
                                                                                  postsItem,
                                                                                  r'''$.likes_count''',
                                                                                )?.toString(),
                                                                                '0',
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
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  InkWell(
                                                                    splashColor:
                                                                        Colors
                                                                            .transparent,
                                                                    focusColor:
                                                                        Colors
                                                                            .transparent,
                                                                    hoverColor:
                                                                        Colors
                                                                            .transparent,
                                                                    highlightColor:
                                                                        Colors
                                                                            .transparent,
                                                                    onTap:
                                                                        () async {
                                                                      _model.apiResultpio22 =
                                                                          await GetPostAllCommentsCall
                                                                              .call(
                                                                        pPostId:
                                                                            getJsonField(
                                                                          postsItem,
                                                                          r'''$.id''',
                                                                        ).toString(),
                                                                        token:
                                                                            currentJwtToken,
                                                                      );

                                                                      FFAppState()
                                                                              .AsComments =
                                                                          getJsonField(
                                                                        (_model.apiResultpio22?.jsonBody ??
                                                                            ''),
                                                                        r'''$.comments''',
                                                                      );
                                                                      FFAppState()
                                                                              .AsCommentReplies =
                                                                          getJsonField(
                                                                        (_model.apiResultpio22?.jsonBody ??
                                                                            ''),
                                                                        r'''$.replies''',
                                                                      );
                                                                      safeSetState(
                                                                          () {});

                                                                      context
                                                                          .pushNamed(
                                                                        CommentsPageWidget
                                                                            .routeName,
                                                                        queryParameters:
                                                                            {
                                                                          'postId':
                                                                              serializeParam(
                                                                            getJsonField(
                                                                              postsItem,
                                                                              r'''$.id''',
                                                                            ).toString(),
                                                                            ParamType.String,
                                                                          ),
                                                                        }.withoutNulls,
                                                                      );

                                                                      safeSetState(
                                                                          () {});
                                                                    },
                                                                    child:
                                                                        Container(
                                                                      decoration:
                                                                          BoxDecoration(),
                                                                      child:
                                                                          Padding(
                                                                        padding: EdgeInsetsDirectional.fromSTEB(
                                                                            6.0,
                                                                            6.0,
                                                                            6.0,
                                                                            6.0),
                                                                        child:
                                                                            Row(
                                                                          mainAxisSize:
                                                                              MainAxisSize.max,
                                                                          children:
                                                                              [
                                                                            ClipRRect(
                                                                              borderRadius: BorderRadius.circular(0.0),
                                                                              child: Image.asset(
                                                                                'assets/images/forum.png',
                                                                                width: 22.0,
                                                                                height: 22.0,
                                                                                fit: BoxFit.cover,
                                                                              ),
                                                                            ),
                                                                            Text(
                                                                              valueOrDefault<String>(
                                                                                getJsonField(
                                                                                  postsItem,
                                                                                  r'''$.comment_count''',
                                                                                )?.toString(),
                                                                                '0',
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
                                                                          ].divide(SizedBox(width: 4.0)),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  InkWell(
                                                                    splashColor:
                                                                        Colors
                                                                            .transparent,
                                                                    focusColor:
                                                                        Colors
                                                                            .transparent,
                                                                    hoverColor:
                                                                        Colors
                                                                            .transparent,
                                                                    highlightColor:
                                                                        Colors
                                                                            .transparent,
                                                                    onTap:
                                                                        () async {
                                                                      await showModalBottomSheet(
                                                                        isScrollControlled:
                                                                            true,
                                                                        backgroundColor:
                                                                            Colors.transparent,
                                                                        context:
                                                                            context,
                                                                        builder:
                                                                            (context) {
                                                                          return GestureDetector(
                                                                            onTap:
                                                                                () {
                                                                              FocusScope.of(context).unfocus();
                                                                              FocusManager.instance.primaryFocus?.unfocus();
                                                                            },
                                                                            child:
                                                                                Padding(
                                                                              padding: MediaQuery.viewInsetsOf(context),
                                                                              child: CompShareWidget(
                                                                                pagename: '',
                                                                                id: '',
                                                                              ),
                                                                            ),
                                                                          );
                                                                        },
                                                                      ).then((value) =>
                                                                          safeSetState(
                                                                              () {}));
                                                                    },
                                                                    child:
                                                                        Container(
                                                                      decoration:
                                                                          BoxDecoration(),
                                                                      child:
                                                                          Padding(
                                                                        padding: EdgeInsetsDirectional.fromSTEB(
                                                                            6.0,
                                                                            6.0,
                                                                            6.0,
                                                                            6.0),
                                                                        child:
                                                                            Row(
                                                                          mainAxisSize:
                                                                              MainAxisSize.max,
                                                                          children:
                                                                              [
                                                                            InkWell(
                                                                              splashColor: Colors.transparent,
                                                                              focusColor: Colors.transparent,
                                                                              hoverColor: Colors.transparent,
                                                                              highlightColor: Colors.transparent,
                                                                              onTap: () async {},
                                                                              child: ClipRRect(
                                                                                borderRadius: BorderRadius.circular(0.0),
                                                                                child: Image.asset(
                                                                                  'assets/images/share_windows.png',
                                                                                  width: 22.0,
                                                                                  height: 22.0,
                                                                                  fit: BoxFit.cover,
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            Text(
                                                                              valueOrDefault<String>(
                                                                                getJsonField(
                                                                                  postsItem,
                                                                                  r'''$.share_count''',
                                                                                )?.toString(),
                                                                                '0',
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
                                                                          ].divide(SizedBox(width: 4.0)),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ]
                                                              .divide(SizedBox(
                                                                  height: 4.0))
                                                              .addToStart(
                                                                  SizedBox(
                                                                      height:
                                                                          12.0))
                                                              .addToEnd(
                                                                  SizedBox(
                                                                      height:
                                                                          6.0)),
                                                        ),
                                                      );
                                                    }).divide(
                                                        SizedBox(height: 8.0)),
                                                  ),
                                                );
                                              },
                                            );
                                          },
                                        ),
                                      ),
                                  ].divide(SizedBox(height: 16.0)),
                                ),
                              ),
                            ),
                          if (_model.optionChoosed == 'neighbourhood')
                            Expanded(
                              child: Align(
                                alignment: AlignmentDirectional(0.0, 0.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    if (((String var1) {
                                          return var1 == "null";
                                        }(getJsonField(
                                          FFAppState().SearchData,
                                          r'''$.nearby_users''',
                                        ).toString())) ==
                                        true)
                                      wrapWithModel(
                                        model: _model.compNoDataFoundModel3,
                                        updateCallback: () =>
                                            safeSetState(() {}),
                                        child: CompNoDataFoundWidget(
                                          pageName: 'neighbourhood',
                                          text1: 'No neighbours found',
                                          text2:
                                              'No one matched your search. Try adjusting the name.',
                                        ),
                                      ),
                                    if (((String var1) {
                                          return var1 == "null";
                                        }(getJsonField(
                                          FFAppState().SearchData,
                                          r'''$.nearby_users''',
                                        ).toString())) ==
                                        false)
                                      Expanded(
                                        child: Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  0.0, 12.0, 0.0, 0.0),
                                          child: FutureBuilder<ApiCallResponse>(
                                            future:
                                                GetSpecifFilterSearchCall.call(
                                              pUserid: currentUserUid,
                                              pCommunityid:
                                                  FFAppState().communityId,
                                              token: currentJwtToken,
                                              pType: 'neighbourhood',
                                              pIdsList:
                                                  functions.returnIdsSearch(
                                                      FFAppState().SearchData,
                                                      'nearby_users'),
                                            ),
                                            builder: (context, snapshot) {
                                              // Customize what your widget looks like when it's loading.
                                              if (!snapshot.hasData) {
                                                return Center(
                                                  child: SizedBox(
                                                    width: 50.0,
                                                    height: 50.0,
                                                    child:
                                                        CircularProgressIndicator(
                                                      valueColor:
                                                          AlwaysStoppedAnimation<
                                                              Color>(
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .primary,
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              }
                                              final neighbourhoodListViewGetSpecifFilterSearchResponse =
                                                  snapshot.data!;

                                              return Builder(
                                                builder: (context) {
                                                  final neighbourhoodData =
                                                      neighbourhoodListViewGetSpecifFilterSearchResponse
                                                          .jsonBody
                                                          .toList();

                                                  return ListView.separated(
                                                    padding:
                                                        EdgeInsets.fromLTRB(
                                                      0,
                                                      12.0,
                                                      0,
                                                      12.0,
                                                    ),
                                                    primary: false,
                                                    shrinkWrap: true,
                                                    scrollDirection:
                                                        Axis.vertical,
                                                    itemCount: neighbourhoodData
                                                        .length,
                                                    separatorBuilder: (_, __) =>
                                                        SizedBox(height: 12.0),
                                                    itemBuilder: (context,
                                                        neighbourhoodDataIndex) {
                                                      final neighbourhoodDataItem =
                                                          neighbourhoodData[
                                                              neighbourhoodDataIndex];
                                                      return Column(
                                                        mainAxisSize:
                                                            MainAxisSize.max,
                                                        children: [
                                                          Padding(
                                                            padding:
                                                                EdgeInsetsDirectional
                                                                    .fromSTEB(
                                                                        20.0,
                                                                        12.0,
                                                                        20.0,
                                                                        12.0),
                                                            child: Row(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .max,
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                Row(
                                                                  mainAxisSize:
                                                                      MainAxisSize
                                                                          .max,
                                                                  children: [
                                                                    Container(
                                                                      width:
                                                                          32.0,
                                                                      height:
                                                                          32.0,
                                                                      clipBehavior:
                                                                          Clip.antiAlias,
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        shape: BoxShape
                                                                            .circle,
                                                                      ),
                                                                      child: Image
                                                                          .network(
                                                                        getJsonField(
                                                                          neighbourhoodDataItem,
                                                                          r'''$.profile_picture''',
                                                                        ).toString(),
                                                                        fit: BoxFit
                                                                            .cover,
                                                                      ),
                                                                    ),
                                                                    Column(
                                                                      mainAxisSize:
                                                                          MainAxisSize
                                                                              .max,
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                        Text(
                                                                          getJsonField(
                                                                            neighbourhoodDataItem,
                                                                            r'''$.name''',
                                                                          ).toString(),
                                                                          style: FlutterFlowTheme.of(context)
                                                                              .bodyMedium
                                                                              .override(
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
                                                                        Text(
                                                                          getJsonField(
                                                                            neighbourhoodDataItem,
                                                                            r'''$.city''',
                                                                          ).toString(),
                                                                          style: FlutterFlowTheme.of(context)
                                                                              .bodyMedium
                                                                              .override(
                                                                                font: GoogleFonts.manrope(
                                                                                  fontWeight: FontWeight.w500,
                                                                                  fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                ),
                                                                                color: FlutterFlowTheme.of(context).greyL4,
                                                                                fontSize: 10.0,
                                                                                letterSpacing: 0.0,
                                                                                fontWeight: FontWeight.w500,
                                                                                fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                lineHeight: 1.4,
                                                                              ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ].divide(SizedBox(
                                                                      width:
                                                                          8.0)),
                                                                ),
                                                                InkWell(
                                                                  splashColor:
                                                                      Colors
                                                                          .transparent,
                                                                  focusColor: Colors
                                                                      .transparent,
                                                                  hoverColor: Colors
                                                                      .transparent,
                                                                  highlightColor:
                                                                      Colors
                                                                          .transparent,
                                                                  onTap:
                                                                      () async {
                                                                    await AddFollowCall
                                                                        .call(
                                                                      pFollowerid:
                                                                          currentUserUid,
                                                                      pFollowingid:
                                                                          getJsonField(
                                                                        neighbourhoodDataItem,
                                                                        r'''$.id''',
                                                                      ).toString(),
                                                                      pCommunityid:
                                                                          FFAppState()
                                                                              .communityId,
                                                                      token:
                                                                          currentJwtToken,
                                                                    );
                                                                  },
                                                                  child:
                                                                      Container(
                                                                    width:
                                                                        100.0,
                                                                    height:
                                                                        30.0,
                                                                    decoration:
                                                                        BoxDecoration(),
                                                                    alignment:
                                                                        AlignmentDirectional(
                                                                            0.0,
                                                                            0.0),
                                                                    child: FutureBuilder<
                                                                        List<
                                                                            FollowsRow>>(
                                                                      future: FollowsTable()
                                                                          .querySingleRow(
                                                                        queryFn: (q) => q
                                                                            .eqOrNull(
                                                                              'follower_id',
                                                                              currentUserUid,
                                                                            )
                                                                            .eqOrNull(
                                                                              'following_id',
                                                                              getJsonField(
                                                                                neighbourhoodDataItem,
                                                                                r'''$.id''',
                                                                              ).toString(),
                                                                            )
                                                                            .order('created_at', ascending: true),
                                                                      ),
                                                                      builder:
                                                                          (context,
                                                                              snapshot) {
                                                                        // Customize what your widget looks like when it's loading.
                                                                        if (!snapshot
                                                                            .hasData) {
                                                                          return CompLoadingWidget(
                                                                            name:
                                                                                'followPost',
                                                                          );
                                                                        }
                                                                        List<FollowsRow>
                                                                            stackFollowsRowList =
                                                                            snapshot.data!;

                                                                        final stackFollowsRow = stackFollowsRowList.isNotEmpty
                                                                            ? stackFollowsRowList.first
                                                                            : null;

                                                                        return Stack(
                                                                          children: [
                                                                            if (stackFollowsRow?.id == null ||
                                                                                stackFollowsRow?.id == '')
                                                                              Row(
                                                                                mainAxisSize: MainAxisSize.max,
                                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                                children: [
                                                                                  Icon(
                                                                                    Icons.add,
                                                                                    color: FlutterFlowTheme.of(context).primaryD3,
                                                                                    size: 14.0,
                                                                                  ),
                                                                                  Text(
                                                                                    'Follow',
                                                                                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                          font: GoogleFonts.manrope(
                                                                                            fontWeight: FontWeight.w600,
                                                                                            fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                          ),
                                                                                          color: FlutterFlowTheme.of(context).primaryD3,
                                                                                          fontSize: 12.0,
                                                                                          letterSpacing: 0.0,
                                                                                          fontWeight: FontWeight.w600,
                                                                                          fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                          lineHeight: 1.4,
                                                                                        ),
                                                                                  ),
                                                                                ].divide(SizedBox(width: 6.0)),
                                                                              ),
                                                                            if (stackFollowsRow?.id != null &&
                                                                                stackFollowsRow?.id != '')
                                                                              Row(
                                                                                mainAxisSize: MainAxisSize.max,
                                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                                children: [
                                                                                  ClipRRect(
                                                                                    borderRadius: BorderRadius.circular(8.0),
                                                                                    child: Image.asset(
                                                                                      'assets/images/check.png',
                                                                                      width: 12.0,
                                                                                      height: 12.0,
                                                                                      fit: BoxFit.cover,
                                                                                    ),
                                                                                  ),
                                                                                  Text(
                                                                                    'Following',
                                                                                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                          font: GoogleFonts.manrope(
                                                                                            fontWeight: FontWeight.w600,
                                                                                            fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                          ),
                                                                                          color: FlutterFlowTheme.of(context).greyL4,
                                                                                          letterSpacing: 0.0,
                                                                                          fontWeight: FontWeight.w600,
                                                                                          fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                          lineHeight: 1.4,
                                                                                        ),
                                                                                  ),
                                                                                ].divide(SizedBox(width: 6.0)),
                                                                              ),
                                                                          ],
                                                                        );
                                                                      },
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          Container(
                                                            width:
                                                                double.infinity,
                                                            height: 1.0,
                                                            decoration:
                                                                BoxDecoration(
                                                              color: FlutterFlowTheme
                                                                      .of(context)
                                                                  .greayL1,
                                                            ),
                                                          ),
                                                        ],
                                                      );
                                                    },
                                                  );
                                                },
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                  ].divide(SizedBox(height: 16.0)),
                                ),
                              ),
                            ),
                          if (_model.optionChoosed == 'business')
                            Expanded(
                              child: Align(
                                alignment: AlignmentDirectional(0.0, 0.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    if (((String var1) {
                                          return var1 == "null";
                                        }(getJsonField(
                                          FFAppState().SearchData,
                                          r'''$.business_pages''',
                                        ).toString())) ==
                                        true)
                                      Expanded(
                                        child: Align(
                                          alignment:
                                              AlignmentDirectional(0.0, 0.0),
                                          child: wrapWithModel(
                                            model: _model.compNoDataFoundModel4,
                                            updateCallback: () =>
                                                safeSetState(() {}),
                                            child: CompNoDataFoundWidget(
                                              pageName: 'yourslisting',
                                              text1: 'No Business found',
                                              text2:
                                                  'No one matched your search. Try adjusting the name.',
                                            ),
                                          ),
                                        ),
                                      ),
                                    if (((String var1) {
                                          return var1 == "null";
                                        }(getJsonField(
                                          FFAppState().SearchData,
                                          r'''$.business_pages''',
                                        ).toString())) ==
                                        false)
                                      Expanded(
                                        child: FutureBuilder<ApiCallResponse>(
                                          future:
                                              GetSpecifFilterSearchCall.call(
                                            pUserid: currentUserUid,
                                            pCommunityid:
                                                FFAppState().communityId,
                                            token: currentJwtToken,
                                            pType: 'business',
                                            pIdsList: functions.returnIdsSearch(
                                                FFAppState().SearchData,
                                                'business_pages'),
                                          ),
                                          builder: (context, snapshot) {
                                            // Customize what your widget looks like when it's loading.
                                            if (!snapshot.hasData) {
                                              return Center(
                                                child: SizedBox(
                                                  width: 50.0,
                                                  height: 50.0,
                                                  child:
                                                      CircularProgressIndicator(
                                                    valueColor:
                                                        AlwaysStoppedAnimation<
                                                            Color>(
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .primary,
                                                    ),
                                                  ),
                                                ),
                                              );
                                            }
                                            final businessListView2GetSpecifFilterSearchResponse =
                                                snapshot.data!;

                                            return Builder(
                                              builder: (context) {
                                                final business =
                                                    businessListView2GetSpecifFilterSearchResponse
                                                        .jsonBody
                                                        .toList();

                                                return ListView.separated(
                                                  padding: EdgeInsets.zero,
                                                  primary: false,
                                                  shrinkWrap: true,
                                                  scrollDirection:
                                                      Axis.vertical,
                                                  itemCount: business.length,
                                                  separatorBuilder: (_, __) =>
                                                      SizedBox(height: 5.0),
                                                  itemBuilder:
                                                      (context, businessIndex) {
                                                    final businessItem =
                                                        business[businessIndex];
                                                    return Column(
                                                      mainAxisSize:
                                                          MainAxisSize.max,
                                                      children: [
                                                        InkWell(
                                                          splashColor: Colors
                                                              .transparent,
                                                          focusColor: Colors
                                                              .transparent,
                                                          hoverColor: Colors
                                                              .transparent,
                                                          highlightColor: Colors
                                                              .transparent,
                                                          onTap: () async {
                                                            context.pushNamed(
                                                              BusinessHomePageWidget
                                                                  .routeName,
                                                              queryParameters: {
                                                                'businessId':
                                                                    serializeParam(
                                                                  getJsonField(
                                                                    businessItem,
                                                                    r'''$.id''',
                                                                  ).toString(),
                                                                  ParamType
                                                                      .String,
                                                                ),
                                                              }.withoutNulls,
                                                            );
                                                          },
                                                          child: Container(
                                                            decoration:
                                                                BoxDecoration(),
                                                            child: Padding(
                                                              padding:
                                                                  EdgeInsetsDirectional
                                                                      .fromSTEB(
                                                                          20.0,
                                                                          16.0,
                                                                          20.0,
                                                                          16.0),
                                                              child: Row(
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .max,
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  ClipRRect(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            8.0),
                                                                    child: Image
                                                                        .network(
                                                                      getJsonField(
                                                                        businessItem,
                                                                        r'''$.profile_picture''',
                                                                      ).toString(),
                                                                      width:
                                                                          64.0,
                                                                      height:
                                                                          64.0,
                                                                      fit: BoxFit
                                                                          .cover,
                                                                    ),
                                                                  ),
                                                                  Flexible(
                                                                    child:
                                                                        Column(
                                                                      mainAxisSize:
                                                                          MainAxisSize
                                                                              .max,
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                        Text(
                                                                          getJsonField(
                                                                            businessItem,
                                                                            r'''$.name''',
                                                                          ).toString(),
                                                                          maxLines:
                                                                              1,
                                                                          style: FlutterFlowTheme.of(context)
                                                                              .bodyMedium
                                                                              .override(
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
                                                                        Text(
                                                                          '${getJsonField(
                                                                            businessItem,
                                                                            r'''$.contacted_count''',
                                                                          ).toString()} people contacted this business',
                                                                          style: FlutterFlowTheme.of(context)
                                                                              .bodyMedium
                                                                              .override(
                                                                                font: GoogleFonts.manrope(
                                                                                  fontWeight: FontWeight.w500,
                                                                                  fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                ),
                                                                                color: FlutterFlowTheme.of(context).greyL4,
                                                                                fontSize: 10.0,
                                                                                letterSpacing: 0.0,
                                                                                fontWeight: FontWeight.w500,
                                                                                fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                lineHeight: 1.4,
                                                                              ),
                                                                        ),
                                                                        Padding(
                                                                          padding: EdgeInsetsDirectional.fromSTEB(
                                                                              0.0,
                                                                              8.0,
                                                                              0.0,
                                                                              0.0),
                                                                          child:
                                                                              Row(
                                                                            mainAxisSize:
                                                                                MainAxisSize.max,
                                                                            children:
                                                                                [
                                                                              Expanded(
                                                                                child: FFButtonWidget(
                                                                                  onPressed: () async {
                                                                                    await showModalBottomSheet(
                                                                                      isScrollControlled: true,
                                                                                      backgroundColor: Colors.transparent,
                                                                                      context: context,
                                                                                      builder: (context) {
                                                                                        return GestureDetector(
                                                                                          onTap: () {
                                                                                            FocusScope.of(context).unfocus();
                                                                                            FocusManager.instance.primaryFocus?.unfocus();
                                                                                          },
                                                                                          child: Padding(
                                                                                            padding: MediaQuery.viewInsetsOf(context),
                                                                                            child: CompBusinessContactWidget(
                                                                                              website: getJsonField(
                                                                                                businessItem,
                                                                                                r'''$.website_link''',
                                                                                              ).toString(),
                                                                                              email: getJsonField(
                                                                                                businessItem,
                                                                                                r'''$.email''',
                                                                                              ).toString(),
                                                                                              mobile: getJsonField(
                                                                                                businessItem,
                                                                                                r'''$.phonenumber''',
                                                                                              ).toString(),
                                                                                              userid: getJsonField(
                                                                                                businessItem,
                                                                                                r'''$.admin_user''',
                                                                                              ).toString(),
                                                                                              businessid: getJsonField(
                                                                                                businessItem,
                                                                                                r'''$.id''',
                                                                                              ).toString(),
                                                                                            ),
                                                                                          ),
                                                                                        );
                                                                                      },
                                                                                    ).then((value) => safeSetState(() {}));
                                                                                  },
                                                                                  text: 'Contact',
                                                                                  icon: Icon(
                                                                                    Icons.arrow_drop_down,
                                                                                    size: 15.0,
                                                                                  ),
                                                                                  options: FFButtonOptions(
                                                                                    height: 24.0,
                                                                                    padding: EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                                                                                    iconAlignment: IconAlignment.end,
                                                                                    iconPadding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                                                                                    iconColor: FlutterFlowTheme.of(context).white,
                                                                                    color: FlutterFlowTheme.of(context).primary,
                                                                                    textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                                                                                          font: GoogleFonts.interTight(
                                                                                            fontWeight: FlutterFlowTheme.of(context).titleSmall.fontWeight,
                                                                                            fontStyle: FlutterFlowTheme.of(context).titleSmall.fontStyle,
                                                                                          ),
                                                                                          color: Colors.white,
                                                                                          fontSize: 12.0,
                                                                                          letterSpacing: 0.0,
                                                                                          fontWeight: FlutterFlowTheme.of(context).titleSmall.fontWeight,
                                                                                          fontStyle: FlutterFlowTheme.of(context).titleSmall.fontStyle,
                                                                                        ),
                                                                                    elevation: 0.0,
                                                                                    borderRadius: BorderRadius.circular(24.0),
                                                                                  ),
                                                                                  showLoadingIndicator: false,
                                                                                ),
                                                                              ),
                                                                              Expanded(
                                                                                child: FFButtonWidget(
                                                                                  onPressed: () async {
                                                                                    await showModalBottomSheet(
                                                                                      isScrollControlled: true,
                                                                                      backgroundColor: Colors.transparent,
                                                                                      context: context,
                                                                                      builder: (context) {
                                                                                        return GestureDetector(
                                                                                          onTap: () {
                                                                                            FocusScope.of(context).unfocus();
                                                                                            FocusManager.instance.primaryFocus?.unfocus();
                                                                                          },
                                                                                          child: Padding(
                                                                                            padding: MediaQuery.viewInsetsOf(context),
                                                                                            child: CompShareGroupWidget(),
                                                                                          ),
                                                                                        );
                                                                                      },
                                                                                    ).then((value) => safeSetState(() {}));
                                                                                  },
                                                                                  text: 'Share',
                                                                                  options: FFButtonOptions(
                                                                                    height: 24.0,
                                                                                    padding: EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                                                                                    iconAlignment: IconAlignment.end,
                                                                                    iconPadding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                                                                                    color: FlutterFlowTheme.of(context).greyL2,
                                                                                    textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                                                                                          font: GoogleFonts.interTight(
                                                                                            fontWeight: FlutterFlowTheme.of(context).titleSmall.fontWeight,
                                                                                            fontStyle: FlutterFlowTheme.of(context).titleSmall.fontStyle,
                                                                                          ),
                                                                                          color: FlutterFlowTheme.of(context).greyD1,
                                                                                          fontSize: 12.0,
                                                                                          letterSpacing: 0.0,
                                                                                          fontWeight: FlutterFlowTheme.of(context).titleSmall.fontWeight,
                                                                                          fontStyle: FlutterFlowTheme.of(context).titleSmall.fontStyle,
                                                                                        ),
                                                                                    elevation: 0.0,
                                                                                    borderRadius: BorderRadius.circular(24.0),
                                                                                  ),
                                                                                  showLoadingIndicator: false,
                                                                                ),
                                                                              ),
                                                                            ].divide(SizedBox(width: 10.0)),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ].divide(SizedBox(
                                                                    width:
                                                                        10.0)),
                                                              ),
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
                                                    );
                                                  },
                                                );
                                              },
                                            );
                                          },
                                        ),
                                      ),
                                  ].divide(SizedBox(height: 16.0)),
                                ),
                              ),
                            ),
                          if (_model.optionChoosed == 'event')
                            Expanded(
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  if (((String var1) {
                                        return var1 == "null";
                                      }(getJsonField(
                                        FFAppState().SearchData,
                                        r'''$.events''',
                                      ).toString())) ==
                                      true)
                                    Expanded(
                                      child: Align(
                                        alignment:
                                            AlignmentDirectional(0.0, 0.0),
                                        child: wrapWithModel(
                                          model: _model.compNoDataFoundModel5,
                                          updateCallback: () =>
                                              safeSetState(() {}),
                                          child: CompNoDataFoundWidget(
                                            pageName: 'yourslisting',
                                            text1: 'No Business found',
                                            text2:
                                                'No one matched your search. Try adjusting the name.',
                                          ),
                                        ),
                                      ),
                                    ),
                                  FutureBuilder<ApiCallResponse>(
                                    future: (_model.apiRequestCompleter3 ??=
                                            Completer<ApiCallResponse>()
                                              ..complete(
                                                  GetSpecifFilterSearchCall
                                                      .call(
                                                pUserid: currentUserUid,
                                                pCommunityid:
                                                    FFAppState().communityId,
                                                token: currentJwtToken,
                                                pType: 'event',
                                                pIdsList:
                                                    functions.returnIdsSearch(
                                                        FFAppState().SearchData,
                                                        'events'),
                                              )))
                                        .future,
                                    builder: (context, snapshot) {
                                      // Customize what your widget looks like when it's loading.
                                      if (!snapshot.hasData) {
                                        return CompLoadingWidget(
                                          name: 'eventList',
                                        );
                                      }
                                      final allEventsListViewGetSpecifFilterSearchResponse =
                                          snapshot.data!;

                                      return Builder(
                                        builder: (context) {
                                          final events =
                                              (GetSpecifFilterSearchCall
                                                          .eventData(
                                                        allEventsListViewGetSpecifFilterSearchResponse
                                                            .jsonBody,
                                                      )?.toList() ??
                                                      [])
                                                  .take(4)
                                                  .toList();

                                          return ListView.separated(
                                            padding: EdgeInsets.fromLTRB(
                                              0,
                                              0,
                                              0,
                                              20.0,
                                            ),
                                            shrinkWrap: true,
                                            scrollDirection: Axis.vertical,
                                            itemCount: events.length,
                                            separatorBuilder: (_, __) =>
                                                SizedBox(height: 12.0),
                                            itemBuilder:
                                                (context, eventsIndex) {
                                              final eventsItem =
                                                  events[eventsIndex];
                                              return Padding(
                                                padding: EdgeInsetsDirectional
                                                    .fromSTEB(
                                                        20.0, 0.0, 20.0, 0.0),
                                                child: FutureBuilder<
                                                    List<EventAttendingRow>>(
                                                  future: EventAttendingTable()
                                                      .querySingleRow(
                                                    queryFn: (q) => q
                                                        .eqOrNull(
                                                          'event_id',
                                                          getJsonField(
                                                            eventsItem,
                                                            r'''$.id''',
                                                          ).toString(),
                                                        )
                                                        .eqOrNull(
                                                          'attending_id',
                                                          currentUserUid,
                                                        ),
                                                  ),
                                                  builder: (context, snapshot) {
                                                    // Customize what your widget looks like when it's loading.
                                                    if (!snapshot.hasData) {
                                                      return Center(
                                                        child: SizedBox(
                                                          width: 50.0,
                                                          height: 50.0,
                                                          child:
                                                              CircularProgressIndicator(
                                                            valueColor:
                                                                AlwaysStoppedAnimation<
                                                                    Color>(
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .primary,
                                                            ),
                                                          ),
                                                        ),
                                                      );
                                                    }
                                                    List<EventAttendingRow>
                                                        containerEventAttendingRowList =
                                                        snapshot.data!;

                                                    final containerEventAttendingRow =
                                                        containerEventAttendingRowList
                                                                .isNotEmpty
                                                            ? containerEventAttendingRowList
                                                                .first
                                                            : null;

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
                                                        context.pushNamed(
                                                          EventDetailsWidget
                                                              .routeName,
                                                          queryParameters: {
                                                            'eventId':
                                                                serializeParam(
                                                              getJsonField(
                                                                eventsItem,
                                                                r'''$.id''',
                                                              ).toString(),
                                                              ParamType.String,
                                                            ),
                                                          }.withoutNulls,
                                                        );
                                                      },
                                                      child: Container(
                                                        height: 188.0,
                                                        decoration:
                                                            BoxDecoration(),
                                                        child: Padding(
                                                          padding:
                                                              EdgeInsetsDirectional
                                                                  .fromSTEB(
                                                                      0.0,
                                                                      8.0,
                                                                      0.0,
                                                                      8.0),
                                                          child: Row(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .max,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              ClipRRect(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            2.0),
                                                                child: Image
                                                                    .network(
                                                                  getJsonField(
                                                                    eventsItem,
                                                                    r'''$.cover_image''',
                                                                  ).toString(),
                                                                  width: 120.0,
                                                                  height: 120.0,
                                                                  fit: BoxFit
                                                                      .cover,
                                                                ),
                                                              ),
                                                              Expanded(
                                                                child: Column(
                                                                  mainAxisSize:
                                                                      MainAxisSize
                                                                          .max,
                                                                  children: [
                                                                    Expanded(
                                                                      child:
                                                                          Column(
                                                                        mainAxisSize:
                                                                            MainAxisSize.max,
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.start,
                                                                        children: [
                                                                          if ((containerEventAttendingRow?.id != null && containerEventAttendingRow?.id != '') &&
                                                                              (containerEventAttendingRow?.isInvited == true))
                                                                            FutureBuilder<List<PublicUserProfileRow>>(
                                                                              future: PublicUserProfileTable().querySingleRow(
                                                                                queryFn: (q) => q.eqOrNull(
                                                                                  'id',
                                                                                  containerEventAttendingRow?.invitedBy,
                                                                                ),
                                                                              ),
                                                                              builder: (context, snapshot) {
                                                                                // Customize what your widget looks like when it's loading.
                                                                                if (!snapshot.hasData) {
                                                                                  return CompLoadingWidget(
                                                                                    name: 'loading',
                                                                                  );
                                                                                }
                                                                                List<PublicUserProfileRow> rowPublicUserProfileRowList = snapshot.data!;

                                                                                // Return an empty Container when the item does not exist.
                                                                                if (snapshot.data!.isEmpty) {
                                                                                  return Container();
                                                                                }
                                                                                final rowPublicUserProfileRow = rowPublicUserProfileRowList.isNotEmpty ? rowPublicUserProfileRowList.first : null;

                                                                                return Row(
                                                                                  mainAxisSize: MainAxisSize.max,
                                                                                  children: [
                                                                                    Container(
                                                                                      width: 12.0,
                                                                                      height: 12.0,
                                                                                      clipBehavior: Clip.antiAlias,
                                                                                      decoration: BoxDecoration(
                                                                                        shape: BoxShape.circle,
                                                                                      ),
                                                                                      child: Image.network(
                                                                                        rowPublicUserProfileRow!.profilePicture!,
                                                                                        fit: BoxFit.cover,
                                                                                      ),
                                                                                    ),
                                                                                    Expanded(
                                                                                      child: Row(
                                                                                        mainAxisSize: MainAxisSize.max,
                                                                                        children: [
                                                                                          Text(
                                                                                            valueOrDefault<String>(
                                                                                              rowPublicUserProfileRow?.name,
                                                                                              'name  jjhgjh jhjhjh jhjhjhj',
                                                                                            ),
                                                                                            style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                                  font: GoogleFonts.manrope(
                                                                                                    fontWeight: FontWeight.w500,
                                                                                                    fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                  ),
                                                                                                  color: FlutterFlowTheme.of(context).greyL4,
                                                                                                  fontSize: 10.0,
                                                                                                  letterSpacing: 0.0,
                                                                                                  fontWeight: FontWeight.w500,
                                                                                                  fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                  lineHeight: 1.4,
                                                                                                ),
                                                                                          ),
                                                                                          Expanded(
                                                                                            child: Text(
                                                                                              ' invited you to join this event',
                                                                                              maxLines: 1,
                                                                                              style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                                    font: GoogleFonts.manrope(
                                                                                                      fontWeight: FontWeight.w500,
                                                                                                      fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                    ),
                                                                                                    color: FlutterFlowTheme.of(context).greyL4,
                                                                                                    fontSize: 10.0,
                                                                                                    letterSpacing: 0.0,
                                                                                                    fontWeight: FontWeight.w500,
                                                                                                    fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                    lineHeight: 1.4,
                                                                                                  ),
                                                                                            ),
                                                                                          ),
                                                                                        ],
                                                                                      ),
                                                                                    ),
                                                                                  ].divide(SizedBox(width: 10.0)),
                                                                                );
                                                                              },
                                                                            ),
                                                                          Column(
                                                                            mainAxisSize:
                                                                                MainAxisSize.max,
                                                                            crossAxisAlignment:
                                                                                CrossAxisAlignment.start,
                                                                            children:
                                                                                [
                                                                              Text(
                                                                                getJsonField(
                                                                                  eventsItem,
                                                                                  r'''$.name''',
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
                                                                              Text(
                                                                                getJsonField(
                                                                                  eventsItem,
                                                                                  r'''$.description''',
                                                                                ).toString(),
                                                                                maxLines: 2,
                                                                                style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                      font: GoogleFonts.manrope(
                                                                                        fontWeight: FontWeight.w500,
                                                                                        fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                      ),
                                                                                      color: FlutterFlowTheme.of(context).greyL4,
                                                                                      fontSize: 10.0,
                                                                                      letterSpacing: 0.0,
                                                                                      fontWeight: FontWeight.w500,
                                                                                      fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                      lineHeight: 1.4,
                                                                                    ),
                                                                              ),
                                                                            ].divide(SizedBox(height: 2.0)),
                                                                          ),
                                                                          Padding(
                                                                            padding: EdgeInsetsDirectional.fromSTEB(
                                                                                0.0,
                                                                                4.0,
                                                                                0.0,
                                                                                0.0),
                                                                            child:
                                                                                Column(
                                                                              mainAxisSize: MainAxisSize.max,
                                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                                              children: [
                                                                                Row(
                                                                                  mainAxisSize: MainAxisSize.max,
                                                                                  children: [
                                                                                    ClipRRect(
                                                                                      borderRadius: BorderRadius.circular(0.0),
                                                                                      child: Image.asset(
                                                                                        'assets/images/calendar_clock.png',
                                                                                        width: 16.0,
                                                                                        height: 16.0,
                                                                                        fit: BoxFit.cover,
                                                                                      ),
                                                                                    ),
                                                                                    Text(
                                                                                      getJsonField(
                                                                                        eventsItem,
                                                                                        r'''$.start_date_time''',
                                                                                      ).toString(),
                                                                                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                            font: GoogleFonts.manrope(
                                                                                              fontWeight: FontWeight.w500,
                                                                                              fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                            ),
                                                                                            color: FlutterFlowTheme.of(context).greyL4,
                                                                                            fontSize: 10.0,
                                                                                            letterSpacing: 0.0,
                                                                                            fontWeight: FontWeight.w500,
                                                                                            fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                            lineHeight: 1.4,
                                                                                          ),
                                                                                    ),
                                                                                  ].divide(SizedBox(width: 6.0)),
                                                                                ),
                                                                                Row(
                                                                                  mainAxisSize: MainAxisSize.max,
                                                                                  children: [
                                                                                    ClipRRect(
                                                                                      borderRadius: BorderRadius.circular(0.0),
                                                                                      child: Image.asset(
                                                                                        'assets/images/explore.png',
                                                                                        width: 16.0,
                                                                                        height: 16.0,
                                                                                        fit: BoxFit.cover,
                                                                                      ),
                                                                                    ),
                                                                                    Expanded(
                                                                                      child: Text(
                                                                                        getJsonField(
                                                                                          eventsItem,
                                                                                          r'''$.Adderss''',
                                                                                        ).toString(),
                                                                                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                              font: GoogleFonts.manrope(
                                                                                                fontWeight: FontWeight.w500,
                                                                                                fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                              ),
                                                                                              color: FlutterFlowTheme.of(context).greyL4,
                                                                                              fontSize: 10.0,
                                                                                              letterSpacing: 0.0,
                                                                                              fontWeight: FontWeight.w500,
                                                                                              fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                              lineHeight: 1.4,
                                                                                            ),
                                                                                      ),
                                                                                    ),
                                                                                  ].divide(SizedBox(width: 6.0)),
                                                                                ),
                                                                                Row(
                                                                                  mainAxisSize: MainAxisSize.max,
                                                                                  children: [
                                                                                    ClipRRect(
                                                                                      borderRadius: BorderRadius.circular(0.0),
                                                                                      child: Image.asset(
                                                                                        'assets/images/crowdsource_(1).png',
                                                                                        width: 16.0,
                                                                                        height: 16.0,
                                                                                        fit: BoxFit.cover,
                                                                                      ),
                                                                                    ),
                                                                                    Text(
                                                                                      '${getJsonField(
                                                                                        eventsItem,
                                                                                        r'''$.attendee_count''',
                                                                                      ).toString()}  attending',
                                                                                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                            font: GoogleFonts.manrope(
                                                                                              fontWeight: FontWeight.w500,
                                                                                              fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                            ),
                                                                                            color: FlutterFlowTheme.of(context).greyL4,
                                                                                            fontSize: 10.0,
                                                                                            letterSpacing: 0.0,
                                                                                            fontWeight: FontWeight.w500,
                                                                                            fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                            lineHeight: 1.4,
                                                                                          ),
                                                                                    ),
                                                                                  ].divide(SizedBox(width: 6.0)),
                                                                                ),
                                                                              ].divide(SizedBox(height: 4.0)),
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                    Stack(
                                                                      children: [
                                                                        FFButtonWidget(
                                                                          onPressed:
                                                                              () async {
                                                                            await EventAttendingTable().insert({
                                                                              'community_id': FFAppState().communityId,
                                                                              'event_id': getJsonField(
                                                                                eventsItem,
                                                                                r'''$.id''',
                                                                              ).toString(),
                                                                              'attending_id': currentUserUid,
                                                                              'is_invited': false,
                                                                              'is_attending': true,
                                                                            });
                                                                            _model.apiResultrykremmm =
                                                                                await UpdateEventAttendeeCountCall.call(
                                                                              token: currentJwtToken,
                                                                              eventId: containerEventAttendingRow?.id,
                                                                            );

                                                                            safeSetState(() {});
                                                                          },
                                                                          text:
                                                                              'Attend',
                                                                          icon:
                                                                              Icon(
                                                                            Icons.edit_calendar_outlined,
                                                                            size:
                                                                                15.0,
                                                                          ),
                                                                          options:
                                                                              FFButtonOptions(
                                                                            width:
                                                                                double.infinity,
                                                                            height:
                                                                                24.0,
                                                                            padding: EdgeInsetsDirectional.fromSTEB(
                                                                                16.0,
                                                                                0.0,
                                                                                16.0,
                                                                                0.0),
                                                                            iconPadding: EdgeInsetsDirectional.fromSTEB(
                                                                                0.0,
                                                                                0.0,
                                                                                0.0,
                                                                                0.0),
                                                                            color:
                                                                                FlutterFlowTheme.of(context).white,
                                                                            textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                                                                                  font: GoogleFonts.interTight(
                                                                                    fontWeight: FlutterFlowTheme.of(context).titleSmall.fontWeight,
                                                                                    fontStyle: FlutterFlowTheme.of(context).titleSmall.fontStyle,
                                                                                  ),
                                                                                  color: FlutterFlowTheme.of(context).primaryD3,
                                                                                  fontSize: 12.0,
                                                                                  letterSpacing: 0.0,
                                                                                  fontWeight: FlutterFlowTheme.of(context).titleSmall.fontWeight,
                                                                                  fontStyle: FlutterFlowTheme.of(context).titleSmall.fontStyle,
                                                                                ),
                                                                            elevation:
                                                                                0.0,
                                                                            borderSide:
                                                                                BorderSide(
                                                                              color: FlutterFlowTheme.of(context).primaryD3,
                                                                              width: 1.0,
                                                                            ),
                                                                            borderRadius:
                                                                                BorderRadius.only(
                                                                              topLeft: Radius.circular(100.0),
                                                                              topRight: Radius.circular(100.0),
                                                                              bottomLeft: Radius.circular(100.0),
                                                                              bottomRight: Radius.circular(100.0),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        if ((containerEventAttendingRow?.id != null && containerEventAttendingRow?.id != '') &&
                                                                            (containerEventAttendingRow?.isAttending ==
                                                                                false))
                                                                          FFButtonWidget(
                                                                            onPressed:
                                                                                () async {
                                                                              await EventAttendingTable().update(
                                                                                data: {
                                                                                  'is_attending': true,
                                                                                },
                                                                                matchingRows: (rows) => rows
                                                                                    .eqOrNull(
                                                                                      'event_id',
                                                                                      getJsonField(
                                                                                        eventsItem,
                                                                                        r'''$.id''',
                                                                                      ).toString(),
                                                                                    )
                                                                                    .eqOrNull(
                                                                                      'attending_id',
                                                                                      currentUserUid,
                                                                                    ),
                                                                              );
                                                                              _model.apiResultrykuu = await UpdateEventAttendeeCountCall.call(
                                                                                token: currentJwtToken,
                                                                                eventId: containerEventAttendingRow?.id,
                                                                              );

                                                                              safeSetState(() {});
                                                                            },
                                                                            text:
                                                                                'Attend',
                                                                            icon:
                                                                                Icon(
                                                                              Icons.edit_calendar_outlined,
                                                                              size: 15.0,
                                                                            ),
                                                                            options:
                                                                                FFButtonOptions(
                                                                              width: double.infinity,
                                                                              height: 24.0,
                                                                              padding: EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                                                                              iconPadding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                                                                              color: FlutterFlowTheme.of(context).white,
                                                                              textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                                                                                    font: GoogleFonts.interTight(
                                                                                      fontWeight: FlutterFlowTheme.of(context).titleSmall.fontWeight,
                                                                                      fontStyle: FlutterFlowTheme.of(context).titleSmall.fontStyle,
                                                                                    ),
                                                                                    color: FlutterFlowTheme.of(context).primaryD3,
                                                                                    fontSize: 12.0,
                                                                                    letterSpacing: 0.0,
                                                                                    fontWeight: FlutterFlowTheme.of(context).titleSmall.fontWeight,
                                                                                    fontStyle: FlutterFlowTheme.of(context).titleSmall.fontStyle,
                                                                                  ),
                                                                              elevation: 0.0,
                                                                              borderSide: BorderSide(
                                                                                color: FlutterFlowTheme.of(context).primaryD3,
                                                                                width: 1.0,
                                                                              ),
                                                                              borderRadius: BorderRadius.only(
                                                                                topLeft: Radius.circular(100.0),
                                                                                topRight: Radius.circular(100.0),
                                                                                bottomLeft: Radius.circular(100.0),
                                                                                bottomRight: Radius.circular(100.0),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        if ((containerEventAttendingRow?.id != null && containerEventAttendingRow?.id != '') &&
                                                                            (containerEventAttendingRow?.isAttending ==
                                                                                true))
                                                                          FFButtonWidget(
                                                                            onPressed:
                                                                                () async {
                                                                              await EventAttendingTable().update(
                                                                                data: {
                                                                                  'is_attending': false,
                                                                                },
                                                                                matchingRows: (rows) => rows
                                                                                    .eqOrNull(
                                                                                      'event_id',
                                                                                      getJsonField(
                                                                                        eventsItem,
                                                                                        r'''$.id''',
                                                                                      ).toString(),
                                                                                    )
                                                                                    .eqOrNull(
                                                                                      'attending_id',
                                                                                      currentUserUid,
                                                                                    ),
                                                                              );
                                                                              _model.kk = await UpdateEventAttendeeCountCall.call(
                                                                                token: currentJwtToken,
                                                                                eventId: containerEventAttendingRow?.id,
                                                                              );

                                                                              safeSetState(() {});
                                                                            },
                                                                            text:
                                                                                'Attending',
                                                                            icon:
                                                                                Icon(
                                                                              Icons.edit_calendar_outlined,
                                                                              size: 15.0,
                                                                            ),
                                                                            options:
                                                                                FFButtonOptions(
                                                                              width: double.infinity,
                                                                              height: 24.0,
                                                                              padding: EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                                                                              iconPadding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                                                                              color: FlutterFlowTheme.of(context).white,
                                                                              textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                                                                                    font: GoogleFonts.interTight(
                                                                                      fontWeight: FlutterFlowTheme.of(context).titleSmall.fontWeight,
                                                                                      fontStyle: FlutterFlowTheme.of(context).titleSmall.fontStyle,
                                                                                    ),
                                                                                    color: FlutterFlowTheme.of(context).greyL4,
                                                                                    fontSize: 12.0,
                                                                                    letterSpacing: 0.0,
                                                                                    fontWeight: FlutterFlowTheme.of(context).titleSmall.fontWeight,
                                                                                    fontStyle: FlutterFlowTheme.of(context).titleSmall.fontStyle,
                                                                                  ),
                                                                              elevation: 0.0,
                                                                              borderSide: BorderSide(
                                                                                color: FlutterFlowTheme.of(context).greyL4,
                                                                                width: 1.0,
                                                                              ),
                                                                              borderRadius: BorderRadius.only(
                                                                                topLeft: Radius.circular(100.0),
                                                                                topRight: Radius.circular(100.0),
                                                                                bottomLeft: Radius.circular(100.0),
                                                                                bottomRight: Radius.circular(100.0),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                      ],
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ].divide(SizedBox(
                                                                width: 8.0)),
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ),
                                              );
                                            },
                                          );
                                        },
                                      );
                                    },
                                  ),
                                ].divide(SizedBox(height: 16.0)),
                              ),
                            ),
                          if (_model.optionChoosed == 'group')
                            Expanded(
                              child: Align(
                                alignment: AlignmentDirectional(0.0, 0.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    if (((String var1) {
                                          return var1 != "null";
                                        }(getJsonField(
                                          FFAppState().SearchData,
                                          r'''$.groups''',
                                        ).toString())) ==
                                        false)
                                      wrapWithModel(
                                        model: _model.compNoDataFoundModel6,
                                        updateCallback: () =>
                                            safeSetState(() {}),
                                        child: CompNoDataFoundWidget(
                                          pageName: 'group',
                                          text1: 'No groups found',
                                          text2:
                                              'We couldn’t find any groups with that name. Try another search.',
                                        ),
                                      ),
                                    if (((String var1) {
                                          return var1 != "null";
                                        }(getJsonField(
                                          FFAppState().SearchData,
                                          r'''$.groups''',
                                        ).toString())) ==
                                        true)
                                      Expanded(
                                        child: SingleChildScrollView(
                                          child: Column(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Container(
                                                decoration: BoxDecoration(
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .white,
                                                ),
                                                child: Builder(
                                                  builder: (context) {
                                                    final groups = getJsonField(
                                                      FFAppState().SearchData,
                                                      r'''$.groups''',
                                                    ).toList();

                                                    return ListView.separated(
                                                      padding:
                                                          EdgeInsets.fromLTRB(
                                                        0,
                                                        12.0,
                                                        0,
                                                        12.0,
                                                      ),
                                                      primary: false,
                                                      shrinkWrap: true,
                                                      scrollDirection:
                                                          Axis.vertical,
                                                      itemCount: groups.length,
                                                      separatorBuilder:
                                                          (_, __) => SizedBox(
                                                              height: 12.0),
                                                      itemBuilder: (context,
                                                          groupsIndex) {
                                                        final groupsItem =
                                                            groups[groupsIndex];
                                                        return FutureBuilder<
                                                            ApiCallResponse>(
                                                          future:
                                                              SpecificGroupCall
                                                                  .call(
                                                            apiKey:
                                                                FFDevEnvironmentValues()
                                                                    .AnonKey,
                                                            token:
                                                                currentJwtToken,
                                                            pGroupId:
                                                                getJsonField(
                                                              groupsItem,
                                                              r'''$.id''',
                                                            ).toString(),
                                                          ),
                                                          builder: (context,
                                                              snapshot) {
                                                            // Customize what your widget looks like when it's loading.
                                                            if (!snapshot
                                                                .hasData) {
                                                              return CompLoadingWidget(
                                                                name: 'group',
                                                              );
                                                            }
                                                            final containerSpecificGroupResponse =
                                                                snapshot.data!;

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
                                                                context
                                                                    .pushNamed(
                                                                  GroupDetailsWidget
                                                                      .routeName,
                                                                  queryParameters:
                                                                      {
                                                                    'groupId':
                                                                        serializeParam(
                                                                      getJsonField(
                                                                        groupsItem,
                                                                        r'''$.group_id''',
                                                                      ).toString(),
                                                                      ParamType
                                                                          .String,
                                                                    ),
                                                                  }.withoutNulls,
                                                                );
                                                              },
                                                              child: Container(
                                                                width: double
                                                                    .infinity,
                                                                height: 56.0,
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .secondaryBackground,
                                                                ),
                                                                child: Padding(
                                                                  padding: EdgeInsetsDirectional
                                                                      .fromSTEB(
                                                                          20.0,
                                                                          8.0,
                                                                          20.0,
                                                                          8.0),
                                                                  child: Row(
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .max,
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .spaceBetween,
                                                                    children: [
                                                                      Expanded(
                                                                        child:
                                                                            Row(
                                                                          mainAxisSize:
                                                                              MainAxisSize.max,
                                                                          children:
                                                                              [
                                                                            ClipRRect(
                                                                              borderRadius: BorderRadius.circular(2.0),
                                                                              child: Image.network(
                                                                                SpecificGroupCall.profilepicture(
                                                                                  containerSpecificGroupResponse.jsonBody,
                                                                                )!,
                                                                                width: 40.0,
                                                                                height: 40.0,
                                                                                fit: BoxFit.cover,
                                                                              ),
                                                                            ),
                                                                            Expanded(
                                                                              child: Column(
                                                                                mainAxisSize: MainAxisSize.max,
                                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                                children: [
                                                                                  if (('${getJsonField(
                                                                                            containerSpecificGroupResponse.jsonBody,
                                                                                            r'''$[:].invited_by_user_id''',
                                                                                          ).toString()}' !=
                                                                                          'null') &&
                                                                                      ('${getJsonField(
                                                                                            containerSpecificGroupResponse.jsonBody,
                                                                                            r'''$[:].user_status''',
                                                                                          ).toString()}' ==
                                                                                          'invite'))
                                                                                    Row(
                                                                                      mainAxisSize: MainAxisSize.max,
                                                                                      children: [
                                                                                        Container(
                                                                                          width: 12.0,
                                                                                          height: 12.0,
                                                                                          clipBehavior: Clip.antiAlias,
                                                                                          decoration: BoxDecoration(
                                                                                            shape: BoxShape.circle,
                                                                                          ),
                                                                                          child: Image.network(
                                                                                            getJsonField(
                                                                                              containerSpecificGroupResponse.jsonBody,
                                                                                              r'''$[:].invited_by_profile_picture''',
                                                                                            ).toString(),
                                                                                            fit: BoxFit.cover,
                                                                                          ),
                                                                                        ),
                                                                                        Expanded(
                                                                                          child: Text(
                                                                                            '${getJsonField(
                                                                                              containerSpecificGroupResponse.jsonBody,
                                                                                              r'''$[:].invited_by_name''',
                                                                                            ).toString()} invited you to join this group ',
                                                                                            maxLines: 1,
                                                                                            style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                                  font: GoogleFonts.manrope(
                                                                                                    fontWeight: FontWeight.w500,
                                                                                                    fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                  ),
                                                                                                  color: FlutterFlowTheme.of(context).greyL4,
                                                                                                  fontSize: 10.0,
                                                                                                  letterSpacing: 0.0,
                                                                                                  fontWeight: FontWeight.w500,
                                                                                                  fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                  lineHeight: 1.4,
                                                                                                ),
                                                                                          ),
                                                                                        ),
                                                                                      ].divide(SizedBox(width: 6.0)),
                                                                                    ),
                                                                                  Text(
                                                                                    getJsonField(
                                                                                      containerSpecificGroupResponse.jsonBody,
                                                                                      r'''$[:].name''',
                                                                                    ).toString(),
                                                                                    maxLines: 1,
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
                                                                                  if ('${getJsonField(
                                                                                        containerSpecificGroupResponse.jsonBody,
                                                                                        r'''$[:].user_status''',
                                                                                      ).toString()}' !=
                                                                                      'invite')
                                                                                    Text(
                                                                                      '${getJsonField(
                                                                                        containerSpecificGroupResponse.jsonBody,
                                                                                        r'''$[:].total_members''',
                                                                                      ).toString()} ${'${getJsonField(
                                                                                            containerSpecificGroupResponse.jsonBody,
                                                                                            r'''$[:].total_members''',
                                                                                          ).toString()}' == '1' ? 'member' : 'members'}',
                                                                                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                            font: GoogleFonts.manrope(
                                                                                              fontWeight: FontWeight.w500,
                                                                                              fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                            ),
                                                                                            color: FlutterFlowTheme.of(context).greyL4,
                                                                                            fontSize: 10.0,
                                                                                            letterSpacing: 0.0,
                                                                                            fontWeight: FontWeight.w500,
                                                                                            fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                            lineHeight: 1.4,
                                                                                          ),
                                                                                    ),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                          ].divide(SizedBox(width: 8.0)),
                                                                        ),
                                                                      ),
                                                                      Stack(
                                                                        children: [
                                                                          if ('${getJsonField(
                                                                                containerSpecificGroupResponse.jsonBody,
                                                                                r'''$[:].user_status''',
                                                                              ).toString()}' ==
                                                                              'join')
                                                                            FFButtonWidget(
                                                                              onPressed: () async {
                                                                                await GroupMembersTable().insert({
                                                                                  'community_id': FFAppState().communityId,
                                                                                  'user_id': currentUserUid,
                                                                                  'group_id': getJsonField(
                                                                                    containerSpecificGroupResponse.jsonBody,
                                                                                    r'''$[:].group_id''',
                                                                                  ).toString(),
                                                                                  'is_requested': false,
                                                                                  'requested_date': supaSerialize<DateTime>(functions.getCurrentUtcTime()),
                                                                                  'is_approved': true,
                                                                                  'approved_by': currentUserUid,
                                                                                  'joined_at': supaSerialize<DateTime>(functions.getCurrentUtcTime()),
                                                                                });
                                                                                await GroupUserStatusTable().insert({
                                                                                  'community_id': FFAppState().communityId,
                                                                                  'user_id': currentUserUid,
                                                                                  'group_id': getJsonField(
                                                                                    containerSpecificGroupResponse.jsonBody,
                                                                                    r'''$[:].group_id''',
                                                                                  ).toString(),
                                                                                  'is_requested': false,
                                                                                  'is_invited': false,
                                                                                  'is_member': true,
                                                                                  'joined_at': supaSerialize<DateTime>(functions.getCurrentUtcTime()),
                                                                                });
                                                                                _model.apiResultd2p5bvv = await UpdateTotalGroupMembersCall.call(
                                                                                  token: currentJwtToken,
                                                                                  anonKey: FFDevEnvironmentValues().AnonKey,
                                                                                  groupId: getJsonField(
                                                                                    containerSpecificGroupResponse.jsonBody,
                                                                                    r'''$[:].group_id''',
                                                                                  ).toString(),
                                                                                );

                                                                                if ((String var1) {
                                                                                  return var1.length >= 3;
                                                                                }(_model.textController.text)) {
                                                                                  _model.searchEmpty = false;
                                                                                  safeSetState(() {});
                                                                                  _model.apiResulth6nttzx = await GetAllSearchCall.call(
                                                                                    pSearchText: _model.textController.text,
                                                                                    pUserid: currentUserUid,
                                                                                    pCommunityid: FFAppState().communityId,
                                                                                    token: currentJwtToken,
                                                                                    pType: _model.optionChoosed,
                                                                                    pCategory: FFAppState().SalesFilter,
                                                                                    pSaleType: FFAppState().SalesTypeFilter,
                                                                                    pSort: FFAppState().SalesSort,
                                                                                    pDistance: FFAppState().SalesKmFilter,
                                                                                  );

                                                                                  if ((_model.apiResulth6n?.succeeded ?? true)) {
                                                                                    FFAppState().SearchData = (_model.apiResulth6n?.jsonBody ?? '');
                                                                                    safeSetState(() {});
                                                                                  }
                                                                                } else {
                                                                                  if (_model.textController.text.length == 0) {
                                                                                    _model.searchEmpty = true;
                                                                                    safeSetState(() {});
                                                                                  } else {
                                                                                    _model.searchEmpty = false;
                                                                                    safeSetState(() {});
                                                                                  }
                                                                                }

                                                                                safeSetState(() {});
                                                                              },
                                                                              text: 'Join',
                                                                              options: FFButtonOptions(
                                                                                height: 24.0,
                                                                                padding: EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                                                                                iconPadding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                                                                                color: Color(0x00264AFF),
                                                                                textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                                                                                      font: GoogleFonts.interTight(
                                                                                        fontWeight: FlutterFlowTheme.of(context).titleSmall.fontWeight,
                                                                                        fontStyle: FlutterFlowTheme.of(context).titleSmall.fontStyle,
                                                                                      ),
                                                                                      color: FlutterFlowTheme.of(context).primaryD3,
                                                                                      fontSize: 12.0,
                                                                                      letterSpacing: 0.0,
                                                                                      fontWeight: FlutterFlowTheme.of(context).titleSmall.fontWeight,
                                                                                      fontStyle: FlutterFlowTheme.of(context).titleSmall.fontStyle,
                                                                                    ),
                                                                                elevation: 0.0,
                                                                                borderSide: BorderSide(
                                                                                  color: FlutterFlowTheme.of(context).primaryD3,
                                                                                  width: 1.0,
                                                                                ),
                                                                                borderRadius: BorderRadius.only(
                                                                                  topLeft: Radius.circular(100.0),
                                                                                  topRight: Radius.circular(100.0),
                                                                                  bottomLeft: Radius.circular(100.0),
                                                                                  bottomRight: Radius.circular(100.0),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          if ('${getJsonField(
                                                                                containerSpecificGroupResponse.jsonBody,
                                                                                r'''$[:].user_status''',
                                                                              ).toString()}' ==
                                                                              'joined')
                                                                            FFButtonWidget(
                                                                              onPressed: () {
                                                                                print('Joined pressed ...');
                                                                              },
                                                                              text: 'Joined',
                                                                              icon: Icon(
                                                                                Icons.done_all,
                                                                                size: 15.0,
                                                                              ),
                                                                              options: FFButtonOptions(
                                                                                height: 24.0,
                                                                                padding: EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                                                                                iconPadding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                                                                                iconColor: FlutterFlowTheme.of(context).greyL4,
                                                                                color: Color(0x00264AFF),
                                                                                textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                                                                                      font: GoogleFonts.interTight(
                                                                                        fontWeight: FlutterFlowTheme.of(context).titleSmall.fontWeight,
                                                                                        fontStyle: FlutterFlowTheme.of(context).titleSmall.fontStyle,
                                                                                      ),
                                                                                      color: FlutterFlowTheme.of(context).greyL4,
                                                                                      fontSize: 12.0,
                                                                                      letterSpacing: 0.0,
                                                                                      fontWeight: FlutterFlowTheme.of(context).titleSmall.fontWeight,
                                                                                      fontStyle: FlutterFlowTheme.of(context).titleSmall.fontStyle,
                                                                                    ),
                                                                                elevation: 0.0,
                                                                                borderSide: BorderSide(
                                                                                  color: FlutterFlowTheme.of(context).greyL4,
                                                                                  width: 1.0,
                                                                                ),
                                                                                borderRadius: BorderRadius.only(
                                                                                  topLeft: Radius.circular(100.0),
                                                                                  topRight: Radius.circular(100.0),
                                                                                  bottomLeft: Radius.circular(100.0),
                                                                                  bottomRight: Radius.circular(100.0),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          if ('${getJsonField(
                                                                                containerSpecificGroupResponse.jsonBody,
                                                                                r'''$[:].user_status''',
                                                                              ).toString()}' ==
                                                                              'requested')
                                                                            FFButtonWidget(
                                                                              onPressed: () {
                                                                                print('Requested pressed ...');
                                                                              },
                                                                              text: 'Requested',
                                                                              options: FFButtonOptions(
                                                                                height: 24.0,
                                                                                padding: EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                                                                                iconPadding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                                                                                color: FlutterFlowTheme.of(context).greyL2,
                                                                                textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                                                                                      font: GoogleFonts.interTight(
                                                                                        fontWeight: FlutterFlowTheme.of(context).titleSmall.fontWeight,
                                                                                        fontStyle: FlutterFlowTheme.of(context).titleSmall.fontStyle,
                                                                                      ),
                                                                                      color: FlutterFlowTheme.of(context).greyL3,
                                                                                      fontSize: 12.0,
                                                                                      letterSpacing: 0.0,
                                                                                      fontWeight: FlutterFlowTheme.of(context).titleSmall.fontWeight,
                                                                                      fontStyle: FlutterFlowTheme.of(context).titleSmall.fontStyle,
                                                                                    ),
                                                                                elevation: 0.0,
                                                                                borderRadius: BorderRadius.only(
                                                                                  topLeft: Radius.circular(100.0),
                                                                                  topRight: Radius.circular(100.0),
                                                                                  bottomLeft: Radius.circular(100.0),
                                                                                  bottomRight: Radius.circular(100.0),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          if ('${getJsonField(
                                                                                containerSpecificGroupResponse.jsonBody,
                                                                                r'''$[:].user_status''',
                                                                              ).toString()}' ==
                                                                              'request')
                                                                            FFButtonWidget(
                                                                              onPressed: () async {
                                                                                await GroupUserStatusTable().insert({
                                                                                  'community_id': FFAppState().communityId,
                                                                                  'user_id': currentUserUid,
                                                                                  'group_id': getJsonField(
                                                                                    containerSpecificGroupResponse.jsonBody,
                                                                                    r'''$[:].group_id''',
                                                                                  ).toString(),
                                                                                  'is_requested': true,
                                                                                  'is_invited': false,
                                                                                  'is_member': false,
                                                                                  'is_approved': false,
                                                                                  'requested_date': supaSerialize<DateTime>(functions.getCurrentUtcTime()),
                                                                                });
                                                                                if ((String var1) {
                                                                                  return var1.length >= 3;
                                                                                }(_model.textController.text)) {
                                                                                  _model.searchEmpty = false;
                                                                                  safeSetState(() {});
                                                                                  _model.apiResulth6nttzxc = await GetAllSearchCall.call(
                                                                                    pSearchText: _model.textController.text,
                                                                                    pUserid: currentUserUid,
                                                                                    pCommunityid: FFAppState().communityId,
                                                                                    token: currentJwtToken,
                                                                                    pType: _model.optionChoosed,
                                                                                    pCategory: FFAppState().SalesFilter,
                                                                                    pSaleType: FFAppState().SalesTypeFilter,
                                                                                    pSort: FFAppState().SalesSort,
                                                                                    pDistance: FFAppState().SalesKmFilter,
                                                                                  );

                                                                                  if ((_model.apiResulth6n?.succeeded ?? true)) {
                                                                                    FFAppState().SearchData = (_model.apiResulth6n?.jsonBody ?? '');
                                                                                    safeSetState(() {});
                                                                                  }
                                                                                } else {
                                                                                  if (_model.textController.text.length == 0) {
                                                                                    _model.searchEmpty = true;
                                                                                    safeSetState(() {});
                                                                                  } else {
                                                                                    _model.searchEmpty = false;
                                                                                    safeSetState(() {});
                                                                                  }
                                                                                }

                                                                                safeSetState(() {});
                                                                              },
                                                                              text: 'Request',
                                                                              icon: Icon(
                                                                                Icons.lock_outline_sharp,
                                                                                size: 15.0,
                                                                              ),
                                                                              options: FFButtonOptions(
                                                                                height: 24.0,
                                                                                padding: EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                                                                                iconPadding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                                                                                iconColor: FlutterFlowTheme.of(context).primaryD3,
                                                                                color: Color(0x00264AFF),
                                                                                textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                                                                                      font: GoogleFonts.interTight(
                                                                                        fontWeight: FlutterFlowTheme.of(context).titleSmall.fontWeight,
                                                                                        fontStyle: FlutterFlowTheme.of(context).titleSmall.fontStyle,
                                                                                      ),
                                                                                      color: FlutterFlowTheme.of(context).primaryD3,
                                                                                      fontSize: 12.0,
                                                                                      letterSpacing: 0.0,
                                                                                      fontWeight: FlutterFlowTheme.of(context).titleSmall.fontWeight,
                                                                                      fontStyle: FlutterFlowTheme.of(context).titleSmall.fontStyle,
                                                                                    ),
                                                                                elevation: 0.0,
                                                                                borderSide: BorderSide(
                                                                                  color: FlutterFlowTheme.of(context).primaryD3,
                                                                                  width: 1.0,
                                                                                ),
                                                                                borderRadius: BorderRadius.only(
                                                                                  topLeft: Radius.circular(100.0),
                                                                                  topRight: Radius.circular(100.0),
                                                                                  bottomLeft: Radius.circular(100.0),
                                                                                  bottomRight: Radius.circular(100.0),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          if ('${getJsonField(
                                                                                containerSpecificGroupResponse.jsonBody,
                                                                                r'''$[:].user_status''',
                                                                              ).toString()}' ==
                                                                              'admin')
                                                                            FFButtonWidget(
                                                                              onPressed: () {
                                                                                print('Button pressed ...');
                                                                              },
                                                                              text: 'Admin',
                                                                              options: FFButtonOptions(
                                                                                height: 24.0,
                                                                                padding: EdgeInsetsDirectional.fromSTEB(12.0, 0.0, 12.0, 0.0),
                                                                                iconPadding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                                                                                color: Color(0xFF23B3A6),
                                                                                textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                                                                                      font: GoogleFonts.interTight(
                                                                                        fontWeight: FlutterFlowTheme.of(context).titleSmall.fontWeight,
                                                                                        fontStyle: FlutterFlowTheme.of(context).titleSmall.fontStyle,
                                                                                      ),
                                                                                      color: Colors.white,
                                                                                      fontSize: 12.0,
                                                                                      letterSpacing: 0.0,
                                                                                      fontWeight: FlutterFlowTheme.of(context).titleSmall.fontWeight,
                                                                                      fontStyle: FlutterFlowTheme.of(context).titleSmall.fontStyle,
                                                                                    ),
                                                                                elevation: 0.0,
                                                                                borderRadius: BorderRadius.only(
                                                                                  topLeft: Radius.circular(100.0),
                                                                                  topRight: Radius.circular(100.0),
                                                                                  bottomLeft: Radius.circular(100.0),
                                                                                  bottomRight: Radius.circular(100.0),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          if (('${getJsonField(
                                                                                    containerSpecificGroupResponse.jsonBody,
                                                                                    r'''$[:].user_status''',
                                                                                  ).toString()}' ==
                                                                                  'invite') &&
                                                                              ('${getJsonField(
                                                                                    containerSpecificGroupResponse.jsonBody,
                                                                                    r'''$[:].e_group_type''',
                                                                                  ).toString()}' ==
                                                                                  'open'))
                                                                            FFButtonWidget(
                                                                              onPressed: () async {
                                                                                await GroupMembersTable().insert({
                                                                                  'community_id': FFAppState().communityId,
                                                                                  'user_id': currentUserUid,
                                                                                  'group_id': getJsonField(
                                                                                    containerSpecificGroupResponse.jsonBody,
                                                                                    r'''$[:].group_id''',
                                                                                  ).toString(),
                                                                                  'is_requested': false,
                                                                                  'is_approved': true,
                                                                                  'approved_by': getJsonField(
                                                                                    containerSpecificGroupResponse.jsonBody,
                                                                                    r'''$[:].invited_by_user_id''',
                                                                                  ).toString(),
                                                                                  'joined_at': supaSerialize<DateTime>(functions.getCurrentUtcTime()),
                                                                                });
                                                                                await GroupUserStatusTable().insert({
                                                                                  'community_id': FFAppState().communityId,
                                                                                  'user_id': currentUserUid,
                                                                                  'group_id': getJsonField(
                                                                                    containerSpecificGroupResponse.jsonBody,
                                                                                    r'''$[:].group_id''',
                                                                                  ).toString(),
                                                                                  'is_requested': false,
                                                                                  'is_invited': true,
                                                                                  'is_member': true,
                                                                                  'joined_at': supaSerialize<DateTime>(functions.getCurrentUtcTime()),
                                                                                  'is_approved': true,
                                                                                  'invited_by': getJsonField(
                                                                                    containerSpecificGroupResponse.jsonBody,
                                                                                    r'''$[:].invited_by_user_id''',
                                                                                  ).toString(),
                                                                                });
                                                                                await GroupMembersInviteTable().update(
                                                                                  data: {
                                                                                    'is_member': true,
                                                                                  },
                                                                                  matchingRows: (rows) => rows
                                                                                      .eqOrNull(
                                                                                        'group_id',
                                                                                        getJsonField(
                                                                                          containerSpecificGroupResponse.jsonBody,
                                                                                          r'''$[:].group_id''',
                                                                                        ).toString(),
                                                                                      )
                                                                                      .eqOrNull(
                                                                                        'invited_by',
                                                                                        getJsonField(
                                                                                          containerSpecificGroupResponse.jsonBody,
                                                                                          r'''$[:].invited_by_user_id''',
                                                                                        ).toString(),
                                                                                      )
                                                                                      .eqOrNull(
                                                                                        'invited_user',
                                                                                        currentUserUid,
                                                                                      ),
                                                                                );
                                                                                _model.apiResultd2pp23fxx = await UpdateTotalGroupMembersCall.call(
                                                                                  token: currentJwtToken,
                                                                                  anonKey: FFDevEnvironmentValues().AnonKey,
                                                                                  groupId: getJsonField(
                                                                                    containerSpecificGroupResponse.jsonBody,
                                                                                    r'''$[:].group_id''',
                                                                                  ).toString(),
                                                                                );

                                                                                if ((String var1) {
                                                                                  return var1.length >= 3;
                                                                                }(_model.textController.text)) {
                                                                                  _model.searchEmpty = false;
                                                                                  safeSetState(() {});
                                                                                  _model.apiResulth6nttcvcss = await GetAllSearchCall.call(
                                                                                    pSearchText: _model.textController.text,
                                                                                    pUserid: currentUserUid,
                                                                                    pCommunityid: FFAppState().communityId,
                                                                                    token: currentJwtToken,
                                                                                    pType: _model.optionChoosed,
                                                                                    pCategory: FFAppState().SalesFilter,
                                                                                    pSaleType: FFAppState().SalesTypeFilter,
                                                                                    pSort: FFAppState().SalesSort,
                                                                                    pDistance: FFAppState().SalesKmFilter,
                                                                                  );

                                                                                  if ((_model.apiResulth6n?.succeeded ?? true)) {
                                                                                    FFAppState().SearchData = (_model.apiResulth6n?.jsonBody ?? '');
                                                                                    safeSetState(() {});
                                                                                  }
                                                                                } else {
                                                                                  if (_model.textController.text.length == 0) {
                                                                                    _model.searchEmpty = true;
                                                                                    safeSetState(() {});
                                                                                  } else {
                                                                                    _model.searchEmpty = false;
                                                                                    safeSetState(() {});
                                                                                  }
                                                                                }

                                                                                safeSetState(() {});
                                                                              },
                                                                              text: 'Join',
                                                                              options: FFButtonOptions(
                                                                                height: 24.0,
                                                                                padding: EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                                                                                iconPadding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                                                                                color: Color(0x00264AFF),
                                                                                textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                                                                                      font: GoogleFonts.interTight(
                                                                                        fontWeight: FlutterFlowTheme.of(context).titleSmall.fontWeight,
                                                                                        fontStyle: FlutterFlowTheme.of(context).titleSmall.fontStyle,
                                                                                      ),
                                                                                      color: FlutterFlowTheme.of(context).primaryD3,
                                                                                      fontSize: 12.0,
                                                                                      letterSpacing: 0.0,
                                                                                      fontWeight: FlutterFlowTheme.of(context).titleSmall.fontWeight,
                                                                                      fontStyle: FlutterFlowTheme.of(context).titleSmall.fontStyle,
                                                                                    ),
                                                                                elevation: 0.0,
                                                                                borderSide: BorderSide(
                                                                                  color: FlutterFlowTheme.of(context).primaryD3,
                                                                                  width: 1.0,
                                                                                ),
                                                                                borderRadius: BorderRadius.only(
                                                                                  topLeft: Radius.circular(100.0),
                                                                                  topRight: Radius.circular(100.0),
                                                                                  bottomLeft: Radius.circular(100.0),
                                                                                  bottomRight: Radius.circular(100.0),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          if (('${getJsonField(
                                                                                    containerSpecificGroupResponse.jsonBody,
                                                                                    r'''$[:].user_status''',
                                                                                  ).toString()}' ==
                                                                                  'invite') &&
                                                                              ('${getJsonField(
                                                                                    containerSpecificGroupResponse.jsonBody,
                                                                                    r'''$[:].e_group_type''',
                                                                                  ).toString()}' ==
                                                                                  'private'))
                                                                            FFButtonWidget(
                                                                              onPressed: () async {
                                                                                await GroupUserStatusTable().update(
                                                                                  data: {
                                                                                    'is_requested': true,
                                                                                    'requested_date': supaSerialize<DateTime>(functions.getCurrentUtcTime()),
                                                                                  },
                                                                                  matchingRows: (rows) => rows
                                                                                      .eqOrNull(
                                                                                        'group_id',
                                                                                        getJsonField(
                                                                                          containerSpecificGroupResponse.jsonBody,
                                                                                          r'''$[:].group_id''',
                                                                                        ).toString(),
                                                                                      )
                                                                                      .eqOrNull(
                                                                                        'user_id',
                                                                                        currentUserUid,
                                                                                      )
                                                                                      .eqOrNull(
                                                                                        'invited_by',
                                                                                        getJsonField(
                                                                                          containerSpecificGroupResponse.jsonBody,
                                                                                          r'''$[:].invited_by_user_id''',
                                                                                        ).toString(),
                                                                                      ),
                                                                                );
                                                                                if ((String var1) {
                                                                                  return var1.length >= 3;
                                                                                }(_model.textController.text)) {
                                                                                  _model.searchEmpty = false;
                                                                                  safeSetState(() {});
                                                                                  _model.apiResulth6nttcvc = await GetAllSearchCall.call(
                                                                                    pSearchText: _model.textController.text,
                                                                                    pUserid: currentUserUid,
                                                                                    pCommunityid: FFAppState().communityId,
                                                                                    token: currentJwtToken,
                                                                                    pType: _model.optionChoosed,
                                                                                    pCategory: FFAppState().SalesFilter,
                                                                                    pSaleType: FFAppState().SalesTypeFilter,
                                                                                    pSort: FFAppState().SalesSort,
                                                                                    pDistance: FFAppState().SalesKmFilter,
                                                                                  );

                                                                                  if ((_model.apiResulth6n?.succeeded ?? true)) {
                                                                                    FFAppState().SearchData = (_model.apiResulth6n?.jsonBody ?? '');
                                                                                    safeSetState(() {});
                                                                                  }
                                                                                } else {
                                                                                  if (_model.textController.text.length == 0) {
                                                                                    _model.searchEmpty = true;
                                                                                    safeSetState(() {});
                                                                                  } else {
                                                                                    _model.searchEmpty = false;
                                                                                    safeSetState(() {});
                                                                                  }
                                                                                }

                                                                                safeSetState(() {});
                                                                              },
                                                                              text: 'Request',
                                                                              icon: Icon(
                                                                                Icons.lock_outline_sharp,
                                                                                size: 15.0,
                                                                              ),
                                                                              options: FFButtonOptions(
                                                                                height: 24.0,
                                                                                padding: EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                                                                                iconPadding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                                                                                iconColor: FlutterFlowTheme.of(context).primaryD3,
                                                                                color: Color(0x00264AFF),
                                                                                textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                                                                                      font: GoogleFonts.interTight(
                                                                                        fontWeight: FlutterFlowTheme.of(context).titleSmall.fontWeight,
                                                                                        fontStyle: FlutterFlowTheme.of(context).titleSmall.fontStyle,
                                                                                      ),
                                                                                      color: FlutterFlowTheme.of(context).primaryD3,
                                                                                      fontSize: 12.0,
                                                                                      letterSpacing: 0.0,
                                                                                      fontWeight: FlutterFlowTheme.of(context).titleSmall.fontWeight,
                                                                                      fontStyle: FlutterFlowTheme.of(context).titleSmall.fontStyle,
                                                                                    ),
                                                                                elevation: 0.0,
                                                                                borderSide: BorderSide(
                                                                                  color: FlutterFlowTheme.of(context).primaryD3,
                                                                                  width: 1.0,
                                                                                ),
                                                                                borderRadius: BorderRadius.only(
                                                                                  topLeft: Radius.circular(100.0),
                                                                                  topRight: Radius.circular(100.0),
                                                                                  bottomLeft: Radius.circular(100.0),
                                                                                  bottomRight: Radius.circular(100.0),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                        ],
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            );
                                                          },
                                                        );
                                                      },
                                                    );
                                                  },
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
                        ],
                      ),
                    ),
                  ),
                if ((_model.showData == false) && _model.isSearchHistory)
                  Expanded(
                    child: Padding(
                      padding:
                          EdgeInsetsDirectional.fromSTEB(0.0, 4.0, 0.0, 0.0),
                      child: Container(
                        width: double.infinity,
                        height: double.infinity,
                        decoration: BoxDecoration(
                          color:
                              FlutterFlowTheme.of(context).secondaryBackground,
                        ),
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Container(
                                height: 50.0,
                                decoration: BoxDecoration(),
                                child: Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      20.0, 0.0, 0.0, 0.0),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Recent Searches',
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
                                      InkWell(
                                        splashColor: Colors.transparent,
                                        focusColor: Colors.transparent,
                                        hoverColor: Colors.transparent,
                                        highlightColor: Colors.transparent,
                                        onTap: () async {
                                          await SearchHistoryTable().delete(
                                            matchingRows: (rows) => rows
                                                .eqOrNull(
                                                  'community_id',
                                                  FFAppState().communityId,
                                                )
                                                .eqOrNull(
                                                  'searched_by',
                                                  currentUserUid,
                                                ),
                                          );
                                          _model.isSearchHistory = false;
                                          safeSetState(() {});
                                          safeSetState(() =>
                                              _model.requestCompleter = null);
                                        },
                                        child: Container(
                                          width: 80.0,
                                          height: 35.0,
                                          decoration: BoxDecoration(),
                                          alignment:
                                              AlignmentDirectional(0.0, 0.0),
                                          child: Text(
                                            'Clear',
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
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              FutureBuilder<List<SearchHistoryRow>>(
                                future: (_model.requestCompleter ??= Completer<
                                        List<SearchHistoryRow>>()
                                      ..complete(SearchHistoryTable().queryRows(
                                        queryFn: (q) => q
                                            .eqOrNull(
                                              'community_id',
                                              FFAppState().communityId,
                                            )
                                            .eqOrNull(
                                              'searched_by',
                                              currentUserUid,
                                            )
                                            .order('created_at'),
                                      )))
                                    .future,
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
                                  List<SearchHistoryRow>
                                      searchHistoryListViewSearchHistoryRowList =
                                      snapshot.data!;

                                  return ListView.builder(
                                    padding: EdgeInsets.zero,
                                    primary: false,
                                    shrinkWrap: true,
                                    scrollDirection: Axis.vertical,
                                    itemCount:
                                        searchHistoryListViewSearchHistoryRowList
                                            .length,
                                    itemBuilder:
                                        (context, searchHistoryListViewIndex) {
                                      final searchHistoryListViewSearchHistoryRow =
                                          searchHistoryListViewSearchHistoryRowList[
                                              searchHistoryListViewIndex];
                                      return InkWell(
                                        splashColor: Colors.transparent,
                                        focusColor: Colors.transparent,
                                        hoverColor: Colors.transparent,
                                        highlightColor: Colors.transparent,
                                        onTap: () async {
                                          safeSetState(() {
                                            _model.textController?.text =
                                                searchHistoryListViewSearchHistoryRow
                                                    .search;
                                          });
                                          _model.searchEmpty = false;
                                          _model.showData = true;
                                          _model.optionChoosed = 'all';
                                          safeSetState(() {});
                                          _model.searchHistoryData =
                                              await GetAllSearchCall.call(
                                            pSearchText:
                                                _model.textController.text,
                                            pUserid: currentUserUid,
                                            pCommunityid:
                                                FFAppState().communityId,
                                            token: currentJwtToken,
                                            pType: _model.optionChoosed,
                                            pCategory: FFAppState().SalesFilter,
                                            pSaleType:
                                                FFAppState().SalesTypeFilter,
                                            pSort: FFAppState().SalesSort,
                                            pDistance:
                                                FFAppState().SalesKmFilter,
                                          );

                                          if ((_model.searchHistoryData
                                                  ?.succeeded ??
                                              true)) {
                                            FFAppState().SearchData = (_model
                                                    .searchHistoryData
                                                    ?.jsonBody ??
                                                '');
                                            safeSetState(() {});
                                          }

                                          safeSetState(() {});
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(),
                                          child: Padding(
                                            padding:
                                                EdgeInsetsDirectional.fromSTEB(
                                                    20.0, 12.0, 20.0, 12.0),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.max,
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Row(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  children: [
                                                    Icon(
                                                      Icons.history,
                                                      color:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .greyD1,
                                                      size: 24.0,
                                                    ),
                                                    Text(
                                                      searchHistoryListViewSearchHistoryRow
                                                          .search,
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
                                                                    .greyD1,
                                                                fontSize: 16.0,
                                                                letterSpacing:
                                                                    0.0,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                fontStyle: FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .fontStyle,
                                                                lineHeight: 1.4,
                                                              ),
                                                    ),
                                                  ].divide(
                                                      SizedBox(width: 10.0)),
                                                ),
                                                Icon(
                                                  Icons.arrow_outward,
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .greyD1,
                                                  size: 24.0,
                                                ),
                                              ].divide(SizedBox(width: 10.0)),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                            ].addToStart(SizedBox(height: 12.0)),
                          ),
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
