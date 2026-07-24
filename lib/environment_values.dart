import 'dart:convert';
import 'package:flutter/services.dart';
import 'flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/app_log.dart';

class FFDevEnvironmentValues {
  static const String currentEnvironment = 'Production';
  static const String environmentValuesPath =
      'assets/environment_values/environment.json';

  static final FFDevEnvironmentValues _instance =
      FFDevEnvironmentValues._internal();

  factory FFDevEnvironmentValues() {
    return _instance;
  }

  FFDevEnvironmentValues._internal();

  Future<void> initialize() async {
    try {
      final String response =
          await rootBundle.loadString(environmentValuesPath);
      final data = await json.decode(response);
      _AnonKey = data['AnonKey'];
      _Google = data['Google'];
      _oneSignalAppId = data['oneSignalAppId'];
      _secretKey = data['secretKey'];
    } catch (e) {
      appLog('Error loading environment values: $e');
    }
  }

  String _AnonKey = '';
  String get AnonKey => _AnonKey;

  String _Google = '';
  String get Google => _Google;

  String _oneSignalAppId = '';
  String get oneSignalAppId => _oneSignalAppId;

  String _secretKey = '';
  String get secretKey => _secretKey;
}
