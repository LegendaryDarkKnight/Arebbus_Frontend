/// Application configuration manager for the Arebbus Flutter app.
/// 
/// AppConfig is a singleton class that manages application-wide configuration
/// settings, primarily handling environment-specific values such as API endpoints.
/// This class implements the singleton pattern to ensure consistent configuration
/// access throughout the application lifecycle.
/// 
/// Key features:
/// - Singleton pattern for global configuration access
/// - Environment variable support for different deployment environments
/// - Default fallback values for development and testing
/// - Immutable configuration once initialized
/// 
/// Usage:
/// ```dart
/// await AppConfig.initializeFromEnv();
/// String apiUrl = AppConfig.instance.apiBaseUrl;
/// ```
class AppConfig {
  /// Singleton instance of AppConfig
  static late AppConfig _instance;
  
  /// Base URL for API endpoints, loaded from environment or default
  final String apiBaseUrl;

  /// Private constructor to enforce singleton pattern.
  /// 
  /// @param apiBaseUrl The base URL for all API calls
  AppConfig._internal({required this.apiBaseUrl});

  /// Initializes the AppConfig singleton from environment variables.
  /// 
  /// This method must be called once during app startup before accessing
  /// the configuration instance. It reads the API_BASE_URL from environment
  /// variables or uses a default localhost URL for development.
  /// 
  /// Environment variables supported:
  /// - API_BASE_URL: Base URL for API endpoints (default: "http://localhost:6996")
  /// 
  /// @return Future that completes when configuration is initialized
  static Future<void> initializeFromEnv() async {
    const apiBaseUrl = String.fromEnvironment(
      "API_BASE_URL",
      defaultValue: "http://localhost:6996",
    );
    _instance = AppConfig._internal(apiBaseUrl: apiBaseUrl);
  }

  /// Gets the singleton instance of AppConfig.
  /// 
  /// Throws an error if initializeFromEnv() hasn't been called first.
  /// 
  /// @return The configured AppConfig instance
  static AppConfig get instance => _instance;
}
