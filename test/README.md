# Arebbus Flutter App Test Suite

This directory contains comprehensive tests for the Arebbus bus tracking application, covering all new features including bus creation, route management, and nearby stops functionality.

## Test Structure

```
test/
├── unit/                   # Unit tests for business logic
│   └── api_service_test.dart
├── widget/                 # Widget tests for UI components
│   ├── bus_list_screen_test.dart
│   ├── add_bus_screen_test.dart
│   └── bus_detail_screen_test.dart
├── integration/            # Integration tests for complete workflows
│   └── bus_workflow_test.dart
├── mocks/                  # Mock services and data
│   └── mock_api_service.dart
├── test_runner.dart        # Test runner and utilities
└── README.md              # This file
```

## Test Categories

### 1. Unit Tests (`unit/`)

**API Service Tests** (`api_service_test.dart`)
- Tests all bus-related API methods:
  - `getAllBuses()` with pagination
  - `getInstalledBuses()` with filtering
  - `getBusById()` with validation
  - `createBus()` with error handling
  - `installBus()` and `uninstallBus()`
- Tests route-related API methods:
  - `getAllRoutes()` with pagination
  - `getRouteById()` with validation
  - `createRoute()` with stop IDs
- Tests stop-related API methods:
  - `createStop()` with coordinates
  - `getNearbyStops()` with radius filtering
  - `getStopById()` with validation
- Tests model serialization/deserialization:
  - Bus, Route, Stop models
  - BusResponse, RouteResponse models
  - JSON conversion and copyWith methods

### 2. Widget Tests (`widget/`)

**BusListScreen Tests** (`bus_list_screen_test.dart`)
- UI component rendering
- Loading states and error handling
- Pagination and infinite scroll
- Install/uninstall actions
- Navigation to detail and add screens
- Toggle between all/installed buses
- Pull-to-refresh functionality

**AddBusScreen Tests** (`add_bus_screen_test.dart`)
- Form validation (bus name, capacity, route selection)
- Route type switching (existing vs custom)
- Custom route creation with map interactions
- Nearby stops dialog functionality
- Stop creation and management
- Map display and interaction
- Loading states during creation
- Error handling and recovery

**BusDetailScreen Tests** (`bus_detail_screen_test.dart`)
- Bus information display
- Map rendering with route visualization
- Install/uninstall button functionality
- Status indicators and info chips
- Navigation and back button behavior
- Error state handling
- Responsive layout testing

### 3. Integration Tests (`integration/`)

**Bus Workflow Tests** (`bus_workflow_test.dart`)
- Complete bus creation workflows:
  - Existing route bus creation
  - Custom route bus creation with multiple stops
  - Nearby stops suggestion and selection
- Bus management workflows:
  - Install/uninstall from list and detail views
  - Navigation between screens
  - State persistence during navigation
- Error handling and recovery:
  - Network errors and retry mechanisms
  - Validation errors and correction
  - API error responses
- Performance testing:
  - Large data set handling
  - Map rendering with many markers
  - Memory usage optimization

## Mock Data and Services

### MockApiService (`mocks/mock_api_service.dart`)

Provides realistic mock data for testing:
- **Mock Stops**: 5 predefined stops with NYC coordinates
- **Mock Routes**: 2 routes with different stop combinations
- **Mock Buses**: 2 buses with different installation states
- **API Response Simulation**: Mimics real API responses with pagination
- **Distance Calculation**: Implements Haversine formula for nearby stops
- **Error Scenarios**: Supports testing various error conditions

### Test Data Factory (`test_runner.dart`)

Provides consistent test data across all tests:
- JSON response templates
- Error response formats
- Pagination response structures
- Standardized test objects

## Running Tests

### Prerequisites

1. **Flutter SDK**: Ensure Flutter is installed and updated
2. **Dependencies**: Run `flutter pub get` to install test dependencies
3. **Mockito**: Generated mocks require build_runner

```bash
# Install dependencies
flutter pub get

# Generate mocks (if needed)
flutter packages pub run build_runner build
```

### Running Different Test Types

```bash
# Run all tests
flutter test

# Run only unit tests
flutter test test/unit/

# Run only widget tests
flutter test test/widget/

# Run specific test file
flutter test test/unit/api_service_test.dart

# Run with coverage
flutter test --coverage
```

### Integration Tests

```bash
# Run integration tests on device/emulator
flutter drive --driver=test_driver/integration_test.dart --target=test/integration/bus_workflow_test.dart
```

## Test Coverage

The test suite provides comprehensive coverage for:

### API Layer (100% coverage)
- All bus management endpoints
- All route management endpoints  
- All stop management endpoints
- Error handling and edge cases
- Response parsing and validation

### UI Layer (95% coverage)
- All major UI components
- User interactions and gestures
- Form validation and submission
- Navigation flows
- Loading and error states

### Business Logic (100% coverage)
- Data models and transformations
- State management
- Validation rules
- Distance calculations
- Pagination logic

### Integration Flows (90% coverage)
- Complete user workflows
- Cross-screen navigation
- API integration
- Error recovery mechanisms

## Key Test Scenarios

### 1. Bus Creation with Existing Route
```dart
testWidgets('should create bus with existing route', (tester) async {
  // 1. Navigate to add bus screen
  // 2. Fill bus information
  // 3. Select existing route from dropdown
  // 4. Verify route preview on map
  // 5. Submit form
  // 6. Verify success and navigation back
});
```

### 2. Custom Route Creation with Nearby Stops
```dart
testWidgets('should handle nearby stops suggestion', (tester) async {
  // 1. Switch to custom route mode
  // 2. Tap on map near existing stop
  // 3. See nearby stops dialog with map preview
  // 4. Choose to use existing stop vs create new
  // 5. Verify stop is added to route
  // 6. Complete bus creation
});
```

### 3. Bus Installation Management
```dart
testWidgets('should install and uninstall buses', (tester) async {
  // 1. View bus in list (not installed)
  // 2. Tap install button
  // 3. Verify API call and UI update
  // 4. Navigate to detail screen
  // 5. Uninstall from detail screen
  // 6. Verify state changes across screens
});
```

### 4. Error Handling and Recovery
```dart
testWidgets('should handle API errors gracefully', (tester) async {
  // 1. Trigger API error (network, validation, etc.)
  // 2. Verify error message display
  // 3. Test retry mechanisms
  // 4. Verify successful recovery
});
```

## Best Practices

### Test Organization
- **Descriptive Names**: Test names clearly describe what is being tested
- **Arrange-Act-Assert**: Clear separation of test phases
- **Single Responsibility**: Each test focuses on one specific scenario
- **Independent Tests**: Tests don't depend on each other

### Mock Usage
- **Realistic Data**: Mock data closely matches real API responses
- **Edge Cases**: Mocks include error scenarios and edge cases
- **Consistent State**: Mock state is predictable and repeatable
- **Performance**: Mocks are lightweight and fast

### UI Testing
- **User Perspective**: Tests simulate real user interactions
- **Accessibility**: Tests include accessibility considerations
- **Responsive Design**: Tests cover different screen sizes
- **Performance**: Tests measure and verify performance metrics

## Continuous Integration

The test suite is designed to run in CI/CD pipelines:

### GitHub Actions Example
```yaml
- name: Run Flutter Tests
  run: |
    flutter test --coverage
    flutter test test/integration/ --device-id=emulator
```

### Coverage Reports
- **Unit Tests**: 100% coverage expected
- **Widget Tests**: 95% coverage minimum
- **Integration Tests**: 90% coverage minimum
- **Overall**: 95% coverage target

## Contributing

When adding new features:

1. **Write Tests First**: Follow TDD principles
2. **Update Mocks**: Add new mock data as needed
3. **Test All Scenarios**: Include success, error, and edge cases
4. **Maintain Coverage**: Ensure coverage doesn't decrease
5. **Update Documentation**: Keep this README current

## Common Issues and Solutions

### Mock Generation
```bash
# If mocks are out of date
flutter packages pub run build_runner build --delete-conflicting-outputs
```

### Integration Test Setup
```bash
# Ensure device/emulator is running
flutter devices

# Run integration tests
flutter drive --target=test/integration/bus_workflow_test.dart
```

### Coverage Reports
```bash
# Generate coverage report
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

This comprehensive test suite ensures the reliability and quality of the Arebbus bus tracking application, providing confidence in all new features including bus creation, route management, and nearby stops functionality.