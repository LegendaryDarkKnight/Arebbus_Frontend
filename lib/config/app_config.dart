import 'dart:convert' show jsonDecode;
import 'package:flutter/services.dart' show rootBundle;

class AppConfig {
  static late AppConfig _instance;

  final String apiBaseUrl;
  final String apiKey;
  final String authDomain;
  final String projectId;
  final String storageBucket;
  final String messagingSenderId;
  final String appId;
  final String measurementId;
  final String environmentName;
  final bool featureFlagNewProfile;

  AppConfig._internal({
    required this.apiBaseUrl,
    required this.apiKey,
    required this.authDomain,
    required this.projectId,
    required this.storageBucket,
    required this.messagingSenderId,
    required this.appId,
    required this.measurementId,
    required this.environmentName,
    required this.featureFlagNewProfile,
  });

  static Future<void> initialize() async {
    final contents = await rootBundle.loadString('assets/config/env.json');
    final json = jsonDecode(contents);

    _instance = AppConfig._internal(
      apiBaseUrl: json['API_BASE_URL'],
      apiKey: json['apiKey'],
      authDomain: json['authDomain'],
      projectId: json['projectId'],
      storageBucket: json['storageBucket'],
      messagingSenderId: json['messagingSenderId'],
      appId: json['appId'],
      measurementId: json['measurementId'],
      environmentName: json['ENVIRONMENT_NAME'],
      featureFlagNewProfile: json['FEATURE_FLAG_NEW_PROFILE'] ?? false,
    );
  }

  static AppConfig get instance => _instance;
}
