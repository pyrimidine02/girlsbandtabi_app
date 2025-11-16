import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_spacing.dart';
import '../../models/place_model.dart' as model;
import '../../providers/content_filter_provider.dart';
import '../../providers/places_api_provider.dart';
import '../../widgets/flow_components.dart';

/// EN: Map screen showing places with optional initial place selection.
/// KO: 선택적 초기 장소 선택과 함께 장소들을 보여주는 지도 화면.
class PlaceMapScreen extends ConsumerStatefulWidget {
  const PlaceMapScreen({
    super.key,
    this.initialPlaceId,
  });

  final String? initialPlaceId;

  @override
  ConsumerState<PlaceMapScreen> createState() => _PlaceMapScreenState();
}

class _PlaceMapScreenState extends ConsumerState<PlaceMapScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  model.PlaceSummary? _selectedPlace;
  bool _showPlaceDetails = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final placesAsync = ref.watch(placesPageProvider);
    final selectedProjectName = ref.watch(selectedProjectNameProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_rounded),
          style: IconButton.styleFrom(
            backgroundColor: theme.colorScheme.surface.withValues(alpha: 0.9),
          ),
        ),
        title: Text(
          'Places Map',
          style: theme.textTheme.titleLarge,
        ),
        actions: [
          IconButton(
            onPressed: () => context.push('/places'),
            icon: const Icon(Icons.list_rounded),
            tooltip: '목록으로 보기',
            style: IconButton.styleFrom(
              backgroundColor: theme.colorScheme.surface.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: FlowGradientBackground(
        child: Stack(
          children: [
            // EN: Main map content area
            // KO: 메인 지도 콘텐츠 영역
            FadeTransition(
              opacity: _fadeAnimation,
              child: placesAsync.when(
                data: (page) => _buildMapContent(page.places, theme),
                loading: () => _buildLoadingView(),
                error: (error, _) => _buildErrorView(error.toString()),
              ),
            ),

            // EN: Project selection overlay
            // KO: 프로젝트 선택 오버레이
            Positioned(
              top: 100,
              left: kSpacingMedium,
              right: kSpacingMedium,
              child: _buildProjectSelector(selectedProjectName, theme),
            ),

            // EN: Place details bottom sheet
            // KO: 장소 상세정보 하단 시트
            if (_showPlaceDetails && _selectedPlace != null)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: _buildPlaceDetailsSheet(_selectedPlace!, theme),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapContent(List<model.PlaceSummary> places, ThemeData theme) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Stack(
        children: [
          // EN: Mock map background with grid pattern
          // KO: 격자 패턴이 있는 모의 지도 배경
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary.withValues(alpha: 0.05),
                  theme.colorScheme.secondary.withValues(alpha: 0.03),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          
          // EN: Grid overlay for map effect
          // KO: 지도 효과를 위한 격자 오버레이
          CustomPaint(
            size: Size.infinite,
            painter: _MapGridPainter(theme.colorScheme.outline.withValues(alpha: 0.1)),
          ),

          // EN: Places markers
          // KO: 장소 마커들
          ...places.asMap().entries.map((entry) {
            final index = entry.key;
            final place = entry.value;
            return _buildPlaceMarker(place, index, theme);
          }).toList(),

          // EN: Map controls
          // KO: 지도 컨트롤
          Positioned(
            bottom: 120,
            right: kSpacingMedium,
            child: Column(
              children: [
                FloatingActionButton(
                  mini: true,
                  onPressed: () => _zoomIn(),
                  backgroundColor: theme.colorScheme.surface.withValues(alpha: 0.9),
                  child: const Icon(Icons.add_rounded),
                ),
                const SizedBox(height: kSpacingXSmall),
                FloatingActionButton(
                  mini: true,
                  onPressed: () => _zoomOut(),
                  backgroundColor: theme.colorScheme.surface.withValues(alpha: 0.9),
                  child: const Icon(Icons.remove_rounded),
                ),
                const SizedBox(height: kSpacingXSmall),
                FloatingActionButton(
                  mini: true,
                  onPressed: () => _centerMap(),
                  backgroundColor: theme.colorScheme.surface.withValues(alpha: 0.9),
                  child: const Icon(Icons.my_location_rounded),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceMarker(model.PlaceSummary place, int index, ThemeData theme) {
    final isSelected = _selectedPlace?.id == place.id;
    final baseX = 100.0 + (index % 3) * 80.0;
    final baseY = 200.0 + (index ~/ 3) * 100.0;
    
    return Positioned(
      left: baseX,
      top: baseY,
      child: GestureDetector(
        onTap: () => _selectPlace(place),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: Matrix4.identity()..scale(isSelected ? 1.2 : 1.0),
          child: Container(
            width: isSelected ? 50 : 40,
            height: isSelected ? 50 : 40,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              _getPlaceTypeIcon(place.type),
              color: Colors.white,
              size: isSelected ? 24 : 20,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProjectSelector(String? selectedProjectName, ThemeData theme) {
    return FlowCard(
      padding: const EdgeInsets.symmetric(
        horizontal: kSpacingMedium,
        vertical: kSpacingSmall,
      ),
      child: Row(
        children: [
          Icon(
            Icons.layers_outlined,
            size: 20,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: kSpacingXSmall),
          Expanded(
            child: Text(
              selectedProjectName ?? '전체 프로젝트',
              style: theme.textTheme.titleSmall,
            ),
          ),
          const Icon(Icons.chevron_right_rounded, size: 18),
        ],
      ),
    );
  }

  Widget _buildPlaceDetailsSheet(model.PlaceSummary place, ThemeData theme) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 1),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      )),
      child: Container(
        margin: const EdgeInsets.all(kSpacingMedium),
        child: FlowCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      image: place.thumbnailUrl != null
                          ? DecorationImage(
                              image: NetworkImage(place.thumbnailUrl!),
                              fit: BoxFit.cover,
                            )
                          : null,
                      gradient: place.thumbnailUrl == null
                          ? LinearGradient(
                              colors: [
                                theme.colorScheme.primary.withValues(alpha: 0.2),
                                theme.colorScheme.secondary.withValues(alpha: 0.18),
                              ],
                            )
                          : null,
                    ),
                    child: place.thumbnailUrl == null
                        ? Icon(
                            _getPlaceTypeIcon(place.type),
                            color: theme.colorScheme.primary,
                          )
                        : null,
                  ),
                  const SizedBox(width: kSpacingMedium),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          place.name,
                          style: theme.textTheme.titleMedium,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: kSpacingXXSmall),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: kSpacingXSmall,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _getPlaceTypeLabel(place.type),
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => setState(() {
                      _showPlaceDetails = false;
                      _selectedPlace = null;
                    }),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: kSpacingMedium),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => context.push('/places/${place.id}'),
                      icon: const Icon(Icons.info_outline_rounded, size: 18),
                      label: const Text('상세 보기'),
                    ),
                  ),
                  const SizedBox(width: kSpacingXSmall),
                  OutlinedButton.icon(
                    onPressed: () => _navigateToPlace(place),
                    icon: const Icon(Icons.directions_rounded, size: 18),
                    label: const Text('길찾기'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: kSpacingMedium),
          Text('지도를 로딩 중...'),
        ],
      ),
    );
  }

  Widget _buildErrorView(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(kSpacingLarge),
        child: FlowCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.map_outlined, size: 64),
              const SizedBox(height: kSpacingMedium),
              Text(
                '지도를 불러올 수 없습니다',
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: kSpacingXSmall),
              Text(
                error,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: kSpacingMedium),
              FilledButton.icon(
                onPressed: () {
                  ref.invalidate(placesPageProvider);
                },
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('다시 시도'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _selectPlace(model.PlaceSummary place) {
    setState(() {
      _selectedPlace = place;
      _showPlaceDetails = true;
    });
  }

  void _zoomIn() {
    // EN: Mock zoom in implementation
    // KO: 모의 줌 인 구현
    debugPrint('Zoom in');
  }

  void _zoomOut() {
    // EN: Mock zoom out implementation
    // KO: 모의 줌 아웃 구현
    debugPrint('Zoom out');
  }

  void _centerMap() {
    // EN: Mock center map implementation
    // KO: 모의 지도 중앙 정렬 구현
    debugPrint('Center map');
  }

  void _navigateToPlace(model.PlaceSummary place) {
    // EN: Mock navigation implementation
    // KO: 모의 네비게이션 구현
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${place.name}으로의 길찾기는 준비 중입니다'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

/// EN: Custom painter for map grid overlay.
/// KO: 지도 격자 오버레이를 위한 커스텀 페인터.
class _MapGridPainter extends CustomPainter {
  const _MapGridPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;

    const spacing = 50.0;

    // EN: Draw vertical lines
    // KO: 수직선 그리기
    for (double x = 0; x <= size.width; x += spacing) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }

    // EN: Draw horizontal lines
    // KO: 수평선 그리기
    for (double y = 0; y <= size.height; y += spacing) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// EN: Helper functions for place types
// KO: 장소 타입을 위한 헬퍼 함수들
IconData _getPlaceTypeIcon(model.PlaceType type) {
  switch (type) {
    case model.PlaceType.concertVenue:
      return Icons.mic_external_on_rounded;
    case model.PlaceType.cafeCollaboration:
      return Icons.local_cafe_rounded;
    case model.PlaceType.animeLocation:
      return Icons.movie_outlined;
    case model.PlaceType.characterShop:
      return Icons.storefront_rounded;
    case model.PlaceType.other:
      return Icons.location_city_rounded;
  }
}

String _getPlaceTypeLabel(model.PlaceType type) {
  switch (type) {
    case model.PlaceType.concertVenue:
      return '라이브 하우스';
    case model.PlaceType.cafeCollaboration:
      return '콜라보 카페';
    case model.PlaceType.animeLocation:
      return '작중 장소';
    case model.PlaceType.characterShop:
      return '샵 & 굿즈';
    case model.PlaceType.other:
      return '기타 장소';
  }
}
