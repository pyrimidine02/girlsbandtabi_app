/// EN: Visit detail page showing visit info, map, and place summary.
/// KO: 방문 정보, 지도, 장소 요약을 보여주는 방문 상세 페이지.
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

/// EN: Visit detail page widget.
/// KO: 방문 상세 페이지 위젯.
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
    final place = placesMapState.valueOrNull?[placeId];

    // EN: Determine map coordinates with fallback strategy.
    // KO: 폴백 전략으로 지도 좌표를 결정합니다.
    final hasVerificationCoords = latitude != null && longitude != null;
    final mapLat = latitude ?? place?.latitude;
    final mapLng = longitude ?? place?.longitude;
    final hasMapCoords = mapLat != null && mapLng != null;

    final visitedAtFormatted = _formatVisitedAt(visitedAt);

    return Scaffold(
      appBar: AppBar(title: const Text('방문 상세')),
      body: CustomScrollView(
        slivers: [
          // EN: [0] Map section
          // KO: [0] 지도 섹션
          SliverToBoxAdapter(
            child: hasMapCoords
                ? _VisitLocationMap(
                    latitude: mapLat,
                    longitude: mapLng,
                    isVerificationLocation: hasVerificationCoords,
                    isDark: isDark,
                  )
                : _NoLocationMessage(isDark: isDark),
          ),

          // EN: [1] Visit info section
          // KO: [1] 방문 정보 섹션
          SliverToBoxAdapter(
            child: _VisitInfoSection(
              visitedAt: visitedAtFormatted,
              visitId: visitId,
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
            ),
          ),

          // EN: [3] Visit stats section
          // KO: [3] 방문 통계 섹션
          SliverToBoxAdapter(
            child: _VisitStatsSection(
              summaryState: summaryState,
              isDark: isDark,
            ),
          ),

          // EN: [4] Action button
          // KO: [4] 액션 버튼
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: GBTSpacing.md,
                vertical: GBTSpacing.lg,
              ),
              child: FilledButton.icon(
                onPressed: () => context.goToPlaceDetail(placeId),
                icon: const Icon(Icons.place),
                label: const Text('장소 상세 보기'),
              ),
            ),
          ),

          // EN: Bottom safe area padding
          // KO: 하단 안전 영역 패딩
          SliverToBoxAdapter(
            child: SizedBox(
              height: MediaQuery.of(context).padding.bottom + GBTSpacing.md,
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
// EN: Map widget showing visit/place location
// KO: 방문/장소 위치를 표시하는 지도 위젯
// ---------------------------------------------------------------------------

class _VisitLocationMap extends StatelessWidget {
  const _VisitLocationMap({
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
    if (kIsWeb) {
      return _mapPlaceholder(context);
    }

    final pinLabel = isVerificationLocation ? '인증 위치' : '장소 위치';

    return SizedBox(
      height: 250,
      child: Stack(
        children: [
          Positioned.fill(child: _buildMap(pinLabel)),
          if (!isVerificationLocation)
            Positioned(
              bottom: GBTSpacing.sm,
              left: GBTSpacing.md,
              right: GBTSpacing.md,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: GBTSpacing.sm,
                  vertical: GBTSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? GBTColors.darkSurfaceElevated.withValues(alpha: 0.9)
                      : Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(GBTSpacing.radiusSm),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: GBTSpacing.iconSm,
                      color: isDark
                          ? GBTColors.darkTextSecondary
                          : GBTColors.textSecondary,
                    ),
                    const SizedBox(width: GBTSpacing.xs),
                    Text(
                      '인증 위치 정보 없음 (장소 위치 표시)',
                      style: GBTTypography.bodySmall.copyWith(
                        color: isDark
                            ? GBTColors.darkTextSecondary
                            : GBTColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMap(String pinLabel) {
    final isApple =
        !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

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

  Widget _mapPlaceholder(BuildContext context) {
    return Container(
      height: 250,
      color: isDark ? GBTColors.darkSurfaceVariant : GBTColors.surfaceVariant,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.map,
              size: 48,
              color: isDark
                  ? GBTColors.darkTextTertiary
                  : GBTColors.textTertiary,
            ),
            const SizedBox(height: GBTSpacing.sm),
            Text(
              '웹에서는 지도를 지원하지 않습니다',
              style: GBTTypography.bodyMedium.copyWith(
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

class _NoLocationMessage extends StatelessWidget {
  const _NoLocationMessage({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      color: isDark ? GBTColors.darkSurfaceVariant : GBTColors.surfaceVariant,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_off,
              size: 32,
              color: isDark
                  ? GBTColors.darkTextTertiary
                  : GBTColors.textTertiary,
            ),
            const SizedBox(height: GBTSpacing.sm),
            Text(
              '위치 정보 없음',
              style: GBTTypography.bodyMedium.copyWith(
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
// EN: Visit info section (date, ID)
// KO: 방문 정보 섹션 (날짜, ID)
// ---------------------------------------------------------------------------

class _VisitInfoSection extends StatelessWidget {
  const _VisitInfoSection({
    required this.visitedAt,
    required this.visitId,
    required this.isDark,
  });

  final String visitedAt;
  final String visitId;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final secondaryColor = isDark
        ? GBTColors.darkTextSecondary
        : GBTColors.textSecondary;

    return Padding(
      padding: const EdgeInsets.all(GBTSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '방문 정보',
            style: GBTTypography.titleMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: GBTSpacing.sm),
          _InfoRow(
            icon: Icons.calendar_today,
            label: '방문 일시',
            value: visitedAt.isNotEmpty ? visitedAt : '-',
            valueColor: secondaryColor,
            isDark: isDark,
          ),
          const SizedBox(height: GBTSpacing.sm),
          const Divider(height: 1),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.valueColor,
    required this.isDark,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color valueColor;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: GBTSpacing.iconSm,
          color: isDark
              ? GBTColors.darkTextTertiary
              : GBTColors.textTertiary,
        ),
        const SizedBox(width: GBTSpacing.sm),
        Text(
          label,
          style: GBTTypography.bodySmall.copyWith(
            color: isDark
                ? GBTColors.darkTextTertiary
                : GBTColors.textTertiary,
          ),
        ),
        const SizedBox(width: GBTSpacing.sm),
        Expanded(
          child: Text(
            value,
            style: GBTTypography.bodyMedium.copyWith(color: valueColor),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// EN: Place info section (image, name, address)
// KO: 장소 정보 섹션 (이미지, 이름, 주소)
// ---------------------------------------------------------------------------

class _PlaceInfoSection extends StatelessWidget {
  const _PlaceInfoSection({
    required this.place,
    required this.isLoading,
    required this.isDark,
  });

  final PlaceSummary? place;
  final bool isLoading;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: GBTSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '장소 정보',
            style: GBTTypography.titleMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: GBTSpacing.sm),
          if (isLoading) _buildShimmer() else _buildPlaceInfo(),
          const SizedBox(height: GBTSpacing.sm),
          const Divider(height: 1),
        ],
      ),
    );
  }

  Widget _buildShimmer() {
    return Row(
      children: [
        GBTShimmer(
          child: Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: isDark
                  ? GBTColors.darkSurfaceVariant
                  : GBTColors.surfaceVariant,
              borderRadius: BorderRadius.circular(GBTSpacing.radiusSm),
            ),
          ),
        ),
        const SizedBox(width: GBTSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GBTShimmer(
                child: Container(
                  height: 16,
                  width: 120,
                  decoration: BoxDecoration(
                    color: isDark
                        ? GBTColors.darkSurfaceVariant
                        : GBTColors.surfaceVariant,
                    borderRadius:
                        BorderRadius.circular(GBTSpacing.radiusXs),
                  ),
                ),
              ),
              const SizedBox(height: GBTSpacing.xs),
              GBTShimmer(
                child: Container(
                  height: 14,
                  width: 180,
                  decoration: BoxDecoration(
                    color: isDark
                        ? GBTColors.darkSurfaceVariant
                        : GBTColors.surfaceVariant,
                    borderRadius:
                        BorderRadius.circular(GBTSpacing.radiusXs),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceInfo() {
    if (place == null) {
      return Text(
        '장소 정보를 불러올 수 없습니다',
        style: GBTTypography.bodyMedium.copyWith(
          color: isDark
              ? GBTColors.darkTextSecondary
              : GBTColors.textSecondary,
        ),
      );
    }

    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(GBTSpacing.radiusSm),
          child: place!.imageUrl != null
              ? GBTImage(
                  imageUrl: place!.imageUrl!,
                  width: 72,
                  height: 72,
                  fit: BoxFit.cover,
                  semanticLabel: '${place!.name} 이미지',
                )
              : Container(
                  width: 72,
                  height: 72,
                  color: isDark
                      ? GBTColors.darkSurfaceVariant
                      : GBTColors.surfaceVariant,
                  child: Icon(
                    Icons.place,
                    color: isDark
                        ? GBTColors.darkTextTertiary
                        : GBTColors.textTertiary,
                  ),
                ),
        ),
        const SizedBox(width: GBTSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                place!.name,
                style: GBTTypography.titleSmall.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (place!.address.isNotEmpty) ...[
                const SizedBox(height: GBTSpacing.xxs),
                Text(
                  place!.address,
                  style: GBTTypography.bodySmall.copyWith(
                    color: isDark
                        ? GBTColors.darkTextSecondary
                        : GBTColors.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// EN: Visit stats section (total visits, first/last visit)
// KO: 방문 통계 섹션 (총 방문, 첫/마지막 방문)
// ---------------------------------------------------------------------------

class _VisitStatsSection extends StatelessWidget {
  const _VisitStatsSection({
    required this.summaryState,
    required this.isDark,
  });

  final AsyncValue<VisitSummary?> summaryState;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: GBTSpacing.md,
        vertical: GBTSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '방문 통계',
            style: GBTTypography.titleMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: GBTSpacing.sm),
          summaryState.when(
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(GBTSpacing.md),
                child: GBTLoading(message: '통계를 불러오는 중...'),
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
          child: _StatCard(
            icon: Icons.repeat,
            label: '총 방문',
            value: '${summary.visitCount}회',
            isDark: isDark,
          ),
        ),
        const SizedBox(width: GBTSpacing.sm),
        Expanded(
          child: _StatCard(
            icon: Icons.first_page,
            label: '첫 방문',
            value: summary.firstVisitedLabel.isNotEmpty
                ? summary.firstVisitedLabel
                : '-',
            isDark: isDark,
          ),
        ),
        const SizedBox(width: GBTSpacing.sm),
        Expanded(
          child: _StatCard(
            icon: Icons.last_page,
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

class _StatCard extends StatelessWidget {
  const _StatCard({
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
      padding: const EdgeInsets.all(GBTSpacing.sm),
      decoration: BoxDecoration(
        color: isDark
            ? GBTColors.darkSurfaceVariant
            : GBTColors.surfaceVariant,
        borderRadius: BorderRadius.circular(GBTSpacing.radiusSm),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: GBTSpacing.iconSm,
            color: isDark
                ? GBTColors.darkTextTertiary
                : GBTColors.textTertiary,
          ),
          const SizedBox(height: GBTSpacing.xs),
          Text(
            value,
            style: GBTTypography.titleSmall.copyWith(
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: GBTSpacing.xxs),
          Text(
            label,
            style: GBTTypography.bodySmall.copyWith(
              color: isDark
                  ? GBTColors.darkTextTertiary
                  : GBTColors.textTertiary,
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
