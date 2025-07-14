class AppConfig {
  static late AppConfig _instance;
  final String apiBaseUrl;

  AppConfig._internal({
    required this.apiBaseUrl,
  });

  static Future<void> initializeFromEnv() async {
    const apiBaseUrl = String.fromEnvironment(
      "API_BASE_URL",
      defaultValue: "http://10.0.2.2:6996",
    );
    _instance = AppConfig._internal(
      apiBaseUrl: apiBaseUrl,
    );
  }

  static AppConfig get instance => _instance;
}
