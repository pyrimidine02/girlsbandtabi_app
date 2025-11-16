import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../services/location_service.dart';
import '../services/place_service.dart';
import '../models/verification_model.dart';

// Location service provider
final locationServiceProvider = Provider<LocationService>((ref) => LocationService.instance);
final placeServiceProvider = Provider<PlaceService>((ref) => PlaceService());

// Current location provider
final currentLocationProvider = StateNotifierProvider<LocationNotifier, LocationState>((ref) {
  return LocationNotifier(
    locationService: ref.read(locationServiceProvider),
  );
});

// Visit verification provider
final visitVerificationProvider = StateNotifierProvider<VisitVerificationNotifier, VisitVerificationState>((ref) {
  return VisitVerificationNotifier(
    locationService: ref.read(locationServiceProvider),
    placeService: ref.read(placeServiceProvider),
  );
});

// Location state
class LocationState {
  final bool isLoading;
  final Position? currentPosition;
  final bool hasPermission;
  final String? error;
  final List<Position> recentPositions;

  const LocationState({
    this.isLoading = false,
    this.currentPosition,
    this.hasPermission = false,
    this.error,
    this.recentPositions = const [],
  });

  LocationState copyWith({
    bool? isLoading,
    Position? currentPosition,
    bool? hasPermission,
    String? error,
    List<Position>? recentPositions,
  }) {
    return LocationState(
      isLoading: isLoading ?? this.isLoading,
      currentPosition: currentPosition ?? this.currentPosition,
      hasPermission: hasPermission ?? this.hasPermission,
      error: error,
      recentPositions: recentPositions ?? this.recentPositions,
    );
  }
}

// Location notifier
class LocationNotifier extends StateNotifier<LocationState> {
  final LocationService _locationService;

  LocationNotifier({
    required LocationService locationService,
  }) : _locationService = locationService,
       super(const LocationState()) {
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    final hasPermission = await _locationService.requestLocationPermission();
    state = state.copyWith(hasPermission: hasPermission);
  }

  Future<void> requestPermission() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final hasPermission = await _locationService.requestLocationPermission();
      state = state.copyWith(
        isLoading: false,
        hasPermission: hasPermission,
        error: hasPermission ? null : 'Location permission denied',
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> getCurrentLocation() async {
    if (!state.hasPermission) {
      await requestPermission();
      if (!state.hasPermission) return;
    }

    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final position = await _locationService.getCurrentLocation();
      if (position != null) {
        final updatedPositions = [...state.recentPositions, position];
        // Keep only last 10 positions
        final recentPositions = updatedPositions.length > 10 
          ? updatedPositions.sublist(updatedPositions.length - 10)
          : updatedPositions;

        state = state.copyWith(
          isLoading: false,
          currentPosition: position,
          recentPositions: recentPositions,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Failed to get location',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> getAccurateLocation() async {
    if (!state.hasPermission) {
      await requestPermission();
      if (!state.hasPermission) return;
    }

    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final position = await _locationService.getAccurateLocation();
      if (position != null) {
        final updatedPositions = [...state.recentPositions, position];
        final recentPositions = updatedPositions.length > 10 
          ? updatedPositions.sublist(updatedPositions.length - 10)
          : updatedPositions;

        state = state.copyWith(
          isLoading: false,
          currentPosition: position,
          recentPositions: recentPositions,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Failed to get accurate location',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Visit verification state
class VisitVerificationState {
  final bool isVerifying;
  final VisitVerificationResponse? verificationResult;
  final String? error;
  final bool isWithinRange;
  final double? distance;

  const VisitVerificationState({
    this.isVerifying = false,
    this.verificationResult,
    this.error,
    this.isWithinRange = false,
    this.distance,
  });

  VisitVerificationState copyWith({
    bool? isVerifying,
    VisitVerificationResponse? verificationResult,
    String? error,
    bool? isWithinRange,
    double? distance,
  }) {
    return VisitVerificationState(
      isVerifying: isVerifying ?? this.isVerifying,
      verificationResult: verificationResult ?? this.verificationResult,
      error: error,
      isWithinRange: isWithinRange ?? this.isWithinRange,
      distance: distance ?? this.distance,
    );
  }
}

// Visit verification notifier
class VisitVerificationNotifier extends StateNotifier<VisitVerificationState> {
  final LocationService _locationService;
  final PlaceService _placeService;

  VisitVerificationNotifier({
    required LocationService locationService,
    required PlaceService placeService,
  }) : _locationService = locationService,
       _placeService = placeService,
       super(const VisitVerificationState());

  Future<void> checkLocationForPlace({
    required String projectCode,
    required String placeId,
    required double placeLat,
    required double placeLon,
  }) async {
    state = state.copyWith(isVerifying: true, error: null);

    try {
      final position = await _locationService.getAccurateLocation();
      if (position == null) {
        state = state.copyWith(
          isVerifying: false,
          error: 'Unable to get location',
        );
        return;
      }

      final distance = _locationService.calculateDistance(
        position.latitude, position.longitude,
        placeLat, placeLon,
      );

      final isWithinRange = _locationService.isWithinVisitRange(
        position, placeLat, placeLon,
      );

      state = state.copyWith(
        isVerifying: false,
        isWithinRange: isWithinRange,
        distance: distance,
      );
    } catch (e) {
      state = state.copyWith(
        isVerifying: false,
        error: e.toString(),
      );
    }
  }

  Future<bool> verifyPlaceVisit({
    required String projectCode,
    required String placeId,
  }) async {
    state = state.copyWith(isVerifying: true, error: null);

    try {
      final position = await _locationService.getAccurateLocation();
      if (position == null) {
        state = state.copyWith(
          isVerifying: false,
          error: 'Unable to get location',
        );
        return false;
      }

      final verificationRequest = await _locationService.createVerificationRequest(
        position,
        placeId: placeId,
      );

      if (verificationRequest == null) {
        state = state.copyWith(
          isVerifying: false,
          error: 'Failed to create verification request',
        );
        return false;
      }

      final result = await _placeService.verifyVisit(
        projectId: projectCode,
        placeId: placeId,
        token: verificationRequest.token,
      );

      state = state.copyWith(
        isVerifying: false,
        verificationResult: result,
        isWithinRange: result.result == 'VERIFIED',
        distance: result.distanceM ?? state.distance,
      );

      return result.result == 'VERIFIED';
    } catch (e) {
      state = state.copyWith(
        isVerifying: false,
        error: e.toString(),
      );
      return false;
    }
  }

  void clearResults() {
    state = const VisitVerificationState();
  }
}
