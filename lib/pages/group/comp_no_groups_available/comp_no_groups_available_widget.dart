// comp_no_groups_available_widget.dart
// Empty-state shown when no groups are available to list.
// Follows docs/design/flock-interaction-spec.md §3 (empty states) and
// §2.D (entrance animation for empty/error art).
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'comp_no_groups_available_model.dart';
export 'comp_no_groups_available_model.dart';

class CompNoGroupsAvailableWidget extends StatefulWidget {
  const CompNoGroupsAvailableWidget({super.key});

  @override
  State<CompNoGroupsAvailableWidget> createState() =>
      _CompNoGroupsAvailableWidgetState();
}

class _CompNoGroupsAvailableWidgetState
    extends State<CompNoGroupsAvailableWidget> {
  late CompNoGroupsAvailableModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => CompNoGroupsAvailableModel());
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  // Builds the empty-groups illustration, headline and supporting copy.
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 400.0,
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
      ),
      child: SingleChildScrollView(
        // Always scrollable so an enclosing RefreshIndicator still receives the
        // pull gesture when this empty state is the only thing on screen.
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Padding(
              padding:
                  const EdgeInsetsDirectional.fromSTEB(0.0, 24.0, 0.0, 0.0),
              child: Image.asset(
                'assets/images/empty_groups.png',
                width: 180.0,
                height: 171.0,
                fit: BoxFit.contain,
              ).animate().fadeIn(duration: 400.ms).scale(
                    begin: const Offset(0.92, 0.92),
                    end: const Offset(1, 1),
                    curve: Curves.easeOutBack,
                  ),
            ),
            Padding(
              padding:
                  const EdgeInsetsDirectional.fromSTEB(24.0, 16.0, 24.0, 0.0),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Text(
                    'No groups near you yet',
                    textAlign: TextAlign.center,
                    style: FlutterFlowTheme.of(context).titleMedium.override(
                          font: GoogleFonts.baloo2(
                            fontWeight: FlutterFlowTheme.of(context)
                                .titleMedium
                                .fontWeight,
                            fontStyle: FlutterFlowTheme.of(context)
                                .titleMedium
                                .fontStyle,
                          ),
                          color: FlutterFlowTheme.of(context).primaryText,
                          letterSpacing: 0.0,
                          fontWeight: FlutterFlowTheme.of(context)
                              .titleMedium
                              .fontWeight,
                          fontStyle: FlutterFlowTheme.of(context)
                              .titleMedium
                              .fontStyle,
                        ),
                  ),
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                        0.0, 8.0, 0.0, 0.0),
                    child: Text(
                      'Groups near you will show up here once you join or create one.',
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
                            color: FlutterFlowTheme.of(context).secondaryText,
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
                ],
              ),
            )
                .animate()
                .fadeIn(duration: 400.ms, delay: 80.ms)
                .slideY(begin: 0.06, end: 0, curve: Curves.easeOutCubic),
          ],
        ),
      ),
    );
  }
}
