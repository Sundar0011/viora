import 'package:flutter/material.dart';
import '/backend/schema/enums/enums.dart';
import '/backend/api_requests/api_manager.dart';
import 'backend/supabase/supabase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'flutter_flow/flutter_flow_util.dart';
import 'dart:convert';

class FFAppState extends ChangeNotifier {
  static FFAppState _instance = FFAppState._internal();

  factory FFAppState() {
    return _instance;
  }

  FFAppState._internal();

  static void reset() {
    _instance = FFAppState._internal();
  }

  Future initializePersistedState() async {
    prefs = await SharedPreferences.getInstance();
    _safeInit(() {
      _communityId = prefs.getInt('ff_communityId') ?? _communityId;
    });
    _safeInit(() {
      _AsCoverImage = prefs.getString('ff_AsCoverImage') ?? _AsCoverImage;
    });
    _safeInit(() {
      _AsGroupCover = prefs.getString('ff_AsGroupCover') ?? _AsGroupCover;
    });
    _safeInit(() {
      _AsBusinessCover =
          prefs.getString('ff_AsBusinessCover') ?? _AsBusinessCover;
    });
    _safeInit(() {
      _AsBusinessProfile =
          prefs.getString('ff_AsBusinessProfile') ?? _AsBusinessProfile;
    });
    _safeInit(() {
      _ChoosedEventDate = prefs.containsKey('ff_ChoosedEventDate')
          ? DateTime.fromMillisecondsSinceEpoch(
              prefs.getInt('ff_ChoosedEventDate')!)
          : _ChoosedEventDate;
    });
    _safeInit(() {
      _ChoosedStartEventDate = prefs.containsKey('ff_ChoosedStartEventDate')
          ? DateTime.fromMillisecondsSinceEpoch(
              prefs.getInt('ff_ChoosedStartEventDate')!)
          : _ChoosedStartEventDate;
    });
    _safeInit(() {
      _ChoosedEndEventDate = prefs.containsKey('ff_ChoosedEndEventDate')
          ? DateTime.fromMillisecondsSinceEpoch(
              prefs.getInt('ff_ChoosedEndEventDate')!)
          : _ChoosedEndEventDate;
    });
    _safeInit(() {
      _AsLatitude = prefs.getDouble('ff_AsLatitude') ?? _AsLatitude;
    });
    _safeInit(() {
      _AsLongitude = prefs.getDouble('ff_AsLongitude') ?? _AsLongitude;
    });
    _safeInit(() {
      if (prefs.containsKey('ff_AsCommentReplies')) {
        try {
          _AsCommentReplies =
              jsonDecode(prefs.getString('ff_AsCommentReplies') ?? '');
        } catch (e) {
          print("Can't decode persisted json. Error: $e.");
        }
      }
    });
    _safeInit(() {
      if (prefs.containsKey('ff_SearchData')) {
        try {
          _SearchData = jsonDecode(prefs.getString('ff_SearchData') ?? '');
        } catch (e) {
          print("Can't decode persisted json. Error: $e.");
        }
      }
    });
    _safeInit(() {
      if (prefs.containsKey('ff_neighbourhoodUsers')) {
        try {
          _neighbourhoodUsers =
              jsonDecode(prefs.getString('ff_neighbourhoodUsers') ?? '');
        } catch (e) {
          print("Can't decode persisted json. Error: $e.");
        }
      }
    });
    _safeInit(() {
      if (prefs.containsKey('ff_notifications')) {
        try {
          _notifications =
              jsonDecode(prefs.getString('ff_notifications') ?? '');
        } catch (e) {
          print("Can't decode persisted json. Error: $e.");
        }
      }
    });
  }

  void update(VoidCallback callback) {
    callback();
    notifyListeners();
  }

  late SharedPreferences prefs;

  String _Otp = '';
  String get Otp => _Otp;
  set Otp(String value) {
    _Otp = value;
  }

  String _AsFirstName = '';
  String get AsFirstName => _AsFirstName;
  set AsFirstName(String value) {
    _AsFirstName = value;
  }

  String _AsLastName = '';
  String get AsLastName => _AsLastName;
  set AsLastName(String value) {
    _AsLastName = value;
  }

  String _AsAddress = '';
  String get AsAddress => _AsAddress;
  set AsAddress(String value) {
    _AsAddress = value;
  }

  String _AsFlat = '';
  String get AsFlat => _AsFlat;
  set AsFlat(String value) {
    _AsFlat = value;
  }

  String _AsCity = '';
  String get AsCity => _AsCity;
  set AsCity(String value) {
    _AsCity = value;
  }

  String _AsEmail = '';
  String get AsEmail => _AsEmail;
  set AsEmail(String value) {
    _AsEmail = value;
  }

  String _AsPassword = '';
  String get AsPassword => _AsPassword;
  set AsPassword(String value) {
    _AsPassword = value;
  }

  String _AsMobileNumer = '';
  String get AsMobileNumer => _AsMobileNumer;
  set AsMobileNumer(String value) {
    _AsMobileNumer = value;
  }

  String _AsCountryCode = '+44';
  String get AsCountryCode => _AsCountryCode;
  set AsCountryCode(String value) {
    _AsCountryCode = value;
  }

  String _AsProfilePicture =
      'https://wgcqstmmkcdjnnpuvspr.supabase.co/storage/v1/object/public/squadd/default_profile/file_0000000035b061f896bf60c815a83ceb.png';
  String get AsProfilePicture => _AsProfilePicture;
  set AsProfilePicture(String value) {
    _AsProfilePicture = value;
  }

  String _AsPostalCode = '';
  String get AsPostalCode => _AsPostalCode;
  set AsPostalCode(String value) {
    _AsPostalCode = value;
  }

  dynamic _matchedUsers;
  dynamic get matchedUsers => _matchedUsers;
  set matchedUsers(dynamic value) {
    _matchedUsers = value;
  }

  String _AsCountry = '';
  String get AsCountry => _AsCountry;
  set AsCountry(String value) {
    _AsCountry = value;
  }

  int _postControl = 1;
  int get postControl => _postControl;
  set postControl(int value) {
    _postControl = value;
  }

  int _commentControl = 1;
  int get commentControl => _commentControl;
  set commentControl(int value) {
    _commentControl = value;
  }

  int _communityId = 1;
  int get communityId => _communityId;
  set communityId(int value) {
    _communityId = value;
    prefs.setInt('ff_communityId', value);
  }

  dynamic _AsPublicProfile;
  dynamic get AsPublicProfile => _AsPublicProfile;
  set AsPublicProfile(dynamic value) {
    _AsPublicProfile = value;
  }

  List<String> _userIds = [];
  List<String> get userIds => _userIds;
  set userIds(List<String> value) {
    _userIds = value;
  }

  void addToUserIds(String value) {
    userIds.add(value);
  }

  void removeFromUserIds(String value) {
    userIds.remove(value);
  }

  void removeAtIndexFromUserIds(int index) {
    userIds.removeAt(index);
  }

  void updateUserIdsAtIndex(
    int index,
    String Function(String) updateFn,
  ) {
    userIds[index] = updateFn(_userIds[index]);
  }

  void insertAtIndexInUserIds(int index, String value) {
    userIds.insert(index, value);
  }

  String _AsName = '';
  String get AsName => _AsName;
  set AsName(String value) {
    _AsName = value;
  }

  bool _showReply = false;
  bool get showReply => _showReply;
  set showReply(bool value) {
    _showReply = value;
  }

  String _postCommentUserName = '';
  String get postCommentUserName => _postCommentUserName;
  set postCommentUserName(String value) {
    _postCommentUserName = value;
  }

  String _AsCoverImage =
      'https://wgcqstmmkcdjnnpuvspr.supabase.co/storage/v1/object/public/squadd/default_cover_image/Header_(1).webp';
  String get AsCoverImage => _AsCoverImage;
  set AsCoverImage(String value) {
    _AsCoverImage = value;
    prefs.setString('ff_AsCoverImage', value);
  }

  String _postCommentPostId = '';
  String get postCommentPostId => _postCommentPostId;
  set postCommentPostId(String value) {
    _postCommentPostId = value;
  }

  dynamic _followers = jsonDecode('[]');
  dynamic get followers => _followers;
  set followers(dynamic value) {
    _followers = value;
  }

  int _AsFollowersCount = 0;
  int get AsFollowersCount => _AsFollowersCount;
  set AsFollowersCount(int value) {
    _AsFollowersCount = value;
  }

  dynamic _AsFollowingList = jsonDecode('[]');
  dynamic get AsFollowingList => _AsFollowingList;
  set AsFollowingList(dynamic value) {
    _AsFollowingList = value;
  }

  int _AsFollowingCount = 0;
  int get AsFollowingCount => _AsFollowingCount;
  set AsFollowingCount(int value) {
    _AsFollowingCount = value;
  }

  String _AsGroupCover =
      'https://wgcqstmmkcdjnnpuvspr.supabase.co/storage/v1/object/public/squadd/default_cover_image/Header_(1).webp';
  String get AsGroupCover => _AsGroupCover;
  set AsGroupCover(String value) {
    _AsGroupCover = value;
    prefs.setString('ff_AsGroupCover', value);
  }

  String _AsBusinessCover =
      'https://wgcqstmmkcdjnnpuvspr.supabase.co/storage/v1/object/public/squadd/default_cover_image/Header_(1).webp';
  String get AsBusinessCover => _AsBusinessCover;
  set AsBusinessCover(String value) {
    _AsBusinessCover = value;
    prefs.setString('ff_AsBusinessCover', value);
  }

  String _AsBusinessProfile =
      'https://wgcqstmmkcdjnnpuvspr.supabase.co/storage/v1/object/public/squadd/default_business_profile/Frame%20629749.webp';
  String get AsBusinessProfile => _AsBusinessProfile;
  set AsBusinessProfile(String value) {
    _AsBusinessProfile = value;
    prefs.setString('ff_AsBusinessProfile', value);
  }

  dynamic _AsGroupList = jsonDecode('[]');
  dynamic get AsGroupList => _AsGroupList;
  set AsGroupList(dynamic value) {
    _AsGroupList = value;
  }

  dynamic _AsSpecificGroupDetails;
  dynamic get AsSpecificGroupDetails => _AsSpecificGroupDetails;
  set AsSpecificGroupDetails(dynamic value) {
    _AsSpecificGroupDetails = value;
  }

  String _SalesFilter = 'All categories';
  String get SalesFilter => _SalesFilter;
  set SalesFilter(String value) {
    _SalesFilter = value;
  }

  String _SalesSort = 'Newest';
  String get SalesSort => _SalesSort;
  set SalesSort(String value) {
    _SalesSort = value;
  }

  dynamic _AsAssignAdmin;
  dynamic get AsAssignAdmin => _AsAssignAdmin;
  set AsAssignAdmin(dynamic value) {
    _AsAssignAdmin = value;
  }

  dynamic _chatSubscriptions;
  dynamic get chatSubscriptions => _chatSubscriptions;
  set chatSubscriptions(dynamic value) {
    _chatSubscriptions = value;
  }

  String _AsGeoCode = '';
  String get AsGeoCode => _AsGeoCode;
  set AsGeoCode(String value) {
    _AsGeoCode = value;
  }

  dynamic _AsPost;
  dynamic get AsPost => _AsPost;
  set AsPost(dynamic value) {
    _AsPost = value;
  }

  int _SalesKmFilter = 10;
  int get SalesKmFilter => _SalesKmFilter;
  set SalesKmFilter(int value) {
    _SalesKmFilter = value;
  }

  List<dynamic> _SalesHomePageData = [];
  List<dynamic> get SalesHomePageData => _SalesHomePageData;
  set SalesHomePageData(List<dynamic> value) {
    _SalesHomePageData = value;
  }

  void addToSalesHomePageData(dynamic value) {
    SalesHomePageData.add(value);
  }

  void removeFromSalesHomePageData(dynamic value) {
    SalesHomePageData.remove(value);
  }

  void removeAtIndexFromSalesHomePageData(int index) {
    SalesHomePageData.removeAt(index);
  }

  void updateSalesHomePageDataAtIndex(
    int index,
    dynamic Function(dynamic) updateFn,
  ) {
    SalesHomePageData[index] = updateFn(_SalesHomePageData[index]);
  }

  void insertAtIndexInSalesHomePageData(int index, dynamic value) {
    SalesHomePageData.insert(index, value);
  }

  String _SalesTypeFilter = 'Fixed';
  String get SalesTypeFilter => _SalesTypeFilter;
  set SalesTypeFilter(String value) {
    _SalesTypeFilter = value;
  }

  DateTime? _ChoosedEventDate;
  DateTime? get ChoosedEventDate => _ChoosedEventDate;
  set ChoosedEventDate(DateTime? value) {
    _ChoosedEventDate = value;
    value != null
        ? prefs.setInt('ff_ChoosedEventDate', value.millisecondsSinceEpoch)
        : prefs.remove('ff_ChoosedEventDate');
  }

  DateTime? _ChoosedStartEventDate;
  DateTime? get ChoosedStartEventDate => _ChoosedStartEventDate;
  set ChoosedStartEventDate(DateTime? value) {
    _ChoosedStartEventDate = value;
    value != null
        ? prefs.setInt('ff_ChoosedStartEventDate', value.millisecondsSinceEpoch)
        : prefs.remove('ff_ChoosedStartEventDate');
  }

  DateTime? _ChoosedEndEventDate;
  DateTime? get ChoosedEndEventDate => _ChoosedEndEventDate;
  set ChoosedEndEventDate(DateTime? value) {
    _ChoosedEndEventDate = value;
    value != null
        ? prefs.setInt('ff_ChoosedEndEventDate', value.millisecondsSinceEpoch)
        : prefs.remove('ff_ChoosedEndEventDate');
  }

  String _EventChoosedTime = '';
  String get EventChoosedTime => _EventChoosedTime;
  set EventChoosedTime(String value) {
    _EventChoosedTime = value;
  }

  String _EventChoosedTimeEnd = '';
  String get EventChoosedTimeEnd => _EventChoosedTimeEnd;
  set EventChoosedTimeEnd(String value) {
    _EventChoosedTimeEnd = value;
  }

  double _AsLatitude = 0.0;
  double get AsLatitude => _AsLatitude;
  set AsLatitude(double value) {
    _AsLatitude = value;
    prefs.setDouble('ff_AsLatitude', value);
  }

  double _AsLongitude = 0.0;
  double get AsLongitude => _AsLongitude;
  set AsLongitude(double value) {
    _AsLongitude = value;
    prefs.setDouble('ff_AsLongitude', value);
  }

  List<dynamic> _userLocationsList = [];
  List<dynamic> get userLocationsList => _userLocationsList;
  set userLocationsList(List<dynamic> value) {
    _userLocationsList = value;
  }

  void addToUserLocationsList(dynamic value) {
    userLocationsList.add(value);
  }

  void removeFromUserLocationsList(dynamic value) {
    userLocationsList.remove(value);
  }

  void removeAtIndexFromUserLocationsList(int index) {
    userLocationsList.removeAt(index);
  }

  void updateUserLocationsListAtIndex(
    int index,
    dynamic Function(dynamic) updateFn,
  ) {
    userLocationsList[index] = updateFn(_userLocationsList[index]);
  }

  void insertAtIndexInUserLocationsList(int index, dynamic value) {
    userLocationsList.insert(index, value);
  }

  dynamic _AsComments;
  dynamic get AsComments => _AsComments;
  set AsComments(dynamic value) {
    _AsComments = value;
  }

  dynamic _AsCommentReplies;
  dynamic get AsCommentReplies => _AsCommentReplies;
  set AsCommentReplies(dynamic value) {
    _AsCommentReplies = value;
    prefs.setString('ff_AsCommentReplies', jsonEncode(value));
  }

  dynamic _SearchData;
  dynamic get SearchData => _SearchData;
  set SearchData(dynamic value) {
    _SearchData = value;
    prefs.setString('ff_SearchData', jsonEncode(value));
  }

  String _URL = 'https://app.closefuture.io/share_redirect_squadd?';
  String get URL => _URL;
  set URL(String value) {
    _URL = value;
  }

  String _mentionText = '';
  String get mentionText => _mentionText;
  set mentionText(String value) {
    _mentionText = value;
  }

  bool _showMentionList = false;
  bool get showMentionList => _showMentionList;
  set showMentionList(bool value) {
    _showMentionList = value;
  }

  dynamic _neighbourhoodUsers;
  dynamic get neighbourhoodUsers => _neighbourhoodUsers;
  set neighbourhoodUsers(dynamic value) {
    _neighbourhoodUsers = value;
    prefs.setString('ff_neighbourhoodUsers', jsonEncode(value));
  }

  dynamic _NeighbourHoodPost;
  dynamic get NeighbourHoodPost => _NeighbourHoodPost;
  set NeighbourHoodPost(dynamic value) {
    _NeighbourHoodPost = value;
  }

  String _deviceId = '';
  String get deviceId => _deviceId;
  set deviceId(String value) {
    _deviceId = value;
  }

  dynamic _tagList;
  dynamic get tagList => _tagList;
  set tagList(dynamic value) {
    _tagList = value;
  }

  dynamic _tagSuggestions;
  dynamic get tagSuggestions => _tagSuggestions;
  set tagSuggestions(dynamic value) {
    _tagSuggestions = value;
  }

  String _customText = '';
  String get customText => _customText;
  set customText(String value) {
    _customText = value;
  }

  String _CommentId = '';
  String get CommentId => _CommentId;
  set CommentId(String value) {
    _CommentId = value;
  }

  dynamic _notifications;
  dynamic get notifications => _notifications;
  set notifications(dynamic value) {
    _notifications = value;
    prefs.setString('ff_notifications', jsonEncode(value));
  }

  int _cursorPosition = 0;
  int get cursorPosition => _cursorPosition;
  set cursorPosition(int value) {
    _cursorPosition = value;
  }

  dynamic _richTextContent;
  dynamic get richTextContent => _richTextContent;
  set richTextContent(dynamic value) {
    _richTextContent = value;
  }

  String _fcmToken = '';
  String get fcmToken => _fcmToken;
  set fcmToken(String value) {
    _fcmToken = value;
  }

  bool _datapresent = false;
  bool get datapresent => _datapresent;
  set datapresent(bool value) {
    _datapresent = value;
  }

  List<String> _taggedUserId = [];
  List<String> get taggedUserId => _taggedUserId;
  set taggedUserId(List<String> value) {
    _taggedUserId = value;
  }

  void addToTaggedUserId(String value) {
    taggedUserId.add(value);
  }

  void removeFromTaggedUserId(String value) {
    taggedUserId.remove(value);
  }

  void removeAtIndexFromTaggedUserId(int index) {
    taggedUserId.removeAt(index);
  }

  void updateTaggedUserIdAtIndex(
    int index,
    String Function(String) updateFn,
  ) {
    taggedUserId[index] = updateFn(_taggedUserId[index]);
  }

  void insertAtIndexInTaggedUserId(int index, String value) {
    taggedUserId.insert(index, value);
  }

  String _contentText = '';
  String get contentText => _contentText;
  set contentText(String value) {
    _contentText = value;
  }

  String _navigatorKey = '';
  String get navigatorKey => _navigatorKey;
  set navigatorKey(String value) {
    _navigatorKey = value;
  }

  String _pendingNotificationPage = '';
  String get pendingNotificationPage => _pendingNotificationPage;
  set pendingNotificationPage(String value) {
    _pendingNotificationPage = value;
  }

  String _pendingNotificationId = '';
  String get pendingNotificationId => _pendingNotificationId;
  set pendingNotificationId(String value) {
    _pendingNotificationId = value;
  }

  bool _shouldNavigateFromNotification = false;
  bool get shouldNavigateFromNotification => _shouldNavigateFromNotification;
  set shouldNavigateFromNotification(bool value) {
    _shouldNavigateFromNotification = value;
  }

  String _pendingPostId = '';
  String get pendingPostId => _pendingPostId;
  set pendingPostId(String value) {
    _pendingPostId = value;
  }

  String _pendingPageName = '';
  String get pendingPageName => _pendingPageName;
  set pendingPageName(String value) {
    _pendingPageName = value;
  }

  bool _notify = false;
  bool get notify => _notify;
  set notify(bool value) {
    _notify = value;
  }

  String _AsPlayStoreLink =
      'https://play.google.com/store/apps/details?id=com.company.squaDD';
  String get AsPlayStoreLink => _AsPlayStoreLink;
  set AsPlayStoreLink(String value) {
    _AsPlayStoreLink = value;
  }

  String _AppStoreLink = 'https://apps.apple.com/app/squadd/id6752684914';
  String get AppStoreLink => _AppStoreLink;
  set AppStoreLink(String value) {
    _AppStoreLink = value;
  }
}

void _safeInit(Function() initializeField) {
  try {
    initializeField();
  } catch (_) {}
}

Future _safeInitAsync(Function() initializeField) async {
  try {
    await initializeField();
  } catch (_) {}
}
