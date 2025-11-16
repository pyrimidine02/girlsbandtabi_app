import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_spacing.dart';
import '../../models/favorite_model.dart';
import '../../models/place_model.dart' as model;
import '../../providers/content_filter_provider.dart';
import '../../providers/favorites_provider.dart';
import '../../providers/places_api_provider.dart';
import '../../widgets/flow_components.dart';
import '../../widgets/project_band_sheet.dart';

/// EN: Main places list screen with search, filters, and grid/list view.
/// KO: 검색, 필터, 그리드/리스트 뷰를 포함한 메인 장소 목록 화면.
class PlaceListScreen extends ConsumerStatefulWidget {
  const PlaceListScreen({super.key});

  @override
  ConsumerState<PlaceListScreen> createState() => _PlaceListScreenState();
}

class _PlaceListScreenState extends ConsumerState<PlaceListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isGridView = true;

  @override
  void initState() {
    super.initState();
    // EN: Initialize favorites bootstrap
    // KO: 즐겨찾기 부트스트랩 초기화
    ref.read(favoritesBootstrapProvider);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final placesAsync = ref.watch(placesPageProvider);
    final selectedProjectName = ref.watch(selectedProjectNameProvider);
    final selectedBandName = ref.watch(selectedBandNameProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: FlowGradientBackground(
        child: SafeArea(
          bottom: false,
          child: placesAsync.when(
            data: (page) => _buildPlacesContent(
              context,
              page.places,
              selectedProjectName,
              selectedBandName,
              theme,
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => _buildErrorView(error.toString()),
          ),
        ),
      ),
    );
  }

  Widget _buildPlacesContent(
    BuildContext context,
    List<model.PlaceSummary> places,
    String? selectedProjectName,
    String? selectedBandName,
    ThemeData theme,
  ) {
    // EN: Filter places based on search query
    // KO: 검색 쿼리를 기반으로 장소 필터링
    final filteredPlaces = _searchQuery.isEmpty
        ? places
        : places.where((place) =>
            place.name.toLowerCase().contains(_searchQuery.toLowerCase())).toList();

    return RefreshIndicator(
      color: theme.colorScheme.primary,
      onRefresh: () async {
        ref.invalidate(placesPageProvider);
        await ref.read(placesPageProvider.future);
      },
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          // EN: Header with project/band selection and search
          // KO: 프로젝트/밴드 선택 및 검색이 포함된 헤더
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              kSpacingMedium,
              kSpacingMedium,
              kSpacingMedium,
              kSpacingSmall,
            ),
            sliver: SliverToBoxAdapter(
              child: _buildHeaderCard(
                selectedProjectName,
                selectedBandName,
                theme,
              ),
            ),
          ),

          // EN: Search and view toggle controls
          // KO: 검색 및 뷰 전환 컨트롤
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: kSpacingMedium),
            sliver: SliverToBoxAdapter(
              child: _buildSearchAndControls(theme),
            ),
          ),

          // EN: Places grid or list
          // KO: 장소 그리드 또는 리스트
          if (filteredPlaces.isEmpty)
            SliverFillRemaining(
              child: _buildEmptyState(_searchQuery.isNotEmpty),
            )
          else
            _isGridView
                ? _buildPlacesGrid(filteredPlaces)
                : _buildPlacesList(filteredPlaces),
        ],
      ),
    );
  }

  Widget _buildHeaderCard(
    String? selectedProjectName,
    String? selectedBandName,
    ThemeData theme,
  ) {
    return FlowCard(
      gradient: LinearGradient(
        colors: [
          theme.colorScheme.primary.withValues(alpha: 0.2),
          theme.colorScheme.secondary.withValues(alpha: 0.18),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Places',
                      style: theme.textTheme.headlineLarge,
                    ),
                    const SizedBox(height: kSpacingXXSmall),
                    Text(
                      '성지와 라이브 장소를 탐험해보세요',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => context.push('/places/map'),
                icon: const Icon(Icons.map_outlined),
                tooltip: '지도 보기',
                style: IconButton.styleFrom(
                  backgroundColor: theme.colorScheme.surface.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
          const SizedBox(height: kSpacingMedium),
          FlowPill(
            label: selectedProjectName ?? '전체 프로젝트',
            leading: const Icon(Icons.layers_outlined, size: 16),
            trailing: const Icon(Icons.chevron_right_rounded, size: 18),
            onTap: () => showProjectBandSelector(
              context,
              ref,
              onApplied: () => ref.invalidate(placesPageProvider),
            ),
            backgroundColor: theme.colorScheme.surface.withValues(alpha: 0.72),
          ),
          if (selectedBandName != null) ...[
            const SizedBox(height: kSpacingSmall),
            FlowPill(
              label: selectedBandName,
              leading: const Icon(Icons.music_note_outlined, size: 16),
              backgroundColor: theme.colorScheme.secondary.withValues(alpha: 0.18),
              onTap: () => showProjectBandSelector(
                context,
                ref,
                onApplied: () => ref.invalidate(placesPageProvider),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSearchAndControls(ThemeData theme) {
    return Column(
      children: [
        const SizedBox(height: kSpacingMedium),
        // EN: Search bar
        // KO: 검색 바
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.2),
            ),
          ),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: '장소 이름으로 검색...',
              hintStyle: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              prefixIcon: Semantics(
                label: '검색',
                child: const Icon(Icons.search_rounded),
              ),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                      icon: const Icon(Icons.clear_rounded),
                      tooltip: '검색어 지우기',
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: kSpacingMedium,
                vertical: kSpacingMedium,
              ),
            ),
            onChanged: (value) => setState(() => _searchQuery = value),
          ),
        ),
        const SizedBox(height: kSpacingSmall),
        // EN: View toggle
        // KO: 뷰 전환
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment<bool>(
                  value: true,
                  icon: Icon(Icons.grid_view_rounded, size: 18),
                  label: Text('Grid'),
                ),
                ButtonSegment<bool>(
                  value: false,
                  icon: Icon(Icons.view_list_rounded, size: 18),
                  label: Text('List'),
                ),
              ],
              selected: {_isGridView},
              onSelectionChanged: (selection) {
                setState(() => _isGridView = selection.first);
              },
              showSelectedIcon: false,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPlacesGrid(List<model.PlaceSummary> places) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(
        kSpacingMedium,
        kSpacingMedium,
        kSpacingMedium,
        100,
      ),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.8,
          crossAxisSpacing: kSpacingMedium,
          mainAxisSpacing: kSpacingMedium,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final place = places[index];
            return _PlaceGridItem(place: place);
          },
          childCount: places.length,
        ),
      ),
    );
  }

  Widget _buildPlacesList(List<model.PlaceSummary> places) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(
        kSpacingMedium,
        kSpacingMedium,
        kSpacingMedium,
        100,
      ),
      sliver: SliverList.separated(
        itemBuilder: (context, index) {
          final place = places[index];
          return _PlaceListItem(place: place);
        },
        separatorBuilder: (_, __) => const SizedBox(height: kSpacingMedium),
        itemCount: places.length,
      ),
    );
  }

  Widget _buildEmptyState(bool isSearching) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isSearching ? Icons.search_off_rounded : Icons.place_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
          ),
          const SizedBox(height: kSpacingMedium),
          Text(
            isSearching ? '검색 결과가 없습니다' : '표시할 장소가 없습니다',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: kSpacingXSmall),
          Text(
            isSearching
                ? '다른 검색어를 시도해보세요'
                : '프로젝트나 밴드를 선택해보세요',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(kSpacingLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64),
            const SizedBox(height: kSpacingMedium),
            Text(
              '데이터를 불러올 수 없습니다',
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
    );
  }
}

/// EN: Grid item widget for place display.
/// KO: 장소 표시를 위한 그리드 아이템 위젯.
class _PlaceGridItem extends ConsumerWidget {
  const _PlaceGridItem({required this.place});

  final model.PlaceSummary place;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final favoriteKey = FavoriteKey(FavoriteEntityType.place, place.id);
    final isFavorite = ref.watch(isFavoriteProvider(favoriteKey));

    return Semantics(
      label: '${place.name}, ${_getPlaceTypeLabel(place.type)} 장소',
      hint: '탭하여 상세 정보 보기',
      child: FlowCard(
        padding: EdgeInsets.zero,
        onTap: () => context.push('/places/${place.id}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          // EN: Place image
          // KO: 장소 이미지
          Expanded(
            flex: 3,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                image: place.thumbnailUrl != null
                    ? DecorationImage(
                        image: NetworkImage(place.thumbnailUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: place.thumbnailUrl == null
                  ? Container(
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                        gradient: LinearGradient(
                          colors: [
                            theme.colorScheme.primary.withValues(alpha: 0.2),
                            theme.colorScheme.secondary.withValues(alpha: 0.18),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          _getPlaceTypeIcon(place.type),
                          size: 32,
                          color: Colors.white70,
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ),
          
          // EN: Place info
          // KO: 장소 정보
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(kSpacingSmall),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          place.name,
                          style: theme.textTheme.titleSmall,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      _FavoriteButton(
                        isFavorite: isFavorite,
                        onToggle: () => _toggleFavorite(ref, place.id),
                      ),
                    ],
                  ),
                  const Spacer(),
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
          ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleFavorite(WidgetRef ref, String placeId) async {
    final controller = ref.read(favoriteControllerProvider);
    try {
      await controller.toggle(FavoriteEntityType.place, placeId);
    } catch (e) {
      // EN: Error handling - could show snackbar
      // KO: 오류 처리 - 스낵바를 표시할 수 있음
      debugPrint('Error toggling favorite: $e');
    }
  }
}

/// EN: List item widget for place display.
/// KO: 장소 표시를 위한 리스트 아이템 위젯.
class _PlaceListItem extends ConsumerWidget {
  const _PlaceListItem({required this.place});

  final model.PlaceSummary place;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final favoriteKey = FavoriteKey(FavoriteEntityType.place, place.id);
    final isFavorite = ref.watch(isFavoriteProvider(favoriteKey));

    return Semantics(
      label: '${place.name}, ${_getPlaceTypeLabel(place.type)} 장소',
      hint: '탭하여 상세 정보 보기',
      child: FlowCard(
        padding: EdgeInsets.zero,
        onTap: () => context.push('/places/${place.id}'),
        child: Row(
          children: [
          // EN: Place image
          // KO: 장소 이미지
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(24)),
              image: place.thumbnailUrl != null
                  ? DecorationImage(
                      image: NetworkImage(place.thumbnailUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: place.thumbnailUrl == null
                ? Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.horizontal(left: Radius.circular(24)),
                      gradient: LinearGradient(
                        colors: [
                          theme.colorScheme.primary.withValues(alpha: 0.2),
                          theme.colorScheme.secondary.withValues(alpha: 0.18),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        _getPlaceTypeIcon(place.type),
                        size: 24,
                        color: Colors.white70,
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          
          // EN: Place info
          // KO: 장소 정보
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(kSpacingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          place.name,
                          style: theme.textTheme.titleMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      _FavoriteButton(
                        isFavorite: isFavorite,
                        onToggle: () => _toggleFavorite(ref, place.id),
                      ),
                    ],
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
          ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleFavorite(WidgetRef ref, String placeId) async {
    final controller = ref.read(favoriteControllerProvider);
    try {
      await controller.toggle(FavoriteEntityType.place, placeId);
    } catch (e) {
      debugPrint('Error toggling favorite: $e');
    }
  }
}

/// EN: Animated favorite button widget.
/// KO: 애니메이션 즐겨찾기 버튼 위젯.
class _FavoriteButton extends StatefulWidget {
  const _FavoriteButton({
    required this.isFavorite,
    required this.onToggle,
  });

  final bool isFavorite;
  final VoidCallback onToggle;

  @override
  State<_FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<_FavoriteButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: IconButton(
            onPressed: () {
              _animationController.forward().then((_) {
                _animationController.reverse();
              });
              widget.onToggle();
            },
            icon: Icon(
              widget.isFavorite
                  ? Icons.favorite_rounded
                  : Icons.favorite_border_rounded,
              color: widget.isFavorite
                  ? theme.colorScheme.error
                  : theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            iconSize: 18,
            constraints: const BoxConstraints(
              minWidth: 28,
              minHeight: 28,
            ),
            padding: EdgeInsets.zero,
            tooltip: widget.isFavorite ? '즐겨찾기 해제' : '즐겨찾기 추가',
          ),
        );
      },
    );
  }
}

// EN: Helper functions for place type icons and labels
// KO: 장소 타입 아이콘 및 라벨을 위한 헬퍼 함수들
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
      return '라이브';
    case model.PlaceType.cafeCollaboration:
      return '카페';
    case model.PlaceType.animeLocation:
      return '작중';
    case model.PlaceType.characterShop:
      return '샵';
    case model.PlaceType.other:
      return '기타';
  }
}
