import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationService {
  // Check and request location permissions
  static Future<bool> requestLocationPermission() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return false;
      }

      // Request permission using permission_handler for better control
      PermissionStatus permission = await Permission.location.request();

      if (permission.isGranted) {
        return true;
      } else if (permission.isDenied) {
        // Try requesting again with geolocator
        LocationPermission geoPermission = await Geolocator.requestPermission();
        return geoPermission == LocationPermission.whileInUse ||
            geoPermission == LocationPermission.always;
      }

      return false;
    } catch (e) {
      print('Error requesting location permission: $e');
      return false;
    }
  }

  // Get current location
  static Future<Position?> getCurrentLocation() async {
    try {
      bool hasPermission = await requestLocationPermission();
      if (!hasPermission) {
        return null;
      }

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
    } catch (e) {
      print('Error getting current location: $e');
      return null;
    }
  }

  // Get address from coordinates
  static Future<String?> getAddressFromCoordinates(
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

        // Build address string
        List<String> addressParts = [];

        if (place.street != null && place.street!.isNotEmpty) {
          addressParts.add(place.street!);
        }
        if (place.subLocality != null && place.subLocality!.isNotEmpty) {
          addressParts.add(place.subLocality!);
        }
        if (place.locality != null && place.locality!.isNotEmpty) {
          addressParts.add(place.locality!);
        }
        if (place.administrativeArea != null &&
            place.administrativeArea!.isNotEmpty) {
          addressParts.add(place.administrativeArea!);
        }

        return addressParts.join(', ');
      }

      return null;
    } catch (e) {
      print('Error getting address from coordinates: $e');
      return null;
    }
  }

  // Get coordinates from address
  static Future<Position?> getCoordinatesFromAddress(String address) async {
    try {
      List<Location> locations = await locationFromAddress(address);

      if (locations.isNotEmpty) {
        Location location = locations[0];
        return Position(
          latitude: location.latitude,
          longitude: location.longitude,
          timestamp: DateTime.now(),
          accuracy: 0,
          altitude: 0,
          altitudeAccuracy: 0,
          heading: 0,
          headingAccuracy: 0,
          speed: 0,
          speedAccuracy: 0,
        );
      }

      return null;
    } catch (e) {
      print('Error getting coordinates from address: $e');
      return null;
    }
  }

  // Calculate distance between two points
  static double calculateDistance(
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
        ) /
        1000; // Convert to kilometers
  }

  // Get location info for display
  static Future<LocationInfo?> getLocationInfo() async {
    try {
      Position? position = await getCurrentLocation();
      if (position == null) return null;

      String? address = await getAddressFromCoordinates(
        position.latitude,
        position.longitude,
      );

      return LocationInfo(
        latitude: position.latitude,
        longitude: position.longitude,
        address: address ?? 'Unknown location',
      );
    } catch (e) {
      print('Error getting location info: $e');
      return null;
    }
  }
}

class LocationInfo {
  final double latitude;
  final double longitude;
  final String address;

  const LocationInfo({
    required this.latitude,
    required this.longitude,
    required this.address,
  });

  // Get short address for display
  String get shortAddress {
    List<String> parts = address.split(', ');
    if (parts.length > 2) {
      return '${parts[0]}, ${parts[1]}';
    }
    return address;
  }

  // Get area name (locality/city)
  String get areaName {
    List<String> parts = address.split(', ');
    if (parts.length > 1) {
      return parts.last; // Usually the city/area is last
    }
    return address;
  }
}
