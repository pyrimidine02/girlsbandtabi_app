import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:apple_maps_flutter/apple_maps_flutter.dart' as amaps;
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;

import '../../../../core/theme/gbt_spacing.dart';
import '../../../../core/theme/gbt_typography.dart';
import '../../../places/domain/entities/place_entities.dart';

/// EN: Travel Review creation page.
/// KO: 여행 후기 작성 페이지.
class TravelReviewCreatePage extends ConsumerStatefulWidget {
  const TravelReviewCreatePage({super.key});

  @override
  ConsumerState<TravelReviewCreatePage> createState() => _TravelReviewCreatePageState();
}

class _TravelReviewCreatePageState extends ConsumerState<TravelReviewCreatePage> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  
  // EN: Selected places for the review
  // KO: 후기에 선택된 장소들
  final List<PlaceSummary> _selectedPlaces = [];
  
  bool _isSubmitting = false;

  bool get _isAppleMap => !kIsWeb && Platform.isIOS;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _addPlace(PlaceSummary place) {
    setState(() {
      if (!_selectedPlaces.any((p) => p.id == place.id)) {
        _selectedPlaces.add(place);
      }
    });
  }

  void _removePlace(int index) {
    setState(() {
      _selectedPlaces.removeAt(index);
    });
  }

  void _reorderPlaces(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final place = _selectedPlaces.removeAt(oldIndex);
      _selectedPlaces.insert(newIndex, place);
    });
  }

  void _submit() {
    if (_titleController.text.trim().isEmpty || _contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('제목과 내용을 입력해주세요')));
      return;
    }
    if (_selectedPlaces.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('최소 1개 이상의 장소를 추가해주세요')));
      return;
    }

    setState(() => _isSubmitting = true);
    
    // EN: Mock submission delay
    // KO: 제출 지연 모의
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('여행 후기가 등록되었습니다.')));
        context.pop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('여행 후기 작성'),
        actions: [
          TextButton(
            onPressed: _isSubmitting ? null : _submit,
            child: const Text('등록'),
          ),
        ],
      ),
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: _buildMapSection(colorScheme),
              ),
              SliverPadding(
                padding: GBTSpacing.paddingPage,
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    TextField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: '제목',
                        hintText: '이번 여행은 어떠셨나요?',
                      ),
                    ),
                    const SizedBox(height: GBTSpacing.md),
                    TextField(
                      controller: _contentController,
                      maxLines: 8,
                      minLines: 5,
                      decoration: const InputDecoration(
                        labelText: '내용',
                        hintText: '자세한 후기를 남겨주세요.',
                      ),
                    ),
                    const SizedBox(height: GBTSpacing.xl),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('방문 일정', style: GBTTypography.titleMedium),
                        TextButton.icon(
                          onPressed: () {
                            // EN: Placeholder for opening place search sheet
                            // KO: 장소 검색 시트 열기 위한 플레이스홀더
                            _showDummyPlacePicker();
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('장소 추가'),
                        ),
                      ],
                    ),
                  ]),
                ),
              ),
              SliverReorderableList(
                itemCount: _selectedPlaces.length,
                onReorder: _reorderPlaces,
                itemBuilder: (context, index) {
                  final place = _selectedPlaces[index];
                  return Container(
                    key: ValueKey(place.id),
                    margin: const EdgeInsets.symmetric(horizontal: GBTSpacing.md, vertical: GBTSpacing.xs),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest.withAlpha(100),
                      borderRadius: BorderRadius.circular(GBTSpacing.radiusMd),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        radius: 14,
                        backgroundColor: colorScheme.primary,
                        child: Text('${index + 1}', style: TextStyle(color: colorScheme.onPrimary, fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                      title: Text(place.name, style: GBTTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
                      subtitle: Text(place.address, style: GBTTypography.bodySmall),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.close, size: 20),
                            onPressed: () => _removePlace(index),
                          ),
                          const Icon(Icons.drag_handle, color: Colors.grey),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
            ],
          ),
          if (_isSubmitting)
            Container(
              color: Colors.black45,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Widget _buildMapSection(ColorScheme colorScheme) {
    if (_selectedPlaces.isEmpty) {
      return Container(
        height: 200,
        color: colorScheme.surfaceContainerHighest,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.map_outlined, size: 48, color: colorScheme.onSurfaceVariant.withAlpha(150)),
              const SizedBox(height: GBTSpacing.sm),
              Text('장소를 추가하면 지도에 경로가 표시됩니다.', style: GBTTypography.bodyMedium.copyWith(color: colorScheme.onSurfaceVariant)),
            ],
          ),
        ),
      );
    }

    if (_isAppleMap) {
      final amaps.Polyline polyline = amaps.Polyline(
        polylineId: amaps.PolylineId('route'),
        points: _selectedPlaces.map((p) => amaps.LatLng(p.latitude, p.longitude)).toList(),
        color: colorScheme.primary,
        width: 4,
        jointType: amaps.JointType.round,
      );

      final Set<amaps.Annotation> markers = {};
      for (int i = 0; i < _selectedPlaces.length; i++) {
        final place = _selectedPlaces[i];
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
            target: amaps.LatLng(_selectedPlaces.first.latitude, _selectedPlaces.first.longitude),
            zoom: 12,
          ),
          polylines: {polyline},
          annotations: markers,
        ),
      );
    } else {
      final gmaps.Polyline polyline = gmaps.Polyline(
        polylineId: const gmaps.PolylineId('route'),
        points: _selectedPlaces.map((p) => gmaps.LatLng(p.latitude, p.longitude)).toList(),
        color: colorScheme.primary,
        width: 4,
        jointType: gmaps.JointType.round,
      );

      final Set<gmaps.Marker> markers = {};
      for (int i = 0; i < _selectedPlaces.length; i++) {
        final place = _selectedPlaces[i];
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
            target: gmaps.LatLng(_selectedPlaces.first.latitude, _selectedPlaces.first.longitude),
            zoom: 12,
          ),
          polylines: {polyline},
          markers: markers,
        ),
      );
    }
  }

  void _showDummyPlacePicker() {
    // EN: Simple dummy place picker for demo
    // KO: 데모용 간단한 장소 선택기
    final dummyPlaces = [
      const PlaceSummary(id: '1', name: '도쿄 타워', address: '도쿄도 미나토구 시바코엔 4-2-8', latitude: 35.6585805, longitude: 139.7454329),
      const PlaceSummary(id: '2', name: '시부야 스크램블 교차로', address: '도쿄도 시부야구 도겐자카 2-2-1', latitude: 35.6595, longitude: 139.7001),
      const PlaceSummary(id: '3', name: '아키하바라', address: '도쿄도 지요다구 소토칸다', latitude: 35.6983, longitude: 139.7731),
      const PlaceSummary(id: '4', name: '오다이바', address: '도쿄도 미나토구 오다이바', latitude: 35.6264, longitude: 139.7753),
    ];

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return ListView.builder(
          itemCount: dummyPlaces.length,
          itemBuilder: (context, index) {
            final place = dummyPlaces[index];
            return ListTile(
              title: Text(place.name),
              subtitle: Text(place.address),
              onTap: () {
                _addPlace(place);
                Navigator.pop(context);
              },
            );
          },
        );
      },
    );
  }
}
