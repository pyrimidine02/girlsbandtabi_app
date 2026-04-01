/// EN: Visit detail page — Premium design with hero image, stats, and map.
/// KO: 방문 상세 페이지 — 히어로 이미지, 통계, 지도가 있는 프리미엄 디자인.
library;

import 'dart:math' show log;
import 'dart:ui';

import 'package:apple_maps_flutter/apple_maps_flutter.dart' as amaps;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'package:intl/intl.dart';

import '../../../../core/localization/locale_text.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/gbt_colors.dart';
import '../../../../core/theme/gbt_map_styles.dart';
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
  });

  final String visitId;
  final String placeId;
  final String? visitedAt;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final placesMapState = ref.watch(visitPlacesMapProvider);
    final summaryState = ref.watch(visitSummaryProvider(placeId));
    final detailState = ref.watch(visitDetailProvider(visitId));
    final place = placesMapState.valueOrNull?[placeId];
    final detail = detailState.valueOrNull;

    // EN: GPS verified if distanceM is present in the detail response.
    // KO: 상세 응답에 distanceM이 있으면 GPS 인증 완료로 판단합니다.
    final hasVerificationCoords = detail?.hasGpsVerification ?? false;
    final distanceM = detail?.distanceM;
    final mapLat = place?.latitude;
    final mapLng = place?.longitude;
    final hasMapCoords = mapLat != null && mapLng != null;

    final visitedAtFormatted = _formatVisitedAt(
      detail?.visitedAt?.toIso8601String() ?? visitedAt,
    );

    return Scaffold(
      body: CustomScrollView(
        physics: Theme.of(context).platform == TargetPlatform.android
            ? const ClampingScrollPhysics()
            : const BouncingScrollPhysics(),
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
              distanceM: distanceM,
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
                    distanceM: distanceM,
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
                label: Text(
                  context.l10n(
                    ko: '장소 상세 보기',
                    en: 'View place details',
                    ja: '場所詳細を見る',
                  ),
                ),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(GBTSpacing.radiusMd),
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
      backgroundColor: (isDark ? GBTColors.darkSurface : Colors.white).withValues(alpha: 0.8),
      foregroundColor: hasImage ? Colors.white : null,
      flexibleSpace: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: FlexibleSpaceBar(
        title: Text(
          place?.name ??
              context.l10n(ko: '방문 상세', en: 'Visit detail', ja: '訪問詳細'),
          style: GBTTypography.titleSmall.copyWith(
            color: hasImage
                ? Colors.white
                : (isDark ? GBTColors.darkTextPrimary : GBTColors.textPrimary),
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
                    semanticLabel: context.l10n(
                      ko: '${place!.name} 이미지',
                      en: '${place!.name} image',
                      ja: '${place!.name} 画像',
                    ),
                  ),
                  // EN: Gradient overlay for text readability
                  // KO: 텍스트 가독성을 위한 그라디언트 오버레이
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black54],
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
    this.distanceM,
  });

  final String visitedAt;
  final bool hasCoordinates;
  final double? distanceM;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    // EN: Format distance label: show meters or kilometers as appropriate.
    // KO: 거리 레이블 포맷: 적절하게 미터 또는 킬로미터로 표시합니다.
    String gpsValue;
    if (!hasCoordinates) {
      gpsValue = context.l10n(ko: '미인증', en: 'Not verified', ja: '未認証');
    } else if (distanceM != null) {
      final d = distanceM!;
      gpsValue = d < 1000
          ? '${d.toStringAsFixed(1)}m'
          : '${(d / 1000).toStringAsFixed(2)}km';
    } else {
      gpsValue = context.l10n(ko: '인증됨', en: 'Verified', ja: '認証済み');
    }

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
              label: context.l10n(ko: '방문 일시', en: 'Visited at', ja: '訪問日時'),
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
              label: context.l10n(ko: 'GPS 인증', en: 'GPS verify', ja: 'GPS認証'),
              value: gpsValue,
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
        color: isDark
            ? GBTColors.darkSurfaceElevated
            : GBTColors.surfaceVariant,
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
              color: isDark ? GBTColors.darkTextPrimary : GBTColors.textPrimary,
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
            context.l10n(ko: '장소 정보', en: 'Place info', ja: '場所情報'),
            style: GBTTypography.titleMedium.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: GBTSpacing.sm),
          if (isLoading) ...[
            _buildShimmer(),
          ] else if (place != null) ...[
            _buildPlaceCard(context),
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
                context.l10n(
                  ko: '장소 정보를 불러올 수 없습니다',
                  en: 'Could not load place info',
                  ja: '場所情報を読み込めません',
                ),
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

  Widget _buildPlaceCard(BuildContext context) {
    return Material(
      color: isDark ? GBTColors.darkSurfaceElevated : Colors.white,
      borderRadius: BorderRadius.circular(GBTSpacing.radiusMd),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onViewPlace,
        onLongPress: () {
          Clipboard.setData(ClipboardData(text: '${place!.name}\n${place!.address}'));
          HapticFeedback.lightImpact();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                context.l10n(
                  ko: '장소 정보가 복사되었습니다',
                  en: 'Place info copied',
                  ja: '場所情報がコピーされました',
                ),
              ),
            ),
          );
        },
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
                  child: place!.imageUrl != null && place!.imageUrl!.isNotEmpty
                      ? GBTImage(
                          imageUrl: place!.imageUrl!,
                          width: 64,
                          height: 64,
                          fit: BoxFit.cover,
                          semanticLabel: context.l10n(
                            ko: '${place!.name} 이미지',
                            en: '${place!.name} image',
                            ja: '${place!.name} 画像',
                          ),
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
                      maxLines: 2,
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
                                maxLines: 2,
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
          color: isDark
              ? GBTColors.darkSurfaceVariant
              : GBTColors.surfaceVariant,
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
    this.distanceM,
  });

  final double latitude;
  final double longitude;
  final bool isVerificationLocation;
  final double? distanceM;
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
                isVerificationLocation
                    ? context.l10n(
                        ko: '인증 위치',
                        en: 'Verified location',
                        ja: '認証位置',
                      )
                    : context.l10n(
                        ko: '장소 위치',
                        en: 'Place location',
                        ja: '場所位置',
                      ),
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
                    context.l10n(ko: '추정', en: 'Approx', ja: '推定'),
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
              child: kIsWeb ? _mapPlaceholder(context) : _buildMap(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMap(BuildContext context) {
    final isApple = !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;
    final pinLabel = isVerificationLocation
        ? context.l10n(ko: '인증 위치', en: 'Verified location', ja: '認証位置')
        : context.l10n(ko: '장소 위치', en: 'Place location', ja: '場所位置');

    // EN: Adjust zoom so the verification radius circle fits in view.
    // KO: 인증 반경 원이 화면에 맞도록 줌 레벨을 조정합니다.
    final zoom = _zoomForRadius(distanceM);

    if (isApple) {
      final appleMap = amaps.AppleMap(
        initialCameraPosition: amaps.CameraPosition(
          target: amaps.LatLng(latitude, longitude),
          zoom: zoom,
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
        circles: {
          if (distanceM != null)
            amaps.Circle(
              circleId: amaps.CircleId('verification_radius'),
              center: amaps.LatLng(latitude, longitude),
              radius: distanceM!,
              strokeColor: GBTColors.primary.withValues(alpha: 0.8),
              strokeWidth: 2,
              fillColor: GBTColors.primary.withValues(alpha: 0.15),
            ),
        },
      );
      return Stack(
        fit: StackFit.expand,
        children: [
          appleMap,
          IgnorePointer(
            child: ColoredBox(
              color: gbtAppleMapOverlayColorForDarkMode(isDark),
            ),
          ),
        ],
      );
    }

    return gmaps.GoogleMap(
      initialCameraPosition: gmaps.CameraPosition(
        target: gmaps.LatLng(latitude, longitude),
        zoom: zoom,
      ),
      scrollGesturesEnabled: false,
      zoomGesturesEnabled: false,
      rotateGesturesEnabled: false,
      zoomControlsEnabled: false,
      myLocationEnabled: false,
      myLocationButtonEnabled: false,
      style: gbtGoogleMapStyleForDarkMode(isDark),
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
      circles: {
        if (distanceM != null)
          gmaps.Circle(
            circleId: const gmaps.CircleId('verification_radius'),
            center: gmaps.LatLng(latitude, longitude),
            radius: distanceM!,
            strokeColor: GBTColors.primary.withValues(alpha: 0.8),
            strokeWidth: 2,
            fillColor: GBTColors.primary.withValues(alpha: 0.15),
          ),
      },
    );
  }

  /// EN: Compute an approximate zoom level so the circle radius is visible.
  /// KO: 원형 반경이 화면에 보이도록 적절한 줌 레벨을 계산합니다.
  double _zoomForRadius(double? radius) {
    if (radius == null || radius <= 0) return 16;
    // EN: Each zoom step halves the visible area (~156km at zoom 0).
    // KO: 줌 0에서 약 156km, 한 단계마다 절반씩 축소됩니다.
    // EN: Add extra padding so the circle has breathing room.
    // KO: 원이 여유 있게 보이도록 패딩을 추가합니다.
    const paddingFactor = 3.0;
    final diameter = radius * 2 * paddingFactor;
    final zoom = 16 - (log(diameter / 500) / log(2));
    return zoom.clamp(10.0, 18.0);
  }

  Widget _mapPlaceholder(BuildContext context) {
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
              context.l10n(
                ko: '웹에서는 지도를 지원하지 않습니다',
                en: 'Map is not supported on web',
                ja: 'Webでは地図をサポートしていません',
              ),
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
            context.l10n(
              ko: '이 장소 방문 통계',
              en: 'Visit stats for this place',
              ja: 'この場所の訪問統計',
            ),
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
              context.l10n(
                ko: '통계를 불러올 수 없습니다',
                en: 'Could not load stats',
                ja: '統計を読み込めません',
              ),
              style: GBTTypography.bodyMedium.copyWith(
                color: isDark
                    ? GBTColors.darkTextSecondary
                    : GBTColors.textSecondary,
              ),
            ),
            data: (summary) {
              if (summary == null) {
                return Text(
                  context.l10n(
                    ko: '통계 정보 없음',
                    en: 'No stats available',
                    ja: '統計情報なし',
                  ),
                  style: GBTTypography.bodyMedium.copyWith(
                    color: isDark
                        ? GBTColors.darkTextSecondary
                        : GBTColors.textSecondary,
                  ),
                );
              }
              return _buildStats(context, summary);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStats(BuildContext context, VisitSummary summary) {
    return Row(
      children: [
        Expanded(
          child: _MiniStatCard(
            icon: Icons.repeat_rounded,
            label: context.l10n(ko: '총 방문', en: 'Total visits', ja: '総訪問'),
            value: context.l10n(
              ko: '${summary.visitCount}회',
              en: '${summary.visitCount}',
              ja: '${summary.visitCount}回',
            ),
            isDark: isDark,
          ),
        ),
        const SizedBox(width: GBTSpacing.sm),
        Expanded(
          child: _MiniStatCard(
            icon: Icons.first_page_rounded,
            label: context.l10n(ko: '첫 방문', en: 'First visit', ja: '初回訪問'),
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
            label: context.l10n(ko: '최근 방문', en: 'Latest visit', ja: '最近の訪問'),
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
        color: isDark
            ? GBTColors.darkSurfaceElevated
            : GBTColors.surfaceVariant,
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
              color: isDark ? GBTColors.darkTextPrimary : GBTColors.textPrimary,
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
