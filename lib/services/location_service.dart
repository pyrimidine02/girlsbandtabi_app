import 'package:geolocator/geolocator.dart';
import '../models/verification_model.dart';
import 'verification_service.dart';
class LocationService {
  LocationService._();

  static LocationService? _instance;
  static LocationService get instance => _instance ??= LocationService._();

  factory LocationService() => instance;

  // Request location permissions
  Future<bool> requestLocationPermission() async {
    // Check if location services are enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    // Check current permission status
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

  // Get current location
  Future<Position?> getCurrentLocation() async {
    try {
      bool hasPermission = await requestLocationPermission();
      if (!hasPermission) return null;

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      return position;
    } catch (e) {
      // TODO: handle location error appropriately.
      return null;
    }
  }

  // Get multiple location readings for better accuracy
  Future<Position?> getAccurateLocation({
    int samples = 3,
    Duration interval = const Duration(seconds: 2),
  }) async {
    try {
      bool hasPermission = await requestLocationPermission();
      if (!hasPermission) return null;

      List<Position> positions = [];

      for (int i = 0; i < samples; i++) {
        if (i > 0) {
          await Future.delayed(interval);
        }

        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 10),
        );

        positions.add(position);
      }

      // Calculate average position
      double avgLat = positions.map((p) => p.latitude).reduce((a, b) => a + b) / positions.length;
      double avgLon = positions.map((p) => p.longitude).reduce((a, b) => a + b) / positions.length;
      double avgAccuracy = positions.map((p) => p.accuracy).reduce((a, b) => a + b) / positions.length;

      // Return a position with averaged coordinates
      return Position(
        longitude: avgLon,
        latitude: avgLat,
        timestamp: DateTime.now(),
        accuracy: avgAccuracy,
        altitude: positions.first.altitude,
        heading: positions.first.heading,
        speed: positions.first.speed,
        speedAccuracy: positions.first.speedAccuracy,
        altitudeAccuracy: positions.first.altitudeAccuracy,
        headingAccuracy: positions.first.headingAccuracy,
      );
    } catch (e) {
      // print('Error getting accurate location: $e');
      return null;
    }
  }

  // Check if location is mocked (Android specific)
  Future<bool> isMockLocation(Position position) async {
    // On Android, check if mock location is detected
    // This is a simplified check - in production, you'd want more sophisticated detection
    try {
      // Check if developer options are enabled and mock location apps are allowed
      // This would require additional platform-specific implementation
      return false; // Placeholder - implement platform-specific mock detection
    } catch (e) {
      return false;
    }
  }

  // Calculate distance between two points
  double calculateDistance(
    double lat1, double lon1, 
    double lat2, double lon2
  ) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
  }

  // Check if user is within visit range of a place
  bool isWithinVisitRange(
    Position userPosition, 
    double placeLat, double placeLon,
    {double radiusMeters = 10.0}
  ) {
    double distance = calculateDistance(
      userPosition.latitude, userPosition.longitude,
      placeLat, placeLon
    );
    
    return distance <= radiusMeters;
  }

  // Generate JWE token for location verification
  Future<String> generateLocationToken(
    Position position, {
    String? placeId,
    String? eventId,
  }) async {
    final verificationService = VerificationService();
    return verificationService.buildLocationToken(
      lat: position.latitude,
      lon: position.longitude,
      accuracyM: position.accuracy,
      altitude: position.altitude,
      heading: position.heading,
      speed: position.speed,
      placeId: placeId,
      eventId: eventId,
    );
  }

  // Create verification request
  Future<VisitVerificationRequest?> createVerificationRequest(
    Position position, {
    String? placeId,
    String? eventId,
  }) async {
    try {
      // Check for mock location
      bool isMocked = await isMockLocation(position);
      if (isMocked) {
        throw Exception('Mock location detected');
      }

      final verificationToken = await generateLocationToken(
        position, 
        placeId: placeId,
        eventId: eventId,
      );

      return VisitVerificationRequest(
        token: verificationToken,
        lat: position.latitude,
        lon: position.longitude,
        accuracyM: position.accuracy,
        clientTs: DateTime.now().toIso8601String(),
      );
    } catch (e) {
      // print('Error creating verification request: $e');
      return null;
    }
  }

  // Validate movement pattern for anti-spoofing
  Future<bool> validateMovementPattern(List<Position> recentPositions) async {
    if (recentPositions.length < 2) return true;

    // Check for unrealistic movement patterns
    for (int i = 1; i < recentPositions.length; i++) {
      final previous = recentPositions[i-1];
      final current = recentPositions[i];
      
      final distance = calculateDistance(
        previous.latitude, previous.longitude,
        current.latitude, current.longitude,
      );
      
      final timeDifference = current.timestamp.difference(previous.timestamp).inSeconds;
      
      if (timeDifference > 0) {
        final speed = distance / timeDifference; // meters per second
        
        // Check for unrealistic speeds (>100 m/s = ~360 km/h)
        if (speed > 100) {
          return false;
        }
      }
    }

    return true;
  }

  // Get location settings info
  Future<Map<String, dynamic>> getLocationSettings() async {
    return {
      'isLocationServiceEnabled': await Geolocator.isLocationServiceEnabled(),
      'locationPermission': (await Geolocator.checkPermission()).toString(),
    };
  }

  // Open location settings
  Future<void> openLocationSettings() async {
    await Geolocator.openLocationSettings();
  }

  // Open app settings
  Future<void> openAppSettings() async {
    await Geolocator.openAppSettings();
  }
}
