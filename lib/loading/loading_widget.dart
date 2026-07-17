import '/auth/supabase_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'loading_model.dart';
export 'loading_model.dart';

class LoadingWidget extends StatefulWidget {
  const LoadingWidget({
    super.key,
    required this.pageName,
    required this.postId,
  });

  final String? pageName;
  final String? postId;

  static String routeName = 'loading';
  static String routePath = 'loading';

  @override
  State<LoadingWidget> createState() => _LoadingWidgetState();
}

class _LoadingWidgetState extends State<LoadingWidget> {
  late LoadingModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => LoadingModel());

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      if (widget!.pageName == 'post') {
        _model.apiResultpio = await GetPostAllCommentsCall.call(
          pPostId: widget!.postId,
          token: currentJwtToken,
        );

        context.goNamed(
          CommentsPageWidget.routeName,
          queryParameters: {
            'postId': serializeParam(
              widget!.postId,
              ParamType.String,
            ),
            'previousPage': serializeParam(
              'loading',
              ParamType.String,
            ),
          }.withoutNulls,
        );
      } else {
        if (widget!.pageName == 'business') {
          context.goNamed(
            BusinessHomePageWidget.routeName,
            queryParameters: {
              'businessId': serializeParam(
                widget!.postId,
                ParamType.String,
              ),
            }.withoutNulls,
          );
        } else {
          if (widget!.pageName == 'group') {
            context.goNamed(
              GroupDetailsWidget.routeName,
              queryParameters: {
                'groupId': serializeParam(
                  widget!.postId,
                  ParamType.String,
                ),
              }.withoutNulls,
            );
          } else {
            if (widget!.pageName == 'grouppost') {
              _model.showPost1 = await CheckGroupMemberShareCall.call(
                token: currentJwtToken,
                pUserid: currentUserUid,
                pPostid: widget!.postId,
              );

              if (CheckGroupMemberShareCall.showPost(
                    (_model.showPost1?.jsonBody ?? ''),
                  ) ==
                  true) {
                context.goNamed(
                  CommentsPageWidget.routeName,
                  queryParameters: {
                    'postId': serializeParam(
                      widget!.postId,
                      ParamType.String,
                    ),
                  }.withoutNulls,
                );
              } else {
                context.goNamed(
                  GroupDetailsWidget.routeName,
                  queryParameters: {
                    'groupId': serializeParam(
                      widget!.postId,
                      ParamType.String,
                    ),
                  }.withoutNulls,
                );
              }
            } else {
              if (widget!.pageName == 'event') {
                context.goNamed(
                  EventDetailsWidget.routeName,
                  queryParameters: {
                    'eventId': serializeParam(
                      widget!.postId,
                      ParamType.String,
                    ),
                    'pagename': serializeParam(
                      'loading',
                      ParamType.String,
                    ),
                  }.withoutNulls,
                );
              } else {
                if (widget!.pageName == 'chat') {
                  _model.chat = await ChatUsersTable().queryRows(
                    queryFn: (q) => q
                        .eqOrNull(
                          'chat_id',
                          widget!.postId,
                        )
                        .neqOrNull(
                          'user_id',
                          currentUserUid,
                        ),
                  );

                  context.goNamed(
                    MessagePageWidget.routeName,
                    queryParameters: {
                      'chatId': serializeParam(
                        widget!.postId,
                        ParamType.String,
                      ),
                      'userId': serializeParam(
                        currentUserUid,
                        ParamType.String,
                      ),
                      'previousName': serializeParam(
                        'loading',
                        ParamType.String,
                      ),
                    }.withoutNulls,
                  );
                }
              }
            }
          }
        }
      }
    });
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          child: Align(
            alignment: AlignmentDirectional(0.0, 0.0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.asset(
                    'assets/images/Untitled_design.gif',
                    width: 200.0,
                    height: 200.0,
                    fit: BoxFit.cover,
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
