import 'dart:io';
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:apple_maps_flutter/apple_maps_flutter.dart' as amaps;
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;

import '../../../../core/theme/gbt_colors.dart';
import '../../../../core/theme/gbt_map_styles.dart';
import '../../../../core/theme/gbt_spacing.dart';
import '../../../../core/theme/gbt_typography.dart';
import '../../../../core/widgets/common/gbt_image.dart';
import '../../../places/application/places_controller.dart';
import '../../../places/domain/entities/place_entities.dart';

/// EN: Travel Review creation page.
/// KO: 여행 후기 작성 페이지.
class TravelReviewCreatePage extends ConsumerStatefulWidget {
  const TravelReviewCreatePage({super.key});

  @override
  ConsumerState<TravelReviewCreatePage> createState() =>
      _TravelReviewCreatePageState();
}

class _TravelReviewCreatePageState
    extends ConsumerState<TravelReviewCreatePage> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  // EN: Selected places for the review
  // KO: 후기에 선택된 장소들
  final List<PlaceSummary> _selectedPlaces = [];

  bool _isSubmitting = false;

  bool get _isAppleMap => !kIsWeb && Platform.isIOS;

  bool get _canSubmit =>
      _titleController.text.trim().isNotEmpty &&
      _contentController.text.trim().isNotEmpty &&
      _selectedPlaces.isNotEmpty &&
      !_isSubmitting;

  @override
  void initState() {
    super.initState();
    _titleController.addListener(_updateState);
    _contentController.addListener(_updateState);
  }

  void _updateState() => setState(() {});

  @override
  void dispose() {
    _titleController.removeListener(_updateState);
    _contentController.removeListener(_updateState);
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
    HapticFeedback.lightImpact();
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final place = _selectedPlaces.removeAt(oldIndex);
      _selectedPlaces.insert(newIndex, place);
    });
  }

  void _submit() {
    if (_titleController.text.trim().isEmpty ||
        _contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('제목과 내용을 입력해주세요')));
      return;
    }
    if (_selectedPlaces.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('최소 1개 이상의 장소를 추가해주세요')));
      return;
    }

    setState(() => _isSubmitting = true);

    // EN: Mock submission delay
    // KO: 제출 지연 모의
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('여행 후기가 등록되었습니다.')));
        context.pop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('여행 후기 작성'),
        actions: [
          TextButton(
            onPressed: _canSubmit ? _submit : null,
            child: const Text('등록'),
          ),
        ],
      ),
      body: Stack(
        children: [
          CustomScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            slivers: [
              SliverToBoxAdapter(child: _buildMapSection(colorScheme, isDark)),
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
                          onPressed: _showPlacePicker,
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
                    margin: const EdgeInsets.symmetric(
                      horizontal: GBTSpacing.md,
                      vertical: GBTSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest.withAlpha(100),
                      borderRadius: BorderRadius.circular(GBTSpacing.radiusMd),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        radius: 14,
                        backgroundColor: colorScheme.primary,
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            color: colorScheme.onPrimary,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(
                        place.name,
                        style: GBTTypography.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        place.address,
                        style: GBTTypography.bodySmall,
                      ),
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

  Widget _buildMapSection(ColorScheme colorScheme, bool isDark) {
    if (_selectedPlaces.isEmpty) {
      return Container(
        height: 200,
        color: colorScheme.surfaceContainerHighest,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.map_outlined,
                size: 48,
                color: colorScheme.onSurfaceVariant.withAlpha(150),
              ),
              const SizedBox(height: GBTSpacing.sm),
              Text(
                '장소를 추가하면 지도에 경로가 표시됩니다.',
                style: GBTTypography.bodyMedium.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_isAppleMap) {
      final amaps.Polyline polyline = amaps.Polyline(
        polylineId: amaps.PolylineId('route'),
        points: _selectedPlaces
            .map((p) => amaps.LatLng(p.latitude, p.longitude))
            .toList(),
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

      final appleMap = SizedBox(
        height: 250,
        child: amaps.AppleMap(
          initialCameraPosition: amaps.CameraPosition(
            target: amaps.LatLng(
              _selectedPlaces.first.latitude,
              _selectedPlaces.first.longitude,
            ),
            zoom: 12,
          ),
          polylines: {polyline},
          annotations: markers,
        ),
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
    } else {
      final gmaps.Polyline polyline = gmaps.Polyline(
        polylineId: const gmaps.PolylineId('route'),
        points: _selectedPlaces
            .map((p) => gmaps.LatLng(p.latitude, p.longitude))
            .toList(),
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
            target: gmaps.LatLng(
              _selectedPlaces.first.latitude,
              _selectedPlaces.first.longitude,
            ),
            zoom: 12,
          ),
          style: gbtGoogleMapStyleForDarkMode(isDark),
          polylines: {polyline},
          markers: markers,
        ),
      );
    }
  }

  // EN: Open the real place picker sheet backed by placesListControllerProvider.
  // KO: placesListControllerProvider를 사용한 실제 장소 선택 시트를 엽니다.
  Future<void> _showPlacePicker() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _PlacePickerSheet(
        selectedIds: _selectedPlaces.map((p) => p.id).toSet(),
        onAdd: _addPlace,
      ),
    );
  }
}

// ================================================
// EN: Place picker bottom sheet — search + list from placesListControllerProvider.
// KO: 장소 선택 바텀시트 — placesListControllerProvider 기반 검색 + 목록.
// ================================================
class _PlacePickerSheet extends ConsumerStatefulWidget {
  const _PlacePickerSheet({required this.selectedIds, required this.onAdd});

  final Set<String> selectedIds;
  final ValueChanged<PlaceSummary> onAdd;

  @override
  ConsumerState<_PlacePickerSheet> createState() => _PlacePickerSheetState();
}

class _PlacePickerSheetState extends ConsumerState<_PlacePickerSheet> {
  final _searchController = TextEditingController();
  String _query = '';
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  List<PlaceSummary> _filtered(List<PlaceSummary> all) {
    if (_query.isEmpty) return all;
    final q = _query.toLowerCase();
    return all
        .where(
          (p) =>
              p.name.toLowerCase().contains(q) ||
              p.address.toLowerCase().contains(q),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final placesAsync = ref.watch(placesListControllerProvider);
    final primaryColor = isDark ? GBTColors.darkPrimary : GBTColors.primary;
    final tertiaryColor = isDark
        ? GBTColors.darkTextTertiary
        : GBTColors.textTertiary;
    final borderColor = isDark ? GBTColors.darkBorder : GBTColors.border;

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            // EN: Header — title + search field
            // KO: 헤더 — 제목 + 검색 필드
            Padding(
              padding: const EdgeInsets.fromLTRB(
                GBTSpacing.md,
                0,
                GBTSpacing.md,
                GBTSpacing.sm,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '성지 장소 추가',
                    style: GBTTypography.titleMedium.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: GBTSpacing.sm),
                  // EN: Search field
                  // KO: 검색 필드
                  Container(
                    decoration: BoxDecoration(
                      color: isDark
                          ? GBTColors.darkSurfaceVariant
                          : GBTColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(GBTSpacing.radiusMd),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (v) {
                        _debounce?.cancel();
                        _debounce = Timer(const Duration(milliseconds: 300), () {
                          if (mounted) {
                            setState(() => _query = v.trim());
                          }
                        });
                      },
                      style: GBTTypography.bodyMedium,
                      decoration: InputDecoration(
                        hintText: '장소명 또는 주소로 검색',
                        hintStyle: GBTTypography.bodyMedium.copyWith(
                          color: tertiaryColor,
                        ),
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          color: tertiaryColor,
                          size: 20,
                        ),
                        suffixIcon: _query.isNotEmpty
                            ? IconButton(
                                icon: Icon(
                                  Icons.close_rounded,
                                  size: 18,
                                  color: tertiaryColor,
                                ),
                                onPressed: () {
                                  _debounce?.cancel();
                                  _searchController.clear();
                                  setState(() => _query = '');
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: GBTSpacing.md,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: borderColor.withValues(alpha: 0.5)),
            // EN: Place list
            // KO: 장소 목록
            Expanded(
              child: placesAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                error: (e, _) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(GBTSpacing.xl),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.cloud_off_rounded,
                          size: 40,
                          color: tertiaryColor,
                        ),
                        const SizedBox(height: GBTSpacing.md),
                        Text(
                          '장소를 불러오지 못했어요',
                          style: GBTTypography.bodyMedium.copyWith(
                            color: tertiaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                data: (all) {
                  final places = _filtered(all);
                  if (places.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(GBTSpacing.xl),
                        child: Text(
                          _query.isEmpty
                              ? '등록된 장소가 없어요'
                              : '"$_query" 검색 결과가 없어요',
                          style: GBTTypography.bodyMedium.copyWith(
                            color: tertiaryColor,
                          ),
                        ),
                      ),
                    );
                  }
                  return ListView.separated(
                    controller: scrollController,
                    padding: const EdgeInsets.only(bottom: GBTSpacing.xl),
                    itemCount: places.length,
                    separatorBuilder: (_, __) => Divider(
                      height: 1,
                      indent: GBTSpacing.md,
                      endIndent: GBTSpacing.md,
                      color: borderColor.withValues(alpha: 0.4),
                    ),
                    itemBuilder: (context, index) {
                      final place = places[index];
                      final isAdded = widget.selectedIds.contains(place.id);
                      return _PlacePickerItem(
                        place: place,
                        isAdded: isAdded,
                        primaryColor: primaryColor,
                        tertiaryColor: tertiaryColor,
                        onTap: isAdded
                            ? null
                            : () {
                                widget.onAdd(place);
                                Navigator.of(context).pop();
                              },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

// EN: Single place row in the picker sheet.
// KO: 선택 시트의 단일 장소 행.
class _PlacePickerItem extends StatelessWidget {
  const _PlacePickerItem({
    required this.place,
    required this.isAdded,
    required this.primaryColor,
    required this.tertiaryColor,
    required this.onTap,
  });

  final PlaceSummary place;
  final bool isAdded;
  final Color primaryColor;
  final Color tertiaryColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final contentColor = isDark
        ? (isAdded ? GBTColors.darkTextTertiary : GBTColors.darkTextPrimary)
        : (isAdded ? GBTColors.textTertiary : GBTColors.textPrimary);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: GBTSpacing.md,
          vertical: 10,
        ),
        child: Row(
          children: [
            // EN: Place thumbnail or placeholder icon
            // KO: 장소 썸네일 또는 플레이스홀더 아이콘
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: place.imageUrl != null && place.imageUrl!.isNotEmpty
                  ? SizedBox(
                      width: 48,
                      height: 48,
                      child: GBTImage(
                        imageUrl: place.imageUrl!,
                        fit: BoxFit.cover,
                        semanticLabel: '${place.name} 이미지',
                      ),
                    )
                  : Container(
                      width: 48,
                      height: 48,
                      color: isDark
                          ? GBTColors.darkSurfaceVariant
                          : GBTColors.surfaceVariant,
                      child: Icon(
                        Icons.place_rounded,
                        size: 22,
                        color: tertiaryColor,
                      ),
                    ),
            ),
            const SizedBox(width: GBTSpacing.sm),
            // EN: Place name + address
            // KO: 장소명 + 주소
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    place.name,
                    style: GBTTypography.labelMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: contentColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    place.address,
                    style: GBTTypography.labelSmall.copyWith(
                      color: tertiaryColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: GBTSpacing.sm),
            // EN: Add button or added checkmark
            // KO: 추가 버튼 또는 추가됨 체크
            isAdded
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle_rounded,
                        size: 18,
                        color: primaryColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '추가됨',
                        style: GBTTypography.labelSmall.copyWith(
                          color: primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  )
                : Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: GBTSpacing.sm,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(
                        GBTSpacing.radiusFull,
                      ),
                    ),
                    child: Text(
                      '추가',
                      style: GBTTypography.labelSmall.copyWith(
                        color: primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
