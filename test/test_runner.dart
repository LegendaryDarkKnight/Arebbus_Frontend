import 'package:flutter_test/flutter_test.dart';

// Import all test files
import 'unit/api_service_test.dart' as api_service_tests;
import 'widget/bus_list_screen_test.dart' as bus_list_tests;
import 'widget/add_bus_screen_test.dart' as add_bus_tests;
import 'widget/bus_detail_screen_test.dart' as bus_detail_tests;

void main() {
  group('All Unit Tests', () {
    api_service_tests.main();
  });

  group('All Widget Tests', () {
    bus_list_tests.main();
    add_bus_tests.main();
    bus_detail_tests.main();
  });
}

// Test utilities and shared setup
class TestConfig {
  static void setUpAll() {
    // Global test setup
  }

  static void tearDownAll() {
    // Global test cleanup
  }
}

// Mock data factory for consistent test data
class TestDataFactory {
  static Map<String, dynamic> getBusJsonResponse() {
    return {
      "id": 1,
      "name": "Test Bus",
      "authorName": "Test Author",
      "route": {
        "id": 1,
        "name": "Test Route",
        "authorName": "Test Author",
        "stops": [
          {
            "id": 1,
            "name": "Test Stop 1",
            "latitude": 40.7128,
            "longitude": -74.0060,
            "authorName": "Test Author"
          },
          {
            "id": 2,
            "name": "Test Stop 2",
            "latitude": 40.7589,
            "longitude": -73.9851,
            "authorName": "Test Author"
          }
        ]
      },
      "capacity": 50,
      "numInstall": 5,
      "numUpvote": 12,
      "status": "ACTIVE",
      "basedOn": null,
      "upvoted": false,
      "installed": true
    };
  }

  static Map<String, dynamic> getBusListResponse() {
    return {
      "buses": [getBusJsonResponse()],
      "page": 0,
      "size": 10,
      "totalPages": 1,
      "totalElements": 1
    };
  }

  static Map<String, dynamic> getRouteJsonResponse() {
    return {
      "id": 1,
      "name": "Test Route",
      "authorName": "Test Author",
      "stops": [
        {
          "id": 1,
          "name": "Test Stop 1",
          "latitude": 40.7128,
          "longitude": -74.0060,
          "authorName": "Test Author"
        },
        {
          "id": 2,
          "name": "Test Stop 2", 
          "latitude": 40.7589,
          "longitude": -73.9851,
          "authorName": "Test Author"
        }
      ]
    };
  }

  static Map<String, dynamic> getRouteListResponse() {
    return {
      "routes": [getRouteJsonResponse()],
      "page": 0,
      "size": 10,
      "totalPages": 1,
      "totalElements": 1
    };
  }

  static Map<String, dynamic> getStopJsonResponse() {
    return {
      "id": 1,
      "name": "Test Stop",
      "latitude": 40.7128,
      "longitude": -74.0060,
      "authorName": "Test Author"
    };
  }

  static List<Map<String, dynamic>> getNearbyStopsResponse() {
    return [
      {
        "id": 1,
        "name": "Nearby Stop 1",
        "latitude": 40.7130,
        "longitude": -74.0062,
        "authorName": "Test Author"
      },
      {
        "id": 2,
        "name": "Nearby Stop 2",
        "latitude": 40.7125,
        "longitude": -74.0058,
        "authorName": "Test Author"
      }
    ];
  }

  static Map<String, dynamic> getInstallResponse() {
    return {
      "busId": 1,
      "busName": "Test Bus",
      "message": "Bus installed successfully",
      "installed": true
    };
  }

  static Map<String, dynamic> getUninstallResponse() {
    return {
      "busId": 1,
      "busName": "Test Bus",
      "message": "Bus uninstalled successfully",
      "installed": false
    };
  }

  static Map<String, dynamic> getErrorResponse() {
    return {
      "timestamp": "2023-12-07T10:30:00Z",
      "error": "Test error message"
    };
  }
}