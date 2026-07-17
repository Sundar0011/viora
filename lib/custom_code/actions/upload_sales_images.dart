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

Future uploadSalesImages(
  List<FFUploadedFile> uploadedImages,
  String saleId,
  String userid,
  String communityId,
) async {
  final bucketName = 'sales-images';

  try {
    for (final image in uploadedImages) {
      if (image.bytes != null && image.bytes!.isNotEmpty) {
        final ext = image.name?.split('.').last ?? 'webp';
        final fileName = '${DateTime.now().millisecondsSinceEpoch}.$ext';
        final cleanSaleId = saleId.trim();
        final path = '$cleanSaleId/$fileName';

        print('Uploading to path: $path'); // Debug

        await Supabase.instance.client.storage.from(bucketName).uploadBinary(
              path,
              image.bytes!,
              fileOptions: const FileOptions(upsert: true),
            );

        final publicUrl = Supabase.instance.client.storage
            .from(bucketName)
            .getPublicUrl(path);

        await Supabase.instance.client.from('sale_images').insert({
          'sale_id': saleId,
          'user_id': userid,
          'community_id': int.tryParse(communityId),
          'image': publicUrl,
        });
      }
    }
  } catch (e) {
    print('UploadSalesImages error: $e');
  }
}
