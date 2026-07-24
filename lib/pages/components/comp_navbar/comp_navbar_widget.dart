// comp_navbar_widget.dart
// Flock bottom navigation bar (Home / Community / Post / Notifications / For Sale & Free).
// Icon-only, 54dp tall; each tab is wrapped in Semantics so TalkBack (Android) and
// VoiceOver (iOS) announce its name, button role and selected state.
import '/components/post_tab_icon.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'comp_navbar_model.dart';
export 'comp_navbar_model.dart';

class CompNavbarWidget extends StatefulWidget {
  const CompNavbarWidget({
    super.key,
    String? pagename,
  }) : this.pagename = pagename ?? '';

  final String pagename;

  @override
  State<CompNavbarWidget> createState() => _CompNavbarWidgetState();
}

class _CompNavbarWidgetState extends State<CompNavbarWidget> {
  late CompNavbarModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => CompNavbarModel());
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54.0,
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        boxShadow: [
          BoxShadow(
            blurRadius: 5.0,
            color: FlutterFlowTheme.of(context).primary.withAlpha(0x14),
            offset: Offset(
              0.0,
              -4.0,
            ),
            spreadRadius: 0.0,
          )
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Flexible(
                  // Screen-reader node for the Home tab. Wraps the tap target itself so the
                  // accessible bounds match the hit area; `selected` tracks the route.
                  child: Semantics(
                    label: 'Home',
                    button: true,
                    selected: widget.pagename == 'home',
                    child: InkWell(
                      splashColor:
                          FlutterFlowTheme.of(context).primary.withAlpha(0x14),
                      focusColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onTap: () async {
                        _model.nav = 'opt1';
                        safeSetState(() {});
                        await Future.delayed(
                          Duration(
                            milliseconds: 300,
                          ),
                        );
                        _model.nav = null;
                        safeSetState(() {});

                        context.pushNamed(
                          HomePageWidget.routeName,
                          extra: <String, dynamic>{
                            '__transition_info__': TransitionInfo(
                              hasTransition: true,
                              transitionType: PageTransitionType.fade,
                              duration: Duration(milliseconds: 0),
                            ),
                          },
                        );
                      },
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                        decoration: BoxDecoration(
                          color: _model.nav == 'opt1'
                              ? FlutterFlowTheme.of(context)
                                  .primary
                                  .withAlpha(0x14)
                              : Colors.transparent,
                        ),
                        child: Stack(
                          children: [
                            if (widget!.pagename == 'home')
                              Column(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                    width: double.infinity,
                                    height: 2.0,
                                    decoration: BoxDecoration(
                                      color:
                                          FlutterFlowTheme.of(context).primary,
                                    ),
                                    child: SingleChildScrollView(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.max,
                                        children: [],
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          0.0, 4.0, 0.0, 0.0),
                                      child: Container(
                                        width: double.infinity,
                                        decoration: BoxDecoration(),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(0.0),
                                              child: Image.asset(
                                                'assets/images/home_blue.png',
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .primary,
                                                width: 28.0,
                                                height: 28.0,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                            if (false)
                                              Text(
                                                'Home',
                                                style: FlutterFlowTheme.of(
                                                        context)
                                                    .bodyMedium
                                                    .override(
                                                      font: GoogleFonts.manrope(
                                                        fontWeight:
                                                            FontWeight.bold,
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
                                                      fontSize: 10.0,
                                                      letterSpacing: 0.0,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontStyle:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .bodyMedium
                                                              .fontStyle,
                                                      lineHeight: 1.4,
                                                    ),
                                              ),
                                          ].divide(SizedBox(height: 4.0)),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            if (widget!.pagename != 'home')
                              Column(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Expanded(
                                    child: Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          0.0, 6.0, 0.0, 0.0),
                                      child: Container(
                                        width: double.infinity,
                                        decoration: BoxDecoration(),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(0.0),
                                              child: Image.asset(
                                                'assets/images/hame_grey.png',
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .secondaryText,
                                                width: 28.0,
                                                height: 28.0,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                            if (false)
                                              Text(
                                                'Home',
                                                style: FlutterFlowTheme.of(
                                                        context)
                                                    .bodyMedium
                                                    .override(
                                                      font: GoogleFonts.manrope(
                                                        fontWeight:
                                                            FontWeight.bold,
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
                                                      fontSize: 10.0,
                                                      letterSpacing: 0.0,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontStyle:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .bodyMedium
                                                              .fontStyle,
                                                      lineHeight: 1.4,
                                                    ),
                                              ),
                                          ].divide(SizedBox(height: 4.0)),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Flexible(
                  // Screen-reader node for the Community tab. Wraps the tap target itself so the
                  // accessible bounds match the hit area; `selected` tracks the route.
                  child: Semantics(
                    label: 'Community',
                    button: true,
                    selected: widget.pagename == 'community',
                    child: InkWell(
                      splashColor:
                          FlutterFlowTheme.of(context).primary.withAlpha(0x14),
                      focusColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onTap: () async {
                        _model.nav = 'opt2';
                        safeSetState(() {});
                        await Future.delayed(
                          Duration(
                            milliseconds: 300,
                          ),
                        );
                        _model.nav = null;
                        safeSetState(() {});

                        context.pushNamed(
                          CommunityWidget.routeName,
                          extra: <String, dynamic>{
                            '__transition_info__': TransitionInfo(
                              hasTransition: true,
                              transitionType: PageTransitionType.fade,
                              duration: Duration(milliseconds: 0),
                            ),
                          },
                        );
                      },
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                        decoration: BoxDecoration(
                          color: _model.nav == 'opt2'
                              ? FlutterFlowTheme.of(context)
                                  .primary
                                  .withAlpha(0x14)
                              : Colors.transparent,
                        ),
                        child: Stack(
                          children: [
                            if (widget!.pagename == 'community')
                              Column(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                    width: double.infinity,
                                    height: 2.0,
                                    decoration: BoxDecoration(
                                      color:
                                          FlutterFlowTheme.of(context).primary,
                                    ),
                                    child: SingleChildScrollView(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.max,
                                        children: [],
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          0.0, 4.0, 0.0, 0.0),
                                      child: Container(
                                        width: double.infinity,
                                        decoration: BoxDecoration(),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(0.0),
                                              child: Image.asset(
                                                'assets/images/community_blue.png',
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .primary,
                                                width: 28.0,
                                                height: 28.0,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                            if (false)
                                              Text(
                                                'Community',
                                                style: FlutterFlowTheme.of(
                                                        context)
                                                    .bodyMedium
                                                    .override(
                                                      font: GoogleFonts.manrope(
                                                        fontWeight:
                                                            FontWeight.bold,
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
                                                      fontSize: 10.0,
                                                      letterSpacing: 0.0,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontStyle:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .bodyMedium
                                                              .fontStyle,
                                                      lineHeight: 1.4,
                                                    ),
                                              ),
                                          ].divide(SizedBox(height: 4.0)),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            if (widget!.pagename != 'community')
                              Column(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Expanded(
                                    child: Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          0.0, 6.0, 0.0, 0.0),
                                      child: Container(
                                        width: double.infinity,
                                        decoration: BoxDecoration(),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(0.0),
                                              child: Image.asset(
                                                'assets/images/community_grey.png',
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .secondaryText,
                                                width: 28.0,
                                                height: 28.0,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                            if (false)
                                              Text(
                                                'Community',
                                                style: FlutterFlowTheme.of(
                                                        context)
                                                    .bodyMedium
                                                    .override(
                                                      font: GoogleFonts.manrope(
                                                        fontWeight:
                                                            FontWeight.bold,
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
                                                      fontSize: 10.0,
                                                      letterSpacing: 0.0,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontStyle:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .bodyMedium
                                                              .fontStyle,
                                                      lineHeight: 1.4,
                                                    ),
                                              ),
                                          ].divide(SizedBox(height: 4.0)),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Flexible(
                  // Screen-reader node for the Post tab. Wraps the tap target itself so the
                  // accessible bounds match the hit area; `selected` tracks the route.
                  child: Semantics(
                    label: 'Post',
                    button: true,
                    selected: widget.pagename == 'post',
                    child: InkWell(
                      splashColor:
                          FlutterFlowTheme.of(context).primary.withAlpha(0x14),
                      focusColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onTap: () async {
                        _model.nav = 'opt3';
                        safeSetState(() {});
                        await Future.delayed(
                          Duration(
                            milliseconds: 300,
                          ),
                        );
                        _model.nav = null;
                        safeSetState(() {});

                        context.pushNamed(
                          CreatePostWidget.routeName,
                          extra: <String, dynamic>{
                            '__transition_info__': TransitionInfo(
                              hasTransition: true,
                              transitionType: PageTransitionType.fade,
                              duration: Duration(milliseconds: 0),
                            ),
                          },
                        );
                      },
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                        decoration: BoxDecoration(
                          color: _model.nav == 'opt3'
                              ? FlutterFlowTheme.of(context)
                                  .primary
                                  .withAlpha(0x14)
                              : Colors.transparent,
                        ),
                        child: Stack(
                          children: [
                            if (widget!.pagename == 'post')
                              Column(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Container(
                                    width: double.infinity,
                                    height: 2.0,
                                    decoration: BoxDecoration(
                                      color:
                                          FlutterFlowTheme.of(context).primary,
                                    ),
                                    child: SingleChildScrollView(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.max,
                                        children: [],
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          0.0, 4.0, 0.0, 0.0),
                                      child: Container(
                                        width: double.infinity,
                                        decoration: BoxDecoration(),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            // Code-drawn two-tone create glyph.
                                            // The old post_blue.png was an
                                            // untintable raster still carrying
                                            // the pre-Flock blue; PostTabIcon
                                            // tracks `primary` in both themes.
                                            PostTabIcon(
                                              isActive: true,
                                              size: 28.0,
                                            ),
                                            if (false)
                                              Text(
                                                'Post',
                                                style: FlutterFlowTheme.of(
                                                        context)
                                                    .bodyMedium
                                                    .override(
                                                      font: GoogleFonts.manrope(
                                                        fontWeight:
                                                            FontWeight.bold,
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
                                                      fontSize: 10.0,
                                                      letterSpacing: 0.0,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontStyle:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .bodyMedium
                                                              .fontStyle,
                                                      lineHeight: 1.4,
                                                    ),
                                              ),
                                          ].divide(SizedBox(height: 4.0)),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            if (widget!.pagename != 'post')
                              Column(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Expanded(
                                    child: Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          0.0, 6.0, 0.0, 0.0),
                                      child: Container(
                                        width: double.infinity,
                                        decoration: BoxDecoration(),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            // Inactive create glyph - see the
                                            // active PostTabIcon above. Replaces
                                            // post_grey.png, a white-bar-tuned
                                            // grey that read muddy on the dark
                                            // theme's #221B2B nav surface.
                                            PostTabIcon(
                                              isActive: false,
                                              size: 28.0,
                                            ),
                                            if (false)
                                              Text(
                                                'Post',
                                                style: FlutterFlowTheme.of(
                                                        context)
                                                    .bodyMedium
                                                    .override(
                                                      font: GoogleFonts.manrope(
                                                        fontWeight:
                                                            FontWeight.bold,
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
                                                      fontSize: 10.0,
                                                      letterSpacing: 0.0,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontStyle:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .bodyMedium
                                                              .fontStyle,
                                                      lineHeight: 1.4,
                                                    ),
                                              ),
                                          ].divide(SizedBox(height: 4.0)),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Flexible(
                  // Screen-reader node for the Notifications tab. Wraps the tap target itself so the
                  // accessible bounds match the hit area; `selected` tracks the route.
                  child: Semantics(
                    label: 'Notifications',
                    button: true,
                    selected: widget.pagename == 'notification',
                    child: InkWell(
                      splashColor:
                          FlutterFlowTheme.of(context).primary.withAlpha(0x14),
                      focusColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onTap: () async {
                        _model.nav = 'opt4';
                        safeSetState(() {});
                        await Future.delayed(
                          Duration(
                            milliseconds: 300,
                          ),
                        );
                        _model.nav = null;
                        safeSetState(() {});

                        context.pushNamed(
                          NotificationWidget.routeName,
                          extra: <String, dynamic>{
                            '__transition_info__': TransitionInfo(
                              hasTransition: true,
                              transitionType: PageTransitionType.fade,
                              duration: Duration(milliseconds: 0),
                            ),
                          },
                        );
                      },
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                        decoration: BoxDecoration(
                          color: _model.nav == 'opt4'
                              ? FlutterFlowTheme.of(context)
                                  .primary
                                  .withAlpha(0x14)
                              : Colors.transparent,
                        ),
                        child: Stack(
                          children: [
                            if (widget!.pagename == 'notification')
                              Column(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Container(
                                    width: double.infinity,
                                    height: 2.0,
                                    decoration: BoxDecoration(
                                      color:
                                          FlutterFlowTheme.of(context).primary,
                                    ),
                                    child: SingleChildScrollView(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.max,
                                        children: [],
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          0.0, 4.0, 0.0, 0.0),
                                      child: Container(
                                        width: double.infinity,
                                        decoration: BoxDecoration(),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(0.0),
                                              child: Image.asset(
                                                'assets/images/notification_blue.webp',
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .primary,
                                                width: 28.0,
                                                height: 28.0,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                            if (false)
                                              Text(
                                                'Notifications',
                                                style: FlutterFlowTheme.of(
                                                        context)
                                                    .bodyMedium
                                                    .override(
                                                      font: GoogleFonts.manrope(
                                                        fontWeight:
                                                            FontWeight.bold,
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
                                                      fontSize: 10.0,
                                                      letterSpacing: 0.0,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontStyle:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .bodyMedium
                                                              .fontStyle,
                                                      lineHeight: 1.4,
                                                    ),
                                              ),
                                          ].divide(SizedBox(height: 4.0)),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            if (widget!.pagename != 'notification')
                              Column(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Expanded(
                                    child: Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          0.0, 6.0, 0.0, 0.0),
                                      child: Container(
                                        width: double.infinity,
                                        decoration: BoxDecoration(),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(0.0),
                                              child: Image.asset(
                                                'assets/images/notification_gray.webp',
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .secondaryText,
                                                width: 28.0,
                                                height: 28.0,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                            if (false)
                                              Text(
                                                'Notifications',
                                                style: FlutterFlowTheme.of(
                                                        context)
                                                    .bodyMedium
                                                    .override(
                                                      font: GoogleFonts.manrope(
                                                        fontWeight:
                                                            FontWeight.bold,
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
                                                      fontSize: 10.0,
                                                      letterSpacing: 0.0,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontStyle:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .bodyMedium
                                                              .fontStyle,
                                                      lineHeight: 1.4,
                                                    ),
                                              ),
                                          ].divide(SizedBox(height: 4.0)),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Flexible(
                  // Screen-reader node for the For Sale & Free tab. Wraps the tap target itself so the
                  // accessible bounds match the hit area; `selected` tracks the route.
                  child: Semantics(
                    label: 'For Sale & Free',
                    button: true,
                    selected: widget.pagename == 'sale',
                    child: InkWell(
                      splashColor:
                          FlutterFlowTheme.of(context).primary.withAlpha(0x14),
                      focusColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onTap: () async {
                        _model.nav = 'opt5';
                        safeSetState(() {});
                        await Future.delayed(
                          Duration(
                            milliseconds: 300,
                          ),
                        );
                        _model.nav = null;
                        safeSetState(() {});

                        context.pushNamed(
                          SaleWidget.routeName,
                          queryParameters: {
                            'pageType': serializeParam(
                              'home',
                              ParamType.String,
                            ),
                          }.withoutNulls,
                          extra: <String, dynamic>{
                            '__transition_info__': TransitionInfo(
                              hasTransition: true,
                              transitionType: PageTransitionType.fade,
                              duration: Duration(milliseconds: 0),
                            ),
                          },
                        );
                      },
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                        decoration: BoxDecoration(
                          color: _model.nav == 'opt5'
                              ? FlutterFlowTheme.of(context)
                                  .primary
                                  .withAlpha(0x14)
                              : Colors.transparent,
                        ),
                        child: Stack(
                          children: [
                            if (widget!.pagename == 'sale')
                              Column(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Container(
                                    width: double.infinity,
                                    height: 2.0,
                                    decoration: BoxDecoration(
                                      color:
                                          FlutterFlowTheme.of(context).primary,
                                    ),
                                    child: SingleChildScrollView(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.max,
                                        children: [],
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          0.0, 4.0, 0.0, 0.0),
                                      child: Container(
                                        width: double.infinity,
                                        decoration: BoxDecoration(),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(0.0),
                                              child: Image.asset(
                                                'assets/images/loyalty_blue.webp',
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .primary,
                                                width: 28.0,
                                                height: 28.0,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                            if (false)
                                              Text(
                                                'For Sale & Free',
                                                maxLines: 1,
                                                style: FlutterFlowTheme.of(
                                                        context)
                                                    .bodyMedium
                                                    .override(
                                                      font: GoogleFonts.manrope(
                                                        fontWeight:
                                                            FontWeight.bold,
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
                                                      fontSize: 10.0,
                                                      letterSpacing: 0.0,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontStyle:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .bodyMedium
                                                              .fontStyle,
                                                      lineHeight: 1.4,
                                                    ),
                                              ),
                                          ].divide(SizedBox(height: 4.0)),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            if (widget!.pagename != 'sale')
                              Column(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Expanded(
                                    child: Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          0.0, 6.0, 0.0, 0.0),
                                      child: Container(
                                        width: double.infinity,
                                        decoration: BoxDecoration(),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(0.0),
                                              child: Image.asset(
                                                'assets/images/loyalty_gray.webp',
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .secondaryText,
                                                width: 28.0,
                                                height: 28.0,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                            if (false)
                                              Text(
                                                'For Sale & Free',
                                                maxLines: 1,
                                                style: FlutterFlowTheme.of(
                                                        context)
                                                    .bodyMedium
                                                    .override(
                                                      font: GoogleFonts.manrope(
                                                        fontWeight:
                                                            FontWeight.bold,
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
                                                      fontSize: 10.0,
                                                      letterSpacing: 0.0,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontStyle:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .bodyMedium
                                                              .fontStyle,
                                                      lineHeight: 1.4,
                                                    ),
                                              ),
                                          ].divide(SizedBox(height: 4.0)),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ]
                  .addToStart(SizedBox(width: 12.0))
                  .addToEnd(SizedBox(width: 12.0)),
            ),
          ),
        ],
      ),
    );
  }
}
