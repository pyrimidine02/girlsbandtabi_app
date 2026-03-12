/// EN: Music catalog tab — redesigned albums/songs browser for the Info page.
/// KO: 악곡 카탈로그 탭 — 정보 페이지 앨범·곡 탐색 뷰 완전 리디자인.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/localization/locale_text.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/gbt_colors.dart';
import '../../../../core/theme/gbt_spacing.dart';
import '../../../../core/theme/gbt_typography.dart';
import '../../../../core/widgets/common/gbt_image.dart';
import '../../application/music_controller.dart';
import '../../domain/entities/music_entities.dart';
import '../../../projects/application/projects_controller.dart';

// ─────────────────────────────────────────────────────────────────────────────
// EN: Pink accent — music / fandom energy.
// KO: 핑크 액센트 — 음악/팬덤 감성.
// ─────────────────────────────────────────────────────────────────────────────
Color _accent(bool isDark) =>
    isDark ? GBTColors.darkSecondary : GBTColors.secondary;

String _errorMsg(BuildContext context, Object? e) {
  if (e is Failure) return e.userMessage;
  return context.l10n(
    ko: '데이터를 불러오지 못했습니다.',
    en: 'Failed to load data.',
    ja: 'データの読み込みに失敗しました。',
  );
}

String _formatMs(int ms) {
  final s = (ms / 1000).floor();
  return '${(s ~/ 60).toString().padLeft(2, '0')}:'
      '${(s % 60).toString().padLeft(2, '0')}';
}

// ─────────────────────────────────────────────────────────────────────────────
// MAIN WIDGET
// ─────────────────────────────────────────────────────────────────────────────

/// EN: Music catalog tab — album grid + track list with segmented switcher.
/// KO: 악곡 카탈로그 탭 — 세그먼트 스위처로 앨범 그리드·트랙 목록을 탐색합니다.
class MusicCatalogTab extends ConsumerStatefulWidget {
  const MusicCatalogTab({super.key});

  @override
  ConsumerState<MusicCatalogTab> createState() => _MusicCatalogTabState();
}

class _MusicCatalogTabState extends ConsumerState<MusicCatalogTab> {
  // EN: 0 = Albums, 1 = Songs
  // KO: 0 = 앨범, 1 = 곡
  int _viewIndex = 0;
  String? _selectedUnitKey;
  late final ScrollController _albumScroll;
  late final ScrollController _songScroll;

  @override
  void initState() {
    super.initState();
    _albumScroll = ScrollController()..addListener(_onAlbumScroll);
    _songScroll = ScrollController()..addListener(_onSongScroll);
  }

  @override
  void dispose() {
    _albumScroll
      ..removeListener(_onAlbumScroll)
      ..dispose();
    _songScroll
      ..removeListener(_onSongScroll)
      ..dispose();
    super.dispose();
  }

  void _onAlbumScroll() {
    if (!_albumScroll.hasClients) return;
    if (_albumScroll.position.extentAfter > 240) return;
    final pk = ref.read(projectSelectionControllerProvider).projectKey;
    if (pk == null || pk.isEmpty) return;
    final s = ref.read(musicAlbumsControllerProvider(pk));
    if (s.isLoading || s.isLoadingMore || !s.hasNext) return;
    ref.read(musicAlbumsControllerProvider(pk).notifier).loadMore();
  }

  void _onSongScroll() {
    if (!_songScroll.hasClients) return;
    if (_songScroll.position.extentAfter > 360) return;
    final pk = ref.read(projectSelectionControllerProvider).projectKey;
    if (pk == null || pk.isEmpty) return;
    final s = ref.read(musicSongsControllerProvider(pk));
    if (s.isLoading || s.isLoadingMore || !s.hasNext) return;
    ref.read(musicSongsControllerProvider(pk).notifier).loadMore();
  }

  String? _unitKey(MusicSongSummary s) {
    final id = s.primaryUnitId?.trim();
    if (id != null && id.isNotEmpty) return 'id:$id';
    final name = s.primaryUnitName?.trim();
    if (name != null && name.isNotEmpty) return 'name:$name';
    return null;
  }

  List<_UnitOption> _buildUnitOptions(List<MusicSongSummary> songs) {
    final order = <String>[];
    final labels = <String, String>{};
    final counts = <String, int>{};
    for (final song in songs) {
      final k = _unitKey(song);
      if (k == null) continue;
      if (!labels.containsKey(k)) {
        labels[k] = (song.primaryUnitName ?? '').trim().isNotEmpty
            ? song.primaryUnitName!.trim()
            : song.primaryUnitId ?? '';
        order.add(k);
      }
      counts[k] = (counts[k] ?? 0) + 1;
    }
    return order
        .map((k) => _UnitOption(key: k, label: labels[k]!, count: counts[k]!))
        .toList(growable: false);
  }

  Future<void> _openAlbumSheet(
    BuildContext ctx,
    String projectId,
    MusicAlbumSummary album,
  ) async {
    final key = (projectId: projectId, albumId: album.id);
    // EN: Returns the tapped songId so we can navigate AFTER the sheet closes,
    //     avoiding GoRouter state conflicts while a modal overlay is active.
    // KO: 탭한 songId를 반환해 시트가 닫힌 후에 이동합니다.
    //     모달 오버레이가 열려있는 동안 GoRouter 상태 충돌을 방지합니다.
    final selectedSongId = await showModalBottomSheet<String>(
      context: ctx,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Theme.of(ctx).brightness == Brightness.dark
          ? GBTColors.darkSurface
          : GBTColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(GBTSpacing.radiusXl),
        ),
      ),
      builder: (sheetCtx) => Consumer(
        builder: (context, ref, _) {
          final detailState = ref.watch(musicAlbumDetailProvider(key));
          final songsState = ref.watch(musicSongsControllerProvider(projectId));
          final isDark = Theme.of(context).brightness == Brightness.dark;
          final ac = _accent(isDark);
          return SafeArea(
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.72,
              child: detailState.when(
                loading: () => Center(
                  child: CircularProgressIndicator(color: ac),
                ),
                error: (e, _) => Center(
                  child: Text(
                    _errorMsg(context, e),
                    style: GBTTypography.bodyMedium.copyWith(
                      color: isDark
                          ? GBTColors.darkTextSecondary
                          : GBTColors.textSecondary,
                    ),
                  ),
                ),
                data: (detail) => _AlbumSheet(
                  detail: detail,
                  songsById: {for (final s in songsState.items) s.id: s},
                  isDark: isDark,
                  accent: ac,
                  projectId: projectId,
                  onSongTap: (songId) =>
                      Navigator.of(sheetCtx).pop(songId),
                ),
              ),
            ),
          );
        },
      ),
    );
    if (selectedSongId != null && ctx.mounted) {
      ctx.goToSongDetail(selectedSongId, projectId: projectId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final selection = ref.watch(projectSelectionControllerProvider);
    final projectKey = selection.projectKey ?? '';
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ac = _accent(isDark);

    if (projectKey.isEmpty) {
      return _EmptyProjectHero(isDark: isDark, accent: ac);
    }

    final albumsState = ref.watch(musicAlbumsControllerProvider(projectKey));
    final songsState = ref.watch(musicSongsControllerProvider(projectKey));
    final unitOptions = _buildUnitOptions(songsState.items);

    // EN: Reset filter key if no longer valid
    // KO: 유효하지 않은 필터 키는 초기화
    final validKey =
        unitOptions.any((o) => o.key == _selectedUnitKey)
            ? _selectedUnitKey
            : null;
    if (validKey != _selectedUnitKey && _selectedUnitKey != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _selectedUnitKey = null);
      });
    }

    final filteredSongs = validKey == null
        ? songsState.items
        : songsState.items.where((s) => _unitKey(s) == validKey).toList();
    final filteredAlbumIds = <String>{
      for (final s in filteredSongs)
        if ((s.albumId ?? '').trim().isNotEmpty) s.albumId!.trim(),
    };
    final filteredAlbums = validKey == null
        ? albumsState.items
        : albumsState.items
              .where((a) => filteredAlbumIds.contains(a.id))
              .toList(growable: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Segmented view switcher ───────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(
            GBTSpacing.pageHorizontal,
            GBTSpacing.md,
            GBTSpacing.pageHorizontal,
            GBTSpacing.xs,
          ),
          child: _ViewSwitcher(
            currentIndex: _viewIndex,
            isDark: isDark,
            accent: ac,
            albumCount: filteredAlbums.length,
            songCount: filteredSongs.length,
            onChanged: (i) => setState(() => _viewIndex = i),
          ),
        ),

        // ── Unit filter chips ─────────────────────────────────────
        if (unitOptions.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(
              left: GBTSpacing.pageHorizontal,
              right: GBTSpacing.pageHorizontal,
              top: GBTSpacing.xs2,
              bottom: GBTSpacing.xs,
            ),
            child: _UnitFilterBar(
              options: unitOptions,
              selectedKey: validKey,
              isDark: isDark,
              accent: ac,
              onSelected: (k) => setState(() => _selectedUnitKey = k),
            ),
          ),

        // ── Content area ─────────────────────────────────────────
        Expanded(
          child: _viewIndex == 0
              ? _AlbumsGrid(
                  albums: filteredAlbums,
                  isLoading: albumsState.isLoading && albumsState.items.isEmpty,
                  isLoadingMore: albumsState.isLoadingMore,
                  failure: albumsState.failure,
                  scrollController: _albumScroll,
                  isDark: isDark,
                  accent: ac,
                  onTap: (a) => _openAlbumSheet(context, projectKey, a),
                )
              : _SongsList(
                  songs: filteredSongs,
                  isLoading: songsState.isLoading && songsState.items.isEmpty,
                  isLoadingMore: songsState.isLoadingMore,
                  failure: songsState.failure,
                  scrollController: _songScroll,
                  isDark: isDark,
                  accent: ac,
                  onTap: (s) =>
                      context.goToSongDetail(s.id, projectId: projectKey),
                ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// VIEW SWITCHER
// ─────────────────────────────────────────────────────────────────────────────

class _ViewSwitcher extends StatelessWidget {
  const _ViewSwitcher({
    required this.currentIndex,
    required this.isDark,
    required this.accent,
    required this.albumCount,
    required this.songCount,
    required this.onChanged,
  });

  final int currentIndex;
  final bool isDark;
  final Color accent;
  final int albumCount;
  final int songCount;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? GBTColors.darkSurfaceVariant : GBTColors.surfaceVariant;
    final selectedBg = isDark ? GBTColors.darkSurface : GBTColors.surface;

    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(GBTSpacing.radiusMd),
      ),
      padding: const EdgeInsets.all(3),
      child: Row(
        children: [
          _SwitcherItem(
            label: context.l10n(ko: '앨범', en: 'Albums', ja: 'アルバム'),
            count: albumCount,
            selected: currentIndex == 0,
            isDark: isDark,
            accent: accent,
            selectedBg: selectedBg,
            onTap: () => onChanged(0),
          ),
          _SwitcherItem(
            label: context.l10n(ko: '곡', en: 'Songs', ja: '楽曲'),
            count: songCount,
            selected: currentIndex == 1,
            isDark: isDark,
            accent: accent,
            selectedBg: selectedBg,
            onTap: () => onChanged(1),
          ),
        ],
      ),
    );
  }
}

class _SwitcherItem extends StatelessWidget {
  const _SwitcherItem({
    required this.label,
    required this.count,
    required this.selected,
    required this.isDark,
    required this.accent,
    required this.selectedBg,
    required this.onTap,
  });

  final String label;
  final int count;
  final bool selected;
  final bool isDark;
  final Color accent;
  final Color selectedBg;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textColor = selected
        ? accent
        : (isDark ? GBTColors.darkTextSecondary : GBTColors.textSecondary);

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(
            color: selected ? selectedBg : Colors.transparent,
            borderRadius: BorderRadius.circular(GBTSpacing.radiusSm),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: GBTTypography.labelMedium.copyWith(
                  color: textColor,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
              if (count > 0) ...[
                const SizedBox(width: GBTSpacing.xs),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: selected
                        ? accent.withValues(alpha: 0.14)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(
                      GBTSpacing.radiusFull,
                    ),
                  ),
                  child: Text(
                    '$count',
                    style: GBTTypography.labelSmall.copyWith(
                      color: selected
                          ? accent
                          : (isDark
                                ? GBTColors.darkTextTertiary
                                : GBTColors.textTertiary),
                      fontWeight: FontWeight.w700,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// UNIT FILTER BAR
// ─────────────────────────────────────────────────────────────────────────────

class _UnitOption {
  const _UnitOption({
    required this.key,
    required this.label,
    required this.count,
  });

  final String key;
  final String label;
  final int count;
}

class _UnitFilterBar extends StatelessWidget {
  const _UnitFilterBar({
    required this.options,
    required this.selectedKey,
    required this.isDark,
    required this.accent,
    required this.onSelected,
  });

  final List<_UnitOption> options;
  final String? selectedKey;
  final bool isDark;
  final Color accent;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    final chipBg =
        isDark ? GBTColors.darkSurfaceVariant : GBTColors.surfaceVariant;
    final textSecondary =
        isDark ? GBTColors.darkTextSecondary : GBTColors.textSecondary;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _FilterChip(
            label: context.l10n(ko: '전체', en: 'All', ja: '全体'),
            selected: selectedKey == null,
            isDark: isDark,
            accent: accent,
            chipBg: chipBg,
            textSecondary: textSecondary,
            onTap: () => onSelected(null),
          ),
          ...options.map(
            (o) => Padding(
              padding: const EdgeInsets.only(left: GBTSpacing.xs),
              child: _FilterChip(
                label: '${o.label}  ${o.count}',
                selected: selectedKey == o.key,
                isDark: isDark,
                accent: accent,
                chipBg: chipBg,
                textSecondary: textSecondary,
                onTap: () => onSelected(o.key),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.isDark,
    required this.accent,
    required this.chipBg,
    required this.textSecondary,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final bool isDark;
  final Color accent;
  final Color chipBg;
  final Color textSecondary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: selected ? accent.withValues(alpha: 0.12) : chipBg,
          borderRadius: BorderRadius.circular(GBTSpacing.radiusFull),
          border: Border.all(
            color: selected
                ? accent.withValues(alpha: 0.45)
                : Colors.transparent,
          ),
        ),
        child: Text(
          label,
          style: GBTTypography.labelSmall.copyWith(
            color: selected ? accent : textSecondary,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ALBUMS GRID
// ─────────────────────────────────────────────────────────────────────────────

class _AlbumsGrid extends StatelessWidget {
  const _AlbumsGrid({
    required this.albums,
    required this.isLoading,
    required this.isLoadingMore,
    required this.failure,
    required this.scrollController,
    required this.isDark,
    required this.accent,
    required this.onTap,
  });

  final List<MusicAlbumSummary> albums;
  final bool isLoading;
  final bool isLoadingMore;
  final Failure? failure;
  final ScrollController scrollController;
  final bool isDark;
  final Color accent;
  final ValueChanged<MusicAlbumSummary> onTap;

  @override
  Widget build(BuildContext context) {
    final textSecondary =
        isDark ? GBTColors.darkTextSecondary : GBTColors.textSecondary;

    if (isLoading) {
      return Center(child: CircularProgressIndicator(color: accent));
    }

    if (failure != null && albums.isEmpty) {
      return Center(
        child: Text(
          failure!.userMessage,
          style: GBTTypography.bodySmall.copyWith(color: textSecondary),
          textAlign: TextAlign.center,
        ),
      );
    }

    if (albums.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.album_outlined,
              size: 48,
              color: accent.withValues(alpha: 0.3),
            ),
            const SizedBox(height: GBTSpacing.sm),
            Text(
              context.l10n(
                ko: '앨범 정보가 없습니다.',
                en: 'No albums available.',
                ja: 'アルバム情報がありません。',
              ),
              style: GBTTypography.bodySmall.copyWith(color: textSecondary),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(
        GBTSpacing.pageHorizontal,
        GBTSpacing.sm,
        GBTSpacing.pageHorizontal,
        GBTSpacing.xxl,
      ),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: GBTSpacing.sm,
        mainAxisSpacing: GBTSpacing.md,
        childAspectRatio: 0.72,
      ),
      itemCount: albums.length + (isLoadingMore ? 2 : 0),
      itemBuilder: (context, i) {
        if (i >= albums.length) {
          // EN: Loading placeholder tiles
          // KO: 추가 로딩 플레이스홀더 타일
          return _AlbumCardSkeleton(isDark: isDark);
        }
        return _AlbumCard(
          album: albums[i],
          isDark: isDark,
          accent: accent,
          onTap: () => onTap(albums[i]),
        );
      },
    );
  }
}

class _AlbumCard extends StatelessWidget {
  const _AlbumCard({
    required this.album,
    required this.isDark,
    required this.accent,
    required this.onTap,
  });

  final MusicAlbumSummary album;
  final bool isDark;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cardBg =
        isDark ? GBTColors.darkSurfaceVariant : GBTColors.surfaceVariant;
    final titleColor =
        isDark ? GBTColors.darkTextPrimary : GBTColors.textPrimary;
    final metaColor =
        isDark ? GBTColors.darkTextSecondary : GBTColors.textSecondary;
    final hasCover = (album.coverUrl ?? '').trim().isNotEmpty;
    final releaseYear = (album.releaseDate ?? '').trim().isNotEmpty
        ? album.releaseDate!.trim().split('-').first
        : null;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(GBTSpacing.radiusMd),
      child: InkWell(
        borderRadius: BorderRadius.circular(GBTSpacing.radiusMd),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(GBTSpacing.radiusMd),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Album art ──────────────────────────────────
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(GBTSpacing.radiusMd),
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (hasCover)
                        GBTImage(
                          imageUrl: album.coverUrl!,
                          fit: BoxFit.cover,
                          semanticLabel: '${album.title} cover',
                        )
                      else
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                accent.withValues(alpha: 0.18),
                                accent.withValues(alpha: 0.06),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.album_rounded,
                              size: 52,
                              color: accent.withValues(alpha: 0.35),
                            ),
                          ),
                        ),
                      // EN: Gradient overlay for readability
                      // KO: 가독성을 위한 그라디언트 오버레이
                      if (hasCover)
                        Positioned.fill(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withValues(alpha: 0.55),
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                stops: const [0.5, 1.0],
                              ),
                            ),
                          ),
                        ),
                      // EN: Album type badge
                      // KO: 앨범 타입 배지
                      if (album.type.trim().isNotEmpty)
                        Positioned(
                          top: GBTSpacing.xs,
                          left: GBTSpacing.xs,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: accent.withValues(alpha: 0.88),
                              borderRadius: BorderRadius.circular(
                                GBTSpacing.radiusFull,
                              ),
                            ),
                            child: Text(
                              album.type.toUpperCase(),
                              style: GBTTypography.caption.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 9,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // ── Info area ──────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  GBTSpacing.sm,
                  GBTSpacing.xs2,
                  GBTSpacing.sm,
                  GBTSpacing.sm,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      album.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GBTTypography.labelMedium.copyWith(
                        color: titleColor,
                        fontWeight: FontWeight.w700,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        if (releaseYear != null) ...[
                          Text(
                            releaseYear,
                            style: GBTTypography.caption.copyWith(
                              color: metaColor,
                            ),
                          ),
                          if (album.trackCount > 0) ...[
                            Text(
                              '  ·  ',
                              style: GBTTypography.caption.copyWith(
                                color: metaColor,
                              ),
                            ),
                          ],
                        ],
                        if (album.trackCount > 0)
                          Text(
                            context.l10n(
                              ko: '${album.trackCount}곡',
                              en: '${album.trackCount} tracks',
                              ja: '${album.trackCount}曲',
                            ),
                            style: GBTTypography.caption.copyWith(
                              color: metaColor,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AlbumCardSkeleton extends StatelessWidget {
  const _AlbumCardSkeleton({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? GBTColors.darkSurfaceVariant : GBTColors.surfaceVariant;
    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(GBTSpacing.radiusMd),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SONGS LIST
// ─────────────────────────────────────────────────────────────────────────────

class _SongsList extends StatelessWidget {
  const _SongsList({
    required this.songs,
    required this.isLoading,
    required this.isLoadingMore,
    required this.failure,
    required this.scrollController,
    required this.isDark,
    required this.accent,
    required this.onTap,
  });

  final List<MusicSongSummary> songs;
  final bool isLoading;
  final bool isLoadingMore;
  final Failure? failure;
  final ScrollController scrollController;
  final bool isDark;
  final Color accent;
  final ValueChanged<MusicSongSummary> onTap;

  @override
  Widget build(BuildContext context) {
    final textSecondary =
        isDark ? GBTColors.darkTextSecondary : GBTColors.textSecondary;

    if (isLoading) {
      return Center(child: CircularProgressIndicator(color: accent));
    }

    if (failure != null && songs.isEmpty) {
      return Center(
        child: Text(
          failure!.userMessage,
          style: GBTTypography.bodySmall.copyWith(color: textSecondary),
          textAlign: TextAlign.center,
        ),
      );
    }

    if (songs.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.queue_music_outlined,
              size: 48,
              color: accent.withValues(alpha: 0.3),
            ),
            const SizedBox(height: GBTSpacing.sm),
            Text(
              context.l10n(
                ko: '곡 정보가 없습니다.',
                en: 'No songs available.',
                ja: '楽曲情報がありません。',
              ),
              style: GBTTypography.bodySmall.copyWith(color: textSecondary),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(
        GBTSpacing.pageHorizontal,
        GBTSpacing.sm,
        GBTSpacing.pageHorizontal,
        GBTSpacing.xxl,
      ),
      itemCount: songs.length + (isLoadingMore ? 1 : 0),
      itemBuilder: (context, i) {
        if (i >= songs.length) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: GBTSpacing.md),
            child: Center(child: CircularProgressIndicator(color: accent)),
          );
        }
        return Padding(
          padding: const EdgeInsets.only(bottom: GBTSpacing.xs2),
          child: _SongRow(
            song: songs[i],
            rank: i + 1,
            isDark: isDark,
            accent: accent,
            onTap: () => onTap(songs[i]),
          ),
        );
      },
    );
  }
}

class _SongRow extends StatelessWidget {
  const _SongRow({
    required this.song,
    required this.rank,
    required this.isDark,
    required this.accent,
    required this.onTap,
  });

  final MusicSongSummary song;
  final int rank;
  final bool isDark;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cardBg = isDark
        ? GBTColors.darkSurfaceVariant.withValues(alpha: 0.7)
        : GBTColors.surfaceVariant;
    final titleColor =
        isDark ? GBTColors.darkTextPrimary : GBTColors.textPrimary;
    final rankColor = rank <= 3
        ? accent
        : (isDark ? GBTColors.darkTextTertiary : GBTColors.textTertiary);
    final metaColor =
        isDark ? GBTColors.darkTextSecondary : GBTColors.textSecondary;
    final isTitleTrack = song.isTitleTrack ?? false;

    final metaParts = <String>[];
    if ((song.primaryUnitName ?? '').trim().isNotEmpty) {
      metaParts.add(song.primaryUnitName!.trim());
    }
    if (song.bpm != null && song.bpm! > 0) {
      metaParts.add('BPM ${song.bpm}');
    }
    if (song.durationMs != null && song.durationMs! > 0) {
      metaParts.add(_formatMs(song.durationMs!));
    }

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(GBTSpacing.radiusMd),
      child: InkWell(
        borderRadius: BorderRadius.circular(GBTSpacing.radiusMd),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.symmetric(
            horizontal: GBTSpacing.sm,
            vertical: GBTSpacing.sm2,
          ),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(GBTSpacing.radiusMd),
          ),
          child: Row(
            children: [
              // ── Rank ────────────────────────────────────────
              SizedBox(
                width: 28,
                child: Text(
                  '$rank',
                  textAlign: TextAlign.center,
                  style: GBTTypography.bodySmall.copyWith(
                    color: rankColor,
                    fontWeight: rank <= 3 ? FontWeight.w800 : FontWeight.w400,
                  ),
                ),
              ),
              const SizedBox(width: GBTSpacing.xs),

              // ── Title + metadata ─────────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            song.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GBTTypography.bodyMedium.copyWith(
                              color: titleColor,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        if (isTitleTrack) ...[
                          const SizedBox(width: GBTSpacing.xs),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 1,
                            ),
                            decoration: BoxDecoration(
                              color: accent.withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(
                                GBTSpacing.radiusFull,
                              ),
                            ),
                            child: Text(
                              'TITLE',
                              style: GBTTypography.caption.copyWith(
                                color: accent,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                                fontSize: 9,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (metaParts.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        metaParts.join('  ·  '),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GBTTypography.caption.copyWith(
                          color: metaColor,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: GBTSpacing.xs),

              // ── Chevron ──────────────────────────────────────
              Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: isDark ? GBTColors.darkTextTertiary : GBTColors.textTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ALBUM BOTTOM SHEET
// ─────────────────────────────────────────────────────────────────────────────

class _AlbumSheet extends StatelessWidget {
  const _AlbumSheet({
    required this.detail,
    required this.songsById,
    required this.isDark,
    required this.accent,
    required this.projectId,
    required this.onSongTap,
  });

  final MusicAlbumDetail detail;
  final Map<String, MusicSongSummary> songsById;
  final bool isDark;
  final Color accent;
  final String projectId;
  final ValueChanged<String> onSongTap;

  String? _resolveSongId(MusicAlbumTrack track) {
    final direct = track.songId.trim();
    if (direct.isNotEmpty) return direct;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final titleColor =
        isDark ? GBTColors.darkTextPrimary : GBTColors.textPrimary;
    final metaColor =
        isDark ? GBTColors.darkTextSecondary : GBTColors.textSecondary;
    final divider = isDark ? GBTColors.darkBorder : GBTColors.border;
    final hasCover = (detail.coverUrl ?? '').trim().isNotEmpty;
    final releaseYear = (detail.releaseDate ?? '').trim().isNotEmpty
        ? detail.releaseDate!.trim().split('-').first
        : null;
    final effectiveTrackCount =
        detail.tracks.isNotEmpty ? detail.tracks.length : detail.trackCount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Album header ─────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(
            GBTSpacing.md,
            GBTSpacing.sm,
            GBTSpacing.md,
            GBTSpacing.md,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cover art
              ClipRRect(
                borderRadius: BorderRadius.circular(GBTSpacing.radiusMd),
                child: SizedBox(
                  width: 80,
                  height: 80,
                  child: hasCover
                      ? GBTImage(
                          imageUrl: detail.coverUrl!,
                          fit: BoxFit.cover,
                          semanticLabel: '${detail.title} cover',
                        )
                      : Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                accent.withValues(alpha: 0.18),
                                accent.withValues(alpha: 0.06),
                              ],
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.album_rounded,
                              size: 36,
                              color: accent.withValues(alpha: 0.4),
                            ),
                          ),
                        ),
                ),
              ),
              const SizedBox(width: GBTSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (detail.type.trim().isNotEmpty)
                      Container(
                        margin: const EdgeInsets.only(bottom: 4),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: accent.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(
                            GBTSpacing.radiusFull,
                          ),
                        ),
                        child: Text(
                          detail.type.toUpperCase(),
                          style: GBTTypography.caption.copyWith(
                            color: accent,
                            fontWeight: FontWeight.w800,
                            fontSize: 9,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    Text(
                      detail.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GBTTypography.titleSmall.copyWith(
                        color: titleColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      [
                        if (releaseYear != null) releaseYear,
                        if (effectiveTrackCount > 0)
                          context.l10n(
                            ko: '$effectiveTrackCount곡',
                            en: '$effectiveTrackCount tracks',
                            ja: '$effectiveTrackCount曲',
                          ),
                        if ((detail.label ?? '').trim().isNotEmpty)
                          detail.label!.trim(),
                      ].join('  ·  '),
                      style: GBTTypography.bodySmall.copyWith(
                        color: metaColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        Divider(height: 1, color: divider),

        // ── Track list ───────────────────────────────────────
        Expanded(
          child: detail.tracks.isEmpty
              ? Center(
                  child: Text(
                    context.l10n(
                      ko: '트랙 정보가 없습니다.',
                      en: 'No tracks available.',
                      ja: 'トラック情報がありません。',
                    ),
                    style: GBTTypography.bodySmall.copyWith(
                      color: metaColor,
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: GBTSpacing.md,
                    vertical: GBTSpacing.sm,
                  ),
                  itemCount: detail.tracks.length,
                  itemBuilder: (context, i) {
                    final track = detail.tracks[i];
                    final songId = _resolveSongId(track);
                    return _SheetTrackRow(
                      track: track,
                      isDark: isDark,
                      accent: accent,
                      onTap: songId == null ? null : () => onSongTap(songId),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _SheetTrackRow extends StatelessWidget {
  const _SheetTrackRow({
    required this.track,
    required this.isDark,
    required this.accent,
    this.onTap,
  });

  final MusicAlbumTrack track;
  final bool isDark;
  final Color accent;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final titleColor =
        isDark ? GBTColors.darkTextPrimary : GBTColors.textPrimary;
    final metaColor =
        isDark ? GBTColors.darkTextSecondary : GBTColors.textSecondary;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(GBTSpacing.radiusSm),
      child: InkWell(
        borderRadius: BorderRadius.circular(GBTSpacing.radiusSm),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: GBTSpacing.xs,
            vertical: GBTSpacing.xs2,
          ),
          child: Row(
            children: [
              SizedBox(
                width: 28,
                child: Text(
                  '${track.trackNo}',
                  textAlign: TextAlign.center,
                  style: GBTTypography.bodySmall.copyWith(color: metaColor),
                ),
              ),
              const SizedBox(width: GBTSpacing.xs),
              Expanded(
                child: Text(
                  track.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GBTTypography.bodyMedium.copyWith(
                    color: onTap != null ? titleColor : metaColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if ((track.versionCode ?? '').trim().isNotEmpty) ...[
                const SizedBox(width: GBTSpacing.xs),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(GBTSpacing.radiusFull),
                  ),
                  child: Text(
                    track.versionCode!,
                    style: GBTTypography.caption.copyWith(
                      color: accent,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
              if (track.durationMs != null && track.durationMs! > 0) ...[
                const SizedBox(width: GBTSpacing.xs),
                Text(
                  _formatMs(track.durationMs!),
                  style: GBTTypography.caption.copyWith(color: metaColor),
                ),
              ],
              if (onTap != null) ...[
                const SizedBox(width: GBTSpacing.xs2),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 16,
                  color: metaColor,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// EMPTY PROJECT HERO
// ─────────────────────────────────────────────────────────────────────────────

class _EmptyProjectHero extends StatelessWidget {
  const _EmptyProjectHero({required this.isDark, required this.accent});

  final bool isDark;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final textSecondary =
        isDark ? GBTColors.darkTextSecondary : GBTColors.textSecondary;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(GBTSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    accent.withValues(alpha: 0.18),
                    accent.withValues(alpha: 0.06),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(GBTSpacing.radiusXl),
              ),
              child: Center(
                child: Icon(
                  Icons.library_music_outlined,
                  size: 38,
                  color: accent.withValues(alpha: 0.5),
                ),
              ),
            ),
            const SizedBox(height: GBTSpacing.md),
            Text(
              context.l10n(ko: '뮤직 허브', en: 'Music Hub', ja: 'ミュージックハブ'),
              style: GBTTypography.titleSmall.copyWith(
                color: isDark ? GBTColors.darkTextPrimary : GBTColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: GBTSpacing.xs),
            Text(
              context.l10n(
                ko: '프로젝트를 선택하면\n앨범·가사·콜가이드를 탐색할 수 있어요.',
                en: 'Select a project to explore\nalbums, lyrics, and call guides.',
                ja: 'プロジェクトを選択すると\nアルバム・歌詞・コール表を確認できます。',
              ),
              textAlign: TextAlign.center,
              style: GBTTypography.bodySmall.copyWith(
                color: textSecondary,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
