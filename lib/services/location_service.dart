import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {
  /// Check if location services are enabled
  static Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Check location permission status
  static Future<LocationPermission> checkPermission() async {
    return await Geolocator.checkPermission();
  }

  /// Request location permission
  static Future<LocationPermission> requestPermission() async {
    return await Geolocator.requestPermission();
  }

  /// Get current position with error handling
  static Future<Position?> getCurrentPosition() async {
    try {
      debugPrint('📍 Checking location service...');

      // Check if location service is enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('❌ Location service is disabled');
        return null;
      }
      debugPrint('✅ Location service is enabled');

      // Check permission
      debugPrint('🔐 Checking location permission...');
      LocationPermission permission = await Geolocator.checkPermission();
      debugPrint('   Current permission: $permission');

      if (permission == LocationPermission.denied) {
        debugPrint('⚠️ Permission denied, requesting...');
        permission = await Geolocator.requestPermission();
        debugPrint('   New permission: $permission');

        if (permission == LocationPermission.denied) {
          debugPrint('❌ Permission denied by user');
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        debugPrint('❌ Permission denied forever');
        return null;
      }

      debugPrint('✅ Permission granted, getting position...');

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      debugPrint('✅ Position obtained: ${position.latitude}, ${position.longitude}');
      return position;
    } catch (e) {
      debugPrint('❌ Error getting position: $e');
      return null;
    }
  }

  /// Get location name from coordinates (reverse geocoding)
  static Future<String> getLocationName(double latitude, double longitude) async {
    try {
      debugPrint('🌍 Getting location name for: $latitude, $longitude');

      List<Placemark> placemarks = await placemarkFromCoordinates(
        latitude,
        longitude,
      );

      debugPrint('📍 Placemarks found: ${placemarks.length}');

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];

        // Debug: Print all available fields
        debugPrint('🔍 Placemark details:');
        debugPrint('   - subLocality: ${place.subLocality}');
        debugPrint('   - locality: ${place.locality}');
        debugPrint('   - subAdministrativeArea: ${place.subAdministrativeArea}');
        debugPrint('   - administrativeArea: ${place.administrativeArea}');
        debugPrint('   - subThoroughfare: ${place.subThoroughfare}');
        debugPrint('   - thoroughfare: ${place.thoroughfare}');
        debugPrint('   - country: ${place.country}');

        // Try to get a short, meaningful location name (only the first/most specific part)
        String? locationName;

        // Priority 1: subLocality (e.g., "Pabuaran", "Menteng")
        if (place.subLocality != null && place.subLocality!.isNotEmpty &&
            place.subLocality != 'null' && place.subLocality != '') {
          locationName = place.subLocality!;
        }

        // Priority 2: locality (e.g., "Jakarta Pusat", "Cibinong")
        if (locationName == null && place.locality != null && place.locality!.isNotEmpty &&
            place.locality != 'null' && place.locality != '') {
          locationName = place.locality!;
        }

        // Priority 3: subAdministrativeArea
        if (locationName == null && place.subAdministrativeArea != null &&
            place.subAdministrativeArea!.isNotEmpty &&
            place.subAdministrativeArea != 'null') {
          locationName = place.subAdministrativeArea!;
        }

        // Priority 4: administrativeArea
        if (locationName == null && place.administrativeArea != null &&
            place.administrativeArea!.isNotEmpty &&
            place.administrativeArea != 'null') {
          locationName = place.administrativeArea!;
        }

        // Priority 5: thoroughfare (street name)
        if (locationName == null && place.thoroughfare != null &&
            place.thoroughfare!.isNotEmpty &&
            place.thoroughfare != 'null') {
          locationName = place.thoroughfare!;
        }

        // Final result
        if (locationName != null) {
          debugPrint('✅ Location detected: $locationName');
          return locationName;
        }

        // Fallback to country if nothing else is available
        if (place.country != null && place.country!.isNotEmpty) {
          debugPrint('⚠️ Only country available: ${place.country}');
          return place.country!;
        }
      }

      debugPrint('❌ No location found');
      return 'Lokasi Tidak Diketahui';
    } catch (e) {
      debugPrint('❌ Error getting location name: $e');
      return 'Error: ${e.toString()}';
    }
  }

  /// Get current location with name
  static Future<Map<String, dynamic>?> getCurrentLocationWithName() async {
    try {
      Position? position = await getCurrentPosition();

      if (position == null) {
        return null;
      }

      String locationName = await getLocationName(position.latitude, position.longitude);

      return {
        'latitude': position.latitude,
        'longitude': position.longitude,
        'locationName': locationName,
      };
    } catch (e) {
      return null;
    }
  }

  /// Open location settings
  static Future<bool> openLocationSettings() async {
    return await Geolocator.openLocationSettings();
  }

  /// Open app settings
  static Future<bool> openAppSettings() async {
    return await Geolocator.openAppSettings();
  }
}
