import 'package:geolocator/geolocator.dart';

class GpsService {
  // Check if location services are enabled
  static Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  // Check location permissions
  static Future<LocationPermission> checkPermission() async {
    return await Geolocator.checkPermission();
  }

  // Request location permissions
  static Future<LocationPermission> requestPermission() async {
    return await Geolocator.requestPermission();
  }

  // Check and request permissions if needed
  static Future<Map<String, dynamic>> checkAndRequestPermission() async {
    // Check if location services are enabled
    bool serviceEnabled = await isLocationServiceEnabled();
    if (!serviceEnabled) {
      return {
        'success': false,
        'message': 'Location services are disabled. Please enable location services.',
      };
    }

    // Check permissions
    LocationPermission permission = await checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await requestPermission();
      if (permission == LocationPermission.denied) {
        return {
          'success': false,
          'message': 'Location permissions are denied',
        };
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return {
        'success': false,
        'message': 'Location permissions are permanently denied. Please enable them in settings.',
      };
    }

    return {'success': true, 'message': 'Permission granted'};
  }

  // Get current location
  static Future<Map<String, dynamic>> getCurrentLocation() async {
    try {
      // Check and request permissions
      final permissionResult = await checkAndRequestPermission();
      if (!permissionResult['success']) {
        return permissionResult;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      return {
        'success': true,
        'latitude': position.latitude,
        'longitude': position.longitude,
        'accuracy': position.accuracy,
        'altitude': position.altitude,
        'timestamp': position.timestamp,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to get location: ${e.toString()}',
      };
    }
  }

  // Get current location with custom timeout
  static Future<Map<String, dynamic>> getCurrentLocationWithTimeout({
    Duration timeout = const Duration(seconds: 15),
  }) async {
    try {
      // Check and request permissions
      final permissionResult = await checkAndRequestPermission();
      if (!permissionResult['success']) {
        return permissionResult;
      }

      // Get current position with timeout
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: timeout,
      );

      return {
        'success': true,
        'latitude': position.latitude,
        'longitude': position.longitude,
        'accuracy': position.accuracy,
        'altitude': position.altitude,
        'timestamp': position.timestamp,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to get location: ${e.toString()}',
      };
    }
  }

  // Validate GPS coordinates
  static bool isValidCoordinate(double latitude, double longitude) {
    return latitude >= -90 &&
           latitude <= 90 &&
           longitude >= -180 &&
           longitude <= 180 &&
           latitude != 0.0 &&
           longitude != 0.0;
  }

  // Format coordinates for display
  static String formatCoordinates(double latitude, double longitude) {
    return '${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}';
  }

  // Get distance between two coordinates (in meters)
  static double getDistanceBetween(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    return Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }

  // Open location settings
  static Future<bool> openLocationSettings() async {
    return await Geolocator.openLocationSettings();
  }

  // Open app settings
  static Future<bool> openAppSettings() async {
    return await Geolocator.openAppSettings();
  }
}
