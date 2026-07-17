import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

import '/backend/schema/enums/enums.dart';
import '/backend/supabase/supabase.dart';

import '/auth/base_auth_user_provider.dart';

import '/main.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/lat_lng.dart';
import '/flutter_flow/place.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'serialization_util.dart';

import '/index.dart';

export 'package:go_router/go_router.dart';
export 'serialization_util.dart';

const kTransitionInfoKey = '__transition_info__';

GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

class AppStateNotifier extends ChangeNotifier {
  AppStateNotifier._();

  static AppStateNotifier? _instance;
  static AppStateNotifier get instance => _instance ??= AppStateNotifier._();

  BaseAuthUser? initialUser;
  BaseAuthUser? user;
  bool showSplashImage = true;
  String? _redirectLocation;

  /// Determines whether the app will refresh and build again when a sign
  /// in or sign out happens. This is useful when the app is launched or
  /// on an unexpected logout. However, this must be turned off when we
  /// intend to sign in/out and then navigate or perform any actions after.
  /// Otherwise, this will trigger a refresh and interrupt the action(s).
  bool notifyOnAuthChange = true;

  bool get loading => user == null || showSplashImage;
  bool get loggedIn => user?.loggedIn ?? false;
  bool get initiallyLoggedIn => initialUser?.loggedIn ?? false;
  bool get shouldRedirect => loggedIn && _redirectLocation != null;

  String getRedirectLocation() => _redirectLocation!;
  bool hasRedirect() => _redirectLocation != null;
  void setRedirectLocationIfUnset(String loc) => _redirectLocation ??= loc;
  void clearRedirectLocation() => _redirectLocation = null;

  /// Mark as not needing to notify on a sign in / out when we intend
  /// to perform subsequent actions (such as navigation) afterwards.
  void updateNotifyOnAuthChange(bool notify) => notifyOnAuthChange = notify;

  void update(BaseAuthUser newUser) {
    final shouldUpdate =
        user?.uid == null || newUser.uid == null || user?.uid != newUser.uid;
    initialUser ??= newUser;
    user = newUser;
    // Refresh the app on auth change unless explicitly marked otherwise.
    // No need to update unless the user has changed.
    if (notifyOnAuthChange && shouldUpdate) {
      notifyListeners();
    }
    // Once again mark the notifier as needing to update on auth change
    // (in order to catch sign in / out events).
    updateNotifyOnAuthChange(true);
  }

  void stopShowingSplashImage() {
    showSplashImage = false;
    notifyListeners();
  }
}

GoRouter createRouter(AppStateNotifier appStateNotifier) => GoRouter(
      initialLocation: '/',
      debugLogDiagnostics: true,
      refreshListenable: appStateNotifier,
      navigatorKey: appNavigatorKey,
      errorBuilder: (context, state) =>
          appStateNotifier.loggedIn ? LoadingPageWidget() : SplashWidget(),
      routes: [
        FFRoute(
          name: '_initialize',
          path: '/',
          builder: (context, _) =>
              appStateNotifier.loggedIn ? LoadingPageWidget() : SplashWidget(),
          routes: [
            FFRoute(
              name: SaleWidget.routeName,
              path: SaleWidget.routePath,
              builder: (context, params) => SaleWidget(
                pageType: params.getParam(
                  'pageType',
                  ParamType.String,
                ),
              ),
            ),
            FFRoute(
              name: EventDetailsWidget.routeName,
              path: EventDetailsWidget.routePath,
              builder: (context, params) => EventDetailsWidget(
                eventId: params.getParam(
                  'eventId',
                  ParamType.String,
                ),
                pagename: params.getParam(
                  'pagename',
                  ParamType.String,
                ),
              ),
            ),
            FFRoute(
              name: CreatePostWidget.routeName,
              path: CreatePostWidget.routePath,
              builder: (context, params) => CreatePostWidget(
                groupId: params.getParam(
                  'groupId',
                  ParamType.String,
                ),
              ),
            ),
            FFRoute(
              name: SplashWidget.routeName,
              path: SplashWidget.routePath,
              builder: (context, params) => SplashWidget(),
            ),
            FFRoute(
              name: LoginPageWidget.routeName,
              path: LoginPageWidget.routePath,
              builder: (context, params) => LoginPageWidget(),
            ),
            FFRoute(
              name: EmailLoginPageWidget.routeName,
              path: EmailLoginPageWidget.routePath,
              builder: (context, params) => EmailLoginPageWidget(),
            ),
            FFRoute(
              name: VerifyPageWidget.routeName,
              path: VerifyPageWidget.routePath,
              builder: (context, params) => VerifyPageWidget(
                verifiedByEmailOrMobile: params.getParam(
                  'verifiedByEmailOrMobile',
                  ParamType.String,
                ),
                emailOrMobileNumber: params.getParam(
                  'emailOrMobileNumber',
                  ParamType.String,
                ),
                verifyType: params.getParam(
                  'verifyType',
                  ParamType.String,
                ),
              ),
            ),
            FFRoute(
              name: CreateAccountPageWidget.routeName,
              path: CreateAccountPageWidget.routePath,
              builder: (context, params) => CreateAccountPageWidget(),
            ),
            FFRoute(
              name: LocationPageWidget.routeName,
              path: LocationPageWidget.routePath,
              builder: (context, params) => LocationPageWidget(
                pageName: params.getParam(
                  'pageName',
                  ParamType.String,
                ),
              ),
            ),
            FFRoute(
              name: FinalStepsMailPageWidget.routeName,
              path: FinalStepsMailPageWidget.routePath,
              builder: (context, params) => FinalStepsMailPageWidget(),
            ),
            FFRoute(
              name: FinalStepsPhonePageWidget.routeName,
              path: FinalStepsPhonePageWidget.routePath,
              builder: (context, params) => FinalStepsPhonePageWidget(),
            ),
            FFRoute(
              name: GroupsWidget.routeName,
              path: GroupsWidget.routePath,
              builder: (context, params) => GroupsWidget(),
            ),
            FFRoute(
              name: ArchivedChatsPageWidget.routeName,
              path: ArchivedChatsPageWidget.routePath,
              builder: (context, params) => ArchivedChatsPageWidget(),
            ),
            FFRoute(
              name: CreateGroupWidget.routeName,
              path: CreateGroupWidget.routePath,
              builder: (context, params) => CreateGroupWidget(),
            ),
            FFRoute(
              name: CreatePollDeletedWidget.routeName,
              path: CreatePollDeletedWidget.routePath,
              builder: (context, params) => CreatePollDeletedWidget(),
            ),
            FFRoute(
              name: ThankNeighborDeletedWidget.routeName,
              path: ThankNeighborDeletedWidget.routePath,
              builder: (context, params) => ThankNeighborDeletedWidget(),
            ),
            FFRoute(
              name: PostAboutSafetyDeletedWidget.routeName,
              path: PostAboutSafetyDeletedWidget.routePath,
              builder: (context, params) => PostAboutSafetyDeletedWidget(),
            ),
            FFRoute(
              name: ListingDetailsNoPhotosWidget.routeName,
              path: ListingDetailsNoPhotosWidget.routePath,
              builder: (context, params) => ListingDetailsNoPhotosWidget(),
            ),
            FFRoute(
              name: ProfileWidget.routeName,
              path: ProfileWidget.routePath,
              builder: (context, params) => ProfileWidget(),
            ),
            FFRoute(
              name: AccountSettingsWidget.routeName,
              path: AccountSettingsWidget.routePath,
              builder: (context, params) => AccountSettingsWidget(),
            ),
            FFRoute(
              name: ChangePasswordWidget.routeName,
              path: ChangePasswordWidget.routePath,
              builder: (context, params) => ChangePasswordWidget(),
            ),
            FFRoute(
              name: FollowingWidget.routeName,
              path: FollowingWidget.routePath,
              builder: (context, params) => FollowingWidget(),
            ),
            FFRoute(
              name: FollowersWidget.routeName,
              path: FollowersWidget.routePath,
              builder: (context, params) => FollowersWidget(),
            ),
            FFRoute(
              name: SwitchProfileDeletedWidget.routeName,
              path: SwitchProfileDeletedWidget.routePath,
              builder: (context, params) => SwitchProfileDeletedWidget(),
            ),
            FFRoute(
              name: BlockedUsersWidget.routeName,
              path: BlockedUsersWidget.routePath,
              builder: (context, params) => BlockedUsersWidget(),
            ),
            FFRoute(
              name: HibernateAccountWidget.routeName,
              path: HibernateAccountWidget.routePath,
              builder: (context, params) => HibernateAccountWidget(),
            ),
            FFRoute(
              name: PendingInvitesWidget.routeName,
              path: PendingInvitesWidget.routePath,
              builder: (context, params) => PendingInvitesWidget(),
            ),
            FFRoute(
              name: FollowedPagesWidget.routeName,
              path: FollowedPagesWidget.routePath,
              builder: (context, params) => FollowedPagesWidget(),
            ),
            FFRoute(
              name: MyPagesWidget.routeName,
              path: MyPagesWidget.routePath,
              builder: (context, params) => MyPagesWidget(),
            ),
            FFRoute(
              name: CreatePageWidget.routeName,
              path: CreatePageWidget.routePath,
              builder: (context, params) => CreatePageWidget(
                pageType: params.getParam(
                  'pageType',
                  ParamType.String,
                ),
                businessId: params.getParam(
                  'businessId',
                  ParamType.String,
                ),
              ),
            ),
            FFRoute(
              name: ForgetPasswordWidget.routeName,
              path: ForgetPasswordWidget.routePath,
              builder: (context, params) => ForgetPasswordWidget(),
            ),
            FFRoute(
              name: DeleteAccountWidget.routeName,
              path: DeleteAccountWidget.routePath,
              builder: (context, params) => DeleteAccountWidget(),
            ),
            FFRoute(
              name: NeighbourhoodsFollowingWidget.routeName,
              path: NeighbourhoodsFollowingWidget.routePath,
              builder: (context, params) => NeighbourhoodsFollowingWidget(),
            ),
            FFRoute(
              name: NeighborhoodsWidget.routeName,
              path: NeighborhoodsWidget.routePath,
              builder: (context, params) => NeighborhoodsWidget(),
            ),
            FFRoute(
              name: NeighbourhoodExploreWidget.routeName,
              path: NeighbourhoodExploreWidget.routePath,
              builder: (context, params) => NeighbourhoodExploreWidget(),
            ),
            FFRoute(
              name: SpecificUserGroupsWidget.routeName,
              path: SpecificUserGroupsWidget.routePath,
              builder: (context, params) => SpecificUserGroupsWidget(),
            ),
            FFRoute(
              name: ResetPasswordWidget.routeName,
              path: ResetPasswordWidget.routePath,
              builder: (context, params) => ResetPasswordWidget(
                emailOrMobileNumber: params.getParam(
                  'emailOrMobileNumber',
                  ParamType.String,
                ),
                isMobile: params.getParam(
                  'isMobile',
                  ParamType.bool,
                ),
              ),
            ),
            FFRoute(
              name: SearchWidget.routeName,
              path: SearchWidget.routePath,
              builder: (context, params) => SearchWidget(
                searchName: params.getParam(
                  'searchName',
                  ParamType.String,
                ),
              ),
            ),
            FFRoute(
              name: LoadingPageWidget.routeName,
              path: LoadingPageWidget.routePath,
              builder: (context, params) => LoadingPageWidget(
                pageName: params.getParam(
                  'pageName',
                  ParamType.String,
                ),
                postId: params.getParam(
                  'postId',
                  ParamType.String,
                ),
              ),
            ),
            FFRoute(
              name: UserAllPostWidget.routeName,
              path: UserAllPostWidget.routePath,
              builder: (context, params) => UserAllPostWidget(
                userid: params.getParam(
                  'userid',
                  ParamType.String,
                ),
              ),
            ),
            FFRoute(
              name: EditpostWidget.routeName,
              path: EditpostWidget.routePath,
              builder: (context, params) => EditpostWidget(
                postid: params.getParam(
                  'postid',
                  ParamType.String,
                ),
                groupId: params.getParam(
                  'groupId',
                  ParamType.String,
                ),
                content: params.getParam(
                  'content',
                  ParamType.String,
                ),
              ),
            ),
            FFRoute(
              name: DummyWidget.routeName,
              path: DummyWidget.routePath,
              builder: (context, params) => DummyWidget(),
            ),
            FFRoute(
              name: PromoteBusinessWidget.routeName,
              path: PromoteBusinessWidget.routePath,
              builder: (context, params) => PromoteBusinessWidget(
                businessId: params.getParam(
                  'businessId',
                  ParamType.String,
                ),
                pagetype: params.getParam(
                  'pagetype',
                  ParamType.String,
                ),
              ),
            ),
            FFRoute(
              name: UploadReceiptWidget.routeName,
              path: UploadReceiptWidget.routePath,
              builder: (context, params) => UploadReceiptWidget(
                amount: params.getParam(
                  'amount',
                  ParamType.String,
                ),
                planid: params.getParam(
                  'planid',
                  ParamType.int,
                ),
                businessId: params.getParam(
                  'businessId',
                  ParamType.String,
                ),
                type: params.getParam(
                  'type',
                  ParamType.String,
                ),
              ),
            ),
            FFRoute(
              name: CreateEventWidget.routeName,
              path: CreateEventWidget.routePath,
              builder: (context, params) => CreateEventWidget(),
            ),
            FFRoute(
              name: EditGroupWidget.routeName,
              path: EditGroupWidget.routePath,
              builder: (context, params) => EditGroupWidget(
                groupId: params.getParam(
                  'groupId',
                  ParamType.String,
                ),
              ),
            ),
            FFRoute(
              name: NearestGroupsWidget.routeName,
              path: NearestGroupsWidget.routePath,
              builder: (context, params) => NearestGroupsWidget(),
            ),
            FFRoute(
              name: AllGroupsWidget.routeName,
              path: AllGroupsWidget.routePath,
              builder: (context, params) => AllGroupsWidget(),
            ),
            FFRoute(
              name: ListingDetailsWidget.routeName,
              path: ListingDetailsWidget.routePath,
              builder: (context, params) => ListingDetailsWidget(
                uploadFiles: params.getParam<FFUploadedFile>(
                  'uploadFiles',
                  ParamType.FFUploadedFile,
                  isList: true,
                ),
              ),
            ),
            FFRoute(
              name: AllEventsWidget.routeName,
              path: AllEventsWidget.routePath,
              builder: (context, params) => AllEventsWidget(),
            ),
            FFRoute(
              name: EditEventWidget.routeName,
              path: EditEventWidget.routePath,
              builder: (context, params) => EditEventWidget(
                eventId: params.getParam(
                  'eventId',
                  ParamType.String,
                ),
              ),
            ),
            FFRoute(
              name: RealTimeTestingWidget.routeName,
              path: RealTimeTestingWidget.routePath,
              builder: (context, params) => RealTimeTestingWidget(),
            ),
            FFRoute(
              name: HomePageWidget.routeName,
              path: HomePageWidget.routePath,
              builder: (context, params) => HomePageWidget(
                pageName: params.getParam(
                  'pageName',
                  ParamType.String,
                ),
              ),
            ),
            FFRoute(
              name: CommunityWidget.routeName,
              path: CommunityWidget.routePath,
              builder: (context, params) => CommunityWidget(
                pageType: params.getParam(
                  'pageType',
                  ParamType.String,
                ),
              ),
            ),
            FFRoute(
              name: NotificationWidget.routeName,
              path: NotificationWidget.routePath,
              builder: (context, params) => NotificationWidget(),
            ),
            FFRoute(
              name: MyGroupWidget.routeName,
              path: MyGroupWidget.routePath,
              builder: (context, params) => MyGroupWidget(
                initialButton: params.getParam(
                  'initialButton',
                  ParamType.String,
                ),
              ),
            ),
            FFRoute(
              name: GroupDetailsWidget.routeName,
              path: GroupDetailsWidget.routePath,
              builder: (context, params) => GroupDetailsWidget(
                groupId: params.getParam(
                  'groupId',
                  ParamType.String,
                ),
              ),
            ),
            FFRoute(
              name: ChatWidget.routeName,
              path: ChatWidget.routePath,
              builder: (context, params) => ChatWidget(
                selectMessage: params.getParam(
                  'selectMessage',
                  ParamType.bool,
                ),
                previousPage: params.getParam(
                  'previousPage',
                  ParamType.String,
                ),
              ),
            ),
            FFRoute(
              name: CommentsPageWidget.routeName,
              path: CommentsPageWidget.routePath,
              builder: (context, params) => CommentsPageWidget(
                postId: params.getParam(
                  'postId',
                  ParamType.String,
                ),
                previousPage: params.getParam(
                  'previousPage',
                  ParamType.String,
                ),
              ),
            ),
            FFRoute(
              name: MessagePageWidget.routeName,
              path: MessagePageWidget.routePath,
              builder: (context, params) => MessagePageWidget(
                chatId: params.getParam(
                  'chatId',
                  ParamType.String,
                ),
                userId: params.getParam(
                  'userId',
                  ParamType.String,
                ),
                previousName: params.getParam(
                  'previousName',
                  ParamType.String,
                ),
              ),
            ),
            FFRoute(
              name: PersonalDetailsWidget.routeName,
              path: PersonalDetailsWidget.routePath,
              builder: (context, params) => PersonalDetailsWidget(),
            ),
            FFRoute(
              name: UserProfileWidget.routeName,
              path: UserProfileWidget.routePath,
              builder: (context, params) => UserProfileWidget(),
            ),
            FFRoute(
              name: OtherProfileWidget.routeName,
              path: OtherProfileWidget.routePath,
              builder: (context, params) => OtherProfileWidget(
                userid: params.getParam(
                  'userid',
                  ParamType.String,
                ),
              ),
            ),
            FFRoute(
              name: BusinessHomePageWidget.routeName,
              path: BusinessHomePageWidget.routePath,
              builder: (context, params) => BusinessHomePageWidget(
                businessId: params.getParam(
                  'businessId',
                  ParamType.String,
                ),
              ),
            ),
            FFRoute(
              name: AboutGroupWidget.routeName,
              path: AboutGroupWidget.routePath,
              builder: (context, params) => AboutGroupWidget(
                groupId: params.getParam(
                  'groupId',
                  ParamType.String,
                ),
              ),
            ),
            FFRoute(
              name: LatestEventWidget.routeName,
              path: LatestEventWidget.routePath,
              builder: (context, params) => LatestEventWidget(),
            ),
            FFRoute(
              name: TestingPageWidget.routeName,
              path: TestingPageWidget.routePath,
              builder: (context, params) => TestingPageWidget(),
            ),
            FFRoute(
              name: Testing2Widget.routeName,
              path: Testing2Widget.routePath,
              builder: (context, params) => Testing2Widget(),
            ),
            FFRoute(
              name: EndingEventWidget.routeName,
              path: EndingEventWidget.routePath,
              builder: (context, params) => EndingEventWidget(),
            ),
            FFRoute(
              name: SaleDetailsWidget.routeName,
              path: SaleDetailsWidget.routePath,
              builder: (context, params) => SaleDetailsWidget(
                saleId: params.getParam(
                  'saleId',
                  ParamType.String,
                ),
              ),
            ),
            FFRoute(
              name: SupportpageWidget.routeName,
              path: SupportpageWidget.routePath,
              builder: (context, params) => SupportpageWidget(),
            ),
            FFRoute(
              name: AccountDeletedWidget.routeName,
              path: AccountDeletedWidget.routePath,
              builder: (context, params) => AccountDeletedWidget(),
            ),
            FFRoute(
              name: MyEventWidget.routeName,
              path: MyEventWidget.routePath,
              builder: (context, params) => MyEventWidget(
                btnOption: params.getParam(
                  'btnOption',
                  ParamType.String,
                ),
              ),
            ),
            FFRoute(
              name: ListingDetailsNoPhotosEditWidget.routeName,
              path: ListingDetailsNoPhotosEditWidget.routePath,
              builder: (context, params) => ListingDetailsNoPhotosEditWidget(
                saleId: params.getParam(
                  'saleId',
                  ParamType.String,
                ),
              ),
            ),
            FFRoute(
              name: ListingDetailsEditWidget.routeName,
              path: ListingDetailsEditWidget.routePath,
              builder: (context, params) => ListingDetailsEditWidget(
                saleId: params.getParam(
                  'saleId',
                  ParamType.String,
                ),
              ),
            ),
            FFRoute(
              name: TermsAndConditionsWidget.routeName,
              path: TermsAndConditionsWidget.routePath,
              builder: (context, params) => TermsAndConditionsWidget(),
            ),
            FFRoute(
              name: LoadingWidget.routeName,
              path: LoadingWidget.routePath,
              requireAuth: true,
              builder: (context, params) => LoadingWidget(
                pageName: params.getParam(
                  'pageName',
                  ParamType.String,
                ),
                postId: params.getParam(
                  'postId',
                  ParamType.String,
                ),
              ),
            ),
            FFRoute(
              name: NoInternetPageWidget.routeName,
              path: NoInternetPageWidget.routePath,
              builder: (context, params) => NoInternetPageWidget(
                pageName: params.getParam(
                  'pageName',
                  ParamType.String,
                ),
              ),
            )
          ].map((r) => r.toRoute(appStateNotifier)).toList(),
        ),
      ].map((r) => r.toRoute(appStateNotifier)).toList(),
    );

extension NavParamExtensions on Map<String, String?> {
  Map<String, String> get withoutNulls => Map.fromEntries(
        entries
            .where((e) => e.value != null)
            .map((e) => MapEntry(e.key, e.value!)),
      );
}

extension NavigationExtensions on BuildContext {
  void goNamedAuth(
    String name,
    bool mounted, {
    Map<String, String> pathParameters = const <String, String>{},
    Map<String, String> queryParameters = const <String, String>{},
    Object? extra,
    bool ignoreRedirect = false,
  }) =>
      !mounted || GoRouter.of(this).shouldRedirect(ignoreRedirect)
          ? null
          : goNamed(
              name,
              pathParameters: pathParameters,
              queryParameters: queryParameters,
              extra: extra,
            );

  void pushNamedAuth(
    String name,
    bool mounted, {
    Map<String, String> pathParameters = const <String, String>{},
    Map<String, String> queryParameters = const <String, String>{},
    Object? extra,
    bool ignoreRedirect = false,
  }) =>
      !mounted || GoRouter.of(this).shouldRedirect(ignoreRedirect)
          ? null
          : pushNamed(
              name,
              pathParameters: pathParameters,
              queryParameters: queryParameters,
              extra: extra,
            );

  void safePop() {
    // If there is only one route on the stack, navigate to the initial
    // page instead of popping.
    if (canPop()) {
      pop();
    } else {
      go('/');
    }
  }
}

extension GoRouterExtensions on GoRouter {
  AppStateNotifier get appState => AppStateNotifier.instance;
  void prepareAuthEvent([bool ignoreRedirect = false]) =>
      appState.hasRedirect() && !ignoreRedirect
          ? null
          : appState.updateNotifyOnAuthChange(false);
  bool shouldRedirect(bool ignoreRedirect) =>
      !ignoreRedirect && appState.hasRedirect();
  void clearRedirectLocation() => appState.clearRedirectLocation();
  void setRedirectLocationIfUnset(String location) =>
      appState.updateNotifyOnAuthChange(false);
}

extension _GoRouterStateExtensions on GoRouterState {
  Map<String, dynamic> get extraMap =>
      extra != null ? extra as Map<String, dynamic> : {};
  Map<String, dynamic> get allParams => <String, dynamic>{}
    ..addAll(pathParameters)
    ..addAll(uri.queryParameters)
    ..addAll(extraMap);
  TransitionInfo get transitionInfo => extraMap.containsKey(kTransitionInfoKey)
      ? extraMap[kTransitionInfoKey] as TransitionInfo
      : TransitionInfo.appDefault();
}

class FFParameters {
  FFParameters(this.state, [this.asyncParams = const {}]);

  final GoRouterState state;
  final Map<String, Future<dynamic> Function(String)> asyncParams;

  Map<String, dynamic> futureParamValues = {};

  // Parameters are empty if the params map is empty or if the only parameter
  // present is the special extra parameter reserved for the transition info.
  bool get isEmpty =>
      state.allParams.isEmpty ||
      (state.allParams.length == 1 &&
          state.extraMap.containsKey(kTransitionInfoKey));
  bool isAsyncParam(MapEntry<String, dynamic> param) =>
      asyncParams.containsKey(param.key) && param.value is String;
  bool get hasFutures => state.allParams.entries.any(isAsyncParam);
  Future<bool> completeFutures() => Future.wait(
        state.allParams.entries.where(isAsyncParam).map(
          (param) async {
            final doc = await asyncParams[param.key]!(param.value)
                .onError((_, __) => null);
            if (doc != null) {
              futureParamValues[param.key] = doc;
              return true;
            }
            return false;
          },
        ),
      ).onError((_, __) => [false]).then((v) => v.every((e) => e));

  dynamic getParam<T>(
    String paramName,
    ParamType type, {
    bool isList = false,
  }) {
    if (futureParamValues.containsKey(paramName)) {
      return futureParamValues[paramName];
    }
    if (!state.allParams.containsKey(paramName)) {
      return null;
    }
    final param = state.allParams[paramName];
    // Got parameter from `extras`, so just directly return it.
    if (param is! String) {
      return param;
    }
    // Return serialized value.
    return deserializeParam<T>(
      param,
      type,
      isList,
    );
  }
}

class FFRoute {
  const FFRoute({
    required this.name,
    required this.path,
    required this.builder,
    this.requireAuth = false,
    this.asyncParams = const {},
    this.routes = const [],
  });

  final String name;
  final String path;
  final bool requireAuth;
  final Map<String, Future<dynamic> Function(String)> asyncParams;
  final Widget Function(BuildContext, FFParameters) builder;
  final List<GoRoute> routes;

  GoRoute toRoute(AppStateNotifier appStateNotifier) => GoRoute(
        name: name,
        path: path,
        redirect: (context, state) {
          if (appStateNotifier.shouldRedirect) {
            final redirectLocation = appStateNotifier.getRedirectLocation();
            appStateNotifier.clearRedirectLocation();
            return redirectLocation;
          }

          if (requireAuth && !appStateNotifier.loggedIn) {
            appStateNotifier.setRedirectLocationIfUnset(state.uri.toString());
            return '/splash';
          }
          return null;
        },
        pageBuilder: (context, state) {
          fixStatusBarOniOS16AndBelow(context);
          final ffParams = FFParameters(state, asyncParams);
          final page = ffParams.hasFutures
              ? FutureBuilder(
                  future: ffParams.completeFutures(),
                  builder: (context, _) => builder(context, ffParams),
                )
              : builder(context, ffParams);
          final child = appStateNotifier.loading
              ? Container(
                  color: Colors.transparent,
                  child: Center(
                    child: Image.asset(
                      'assets/images/Group_2_(1).png',
                      width: 125.0,
                      height: 125.0,
                      fit: BoxFit.cover,
                    ),
                  ),
                )
              : page;

          final transitionInfo = state.transitionInfo;
          return transitionInfo.hasTransition
              ? CustomTransitionPage(
                  key: state.pageKey,
                  name: state.name,
                  child: child,
                  transitionDuration: transitionInfo.duration,
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) =>
                          PageTransition(
                    type: transitionInfo.transitionType,
                    duration: transitionInfo.duration,
                    reverseDuration: transitionInfo.duration,
                    alignment: transitionInfo.alignment,
                    child: child,
                  ).buildTransitions(
                    context,
                    animation,
                    secondaryAnimation,
                    child,
                  ),
                )
              : MaterialPage(
                  key: state.pageKey, name: state.name, child: child);
        },
        routes: routes,
      );
}

class TransitionInfo {
  const TransitionInfo({
    required this.hasTransition,
    this.transitionType = PageTransitionType.fade,
    this.duration = const Duration(milliseconds: 300),
    this.alignment,
  });

  final bool hasTransition;
  final PageTransitionType transitionType;
  final Duration duration;
  final Alignment? alignment;

  static TransitionInfo appDefault() => TransitionInfo(hasTransition: false);
}

class RootPageContext {
  const RootPageContext(this.isRootPage, [this.errorRoute]);
  final bool isRootPage;
  final String? errorRoute;

  static bool isInactiveRootPage(BuildContext context) {
    final rootPageContext = context.read<RootPageContext?>();
    final isRootPage = rootPageContext?.isRootPage ?? false;
    final location = GoRouterState.of(context).uri.toString();
    return isRootPage &&
        location != '/' &&
        location != rootPageContext?.errorRoute;
  }

  static Widget wrap(Widget child, {String? errorRoute}) => Provider.value(
        value: RootPageContext(true, errorRoute),
        child: child,
      );
}

extension GoRouterLocationExtension on GoRouter {
  String getCurrentLocation() {
    final RouteMatch lastMatch = routerDelegate.currentConfiguration.last;
    final RouteMatchList matchList = lastMatch is ImperativeRouteMatch
        ? lastMatch.matches
        : routerDelegate.currentConfiguration;
    return matchList.uri.toString();
  }
}
