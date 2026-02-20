/// EN: Visit detail page — Premium design with hero image, stats, and map.
/// KO: 방문 상세 페이지 — 히어로 이미지, 통계, 지도가 있는 프리미엄 디자인.
library;

import 'package:apple_maps_flutter/apple_maps_flutter.dart' as amaps;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'package:intl/intl.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/gbt_colors.dart';
import '../../../../core/theme/gbt_spacing.dart';
import '../../../../core/theme/gbt_typography.dart';
import '../../../../core/widgets/common/gbt_image.dart';
import '../../../../core/widgets/feedback/gbt_loading.dart';
import '../../../places/domain/entities/place_entities.dart';
import '../../application/visits_controller.dart';
import '../../domain/entities/visit_entities.dart';

/// EN: Visit detail page widget — premium layout.
/// KO: 방문 상세 페이지 위젯 — 프리미엄 레이아웃.
class VisitDetailPage extends ConsumerWidget {
  const VisitDetailPage({
    super.key,
    required this.visitId,
    required this.placeId,
    this.visitedAt,
    this.latitude,
    this.longitude,
  });

  final String visitId;
  final String placeId;
  final String? visitedAt;
  final double? latitude;
  final double? longitude;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final placesMapState = ref.watch(visitPlacesMapProvider);
    final summaryState = ref.watch(visitSummaryProvider(placeId));
    final detailState = ref.watch(visitDetailProvider(visitId));
    final place = placesMapState.valueOrNull?[placeId];
    final detail = detailState.valueOrNull;

    final detailLat = detail?.latitude;
    final detailLng = detail?.longitude;
    final hasVerificationCoords =
        (detailLat != null && detailLng != null) ||
        (latitude != null && longitude != null);
    final mapLat = detailLat ?? latitude ?? place?.latitude;
    final mapLng = detailLng ?? longitude ?? place?.longitude;
    final hasMapCoords = mapLat != null && mapLng != null;

    final visitedAtFormatted = _formatVisitedAt(
      detail?.visitedAt?.toIso8601String() ?? visitedAt,
    );

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // EN: [0] Hero image + AppBar
          // KO: [0] 히어로 이미지 + AppBar
          _HeroAppBar(
            place: place,
            visitedAt: visitedAtFormatted,
            isDark: isDark,
          ),

          // EN: [1] Visit info cards
          // KO: [1] 방문 정보 카드
          SliverToBoxAdapter(
            child: _VisitInfoCards(
              visitedAt: visitedAtFormatted,
              hasCoordinates: hasVerificationCoords,
              isDark: isDark,
            ),
          ),

          // EN: [2] Place info section
          // KO: [2] 장소 정보 섹션
          SliverToBoxAdapter(
            child: _PlaceInfoSection(
              place: place,
              isLoading: placesMapState.isLoading,
              isDark: isDark,
              onViewPlace: () => context.goToPlaceDetail(placeId),
            ),
          ),

          // EN: [3] Map section
          // KO: [3] 지도 섹션
          SliverToBoxAdapter(
            child: hasMapCoords
                ? _MapSection(
                    latitude: mapLat,
                    longitude: mapLng,
                    isVerificationLocation: hasVerificationCoords,
                    isDark: isDark,
                  )
                : const SizedBox.shrink(),
          ),

          // EN: [4] Visit stats section
          // KO: [4] 방문 통계 섹션
          SliverToBoxAdapter(
            child: _VisitStatsSection(
              summaryState: summaryState,
              isDark: isDark,
            ),
          ),

          // EN: [5] Action buttons
          // KO: [5] 액션 버튼
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: GBTSpacing.pageHorizontal,
                vertical: GBTSpacing.md,
              ),
              child: FilledButton.icon(
                onPressed: () => context.goToPlaceDetail(placeId),
                icon: const Icon(Icons.place_rounded),
                label: const Text('장소 상세 보기'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(GBTSpacing.radiusMd),
                  ),
                ),
              ),
            ),
          ),

          // EN: Bottom safe area
          // KO: 하단 안전 영역
          SliverToBoxAdapter(
            child: SizedBox(
              height: MediaQuery.of(context).padding.bottom + GBTSpacing.lg,
            ),
          ),
        ],
      ),
    );
  }

  String _formatVisitedAt(String? raw) {
    if (raw == null || raw.isEmpty) return '';
    final dt = DateTime.tryParse(raw);
    if (dt == null) return raw;
    return DateFormat('yyyy.MM.dd HH:mm').format(dt.toLocal());
  }
}

// ---------------------------------------------------------------------------
// EN: Hero app bar with place image background
// KO: 장소 이미지 배경의 히어로 앱바
// ---------------------------------------------------------------------------

class _HeroAppBar extends StatelessWidget {
  const _HeroAppBar({
    required this.place,
    required this.visitedAt,
    required this.isDark,
  });

  final PlaceSummary? place;
  final String visitedAt;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final hasImage = place?.imageUrl != null && place!.imageUrl!.isNotEmpty;

    return SliverAppBar(
      expandedHeight: hasImage ? 280 : 160,
      pinned: true,
      stretch: true,
      backgroundColor: isDark ? GBTColors.darkSurface : Colors.white,
      foregroundColor: hasImage ? Colors.white : null,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          place?.name ?? '방문 상세',
          style: GBTTypography.titleSmall.copyWith(
            color: hasImage
                ? Colors.white
                : (isDark
                    ? GBTColors.darkTextPrimary
                    : GBTColors.textPrimary),
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        background: hasImage
            ? Stack(
                fit: StackFit.expand,
                children: [
                  GBTImage(
                    imageUrl: place!.imageUrl!,
                    fit: BoxFit.cover,
                    semanticLabel: '${place!.name} 이미지',
                  ),
                  // EN: Gradient overlay for text readability
                  // KO: 텍스트 가독성을 위한 그라디언트 오버레이
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black54,
                        ],
                        stops: [0.5, 1.0],
                      ),
                    ),
                  ),
                ],
              )
            : Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [
                            GBTColors.darkSurfaceElevated,
                            GBTColors.darkSurfaceVariant,
                          ]
                        : [
                            GBTColors.primaryLight,
                            GBTColors.primary.withValues(alpha: 0.15),
                          ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.place_rounded,
                    size: 64,
                    color: isDark
                        ? GBTColors.darkTextTertiary
                        : GBTColors.primaryMuted,
                  ),
                ),
              ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// EN: Visit info cards row
// KO: 방문 정보 카드 행
// ---------------------------------------------------------------------------

class _VisitInfoCards extends StatelessWidget {
  const _VisitInfoCards({
    required this.visitedAt,
    required this.hasCoordinates,
    required this.isDark,
  });

  final String visitedAt;
  final bool hasCoordinates;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        GBTSpacing.pageHorizontal,
        GBTSpacing.lg,
        GBTSpacing.pageHorizontal,
        GBTSpacing.sm,
      ),
      child: Row(
        children: [
          Expanded(
            child: _InfoChip(
              icon: Icons.calendar_today_rounded,
              label: '방문 일시',
              value: visitedAt.isNotEmpty ? visitedAt : '-',
              isDark: isDark,
            ),
          ),
          const SizedBox(width: GBTSpacing.sm),
          Expanded(
            child: _InfoChip(
              icon: hasCoordinates
                  ? Icons.gps_fixed_rounded
                  : Icons.gps_off_rounded,
              label: 'GPS 인증',
              value: hasCoordinates ? '인증됨' : '미인증',
              isDark: isDark,
              highlight: hasCoordinates,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.isDark,
    this.highlight = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool isDark;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(GBTSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? GBTColors.darkSurfaceElevated : GBTColors.surfaceVariant,
        borderRadius: BorderRadius.circular(GBTSpacing.radiusMd),
        border: highlight
            ? Border.all(
                color: isDark
                    ? GBTColors.darkPrimary.withValues(alpha: 0.5)
                    : GBTColors.primary.withValues(alpha: 0.3),
              )
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 16,
                color: highlight
                    ? (isDark ? GBTColors.darkPrimary : GBTColors.primary)
                    : (isDark
                        ? GBTColors.darkTextTertiary
                        : GBTColors.textTertiary),
              ),
              const SizedBox(width: GBTSpacing.xs),
              Text(
                label,
                style: GBTTypography.labelSmall.copyWith(
                  color: isDark
                      ? GBTColors.darkTextSecondary
                      : GBTColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: GBTSpacing.xs),
          Text(
            value,
            style: GBTTypography.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color:
                  isDark ? GBTColors.darkTextPrimary : GBTColors.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// EN: Place info section
// KO: 장소 정보 섹션
// ---------------------------------------------------------------------------

class _PlaceInfoSection extends StatelessWidget {
  const _PlaceInfoSection({
    required this.place,
    required this.isLoading,
    required this.isDark,
    required this.onViewPlace,
  });

  final PlaceSummary? place;
  final bool isLoading;
  final bool isDark;
  final VoidCallback onViewPlace;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: GBTSpacing.pageHorizontal,
        vertical: GBTSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '장소 정보',
            style: GBTTypography.titleMedium.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: GBTSpacing.sm),
          if (isLoading) ...[
            _buildShimmer(),
          ] else if (place != null) ...[
            _buildPlaceCard(),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(GBTSpacing.md),
              decoration: BoxDecoration(
                color: isDark
                    ? GBTColors.darkSurfaceElevated
                    : GBTColors.surfaceVariant,
                borderRadius: BorderRadius.circular(GBTSpacing.radiusMd),
              ),
              child: Text(
                '장소 정보를 불러올 수 없습니다',
                style: GBTTypography.bodyMedium.copyWith(
                  color: isDark
                      ? GBTColors.darkTextSecondary
                      : GBTColors.textSecondary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPlaceCard() {
    return Material(
      color: isDark ? GBTColors.darkSurfaceElevated : Colors.white,
      borderRadius: BorderRadius.circular(GBTSpacing.radiusMd),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onViewPlace,
        child: Padding(
          padding: const EdgeInsets.all(GBTSpacing.md),
          child: Row(
            children: [
              // EN: Place thumbnail
              // KO: 장소 썸네일
              ClipRRect(
                borderRadius: BorderRadius.circular(GBTSpacing.radiusSm),
                child: SizedBox(
                  width: 64,
                  height: 64,
                  child: place!.imageUrl != null &&
                          place!.imageUrl!.isNotEmpty
                      ? GBTImage(
                          imageUrl: place!.imageUrl!,
                          width: 64,
                          height: 64,
                          fit: BoxFit.cover,
                          semanticLabel: '${place!.name} 이미지',
                        )
                      : Container(
                          color: isDark
                              ? GBTColors.darkSurfaceVariant
                              : GBTColors.primaryLight,
                          child: Icon(
                            Icons.place_rounded,
                            color: isDark
                                ? GBTColors.darkTextTertiary
                                : GBTColors.primaryMuted,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: GBTSpacing.md),
              // EN: Place info
              // KO: 장소 정보
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      place!.name,
                      style: GBTTypography.titleSmall.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (place!.address.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 14,
                            color: isDark
                                ? GBTColors.darkPrimary
                                : GBTColors.accentTeal,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              place!.address,
                              style: GBTTypography.bodySmall.copyWith(
                                color: isDark
                                    ? GBTColors.darkTextSecondary
                                    : GBTColors.textSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (place!.types.isNotEmpty) ...[
                      const SizedBox(height: GBTSpacing.xs),
                      Wrap(
                        spacing: 4,
                        children: place!.types.take(3).map((type) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? GBTColors.darkSurfaceVariant
                                  : GBTColors.primaryLight,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              type,
                              style: GBTTypography.labelSmall.copyWith(
                                color: isDark
                                    ? GBTColors.darkTextSecondary
                                    : GBTColors.primary,
                                fontSize: 10,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: isDark
                    ? GBTColors.darkTextTertiary
                    : GBTColors.textTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShimmer() {
    return GBTShimmer(
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          color:
              isDark ? GBTColors.darkSurfaceVariant : GBTColors.surfaceVariant,
          borderRadius: BorderRadius.circular(GBTSpacing.radiusMd),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// EN: Map section with rounded corners
// KO: 모서리가 둥근 지도 섹션
// ---------------------------------------------------------------------------

class _MapSection extends StatelessWidget {
  const _MapSection({
    required this.latitude,
    required this.longitude,
    required this.isVerificationLocation,
    required this.isDark,
  });

  final double latitude;
  final double longitude;
  final bool isVerificationLocation;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: GBTSpacing.pageHorizontal,
        vertical: GBTSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                isVerificationLocation ? '인증 위치' : '장소 위치',
                style: GBTTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (!isVerificationLocation) ...[
                const SizedBox(width: GBTSpacing.xs),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? GBTColors.darkSurfaceVariant
                        : GBTColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '추정',
                    style: GBTTypography.labelSmall.copyWith(
                      color: isDark
                          ? GBTColors.darkTextSecondary
                          : GBTColors.textSecondary,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: GBTSpacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(GBTSpacing.radiusMd),
            child: SizedBox(
              height: 200,
              child: kIsWeb
                  ? _mapPlaceholder()
                  : _buildMap(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMap() {
    final isApple =
        !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;
    final pinLabel = isVerificationLocation ? '인증 위치' : '장소 위치';

    if (isApple) {
      return amaps.AppleMap(
        initialCameraPosition: amaps.CameraPosition(
          target: amaps.LatLng(latitude, longitude),
          zoom: 16,
        ),
        scrollGesturesEnabled: false,
        zoomGesturesEnabled: false,
        rotateGesturesEnabled: false,
        myLocationEnabled: false,
        myLocationButtonEnabled: false,
        annotations: {
          amaps.Annotation(
            annotationId: amaps.AnnotationId('visit_pin'),
            position: amaps.LatLng(latitude, longitude),
            infoWindow: amaps.InfoWindow(title: pinLabel),
          ),
        },
      );
    }

    return gmaps.GoogleMap(
      initialCameraPosition: gmaps.CameraPosition(
        target: gmaps.LatLng(latitude, longitude),
        zoom: 16,
      ),
      scrollGesturesEnabled: false,
      zoomGesturesEnabled: false,
      rotateGesturesEnabled: false,
      zoomControlsEnabled: false,
      myLocationEnabled: false,
      myLocationButtonEnabled: false,
      style: isDark ? _darkMapStyle : null,
      markers: {
        gmaps.Marker(
          markerId: const gmaps.MarkerId('visit_pin'),
          position: gmaps.LatLng(latitude, longitude),
          infoWindow: gmaps.InfoWindow(title: pinLabel),
          icon: isVerificationLocation
              ? gmaps.BitmapDescriptor.defaultMarkerWithHue(
                  gmaps.BitmapDescriptor.hueRed,
                )
              : gmaps.BitmapDescriptor.defaultMarker,
        ),
      },
    );
  }

  Widget _mapPlaceholder() {
    return Container(
      color: isDark ? GBTColors.darkSurfaceVariant : GBTColors.surfaceVariant,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.map_rounded,
              size: 40,
              color: isDark
                  ? GBTColors.darkTextTertiary
                  : GBTColors.textTertiary,
            ),
            const SizedBox(height: GBTSpacing.sm),
            Text(
              '웹에서는 지도를 지원하지 않습니다',
              style: GBTTypography.bodySmall.copyWith(
                color: isDark
                    ? GBTColors.darkTextSecondary
                    : GBTColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// EN: Visit stats section with pill-style counters
// KO: 알약 스타일 카운터가 있는 방문 통계 섹션
// ---------------------------------------------------------------------------

class _VisitStatsSection extends StatelessWidget {
  const _VisitStatsSection({required this.summaryState, required this.isDark});

  final AsyncValue<VisitSummary?> summaryState;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: GBTSpacing.pageHorizontal,
        vertical: GBTSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '이 장소 방문 통계',
            style: GBTTypography.titleMedium.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: GBTSpacing.sm),
          summaryState.when(
            loading: () => GBTShimmer(
              child: Container(
                height: 72,
                decoration: BoxDecoration(
                  color: isDark
                      ? GBTColors.darkSurfaceVariant
                      : GBTColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(GBTSpacing.radiusMd),
                ),
              ),
            ),
            error: (_, __) => Text(
              '통계를 불러올 수 없습니다',
              style: GBTTypography.bodyMedium.copyWith(
                color: isDark
                    ? GBTColors.darkTextSecondary
                    : GBTColors.textSecondary,
              ),
            ),
            data: (summary) {
              if (summary == null) {
                return Text(
                  '통계 정보 없음',
                  style: GBTTypography.bodyMedium.copyWith(
                    color: isDark
                        ? GBTColors.darkTextSecondary
                        : GBTColors.textSecondary,
                  ),
                );
              }
              return _buildStats(summary);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStats(VisitSummary summary) {
    return Row(
      children: [
        Expanded(
          child: _MiniStatCard(
            icon: Icons.repeat_rounded,
            label: '총 방문',
            value: '${summary.visitCount}회',
            isDark: isDark,
          ),
        ),
        const SizedBox(width: GBTSpacing.sm),
        Expanded(
          child: _MiniStatCard(
            icon: Icons.first_page_rounded,
            label: '첫 방문',
            value: summary.firstVisitedLabel.isNotEmpty
                ? summary.firstVisitedLabel
                : '-',
            isDark: isDark,
          ),
        ),
        const SizedBox(width: GBTSpacing.sm),
        Expanded(
          child: _MiniStatCard(
            icon: Icons.last_page_rounded,
            label: '최근 방문',
            value: summary.lastVisitedLabel.isNotEmpty
                ? summary.lastVisitedLabel
                : '-',
            isDark: isDark,
          ),
        ),
      ],
    );
  }
}

class _MiniStatCard extends StatelessWidget {
  const _MiniStatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.isDark,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: GBTSpacing.sm,
        vertical: GBTSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: isDark ? GBTColors.darkSurfaceElevated : GBTColors.surfaceVariant,
        borderRadius: BorderRadius.circular(GBTSpacing.radiusMd),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 18,
            color: isDark ? GBTColors.darkPrimary : GBTColors.primary,
          ),
          const SizedBox(height: GBTSpacing.xxs),
          Text(
            value,
            style: GBTTypography.labelMedium.copyWith(
              fontWeight: FontWeight.w700,
              color:
                  isDark ? GBTColors.darkTextPrimary : GBTColors.textPrimary,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GBTTypography.labelSmall.copyWith(
              color: isDark
                  ? GBTColors.darkTextTertiary
                  : GBTColors.textTertiary,
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// EN: Dark map style for Google Maps
// KO: Google Maps 다크 지도 스타일
// ---------------------------------------------------------------------------

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
