import '/auth/supabase_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'dummylikecomponent_model.dart';
export 'dummylikecomponent_model.dart';

class DummylikecomponentWidget extends StatefulWidget {
  const DummylikecomponentWidget({
    super.key,
    this.parameter1,
  });

  final String? parameter1;

  @override
  State<DummylikecomponentWidget> createState() =>
      _DummylikecomponentWidgetState();
}

class _DummylikecomponentWidgetState extends State<DummylikecomponentWidget> {
  late DummylikecomponentModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DummylikecomponentModel());
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    return Stack(
      children: [
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            InkWell(
              splashColor: Colors.transparent,
              focusColor: Colors.transparent,
              hoverColor: Colors.transparent,
              highlightColor: Colors.transparent,
              onTap: () async {
                await AddLikeCall.call(
                  pCommunityid: FFAppState().communityId.toString(),
                  pUserid: currentUserUid,
                  pPostid: widget!.parameter1,
                  token: currentJwtToken,
                );

                safeSetState(() => _model.requestCompleter = null);
              },
              child: Icon(
                Icons.favorite_border,
                color: FlutterFlowTheme.of(context).greyL4,
                size: 22.0,
              ),
            ),
            FutureBuilder<List<PostLikeRow>>(
              future:
                  (_model.requestCompleter ??= Completer<List<PostLikeRow>>()
                        ..complete(PostLikeTable().querySingleRow(
                          queryFn: (q) => q
                              .eqOrNull(
                                'post_id',
                                widget!.parameter1,
                              )
                              .eqOrNull(
                                'user_id',
                                currentUserUid,
                              ),
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
                        valueColor: AlwaysStoppedAnimation<Color>(
                          FlutterFlowTheme.of(context).primary,
                        ),
                      ),
                    ),
                  );
                }
                List<PostLikeRow> iconPostLikeRowList = snapshot.data!;

                // Return an empty Container when the item does not exist.
                if (snapshot.data!.isEmpty) {
                  return Container();
                }
                final iconPostLikeRow = iconPostLikeRowList.isNotEmpty
                    ? iconPostLikeRowList.first
                    : null;

                return InkWell(
                  splashColor: Colors.transparent,
                  focusColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: () async {
                    await AddLikeCall.call(
                      pCommunityid: FFAppState().communityId.toString(),
                      pUserid: currentUserUid,
                      pPostid: widget!.parameter1,
                      token: currentJwtToken,
                    );

                    safeSetState(() => _model.requestCompleter = null);
                  },
                  child: Icon(
                    Icons.favorite,
                    color: FlutterFlowTheme.of(context).redColor2,
                    size: 22.0,
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }
}
