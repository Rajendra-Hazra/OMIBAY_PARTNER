import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service to handle location permissions and tracking for partners
class LocationService {
  static final LocationService instance = LocationService._internal();
  factory LocationService() => instance;
  LocationService._internal();

  Timer? _locationUpdateTimer;
  Position? _lastKnownPosition;
  String? _currentAddress;

  // Storage keys
  static const String _keyLatitude = 'partner_latitude';
  static const String _keyLongitude = 'partner_longitude';
  static const String _keyAddress = 'partner_address';

  /// Check if location permission is granted
  Future<bool> isPermissionGranted() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      return permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse;
    } catch (e) {
      debugPrint('Error checking location permission: $e');
      return false;
    }
  }

  /// Request location permission from user
  Future<bool> requestPermission() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        debugPrint('Location permission denied forever');
        return false;
      }

      if (permission == LocationPermission.denied) {
        debugPrint('Location permission denied');
        return false;
      }

      debugPrint('✅ Location permission granted');
      return true;
    } catch (e) {
      debugPrint('Error requesting location permission: $e');
      return false;
    }
  }

  /// Get current location coordinates
  Future<Position?> getCurrentLocation() async {
    try {
      bool hasPermission = await isPermissionGranted();
      if (!hasPermission) {
        debugPrint('⚠️ Location permission not granted');
        return null;
      }

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('⚠️ Location services are disabled');
        return null;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      _lastKnownPosition = position;
      await _saveLocationToPrefs(position);

      debugPrint('📍 Location: ${position.latitude}, ${position.longitude}');
      return position;
    } catch (e) {
      debugPrint('Error getting current location: $e');
      return null;
    }
  }

  /// Get address from coordinates
  Future<String?> getAddressFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latitude,
        longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        String address = '';

        if (place.locality != null && place.locality!.isNotEmpty) {
          address = place.locality!;
        }
        if (place.administrativeArea != null &&
            place.administrativeArea!.isNotEmpty) {
          if (address.isNotEmpty) address += ', ';
          address += place.administrativeArea!;
        }

        _currentAddress = address.isNotEmpty ? address : 'Location detected';
        await _saveAddressToPrefs(_currentAddress!);

        return _currentAddress;
      }
      return null;
    } catch (e) {
      debugPrint('Error getting address: $e');
      return null;
    }
  }

  /// Start periodic location tracking (every 30 seconds)
  void startLocationTracking(Function(Position) onLocationUpdate) {
    debugPrint('🔄 Starting location tracking');

    _locationUpdateTimer?.cancel();
    _locationUpdateTimer = Timer.periodic(const Duration(seconds: 30), (
      timer,
    ) async {
      Position? position = await getCurrentLocation();
      if (position != null) {
        onLocationUpdate(position);
      }
    });
  }

  /// Stop location tracking
  void stopLocationTracking() {
    debugPrint('⏸️ Stopping location tracking');
    _locationUpdateTimer?.cancel();
    _locationUpdateTimer = null;
  }

  /// Save location to SharedPreferences
  Future<void> _saveLocationToPrefs(Position position) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(_keyLatitude, position.latitude);
      await prefs.setDouble(_keyLongitude, position.longitude);
    } catch (e) {
      debugPrint('Error saving location to prefs: $e');
    }
  }

  /// Save address to SharedPreferences
  Future<void> _saveAddressToPrefs(String address) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyAddress, address);
    } catch (e) {
      debugPrint('Error saving address to prefs: $e');
    }
  }

  /// Get saved location from SharedPreferences
  Future<Map<String, double>?> getSavedLocation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lat = prefs.getDouble(_keyLatitude);
      final lng = prefs.getDouble(_keyLongitude);

      if (lat != null && lng != null) {
        return {'latitude': lat, 'longitude': lng};
      }
      return null;
    } catch (e) {
      debugPrint('Error getting saved location: $e');
      return null;
    }
  }

  /// Get saved address from SharedPreferences
  Future<String?> getSavedAddress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_keyAddress);
    } catch (e) {
      debugPrint('Error getting saved address: $e');
      return null;
    }
  }

  /// Get last known position
  Position? get lastKnownPosition => _lastKnownPosition;

  /// Get current address
  String? get currentAddress => _currentAddress;

  /// Dispose resources
  void dispose() {
    _locationUpdateTimer?.cancel();
  }
}
