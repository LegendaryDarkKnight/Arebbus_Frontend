import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:arebbus/service/api_service.dart';
import 'package:arebbus/models/user_location.dart';

/// Background location tracking service for the Arebbus application.
/// 
/// This service manages continuous location tracking for users when they are
/// actively using bus transportation services. It provides:
/// 
/// - Background location monitoring and updates
/// - Periodic location data transmission to the backend
/// - User status-based tracking (only when WAITING or ON_BUS)
/// - Real-time position streaming for immediate updates
/// - Automatic location permission handling
/// - Battery-optimized tracking intervals
/// - Integration with the API service for location data persistence
/// 
/// The service uses a singleton pattern to ensure consistent location tracking
/// across the application and manages both timer-based periodic updates and
/// continuous location streaming for optimal user experience.
class LocationTrackingService {
  /// Singleton instance of the LocationTrackingService
  static final LocationTrackingService _instance = LocationTrackingService._internal();
  
  /// Getter for accessing the singleton instance
  static LocationTrackingService get instance => _instance;
  
  /// Private constructor for singleton pattern implementation
  LocationTrackingService._internal();

  /// API service instance for sending location data to backend
  final ApiService _apiService = ApiService.instance;
  
  /// Timer for periodic location updates (every 5 minutes)
  Timer? _locationTimer;
  
  /// Stream subscription for continuous location monitoring
  StreamSubscription<Position>? _positionStreamSubscription;
  
  /// Current user location status information
  UserLocation? _currentUserStatus;
  
  /// Flag indicating whether location tracking is currently active
  bool _isTracking = false;

  /// Starts location tracking with periodic updates and continuous monitoring.
  /// 
  /// This method initiates background location tracking by:
  /// - Checking and updating current user status from the server
  /// - Setting up periodic location updates every 5 minutes
  /// - Starting continuous location stream for immediate updates
  /// - Only tracking when user status is WAITING or ON_BUS for battery optimization
  /// 
  /// The service prevents duplicate tracking sessions and handles location
  /// permissions automatically.
  Future<void> startTracking() async {
    if (_isTracking) return;
    
    debugPrint('Starting location tracking service');
    _isTracking = true;

    // Check current user status
    await _updateUserStatus();
    
    // Start periodic location updates every 5 minutes
    _locationTimer = Timer.periodic(const Duration(minutes: 5), (timer) async {
      await _performLocationUpdate();
    });

    // Also start continuous location monitoring for immediate updates
    await _startLocationStream();
  }

  /// Stops all location tracking activities and cleans up resources.
  /// 
  /// This method safely stops location tracking by:
  /// - Cancelling the periodic location update timer
  /// - Stopping the continuous location stream subscription
  /// - Cleaning up all tracking-related resources
  /// - Setting tracking state to inactive
  /// 
  /// Should be called when the user logs out, disables location sharing,
  /// or when the app is being terminated.
  void stopTracking() {
    debugPrint('Stopping location tracking service');
    _isTracking = false;
    _locationTimer?.cancel();
    _locationTimer = null;
    _positionStreamSubscription?.cancel();
    _positionStreamSubscription = null;
  }

  /// Updates user status from the server to determine tracking eligibility.
  /// 
  /// This method fetches the current user location status from the backend
  /// to determine if location tracking should continue. Only users with
  /// WAITING or ON_BUS status have their locations tracked to optimize
  /// battery usage and respect user privacy.
  /// 
  /// Handles API errors gracefully and logs debugging information.
  Future<void> _updateUserStatus() async {
    try {
      _currentUserStatus = await _apiService.getUserLocation();
      debugPrint('User status updated: ${_currentUserStatus?.status}');
    } catch (e) {
      debugPrint('Failed to get user status: $e');
      _currentUserStatus = null;
    }
  }

  /// Start location stream for real-time position monitoring
  Future<void> _startLocationStream() async {
    try {
      const LocationSettings locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Only trigger when user moves 10+ meters
      );

      _positionStreamSubscription = Geolocator.getPositionStream(
        locationSettings: locationSettings,
      ).listen(
        (Position position) async {
          // Update location immediately when position changes significantly
          await _performLocationUpdate();
        },
        onError: (error) {
          debugPrint('Location stream error: $error');
        },
      );
    } catch (e) {
      debugPrint('Failed to start location stream: $e');
    }
  }

  /// Perform the actual location update
  Future<void> _performLocationUpdate() async {
    if (!_isTracking) return;

    try {
      // Update user status first
      await _updateUserStatus();

      // Only track if user is WAITING or ON_BUS
      if (_currentUserStatus == null || 
          (_currentUserStatus!.status != 'WAITING' && _currentUserStatus!.status != 'ON_BUS')) {
        debugPrint('User not in trackable status: ${_currentUserStatus?.status}. Stopping tracking.');
        stopTracking();
        return;
      }

      // Check location permissions
      bool hasPermission = await _checkLocationPermissions();
      if (!hasPermission) {
        debugPrint('No location permission, stopping tracking');
        stopTracking();
        return;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );

      // Update location on server
      UserLocation updatedLocation = await _apiService.updateUserLocation(
        latitude: position.latitude,
        longitude: position.longitude,
      );

      _currentUserStatus = updatedLocation;
      debugPrint('Location updated successfully: ${updatedLocation.status} at (${position.latitude}, ${position.longitude})');

    } catch (e) {
      debugPrint('Failed to update location: $e');
      // Don't stop tracking on single failure, continue trying
    }
  }

  /// Check if we have necessary location permissions
  Future<bool> _checkLocationPermissions() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    // For background tracking, we ideally want always permission
    // but whileInUse is acceptable for foreground tracking
    return permission == LocationPermission.always || 
           permission == LocationPermission.whileInUse;
  }

  /// Request background location permission (always)
  Future<bool> requestBackgroundLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.whileInUse) {
      // Try to upgrade to always permission for background tracking
      permission = await Geolocator.requestPermission();
    }

    return permission == LocationPermission.always;
  }

  /// Get current tracking status
  bool get isTracking => _isTracking;

  /// Get current user status
  UserLocation? get currentUserStatus => _currentUserStatus;

  /// Manually trigger a location update (for testing or immediate updates)
  Future<void> updateLocationNow() async {
    await _performLocationUpdate();
  }

  /// Update the cached user status (call this when status changes in UI)
  void updateCachedUserStatus(UserLocation userStatus) {
    _currentUserStatus = userStatus;
    
    // Start tracking if user is now in a trackable status
    if ((userStatus.status == 'WAITING' || userStatus.status == 'ON_BUS') && !_isTracking) {
      startTracking();
    }
    // Stop tracking if user is no longer in a trackable status
    else if (userStatus.status == 'NO_TRACK' && _isTracking) {
      stopTracking();
    }
  }

  /// Dispose resources
  void dispose() {
    stopTracking();
  }
}