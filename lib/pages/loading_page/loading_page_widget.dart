import '/auth/supabase_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:async';
import 'dart:ui';
import '/custom_code/actions/index.dart' as actions;
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'loading_page_model.dart';
export 'loading_page_model.dart';

class LoadingPageWidget extends StatefulWidget {
  const LoadingPageWidget({
    super.key,
    this.pageName,
    this.postId,
  });

  final String? pageName;
  final String? postId;

  static String routeName = 'loadingPage';
  static String routePath = 'loadingPage';

  @override
  State<LoadingPageWidget> createState() => _LoadingPageWidgetState();
}

class _LoadingPageWidgetState extends State<LoadingPageWidget> {
  late LoadingPageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => LoadingPageModel());

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      _model.isOnline11 = await actions.checkInternetConnect();
      if (_model.isOnline11 == true) {
        await actions.setupNotifications();
        await actions.refreshAndStoreJwtToken();
        _model.publicProfile = await PublicUserProfileTable().queryRows(
          queryFn: (q) => q.eqOrNull(
            'id',
            currentUserUid,
          ),
        );
        _model.userDetails = await UserTable().queryRows(
          queryFn: (q) => q.eqOrNull(
            'id',
            currentUserUid,
          ),
        );
        _model.location = await UserLocationsTable().queryRows(
          queryFn: (q) => q.eqOrNull(
            'id',
            currentUserUid,
          ),
        );
        FFAppState().AsFirstName = _model.userDetails!.firstOrNull!.firstName!;
        FFAppState().AsLastName = _model.userDetails!.firstOrNull!.lastName!;
        FFAppState().AsAddress = _model.userDetails!.firstOrNull!.address!;
        FFAppState().AsFlat = _model.userDetails!.firstOrNull!.flat!;
        FFAppState().AsCity = _model.publicProfile!.firstOrNull!.city!;
        FFAppState().AsProfilePicture =
            _model.publicProfile!.firstOrNull!.profilePicture!;
        FFAppState().AsName = _model.publicProfile!.firstOrNull!.name!;
        FFAppState().AsLatitude = _model.location!.firstOrNull!.latitude!;
        FFAppState().AsLongitude = _model.location!.firstOrNull!.longitude!;
        FFAppState().AsEmail = valueOrDefault<String>(
          _model.userDetails?.firstOrNull?.email,
          'null',
        );
        FFAppState().AsMobileNumer = valueOrDefault<String>(
          _model.userDetails?.firstOrNull?.mobileNumber,
          'null',
        );
        safeSetState(() {});
        _model.group = await GetGroupsWithUserStatusCall.call(
          apiKey: FFDevEnvironmentValues().AnonKey,
          token: currentJwtToken,
        );

        FFAppState().AsGroupList = getJsonField(
          (_model.group?.jsonBody ?? ''),
          r'''$''',
        );
        safeSetState(() {});
        _model.post1 = await GetPostCall.call(
          anonKey: FFDevEnvironmentValues().AnonKey,
          token: currentJwtToken,
        );

        FFAppState().AsPost = getJsonField(
          (_model.post1?.jsonBody ?? ''),
          r'''$''',
        );
        safeSetState(() {});
        _model.userChat = await GetChatCall.call(
          apiKey: FFDevEnvironmentValues().AnonKey,
          token: currentJwtToken,
          searchQuery: ' ',
        );

        FFAppState().matchedUsers = getJsonField(
          (_model.userChat?.jsonBody ?? ''),
          r'''$''',
        );
        safeSetState(() {});
        unawaited(
          () async {
            await actions.initRealtimeChatUpdates();
          }(),
        );
        unawaited(
          () async {
            await actions.initRealtimeGroupUpdates();
          }(),
        );
        await actions.initRealtimePostUpdates();
        _model.checknotificationStatus =
            await actions.checkNotificationAndStoreFCMToken(
          FFDevEnvironmentValues().AnonKey,
        );
        FFAppState().notify = true;
        safeSetState(() {});
        if (_model.userDetails?.firstOrNull?.isDeleted == true) {
          context.goNamed(AccountDeletedWidget.routeName);

          return;
        } else {
          if ((widget!.pageName != null && widget!.pageName != '') &&
              (widget!.postId != null && widget!.postId != '')) {
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
                    _model.showPost = await CheckGroupMemberShareCall.call(
                      token: currentJwtToken,
                      pUserid: currentUserUid,
                      pPostid: widget!.postId,
                    );

                    if (CheckGroupMemberShareCall.showPost(
                          (_model.showPost?.jsonBody ?? ''),
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
                            CheckGroupMemberShareCall.groupid(
                              (_model.showPost?.jsonBody ?? ''),
                            ),
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
                              _model.chat?.firstOrNull?.userId,
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
          } else {
            context.goNamed(HomePageWidget.routeName);
          }
        }
      } else {
        context.pushNamed(
          NoInternetPageWidget.routeName,
          queryParameters: {
            'pageName': serializeParam(
              '',
              ParamType.String,
            ),
          }.withoutNulls,
        );
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
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(),
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
