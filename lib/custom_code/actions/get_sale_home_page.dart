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

import 'package:http/http.dart' as http;
import 'dart:convert';

Future<List<dynamic>> getSaleHomePage(
  String apiKey,
  String jwt,
  String pUserid,
  String pCategory,
  String pType,
  int pDistance,
  String pSort,
  int pCommunityid,
) async {
  final url = Uri.parse(
    'https://hlmymmlkgirafodcnkgg.supabase.co/rest/v1/rpc/get_sales_home_data',
  );

  final headers = {
    'apikey': apiKey,
    'Authorization': 'Bearer $jwt',
    'Content-Type': 'application/json',
  };

  final body = json.encode({
    'p_userid': pUserid,
    'p_category': pCategory,
    'p_type': pType,
    'p_distance': pDistance,
    'p_sort': pSort,
    'p_communityid': pCommunityid,
  });

  final response = await http.post(url, headers: headers, body: body);

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    if (data is List) {
      return data;
    } else {
      return [data]; // Return as list if it’s a single object
    }
  } else {
    throw Exception('Failed to fetch sales home data: ${response.body}');
  }
}
