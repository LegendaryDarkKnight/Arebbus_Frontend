import 'package:flutter_test/flutter_test.dart';

// Import all working test files
import 'unit/mock_api_service_test.dart' as mock_tests;
import 'simple_test.dart' as simple_tests;
import 'widget/bus_list_simple_test.dart' as widget_tests;

void main() {
  group('Arebbus Test Suite', () {
    group('Unit Tests', () {
      mock_tests.main();
    });

    group('Simple Tests', () {
      simple_tests.main();
    });

    group('Widget Tests', () {
      widget_tests.main();
    });
  });
}