# ADR-20251211: Platform-Specific Map Integration for Places Tab

## Status
Implemented

## Context
The Girls Band Travel Info app needed platform-specific map integration for the Places tab to provide native map experiences on different platforms. The requirement specified using Apple Maps for iOS and Google Maps for Android to ensure optimal user experience and performance.

## Decision
We implemented a comprehensive platform-specific map integration with the following architecture:

### 1. Clean Architecture Implementation
- **Domain Layer**: Place entities, MapBounds, LatLng value objects, and PlacesRepository interface
- **Data Layer**: PlaceDto models, PlacesRemoteDataSource, and PlacesRepositoryImpl
- **Application Layer**: PlacesController with Riverpod state management
- **Presentation Layer**: Platform-specific widgets, screens, and UI components

### 2. Platform-Specific Map Widget
Created `PlatformMapWidget` that:
- Uses Apple Maps (`apple_maps_flutter`) on iOS
- Uses Google Maps (`google_maps_flutter`) on Android
- Provides unified interface for both platforms
- Handles markers, camera movement, and user interactions

### 3. Core Features Implemented
- **PlaceMapScreen**: Main map screen with search, markers, and bottom sheet
- **PlaceDetailScreen**: Detailed view with image gallery, map snippet, and check-in
- **Search Functionality**: Real-time place search with autocomplete
- **Location Services**: Current location detection with proper permission handling
- **Visit Check-in**: Location-based visit verification system

### 4. API Integration
Integrated with REST endpoints:
- `GET /api/v1/projects/{projectId}/places/within-bounds`
- `GET /api/v1/projects/{projectId}/places/nearby`
- `GET /api/v1/search/places`
- `POST /api/v1/places/{placeId}/checkin`
- `POST /api/v1/places/{placeId}/favorite`

### 5. State Management
- Used Riverpod for dependency injection and state management
- Implemented PlacesController with proper error handling
- Separated loading states for different operations (search, location, data loading)

### 6. Error Handling & Permissions
- Comprehensive location permission handling
- Graceful error states with user-friendly messages
- Offline support considerations

## Implementation Details

### File Structure
```
lib/
├── features/places/
│   ├── domain/
│   │   ├── entities/
│   │   │   ├── place.dart
│   │   │   └── map_bounds.dart
│   │   └── repositories/
│   │       └── places_repository.dart
│   ├── data/
│   │   ├── models/
│   │   │   └── place_dto.dart
│   │   ├── datasources/
│   │   │   └── places_remote_datasource.dart
│   │   └── repositories/
│   │       └── places_repository_impl.dart
│   ├── application/
│   │   ├── controllers/
│   │   │   └── places_controller.dart
│   │   └── providers/
│   │       └── places_providers.dart
│   └── presentation/
│       ├── pages/
│       │   ├── place_map_screen.dart
│       │   └── place_detail_screen.dart
│       └── widgets/
│           ├── platform_map_widget.dart
│           ├── place_search_bar.dart
│           └── places_bottom_sheet.dart
├── core/
│   ├── services/
│   │   └── location_service.dart
│   ├── routing/
│   │   └── app_router.dart
│   └── theme/
│       └── app_theme.dart
```

### Key Components

#### PlatformMapWidget
- Platform detection using `Platform.isIOS`
- Unified callback interface for both map types
- Automatic bounds calculation for camera movements
- Marker management with place data

#### PlacesController
- Riverpod StateNotifier for state management
- Separate loading states for different operations
- Error handling with typed exceptions
- Efficient state updates with immutable data

#### LocationService
- Geolocator integration for location services
- Custom exception hierarchy for better error handling
- Permission request flow with proper UX guidance
- Distance calculation utilities

### Testing
Implemented comprehensive tests:
- Unit tests for Place entity and LocationService
- Widget tests for PlatformMapWidget
- Proper mocking strategies for platform dependencies

## Consequences

### Positive
- Native map experience on each platform
- Clean separation of concerns with testable architecture
- Comprehensive error handling and user guidance
- Scalable state management with Riverpod
- Good test coverage for core functionality

### Negative
- Increased complexity due to platform-specific implementations
- Dependency on multiple map SDKs
- Potential maintenance overhead for two map implementations

### Technical Debt
- Need to complete Freezed code generation for some models
- Some existing codebase issues need resolution
- Localization strings need to be externalized

## Monitoring
- Track map performance metrics on both platforms
- Monitor location permission grant rates
- Measure search query performance and accuracy
- Track place check-in success rates

## Future Considerations
- Add offline map caching capabilities
- Implement map clustering for performance with large datasets
- Add custom map styling to match app branding
- Consider adding route planning features
- Implement push notifications for nearby places

## Dependencies
- `google_maps_flutter: ^2.14.0`
- `apple_maps_flutter: ^1.4.0`
- `geolocator: ^12.0.0`
- `permission_handler: ^11.3.1`
- `flutter_riverpod: ^2.5.1`
- `cached_network_image: ^3.3.1`