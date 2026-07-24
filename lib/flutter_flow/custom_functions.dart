import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'lat_lng.dart';
import 'place.dart';
import 'uploaded_file.dart';
import '/backend/schema/enums/enums.dart';
import '/backend/supabase/supabase.dart';
import '/auth/supabase_auth/auth_util.dart';
import '/flutter_flow/app_log.dart';

DateTime? getCurrentUtcTime() {
  return DateTime.now().toUtc();
}

String? lastSeen(String time) {
  // Parse the input timestamp to local time
  DateTime postTime = DateTime.parse(time).toLocal();
  DateTime now = DateTime.now();

  Duration difference = now.difference(postTime);

  if (difference.inSeconds < 60) {
    return "last seen just now";
  } else if (difference.inMinutes < 60) {
    return "last seen ${difference.inMinutes} min${difference.inMinutes == 1 ? '' : 's'} ago";
  } else if (difference.inHours < 24) {
    return "last seen ${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago";
  } else if (difference.inDays < 7) {
    return "last seen ${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago";
  } else {
    return "last seen on ${DateFormat('d MMM yyyy').format(postTime)}";
  }
}

String? lastMessageDate(String time) {
  DateTime postTime = DateTime.parse(time).toLocal();
  DateTime now = DateTime.now();

  DateTime today = DateTime(now.year, now.month, now.day);
  DateTime yesterday = today.subtract(Duration(days: 1));
  DateTime postDate = DateTime(postTime.year, postTime.month, postTime.day);

  if (postDate == today) {
    // Same day: show time
    return DateFormat('h:mm a').format(postTime); // e.g., 2:30 PM
  } else if (postDate == yesterday) {
    // One day before: say "Yesterday"
    return "Yesterday";
  } else {
    // Older dates: show date
    return DateFormat('dd/MM/yyyy').format(postTime); // e.g., 03/04/2025
  }
}

DateTime returnTime(String time) {
  return DateTime.parse(time);
}

String getFinalValues(int total) {
  if (total < 1000) {
    return total.toString();
  } else if (total < 100000) {
    double value = total / 1000;
    return value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 1) +
        'k';
  } else if (total < 10000000) {
    double value = total / 100000;
    return value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 1) +
        'L';
  } else {
    double value = total / 10000000;
    return value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 1) +
        'M';
  }
}

String? maskContactInfo(String input) {
  // Remove any whitespace
  String cleanInput = input.trim();

  // Check if it's an email (contains @ symbol)
  if (cleanInput.contains('@')) {
    // EMAIL MASKING LOGIC
    List<String> parts = cleanInput.split('@');

    if (parts.length != 2) {
      return cleanInput; // Invalid email format, return as is
    }

    String localPart = parts[0];
    String domainPart = parts[1];

    // Mask local part (keep first 3 characters, rest as *)
    String maskedLocal;
    if (localPart.length <= 3) {
      maskedLocal = localPart + '***';
    } else {
      maskedLocal = localPart.substring(0, 3) + '***';
    }

    // Mask domain part (show as ***)
    String maskedDomain = '***';

    return maskedLocal + '@' + maskedDomain;
  }

  // PHONE NUMBER DETECTION AND MASKING LOGIC
  // Remove common phone number characters to check if remaining are digits
  String digitsOnly = cleanInput.replaceAll(RegExp(r'[\s\-\(\)\+]'), '');

  // Check if it's a phone number (starts with + or if it's all digits after removing formatting)
  bool isPhoneNumber =
      cleanInput.startsWith('+') || RegExp(r'^\d+$').hasMatch(digitsOnly);

  if (isPhoneNumber) {
    // Remove spaces and formatting, but keep the + and hyphens for structure
    String cleanPhone = cleanInput.replaceAll(RegExp(r'[\s\(\)]'), '');

    // If it doesn't start with +, assume it's a local number
    if (!cleanPhone.startsWith('+')) {
      // For local numbers, just mask last 4 digits
      if (cleanPhone.length >= 4) {
        return cleanPhone.substring(0, cleanPhone.length - 4) + 'XXXX';
      }
      return cleanPhone;
    }

    // For international numbers with country code
    // Find the last 4 digits and replace with XXXX
    String digits = cleanPhone.replaceAll(RegExp(r'[^\d]'), '');

    if (digits.length >= 4) {
      // Reconstruct with original formatting but mask last 4 digits
      String result = cleanPhone;

      // Find position of last 4 digits
      int digitCount = 0;
      for (int i = result.length - 1; i >= 0; i--) {
        if (RegExp(r'\d').hasMatch(result[i])) {
          digitCount++;
          if (digitCount <= 4) {
            result = result.substring(0, i) + 'X' + result.substring(i + 1);
          }
        }
      }
      return result;
    }

    return cleanPhone;
  }

  // If neither email nor phone, return original string
  return cleanInput;
}

List<String> returnListServices(String services) {
  return services
      .split(',')
      .map((s) => s.trim())
      .where((s) => s.isNotEmpty)
      .toList();
}

dynamic returnServices(
  dynamic inputJson,
  String countValue,
) {
  // Decode input if it's a JSON string
  final List<dynamic> businesses =
      inputJson is String ? json.decode(inputJson) : inputJson;

  // We're assuming you only want to process the first object
  final business = businesses.first;

  final List<dynamic> services = business['services'];
  final int totalCount = services.length;

  if (countValue == 'all') {
    return {
      'services': services,
      'total_count': totalCount,
    };
  } else {
    return {
      'services': services.take(4).toList(),
      'total_count': totalCount,
    };
  }
}

String returnServicesArrray(List<String> input) {
  return input.join(', ');
}

String formatTimestamp(String timestampString) {
  // Parse the ISO 8601 timestamp string
  DateTime dateTime = DateTime.parse(timestampString);

  // List of month abbreviations
  List<String> months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec'
  ];

  // Format as "MMM. dd, yyyy"
  String month = months[dateTime.month - 1];
  String day = dateTime.day.toString().padLeft(2, '0');
  String year = dateTime.year.toString();

  return '$month. $day, $year';
}

DateTime returnPlanEndDate(String inputDate) {
  return DateTime.parse(inputDate);
}

List<dynamic> addSampleUserData() {
  return [
    {
      "userid": "1a14873d-b1e5-4d71-85ee-ab20d18939c5",
      "username": "Harikishore S",
      "profile":
          "https://hlmymmlkgirafodcnkgg.supabase.co/storage/v1/object/public/squadd/default_profile/default_profile.png",
    },
    {
      "userid": "d3060943-fe07-4031-9bbb-3fc0b4608b06",
      "username": "Sundaravel S",
      "profile":
          "https://hlmymmlkgirafodcnkgg.supabase.co/storage/v1/object/public/profile-images/d3060943-fe07-4031-9bbb-3fc0b4608b06/1752467834364978.jpg",
    },
  ];
}

String returnRelativeTIme(String inputtimestrampz) {
  try {
    final parsedDate = DateTime.parse(inputtimestrampz);
    return timeago.format(parsedDate, allowFromNow: true);
  } catch (e) {
    return 'Invalid time';
  }
}

LatLng returnlatitudeLongitude(
  double lat,
  double lng,
) {
  return LatLng(lat, lng);
}

DateTime? returnTimeStamp(
  DateTime date,
  String time,
) {
  try {
    // Parse the time string (supports both 12-hour and 24-hour formats)
    DateTime parsedTime;
    if (time.toLowerCase().contains('am') ||
        time.toLowerCase().contains('pm')) {
      parsedTime = DateFormat.jm().parse(time); // e.g. "2:30 PM"
    } else {
      parsedTime = DateFormat.Hm().parse(time); // e.g. "14:30"
    }

    // Combine the date and parsed time into one DateTime object
    final combinedDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      parsedTime.hour,
      parsedTime.minute,
    );

    return combinedDateTime;
  } catch (e) {
    return null;
  }
}

String? eventDate(DateTime date) {
  // Format: May 23, 6:00 PM UTC
  final datePart = DateFormat('MMM d').format(date.toUtc());
  final timePart = DateFormat('h:mm a').format(date.toUtc());

  return '$datePart, $timePart UTC';
}

bool endSoon(DateTime date) {
  final now = DateTime.now();
  final difference = date.difference(now);

  // Return true if the date is within the next 24 hours and is in the future
  return difference.inSeconds > 0 && difference.inHours < 24;
}

String eventDateTime2(DateTime date) {
  String getDaySuffix(int day) {
    if (day >= 11 && day <= 13) return 'th';
    switch (day % 10) {
      case 1:
        return 'st';
      case 2:
        return 'nd';
      case 3:
        return 'rd';
      default:
        return 'th';
    }
  }

  final month = DateFormat.MMMM().format(date); // e.g. May
  final day = date.day;
  final suffix = getDaySuffix(day);
  final time = DateFormat.j().format(date); // e.g. 7 PM

  return '$month ${day}$suffix, @$time';
}

String getDistance(
  String lat1,
  String lon1,
  String lat2,
  String lon2,
) {
  try {
    final double latitude1 = double.parse(lat1);
    final double longitude1 = double.parse(lon1);
    final double latitude2 = double.parse(lat2);
    final double longitude2 = double.parse(lon2);

    const double earthRadiusMiles = 3958.8;

    double degreesToRadians(double degrees) => degrees * math.pi / 180;

    final double dLat = degreesToRadians(latitude2 - latitude1);
    final double dLon = degreesToRadians(longitude2 - longitude1);

    final double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(degreesToRadians(latitude1)) *
            math.cos(degreesToRadians(latitude2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);

    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    final double distance = earthRadiusMiles * c;

    return distance.toStringAsFixed(2); // distance in miles as a string
  } catch (e) {
    return '0.00';
  }
}

bool checkCommentReplyPresent(
  dynamic commentReplies,
  String parentId,
) {
  if (commentReplies is List) {
    for (final item in commentReplies) {
      if (item is Map && item['parent_comment_id'] == parentId) {
        return true;
      }
    }
  }
  return false;
}

dynamic returnCommentReplies(
  dynamic repliesjson,
  String parentId,
) {
  if (repliesjson is List) {
    final filteredReplies = repliesjson.where((reply) {
      if (reply is Map && reply['parent_comment_id'] != null) {
        return reply['parent_comment_id'].toString() == parentId;
      }
      return false;
    }).toList();

    return filteredReplies;
  }
  return [];
}

List<String> returnIdsSearch(
  dynamic jsonResponse,
  String type,
) {
  if (jsonResponse == null || type.isEmpty) return [];

  try {
    final data = json.decode(
        jsonResponse is String ? jsonResponse : json.encode(jsonResponse));

    if (data[type] == null || data[type] is! List) return [];

    return List<String>.from(
      (data[type] as List)
          .map((item) => item['id'])
          .where((id) => id != null && id is String),
    );
  } catch (e) {
    appLog('Error parsing IDs from search response: $e');
    return [];
  }
}

dynamic returnSearchedInternalShareUser(
  dynamic inputjson,
  String searchString,
) {
  if (inputjson == null || searchString.trim().isEmpty) {
    return inputjson;
  }

  try {
    final lowerSearch = searchString.toLowerCase();

    final filtered = (inputjson as List).where((user) {
      final name = (user['name'] ?? '').toString().toLowerCase();
      return name.contains(lowerSearch);
    }).toList();

    return filtered;
  } catch (e) {
    return inputjson; // fallback in case of malformed input
  }
}

bool validDate(
  String time1,
  String time2,
) {
  try {
    final format = DateFormat('hh:mm a'); // e.g., "01:00 PM"
    final now = DateTime.now();

    // Parse both times
    final parsedTime1 = format.parseStrict(time1);
    final parsedTime2 = format.parseStrict(time2);

    // Convert to today's full DateTime for safe comparison
    final dateTime1 = DateTime(
        now.year, now.month, now.day, parsedTime1.hour, parsedTime1.minute);
    final dateTime2 = DateTime(
        now.year, now.month, now.day, parsedTime2.hour, parsedTime2.minute);

    return dateTime1.isAfter(dateTime2);
  } catch (e) {
    // If parsing fails (invalid format), return false
    return false;
  }
}

dynamic appendTagList(
  dynamic inputNewTag,
  dynamic currTags,
) {
  List<dynamic> currentTagList = [];

  // Handle currTags - could be null, string, or list
  if (currTags != null) {
    if (currTags is String && currTags.isNotEmpty) {
      try {
        currentTagList = jsonDecode(currTags) as List<dynamic>;
      } catch (e) {
        currentTagList = [];
      }
    } else if (currTags is List) {
      currentTagList = List<dynamic>.from(currTags);
    }
  }

  // Return current list if no new tag to add
  if (inputNewTag == null) {
    return currentTagList;
  }

  // Handle single tag
  if (inputNewTag is Map<String, dynamic>) {
    bool tagExists = currentTagList.any(
      (tag) => tag is Map && tag['id'] == inputNewTag['id'],
    );
    if (!tagExists) {
      currentTagList.add(inputNewTag);
    }
  }
  // Handle multiple tags
  else if (inputNewTag is List) {
    for (var newTag in inputNewTag) {
      if (newTag is Map<String, dynamic>) {
        bool tagExists = currentTagList.any(
          (tag) => tag is Map && tag['id'] == newTag['id'],
        );
        if (!tagExists) {
          currentTagList.add(newTag);
        }
      }
    }
  }

  // Return the updated list
  return currentTagList;
}

String appendCustomText(
  dynamic choosedName,
  String customText,
) {
  if (choosedName == null) {
    return customText;
  }

  // Extract user data from choosedName
  Map<String, dynamic> user = {};
  if (choosedName is Map<String, dynamic>) {
    user = choosedName;
  } else if (choosedName is String) {
    try {
      user = jsonDecode(choosedName) as Map<String, dynamic>;
    } catch (e) {
      return customText; // Return original if parsing fails
    }
  } else {
    return customText; // Return original if invalid type
  }

  // Get user data
  final userId = user['id']?.toString() ?? '';
  final userName = user['name']?.toString() ?? '';

  if (userId.isEmpty || userName.isEmpty) {
    return customText; // Return original if missing data
  }

  // Find the last @ in the custom text
  final lastAtIndex = customText.lastIndexOf('@');

  if (lastAtIndex == -1) {
    // No @ found, just append the mention
    return '$customText@$userName ';
  }

  // Find the text after the last @
  final textAfterAt = customText.substring(lastAtIndex + 1);

  // Find if there's a space after @, if so only replace until the space
  final spaceIndex = textAfterAt.indexOf(' ');

  String result;
  if (spaceIndex == -1) {
    // No space found, replace everything after @
    result = customText.substring(0, lastAtIndex) + '@$userName ';
  } else {
    // Space found, replace only until the space
    final beforeAt = customText.substring(0, lastAtIndex);
    final afterSpace = customText.substring(lastAtIndex + 1 + spaceIndex);
    result = '$beforeAt@$userName $afterSpace';
  }

  return result;
}

dynamic returnLimitedPosts(
  dynamic inputJson,
  int? limit,
  String userid,
) {
  if (inputJson == null || userid.isEmpty) return [];

  // Convert input to list
  List<Map<String, dynamic>> allPosts =
      List<Map<String, dynamic>>.from(inputJson);

  // Filter by user_id
  List<Map<String, dynamic>> filteredPosts =
      allPosts.where((post) => post['user_id'] == userid).toList();

  // If limit is null or 0, return all
  if (limit == null || limit == 0) {
    return filteredPosts;
  }

  // Otherwise, return up to the limit
  return filteredPosts.take(limit).toList();
}

String shortRelativeTime(String fullTimeAgo) {
  try {
    if (fullTimeAgo.contains('second')) {
      final value = RegExp(r'\d+').firstMatch(fullTimeAgo)?.group(0);
      return '${value}s';
    } else if (fullTimeAgo.contains('minute')) {
      final value = RegExp(r'\d+').firstMatch(fullTimeAgo)?.group(0);
      return '${value}m';
    } else if (fullTimeAgo.contains('hour')) {
      final value = RegExp(r'\d+').firstMatch(fullTimeAgo)?.group(0);
      return '${value}h';
    } else if (fullTimeAgo.contains('day')) {
      final value = RegExp(r'\d+').firstMatch(fullTimeAgo)?.group(0);
      return '${value}d';
    } else if (fullTimeAgo.contains('week')) {
      final value = RegExp(r'\d+').firstMatch(fullTimeAgo)?.group(0);
      return '${value}w';
    } else if (fullTimeAgo.contains('month')) {
      final value = RegExp(r'\d+').firstMatch(fullTimeAgo)?.group(0);
      return '${value}mo';
    } else if (fullTimeAgo.contains('year')) {
      final value = RegExp(r'\d+').firstMatch(fullTimeAgo)?.group(0);
      return '${value}y';
    } else {
      return fullTimeAgo;
    }
  } catch (e) {
    return 'Err';
  }
}

List<String>? returnTaggedUserIds(dynamic taggedPeople) {
  if (taggedPeople is! List) return null;

  try {
    return taggedPeople
        .where((item) => item is Map && item.containsKey('id'))
        .map<String>((item) => item['id'].toString())
        .toList();
  } catch (e) {
    return null;
  }
}

dynamic textToJson(String? textt) {
  // Helper function to validate mentions array - moved inside the main function
  List<dynamic> validateMentions(dynamic mentions) {
    if (mentions == null || mentions is! List) {
      return [];
    }

    List<dynamic> validatedMentions = [];

    for (var mention in mentions) {
      if (mention is Map) {
        validatedMentions.add({
          'start': mention['start'] ?? 0,
          'end': mention['end'] ?? 0,
          'userId': mention['userId'] ?? '',
          'name': mention['name'] ?? '',
          'text': mention['text'] ?? '',
        });
      }
    }

    return validatedMentions;
  }

  // Helper function to extract mentions from plain text - moved inside the main function
  List<dynamic> extractMentionsFromText(String text) {
    List<dynamic> mentions = [];
    RegExp mentionRegex = RegExp(r'@([a-zA-Z0-9_\s]+?)(?=\s|$|[^\w\s])');

    Iterable<RegExpMatch> matches = mentionRegex.allMatches(text);

    for (RegExpMatch match in matches) {
      String mentionText = match.group(0) ?? '';
      String userName = match.group(1)?.trim() ?? '';

      mentions.add({
        'start': match.start,
        'end': match.end,
        'text': mentionText,
        'name': userName,
        'userId': '', // This would need to be populated from your user database
      });
    }

    return mentions;
  }

  try {
    // Handle null or empty input
    if (textt == null || textt.isEmpty) {
      return {
        'text': '',
        'mentions': [],
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'success': false,
        'error': 'Input text is null or empty'
      };
    }

    // Remove any leading/trailing whitespace
    String cleanedText = textt.trim();

    // Check if the input is already a valid JSON string
    if (cleanedText.startsWith('{') && cleanedText.endsWith('}')) {
      try {
        // Parse the JSON string
        dynamic jsonData = json.decode(cleanedText);

        // If it's a Map, validate and structure the post data
        if (jsonData is Map<String, dynamic>) {
          return {
            'text': jsonData['text'] ?? '',
            'mentions': validateMentions(jsonData['mentions']),
            'timestamp':
                jsonData['timestamp'] ?? DateTime.now().millisecondsSinceEpoch,
            'success': true
          };
        }

        // Return parsed JSON as-is if not a map
        return jsonData;
      } catch (parseError) {
        return {
          'originalText': textt,
          'parseError': parseError.toString(),
          'success': false,
          'error': 'Failed to parse JSON'
        };
      }
    } else {
      // If it's not properly formatted JSON, return as plain text with extracted mentions
      List<dynamic> extractedMentions = extractMentionsFromText(cleanedText);

      return {
        'text': cleanedText,
        'mentions': extractedMentions,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'success': true,
        'note': 'Converted plain text to JSON format'
      };
    }
  } catch (e) {
    // Return error information if anything fails
    return {
      'originalText': textt,
      'error': e.toString(),
      'success': false,
      'timestamp': DateTime.now().millisecondsSinceEpoch
    };
  }
}

String getRelativeTime(String time) {
  if (time.isEmpty) {
    return 'now';
  }

  try {
    // Parse the timestamp
    DateTime notificationTime = DateTime.parse(time);
    DateTime now = DateTime.now();

    // Calculate the difference
    Duration difference = now.difference(notificationTime);

    // Return relative time based on duration (Instagram-style)
    if (difference.inSeconds < 60) {
      return 'now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()}w';
    } else if (difference.inDays < 365) {
      return '${(difference.inDays / 30).floor()}mo';
    } else {
      return '${(difference.inDays / 365).floor()}y';
    }
  } catch (e) {
    return 'now';
  }
}

String formatnumber(String mobilenumber) {
  // Remove any whitespace
  String cleanNumber = mobilenumber.trim();

  // If the number has 10 or fewer digits, return as is
  if (cleanNumber.length <= 10) {
    return cleanNumber;
  }

  // If the number has more than 10 digits, return the last 10 digits
  return cleanNumber.substring(cleanNumber.length - 10);
}
