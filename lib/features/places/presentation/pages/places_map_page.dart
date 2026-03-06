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
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import '../../../../core/error/failure.dart';
import '../../../../core/localization/locale_text.dart';
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
import '../../../../core/widgets/navigation/gbt_profile_action.dart';
import '../../../projects/application/projects_controller.dart';
import '../../../projects/domain/entities/project_entities.dart';
import '../../../projects/presentation/widgets/band_filter_sheet.dart';
import '../../../settings/application/settings_controller.dart';
import '../../application/places_controller.dart';
import '../../domain/entities/place_entities.dart';
import '../../domain/entities/place_region_entities.dart';
import '../../domain/utils/place_marker_style.dart';
import '../../domain/utils/place_type_search.dart';
import '../utils/place_directions_launcher.dart';

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
    final currentPath = GoRouterState.of(context).uri.path;
    final isPlacesRoute =
        currentPath == '/places' || currentPath.startsWith('/places/');
    final isTabActive = currentNavIndex == NavIndex.places || isPlacesRoute;
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
    final avatarUrl = ref
        .watch(userProfileControllerProvider)
        .valueOrNull
        ?.avatarUrl;
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
          // EN: Floating top header — Google Maps / Naver Maps style
          // KO: 구글맵/네이버맵 스타일 플로팅 상단 헤더
          Positioned(
            top: 0,
            left: GBTSpacing.md,
            right: GBTSpacing.md,
            child: SafeArea(
              bottom: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: GBTSpacing.xs),
                  // EN: Tappable search card (Google Maps style) — fixed 44px height.
                  //     GBTProfileAction sits beside the card to keep it slim.
                  // KO: 탭 가능한 검색 카드 (구글맵 스타일) — 44px 고정 높이.
                  //     GBTProfileAction을 카드 밖으로 분리해 카드를 슬림하게 유지.
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 44,
                          child: Material(
                            color: isDarkMode
                                ? GBTColors.darkSurface
                                : GBTColors.surface,
                            elevation: 3,
                            shadowColor: Colors.black.withValues(
                              alpha: isDarkMode ? 0.3 : 0.15,
                            ),
                            borderRadius: BorderRadius.circular(
                              GBTSpacing.radiusMd,
                            ),
                            child: InkWell(
                              onTap: () =>
                                  _showMapSearch(places, regionOptionsState),
                              borderRadius: BorderRadius.circular(
                                GBTSpacing.radiusMd,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: GBTSpacing.md,
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.search_rounded,
                                      color: isDarkMode
                                          ? GBTColors.darkTextTertiary
                                          : GBTColors.textTertiary,
                                      size: GBTSpacing.iconSm,
                                    ),
                                    const SizedBox(width: GBTSpacing.sm),
                                    Expanded(
                                      child: Text(
                                        context.l10n(
                                          ko: '장소, 지역 검색',
                                          en: 'Search places, regions',
                                          ja: '場所・地域検索',
                                        ),
                                        style: GBTTypography.bodyMedium
                                            .copyWith(
                                              color: isDarkMode
                                                  ? GBTColors.darkTextTertiary
                                                  : GBTColors.textTertiary,
                                            ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        Icons.refresh_rounded,
                                        size: GBTSpacing.iconSm,
                                        color: isDarkMode
                                            ? GBTColors.darkTextSecondary
                                            : GBTColors.textSecondary,
                                      ),
                                      onPressed: _refreshPlaces,
                                      tooltip: context.l10n(
                                        ko: '새로고침',
                                        en: 'Refresh',
                                        ja: '更新',
                                      ),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(
                                        minWidth: 36,
                                        minHeight: 36,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: GBTSpacing.sm),
                      GBTProfileAction(avatarUrl: avatarUrl),
                    ],
                  ),
                  const SizedBox(height: GBTSpacing.xs),
                  // EN: Compact filter chip row — project · region · band · mode
                  // KO: 컴팩트 필터 칩 행 — 프로젝트 · 지역 · 밴드 · 모드
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _ProjectFilterChip(isDark: isDarkMode),
                        const SizedBox(width: GBTSpacing.xs),
                        _PlaceFilterChip(
                          label: selectedRegionCodes.isEmpty
                              ? context.l10n(ko: '지역', en: 'Region', ja: '地域')
                              : '${context.l10n(ko: "지역", en: "Region", ja: "地域")} · $selectedRegionLabel',
                          isActive: selectedRegionCodes.isNotEmpty,
                          isDark: isDarkMode,
                          onTap: () => _showRegionFilter(selectedRegionCodes),
                          onClear: selectedRegionCodes.isNotEmpty
                              ? () => _applyRegions(const [])
                              : null,
                        ),
                        const SizedBox(width: GBTSpacing.xs),
                        _PlaceFilterChip(
                          label: selectedBandIds.isEmpty
                              ? context.l10n(ko: '밴드', en: 'Band', ja: 'バンド')
                              : '${context.l10n(ko: "밴드", en: "Band", ja: "バンド")} · $selectedBandLabel',
                          isActive: selectedBandIds.isNotEmpty,
                          isDark: isDarkMode,
                          onTap: () => _showBandFilter(selectedBandIds),
                          onClear: selectedBandIds.isNotEmpty
                              ? () =>
                                    ref
                                            .read(
                                              selectedPlaceBandIdsProvider
                                                  .notifier,
                                            )
                                            .state =
                                        []
                              : null,
                        ),
                        const SizedBox(width: GBTSpacing.xs),
                        _PlaceModeChip(
                          listMode: listMode,
                          isDark: isDarkMode,
                          onChanged: (mode) =>
                              ref.read(placeListModeProvider.notifier).state =
                                  mode,
                        ),
                      ],
                    ),
                  ),
                ],
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
                  tooltip: context.l10n(
                    ko: '모든 장소 보기',
                    en: 'Show all places',
                    ja: 'すべての場所を見る',
                  ),
                  onPressed: () => _fitToPlaces(places),
                  child: const Icon(Icons.zoom_out_map),
                ),
                const SizedBox(height: GBTSpacing.sm),
                FloatingActionButton.small(
                  heroTag: 'location',
                  tooltip: context.l10n(
                    ko: '내 위치로 이동',
                    en: 'Go to my location',
                    ja: '現在地へ移動',
                  ),
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
            // EN: Snap to defined anchor points for a predictable, fluid feel.
            // KO: 정해진 앵커 포인트에 스냅 — 예측 가능하고 부드러운 조작감.
            snap: true,
            snapSizes: const [_sheetMinSize, _sheetInitialSize, _sheetMaxSize],
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: isDarkMode ? GBTColors.darkSurface : GBTColors.surface,
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
                // EN: CustomScrollView with pinned sticky header so the count
                //     label + collapse button stay visible while the list scrolls.
                // KO: SliverPersistentHeader로 헤더를 고정 — 리스트 스크롤 중에도
                //     장소 개수와 닫기 버튼이 항상 보입니다.
                child: RefreshIndicator(
                  onRefresh: _refreshPlaces,
                  child: CustomScrollView(
                    controller: scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      // ── Drag handle (scrolls away with top pull) ──
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: GBTSpacing.sm,
                          ),
                          child: Center(
                            child: Container(
                              width: 36,
                              height: 4,
                              decoration: BoxDecoration(
                                color: isDarkMode
                                    ? Colors.white.withValues(alpha: 0.25)
                                    : Colors.black.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // ── Sticky count header + collapse button ──
                      SliverPersistentHeader(
                        pinned: true,
                        delegate: _SheetStickyHeader(
                          placeCount: places.length,
                          hasActiveFilters: hasActiveFilters,
                          isDark: isDarkMode,
                          onCollapse: _collapsePlaceSheet,
                          onResetFilters: hasActiveFilters
                              ? _resetFilters
                              : null,
                        ),
                      ),

                      // ── Place list ──
                      _PlacesSliverList(
                        state: placesState.whenData((_) => places),
                        onRetry: () => ref
                            .read(placesListControllerProvider.notifier)
                            .load(forceRefresh: true),
                        onPlaceTap: _navigateToPlaceDetail,
                        onDirectionsTap: _showDirectionsForPlace,
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

  Future<void> _showDirectionsForPlace(PlaceSummary place) async {
    final directions = place.directions;
    if (directions == null || !directions.hasProviders) return;
    await showPlaceDirectionsSheet(
      context,
      placeName: place.name,
      directions: directions,
    );
  }

  Future<void> _centerOnCurrentLocation() async {
    try {
      final locationService = ref.read(locationServiceProvider);
      final snapshot = await locationService.getCurrentLocation();
      _moveCameraTo(snapshot.latitude, snapshot.longitude, zoom: 14);
    } catch (error) {
      final message = error is Failure
          ? error.userMessage
          : context.l10n(
              ko: '현재 위치를 가져올 수 없습니다',
              en: 'Unable to get current location',
              ja: '現在地を取得できません',
            );
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

  void _showRegionFilter(List<String> selectedCodes) {
    final projectKey = ref.read(selectedProjectKeyProvider);
    final projectId = ref.read(selectedProjectIdProvider);
    final resolvedProjectKey = projectKey?.isNotEmpty == true
        ? projectKey!
        : projectId;
    if (resolvedProjectKey == null || resolvedProjectKey.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.l10n(
              ko: '프로젝트 선택 후 지역 필터를 사용할 수 있어요',
              en: 'Select a project to use region filters',
              ja: '地域フィルタはプロジェクト選択後に利用できます',
            ),
          ),
        ),
      );
      return;
    }

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _RegionFilterSheet(
        initialSelectedCodes: selectedCodes,
        onApply: _applyRegions,
      ),
    );
  }

  void _applyRegions(List<String> regionCodes) {
    final uniqueCodes = regionCodes.toSet().toList(growable: false);
    ref.read(selectedPlaceRegionCodesProvider.notifier).state = uniqueCodes;
    _didInitialCenter = false;
    if (uniqueCodes.length == 1) {
      _moveCameraToRegion(uniqueCodes.first);
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
    _applyRegions(const <String>[]);
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
            _applyRegions(<String>[region.code]);
          },
        );
      },
    );
  }

  String _resolveRegionLabel(
    AsyncValue<RegionFilterOptions> optionsState,
    List<String> selectedCodes,
  ) {
    if (selectedCodes.isEmpty) {
      return context.l10n(ko: '전체 지역', en: 'All regions', ja: '全地域');
    }
    return optionsState.maybeWhen(
      data: (options) {
        final allOptions = [...options.popularRegions, ...options.countries];
        final names = <String>[];
        final seen = <String>{};
        for (final code in selectedCodes) {
          if (!seen.add(code)) continue;
          final match = allOptions.cast<RegionOption?>().firstWhere(
            (option) => option?.code == code,
            orElse: () => null,
          );
          if (match != null) {
            names.add(match.name);
          }
        }
        if (names.isEmpty) {
          return context.l10n(
            ko: '지역 ${selectedCodes.length}개',
            en: '${selectedCodes.length} regions',
            ja: '地域 ${selectedCodes.length}件',
          );
        }
        if (names.length == 1) {
          return names.first;
        }
        return context.l10n(
          ko: '${names.first} 외 ${names.length - 1}',
          en: '${names.first} + ${names.length - 1} more',
          ja: '${names.first} ほか ${names.length - 1}件',
        );
      },
      orElse: () => context.l10n(
        ko: '지역 ${selectedCodes.length}개',
        en: '${selectedCodes.length} regions',
        ja: '地域 ${selectedCodes.length}件',
      ),
    );
  }

  String _resolveBandLabel(
    AsyncValue<List<Unit>> unitsState,
    List<String> selectedBandIds,
  ) {
    if (selectedBandIds.isEmpty) {
      return context.l10n(ko: '전체 밴드', en: 'All bands', ja: '全バンド');
    }

    return unitsState.maybeWhen(
      data: (units) {
        final names = units
            .where((unit) => selectedBandIds.contains(unit.id))
            .map((unit) => unit.code.isNotEmpty ? unit.code : unit.displayName)
            .toList();
        if (names.isEmpty) {
          return context.l10n(
            ko: '밴드 ${selectedBandIds.length}개',
            en: '${selectedBandIds.length} bands',
            ja: 'バンド ${selectedBandIds.length}件',
          );
        }
        if (names.length == 1) {
          return names.first;
        }
        return context.l10n(
          ko: '${names.first} 외 ${names.length - 1}',
          en: '${names.first} + ${names.length - 1} more',
          ja: '${names.first} ほか ${names.length - 1}件',
        );
      },
      orElse: () => context.l10n(
        ko: '밴드 ${selectedBandIds.length}개',
        en: '${selectedBandIds.length} bands',
        ja: 'バンド ${selectedBandIds.length}件',
      ),
    );
  }

  bool get _isAppleMap =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;
}

class _PlacesSliverList extends StatelessWidget {
  const _PlacesSliverList({
    required this.state,
    required this.onRetry,
    required this.onPlaceTap,
    required this.onDirectionsTap,
    this.hasActiveFilters = false,
    this.onResetFilters,
  });

  final AsyncValue<List<PlaceSummary>> state;
  final VoidCallback onRetry;
  final ValueChanged<PlaceSummary> onPlaceTap;
  final ValueChanged<PlaceSummary> onDirectionsTap;
  final bool hasActiveFilters;
  final VoidCallback? onResetFilters;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return state.when(
      // EN: Shimmer skeleton — matches GBTPlaceCardHorizontal shape exactly.
      // KO: 쉬머 스켈레톤 — GBTPlaceCardHorizontal 형태와 정확히 일치.
      loading: () => SliverPadding(
        padding: const EdgeInsets.fromLTRB(
          GBTSpacing.md,
          GBTSpacing.sm,
          GBTSpacing.md,
          GBTSpacing.xl,
        ),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (_, __) => Padding(
              padding: const EdgeInsets.only(bottom: GBTSpacing.sm),
              child: const GBTPlaceCardSkeleton(),
            ),
            childCount: 5,
          ),
        ),
      ),
      error: (error, _) {
        final message = error is Failure
            ? error.userMessage
            : context.l10n(
                ko: '장소 정보를 불러오지 못했어요',
                en: 'Failed to load place information',
                ja: '場所情報を読み込めませんでした',
              );
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
                  const SizedBox(height: GBTSpacing.xl),
                  GBTEmptyState(
                    icon: Icons.place_outlined,
                    message: hasActiveFilters
                        ? context.l10n(
                            ko: '선택한 조건에 맞는 장소가 없습니다',
                            en: 'No places match selected filters',
                            ja: '選択した条件に一致する場所がありません',
                          )
                        : context.l10n(
                            ko: '아직 등록된 장소가 없습니다',
                            en: 'No places registered yet',
                            ja: 'まだ登録された場所がありません',
                          ),
                  ),
                  if (hasActiveFilters && onResetFilters != null) ...[
                    const SizedBox(height: GBTSpacing.md),
                    TextButton(
                      onPressed: onResetFilters,
                      child: Text(
                        context.l10n(
                          ko: '필터 초기화',
                          en: 'Reset filters',
                          ja: 'フィルタ初期化',
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        }

        return SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            GBTSpacing.md,
            GBTSpacing.sm,
            GBTSpacing.md,
            GBTSpacing.xl,
          ),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final place = places[index];
              // EN: DecoratedBox wraps card with elevation shadow so cards
              //     visually separate from the sheet surface background.
              // KO: DecoratedBox로 카드에 그림자를 추가해 시트 배경과
              //     시각적으로 분리합니다.
              return Padding(
                padding: const EdgeInsets.only(bottom: GBTSpacing.sm),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(GBTSpacing.radiusMd),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(
                          alpha: isDark ? 0.18 : 0.07,
                        ),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
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
                    onDirectionsTap: place.directions?.hasProviders == true
                        ? () => onDirectionsTap(place)
                        : null,
                  ),
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
      return _MapFallback(
        message: context.l10n(
          ko: '웹에서는 지도 기능을 지원하지 않습니다',
          en: 'Map is not supported on web',
          ja: 'Webでは地図機能をサポートしていません',
        ),
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

class _RegionFilterSheet extends ConsumerStatefulWidget {
  const _RegionFilterSheet({
    required this.initialSelectedCodes,
    required this.onApply,
  });

  final List<String> initialSelectedCodes;
  final ValueChanged<List<String>> onApply;

  @override
  ConsumerState<_RegionFilterSheet> createState() => _RegionFilterSheetState();
}

class _RegionFilterSheetState extends ConsumerState<_RegionFilterSheet> {
  late Set<String> _draftCodes;
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _draftCodes = widget.initialSelectedCodes.toSet();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<RegionOption> _dedupeRegionOptions(Iterable<RegionOption> options) {
    final unique = <String, RegionOption>{};
    for (final option in options) {
      unique.putIfAbsent(option.code, () => option);
    }
    return unique.values.toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final optionsState = ref.watch(placesRegionOptionsControllerProvider);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(GBTSpacing.md),
        child: optionsState.when(
          loading: () => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _SheetTitleRow(
                title: context.l10n(
                  ko: '지역 선택',
                  en: 'Select regions',
                  ja: '地域選択',
                ),
              ),
              const SizedBox(height: GBTSpacing.md),
              GBTLoading(
                message: context.l10n(
                  ko: '지역 정보를 불러오는 중...',
                  en: 'Loading region information...',
                  ja: '地域情報を読み込み中...',
                ),
              ),
              const SizedBox(height: GBTSpacing.md),
            ],
          ),
          error: (error, _) {
            final message = error is Failure
                ? error.userMessage
                : context.l10n(
                    ko: '지역 정보를 불러오지 못했어요',
                    en: 'Failed to load region information',
                    ja: '地域情報を読み込めませんでした',
                  );
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _SheetTitleRow(
                  title: context.l10n(
                    ko: '지역 선택',
                    en: 'Select regions',
                    ja: '地域選択',
                  ),
                ),
                const SizedBox(height: GBTSpacing.md),
                Text(
                  message,
                  style: GBTTypography.bodySmall.copyWith(
                    color: context.textSecondary,
                  ),
                ),
                const SizedBox(height: GBTSpacing.sm),
                TextButton(
                  onPressed: () => ref
                      .read(placesRegionOptionsControllerProvider.notifier)
                      .load(forceRefresh: true),
                  child: Text(
                    context.l10n(ko: '다시 시도', en: 'Retry', ja: '再試行'),
                  ),
                ),
              ],
            );
          },
          data: (options) {
            if (options.countries.isEmpty && options.popularRegions.isEmpty) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _SheetTitleRow(
                    title: context.l10n(
                      ko: '지역 선택',
                      en: 'Select regions',
                      ja: '地域選択',
                    ),
                  ),
                  const SizedBox(height: GBTSpacing.lg),
                  Text(
                    context.l10n(
                      ko: '현재 프로젝트의 지역 정보가 없습니다',
                      en: 'No region information for current project',
                      ja: '現在のプロジェクトに地域情報がありません',
                    ),
                    style: GBTTypography.bodyMedium.copyWith(
                      color: context.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: GBTSpacing.md),
                ],
              );
            }
            final allOptions = _dedupeRegionOptions([
              ...options.popularRegions,
              ...options.countries,
            ]);
            final query = _query.trim();
            final filtered = query.isEmpty
                ? allOptions
                : allOptions
                      .where(
                        (o) =>
                            normalizedContains(o.name, query) ||
                            normalizedContains(o.code, query),
                      )
                      .toList(growable: false);

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _SheetTitleRow(
                  title: context.l10n(
                    ko: '지역 선택',
                    en: 'Select regions',
                    ja: '地域選択',
                  ),
                ),
                const SizedBox(height: GBTSpacing.md),
                GBTSearchBar(
                  controller: _searchController,
                  hint: context.l10n(
                    ko: '지역명 검색',
                    en: 'Search region name',
                    ja: '地域名検索',
                  ),
                  onChanged: (val) => setState(() => _query = val),
                  onClear: () => setState(() {
                    _query = '';
                    _searchController.clear();
                  }),
                ),
                const SizedBox(height: GBTSpacing.sm),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final option = filtered[index];
                      return _RegionOptionTile(
                        option: option,
                        selected: _draftCodes.contains(option.code),
                        onChanged: (selected) {
                          setState(() {
                            if (selected) {
                              _draftCodes.add(option.code);
                            } else {
                              _draftCodes.remove(option.code);
                            }
                          });
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: GBTSpacing.sm),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _draftCodes.isEmpty
                            ? null
                            : () => setState(() => _draftCodes.clear()),
                        child: Text(
                          context.l10n(ko: '초기화', en: 'Reset', ja: 'リセット'),
                        ),
                      ),
                    ),
                    const SizedBox(width: GBTSpacing.sm),
                    Expanded(
                      child: FilledButton(
                        onPressed: () {
                          widget.onApply(_draftCodes.toList());
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          _draftCodes.isEmpty
                              ? context.l10n(
                                  ko: '전체 보기',
                                  en: 'Show all',
                                  ja: 'すべて表示',
                                )
                              : context.l10n(
                                  ko: '적용 (${_draftCodes.length})',
                                  en: 'Apply (${_draftCodes.length})',
                                  ja: '適用 (${_draftCodes.length})',
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _RegionOptionTile extends StatelessWidget {
  const _RegionOptionTile({
    required this.option,
    required this.selected,
    required this.onChanged,
  });

  final RegionOption option;
  final bool selected;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final metadata = <String>[
      context.l10n(
        ko: '장소 ${option.placeCount}개',
        en: '${option.placeCount} places',
        ja: '場所 ${option.placeCount}件',
      ),
      if (option.hasChildren)
        context.l10n(ko: '하위 포함', en: 'Includes subregions', ja: '下位含む'),
    ].join(' · ');
    final leftPadding = GBTSpacing.sm + math.min(option.level * 10.0, 30.0);

    return CheckboxListTile(
      value: selected,
      onChanged: (value) => onChanged(value ?? false),
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: EdgeInsets.only(left: leftPadding, right: GBTSpacing.md),
      dense: true,
      title: Text(option.name),
      subtitle: Text(
        metadata,
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
              hint: context.l10n(
                ko: '장소/유형/지역 검색',
                en: 'Search places/types/regions',
                ja: '場所/タイプ/地域を検索',
              ),
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
                  context.l10n(
                    ko: '지역, 장소 이름, 장소 유형을 입력하세요',
                    en: 'Enter a region, place name, or place type',
                    ja: '地域、場所名、場所タイプを入力してください',
                  ),
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
                    context.l10n(ko: '지역', en: 'Region', ja: '地域'),
                    style: GBTTypography.labelMedium.copyWith(
                      color: secondaryColor,
                    ),
                  ),
                ),
                const SizedBox(height: GBTSpacing.xs),
                ...regionResults.map(
                  (option) => ListTile(
                    title: Text(option.name),
                    subtitle: Text(
                      context.l10n(
                        ko: '장소 ${option.placeCount}개',
                        en: '${option.placeCount} places',
                        ja: '場所 ${option.placeCount}件',
                      ),
                    ),
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
                    context.l10n(ko: '장소', en: 'Places', ja: '場所'),
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
                    context.l10n(
                      ko: '검색 결과가 없습니다',
                      en: 'No search results',
                      ja: '検索結果がありません',
                    ),
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

  String get title => isCluster ? '${places.length}' : places.first.name;
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
          directions: item.place.directions,
        ),
      )
      .toList();
}

// ============================================================
// EN: Place filter chip — tappable pill with active/inactive state
// KO: 장소 필터 칩 — 활성/비활성 상태를 가진 탭 가능한 필
// ============================================================

class _PlaceFilterChip extends StatelessWidget {
  const _PlaceFilterChip({
    required this.label,
    required this.isActive,
    required this.isDark,
    required this.onTap,
    this.onClear,
  });

  final String label;
  final bool isActive;
  final bool isDark;
  final VoidCallback onTap;

  /// EN: If provided, shows X button instead of chevron.
  /// KO: 제공되면 화살표 대신 X 버튼을 표시합니다.
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final primaryColor = isDark ? GBTColors.darkPrimary : GBTColors.primary;
    final bgColor = isActive
        ? primaryColor
        : (isDark ? GBTColors.darkSurface : GBTColors.surface);
    final borderColor = isActive
        ? primaryColor
        : (isDark ? GBTColors.darkBorder : GBTColors.border);
    final textColor = isActive
        ? (isDark ? GBTColors.darkBackground : Colors.white)
        : (isDark ? GBTColors.darkTextSecondary : GBTColors.textSecondary);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 34,
        padding: EdgeInsets.only(
          left: 12,
          right: onClear != null ? 6 : 10,
          top: 6,
          bottom: 6,
        ),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(GBTSpacing.radiusFull),
          border: Border.all(color: borderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.06),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: GBTTypography.labelSmall.copyWith(
                color: textColor,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
            const SizedBox(width: 4),
            if (onClear != null)
              GestureDetector(
                onTap: onClear,
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.all(2),
                  child: Icon(Icons.close_rounded, size: 13, color: textColor),
                ),
              )
            else
              Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 15,
                color: textColor,
              ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// EN: Place mode chip — 주변 / 전체 segmented toggle
// KO: 장소 모드 칩 — 주변/전체 세그먼트 토글
// ============================================================

class _PlaceModeChip extends StatelessWidget {
  const _PlaceModeChip({
    required this.listMode,
    required this.isDark,
    required this.onChanged,
  });

  final PlaceListMode listMode;
  final bool isDark;
  final ValueChanged<PlaceListMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 34,
      decoration: BoxDecoration(
        color: isDark ? GBTColors.darkSurface : GBTColors.surface,
        borderRadius: BorderRadius.circular(GBTSpacing.radiusFull),
        border: Border.all(
          color: isDark ? GBTColors.darkBorder : GBTColors.border,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.06),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ModeTab(
            label: context.l10n(ko: '주변', en: 'Nearby', ja: '周辺'),
            isSelected: listMode == PlaceListMode.nearby,
            isDark: isDark,
            onTap: () => onChanged(PlaceListMode.nearby),
            isLeft: true,
          ),
          _ModeTab(
            label: context.l10n(ko: '전체', en: 'All', ja: '全体'),
            isSelected: listMode == PlaceListMode.all,
            isDark: isDark,
            onTap: () => onChanged(PlaceListMode.all),
            isLeft: false,
          ),
        ],
      ),
    );
  }
}

class _ModeTab extends StatelessWidget {
  const _ModeTab({
    required this.label,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
    required this.isLeft,
  });

  final String label;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;
  final bool isLeft;

  @override
  Widget build(BuildContext context) {
    final primaryColor = isDark ? GBTColors.darkPrimary : GBTColors.primary;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor : Colors.transparent,
          borderRadius: BorderRadius.only(
            topLeft: isLeft
                ? const Radius.circular(GBTSpacing.radiusFull)
                : Radius.zero,
            bottomLeft: isLeft
                ? const Radius.circular(GBTSpacing.radiusFull)
                : Radius.zero,
            topRight: !isLeft
                ? const Radius.circular(GBTSpacing.radiusFull)
                : Radius.zero,
            bottomRight: !isLeft
                ? const Radius.circular(GBTSpacing.radiusFull)
                : Radius.zero,
          ),
        ),
        child: Text(
          label,
          style: GBTTypography.labelSmall.copyWith(
            color: isSelected
                ? Colors.white
                : (isDark
                      ? GBTColors.darkTextSecondary
                      : GBTColors.textSecondary),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

// ============================================================
// EN: Pinned sheet header — count label + reset + collapse button.
//     Always visible even when the list is scrolled far down.
// KO: 고정 시트 헤더 — 장소 개수 · 필터 초기화 · 닫기 버튼.
//     리스트를 아래로 스크롤해도 항상 화면에 표시됩니다.
// ============================================================

class _SheetStickyHeader extends SliverPersistentHeaderDelegate {
  const _SheetStickyHeader({
    required this.placeCount,
    required this.hasActiveFilters,
    required this.isDark,
    required this.onCollapse,
    this.onResetFilters,
  });

  final int placeCount;
  final bool hasActiveFilters;
  final bool isDark;
  final VoidCallback onCollapse;
  final VoidCallback? onResetFilters;

  // EN: Fixed height = row content (48px touch area) + divider (1px)
  // KO: 고정 높이 = 행 콘텐츠(48px 터치 영역) + 구분선(1px)
  static const double _height = 49.0;

  @override
  double get minExtent => _height;

  @override
  double get maxExtent => _height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final secondaryColor = isDark
        ? GBTColors.darkTextSecondary
        : GBTColors.textSecondary;

    return ColoredBox(
      color: isDark ? GBTColors.darkSurface : GBTColors.surface,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              GBTSpacing.md,
              0,
              GBTSpacing.xs,
              0,
            ),
            child: Row(
              children: [
                Text(
                  context.l10n(
                    ko: '$placeCount개 장소',
                    en: '$placeCount places',
                    ja: '$placeCount件の場所',
                  ),
                  style: GBTTypography.labelMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (hasActiveFilters && onResetFilters != null) ...[
                  const SizedBox(width: GBTSpacing.sm),
                  GestureDetector(
                    onTap: onResetFilters,
                    child: Text(
                      context.l10n(
                        ko: '필터 초기화',
                        en: 'Reset filters',
                        ja: 'フィルタ初期化',
                      ),
                      style: GBTTypography.labelSmall.copyWith(
                        color: secondaryColor,
                      ),
                    ),
                  ),
                ],
                const Spacer(),
                // EN: Always-visible collapse button — tap to close the sheet.
                // KO: 항상 보이는 닫기 버튼 — 탭하면 시트를 접습니다.
                IconButton(
                  icon: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 22,
                    color: secondaryColor,
                  ),
                  onPressed: onCollapse,
                  tooltip: context.l10n(
                    ko: '목록 닫기',
                    en: 'Collapse list',
                    ja: 'リストを閉じる',
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 40,
                    minHeight: 40,
                  ),
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            color: isDark ? GBTColors.darkBorder : GBTColors.border,
          ),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(_SheetStickyHeader old) =>
      placeCount != old.placeCount ||
      hasActiveFilters != old.hasActiveFilters ||
      isDark != old.isDark;
}

// ============================================================
// EN: Project filter chip — solid primary pill, opens picker sheet
// KO: 프로젝트 필터 칩 — 솔리드 primary 필, 선택 시트 오픈
// ============================================================

class _ProjectFilterChip extends ConsumerWidget {
  const _ProjectFilterChip({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectsState = ref.watch(projectsControllerProvider);
    final selection = ref.watch(projectSelectionControllerProvider);

    final label = projectsState.maybeWhen(
      data: (projects) {
        if (projects.isEmpty) {
          return context.l10n(ko: '프로젝트', en: 'Project', ja: 'プロジェクト');
        }
        final selected = projects.cast<Project?>().firstWhere(
          (p) =>
              p?.code == selection.projectKey || p?.id == selection.projectKey,
          orElse: () => projects.first,
        );
        return selected?.name ??
            context.l10n(ko: '프로젝트', en: 'Project', ja: 'プロジェクト');
      },
      orElse: () => context.l10n(ko: '프로젝트', en: 'Project', ja: 'プロジェクト'),
    );

    final primaryColor = isDark ? GBTColors.darkPrimary : GBTColors.primary;
    final textColor = isDark ? GBTColors.darkBackground : Colors.white;

    return GestureDetector(
      onTap: () => _showProjectPicker(context),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 34,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: primaryColor,
          borderRadius: BorderRadius.circular(GBTSpacing.radiusFull),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withValues(alpha: isDark ? 0.35 : 0.30),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: GBTTypography.labelSmall.copyWith(
                color: textColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 15,
              color: textColor.withValues(alpha: 0.8),
            ),
          ],
        ),
      ),
    );
  }

  void _showProjectPicker(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => const _ProjectPickerSheet(),
    );
  }
}

// ============================================================
// EN: Project picker sheet — matches band filter sheet design
// KO: 프로젝트 선택 시트 — 밴드 필터 시트와 동일한 디자인
// ============================================================

class _ProjectPickerSheet extends ConsumerStatefulWidget {
  const _ProjectPickerSheet();

  @override
  ConsumerState<_ProjectPickerSheet> createState() =>
      _ProjectPickerSheetState();
}

class _ProjectPickerSheetState extends ConsumerState<_ProjectPickerSheet> {
  String? _draftKey;

  @override
  void initState() {
    super.initState();
    _draftKey = ref.read(projectSelectionControllerProvider).projectKey;
  }

  void _apply(List<Project> projects) {
    if (projects.isEmpty) return;
    final project = _draftKey == null
        ? projects.first
        : projects.firstWhere(
            (p) => p.code == _draftKey || p.id == _draftKey,
            orElse: () => projects.first,
          );
    final key = project.code.isNotEmpty ? project.code : project.id;
    ref
        .read(projectSelectionControllerProvider.notifier)
        .selectProject(key, projectId: project.id);
    ref
        .read(projectUnitsControllerProvider(key).notifier)
        .load(forceRefresh: true);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final projectsState = ref.watch(projectsControllerProvider);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(GBTSpacing.md),
        child: projectsState.when(
          loading: () => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _SheetTitleRow(
                title: context.l10n(
                  ko: '프로젝트 선택',
                  en: 'Select project',
                  ja: 'プロジェクト選択',
                ),
              ),
              const SizedBox(height: GBTSpacing.md),
              GBTLoading(
                message: context.l10n(
                  ko: '프로젝트를 불러오는 중...',
                  en: 'Loading projects...',
                  ja: 'プロジェクトを読み込み中...',
                ),
              ),
              const SizedBox(height: GBTSpacing.md),
            ],
          ),
          error: (error, _) {
            final message = error is Failure
                ? error.userMessage
                : context.l10n(
                    ko: '프로젝트를 불러오지 못했어요',
                    en: 'Failed to load projects',
                    ja: 'プロジェクトを読み込めませんでした',
                  );
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _SheetTitleRow(
                  title: context.l10n(
                    ko: '프로젝트 선택',
                    en: 'Select project',
                    ja: 'プロジェクト選択',
                  ),
                ),
                const SizedBox(height: GBTSpacing.md),
                Text(
                  message,
                  style: GBTTypography.bodySmall.copyWith(
                    color: context.textSecondary,
                  ),
                ),
                const SizedBox(height: GBTSpacing.sm),
                TextButton(
                  onPressed: () => ref
                      .read(projectsControllerProvider.notifier)
                      .load(forceRefresh: true),
                  child: Text(
                    context.l10n(ko: '다시 시도', en: 'Retry', ja: '再試行'),
                  ),
                ),
              ],
            );
          },
          data: (projects) {
            if (projects.isEmpty) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _SheetTitleRow(
                    title: context.l10n(
                      ko: '프로젝트 선택',
                      en: 'Select project',
                      ja: 'プロジェクト選択',
                    ),
                  ),
                  const SizedBox(height: GBTSpacing.lg),
                  Text(
                    context.l10n(
                      ko: '등록된 프로젝트가 없습니다',
                      en: 'No projects available',
                      ja: '登録されたプロジェクトがありません',
                    ),
                    style: GBTTypography.bodyMedium.copyWith(
                      color: context.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: GBTSpacing.md),
                ],
              );
            }
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _SheetTitleRow(
                  title: context.l10n(
                    ko: '프로젝트 선택',
                    en: 'Select project',
                    ja: 'プロジェクト選択',
                  ),
                ),
                const SizedBox(height: GBTSpacing.md),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: projects.length,
                    itemBuilder: (context, index) {
                      final project = projects[index];
                      final key = project.code.isNotEmpty
                          ? project.code
                          : project.id;
                      final isSelected = _draftKey == key;
                      final primaryColor = Theme.of(
                        context,
                      ).colorScheme.primary;
                      return ListTile(
                        leading: Icon(
                          isSelected
                              ? Icons.radio_button_checked
                              : Icons.radio_button_unchecked,
                          color: isSelected ? primaryColor : null,
                        ),
                        title: Text(project.name),
                        onTap: () => setState(() => _draftKey = key),
                      );
                    },
                  ),
                ),
                const SizedBox(height: GBTSpacing.sm),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton(
                        onPressed: () => _apply(projects),
                        child: Text(
                          context.l10n(ko: '적용', en: 'Apply', ja: '適用'),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ============================================================
// EN: Sheet title row — title + close button for all bottom sheets
// KO: 시트 제목 행 — 모든 바텀시트에 공통으로 사용하는 제목 + 닫기 버튼
// ============================================================

class _SheetTitleRow extends StatelessWidget {
  const _SheetTitleRow({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: GBTTypography.titleMedium.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const Spacer(),
        IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.of(context).pop(),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(
            minWidth: GBTSpacing.minTouchTarget,
            minHeight: GBTSpacing.minTouchTarget,
          ),
          tooltip: context.l10n(ko: '닫기', en: 'Close', ja: '閉じる'),
        ),
      ],
    );
  }
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
