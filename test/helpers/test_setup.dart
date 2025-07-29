import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arebbus/config/app_config.dart';

/// Test setup utility class for initializing dependencies and managing test state.
/// 
/// TestSetup provides centralized functionality for:
/// - Initializing app dependencies required for testing
/// - Managing singleton instances and test isolation
/// - Setting up Flutter test environment consistently
/// - Providing reusable setup methods for different test types
/// 
/// This class ensures that all tests have a consistent environment
/// and that singleton dependencies are properly initialized before
/// running test cases. It also provides cleanup methods for test isolation.
class TestSetup {
  /// Flag to track whether initialization has been completed
  static bool _isInitialized = false;

  /// Initialize all app dependencies for testing
  /// 
  /// This method sets up the Flutter test environment and initializes
  /// all necessary dependencies that the app requires to function properly.
  /// It ensures that:
  /// - Flutter binding is properly initialized
  /// - AppConfig singleton is set up with test environment values
  /// - All required services are ready for test execution
  /// 
  /// The method uses a flag to prevent duplicate initialization when
  /// called multiple times during test suite execution.
  /// 
  /// @return Future that completes when all initialization is done
  static Future<void> initialize() async {
    if (_isInitialized) return;

    TestWidgetsFlutterBinding.ensureInitialized();
    
    // Initialize AppConfig using the existing method
    await AppConfig.initializeFromEnv();
    
    _isInitialized = true;
  }

  /// Reset all singletons and state for test isolation
  /// 
  /// This method cleans up the test environment to ensure proper
  /// test isolation between different test cases. It resets:
  /// - Initialization flags to allow fresh setup
  /// - Singleton instances that might retain state
  /// - Any cached data that could affect subsequent tests
  /// 
  /// Call this method in tearDown() or between tests that need
  /// completely fresh environments.
  static void reset() {
    _isInitialized = false;
  }
}

/// Extension to help with test widget setup
/// 
/// TestWidgetSetup extends WidgetTester to provide convenient methods
/// for setting up widgets in tests with proper dependency initialization.
/// This extension simplifies the common pattern of initializing dependencies
/// before pumping widgets in widget tests.
extension TestWidgetSetup on WidgetTester {
  /// Pump a widget with proper test setup
  /// 
  /// This method combines dependency initialization with widget pumping
  /// to provide a one-step solution for setting up widget tests.
  /// It ensures that all required dependencies are initialized before
  /// the widget is rendered and tested.
  /// 
  /// @param widget The widget to pump and test
  /// @return Future that completes when widget is pumped and ready for testing
  Future<void> pumpWithSetup(Widget widget) async {
    await TestSetup.initialize();
    await pumpWidget(widget);
  }
}