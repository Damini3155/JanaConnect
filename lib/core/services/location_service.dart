import 'package:flutter/foundation.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

/// Data class holding GPS position and reverse-geocoded address.
class GeoLocationData {
  final double latitude;
  final double longitude;
  final double accuracy;
  final String address;
  final DateTime timestamp;

  const GeoLocationData({
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    required this.address,
    required this.timestamp,
  });

  String get formattedCoordinates =>
      'Lat: ${latitude.toStringAsFixed(6)}, Lng: ${longitude.toStringAsFixed(6)}';
}

/// Service handling GPS location requests and reverse geocoding.
class LocationService {
  final Geocoding _geocoding = Geocoding();

  /// Check GPS availability and request permissions if needed
  Future<bool> checkAndRequestPermission() async {
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

    return true;
  }

  /// Get current high-accuracy position and reverse-geocoded address
  Future<GeoLocationData> getCurrentLocation() async {
    final hasPermission = await checkAndRequestPermission();
    if (!hasPermission) {
      throw Exception('Location permissions are disabled or denied.');
    }

    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    );

    final address = await getAddressFromCoordinates(
      position.latitude,
      position.longitude,
    );

    return GeoLocationData(
      latitude: position.latitude,
      longitude: position.longitude,
      accuracy: position.accuracy,
      address: address,
      timestamp: DateTime.now(),
    );
  }

  /// Reverse geocode coordinates to human-readable street address
  Future<String> getAddressFromCoordinates(double lat, double lng) async {
    try {
      final placemarks = await _geocoding.placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final parts = [
          place.subLocality,
          place.locality,
          place.administrativeArea,
          place.postalCode,
        ].where((p) => p != null && p.trim().isNotEmpty).toList();

        if (parts.isNotEmpty) {
          return parts.join(', ');
        }
      }
      return '${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)}';
    } catch (e) {
      debugPrint('Geocoding error: $e');
      return '${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)}';
    }
  }

  /// Distance calculation in meters between two GPS coordinates (used for duplicate detection)
  double calculateDistanceMeters(
    double lat1,
    double lng1,
    double lat2,
    double lng2,
  ) {
    return Geolocator.distanceBetween(lat1, lng1, lat2, lng2);
  }
}
