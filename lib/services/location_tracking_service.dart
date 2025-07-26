import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:arebbus/service/api_service.dart';
import 'package:arebbus/models/user_location.dart';

class LocationTrackingService {
  static final LocationTrackingService _instance = LocationTrackingService._internal();
  static LocationTrackingService get instance => _instance;
  
  LocationTrackingService._internal();

  final ApiService _apiService = ApiService.instance;
  Timer? _locationTimer;
  StreamSubscription<Position>? _positionStreamSubscription;
  UserLocation? _currentUserStatus;
  bool _isTracking = false;

  /// Start tracking user location every minute
  /// Only tracks when user is in WAITING or ON_BUS status
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

  /// Stop location tracking
  void stopTracking() {
    debugPrint('Stopping location tracking service');
    _isTracking = false;
    _locationTimer?.cancel();
    _locationTimer = null;
    _positionStreamSubscription?.cancel();
    _positionStreamSubscription = null;
  }

  /// Update user status from server
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