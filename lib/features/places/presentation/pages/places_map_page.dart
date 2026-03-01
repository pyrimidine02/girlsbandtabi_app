/// EN: Places map page with map view and bottom sheet list
/// KO: 지도 뷰와 바텀시트 리스트를 포함한 장소 지도 페이지
library;

import 'dart:async';
import 'dart:math' as math;

import 'package:apple_maps_flutter/apple_maps_flutter.dart' as amaps;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import '../../../../core/widgets/common/themed_builder.dart';
import '../../../../core/widgets/feedback/gbt_loading.dart';
import '../../../../core/widgets/inputs/gbt_search_bar.dart';
import '../../../../core/widgets/layout/gbt_page_intro_card.dart';
import '../../../../core/widgets/navigation/gbt_profile_action.dart';
import '../../../projects/application/projects_controller.dart';
import '../../../projects/domain/entities/project_entities.dart';
import '../../../projects/presentation/widgets/band_filter_sheet.dart';
import '../../../projects/presentation/widgets/project_selector.dart';
import '../../application/places_controller.dart';
import '../../domain/entities/place_entities.dart';
import '../../domain/entities/place_region_entities.dart';
import '../../domain/utils/place_marker_style.dart';
import '../../domain/utils/place_type_search.dart';

/// EN: Places map page widget
/// KO: 장소 지도 페이지 위젯
class PlacesMapPage extends ConsumerStatefulWidget {
  const PlacesMapPage({super.key});

  @override
  ConsumerState<PlacesMapPage> createState() => _PlacesMapPageState();
}

class _PlacesMapPageState extends ConsumerState<PlacesMapPage> {
  static const double _sheetInitialSize = 0.4;
  static const double _sheetMinSize = 0.15;
  static const double _sheetMaxSize = 0.9;

  final DraggableScrollableController _sheetController =
      DraggableScrollableController();
  gmaps.GoogleMapController? _googleMapController;
  amaps.AppleMapController? _appleMapController;
  bool _didInitialCenter = false;
  double _currentZoom = 12;
  double _pendingZoom = 12;

  // EN: User's current location fetched on init.
  // KO: 초기화 시 가져온 사용자 현재 위치.
  _MapTarget? _userLocation;

  // EN: Place to center on when returning from detail page.
  // KO: 상세 페이지에서 돌아올 때 중앙에 놓을 장소.
  _MapTarget? _pendingCenterTarget;

  @override
  void initState() {
    super.initState();
    _fetchInitialLocation();
  }

  @override
  void dispose() {
    _googleMapController = null;
    _appleMapController = null;
    _sheetController.dispose();
    super.dispose();
  }

  /// EN: Fetches user location on startup and centers map.
  /// KO: 앱 시작 시 사용자 위치를 가져와 지도 중앙에 놓습니다.
  Future<void> _fetchInitialLocation() async {
    try {
      final locationService = ref.read(locationServiceProvider);
      final snapshot = await locationService.getCurrentLocation();
      if (!mounted) return;
      final target = _MapTarget(snapshot.latitude, snapshot.longitude);
      setState(() => _userLocation = target);
      if (!_didInitialCenter) {
        _moveCameraTo(snapshot.latitude, snapshot.longitude, zoom: 14);
        _didInitialCenter = true;
      }
    } catch (_) {
      // EN: Location unavailable; fall back to places-based centering.
      // KO: 위치를 가져올 수 없으면 장소 기반 중심으로 대체합니다.
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final placesState = ref.watch(placesListControllerProvider);
    final rawPlaces = placesState.maybeWhen(
      data: (items) => items,
      orElse: () => const <PlaceSummary>[],
    );
    // EN: Sort places by distance from user (or Tokyo Station fallback).
    // KO: 사용자 위치(또는 도쿄역 폴백) 기준 거리순 정렬.
    final referencePoint =
        _userLocation ?? const _MapTarget(35.681236, 139.767125);
    final places = _sortPlacesByDistance(rawPlaces, referencePoint);
    final regionOptionsState = ref.watch(placesRegionOptionsControllerProvider);
    final selectedRegionCodes = ref.watch(selectedPlaceRegionCodesProvider);
    final selectedBandIds = ref.watch(selectedPlaceBandIdsProvider);
    final listMode = ref.watch(placeListModeProvider);
    final currentNavIndex = ref.watch(currentNavIndexProvider);
    final isTabActive = currentNavIndex == NavIndex.places;
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
    final listModeLabel = listMode == PlaceListMode.nearby ? '주변 장소' : '전체 장소';
    final hasActiveFilters =
        selectedRegionCodes.isNotEmpty ||
        selectedBandIds.isNotEmpty ||
        listMode != PlaceListMode.all;
    // EN: Schedule camera centering after frame to avoid using
    //     a disposed GoogleMapController during build.
    // KO: 빌드 중 dispose된 GoogleMapController 사용을 방지하기 위해
    //     프레임 이후에 카메라 센터링을 예약합니다.
    if (isTabActive) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _maybeCenterOnMap(places);
      });
    }

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
          const GBTProfileAction(),
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
              isTabActive: isTabActive,
              initialTarget: _pendingCenterTarget ?? _userLocation,
              onAppleMapCreated: (controller) {
                _appleMapController = controller;
                _maybeCenterOnMap(places);
              },
              onGoogleMapCreated: (controller) {
                _googleMapController = controller;
                _maybeCenterOnMap(places);
              },
              onCameraMove: _handleCameraMove,
              onCameraIdle: _handleCameraIdle,
              onClusterTap: _zoomToCluster,
              onPlaceTap: _navigateToPlaceDetail,
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
            bottom: MediaQuery.of(context).size.height * 0.4 + GBTSpacing.md,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingActionButton.small(
                  heroTag: 'fit-all',
                  tooltip: '모든 장소 보기',
                  onPressed: () => _fitToPlaces(places),
                  child: const Icon(Icons.zoom_out_map),
                ),
                const SizedBox(height: GBTSpacing.sm),
                FloatingActionButton.small(
                  heroTag: 'location',
                  tooltip: '내 위치로 이동',
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
            initialChildSize: _sheetInitialSize,
            minChildSize: _sheetMinSize,
            maxChildSize: _sheetMaxSize,
            builder: (context, scrollController) {
              final count = placesState.maybeWhen(
                data: (_) => places.length,
                orElse: () => 0,
              );
              return Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(GBTSpacing.radiusLg),
                    topRight: Radius.circular(GBTSpacing.radiusLg),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(
                        alpha: isDarkMode ? 0.4 : 0.1,
                      ),
                      blurRadius: isDarkMode ? 16 : 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                // EN: Single CustomScrollView merges header and list into
                // one scrollable area, preventing RenderFlex overflow when
                // the sheet is at its minimum size.
                // KO: 단일 CustomScrollView로 헤더와 리스트를 하나의 스크롤
                // 영역으로 합쳐 시트가 최소 크기일 때 RenderFlex 오버플로를
                // 방지합니다.
                child: RefreshIndicator(
                  onRefresh: _refreshPlaces,
                  child: CustomScrollView(
                    controller: scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      // ── Header (scrolls with list) ──
                      SliverToBoxAdapter(
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: Container(
                            margin: const EdgeInsets.only(top: GBTSpacing.sm),
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: isDarkMode
                                  ? Colors.white.withValues(alpha: 0.3)
                                  : Colors.black.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(
                            GBTSpacing.md,
                            GBTSpacing.sm,
                            GBTSpacing.md,
                            GBTSpacing.xs,
                          ),
                          child: GBTPageIntroCard(
                            icon: Icons.map_rounded,
                            title: listModeLabel,
                            description: selectedRegionLabel,
                            trailing: _MapCountBadge(
                              count: count,
                              hasActiveFilters: hasActiveFilters,
                            ),
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
                                            .read(
                                              placeListModeProvider.notifier,
                                            )
                                            .state = PlaceListMode
                                            .all;
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
                                                .state =
                                            [];
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
                                                .state =
                                            [];
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
                                      minimumSize: const Size(48, 48),
                                    ),
                                    child: const Text('초기화'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      SliverToBoxAdapter(
                        child: Semantics(
                          label: '장소 목록 모드 선택',
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
                                  ref
                                          .read(placeListModeProvider.notifier)
                                          .state =
                                      selection.first;
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.only(top: GBTSpacing.sm),
                          child: Divider(height: 1),
                        ),
                      ),

                      // ── Place list ──
                      _PlacesSliverList(
                        state: placesState.whenData((_) => places),
                        onRetry: () => ref
                            .read(placesListControllerProvider.notifier)
                            .load(forceRefresh: true),
                        onPlaceTap: _navigateToPlaceDetail,
                        hasActiveFilters: hasActiveFilters,
                        onResetFilters: _resetFilters,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          // EN: Keep a persistent sheet toggle so users can collapse/expand
          // from any scroll position in the list.
          // KO: 목록 스크롤 위치와 관계없이 즉시 내리고/올릴 수 있도록
          // 고정 시트 토글 버튼을 제공합니다.
          AnimatedBuilder(
            animation: _sheetController,
            builder: (context, child) {
              if (!_sheetController.isAttached) {
                return const SizedBox.shrink();
              }

              final isCollapsed = _sheetController.size <= _sheetMinSize + 0.01;
              final bottomInset =
                  MediaQuery.of(context).size.height * _sheetMinSize +
                  GBTSpacing.sm;

              return Positioned(
                right: GBTSpacing.md,
                bottom: bottomInset,
                child: FloatingActionButton.small(
                  heroTag: 'places-sheet-toggle',
                  tooltip: isCollapsed ? '목록 올리기' : '목록 내리기',
                  onPressed: isCollapsed
                      ? _expandPlaceSheet
                      : _collapsePlaceSheet,
                  child: Icon(
                    isCollapsed
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  /// EN: Centers map based on priority: pending target > user location > first place.
  /// KO: 우선순위에 따라 지도 중앙 설정: 대기 타겟 > 사용자 위치 > 첫 장소.
  void _maybeCenterOnMap(List<PlaceSummary> places) {
    if (kIsWeb) return;
    final canMove = _isAppleMap
        ? _appleMapController != null
        : _googleMapController != null;
    if (!canMove) return;

    // EN: Priority 1 — center on place from detail page return.
    // KO: 우선순위 1 — 상세 페이지에서 돌아온 경우 해당 장소 중앙.
    if (_pendingCenterTarget != null) {
      final target = _pendingCenterTarget!;
      _pendingCenterTarget = null;
      _moveCameraTo(target.latitude, target.longitude, zoom: 15);
      return;
    }

    if (_didInitialCenter) return;

    // EN: Priority 2 — center on user's current location.
    // KO: 우선순위 2 — 사용자 현재 위치 중앙.
    if (_userLocation != null) {
      _moveCameraTo(
        _userLocation!.latitude,
        _userLocation!.longitude,
        zoom: 14,
      );
      _didInitialCenter = true;
      return;
    }

    // EN: Priority 3 — center on Tokyo Station as default.
    // KO: 우선순위 3 — 기본값으로 도쿄역 중앙.
    _moveCameraTo(35.681236, 139.767125, zoom: 12);
    _didInitialCenter = true;
  }

  void _handleCameraMove(double zoom) {
    _pendingZoom = zoom;
  }

  void _handleCameraIdle() {
    if ((_pendingZoom - _currentZoom).abs() >= 0.3) {
      setState(() => _currentZoom = _pendingZoom);
    }
  }

  /// EN: Saves place coordinates and navigates to detail page.
  /// KO: 장소 좌표를 저장하고 상세 페이지로 이동합니다.
  void _navigateToPlaceDetail(PlaceSummary place) {
    _pendingCenterTarget = _MapTarget(place.latitude, place.longitude);
    context.goToPlaceDetail(place.id);
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  void _moveCameraTo(double latitude, double longitude, {double zoom = 12}) {
    if (kIsWeb || !mounted) return;
    if (_isAppleMap) {
      final controller = _appleMapController;
      if (controller == null) return;
      unawaited(
        _safeAppleMapCall(
          () => controller.moveCamera(
            amaps.CameraUpdate.newCameraPosition(
              amaps.CameraPosition(
                target: amaps.LatLng(latitude, longitude),
                zoom: zoom,
              ),
            ),
          ),
        ),
      );
      return;
    }
    final controller = _googleMapController;
    if (controller == null) return;
    unawaited(
      _safeGoogleMapCall(
        () => controller.animateCamera(
          gmaps.CameraUpdate.newCameraPosition(
            gmaps.CameraPosition(
              target: gmaps.LatLng(latitude, longitude),
              zoom: zoom,
            ),
          ),
        ),
      ),
    );
  }

  /// EN: Collapses the place list sheet to minimum height.
  /// KO: 장소 목록 시트를 최소 높이까지 내립니다.
  Future<void> _collapsePlaceSheet() async {
    if (!_sheetController.isAttached) {
      return;
    }
    await _sheetController.animateTo(
      _sheetMinSize,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
    );
  }

  /// EN: Expands the place list sheet to the default height.
  /// KO: 장소 목록 시트를 기본 높이로 다시 올립니다.
  Future<void> _expandPlaceSheet() async {
    if (!_sheetController.isAttached) {
      return;
    }
    await _sheetController.animateTo(
      _sheetInitialSize,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _showPlaceInfoWindow(String placeId) async {
    if (kIsWeb || !mounted) return;
    if (_isAppleMap) {
      final controller = _appleMapController;
      if (controller == null) return;
      await _safeAppleMapCall(
        () => controller.showMarkerInfoWindow(amaps.AnnotationId(placeId)),
      );
      return;
    }
    final controller = _googleMapController;
    if (controller == null) return;
    await _safeGoogleMapCall(
      () => controller.showMarkerInfoWindow(gmaps.MarkerId(placeId)),
    );
  }

  Future<void> _safeAppleMapCall(Future<void> Function() call) async {
    try {
      await call();
    } on MissingPluginException {
      _appleMapController = null;
    }
  }

  Future<void> _safeGoogleMapCall(Future<void> Function() call) async {
    try {
      await call();
    } on MissingPluginException {
      _googleMapController = null;
    }
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
              final sheetIsDark =
                  Theme.of(context).brightness == Brightness.dark;
              return Padding(
                padding: const EdgeInsets.all(GBTSpacing.lg),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      message,
                      style: GBTTypography.bodyMedium.copyWith(
                        color: sheetIsDark
                            ? GBTColors.darkTextSecondary
                            : GBTColors.textSecondary,
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
                      // EN: Use context extension instead of Builder for theme
                      // KO: Builder 대신 context 확장을 사용하여 테마 접근
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: GBTSpacing.lg,
                          vertical: GBTSpacing.xs,
                        ),
                        child: Text(
                          '인기 지역',
                          style: GBTTypography.labelSmall.copyWith(
                            color: context.textSecondary,
                          ),
                        ),
                      ),
                      ...options.popularRegions.map(
                        (option) => _RegionOptionTile(option: option),
                      ),
                    ],
                    if (options.countries.isNotEmpty) ...[
                      // EN: Use context extension instead of Builder for theme
                      // KO: Builder 대신 context 확장을 사용하여 테마 접근
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: GBTSpacing.lg,
                          vertical: GBTSpacing.xs,
                        ),
                        child: Text(
                          '국가',
                          style: GBTTypography.labelSmall.copyWith(
                            color: context.textSecondary,
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
    ref.read(selectedPlaceRegionCodesProvider.notifier).state = option == null
        ? []
        : [option.code];
    _didInitialCenter = false;
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
    if (kIsWeb || !mounted) return;
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

  Future<void> _refreshPlaces() async {
    _didInitialCenter = false;
    await Future.wait([
      ref.read(placesListControllerProvider.notifier).load(forceRefresh: true),
      ref
          .read(placesRegionOptionsControllerProvider.notifier)
          .load(forceRefresh: true),
    ]);
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
            unawaited(_showPlaceInfoWindow(place.id));
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

class _MapCountBadge extends StatelessWidget {
  const _MapCountBadge({required this.count, required this.hasActiveFilters});

  final int count;
  final bool hasActiveFilters;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? GBTColors.darkSurface : GBTColors.surfaceVariant;
    final fg = isDark ? GBTColors.darkTextSecondary : GBTColors.textSecondary;
    final label = hasActiveFilters ? '필터 $count개' : '총 $count개';

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: GBTSpacing.sm,
        vertical: GBTSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(GBTSpacing.radiusFull),
      ),
      child: Text(
        label,
        style: GBTTypography.labelSmall.copyWith(
          color: fg,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _PlacesSliverList extends StatelessWidget {
  const _PlacesSliverList({
    required this.state,
    required this.onRetry,
    required this.onPlaceTap,
    this.hasActiveFilters = false,
    this.onResetFilters,
  });

  final AsyncValue<List<PlaceSummary>> state;
  final VoidCallback onRetry;
  final ValueChanged<PlaceSummary> onPlaceTap;
  final bool hasActiveFilters;
  final VoidCallback? onResetFilters;

  @override
  Widget build(BuildContext context) {
    return state.when(
      loading: () => const SliverToBoxAdapter(
        child: Padding(
          padding: GBTSpacing.paddingHorizontalMd,
          child: Column(
            children: [
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
                children: [
                  const SizedBox(height: GBTSpacing.lg),
                  GBTEmptyState(
                    message: hasActiveFilters
                        ? '선택한 조건에 맞는 장소가 없습니다'
                        : '표시할 장소가 없습니다',
                  ),
                  if (hasActiveFilters && onResetFilters != null) ...[
                    const SizedBox(height: GBTSpacing.md),
                    TextButton(
                      onPressed: onResetFilters,
                      child: const Text('필터 초기화'),
                    ),
                  ],
                ],
              ),
            ),
          );
        }

        return SliverPadding(
          padding: GBTSpacing.paddingHorizontalMd,
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final place = places[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: GBTSpacing.sm),
                child: GBTPlaceCardHorizontal(
                  name: place.name,
                  location: place.address,
                  imageUrl: place.imageUrl,
                  distance: place.distanceLabel,
                  typeLabels: _placeTypeLabels(place.types),
                  tagLabels: _placeTagLabels(place.tags),
                  isVerified: place.isVerified,
                  isFavorite: place.isFavorite,
                  onTap: () => onPlaceTap(place),
                ),
              );
            }, childCount: places.length),
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
    required this.isTabActive,
    required this.onAppleMapCreated,
    required this.onGoogleMapCreated,
    required this.onCameraMove,
    required this.onCameraIdle,
    required this.onClusterTap,
    required this.onPlaceTap,
    this.initialTarget,
  });

  final List<PlaceSummary> places;
  final double zoom;
  final double bottomPadding;
  final bool isDarkMode;
  final bool isTabActive;
  final ValueChanged<amaps.AppleMapController> onAppleMapCreated;
  final ValueChanged<gmaps.GoogleMapController> onGoogleMapCreated;
  final ValueChanged<double> onCameraMove;
  final VoidCallback onCameraIdle;
  final ValueChanged<_MapCluster> onClusterTap;
  final ValueChanged<PlaceSummary> onPlaceTap;

  /// EN: Optional override for the initial camera target.
  /// KO: 초기 카메라 타겟 오버라이드 (선택적).
  final _MapTarget? initialTarget;

  @override
  Widget build(BuildContext context) {
    if (!isTabActive) {
      return const SizedBox.shrink();
    }
    final route = ModalRoute.of(context);
    // EN: Keep map alive while popup routes (bottom sheets/dialogs) are shown.
    // KO: 바텀시트/다이얼로그 같은 팝업 라우트 표시 중에는 지도를 유지합니다.
    final isOffstageRoute = route?.offstage ?? false;
    if (isOffstageRoute) {
      return const SizedBox.shrink();
    }
    if (kIsWeb) {
      return _MapFallback(message: '웹에서는 지도 기능을 지원하지 않습니다');
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
    if (initialTarget != null) return initialTarget!;
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
                : gmaps.BitmapDescriptor.defaultMarkerWithHue(
                    placeMarkerHueFromFirstType(cluster.places.first.types),
                  ),
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
            icon: cluster.isCluster
                ? amaps.BitmapDescriptor.defaultAnnotationWithHue(
                    amaps.BitmapDescriptor.hueOrange,
                  )
                : amaps.BitmapDescriptor.defaultAnnotationWithHue(
                    placeMarkerHueFromFirstType(cluster.places.first.types),
                  ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      color: isDark ? GBTColors.darkSurfaceVariant : GBTColors.surfaceVariant,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.map,
              size: 64,
              color: isDark
                  ? GBTColors.darkTextTertiary
                  : GBTColors.textTertiary,
            ),
            const SizedBox(height: GBTSpacing.md),
            Text(
              message,
              style: GBTTypography.bodyMedium.copyWith(
                color: isDark
                    ? GBTColors.darkTextSecondary
                    : GBTColors.textSecondary,
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
    // EN: Use context extension for efficient theme access
    // KO: 효율적인 테마 접근을 위해 context 확장 사용
    return RadioListTile<String?>(
      value: option.code,
      title: Text(option.name),
      subtitle: Text(
        '장소 ${option.placeCount}개',
        style: GBTTypography.labelSmall.copyWith(color: context.textTertiary),
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

  bool _matchesPlaceQuery(PlaceSummary place, String query) {
    return normalizedContains(place.name, query) ||
        normalizedContains(place.address, query) ||
        matchesPlaceTypeQuery(query: query, types: place.types);
  }

  String _placeSubtitle(PlaceSummary place) {
    final typeLabels = place.types
        .map(placeTypeLabel)
        .where((label) => label.isNotEmpty)
        .take(2)
        .toList();
    final tagLabels = place.tags
        .where((tag) => tag.trim().isNotEmpty)
        .take(2)
        .map((tag) => '#${tag.trim()}')
        .toList();
    final labels = [...typeLabels, ...tagLabels];
    if (labels.isEmpty) {
      return place.address;
    }
    return '${place.address} · ${labels.join(', ')}';
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondaryColor = isDark
        ? GBTColors.darkTextSecondary
        : GBTColors.textSecondary;
    final query = _query.trim();
    final placeResults = query.isEmpty
        ? <PlaceSummary>[]
        : widget.places
              .where((place) => _matchesPlaceQuery(place, query))
              .take(30)
              .toList();

    final regionResults = widget.regionOptionsState.maybeWhen(
      data: (options) {
        if (query.isEmpty) return <RegionOption>[];
        final all = [...options.popularRegions, ...options.countries];
        return all
            .where((option) => normalizedContains(option.name, query))
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
              hint: '장소/유형/지역 검색',
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
                  '지역, 장소 이름, 장소 유형을 입력하세요',
                  style: GBTTypography.bodyMedium.copyWith(
                    color: secondaryColor,
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
                      color: secondaryColor,
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
                      color: secondaryColor,
                    ),
                  ),
                ),
                const SizedBox(height: GBTSpacing.xs),
                ...placeResults.map(
                  (place) => ListTile(
                    title: Text(place.name),
                    subtitle: Text(_placeSubtitle(place)),
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
                      color: secondaryColor,
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

  String get title => isCluster ? '${places.length}곳' : places.first.name;
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

// ---------------------------------------------------------------------------
// EN: Distance calculation & sorting helpers
// KO: 거리 계산 및 정렬 헬퍼
// ---------------------------------------------------------------------------

double _toRadians(double degrees) => degrees * math.pi / 180;

/// EN: Haversine distance between two coordinates in meters.
/// KO: 두 좌표 사이의 하버사인 거리 (미터).
double _haversineDistance(double lat1, double lon1, double lat2, double lon2) {
  const earthRadius = 6371000.0;
  final dLat = _toRadians(lat2 - lat1);
  final dLon = _toRadians(lon2 - lon1);
  final a =
      math.sin(dLat / 2) * math.sin(dLat / 2) +
      math.cos(_toRadians(lat1)) *
          math.cos(_toRadians(lat2)) *
          math.sin(dLon / 2) *
          math.sin(dLon / 2);
  final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  return earthRadius * c;
}

/// EN: Format meters to human-readable distance label.
/// KO: 미터를 사람이 읽을 수 있는 거리 라벨로 포맷합니다.
String _formatDistance(double meters) {
  if (meters < 1000) {
    return '${meters.round()}m';
  }
  final km = meters / 1000;
  if (km < 10) {
    return '${km.toStringAsFixed(1)}km';
  }
  return '${km.round()}km';
}

/// EN: Sorts places by distance from reference and sets distanceLabel.
/// KO: 기준점으로부터의 거리순 정렬 및 distanceLabel 설정.
List<PlaceSummary> _sortPlacesByDistance(
  List<PlaceSummary> places,
  _MapTarget reference,
) {
  if (places.isEmpty) return places;
  final withDistance = places.map((place) {
    final distance = _haversineDistance(
      reference.latitude,
      reference.longitude,
      place.latitude,
      place.longitude,
    );
    return (place: place, distance: distance);
  }).toList()..sort((a, b) => a.distance.compareTo(b.distance));

  return withDistance
      .map(
        (item) => PlaceSummary(
          id: item.place.id,
          name: item.place.name,
          address: item.place.address,
          latitude: item.place.latitude,
          longitude: item.place.longitude,
          types: item.place.types,
          tags: item.place.tags,
          imageUrl: item.place.imageUrl,
          distanceLabel: _formatDistance(item.distance),
          isVerified: item.place.isVerified,
          isFavorite: item.place.isFavorite,
          rating: item.place.rating,
          regionCode: item.place.regionCode,
          regionName: item.place.regionName,
          regionPath: item.place.regionPath,
        ),
      )
      .toList();
}

List<String> _placeTypeLabels(List<String> types) {
  return types
      .map(placeTypeLabel)
      .where((label) => label.isNotEmpty)
      .take(2)
      .toList(growable: false);
}

List<String> _placeTagLabels(List<String> tags) {
  return tags
      .where((tag) => tag.trim().isNotEmpty)
      .map((tag) => '#${tag.trim()}')
      .take(3)
      .toList(growable: false);
}
