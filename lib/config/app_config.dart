class AppConfig {
  static late AppConfig _instance;

  final String apiBaseUrl;
  // final String apiKey;
  // final String authDomain;
  // final String projectId;
  // final String storageBucket;
  // final String messagingSenderId;
  // final String appId;
  // final String measurementId;
  // final String environmentName;
  // final bool featureFlagNewProfile;

  AppConfig._internal({
    required this.apiBaseUrl,
    // required this.apiKey,
    // required this.authDomain,
    // required this.projectId,
    // required this.storageBucket,
    // required this.messagingSenderId,
    // required this.appId,
    // required this.measurementId,
    // required this.environmentName,
    // required this.featureFlagNewProfile,
  });

  // static Future<void>  initialize() async {
  //   final contents = await rootBundle.loadString('assets/config/env.json');
  //   final json = jsonDecode(contents);
  //
  //   _instance = AppConfig._internal(
  //     apiBaseUrl: json['API_BASE_URL'],
  //     apiKey: json['apiKey'],
  //     authDomain: json['authDomain'],
  //     projectId: json['projectId'],
  //     storageBucket: json['storageBucket'],
  //     messagingSenderId: json['messagingSenderId'],
  //     appId: json['appId'],
  //     measurementId: json['measurementId'],
  //     environmentName: json['ENVIRONMENT_NAME'],
  //     featureFlagNewProfile: json['FEATURE_FLAG_NEW_PROFILE'] ?? false,
  //   );
  // }

  static Future<void> initializeFromEnv() async {
    const apiBaseUrl = String.fromEnvironment(
      "API_BASE_URL",
      defaultValue: "http://10.0.2.2:6996",
    );
    // const apiKey = String.fromEnvironment("apiKey", defaultValue: "dev-api-key");
    // const authDomain = String.fromEnvironment("AUTH_DOMAIN", defaultValue: "localhost-auth");
    // const projectId = String.fromEnvironment("PROJECT_ID", defaultValue: "dev-project");
    // const storageBucket = String.fromEnvironment("STORAGE_BUCKET", defaultValue: "dev-bucket");
    // const messagingSenderId = String.fromEnvironment("MESSAGING_SENDER_ID", defaultValue: "1234567890");
    // const appId = String.fromEnvironment("APP_ID", defaultValue: "1:1234567890:web:abcdef123456");
    // const measurementId = String.fromEnvironment("MEASUREMENT_ID", defaultValue: "G-DEV1234");
    // const environmentName = String.fromEnvironment("ENVIRONMENT_NAME", defaultValue: "debug");
    // const featureFlagNewProfile = bool.fromEnvironment("FEATURE_FLAG_NEW_PROFILE", defaultValue: false);

    _instance = AppConfig._internal(
      apiBaseUrl: apiBaseUrl,
      // apiKey: apiKey,
      // authDomain: authDomain,
      // projectId: projectId,
      // storageBucket: storageBucket,
      // messagingSenderId: messagingSenderId,
      // appId: appId,
      // measurementId: measurementId,
      // environmentName: environmentName,
      // featureFlagNewProfile: featureFlagNewProfile,
    );
  }

  static AppConfig get instance => _instance;
}
