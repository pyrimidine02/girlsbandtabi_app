/// EN: Places map page with map view and bottom sheet list
/// KO: 지도 뷰와 바텀시트 리스트를 포함한 장소 지도 페이지
library;

import 'package:apple_maps_flutter/apple_maps_flutter.dart' as amaps;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import '../../../../core/error/failure.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/gbt_colors.dart';
import '../../../../core/theme/gbt_spacing.dart';
import '../../../../core/theme/gbt_typography.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/widgets/cards/gbt_place_card.dart';
import '../../../../core/widgets/feedback/gbt_loading.dart';
import '../../../../core/widgets/inputs/gbt_search_bar.dart';
import '../../../projects/application/projects_controller.dart';
import '../../../projects/domain/entities/project_entities.dart';
import '../../../projects/presentation/widgets/band_filter_sheet.dart';
import '../../../projects/presentation/widgets/project_selector.dart';
import '../../application/places_controller.dart';
import '../../domain/entities/place_entities.dart';
import '../../domain/entities/place_region_entities.dart';

/// EN: Places map page widget
/// KO: 장소 지도 페이지 위젯
class PlacesMapPage extends ConsumerStatefulWidget {
  const PlacesMapPage({super.key});

  @override
  ConsumerState<PlacesMapPage> createState() => _PlacesMapPageState();
}

class _PlacesMapPageState extends ConsumerState<PlacesMapPage> {
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();
  gmaps.GoogleMapController? _googleMapController;
  amaps.AppleMapController? _appleMapController;
  bool _didCenterOnPlaces = false;
  double _currentZoom = 12;
  double _pendingZoom = 12;

  @override
  void dispose() {
    _sheetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final placesState = ref.watch(placesListControllerProvider);
    final places = placesState.maybeWhen(
      data: (items) => items,
      orElse: () => const <PlaceSummary>[],
    );
    final regionOptionsState = ref.watch(placesRegionOptionsControllerProvider);
    final selectedRegionCodes = ref.watch(selectedPlaceRegionCodesProvider);
    final selectedBandIds = ref.watch(selectedPlaceBandIdsProvider);
    final listMode = ref.watch(placeListModeProvider);
    final projectKey = ref.watch(selectedProjectKeyProvider);
    final projectId = ref.watch(selectedProjectIdProvider);
    final resolvedProjectKey = projectKey?.isNotEmpty == true
        ? projectKey!
        : (projectId ?? '');
    final unitsState = resolvedProjectKey.isNotEmpty
        ? ref.watch(projectUnitsControllerProvider(resolvedProjectKey))
        : const AsyncValue<List<Unit>>.data([]);
    final selectedRegionLabel = _resolveRegionLabel(
      regionOptionsState,
      selectedRegionCodes,
    );
    final selectedBandLabel = _resolveBandLabel(unitsState, selectedBandIds);
    final listModeLabel =
        listMode == PlaceListMode.nearby ? '주변 장소' : '전체 장소';
    final hasActiveFilters =
        selectedRegionCodes.isNotEmpty ||
        selectedBandIds.isNotEmpty ||
        listMode != PlaceListMode.all;
    _maybeCenterOnPlaces(places);

    return Scaffold(
      appBar: AppBar(
        title: const Text('장소'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _refreshPlaces(),
            tooltip: '새로고침',
          ),
          IconButton(
            icon: const Icon(Icons.groups),
            onPressed: () => _showBandFilter(selectedBandIds),
            tooltip: '밴드 선택',
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              _showRegionFilter(regionOptionsState, selectedRegionCodes);
            },
            tooltip: '필터',
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              _showMapSearch(places, regionOptionsState);
            },
            tooltip: '검색',
          ),
        ],
      ),
      body: Stack(
        children: [
          // EN: Map view
          // KO: 지도 뷰
          Positioned.fill(
            child: _PlacesMapView(
              places: places,
              zoom: _currentZoom,
              bottomPadding: MediaQuery.of(context).size.height * 0.35,
              isDarkMode: isDarkMode,
              onAppleMapCreated: (controller) {
                _appleMapController = controller;
                _maybeCenterOnPlaces(places);
              },
              onGoogleMapCreated: (controller) {
                _googleMapController = controller;
                _maybeCenterOnPlaces(places);
              },
              onCameraMove: _handleCameraMove,
              onCameraIdle: _handleCameraIdle,
              onClusterTap: _zoomToCluster,
              onPlaceTap: (place) => context.goToPlaceDetail(place.id),
            ),
          ),
          Positioned(
            top: GBTSpacing.sm,
            left: GBTSpacing.md,
            right: GBTSpacing.md,
            child: SafeArea(
              bottom: false,
              child: Material(
                color: Theme.of(context).colorScheme.surface,
                elevation: 2,
                borderRadius: BorderRadius.circular(GBTSpacing.radiusMd),
                child: Padding(
                  padding: const EdgeInsets.all(GBTSpacing.sm),
                  child: const ProjectSelectorCompact(),
                ),
              ),
            ),
          ),

              // EN: Current location button
              // KO: 현재 위치 버튼
              Positioned(
                right: GBTSpacing.md,
                bottom:
                    MediaQuery.of(context).size.height * 0.4 + GBTSpacing.md,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FloatingActionButton.small(
                      heroTag: 'fit-all',
                      onPressed: () => _fitToPlaces(places),
                      child: const Icon(Icons.zoom_out_map),
                    ),
                    const SizedBox(height: GBTSpacing.sm),
                    FloatingActionButton.small(
                      heroTag: 'location',
                      onPressed: _centerOnCurrentLocation,
                      child: const Icon(Icons.my_location),
                    ),
                  ],
                ),
              ),

              // EN: Bottom sheet with places list
              // KO: 장소 리스트를 포함한 바텀시트
          DraggableScrollableSheet(
            controller: _sheetController,
            initialChildSize: 0.4,
            minChildSize: 0.15,
            maxChildSize: 0.9,
            builder: (context, scrollController) {
              final count = placesState.maybeWhen(
                data: (_) => places.length,
                orElse: () => 0,
              );
              return Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(GBTSpacing.radiusLg),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: CustomScrollView(
                  controller: scrollController,
                  slivers: [
                    SliverToBoxAdapter(
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: Container(
                          margin: const EdgeInsets.only(top: GBTSpacing.sm),
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: GBTColors.border,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(GBTSpacing.md),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              listModeLabel,
                              style: GBTTypography.titleMedium.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  selectedRegionLabel,
                                  style: GBTTypography.labelSmall.copyWith(
                                    color: GBTColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '$count개',
                                  style: GBTTypography.bodySmall.copyWith(
                                    color: GBTColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (hasActiveFilters)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: GBTSpacing.md,
                          ),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                if (listMode != PlaceListMode.all) ...[
                                  InputChip(
                                    label: Text(
                                      listMode == PlaceListMode.nearby
                                          ? '주변'
                                          : '전체',
                                    ),
                                    onDeleted: () {
                                      ref
                                          .read(placeListModeProvider.notifier)
                                          .state = PlaceListMode.all;
                                    },
                                  ),
                                  const SizedBox(width: GBTSpacing.sm),
                                ],
                                if (selectedRegionCodes.isNotEmpty) ...[
                                  InputChip(
                                    label: Text(selectedRegionLabel),
                                    onDeleted: () {
                                      ref
                                          .read(
                                            selectedPlaceRegionCodesProvider
                                                .notifier,
                                          )
                                          .state = [];
                                    },
                                  ),
                                  const SizedBox(width: GBTSpacing.sm),
                                ],
                                if (selectedBandIds.isNotEmpty) ...[
                                  InputChip(
                                    label: Text(selectedBandLabel),
                                    onDeleted: () {
                                      ref
                                          .read(
                                            selectedPlaceBandIdsProvider
                                                .notifier,
                                          )
                                          .state = [];
                                    },
                                  ),
                                  const SizedBox(width: GBTSpacing.sm),
                                ],
                                TextButton(
                                  onPressed: _resetFilters,
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: GBTSpacing.sm,
                                    ),
                                    minimumSize: const Size(0, 32),
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: const Text('초기화'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: GBTSpacing.md,
                        ),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: SegmentedButton<PlaceListMode>(
                            segments: const [
                              ButtonSegment(
                                value: PlaceListMode.nearby,
                                label: Text('주변'),
                              ),
                              ButtonSegment(
                                value: PlaceListMode.all,
                                label: Text('전체'),
                              ),
                            ],
                            selected: {listMode},
                            onSelectionChanged: (selection) {
                              if (selection.isEmpty) return;
                              ref.read(placeListModeProvider.notifier).state =
                                  selection.first;
                            },
                          ),
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(child: Divider(height: 1)),
                    _PlacesSliverList(
                      state: placesState,
                      onRetry: () => ref
                          .read(placesListControllerProvider.notifier)
                          .load(forceRefresh: true),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _maybeCenterOnPlaces(List<PlaceSummary> places) {
    if (_didCenterOnPlaces || places.isEmpty || kIsWeb) return;
    final canMove = _isAppleMap
        ? _appleMapController != null
        : _googleMapController != null;
    if (!canMove) return;
    final target = places.first;
    _moveCameraTo(target.latitude, target.longitude, zoom: 12);
    _didCenterOnPlaces = true;
  }

  void _handleCameraMove(double zoom) {
    _pendingZoom = zoom;
  }

  void _handleCameraIdle() {
    if ((_pendingZoom - _currentZoom).abs() >= 0.3) {
      setState(() => _currentZoom = _pendingZoom);
    }
  }

  Future<void> _centerOnCurrentLocation() async {
    try {
      final locationService = ref.read(locationServiceProvider);
      final snapshot = await locationService.getCurrentLocation();
      _moveCameraTo(snapshot.latitude, snapshot.longitude, zoom: 14);
    } catch (error) {
      final message = error is Failure
          ? error.userMessage
          : '현재 위치를 가져올 수 없습니다';
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  void _moveCameraTo(double latitude, double longitude, {double zoom = 12}) {
    if (kIsWeb) return;
    if (_isAppleMap) {
      _appleMapController?.moveCamera(
        amaps.CameraUpdate.newCameraPosition(
          amaps.CameraPosition(
            target: amaps.LatLng(latitude, longitude),
            zoom: zoom,
          ),
        ),
      );
      return;
    }
    _googleMapController?.animateCamera(
      gmaps.CameraUpdate.newCameraPosition(
        gmaps.CameraPosition(
          target: gmaps.LatLng(latitude, longitude),
          zoom: zoom,
        ),
      ),
    );
  }

  void _fitToPlaces(List<PlaceSummary> places) {
    final bounds = _buildBoundsFromPlaces(places);
    if (bounds == null) return;
    _moveCameraToBounds(bounds);
  }

  RegionMapBounds? _buildBoundsFromPlaces(List<PlaceSummary> places) {
    if (places.isEmpty) return null;
    var minLat = places.first.latitude;
    var maxLat = places.first.latitude;
    var minLng = places.first.longitude;
    var maxLng = places.first.longitude;
    for (final place in places.skip(1)) {
      minLat = minLat < place.latitude ? minLat : place.latitude;
      maxLat = maxLat > place.latitude ? maxLat : place.latitude;
      minLng = minLng < place.longitude ? minLng : place.longitude;
      maxLng = maxLng > place.longitude ? maxLng : place.longitude;
    }
    final centerLat = (minLat + maxLat) / 2;
    final centerLng = (minLng + maxLng) / 2;
    return RegionMapBounds(
      northEast: Coordinate(latitude: maxLat, longitude: maxLng),
      southWest: Coordinate(latitude: minLat, longitude: minLng),
      center: Coordinate(latitude: centerLat, longitude: centerLng),
      zoom: _currentZoom.round(),
    );
  }

  void _showRegionFilter(
    AsyncValue<RegionFilterOptions> optionsState,
    List<String> selectedCodes,
  ) {
    final selected = selectedCodes.isNotEmpty ? selectedCodes.first : null;
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: optionsState.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(GBTSpacing.lg),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, _) {
              final message = error is Failure
                  ? error.userMessage
                  : '지역 정보를 불러오지 못했어요';
              return Padding(
                padding: const EdgeInsets.all(GBTSpacing.lg),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      message,
                      style: GBTTypography.bodyMedium.copyWith(
                        color: GBTColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: GBTSpacing.md),
                    FilledButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        ref
                            .read(
                              placesRegionOptionsControllerProvider.notifier,
                            )
                            .load(forceRefresh: true);
                      },
                      child: const Text('다시 시도'),
                    ),
                  ],
                ),
              );
            },
            data: (options) {
              final optionMap = {
                for (final option in [
                  ...options.popularRegions,
                  ...options.countries,
                ])
                  option.code: option,
              };
              return RadioGroup<String?>(
                groupValue: selected,
                onChanged: (value) {
                  _selectRegion(value == null ? null : optionMap[value]);
                  Navigator.of(context).pop();
                },
                child: ListView(
                  padding: const EdgeInsets.only(bottom: GBTSpacing.md),
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: GBTSpacing.lg,
                        vertical: GBTSpacing.sm,
                      ),
                      child: Text(
                        '지역 필터',
                        style: GBTTypography.titleMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const RadioListTile<String?>(
                      value: null,
                      title: Text('전체'),
                    ),
                    if (options.popularRegions.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: GBTSpacing.lg,
                          vertical: GBTSpacing.xs,
                        ),
                        child: Text(
                          '인기 지역',
                          style: GBTTypography.labelSmall.copyWith(
                            color: GBTColors.textSecondary,
                          ),
                        ),
                      ),
                      ...options.popularRegions.map(
                        (option) => _RegionOptionTile(option: option),
                      ),
                    ],
                    if (options.countries.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: GBTSpacing.lg,
                          vertical: GBTSpacing.xs,
                        ),
                        child: Text(
                          '국가',
                          style: GBTTypography.labelSmall.copyWith(
                            color: GBTColors.textSecondary,
                          ),
                        ),
                      ),
                      ...options.countries.map(
                        (option) => _RegionOptionTile(option: option),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _selectRegion(RegionOption? option) {
    ref
        .read(selectedPlaceRegionCodesProvider.notifier)
        .state = option == null ? [] : [option.code];
    _didCenterOnPlaces = false;
    if (option != null) {
      _moveCameraToRegion(option.code);
    }
  }

  Future<void> _moveCameraToRegion(String regionCode) async {
    final projectKey = ref.read(selectedProjectKeyProvider);
    final projectId = ref.read(selectedProjectIdProvider);
    final resolvedProjectKey = projectKey?.isNotEmpty == true
        ? projectKey!
        : projectId;
    if (resolvedProjectKey == null || resolvedProjectKey.isEmpty) return;

    final repository = await ref.read(placesRepositoryProvider.future);
    var result = await repository.getRegionMapBounds(
      projectId: resolvedProjectKey,
      regionCode: regionCode,
    );
    if (result is Err<RegionMapBounds> &&
        projectId != null &&
        projectId.isNotEmpty &&
        projectId != resolvedProjectKey) {
      result = await repository.getRegionMapBounds(
        projectId: projectId,
        regionCode: regionCode,
      );
    }

    if (result is Success<RegionMapBounds>) {
      _moveCameraToBounds(result.data);
    }
  }

  void _moveCameraToBounds(RegionMapBounds bounds) {
    if (kIsWeb) return;
    const padding = 48.0;
    if (_isAppleMap) {
      _appleMapController?.moveCamera(
        amaps.CameraUpdate.newLatLngBounds(
          amaps.LatLngBounds(
            southwest: amaps.LatLng(
              bounds.southWest.latitude,
              bounds.southWest.longitude,
            ),
            northeast: amaps.LatLng(
              bounds.northEast.latitude,
              bounds.northEast.longitude,
            ),
          ),
          padding,
        ),
      );
      return;
    }
    _googleMapController?.animateCamera(
      gmaps.CameraUpdate.newLatLngBounds(
        gmaps.LatLngBounds(
          southwest: gmaps.LatLng(
            bounds.southWest.latitude,
            bounds.southWest.longitude,
          ),
          northeast: gmaps.LatLng(
            bounds.northEast.latitude,
            bounds.northEast.longitude,
          ),
        ),
        padding,
      ),
    );
  }

  void _zoomToCluster(_MapCluster cluster) {
    if (cluster.places.length == 1) return;
    final bounds = _buildBoundsFromPlaces(cluster.places);
    if (bounds != null) {
      _moveCameraToBounds(bounds);
      return;
    }
    _moveCameraTo(cluster.latitude, cluster.longitude, zoom: _currentZoom + 2);
  }

  void _resetFilters() {
    ref.read(placeListModeProvider.notifier).state = PlaceListMode.all;
    ref.read(selectedPlaceRegionCodesProvider.notifier).state = [];
    ref.read(selectedPlaceBandIdsProvider.notifier).state = [];
  }

  void _showBandFilter(List<String> selectedBandIds) {
    final projectKey = ref.read(selectedProjectKeyProvider);
    final projectId = ref.read(selectedProjectIdProvider);
    final resolvedProjectKey = projectKey?.isNotEmpty == true
        ? projectKey!
        : (projectId ?? '');
    if (resolvedProjectKey.isEmpty) return;

    showBandFilterSheet(
      context: context,
      ref: ref,
      projectKey: resolvedProjectKey,
      selectedBandIds: selectedBandIds,
      onApply: (ids) {
        ref.read(selectedPlaceBandIdsProvider.notifier).state = ids;
      },
    );
  }

  void _refreshPlaces() {
    _didCenterOnPlaces = false;
    ref.read(placesListControllerProvider.notifier).load(forceRefresh: true);
    ref
        .read(placesRegionOptionsControllerProvider.notifier)
        .load(forceRefresh: true);
  }

  void _showMapSearch(
    List<PlaceSummary> places,
    AsyncValue<RegionFilterOptions> regionOptionsState,
  ) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        return _MapSearchSheet(
          places: places,
          regionOptionsState: regionOptionsState,
          onSelectPlace: (place) {
            _moveCameraTo(place.latitude, place.longitude, zoom: 15);
            if (_isAppleMap) {
              _appleMapController?.showMarkerInfoWindow(
                amaps.AnnotationId(place.id),
              );
            } else {
              _googleMapController?.showMarkerInfoWindow(
                gmaps.MarkerId(place.id),
              );
            }
          },
          onSelectRegion: (region) {
            _selectRegion(region);
          },
        );
      },
    );
  }

  String _resolveRegionLabel(
    AsyncValue<RegionFilterOptions> optionsState,
    List<String> selectedCodes,
  ) {
    final selected = selectedCodes.isNotEmpty ? selectedCodes.first : null;
    if (selected == null || selected.isEmpty) {
      return '전체 지역';
    }
    return optionsState.maybeWhen(
      data: (options) {
        for (final option in [
          ...options.popularRegions,
          ...options.countries,
        ]) {
          if (option.code == selected) {
            return option.name;
          }
        }
        return '선택한 지역';
      },
      orElse: () => '선택한 지역',
    );
  }

  String _resolveBandLabel(
    AsyncValue<List<Unit>> unitsState,
    List<String> selectedBandIds,
  ) {
    if (selectedBandIds.isEmpty) {
      return '전체 밴드';
    }

    return unitsState.maybeWhen(
      data: (units) {
        final names = units
            .where((unit) => selectedBandIds.contains(unit.id))
            .map((unit) => unit.code.isNotEmpty ? unit.code : unit.displayName)
            .toList();
        if (names.isEmpty) {
          return '밴드 ${selectedBandIds.length}개';
        }
        if (names.length == 1) {
          return names.first;
        }
        return '${names.first} 외 ${names.length - 1}';
      },
      orElse: () => '밴드 ${selectedBandIds.length}개',
    );
  }

  bool get _isAppleMap =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;
}

class _PlacesSliverList extends StatelessWidget {
  const _PlacesSliverList({
    required this.state,
    required this.onRetry,
  });

  final AsyncValue<List<PlaceSummary>> state;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return state.when(
      loading: () => SliverToBoxAdapter(
        child: Padding(
          padding: GBTSpacing.paddingHorizontalMd,
          child: Column(
            children: const [
              SizedBox(height: GBTSpacing.lg),
              GBTLoading(message: '장소를 불러오는 중...'),
            ],
          ),
        ),
      ),
      error: (error, _) {
        final message = error is Failure
            ? error.userMessage
            : '장소 정보를 불러오지 못했어요';
        return SliverToBoxAdapter(
          child: Padding(
            padding: GBTSpacing.paddingHorizontalMd,
            child: Column(
              children: [
                const SizedBox(height: GBTSpacing.lg),
                GBTErrorState(message: message, onRetry: onRetry),
              ],
            ),
          ),
        );
      },
      data: (places) {
        if (places.isEmpty) {
          return SliverToBoxAdapter(
            child: Padding(
              padding: GBTSpacing.paddingHorizontalMd,
              child: Column(
                children: const [
                  SizedBox(height: GBTSpacing.lg),
                  GBTEmptyState(message: '표시할 장소가 없습니다'),
                ],
              ),
            ),
          );
        }

        return SliverPadding(
          padding: GBTSpacing.paddingHorizontalMd,
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final place = places[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: GBTSpacing.xs),
                  child: GBTPlaceCardHorizontal(
                    name: place.name,
                    location: place.address,
                    imageUrl: place.imageUrl,
                    distance: place.distanceLabel,
                    isVerified: place.isVerified,
                    isFavorite: place.isFavorite,
                    onTap: () => context.goToPlaceDetail(place.id),
                  ),
                );
              },
              childCount: places.length,
            ),
          ),
        );
      },
    );
  }
}

class _PlacesMapView extends StatelessWidget {
  const _PlacesMapView({
    required this.places,
    required this.zoom,
    required this.bottomPadding,
    required this.isDarkMode,
    required this.onAppleMapCreated,
    required this.onGoogleMapCreated,
    required this.onCameraMove,
    required this.onCameraIdle,
    required this.onClusterTap,
    required this.onPlaceTap,
  });

  final List<PlaceSummary> places;
  final double zoom;
  final double bottomPadding;
  final bool isDarkMode;
  final ValueChanged<amaps.AppleMapController> onAppleMapCreated;
  final ValueChanged<gmaps.GoogleMapController> onGoogleMapCreated;
  final ValueChanged<double> onCameraMove;
  final VoidCallback onCameraIdle;
  final ValueChanged<_MapCluster> onClusterTap;
  final ValueChanged<PlaceSummary> onPlaceTap;

  @override
  Widget build(BuildContext context) {
    final route = ModalRoute.of(context);
    final isActiveRoute = route?.isCurrent ?? true;
    if (!isActiveRoute) {
      return const SizedBox.shrink();
    }
    if (kIsWeb) {
      return _MapFallback(
        message: '웹에서는 지도 기능을 지원하지 않습니다',
      );
    }

    final target = _initialTarget(places);
    final clusters = _clusterPlaces(places, zoom);
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return amaps.AppleMap(
        initialCameraPosition: amaps.CameraPosition(
          target: amaps.LatLng(target.latitude, target.longitude),
          zoom: 12,
        ),
        onMapCreated: onAppleMapCreated,
        onCameraMove: (position) => onCameraMove(position.zoom),
        onCameraIdle: onCameraIdle,
        myLocationEnabled: true,
        myLocationButtonEnabled: false,
        compassEnabled: true,
        rotateGesturesEnabled: true,
        scrollGesturesEnabled: true,
        zoomGesturesEnabled: true,
        annotations: _buildAppleAnnotations(clusters, onPlaceTap, onClusterTap),
        padding: EdgeInsets.only(bottom: bottomPadding),
      );
    }

    return gmaps.GoogleMap(
      initialCameraPosition: gmaps.CameraPosition(
        target: gmaps.LatLng(target.latitude, target.longitude),
        zoom: 12,
      ),
      onMapCreated: onGoogleMapCreated,
      onCameraMove: (position) => onCameraMove(position.zoom),
      onCameraIdle: onCameraIdle,
      myLocationEnabled: true,
      myLocationButtonEnabled: false,
      compassEnabled: true,
      zoomControlsEnabled: false,
      style: isDarkMode ? _darkMapStyle : null,
      markers: _buildGoogleMarkers(clusters, onPlaceTap, onClusterTap),
      padding: EdgeInsets.only(bottom: bottomPadding),
    );
  }

  _MapTarget _initialTarget(List<PlaceSummary> places) {
    if (places.isNotEmpty) {
      final place = places.first;
      return _MapTarget(place.latitude, place.longitude);
    }
    return const _MapTarget(35.681236, 139.767125);
  }

  Set<gmaps.Marker> _buildGoogleMarkers(
    List<_MapCluster> clusters,
    ValueChanged<PlaceSummary> onPlaceTap,
    ValueChanged<_MapCluster> onClusterTap,
  ) {
    return clusters
        .map(
          (cluster) => gmaps.Marker(
            markerId: gmaps.MarkerId(cluster.markerId),
            position: gmaps.LatLng(cluster.latitude, cluster.longitude),
            infoWindow: gmaps.InfoWindow(title: cluster.title),
            icon: cluster.isCluster
                ? gmaps.BitmapDescriptor.defaultMarkerWithHue(
                    gmaps.BitmapDescriptor.hueOrange,
                  )
                : gmaps.BitmapDescriptor.defaultMarker,
            onTap: () {
              if (cluster.isCluster) {
                onClusterTap(cluster);
              } else {
                onPlaceTap(cluster.places.first);
              }
            },
          ),
        )
        .toSet();
  }

  Set<amaps.Annotation> _buildAppleAnnotations(
    List<_MapCluster> clusters,
    ValueChanged<PlaceSummary> onPlaceTap,
    ValueChanged<_MapCluster> onClusterTap,
  ) {
    return clusters
        .map(
          (cluster) => amaps.Annotation(
            annotationId: amaps.AnnotationId(cluster.markerId),
            position: amaps.LatLng(cluster.latitude, cluster.longitude),
            infoWindow: amaps.InfoWindow(title: cluster.title),
            onTap: () {
              if (cluster.isCluster) {
                onClusterTap(cluster);
              } else {
                onPlaceTap(cluster.places.first);
              }
            },
          ),
        )
        .toSet();
  }
}

const String _darkMapStyle = '''
[
  {"elementType":"geometry","stylers":[{"color":"#1f1f1f"}]},
  {"elementType":"labels.icon","stylers":[{"visibility":"off"}]},
  {"elementType":"labels.text.fill","stylers":[{"color":"#8a8a8a"}]},
  {"elementType":"labels.text.stroke","stylers":[{"color":"#1f1f1f"}]},
  {"featureType":"administrative","elementType":"geometry","stylers":[{"color":"#2f2f2f"}]},
  {"featureType":"poi","elementType":"geometry","stylers":[{"color":"#262626"}]},
  {"featureType":"poi.park","elementType":"geometry","stylers":[{"color":"#1e2b20"}]},
  {"featureType":"road","elementType":"geometry","stylers":[{"color":"#2b2b2b"}]},
  {"featureType":"road","elementType":"geometry.stroke","stylers":[{"color":"#1a1a1a"}]},
  {"featureType":"road.highway","elementType":"geometry","stylers":[{"color":"#3a3a3a"}]},
  {"featureType":"water","elementType":"geometry","stylers":[{"color":"#0f1b2a"}]},
  {"featureType":"transit.station","elementType":"labels.text.fill","stylers":[{"color":"#8a8a8a"}]}
]
''';

class _MapFallback extends StatelessWidget {
  const _MapFallback({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: GBTColors.surfaceVariant,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.map, size: 64, color: GBTColors.textTertiary),
            const SizedBox(height: GBTSpacing.md),
            Text(
              message,
              style: GBTTypography.bodyMedium.copyWith(
                color: GBTColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _MapTarget {
  const _MapTarget(this.latitude, this.longitude);

  final double latitude;
  final double longitude;
}

class _RegionOptionTile extends StatelessWidget {
  const _RegionOptionTile({required this.option});

  final RegionOption option;

  @override
  Widget build(BuildContext context) {
    return RadioListTile<String?>(
      value: option.code,
      title: Text(option.name),
      subtitle: Text(
        '장소 ${option.placeCount}개',
        style: GBTTypography.labelSmall.copyWith(
          color: GBTColors.textTertiary,
        ),
      ),
    );
  }
}

class _MapSearchSheet extends StatefulWidget {
  const _MapSearchSheet({
    required this.places,
    required this.regionOptionsState,
    required this.onSelectPlace,
    required this.onSelectRegion,
  });

  final List<PlaceSummary> places;
  final AsyncValue<RegionFilterOptions> regionOptionsState;
  final ValueChanged<PlaceSummary> onSelectPlace;
  final ValueChanged<RegionOption> onSelectRegion;

  @override
  State<_MapSearchSheet> createState() => _MapSearchSheetState();
}

class _MapSearchSheetState extends State<_MapSearchSheet> {
  final TextEditingController _controller = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _query.trim().toLowerCase();
    final placeResults = query.isEmpty
        ? <PlaceSummary>[]
        : widget.places
            .where(
              (place) =>
                  place.name.toLowerCase().contains(query) ||
                  place.address.toLowerCase().contains(query),
            )
            .take(30)
            .toList();

    final regionResults = widget.regionOptionsState.maybeWhen(
      data: (options) {
        if (query.isEmpty) return <RegionOption>[];
        final all = [
          ...options.popularRegions,
          ...options.countries,
        ];
        return all
            .where((option) => option.name.toLowerCase().contains(query))
            .take(30)
            .toList();
      },
      orElse: () => <RegionOption>[],
    );

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: GBTSpacing.md,
          right: GBTSpacing.md,
          bottom: MediaQuery.of(context).viewInsets.bottom + GBTSpacing.md,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GBTSearchBar(
              controller: _controller,
              hint: '장소/지역 검색',
              autofocus: true,
              onChanged: (value) {
                setState(() => _query = value);
              },
              onClear: () => setState(() => _query = ''),
            ),
            const SizedBox(height: GBTSpacing.md),
            if (widget.regionOptionsState.isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: GBTSpacing.md),
                child: CircularProgressIndicator(),
              )
            else if (query.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: GBTSpacing.md),
                child: Text(
                  '지역 또는 장소 이름을 입력하세요',
                  style: GBTTypography.bodyMedium.copyWith(
                    color: GBTColors.textSecondary,
                  ),
                ),
              )
            else ...[
              if (regionResults.isNotEmpty) ...[
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '지역',
                    style: GBTTypography.labelMedium.copyWith(
                      color: GBTColors.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(height: GBTSpacing.xs),
                ...regionResults.map(
                  (option) => ListTile(
                    title: Text(option.name),
                    subtitle: Text('장소 ${option.placeCount}개'),
                    onTap: () {
                      widget.onSelectRegion(option);
                      Navigator.of(context).pop();
                    },
                  ),
                ),
                const SizedBox(height: GBTSpacing.sm),
              ],
              if (placeResults.isNotEmpty) ...[
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '장소',
                    style: GBTTypography.labelMedium.copyWith(
                      color: GBTColors.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(height: GBTSpacing.xs),
                ...placeResults.map(
                  (place) => ListTile(
                    title: Text(place.name),
                    subtitle: Text(place.address),
                    onTap: () {
                      widget.onSelectPlace(place);
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ],
              if (regionResults.isEmpty && placeResults.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: GBTSpacing.md),
                  child: Text(
                    '검색 결과가 없습니다',
                    style: GBTTypography.bodyMedium.copyWith(
                      color: GBTColors.textSecondary,
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MapCluster {
  const _MapCluster({
    required this.places,
    required this.latitude,
    required this.longitude,
    required this.markerId,
  });

  final List<PlaceSummary> places;
  final double latitude;
  final double longitude;
  final String markerId;

  bool get isCluster => places.length > 1;

  String get title =>
      isCluster ? '${places.length}곳' : places.first.name;
}

List<_MapCluster> _clusterPlaces(List<PlaceSummary> places, double zoom) {
  if (places.isEmpty) return const [];
  final grid = _clusterGridSize(zoom);
  if (grid <= 0) {
    return places
        .map(
          (place) => _MapCluster(
            places: [place],
            latitude: place.latitude,
            longitude: place.longitude,
            markerId: place.id,
          ),
        )
        .toList();
  }

  final buckets = <String, List<PlaceSummary>>{};
  for (final place in places) {
    final latKey = (place.latitude / grid).round();
    final lngKey = (place.longitude / grid).round();
    final key = '$latKey:$lngKey';
    buckets.putIfAbsent(key, () => <PlaceSummary>[]).add(place);
  }

  final clusters = <_MapCluster>[];
  var index = 0;
  for (final entry in buckets.entries) {
    final group = entry.value;
    if (group.length == 1) {
      final place = group.first;
      clusters.add(
        _MapCluster(
          places: group,
          latitude: place.latitude,
          longitude: place.longitude,
          markerId: place.id,
        ),
      );
      continue;
    }
    final averageLat =
        group.map((place) => place.latitude).reduce((a, b) => a + b) /
        group.length;
    final averageLng =
        group.map((place) => place.longitude).reduce((a, b) => a + b) /
        group.length;
    clusters.add(
      _MapCluster(
        places: group,
        latitude: averageLat,
        longitude: averageLng,
        markerId: 'cluster_${index++}',
      ),
    );
  }
  return clusters;
}

double _clusterGridSize(double zoom) {
  if (zoom >= 15) return 0;
  if (zoom >= 13) return 0.01;
  if (zoom >= 11) return 0.02;
  if (zoom >= 9) return 0.05;
  return 0.1;
}
