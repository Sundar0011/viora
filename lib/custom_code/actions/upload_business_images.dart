// Automatic FlutterFlow imports
import '/backend/schema/enums/enums.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'dart:typed_data';
import '/flutter_flow/app_log.dart';

Future<List<String>> uploadBusinessImages(
  FFUploadedFile? profile,
  FFUploadedFile? coverImage,
  String foldername,
  String profileUrl,
  String coverUrl,
) async {
  final bucketName = 'business-image';

  try {
    // Initialize return values with the provided URLs
    String uploadedProfileUrl = profileUrl;
    String uploadedCoverUrl = coverUrl;

    // Upload new profile image if provided
    if (profile != null && profile.bytes != null && profile.bytes!.isNotEmpty) {
      final ext = profile.name?.split('.').last ?? 'webp';
      final fileName = 'profile_${DateTime.now().millisecondsSinceEpoch}.$ext';
      final path = '$foldername/$fileName';

      await Supabase.instance.client.storage.from(bucketName).uploadBinary(
          path, profile.bytes!,
          fileOptions: const FileOptions(upsert: true));

      uploadedProfileUrl =
          Supabase.instance.client.storage.from(bucketName).getPublicUrl(path);
    }

    // Upload new cover image if provided
    if (coverImage != null &&
        coverImage.bytes != null &&
        coverImage.bytes!.isNotEmpty) {
      final ext = coverImage.name?.split('.').last ?? 'webp';
      final fileName = 'cover_${DateTime.now().millisecondsSinceEpoch}.$ext';
      final path = '$foldername/$fileName';

      await Supabase.instance.client.storage.from(bucketName).uploadBinary(
          path, coverImage.bytes!,
          fileOptions: const FileOptions(upsert: true));

      uploadedCoverUrl =
          Supabase.instance.client.storage.from(bucketName).getPublicUrl(path);
    }

    return [uploadedProfileUrl, uploadedCoverUrl];
  } catch (e) {
    appLog('UploadBusinessImages error: $e');
    // Return the original URLs if something goes wrong
    return [profileUrl, coverUrl];
  }
}
