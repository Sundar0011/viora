import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';

import '/flutter_flow/flutter_flow_util.dart';
import 'api_manager.dart';

export 'api_manager.dart' show ApiCallResponse;

const _kPrivateApiFunctionName = 'ffPrivateApiCall';

class SendOtpCall {
  static Future<ApiCallResponse> call({
    String? anonKey = '',
    String? mobileNoCc = '',
    String? email = '',
  }) async {
    final ffApiRequestBody = '''
{
  "mobile_no_cc": "${escapeStringForJson(mobileNoCc)}",
"email":"${escapeStringForJson(email)}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'SendOtp',
      apiUrl: 'https://wgcqstmmkcdjnnpuvspr.supabase.co/functions/v1/send-otp',
      callType: ApiCallType.POST,
      headers: {
        'Authorization': 'Bearer ${anonKey}',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  static String? error(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.error''',
      ));
}

class VerifiOtpCall {
  static Future<ApiCallResponse> call({
    String? anonKey = '',
    String? email = '',
    String? mobileNoCc = '',
    String? otp = '',
  }) async {
    final ffApiRequestBody = '''
{
  "otp": "${escapeStringForJson(otp)}",
  "email": "${escapeStringForJson(email)}",
  "mobile_no_cc": "${escapeStringForJson(mobileNoCc)}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'VerifiOtp',
      apiUrl:
          'https://wgcqstmmkcdjnnpuvspr.supabase.co/functions/v1/verify_otp',
      callType: ApiCallType.POST,
      headers: {
        'Authorization': 'Bearer ${anonKey}',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  static String? error(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.error''',
      ));
}

class VaildateUserCall {
  static Future<ApiCallResponse> call({
    String? anonKey = '',
    String? password = '',
    String? identifier = '',
  }) async {
    final ffApiRequestBody = '''
{
  "identifier": "${escapeStringForJson(identifier)}",
  "password": "${escapeStringForJson(password)}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'VaildateUser',
      apiUrl:
          'https://wgcqstmmkcdjnnpuvspr.supabase.co/functions/v1/authenticate-user',
      callType: ApiCallType.POST,
      headers: {
        'Authorization': 'Bearer ${anonKey}',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  static String? error(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.error''',
      ));
}

class CheckUserExistCall {
  static Future<ApiCallResponse> call({
    String? email = '',
    String? mobileNumber = '',
    String? anonKey = '',
  }) async {
    final ffApiRequestBody = '''
{
  "email": "${escapeStringForJson(email)}",
  "mobile_number": "${escapeStringForJson(mobileNumber)}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'CheckUserExist',
      apiUrl:
          'https://wgcqstmmkcdjnnpuvspr.supabase.co/functions/v1/check-user-exist',
      callType: ApiCallType.POST,
      headers: {
        'Authorization': 'Bearer ${anonKey}',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  static bool? mobileNumberExists(dynamic response) =>
      castToType<bool>(getJsonField(
        response,
        r'''$.mobile_number_exists''',
      ));
  static bool? emailExists(dynamic response) => castToType<bool>(getJsonField(
        response,
        r'''$.email_exists''',
      ));
}

class CheckUserCall {
  static Future<ApiCallResponse> call({
    String? email = '',
    String? mobile = '',
    String? anonKey = '',
  }) async {
    final ffApiRequestBody = '''
{
  "email": "${escapeStringForJson(email)}",
  "mobile_number": "${escapeStringForJson(mobile)}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'CheckUser',
      apiUrl:
          'https://wgcqstmmkcdjnnpuvspr.supabase.co/functions/v1/check-user',
      callType: ApiCallType.POST,
      headers: {
        'Authorization': 'Bearer ${anonKey}',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  static bool? exists(dynamic response) => castToType<bool>(getJsonField(
        response,
        r'''$.exists''',
      ));
}

class FindCommonChatCall {
  static Future<ApiCallResponse> call({
    String? anonKey = '',
    String? token = '',
    String? user1 = '',
    String? user2 = '',
  }) async {
    final ffApiRequestBody = '''
{
"user2":"${escapeStringForJson(user2)}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'FindCommonChat',
      apiUrl:
          'https://wgcqstmmkcdjnnpuvspr.supabase.co/rest/v1/rpc/find_common_chat',
      callType: ApiCallType.POST,
      headers: {
        'apikey': '${anonKey}',
        'Authorization': 'Bearer ${token}',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  static String? chatId(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$[:].chat_id''',
      ));
  static bool? chatFound(dynamic response) => castToType<bool>(getJsonField(
        response,
        r'''$[:].chat_found''',
      ));
}

class InsertImageUrlsCall {
  static Future<ApiCallResponse> call({
    String? apikey,
    String? token = '',
    String? pUserid = '',
    int? pCommunityid,
    String? pPostid = '',
    List<String>? imageUrlsList,
    String? pMediaType = '',
  }) async {
    apikey ??= FFDevEnvironmentValues().AnonKey;

    final imageUrls = _serializeList(imageUrlsList);

    final ffApiRequestBody = '''
{
  "p_userid": "${escapeStringForJson(pUserid)}",
  "p_communityid": ${pCommunityid},
  "p_postid": "${escapeStringForJson(pPostid)}",
  "image_urls": ${imageUrls},
  "media_type": "${escapeStringForJson(pMediaType)}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'InsertImageUrls',
      apiUrl:
          'https://wgcqstmmkcdjnnpuvspr.supabase.co/rest/v1/rpc/insert_post_image_rows',
      callType: ApiCallType.POST,
      headers: {
        'apikey': '${apikey}',
        'Authorization': 'Bearer ${token}',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class AddChatUsersCall {
  static Future<ApiCallResponse> call({
    String? user2 = '',
    String? communityId = '',
    String? chatId = '',
    String? anonKey = '',
    String? token = '',
  }) async {
    final ffApiRequestBody = '''
{
  "p_chat_id": "${escapeStringForJson(chatId)}",
  "p_community_id": "${escapeStringForJson(communityId)}",
  "p_user2": "${escapeStringForJson(user2)}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'AddChatUsers',
      apiUrl:
          'https://wgcqstmmkcdjnnpuvspr.supabase.co/rest/v1/rpc/add_chat_users',
      callType: ApiCallType.POST,
      headers: {
        'apikey': '${anonKey}',
        'Authorization': 'Bearer ${token}',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class GetPostUserDataCall {
  static Future<ApiCallResponse> call({
    String? pPostid = '',
    String? token = '',
    String? apikey,
    String? pUserid = '',
  }) async {
    apikey ??= FFDevEnvironmentValues().AnonKey;

    final ffApiRequestBody = '''
{
  "p_postid": "${escapeStringForJson(pPostid)}",
  "p_userid": "${escapeStringForJson(pUserid)}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'GetPostUserData',
      apiUrl:
          'https://wgcqstmmkcdjnnpuvspr.supabase.co/rest/v1/rpc/get_post_user_data',
      callType: ApiCallType.POST,
      headers: {
        'apikey': '${apikey}',
        'Authorization': 'Bearer ${token}',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  static String? username(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.name''',
      ));
  static String? city(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.city''',
      ));
  static String? profle(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.profile_image''',
      ));
  static int? imagesCount(dynamic response) => castToType<int>(getJsonField(
        response,
        r'''$.images_count''',
      ));
  static bool? following(dynamic response) => castToType<bool>(getJsonField(
        response,
        r'''$.following''',
      ));
  static List? likedUsers(dynamic response) => getJsonField(
        response,
        r'''$.liked_users''',
        true,
      ) as List?;
  static int? postAccess(dynamic response) => castToType<int>(getJsonField(
        response,
        r'''$.see_post_access_id''',
      ));
  static int? commentAccess(dynamic response) => castToType<int>(getJsonField(
        response,
        r'''$.comment_post_access_id''',
      ));
  static String? content(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.content''',
      ));
  static List<String>? images(dynamic response) => (getJsonField(
        response,
        r'''$.images''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
}

class AddLikeCall {
  static Future<ApiCallResponse> call({
    String? pCommunityid = '',
    String? pUserid = '',
    String? pPostid = '',
    String? token = '',
    String? apikey,
  }) async {
    apikey ??= FFDevEnvironmentValues().AnonKey;

    final ffApiRequestBody = '''
{
  "p_userid": "${escapeStringForJson(pUserid)}",
  "p_postid": "${escapeStringForJson(pPostid)}",
  "p_communityid": "${escapeStringForJson(pCommunityid)}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'AddLike',
      apiUrl: 'https://wgcqstmmkcdjnnpuvspr.supabase.co/rest/v1/rpc/add_like',
      callType: ApiCallType.POST,
      headers: {
        'apikey': '${apikey}',
        'Authorization': 'Bearer ${token}',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class SoftdeletechatusersCall {
  static Future<ApiCallResponse> call({
    List<String>? userIdsList,
    String? anonKey = '',
    String? token = '',
  }) async {
    final userIds = _serializeList(userIdsList);

    final ffApiRequestBody = '''
{
  "user_ids": ${userIds}
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'softdeletechatusers',
      apiUrl:
          'https://wgcqstmmkcdjnnpuvspr.supabase.co/rest/v1/rpc/soft_delete_chat_users',
      callType: ApiCallType.POST,
      headers: {
        'apikey': '${anonKey}',
        'Authorization': 'Bearer ${token}',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class GetPostCommentsCall {
  static Future<ApiCallResponse> call({
    String? pUserid = '',
    int? pCommentid,
    String? apikey,
    String? token = '',
  }) async {
    apikey ??= FFDevEnvironmentValues().AnonKey;

    final ffApiRequestBody = '''
{
  "p_commentid" : ${pCommentid},
  "p_userid" : "${escapeStringForJson(pUserid)}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'GetPostComments',
      apiUrl:
          'https://wgcqstmmkcdjnnpuvspr.supabase.co/rest/v1/rpc/get_post_comments',
      callType: ApiCallType.POST,
      headers: {
        'apikey': '${apikey}',
        'Authorization': 'Bearer ${token}',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class RestoreChatUserCall {
  static Future<ApiCallResponse> call({
    String? pChatId = '',
    String? pUserId = '',
    String? anonKey = '',
    String? token = '',
  }) async {
    final ffApiRequestBody = '''
{
  "p_chat_id": "${escapeStringForJson(pChatId)}",
  "p_user_id": "${escapeStringForJson(pUserId)}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'RestoreChatUser',
      apiUrl:
          'https://wgcqstmmkcdjnnpuvspr.supabase.co/rest/v1/rpc/restore_chat_user',
      callType: ApiCallType.POST,
      headers: {
        'apikey': '${anonKey}',
        'Authorization': 'Bearer ${token}',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class AddCommentLikeCall {
  static Future<ApiCallResponse> call({
    String? pPostid = '',
    String? pUserid = '',
    int? pCommunityid,
    String? pCommentid = '',
    String? token = '',
    String? apikey,
  }) async {
    apikey ??= FFDevEnvironmentValues().AnonKey;

    final ffApiRequestBody = '''
{
  "p_userid": "${escapeStringForJson(pUserid)}",
  "p_postid": "${escapeStringForJson(pPostid)}",
  "p_communityid": ${pCommunityid},
  "p_commentid": "${escapeStringForJson(pCommentid)}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'AddCommentLike',
      apiUrl:
          'https://wgcqstmmkcdjnnpuvspr.supabase.co/rest/v1/rpc/add_comment_like',
      callType: ApiCallType.POST,
      headers: {
        'apikey': '${apikey}',
        'Authorization': 'Bearer ${token}',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class GetLikedUsersCall {
  static Future<ApiCallResponse> call({
    String? pPostid = '',
    String? apikey,
    String? token = '',
  }) async {
    apikey ??= FFDevEnvironmentValues().AnonKey;

    final ffApiRequestBody = '''
{
  "p_postid": "${escapeStringForJson(pPostid)}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'GetLikedUsers',
      apiUrl:
          'https://wgcqstmmkcdjnnpuvspr.supabase.co/rest/v1/rpc/get_post_likes',
      callType: ApiCallType.POST,
      headers: {
        'apikey': '${apikey}',
        'Authorization': 'Bearer ${token}',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class GetlimitedPostLikesCall {
  static Future<ApiCallResponse> call({
    double? pScreenwidth,
    String? pPostid = '',
    String? apikey,
    String? token = '',
  }) async {
    apikey ??= FFDevEnvironmentValues().AnonKey;

    final ffApiRequestBody = '''
{
  "p_postid" : "${escapeStringForJson(pPostid)}",
  "p_screenwidth" : ${pScreenwidth}
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'GetlimitedPostLikes',
      apiUrl:
          'https://wgcqstmmkcdjnnpuvspr.supabase.co/rest/v1/rpc/get_limited_post_likes',
      callType: ApiCallType.POST,
      headers: {
        'apikey': '${apikey}',
        'Authorization': 'Bearer ${token}',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class AddFollowCall {
  static Future<ApiCallResponse> call({
    String? pFollowerid = '',
    String? pFollowingid = '',
    int? pCommunityid,
    String? token = '',
    String? apikey,
  }) async {
    apikey ??= FFDevEnvironmentValues().AnonKey;

    final ffApiRequestBody = '''
{
  "p_communityid": ${pCommunityid},
  "p_followerid": "${escapeStringForJson(pFollowerid)}",
  "p_followingid": "${escapeStringForJson(pFollowingid)}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'AddFollow',
      apiUrl:
          'https://wgcqstmmkcdjnnpuvspr.supabase.co/rest/v1/rpc/user_follow',
      callType: ApiCallType.POST,
      headers: {
        'apikey': '${apikey}',
        'Authorization': 'Bearer ${token}',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class PostCountIncrementCall {
  static Future<ApiCallResponse> call({
    String? pUserid = '',
    String? apikey,
    String? token = '',
  }) async {
    apikey ??= FFDevEnvironmentValues().AnonKey;

    final ffApiRequestBody = '''
{
  "p_userid": "${escapeStringForJson(pUserid)}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'PostCountIncrement',
      apiUrl:
          'https://wgcqstmmkcdjnnpuvspr.supabase.co/rest/v1/rpc/add_post_count',
      callType: ApiCallType.POST,
      headers: {
        'apikey': '${apikey}',
        'Authorization': 'Bearer ${token}',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class CountLikesCall {
  static Future<ApiCallResponse> call({
    String? pCommentid = '',
    String? pPostId = '',
    String? pType = '',
    String? token = '',
    String? apikey,
  }) async {
    apikey ??= FFDevEnvironmentValues().AnonKey;

    final ffApiRequestBody = '''
{
  "p_type": "${escapeStringForJson(pType)}",
  "p_post_id": "${escapeStringForJson(pPostId)}",
  "p_commentid": ${escapeStringForJson(pCommentid)}
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'CountLikes',
      apiUrl:
          'https://wgcqstmmkcdjnnpuvspr.supabase.co/rest/v1/rpc/count_likes',
      callType: ApiCallType.POST,
      headers: {
        'apikey': '${apikey}',
        'Authorization': 'Bearer ${token}',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class UpdatePostCall {
  static Future<ApiCallResponse> call({
    String? pUserId = '',
    String? pPostid = '',
    int? pSeePostAccessId,
    int? pCommentPostAccessId,
    String? pContent = '',
    List<String>? pImageUrlsList,
    String? token = '',
    String? apikey,
  }) async {
    apikey ??= FFDevEnvironmentValues().AnonKey;

    final pImageUrls = _serializeList(pImageUrlsList);

    final ffApiRequestBody = '''
{
  "user_id": "${escapeStringForJson(pUserId)}",
  "post_id": "${escapeStringForJson(pPostid)}",
  "see_post_access_id": ${pSeePostAccessId},
  "comment_post_access_id": ${pCommentPostAccessId},
  "content": "${escapeStringForJson(pContent)}",
  "image_urls": ${pImageUrls}
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'UpdatePost',
      apiUrl:
          'https://wgcqstmmkcdjnnpuvspr.functions.supabase.co/update-user-post',
      callType: ApiCallType.POST,
      headers: {
        'apikey': '${apikey}',
        'Authorization': 'Bearer ${token}',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class ResetPasswordCall {
  static Future<ApiCallResponse> call({
    String? anonKey,
    String? phone = '',
    String? email = '',
    String? otp = '',
    String? newpassword = '',
  }) async {
    anonKey ??= FFDevEnvironmentValues().AnonKey;

    final ffApiRequestBody = '''
{
  "phone": "${escapeStringForJson(phone)}",
  "email": "${escapeStringForJson(email)}",
  "otp": "${escapeStringForJson(otp)}",
  "new_password": "${escapeStringForJson(newpassword)}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'ResetPassword',
      apiUrl:
          'https://wgcqstmmkcdjnnpuvspr.supabase.co/functions/v1/reset-password',
      callType: ApiCallType.POST,
      headers: {
        'Authorization': 'Bearer ${anonKey}',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class ChangePasswordCall {
  static Future<ApiCallResponse> call({
    String? oldPassword = '',
    String? newPassword = '',
    String? token = '',
  }) async {
    final ffApiRequestBody = '''
{
  "old_password": "${escapeStringForJson(oldPassword)}",
  "new_password": "${escapeStringForJson(newPassword)}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'ChangePassword',
      apiUrl:
          'https://wgcqstmmkcdjnnpuvspr.supabase.co/functions/v1/change-password',
      callType: ApiCallType.POST,
      headers: {
        'Authorization': 'Bearer ${token}',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class GetMyBusinessCall {
  static Future<ApiCallResponse> call({
    String? pUserid = '',
    String? apikey,
    String? token = '',
    int? pCommunityid,
  }) async {
    apikey ??= FFDevEnvironmentValues().AnonKey;

    final ffApiRequestBody = '''
{
  "p_userid": "${escapeStringForJson(pUserid)}",
  "p_communityid": ${pCommunityid}
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'GetMyBusiness',
      apiUrl:
          'https://wgcqstmmkcdjnnpuvspr.supabase.co/rest/v1/rpc/get_my_business',
      callType: ApiCallType.POST,
      headers: {
        'apikey': '${apikey}',
        'Authorization': 'Bearer ${token}',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class BusinessHomepageCall {
  static Future<ApiCallResponse> call({
    String? pBusinessid = '',
    String? apikey,
    String? token = '',
    String? pUserid = '',
  }) async {
    apikey ??= FFDevEnvironmentValues().AnonKey;

    final ffApiRequestBody = '''
{
  "p_businessid": "${escapeStringForJson(pBusinessid)}",
  "p_userid": "${escapeStringForJson(pUserid)}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'BusinessHomepage',
      apiUrl:
          'https://wgcqstmmkcdjnnpuvspr.supabase.co/rest/v1/rpc/get_business_details',
      callType: ApiCallType.POST,
      headers: {
        'apikey': '${apikey}',
        'Authorization': 'Bearer ${token}',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class UpdateTotalGroupMembersCall {
  static Future<ApiCallResponse> call({
    String? token = '',
    String? anonKey = '',
    String? groupId = '',
  }) async {
    final ffApiRequestBody = '''
{
  "p_group_id": "${escapeStringForJson(groupId)}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'UpdateTotalGroupMembers',
      apiUrl:
          'https://wgcqstmmkcdjnnpuvspr.supabase.co/rest/v1/rpc/update_total_group_members',
      callType: ApiCallType.POST,
      headers: {
        'Authorization': 'Bearer${token}',
        'apikey': '${anonKey}',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class GetPromotionplanCall {
  static Future<ApiCallResponse> call({
    String? pBusinessid = '',
    String? apikey,
    String? token = '',
  }) async {
    apikey ??= FFDevEnvironmentValues().AnonKey;

    final ffApiRequestBody = '''
{
  "p_businessid": "${escapeStringForJson(pBusinessid)}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'GetPromotionplan',
      apiUrl:
          'https://wgcqstmmkcdjnnpuvspr.supabase.co/rest/v1/rpc/get_promotion_plan',
      callType: ApiCallType.POST,
      headers: {
        'apikey': '${apikey}',
        'Authorization': 'Bearer ${token}',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class GetBusinessCall {
  static Future<ApiCallResponse> call({
    String? pUserid = '',
    String? apikey,
    String? token = '',
    int? pCommunityid,
  }) async {
    apikey ??= FFDevEnvironmentValues().AnonKey;

    final ffApiRequestBody = '''
{
  "p_userid": "${escapeStringForJson(pUserid)}",
  "p_communityid": ${pCommunityid}
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'GetBusiness',
      apiUrl:
          'https://wgcqstmmkcdjnnpuvspr.supabase.co/rest/v1/rpc/get_all_business',
      callType: ApiCallType.POST,
      headers: {
        'apikey': '${apikey}',
        'Authorization': 'Bearer ${token}',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class InviteFriendsCall {
  static Future<ApiCallResponse> call({
    String? pCommunityId = '',
    String? pGroupId = '',
    String? pSearchText = '',
    String? anonKey = '',
    String? token = '',
  }) async {
    final ffApiRequestBody = '''
{
  "p_search_text": "${escapeStringForJson(pSearchText)}",
  "p_group_id": "${escapeStringForJson(pGroupId)}",
  "p_community_id": "${escapeStringForJson(pCommunityId)}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'InviteFriends',
      apiUrl:
          'https://wgcqstmmkcdjnnpuvspr.supabase.co/rest/v1/rpc/get_available_users_to_invite',
      callType: ApiCallType.POST,
      headers: {
        'apikey': '${anonKey}',
        'Authorization': 'Bearer ${token}',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class UpdateContactedCall {
  static Future<ApiCallResponse> call({
    String? pUserid = '',
    String? pBusinessid = '',
    String? pContactedby = '',
    String? apikey,
    String? token = '',
    int? pCommunityid,
  }) async {
    apikey ??= FFDevEnvironmentValues().AnonKey;

    final ffApiRequestBody = '''
{
  "p_userid": "${escapeStringForJson(pUserid)}",
  "p_businessid": "${escapeStringForJson(pBusinessid)}",
  "p_contactedby": "${escapeStringForJson(pContactedby)}",
  "p_communityid" : ${pCommunityid}
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'UpdateContacted',
      apiUrl:
          'https://wgcqstmmkcdjnnpuvspr.supabase.co/rest/v1/rpc/update_contacted',
      callType: ApiCallType.POST,
      headers: {
        'Authorization': 'Bearer ${token}',
        'apikey': '${apikey}',
        'Content-Type': 'application/json',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class GetContactedCountCall {
  static Future<ApiCallResponse> call({
    String? pBusinessid = '',
    String? apikey,
    String? token = '',
  }) async {
    apikey ??= FFDevEnvironmentValues().AnonKey;

    final ffApiRequestBody = '''
{
  "p_businessid": "${escapeStringForJson(pBusinessid)}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'GetContactedCount',
      apiUrl:
          'https://wgcqstmmkcdjnnpuvspr.supabase.co/rest/v1/rpc/get_contact_count',
      callType: ApiCallType.POST,
      headers: {
        'apikey': '${apikey}',
        'Authorization': 'Bearer ${token}',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class DeleteAdminCall {
  static Future<ApiCallResponse> call({
    String? anonKey = '',
    String? token = '',
    String? groupId = '',
    String? userId = '',
  }) async {
    final ffApiRequestBody = '''
{
  "p_group_id": "${escapeStringForJson(groupId)}",
  "p_user_id": "${escapeStringForJson(userId)}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'delete admin',
      apiUrl:
          'https://wgcqstmmkcdjnnpuvspr.supabase.co/rest/v1/rpc/delete_group_admin',
      callType: ApiCallType.POST,
      headers: {
        'apikey': '${anonKey}',
        'Authorization': 'Bearer ${token}',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class GroupMembersCall {
  static Future<ApiCallResponse> call({
    String? token = '',
    String? anonKey = '',
    String? goupId = '',
    String? searchtext = '',
  }) async {
    final ffApiRequestBody = '''
{
"p_group_id":"${escapeStringForJson(goupId)}",
"p_search_text": "${escapeStringForJson(searchtext)}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'GroupMembers',
      apiUrl:
          'https://wgcqstmmkcdjnnpuvspr.supabase.co/rest/v1/rpc/get_group_members_with_admin_status',
      callType: ApiCallType.POST,
      headers: {
        'apikey': '${anonKey}',
        'Authorization': 'Bearer ${token}',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class GetSpecifiBusinessCall {
  static Future<ApiCallResponse> call({
    String? pUserid = '',
    int? pCommunityid,
    String? pBusinessid = '',
    String? apikey,
    String? token = '',
  }) async {
    apikey ??= FFDevEnvironmentValues().AnonKey;

    final ffApiRequestBody = '''
{
  "p_userid": "${escapeStringForJson(pUserid)}",
  "p_communityid": ${pCommunityid},
  "p_businessid": "${escapeStringForJson(pBusinessid)}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'GetSpecifiBusiness',
      apiUrl:
          'https://wgcqstmmkcdjnnpuvspr.supabase.co/rest/v1/rpc/get_specific_business',
      callType: ApiCallType.POST,
      headers: {
        'apikey': '${apikey}',
        'Authorization': 'Bearer ${token}',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class GetOtherUserFollowingGroupsrCall {
  static Future<ApiCallResponse> call({
    String? anonKey = '',
    String? token = '',
    String? userId = '',
  }) async {
    final ffApiRequestBody = '''
{
  "target_user_id": "${escapeStringForJson(userId)}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'GetOtherUserFollowingGroupsr',
      apiUrl:
          'https://wgcqstmmkcdjnnpuvspr.supabase.co/rest/v1/rpc/get_user_following_groups_with_status',
      callType: ApiCallType.POST,
      headers: {
        'apikey': '${anonKey}',
        'Authorization': 'Bearer ${token}',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class AddUserLocationCall {
  static Future<ApiCallResponse> call({
    String? anonKey = '',
    String? token = '',
    String? id = '',
    String? location = '',
  }) async {
    final ffApiRequestBody = '''
{
  "id": "${escapeStringForJson(id)}",
  "location": "${escapeStringForJson(location)}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'AddUserLocation',
      apiUrl: 'https://wgcqstmmkcdjnnpuvspr.supabase.co/rest/v1/user_locations',
      callType: ApiCallType.POST,
      headers: {
        'apikey': '${anonKey}',
        'Authorization': 'Bearer ${token}',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class UpdateUserGroupCountCall {
  static Future<ApiCallResponse> call({
    String? anonKey = '',
    String? token = '',
  }) async {
    return ApiManager.instance.makeApiCall(
      callName: 'UpdateUserGroupCount',
      apiUrl:
          'https://wgcqstmmkcdjnnpuvspr.supabase.co/rest/v1/rpc/update_user_group_count',
      callType: ApiCallType.POST,
      headers: {
        'apikey': '${anonKey}',
        'Authorization': 'Bearer ${token}',
      },
      params: {},
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class GetPostCall {
  static Future<ApiCallResponse> call({
    String? anonKey = '',
    String? token = '',
  }) async {
    return ApiManager.instance.makeApiCall(
      callName: 'GetPost',
      apiUrl:
          'https://wgcqstmmkcdjnnpuvspr.supabase.co/rest/v1/rpc/get_visible_posts',
      callType: ApiCallType.POST,
      headers: {
        'apikey': '${anonKey}',
        'Authorization': 'Bearer ${token}',
      },
      params: {},
      bodyType: BodyType.NONE,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class ShowSuggestionsCall {
  static Future<ApiCallResponse> call({
    String? input = '',
    String? key,
  }) async {
    key ??= FFDevEnvironmentValues().Google;

    return ApiManager.instance.makeApiCall(
      callName: 'ShowSuggestions',
      apiUrl: 'https://maps.googleapis.com/maps/api/place/autocomplete/json',
      callType: ApiCallType.GET,
      headers: {},
      params: {
        'input': input,
        'key': key,
      },
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  static List<String>? places(dynamic response) => (getJsonField(
        response,
        r'''$.predictions[:].description''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
  static List<String>? placeId(dynamic response) => (getJsonField(
        response,
        r'''$.predictions[:].place_id''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
}

class GetPlaceDetailsCall {
  static Future<ApiCallResponse> call({
    String? key,
    String? placeId = '',
  }) async {
    key ??= FFDevEnvironmentValues().Google;

    return ApiManager.instance.makeApiCall(
      callName: 'GetPlaceDetails',
      apiUrl: 'https://maps.googleapis.com/maps/api/place/details/json',
      callType: ApiCallType.GET,
      headers: {},
      params: {
        'place_id': placeId,
        'key': key,
        'fields': "address_components,geometry",
      },
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  static double? latitude(dynamic response) => castToType<double>(getJsonField(
        response,
        r'''$.result.geometry.location.lat''',
      ));
  static double? longitude(dynamic response) => castToType<double>(getJsonField(
        response,
        r'''$.result.geometry.location.lng''',
      ));
  static String? city(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.result.address_components[?(@.types[0]=="locality")].long_name''',
      ));
  static String? country(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.result.address_components[3].long_name''',
      ));
}

class InsertUserLocationCall {
  static Future<ApiCallResponse> call({
    String? lat = '',
    String? lng = '',
    String? placeName = '',
    String? apikey,
    String? token = '',
    String? pType = '',
  }) async {
    apikey ??= FFDevEnvironmentValues().AnonKey;

    final ffApiRequestBody = '''
{
  "lat": "${escapeStringForJson(lat)}",
  "lon": "${escapeStringForJson(lng)}",
  "place_name": "${escapeStringForJson(placeName)}",
  "p_type" : "${escapeStringForJson(pType)}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'InsertUserLocation',
      apiUrl:
          'https://wgcqstmmkcdjnnpuvspr.supabase.co/rest/v1/rpc/update_user_location',
      callType: ApiCallType.POST,
      headers: {
        'apikey': '${apikey}',
        'Authorization': 'Bearer ${token}',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class InsertSaleDetailsCall {
  static Future<ApiCallResponse> call({
    int? communityId,
    String? title = '',
    String? description = '',
    String? saleCategory = '',
    String? ePriceType = '',
    int? price,
    String? location = '',
    String? eSaleType = '',
    String? pUserid = '',
    double? lat,
    double? lng,
    String? apikey,
    String? token = '',
    String? city = '',
  }) async {
    apikey ??= FFDevEnvironmentValues().AnonKey;

    final ffApiRequestBody = '''
{
  "community_id": ${communityId},
  "title": "${escapeStringForJson(title)}",
  "description": "${escapeStringForJson(description)}",
  "sale_category": "${escapeStringForJson(saleCategory)}",
  "e_price_type": "${escapeStringForJson(ePriceType)}",
  "price": ${price},
  "location": "${escapeStringForJson(location)}",
  "e_sale_type": "${escapeStringForJson(eSaleType)}",
  "p_userid": "${escapeStringForJson(pUserid)}",
  "lon": ${lng},
  "lat": ${lat},
  "city": "${escapeStringForJson(city)}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'InsertSaleDetails',
      apiUrl:
          'https://wgcqstmmkcdjnnpuvspr.supabase.co/rest/v1/rpc/insert_sales_details',
      callType: ApiCallType.POST,
      headers: {
        'apikey': '${apikey}',
        'Authorization': 'Bearer ${token}',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class UpdateSaleWithoutImageCall {
  static Future<ApiCallResponse> call({
    String? title = '',
    String? description = '',
    String? saleCategory = '',
    String? ePriceType = '',
    int? price,
    String? location = '',
    String? saleId = '',
    double? lat,
    double? lng,
    String? apikey,
    String? token = '',
    String? city = '',
  }) async {
    apikey ??= FFDevEnvironmentValues().AnonKey;

    final ffApiRequestBody = '''
{
  "city": "${escapeStringForJson(city)}",
  "description": "${escapeStringForJson(description)}",
  "e_price_type": "${escapeStringForJson(ePriceType)}",
  "lat": ${lat},
  "location": "${escapeStringForJson(location)}",
  "lon":${lng},
  "price": ${price},
  "sale_category":"${escapeStringForJson(saleCategory)}",
  "sale_id": "${escapeStringForJson(saleId)}",
  "title": "${escapeStringForJson(title)}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'UpdateSaleWithoutImage',
      apiUrl:
          'https://wgcqstmmkcdjnnpuvspr.supabase.co/rest/v1/rpc/update_sale_without_image',
      callType: ApiCallType.POST,
      headers: {
        'apikey': '${apikey}',
        'Authorization': 'Bearer ${token}',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class GetSalesDataCall {
  static Future<ApiCallResponse> call({
    String? pUserid = '',
    String? pFilter = '',
    String? apikey,
    String? token = '',
  }) async {
    apikey ??= FFDevEnvironmentValues().AnonKey;

    final ffApiRequestBody = '''
{
  "p_userid": "${escapeStringForJson(pUserid)}",
  "p_filter" : "${escapeStringForJson(pFilter)}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'GetSalesData',
      apiUrl:
          'https://wgcqstmmkcdjnnpuvspr.supabase.co/rest/v1/rpc/get_yours_sales_details',
      callType: ApiCallType.POST,
      headers: {
        'apikey': '${apikey}',
        'Authorization': 'Bearer ${token}',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class GetSalesDetailsCall {
  static Future<ApiCallResponse> call({
    String? pSalesid = '',
    String? pUserid = '',
    String? apikey,
    String? token = '',
  }) async {
    apikey ??= FFDevEnvironmentValues().AnonKey;

    final ffApiRequestBody = '''
{
  "p_salesid": "${escapeStringForJson(pSalesid)}",
  "p_userid": "${escapeStringForJson(pUserid)}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'GetSalesDetails',
      apiUrl:
          'https://wgcqstmmkcdjnnpuvspr.supabase.co/rest/v1/rpc/get_sales_details',
      callType: ApiCallType.POST,
      headers: {
        'apikey': '${apikey}',
        'Authorization': 'Bearer ${token}',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class UpdateEventLocationCall {
  static Future<ApiCallResponse> call({
    String? id = '',
    String? latitude = '',
    String? longitude = '',
    String? anonKey,
    String? token = '',
  }) async {
    anonKey ??= FFDevEnvironmentValues().AnonKey;

    final ffApiRequestBody = '''
{
  "p_event_id": "${escapeStringForJson(id)}",
  "p_lat": "${escapeStringForJson(latitude)}",
  "p_lon": "${escapeStringForJson(longitude)}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'UpdateEventLocation',
      apiUrl:
          'https://wgcqstmmkcdjnnpuvspr.supabase.co/rest/v1/rpc/update_event_location',
      callType: ApiCallType.POST,
      headers: {
        'apikey': '${anonKey}',
        'Authorization': 'Bearer ${token}',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class GetNeighborhoodPeoplesCall {
  static Future<ApiCallResponse> call({
    String? pUserid = '',
    String? apikey,
    String? token = '',
    int? pCommunityid,
  }) async {
    apikey ??= FFDevEnvironmentValues().AnonKey;

    final ffApiRequestBody = '''
{
  "p_userid": "${escapeStringForJson(pUserid)}",
  "p_communityid": ${pCommunityid}
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'GetNeighborhoodPeoples',
      apiUrl:
          'https://wgcqstmmkcdjnnpuvspr.supabase.co/rest/v1/rpc/get_followers_nearby',
      callType: ApiCallType.POST,
      headers: {
        'apikey': '${apikey}',
        'Authorization': 'Bearer ${token}',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class GetneighbourhoodPostsCall {
  static Future<ApiCallResponse> call({
    int? pCommunityid,
    String? pUserid = '',
    String? token = '',
    String? apikey,
  }) async {
    apikey ??= FFDevEnvironmentValues().AnonKey;

    final ffApiRequestBody = '''
{
  "p_userid" : "${escapeStringForJson(pUserid)}",
  "p_communityid" : ${pCommunityid}
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'GetneighbourhoodPosts',
      apiUrl:
          'https://wgcqstmmkcdjnnpuvspr.supabase.co/rest/v1/rpc/get_neighbourhood_post_data',
      callType: ApiCallType.POST,
      headers: {
        'apikey': '${apikey}',
        'Authorization': 'Bearer ${token}',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class UpdateEventAttendeeCountCall {
  static Future<ApiCallResponse> call({
    String? apiKey,
    String? token = '',
    String? eventId = '',
  }) async {
    apiKey ??= FFDevEnvironmentValues().AnonKey;

    final ffApiRequestBody = '''
{
  "p_event_id": "${escapeStringForJson(eventId)}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'UpdateEventAttendeeCount',
      apiUrl:
          'https://wgcqstmmkcdjnnpuvspr.supabase.co/rest/v1/rpc/update_event_attendee_count',
      callType: ApiCallType.POST,
      headers: {
        'apikey': '${apiKey}',
        'Authorization': '${token}',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class GetPostAllCommentsCall {
  static Future<ApiCallResponse> call({
    String? pPostId = '',
    String? apikey,
    String? token = '',
  }) async {
    apikey ??= FFDevEnvironmentValues().AnonKey;

    final ffApiRequestBody = '''
{
  "p_post_id": "${escapeStringForJson(pPostId)}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'GetPostAllComments',
      apiUrl:
          'https://wgcqstmmkcdjnnpuvspr.supabase.co/rest/v1/rpc/get_post_comments_with_user',
      callType: ApiCallType.POST,
      headers: {
        'apikey': '${apikey}',
        'Authorization': 'Bearer ${token}',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class GetSaleHomePageSalesCall {
  static Future<ApiCallResponse> call({
    String? pUserid = '',
    int? pCommunityid,
    String? pSaleid = '',
    String? token = '',
    String? apikey,
  }) async {
    apikey ??= FFDevEnvironmentValues().AnonKey;

    final ffApiRequestBody = '''
{
  "p_userid": "${escapeStringForJson(pUserid)}",
  "p_communityid": ${pCommunityid},
  "p_saleid": "${escapeStringForJson(pSaleid)}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'GetSaleHomePageSales',
      apiUrl:
          'https://wgcqstmmkcdjnnpuvspr.supabase.co/rest/v1/rpc/get_sales_homepage',
      callType: ApiCallType.POST,
      headers: {
        'apikey': '${apikey}',
        'Authorization': 'Bearer ${token}',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class GetAllSearchCall {
  static Future<ApiCallResponse> call({
    String? pSearchText = '',
    String? pUserid = '',
    int? pCommunityid,
    String? apikey,
    String? token = '',
    String? pType = '',
    String? pCategory = '',
    String? pSaleType = '',
    String? pSort = '',
    int? pDistance,
  }) async {
    apikey ??= FFDevEnvironmentValues().AnonKey;

    final ffApiRequestBody = '''
{
  "p_search_text": "${escapeStringForJson(pSearchText)}",
  "p_userid": "${escapeStringForJson(pUserid)}",
  "p_communityid": ${pCommunityid},
  "p_type": "${escapeStringForJson(pType)}",
  "p_category": "${escapeStringForJson(pCategory)}",
  "p_sale_type": "${escapeStringForJson(pSaleType)}",
  "p_sort": "${escapeStringForJson(pSort)}",
  "p_distance": ${pDistance}
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'GetAllSearch',
      apiUrl:
          'https://wgcqstmmkcdjnnpuvspr.supabase.co/rest/v1/rpc/get_search_all_data',
      callType: ApiCallType.POST,
      headers: {
        'apikey': '${apikey}',
        'Authorization': 'Bearer ${token}',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  static List? post(dynamic response) => getJsonField(
        response,
        r'''$.posts''',
        true,
      ) as List?;
  static List? sales(dynamic response) => getJsonField(
        response,
        r'''$.sales''',
        true,
      ) as List?;
  static List? events(dynamic response) => getJsonField(
        response,
        r'''$.events''',
        true,
      ) as List?;
  static List? groups(dynamic response) => getJsonField(
        response,
        r'''$.groups''',
        true,
      ) as List?;
  static List? nearby(dynamic response) => getJsonField(
        response,
        r'''$.nearby_users''',
        true,
      ) as List?;
  static List? business(dynamic response) => getJsonField(
        response,
        r'''$.business_pages''',
        true,
      ) as List?;
}

class GetSpecifFilterSearchCall {
  static Future<ApiCallResponse> call({
    String? pUserid = '',
    int? pCommunityid,
    String? apikey,
    String? token = '',
    String? pType = '',
    List<String>? pIdsList,
  }) async {
    apikey ??= FFDevEnvironmentValues().AnonKey;

    final pIds = _serializeList(pIdsList);

    final ffApiRequestBody = '''
{
  "p_userid": "${escapeStringForJson(pUserid)}",
  "p_community": ${pCommunityid},
  "p_type": "${escapeStringForJson(pType)}",
  "p_ids": ${pIds}
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'GetSpecifFilterSearch',
      apiUrl:
          'https://wgcqstmmkcdjnnpuvspr.supabase.co/rest/v1/rpc/get_search_data',
      callType: ApiCallType.POST,
      headers: {
        'apikey': '${apikey}',
        'Authorization': 'Bearer ${token}',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  static List? post(dynamic response) => getJsonField(
        response,
        r'''$.posts''',
        true,
      ) as List?;
  static List? sales(dynamic response) => getJsonField(
        response,
        r'''$.sales''',
        true,
      ) as List?;
  static List? events(dynamic response) => getJsonField(
        response,
        r'''$.events''',
        true,
      ) as List?;
  static List? groups(dynamic response) => getJsonField(
        response,
        r'''$.groups''',
        true,
      ) as List?;
  static List? nearby(dynamic response) => getJsonField(
        response,
        r'''$.nearby_users''',
        true,
      ) as List?;
  static List? business(dynamic response) => getJsonField(
        response,
        r'''$.business_pages''',
        true,
      ) as List?;
  static List? eventData(dynamic response) => getJsonField(
        response,
        r'''$''',
        true,
      ) as List?;
}

class SpecificGroupCall {
  static Future<ApiCallResponse> call({
    String? apiKey = '',
    String? token = '',
    String? pGroupId = '',
  }) async {
    final ffApiRequestBody = '''
{
  "p_group_id": "${escapeStringForJson(pGroupId)}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'SpecificGroup',
      apiUrl:
          'https://wgcqstmmkcdjnnpuvspr.supabase.co/rest/v1/rpc/get_specific_group_with_user_status',
      callType: ApiCallType.POST,
      headers: {
        'apikey': '${apiKey}',
        'Authorization': 'Bearer ${token}',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  static String? groupid(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$[:].group_id''',
      ));
  static String? description(dynamic response) =>
      castToType<String>(getJsonField(
        response,
        r'''$[:].description''',
      ));
  static String? name(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$[:].name''',
      ));
  static String? profilepicture(dynamic response) =>
      castToType<String>(getJsonField(
        response,
        r'''$[:].profile_picture''',
      ));
  static String? egrouptype(dynamic response) =>
      castToType<String>(getJsonField(
        response,
        r'''$[:].e_group_type''',
      ));
  static String? ediscoverability(dynamic response) =>
      castToType<String>(getJsonField(
        response,
        r'''$[:].e_discoverability''',
      ));
  static String? createdat(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$[:].created_at''',
      ));
  static int? totalmembers(dynamic response) => castToType<int>(getJsonField(
        response,
        r'''$[:].total_members''',
      ));
  static String? userstatus(dynamic response) =>
      castToType<String>(getJsonField(
        response,
        r'''$[:].user_status''',
      ));
  static bool? nearest(dynamic response) => castToType<bool>(getJsonField(
        response,
        r'''$[:].nearest''',
      ));
}

class UpdateSaleCountCall {
  static Future<ApiCallResponse> call({
    String? apiKey,
    String? token = '',
    String? pUserid = '',
  }) async {
    apiKey ??= FFDevEnvironmentValues().AnonKey;

    final ffApiRequestBody = '''
{
  "p_userid": "${escapeStringForJson(pUserid)}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'UpdateSaleCount',
      apiUrl:
          'https://wgcqstmmkcdjnnpuvspr.supabase.co/rest/v1/rpc/update_sale_count',
      callType: ApiCallType.POST,
      headers: {
        'apikey': '${apiKey}',
        'Authorization': 'Bearer ${token}',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class GetSalesImagesCall {
  static Future<ApiCallResponse> call({
    String? apiKey,
    String? token = '',
    String? pSaleid = '',
  }) async {
    apiKey ??= FFDevEnvironmentValues().AnonKey;

    final ffApiRequestBody = '''
{
  "p_saleid": "${escapeStringForJson(pSaleid)}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'GetSalesImages',
      apiUrl:
          'https://wgcqstmmkcdjnnpuvspr.supabase.co/rest/v1/rpc/get_sale_images',
      callType: ApiCallType.POST,
      headers: {
        'apikey': '${apiKey}',
        'Authorization': 'Bearer ${token}',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class InternalShareCall {
  static Future<ApiCallResponse> call({
    String? apiKey,
    String? token = '',
    String? pUserid = '',
  }) async {
    apiKey ??= FFDevEnvironmentValues().AnonKey;

    final ffApiRequestBody = '''
{
  "p_userid": "${escapeStringForJson(pUserid)}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'InternalShare',
      apiUrl:
          'https://wgcqstmmkcdjnnpuvspr.supabase.co/rest/v1/rpc/get_internal_share',
      callType: ApiCallType.POST,
      headers: {
        'apikey': '${apiKey}',
        'Authorization': 'Bearer ${token}',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class CheckGroupMemberShareCall {
  static Future<ApiCallResponse> call({
    String? apiKey,
    String? token = '',
    String? pUserid = '',
    String? pPostid = '',
  }) async {
    apiKey ??= FFDevEnvironmentValues().AnonKey;

    final ffApiRequestBody = '''
{
  "p_userid": "${escapeStringForJson(pUserid)}",
  "p_postid": "${escapeStringForJson(pPostid)}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'CheckGroupMemberShare',
      apiUrl:
          'https://wgcqstmmkcdjnnpuvspr.supabase.co/rest/v1/rpc/check_group_member',
      callType: ApiCallType.POST,
      headers: {
        'apikey': '${apiKey}',
        'Authorization': 'Bearer ${token}',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  static bool? showPost(dynamic response) => castToType<bool>(getJsonField(
        response,
        r'''$.showpost''',
      ));
  static String? groupid(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.group_id''',
      ));
}

class UpdateUserProfileCountsCall {
  static Future<ApiCallResponse> call({
    String? apiKey = '',
    String? token = '',
    String? option = '',
  }) async {
    final ffApiRequestBody = '''
{
  "p_option": "${escapeStringForJson(option)}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'UpdateUserProfileCounts',
      apiUrl:
          'https://wgcqstmmkcdjnnpuvspr.supabase.co/rest/v1/rpc/update_user_profile_counts',
      callType: ApiCallType.POST,
      headers: {
        'apikey': '${apiKey}',
        'Authorization': 'Bearer ${token}',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class UpdatePostShareCountCall {
  static Future<ApiCallResponse> call({
    String? apiKey,
    String? token = '',
    String? pCommunityid = '',
    String? pUserid = '',
    String? pPostid = '',
  }) async {
    apiKey ??= FFDevEnvironmentValues().AnonKey;

    final ffApiRequestBody = '''
{
  "p_postid": "${escapeStringForJson(pPostid)}",
  "p_userid": "${escapeStringForJson(pUserid)}",
  "p_communityid": "${escapeStringForJson(pCommunityid)}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'UpdatePostShareCount',
      apiUrl:
          'https://wgcqstmmkcdjnnpuvspr.supabase.co/rest/v1/rpc/update_post_share_count',
      callType: ApiCallType.POST,
      headers: {
        'apikey': '${apiKey}',
        'Authorization': 'Bearer ${token}',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class GetFollowingUsersCall {
  static Future<ApiCallResponse> call({
    String? apiKey = '',
    String? token = '',
    String? eventId = '',
  }) async {
    final ffApiRequestBody = '''
{
  "p_event_id": "${escapeStringForJson(eventId)}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'GetFollowingUsers',
      apiUrl:
          'https://wgcqstmmkcdjnnpuvspr.supabase.co/rest/v1/rpc/get_following_users_not_attending_event',
      callType: ApiCallType.POST,
      headers: {
        'apikey': '${apiKey}',
        'Authorization': 'Bearer ${token}',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class InviteUserToEventCall {
  static Future<ApiCallResponse> call({
    String? apiKey = '',
    String? token = '',
    String? eventId = '',
    String? attendingId = '',
  }) async {
    final ffApiRequestBody = '''
{
  "p_event_id": "${escapeStringForJson(eventId)}",
  "p_attending_id": "${escapeStringForJson(attendingId)}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'InviteUserToEvent',
      apiUrl:
          'https://wgcqstmmkcdjnnpuvspr.supabase.co/rest/v1/rpc/invite_user_to_event',
      callType: ApiCallType.POST,
      headers: {
        'apikey': '${apiKey}',
        'Authorization': 'Bearer ${token}',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class TagSearchCall {
  static Future<ApiCallResponse> call({
    String? apikey,
    String? token = '',
    String? name = '',
  }) async {
    apikey ??= FFDevEnvironmentValues().AnonKey;

    final ffApiRequestBody = '''
{
  "search_name": "${escapeStringForJson(name)}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'TagSearch',
      apiUrl: 'https://wgcqstmmkcdjnnpuvspr.supabase.co/rest/v1/rpc/tag_search',
      callType: ApiCallType.POST,
      headers: {
        'apikey': '${apikey}',
        'Authorization': 'Bearer ${token}',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class NotificationCall {
  static Future<ApiCallResponse> call({
    String? apikey,
    String? token = '',
    String? pUserid = '',
  }) async {
    apikey ??= FFDevEnvironmentValues().AnonKey;

    final ffApiRequestBody = '''
{
  "p_userid": "${escapeStringForJson(pUserid)}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'Notification',
      apiUrl:
          'https://wgcqstmmkcdjnnpuvspr.supabase.co/rest/v1/rpc/get_notifications',
      callType: ApiCallType.POST,
      headers: {
        'apikey': '${apikey}',
        'Authorization': 'Bearer ${token}',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class UpdateSearchHistoryCall {
  static Future<ApiCallResponse> call({
    String? apikey,
    String? token = '',
    String? pUserid = '',
    String? pSearchText = '',
    int? pCommunityId,
  }) async {
    apikey ??= FFDevEnvironmentValues().AnonKey;

    final ffApiRequestBody = '''
{
  "p_community_id": ${pCommunityId},
  "p_search_text": "${escapeStringForJson(pSearchText)}",
  "p_userid": "${escapeStringForJson(pUserid)}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'UpdateSearchHistory',
      apiUrl:
          'https://wgcqstmmkcdjnnpuvspr.supabase.co/rest/v1/rpc/update_search_data',
      callType: ApiCallType.POST,
      headers: {
        'apikey': '${apikey}',
        'Authorization': 'Bearer ${token}',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class UpdateCommentCountCall {
  static Future<ApiCallResponse> call({
    String? apikey,
    String? token = '',
    String? pPostid = '',
  }) async {
    apikey ??= FFDevEnvironmentValues().AnonKey;

    final ffApiRequestBody = '''
{
  "p_postid": "${escapeStringForJson(pPostid)}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'updateCommentCount',
      apiUrl:
          'https://wgcqstmmkcdjnnpuvspr.supabase.co/rest/v1/rpc/count_comment',
      callType: ApiCallType.POST,
      headers: {
        'apikey': '${apikey}',
        'Authorization': 'Bearer ${token}',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class GetInvitedUsersForGroupCall {
  static Future<ApiCallResponse> call({
    String? apiKey = '',
    String? token = '',
    String? communityId = '',
    String? groupId = '',
    String? search = '',
  }) async {
    final ffApiRequestBody = '''
{
  "p_community_id": "${escapeStringForJson(communityId)}",
  "p_group_id": "${escapeStringForJson(groupId)}",
  "p_search_text": "${escapeStringForJson(search)}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'GetInvitedUsersForGroup',
      apiUrl:
          'https://wgcqstmmkcdjnnpuvspr.supabase.co/rest/v1/rpc/get_invited_users_for_group',
      callType: ApiCallType.POST,
      headers: {
        'apikey': '${apiKey}',
        'Authorization': 'Bearer ${token}',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class GetGroupsWithUserStatusCall {
  static Future<ApiCallResponse> call({
    String? apiKey = '',
    String? token = '',
  }) async {
    return ApiManager.instance.makeApiCall(
      callName: 'GetGroupsWithUserStatus',
      apiUrl:
          'https://wgcqstmmkcdjnnpuvspr.supabase.co/rest/v1/rpc/get_groups_with_user_status',
      callType: ApiCallType.POST,
      headers: {
        'apikey': '${apiKey}',
        'Authorization': 'Bearer ${token}',
      },
      params: {},
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class GetChatCall {
  static Future<ApiCallResponse> call({
    String? apiKey = '',
    String? token = '',
    String? searchQuery = '',
  }) async {
    final ffApiRequestBody = '''
{
  "search_query": "${escapeStringForJson(searchQuery)}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'GetChat',
      apiUrl: 'https://wgcqstmmkcdjnnpuvspr.supabase.co/rest/v1/rpc/get_chat',
      callType: ApiCallType.POST,
      headers: {
        'apikey': '${apiKey}',
        'Authorization': 'Bearer ${token}',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class InsertTagsCall {
  static Future<ApiCallResponse> call({
    String? apiKey = '',
    String? token = '',
    String? pPostId = '',
    List<String>? pUserIdsList,
  }) async {
    final pUserIds = _serializeList(pUserIdsList);

    final ffApiRequestBody = '''
{
"p_post_id":"${escapeStringForJson(pPostId)}",
  "p_user_ids": "${pUserIds}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'InsertTags',
      apiUrl:
          'https://wgcqstmmkcdjnnpuvspr.supabase.co/rest/v1/rpc/insert_tags',
      callType: ApiCallType.POST,
      headers: {
        'apikey': '${apiKey}',
        'Authorization': 'Bearer ${token}',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class GenerateTLDRCall {
  static Future<ApiCallResponse> call({
    String? commentId = '',
    String? postId = '',
    String? text = '',
    String? token = '',
  }) async {
    final ffApiRequestBody = '''
{
"comment_id":"${escapeStringForJson(commentId)}",
"post_id":"${escapeStringForJson(postId)}",
"text":"${escapeStringForJson(text)}"
}
''';
    return ApiManager.instance.makeApiCall(
      callName: 'GenerateTLDR',
      apiUrl:
          'https://wgcqstmmkcdjnnpuvspr.supabase.co/functions/v1/generate-tldr',
      callType: ApiCallType.POST,
      headers: {
        'Authorization': 'Bearer ${token}',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class PhoneSignupCall {
  static Future<ApiCallResponse> call({
    String? anonKey,
    String? secretKey,
    String? phone = '',
    String? password = '',
    String? confiremPassword = '',
  }) async {
    anonKey ??= FFDevEnvironmentValues().AnonKey;
    secretKey ??= FFDevEnvironmentValues().secretKey;

    final ffApiRequestBody = '''
{
  "phone": "${escapeStringForJson(phone)}",
  "password": "${escapeStringForJson(password)}",
  "confirmPassword": "${escapeStringForJson(confiremPassword)}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'PhoneSignup',
      apiUrl:
          'https://wgcqstmmkcdjnnpuvspr.supabase.co/functions/v1/phone-signup',
      callType: ApiCallType.POST,
      headers: {
        'Authorization': 'Bearer ${anonKey}',
        'x-secret-key': '${secretKey}',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class ApiPagingParams {
  int nextPageNumber = 0;
  int numItems = 0;
  dynamic lastResponse;

  ApiPagingParams({
    required this.nextPageNumber,
    required this.numItems,
    required this.lastResponse,
  });

  @override
  String toString() =>
      'PagingParams(nextPageNumber: $nextPageNumber, numItems: $numItems, lastResponse: $lastResponse,)';
}

String _toEncodable(dynamic item) {
  return item;
}

String _serializeList(List? list) {
  list ??= <String>[];
  try {
    return json.encode(list, toEncodable: _toEncodable);
  } catch (_) {
    if (kDebugMode) {
      print("List serialization failed. Returning empty list.");
    }
    return '[]';
  }
}

String _serializeJson(dynamic jsonVar, [bool isList = false]) {
  jsonVar ??= (isList ? [] : {});
  try {
    return json.encode(jsonVar, toEncodable: _toEncodable);
  } catch (_) {
    if (kDebugMode) {
      print("Json serialization failed. Returning empty json.");
    }
    return isList ? '[]' : '{}';
  }
}

String? escapeStringForJson(String? input) {
  if (input == null) {
    return null;
  }
  return input
      .replaceAll('\\', '\\\\')
      .replaceAll('"', '\\"')
      .replaceAll('\n', '\\n')
      .replaceAll('\t', '\\t');
}
