import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:apple_maps_flutter/apple_maps_flutter.dart' as amaps;
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;

import '../../../../core/theme/gbt_colors.dart';
import '../../../../core/theme/gbt_spacing.dart';
import '../../../../core/theme/gbt_typography.dart';
import '../../../places/domain/entities/place_entities.dart';

/// EN: Mock Travel Review Detail Page
/// KO: 목업 여행 후기 상세 페이지
class TravelReviewDetailPage extends ConsumerStatefulWidget {
  const TravelReviewDetailPage({
    super.key,
    required this.reviewId,
  });

  final String reviewId;

  @override
  ConsumerState<TravelReviewDetailPage> createState() => _TravelReviewDetailPageState();
}

class _TravelReviewDetailPageState extends ConsumerState<TravelReviewDetailPage> {
  bool get _isAppleMap => !kIsWeb && Platform.isIOS;

  // EN: Dummy mockup data based on ID
  // KO: ID 기반의 더미 목업 데이터
  late final Map<String, dynamic> _review;
  late final List<PlaceSummary> _places;

  @override
  void initState() {
    super.initState();
    _loadDummyData();
  }

  void _loadDummyData() {
    if (widget.reviewId == '1') {
      _review = {
        'id': '1',
        'authorName': '타비매니아',
        'title': '도쿄 성지순례 1일차 알차게 다녀왔어!',
        'content': '아침 일찍 도쿄역에 도착하자마자 오다이바 먼저 찍고 아키하바라로 넘어갔는데 일정이 좀 빡셌지만 너무 재밌었어.\n\n오다이바에서는 건담 구경하고 점심 먹고, 라디오회관 쪽으로 넘어와서 굿즈 구경하다 보니 하루가 다 갔네. 다음엔 더 여유롭게 가고 싶다!',
        'likeCount': 42,
        'commentCount': 8,
        'timeAgo': '2시간 전',
      };
      _places = [
        const PlaceSummary(id: 'p1', name: '도쿄 역', address: '도쿄도 지요다구 마루노우치', latitude: 35.6812, longitude: 139.7671),
        const PlaceSummary(id: 'p4', name: '오다이바 해변공원', address: '도쿄도 미나토구 다이바', latitude: 35.6329, longitude: 139.7753),
        const PlaceSummary(id: 'p3', name: '아키하바라', address: '도쿄도 지요다구 소토칸다', latitude: 35.6983, longitude: 139.7731),
      ];
    } else {
      _review = {
        'id': widget.reviewId,
        'authorName': '익명유저',
        'title': '테스트 후기 ${widget.reviewId}',
        'content': '더미 테스트 콘텐츠 영역입니다. 상세한 여행기가 여기에 포함됩니다.',
        'likeCount': 0,
        'commentCount': 0,
        'timeAgo': '방금 전',
      };
      _places = [
        const PlaceSummary(id: 'p1', name: '도쿄 타워', address: '도쿄도 미나토구 시바코엔 4-2-8', latitude: 35.6585, longitude: 139.7454),
        const PlaceSummary(id: 'p2', name: '시부야 스크램블 교차로', address: '도쿄도 시부야구 도겐자카', latitude: 35.6595, longitude: 139.7001),
      ];
    }
  }

  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('수정'),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('수정 기능은 현재 목업 상태입니다.')));
                },
              ),
              ListTile(
                leading: Icon(Icons.delete, color: Theme.of(context).colorScheme.error),
                title: Text('삭제', style: TextStyle(color: Theme.of(context).colorScheme.error)),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('삭제 기능은 현재 목업 상태입니다.')));
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('여행 후기'),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: _showMoreOptions,
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // EN: Map Section
          SliverToBoxAdapter(
            child: _buildMapSection(colorScheme),
          ),

          // EN: Content Section
          SliverPadding(
            padding: GBTSpacing.paddingPage,
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // EN: Author Info
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: isDark ? GBTColors.darkSurfaceVariant : GBTColors.surfaceVariant,
                      child: Icon(Icons.person, color: isDark ? GBTColors.darkTextTertiary : GBTColors.textTertiary),
                    ),
                    const SizedBox(width: GBTSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _review['authorName'] as String,
                            style: GBTTypography.labelLarge,
                          ),
                          Text(
                            _review['timeAgo'] as String,
                            style: GBTTypography.labelSmall.copyWith(
                              color: isDark ? GBTColors.darkTextSecondary : GBTColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: GBTSpacing.lg),

                // EN: Title
                Text(
                  _review['title'] as String,
                  style: GBTTypography.headlineSmall.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: GBTSpacing.md),

                // EN: Places List
                Container(
                  padding: const EdgeInsets.all(GBTSpacing.md),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest.withAlpha(80),
                    borderRadius: BorderRadius.circular(GBTSpacing.radiusMd),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('방문 일정', style: GBTTypography.labelLarge),
                      const SizedBox(height: GBTSpacing.sm),
                      for (int i = 0; i < _places.length; i++)
                        Padding(
                          padding: const EdgeInsets.only(bottom: GBTSpacing.xs),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 10,
                                backgroundColor: colorScheme.primary,
                                child: Text('${i + 1}', style: TextStyle(color: colorScheme.onPrimary, fontSize: 10, fontWeight: FontWeight.bold)),
                              ),
                              const SizedBox(width: GBTSpacing.sm),
                              Text(
                                _places[i].name,
                                style: GBTTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: GBTSpacing.lg),

                // EN: Body Content
                Text(
                  _review['content'] as String,
                  style: GBTTypography.bodyLarge.copyWith(height: 1.6),
                ),
                const SizedBox(height: GBTSpacing.xl),

                // EN: Actions (Like / Comment)
                const Divider(),
                Row(
                  children: [
                    TextButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.favorite_border),
                      label: Text('좋아요 ${_review['likeCount']}'),
                      style: TextButton.styleFrom(foregroundColor: colorScheme.onSurface),
                    ),
                    const SizedBox(width: GBTSpacing.md),
                    TextButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.comment_outlined),
                      label: Text('댓글 ${_review['commentCount']}'),
                      style: TextButton.styleFrom(foregroundColor: colorScheme.onSurface),
                    ),
                  ],
                ),
                const Divider(),
                const SizedBox(height: GBTSpacing.lg),
                
                // EN: Placeholder for Comments
                Text('댓글', style: GBTTypography.titleMedium),
                const SizedBox(height: 100), // Spacing
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapSection(ColorScheme colorScheme) {
    if (_isAppleMap) {
      final amaps.Polyline polyline = amaps.Polyline(
        polylineId: amaps.PolylineId('route_${widget.reviewId}'),
        points: _places.map((p) => amaps.LatLng(p.latitude, p.longitude)).toList(),
        color: colorScheme.primary,
        width: 4,
        jointType: amaps.JointType.round,
      );

      final Set<amaps.Annotation> markers = {};
      for (int i = 0; i < _places.length; i++) {
        final place = _places[i];
        markers.add(
          amaps.Annotation(
            annotationId: amaps.AnnotationId(place.id),
            position: amaps.LatLng(place.latitude, place.longitude),
            infoWindow: amaps.InfoWindow(title: '${i + 1}. ${place.name}'),
          ),
        );
      }

      return SizedBox(
        height: 250,
        child: amaps.AppleMap(
          initialCameraPosition: amaps.CameraPosition(
            target: amaps.LatLng(_places.first.latitude, _places.first.longitude),
            zoom: 12,
          ),
          polylines: {polyline},
          annotations: markers,
          scrollGesturesEnabled: false,
        ),
      );
    } else {
      final gmaps.Polyline polyline = gmaps.Polyline(
        polylineId: const gmaps.PolylineId('route'),
        points: _places.map((p) => gmaps.LatLng(p.latitude, p.longitude)).toList(),
        color: colorScheme.primary,
        width: 4,
        jointType: gmaps.JointType.round,
      );

      final Set<gmaps.Marker> markers = {};
      for (int i = 0; i < _places.length; i++) {
        final place = _places[i];
        markers.add(
          gmaps.Marker(
            markerId: gmaps.MarkerId(place.id),
            position: gmaps.LatLng(place.latitude, place.longitude),
            infoWindow: gmaps.InfoWindow(title: '${i + 1}. ${place.name}'),
          ),
        );
      }

      return SizedBox(
        height: 250,
        child: gmaps.GoogleMap(
          initialCameraPosition: gmaps.CameraPosition(
            target: gmaps.LatLng(_places.first.latitude, _places.first.longitude),
            zoom: 12,
          ),
          polylines: {polyline},
          markers: markers,
          scrollGesturesEnabled: false,
        ),
      );
    }
  }
}
