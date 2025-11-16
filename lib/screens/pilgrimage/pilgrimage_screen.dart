import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/favorite_model.dart';
import '../../models/place_model.dart' as model;
import '../../providers/content_filter_provider.dart';
import '../../providers/favorites_provider.dart';
import '../../providers/places_api_provider.dart';
import '../../widgets/flow_components.dart';
import '../../widgets/project_band_sheet.dart';

class PilgrimageScreen extends ConsumerWidget {
  const PilgrimageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(favoritesBootstrapProvider);
    final placesAsync = ref.watch(placesPageProvider);
    final selectedProjectName = ref.watch(selectedProjectNameProvider);
    final selectedBandName = ref.watch(selectedBandNameProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: FlowGradientBackground(
        child: SafeArea(
          bottom: false,
          child: placesAsync.when(
            data: (page) => _PilgrimageContent(
              places: page.places,
              selectedProjectName: selectedProjectName,
              selectedBandName: selectedBandName,
            ),
            loading: () => const Center(
              child: CircularProgressIndicator(),
            ),
            error: (e, _) => _PilgrimageError(
              message: '성지 목록을 불러오지 못했습니다.\n$e',
              onRetry: () => ref.invalidate(placesPageProvider),
            ),
          ),
        ),
      ),
    );
  }
}

class _PilgrimageContent extends ConsumerWidget {
  const _PilgrimageContent({
    required this.places,
    required this.selectedProjectName,
    required this.selectedBandName,
  });

  final List<model.PlaceSummary> places;
  final String? selectedProjectName;
  final String? selectedBandName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
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
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            sliver: SliverToBoxAdapter(
              child: FlowCard(
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
                    FlowPill(
                      label: selectedProjectName ?? '전체 프로젝트',
                      leading: const Icon(Icons.layers_outlined, size: 16),
                      trailing: const Icon(Icons.chevron_right_rounded, size: 18),
                      onTap: () => showProjectBandSelector(
                        context,
                        ref,
                        onApplied: () => ref.invalidate(placesPageProvider),
                      ),
                      backgroundColor:
                          theme.colorScheme.surface.withValues(alpha: 0.72),
                    ),
                    if (selectedBandName != null) ...[
                      const SizedBox(height: 12),
                      FlowPill(
                        label: selectedBandName ?? '전체 밴드',
                        leading: const Icon(Icons.music_note_outlined, size: 16),
                        backgroundColor:
                            theme.colorScheme.secondary.withValues(alpha: 0.18),
                        onTap: () => showProjectBandSelector(
                          context,
                          ref,
                          onApplied: () => ref.invalidate(placesPageProvider),
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    Text(
                      '성지순례',
                      style: theme.textTheme.headlineLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '밴드의 여정을 따라, 팬들의 발자취를 연결해 보세요.',
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 18),
                    FilledButton.tonalIcon(
                      onPressed: () => context.push('/all'),
                      icon: const Icon(Icons.timeline_rounded),
                      label: const Text('내 여정 살펴보기'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 80),
            sliver: SliverList.separated(
              itemBuilder: (context, index) {
                final place = places[index];
                return _PlaceListItem(place: place);
              },
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemCount: places.length,
            ),
          ),
        ],
      ),
    );
  }
}

class _PlaceListItem extends ConsumerWidget {
  const _PlaceListItem({required this.place});

  final model.PlaceSummary place;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final favoriteKey = FavoriteKey(FavoriteEntityType.place, place.id);
    final isFavorite = ref.watch(isFavoriteProvider(favoriteKey));
    final favoriteController = ref.watch(favoriteControllerProvider);

    return FlowCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 160,
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
                      gradient: LinearGradient(
                        colors: [
                          theme.colorScheme.primary.withValues(alpha: 0.2),
                          theme.colorScheme.secondary.withValues(alpha: 0.18),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.landscape_outlined,
                        size: 48,
                        color: Colors.white70,
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      _placeTypeIcon(place.type),
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _placeTypeLabel(place.type),
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () async {
                        final toggled = await favoriteController.toggle(
                          FavoriteEntityType.place,
                          place.id,
                        );
                        final message = toggled
                            ? '즐겨찾기에 추가했습니다.'
                            : '즐겨찾기에서 제거했습니다.';
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context)
                            .showSnackBar(SnackBar(content: Text(message)));
                      },
                      icon: Icon(
                        isFavorite
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        color: isFavorite
                            ? theme.colorScheme.error
                            : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  place.name,
                  style: theme.textTheme.headlineSmall,
                ),
                const SizedBox(height: 6),
                const SizedBox(height: 16),
                Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => context.push('/places/${place.id}'),
                      icon: const Icon(Icons.open_in_new_rounded),
                      label: const Text('상세 보기'),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.tonal(
                        onPressed: () => context.push('/places/${place.id}'),
                        child: const Text('지도 열기'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _placeTypeIcon(model.PlaceType type) {
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

  String _placeTypeLabel(model.PlaceType type) {
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
        return '기타';
    }
  }
}

class _PilgrimageError extends StatelessWidget {
  const _PilgrimageError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 40),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          FilledButton(onPressed: onRetry, child: const Text('다시 시도')),
        ],
      ),
    );
  }
}
