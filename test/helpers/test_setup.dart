import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arebbus/config/app_config.dart';

class TestSetup {
  static bool _isInitialized = false;

  /// Initialize all app dependencies for testing
  static Future<void> initialize() async {
    if (_isInitialized) return;

    TestWidgetsFlutterBinding.ensureInitialized();
    
    // Initialize AppConfig using the existing method
    await AppConfig.initializeFromEnv();
    
    _isInitialized = true;
  }

  /// Reset all singletons and state for test isolation
  static void reset() {
    _isInitialized = false;
  }
}

/// Extension to help with test widget setup
extension TestWidgetSetup on WidgetTester {
  /// Pump a widget with proper test setup
  Future<void> pumpWithSetup(Widget widget) async {
    await TestSetup.initialize();
    await pumpWidget(widget);
  }
}