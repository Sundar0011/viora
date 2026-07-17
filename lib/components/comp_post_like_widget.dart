import '/auth/supabase_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/pages/home/comp_likes/comp_likes_widget.dart';
import 'dart:ui';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'comp_post_like_model.dart';
export 'comp_post_like_model.dart';

class CompPostLikeWidget extends StatefulWidget {
  const CompPostLikeWidget({
    super.key,
    this.parameter1,
    this.parameter2,
    this.parameter3,
  });

  final String? parameter1;
  final int? parameter2;
  final String? parameter3;

  @override
  State<CompPostLikeWidget> createState() => _CompPostLikeWidgetState();
}

class _CompPostLikeWidgetState extends State<CompPostLikeWidget> {
  late CompPostLikeModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => CompPostLikeModel());
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        Stack(
          children: [
            InkWell(
              splashColor: Colors.transparent,
              focusColor: Colors.transparent,
              hoverColor: Colors.transparent,
              highlightColor: Colors.transparent,
              onTap: () async {
                _model.addlike = await AddLikeCall.call(
                  pCommunityid: FFAppState().communityId.toString(),
                  pUserid: currentUserUid,
                  pPostid: widget!.parameter1,
                  token: currentJwtToken,
                );

                safeSetState(() => _model.requestCompleter = null);

                safeSetState(() {});
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
                    _model.addlike2 = await AddLikeCall.call(
                      pCommunityid: FFAppState().communityId.toString(),
                      pUserid: currentUserUid,
                      pPostid: widget!.parameter1,
                      token: currentJwtToken,
                    );

                    safeSetState(() => _model.requestCompleter = null);

                    safeSetState(() {});
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
                return Padding(
                  padding: MediaQuery.viewInsetsOf(context),
                  child: CompLikesWidget(
                    postId: widget!.parameter1!,
                    postUserid: widget!.parameter3!,
                  ),
                );
              },
            ).then((value) => safeSetState(() {}));
          },
          child: Text(
            valueOrDefault<String>(
              widget!.parameter2?.toString(),
              '0',
            ),
            style: FlutterFlowTheme.of(context).bodyMedium.override(
                  font: GoogleFonts.manrope(
                    fontWeight: FontWeight.w500,
                    fontStyle:
                        FlutterFlowTheme.of(context).bodyMedium.fontStyle,
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
      ],
    );
  }
}
