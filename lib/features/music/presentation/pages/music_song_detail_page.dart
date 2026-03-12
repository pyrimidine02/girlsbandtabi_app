/// EN: Song detail page for music information APIs.
/// KO: 악곡 정보 API용 곡 상세 페이지입니다.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/localization/locale_text.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/gbt_colors.dart';
import '../../../../core/theme/gbt_spacing.dart';
import '../../../../core/theme/gbt_typography.dart';
import '../../../../core/widgets/feedback/gbt_loading.dart';
import '../../application/music_controller.dart';
import '../../domain/entities/music_entities.dart';

class MusicSongDetailPage extends ConsumerStatefulWidget {
  const MusicSongDetailPage({
    super.key,
    required this.projectId,
    required this.songId,
    this.eventId,
  });

  final String projectId;
  final String songId;
  final String? eventId;

  @override
  ConsumerState<MusicSongDetailPage> createState() =>
      _MusicSongDetailPageState();
}

class _MusicSongDetailPageState extends ConsumerState<MusicSongDetailPage> {
  bool _includeRomanized = false;
  bool _includeTranslated = false;
  late String _lang;

  @override
  void initState() {
    super.initState();
    final platformLanguage =
        WidgetsBinding.instance.platformDispatcher.locale.languageCode;
    switch (platformLanguage) {
      case 'ja':
      case 'en':
      case 'ko':
        _lang = platformLanguage;
      default:
        _lang = 'ko';
    }
  }

  @override
  Widget build(BuildContext context) {
    final songKey = (projectId: widget.projectId, songId: widget.songId);
    final lyricsKey = (
      projectId: widget.projectId,
      songId: widget.songId,
      lang: _lang,
      version: null,
      includeRomanized: _includeRomanized,
      includeTranslated: _includeTranslated,
    );
    final partsKey = (
      projectId: widget.projectId,
      songId: widget.songId,
      lang: _lang,
      version: null,
    );
    final callGuideKey = (
      projectId: widget.projectId,
      songId: widget.songId,
      lang: _lang,
      version: null,
    );
    final availabilityKey = (
      projectId: widget.projectId,
      songId: widget.songId,
      country: _countryFromLocale(Localizations.localeOf(context)),
    );
    final songState = ref.watch(musicSongDetailProvider(songKey));
    final versionsState = ref.watch(musicSongVersionsProvider(songKey));
    final lyricsState = ref.watch(musicSongLyricsProvider(lyricsKey));
    final partsState = ref.watch(musicSongPartsProvider(partsKey));
    final callGuideState = ref.watch(musicSongCallGuideProvider(callGuideKey));
    final creditsState = ref.watch(musicSongCreditsProvider(songKey));
    final difficultyState = ref.watch(musicSongDifficultyProvider(songKey));
    final mediaState = ref.watch(musicSongMediaLinksProvider(songKey));
    final availabilityState = ref.watch(
      musicSongAvailabilityProvider(availabilityKey),
    );
    final AsyncValue<MusicSongLiveContext?> liveContextState =
        widget.eventId == null
        ? const AsyncData<MusicSongLiveContext?>(null)
        : ref
              .watch(
                musicSongLiveContextProvider((
                  projectId: widget.projectId,
                  songId: widget.songId,
                  eventId: widget.eventId!,
                  lang: _lang,
                  version: null,
                  includeRomanized: _includeRomanized,
                  includeTranslated: _includeTranslated,
                )),
              )
              .whenData<MusicSongLiveContext?>((value) => value);

    final song = songState.valueOrNull;
    final media = mediaState.valueOrNull;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const accent = Color(0xFF1DB954);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          song?.title ??
              context.l10n(ko: '악곡 정보', en: 'Song information', ja: '楽曲情報'),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => _refreshAll(
          songKey,
          lyricsKey,
          partsKey,
          callGuideKey,
          availabilityKey,
        ),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
            GBTSpacing.pageHorizontal,
            GBTSpacing.md,
            GBTSpacing.pageHorizontal,
            GBTSpacing.xxl,
          ),
          children: [
            if (songState.isLoading && song == null)
              const SizedBox(
                height: 280,
                child: Center(child: CircularProgressIndicator()),
              )
            else if (songState.hasError && song == null)
              _ErrorPanel(
                message: _errorText(context, songState.error),
                onRetry: () => _refreshAll(
                  songKey,
                  lyricsKey,
                  partsKey,
                  callGuideKey,
                  availabilityKey,
                ),
              )
            else if (song != null) ...[
              _SongHeroCard(
                song: song,
                isDark: isDark,
                accent: accent,
                previewUrl: media?.preview.url,
                streamingLinks: media?.streamingLinks ?? const [],
              ),
              const SizedBox(height: GBTSpacing.lg),
              _MusicSectionCard(
                icon: Icons.layers_outlined,
                title: context.l10n(
                  ko: '버전 정보',
                  en: 'Version details',
                  ja: 'バージョン情報',
                ),
                child: versionsState.when(
                  data: (versions) {
                    if (versions.isEmpty) {
                      return _EmptyHint(
                        text: context.l10n(
                          ko: '버전 정보가 없습니다.',
                          en: 'No version information.',
                          ja: 'バージョン情報がありません。',
                        ),
                      );
                    }
                    return Column(
                      children: versions
                          .map(
                            (version) => Padding(
                              padding: const EdgeInsets.only(
                                bottom: GBTSpacing.xs,
                              ),
                              child: _VersionRow(version: version),
                            ),
                          )
                          .toList(growable: false),
                    );
                  },
                  loading: () => const _InlineLoading(),
                  error: (error, _) =>
                      _InlineError(message: _errorText(context, error)),
                ),
              ),
              const SizedBox(height: GBTSpacing.md),
              _MusicSectionCard(
                icon: Icons.bar_chart_rounded,
                title: context.l10n(
                  ko: '지표 · 가용성',
                  en: 'Metrics & availability',
                  ja: '指標・利用可否',
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    difficultyState.when(
                      data: (difficulty) => Wrap(
                        spacing: GBTSpacing.xs,
                        runSpacing: GBTSpacing.xs,
                        children: [
                          _MetricChip(
                            icon: Icons.signal_cellular_alt_rounded,
                            label: context.l10n(
                              ko: '난이도 ${difficulty.difficultyLevel}',
                              en: 'Level ${difficulty.difficultyLevel}',
                              ja: '難易度 ${difficulty.difficultyLevel}',
                            ),
                          ),
                          _MetricChip(
                            icon: Icons.surround_sound_rounded,
                            label: context.l10n(
                              ko: '콜 강도 ${difficulty.callIntensity}',
                              en: 'Call ${difficulty.callIntensity}',
                              ja: 'コール ${difficulty.callIntensity}',
                            ),
                          ),
                          _MetricChip(
                            icon: Icons.auto_graph_rounded,
                            label: context.l10n(
                              ko: '밀도 ${difficulty.cueDensityPerMin}/min',
                              en: '${difficulty.cueDensityPerMin}/min',
                              ja: '${difficulty.cueDensityPerMin}/分',
                            ),
                          ),
                        ],
                      ),
                      loading: () => const _InlineLoading(),
                      error: (error, _) =>
                          _InlineError(message: _errorText(context, error)),
                    ),
                    const SizedBox(height: GBTSpacing.sm),
                    availabilityState.when(
                      data: (availability) {
                        final availableColor = availability.isAvailableNow
                            ? (isDark
                                  ? GBTColors.darkPrimary
                                  : GBTColors.primary)
                            : GBTColors.error;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              availability.isAvailableNow
                                  ? context.l10n(
                                      ko: '현재 재생 가능',
                                      en: 'Available now',
                                      ja: '現在利用可能',
                                    )
                                  : context.l10n(
                                      ko: '현재 재생 제한',
                                      en: 'Currently restricted',
                                      ja: '現在利用制限',
                                    ),
                              style: GBTTypography.bodyMedium.copyWith(
                                color: availableColor,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              context.l10n(
                                ko: '권리 정책: ${availability.rightsPolicy}',
                                en: 'Rights policy: ${availability.rightsPolicy}',
                                ja: '権利ポリシー: ${availability.rightsPolicy}',
                              ),
                              style: GBTTypography.labelSmall.copyWith(
                                color: isDark
                                    ? GBTColors.darkTextSecondary
                                    : GBTColors.textSecondary,
                              ),
                            ),
                          ],
                        );
                      },
                      loading: () => const _InlineLoading(),
                      error: (error, _) =>
                          _InlineError(message: _errorText(context, error)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: GBTSpacing.md),
              _MusicSectionCard(
                icon: Icons.podcasts_rounded,
                title: context.l10n(
                  ko: '미디어 링크',
                  en: 'Media links',
                  ja: 'メディアリンク',
                ),
                child: mediaState.when(
                  data: (mediaData) {
                    final previewUrl = mediaData.preview.url;
                    final hasStreaming = mediaData.streamingLinks.isNotEmpty;
                    if ((previewUrl == null || previewUrl.isEmpty) &&
                        !hasStreaming) {
                      return _EmptyHint(
                        text: context.l10n(
                          ko: '미디어 링크가 없습니다.',
                          en: 'No media links.',
                          ja: 'メディアリンクがありません。',
                        ),
                      );
                    }
                    return Column(
                      children: [
                        if (previewUrl != null && previewUrl.isNotEmpty)
                          _MusicLinkRow(
                            icon: Icons.play_arrow_rounded,
                            label: context.l10n(
                              ko: '오디오 미리듣기',
                              en: 'Audio preview',
                              ja: 'オーディオ試聴',
                            ),
                            caption: previewUrl,
                            onTap: () => _launchUrl(previewUrl),
                          ),
                        ...mediaData.streamingLinks.map(
                          (link) => _MusicLinkRow(
                            icon: Icons.open_in_new_rounded,
                            label: link.provider,
                            caption: link.regionAvailability,
                            onTap: () => _launchUrl(link.url),
                          ),
                        ),
                      ],
                    );
                  },
                  loading: () => const _InlineLoading(),
                  error: (error, _) =>
                      _InlineError(message: _errorText(context, error)),
                ),
              ),
              const SizedBox(height: GBTSpacing.md),
              _MusicSectionCard(
                icon: Icons.lyrics_rounded,
                title: context.l10n(ko: '가사', en: 'Lyrics', ja: '歌詞'),
                trailing: Wrap(
                  spacing: GBTSpacing.xs,
                  runSpacing: GBTSpacing.xs,
                  children: [
                    FilterChip(
                      label: const Text('Romanized'),
                      selected: _includeRomanized,
                      onSelected: (value) =>
                          setState(() => _includeRomanized = value),
                    ),
                    FilterChip(
                      label: Text(
                        context.l10n(ko: '번역', en: 'Translated', ja: '翻訳'),
                      ),
                      selected: _includeTranslated,
                      onSelected: (value) =>
                          setState(() => _includeTranslated = value),
                    ),
                  ],
                ),
                child: lyricsState.when(
                  data: (lyrics) {
                    if (lyrics.lines.isEmpty) {
                      return _EmptyHint(
                        text: context.l10n(
                          ko: '가사 정보가 없습니다.',
                          en: 'No lyric data.',
                          ja: '歌詞情報がありません。',
                        ),
                      );
                    }
                    return Column(
                      children: lyrics.lines
                          .map(
                            (line) => Padding(
                              padding: const EdgeInsets.only(
                                bottom: GBTSpacing.xs,
                              ),
                              child: _LyricLineCard(
                                line: line,
                                includeRomanized: _includeRomanized,
                                includeTranslated: _includeTranslated,
                                isDark: isDark,
                              ),
                            ),
                          )
                          .toList(growable: false),
                    );
                  },
                  loading: () => const _InlineLoading(),
                  error: (error, _) =>
                      _InlineError(message: _errorText(context, error)),
                ),
              ),
              const SizedBox(height: GBTSpacing.md),
              _MusicSectionCard(
                icon: Icons.people_outline_rounded,
                title: context.l10n(
                  ko: '멤버 파트',
                  en: 'Member parts',
                  ja: 'メンバーパート',
                ),
                child: partsState.when(
                  data: (parts) {
                    if (parts.segments.isEmpty) {
                      return _EmptyHint(
                        text: context.l10n(
                          ko: '파트 정보가 없습니다.',
                          en: 'No part data.',
                          ja: 'パート情報がありません。',
                        ),
                      );
                    }
                    return Column(
                      children: parts.segments
                          .map(
                            (segment) => Padding(
                              padding: const EdgeInsets.only(
                                bottom: GBTSpacing.xs,
                              ),
                              child: _TimelineRow(
                                title: segment.memberName ?? '-',
                                subtitle:
                                    '${_formatMs(segment.startMs)} - ${_formatMs(segment.endMs)}',
                                badge: segment.partType,
                                icon: Icons.multitrack_audio_rounded,
                              ),
                            ),
                          )
                          .toList(growable: false),
                    );
                  },
                  loading: () => const _InlineLoading(),
                  error: (error, _) =>
                      _InlineError(message: _errorText(context, error)),
                ),
              ),
              const SizedBox(height: GBTSpacing.md),
              _MusicSectionCard(
                icon: Icons.campaign_outlined,
                title: context.l10n(
                  ko: '콜 가이드',
                  en: 'Call guide',
                  ja: 'コールガイド',
                ),
                child: callGuideState.when(
                  data: (guide) {
                    if (guide.cues.isEmpty) {
                      return _EmptyHint(
                        text: context.l10n(
                          ko: '콜표 정보가 없습니다.',
                          en: 'No call guide data.',
                          ja: 'コールガイド情報がありません。',
                        ),
                      );
                    }
                    return Column(
                      children: guide.cues
                          .map(
                            (cue) => Padding(
                              padding: const EdgeInsets.only(
                                bottom: GBTSpacing.xs,
                              ),
                              child: _TimelineRow(
                                title: cue.cueText,
                                subtitle:
                                    '${_formatMs(cue.startMs)} - ${_formatMs(cue.endMs)}',
                                badge: cue.cueType,
                                icon: Icons.music_note_rounded,
                              ),
                            ),
                          )
                          .toList(growable: false),
                    );
                  },
                  loading: () => const _InlineLoading(),
                  error: (error, _) =>
                      _InlineError(message: _errorText(context, error)),
                ),
              ),
              const SizedBox(height: GBTSpacing.md),
              _MusicSectionCard(
                icon: Icons.badge_outlined,
                title: context.l10n(ko: '크레딧', en: 'Credits', ja: 'クレジット'),
                child: creditsState.when(
                  data: (groups) {
                    if (groups.isEmpty) {
                      return _EmptyHint(
                        text: context.l10n(
                          ko: '크레딧 정보가 없습니다.',
                          en: 'No credit data.',
                          ja: 'クレジット情報がありません。',
                        ),
                      );
                    }
                    return Column(
                      children: groups
                          .map(
                            (group) => Padding(
                              padding: const EdgeInsets.only(
                                bottom: GBTSpacing.xs,
                              ),
                              child: _CreditGroupCard(group: group),
                            ),
                          )
                          .toList(growable: false),
                    );
                  },
                  loading: () => const _InlineLoading(),
                  error: (error, _) =>
                      _InlineError(message: _errorText(context, error)),
                ),
              ),
              if (widget.eventId != null) ...[
                const SizedBox(height: GBTSpacing.md),
                _MusicSectionCard(
                  icon: Icons.playlist_play_rounded,
                  title: context.l10n(
                    ko: '라이브 세트리스트',
                    en: 'Live setlist',
                    ja: 'ライブセットリスト',
                  ),
                  child: liveContextState.when(
                    data: (contextData) {
                      final setlist = contextData?.setlistContext;
                      if (setlist == null || setlist.items.isEmpty) {
                        return _EmptyHint(
                          text: context.l10n(
                            ko: '연결된 세트리스트가 없습니다.',
                            en: 'No linked setlist.',
                            ja: '連携されたセットリストがありません。',
                          ),
                        );
                      }
                      return Column(
                        children: setlist.items
                            .map(
                              (item) => Padding(
                                padding: const EdgeInsets.only(
                                  bottom: GBTSpacing.xs,
                                ),
                                child: _TimelineRow(
                                  title: item.songTitle ?? '-',
                                  subtitle: item.segmentType,
                                  badge: item.isEncore ? 'Encore' : null,
                                  leading:
                                      '#${item.order.toString().padLeft(2, '0')}',
                                  icon: Icons.library_music_rounded,
                                  onTap: !item.hasSongLink
                                      ? null
                                      : () => context.goToSongDetail(
                                          item.songId!,
                                          projectId: widget.projectId,
                                          eventId: widget.eventId,
                                        ),
                                ),
                              ),
                            )
                            .toList(growable: false),
                      );
                    },
                    loading: () => const _InlineLoading(),
                    error: (error, _) =>
                        _InlineError(message: _errorText(context, error)),
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _refreshAll(
    MusicSongKey songKey,
    MusicLyricsKey lyricsKey,
    MusicPartsKey partsKey,
    MusicCallGuideKey callGuideKey,
    MusicAvailabilityKey availabilityKey,
  ) async {
    ref.invalidate(musicSongDetailProvider(songKey));
    ref.invalidate(musicSongVersionsProvider(songKey));
    ref.invalidate(musicSongLyricsProvider(lyricsKey));
    ref.invalidate(musicSongPartsProvider(partsKey));
    ref.invalidate(musicSongCallGuideProvider(callGuideKey));
    ref.invalidate(musicSongCreditsProvider(songKey));
    ref.invalidate(musicSongDifficultyProvider(songKey));
    ref.invalidate(musicSongMediaLinksProvider(songKey));
    ref.invalidate(musicSongAvailabilityProvider(availabilityKey));
    if (widget.eventId != null) {
      ref.invalidate(
        musicSongLiveContextProvider((
          projectId: widget.projectId,
          songId: widget.songId,
          eventId: widget.eventId!,
          lang: _lang,
          version: null,
          includeRomanized: _includeRomanized,
          includeTranslated: _includeTranslated,
        )),
      );
    }
    await Future<void>.delayed(const Duration(milliseconds: 100));
  }
}

class _SongHeroCard extends StatelessWidget {
  const _SongHeroCard({
    required this.song,
    required this.isDark,
    required this.accent,
    required this.previewUrl,
    required this.streamingLinks,
  });

  final MusicSongDetail song;
  final bool isDark;
  final Color accent;
  final String? previewUrl;
  final List<MusicStreamingLink> streamingLinks;

  @override
  Widget build(BuildContext context) {
    final titleColor = isDark
        ? GBTColors.darkTextPrimary
        : GBTColors.textPrimary;
    final subtitleColor = isDark
        ? GBTColors.darkTextSecondary
        : GBTColors.textSecondary;
    final hasPreview = (previewUrl ?? '').trim().isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(GBTSpacing.md),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(GBTSpacing.radiusMd),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? const [Color(0xFF191E25), Color(0xFF0C1016)]
              : const [Color(0xFFEAF8EF), Color(0xFFE8F0F8)],
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : accent).withValues(alpha: 0.15),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 108,
            height: 108,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(GBTSpacing.radiusMd),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  accent.withValues(alpha: 0.9),
                  const Color(0xFF0B6E35),
                ],
              ),
            ),
            child: const Icon(
              Icons.multitrack_audio_rounded,
              color: Colors.white,
              size: 40,
            ),
          ),
          const SizedBox(width: GBTSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  song.title,
                  style: GBTTypography.titleMedium.copyWith(
                    color: titleColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if ((song.primaryUnitName ?? '').trim().isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    song.primaryUnitName!,
                    style: GBTTypography.bodySmall.copyWith(
                      color: subtitleColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                const SizedBox(height: GBTSpacing.sm),
                Wrap(
                  spacing: GBTSpacing.xs,
                  runSpacing: GBTSpacing.xs,
                  children: [
                    if (song.durationMs != null)
                      _MetricChip(
                        icon: Icons.schedule_rounded,
                        label: _formatMs(song.durationMs!),
                      ),
                    if (song.bpm != null)
                      _MetricChip(
                        icon: Icons.speed_rounded,
                        label: 'BPM ${song.bpm}',
                      ),
                    if ((song.defaultVersionCode ?? '').trim().isNotEmpty)
                      _MetricChip(
                        icon: Icons.layers_rounded,
                        label: song.defaultVersionCode!,
                      ),
                  ],
                ),
                if (hasPreview || streamingLinks.isNotEmpty) ...[
                  const SizedBox(height: GBTSpacing.sm),
                  Wrap(
                    spacing: GBTSpacing.xs,
                    runSpacing: GBTSpacing.xs,
                    children: [
                      if (hasPreview)
                        _HeroActionChip(
                          icon: Icons.play_arrow_rounded,
                          label: context.l10n(
                            ko: '미리듣기',
                            en: 'Preview',
                            ja: '試聴',
                          ),
                          onTap: () => _launchUrl(previewUrl!),
                        ),
                      if (streamingLinks.isNotEmpty)
                        _HeroActionChip(
                          icon: Icons.headphones_rounded,
                          label: streamingLinks.first.provider,
                          onTap: () => _launchUrl(streamingLinks.first.url),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroActionChip extends StatelessWidget {
  const _HeroActionChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(GBTSpacing.radiusFull),
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.symmetric(
          horizontal: GBTSpacing.sm,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF1DB954).withValues(alpha: 0.16),
          borderRadius: BorderRadius.circular(GBTSpacing.radiusFull),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: const Color(0xFF1DB954)),
            const SizedBox(width: 4),
            Text(
              label,
              style: GBTTypography.labelSmall.copyWith(
                color: const Color(0xFF1DB954),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MusicSectionCard extends StatelessWidget {
  const _MusicSectionCard({
    required this.icon,
    required this.title,
    required this.child,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark
        ? GBTColors.darkTextPrimary
        : GBTColors.textPrimary;
    final borderColor = isDark ? GBTColors.darkBorder : GBTColors.border;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(GBTSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF13181F) : const Color(0xFFF7F9FC),
        borderRadius: BorderRadius.circular(GBTSpacing.radiusMd),
        border: Border.all(color: borderColor.withValues(alpha: 0.7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 16, color: const Color(0xFF1DB954)),
              const SizedBox(width: GBTSpacing.xs),
              Expanded(
                child: Text(
                  title,
                  style: GBTTypography.titleSmall.copyWith(
                    color: titleColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: GBTSpacing.sm),
          child,
        ],
      ),
    );
  }
}

class _VersionRow extends StatelessWidget {
  const _VersionRow({required this.version});

  final MusicSongVersionInfo version;

  @override
  Widget build(BuildContext context) {
    final details = <String>[
      if (version.durationMs != null && version.durationMs! > 0)
        _formatMs(version.durationMs!),
      if (version.bpm != null && version.bpm! > 0) 'BPM ${version.bpm}',
      if ((version.key ?? '').trim().isNotEmpty) version.key!,
      if ((version.timeSignature ?? '').trim().isNotEmpty)
        version.timeSignature!,
    ];
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final subtitleColor = isDark
        ? GBTColors.darkTextSecondary
        : GBTColors.textSecondary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: GBTSpacing.sm,
        vertical: GBTSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1B212A) : Colors.white,
        borderRadius: BorderRadius.circular(GBTSpacing.radiusSm),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              version.versionCode,
              style: GBTTypography.bodySmall.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          if (details.isNotEmpty)
            Flexible(
              child: Text(
                details.join(' · '),
                textAlign: TextAlign.right,
                overflow: TextOverflow.ellipsis,
                style: GBTTypography.labelSmall.copyWith(color: subtitleColor),
              ),
            ),
          if (version.isDefault) ...[
            const SizedBox(width: GBTSpacing.xs),
            const Icon(
              Icons.check_circle_rounded,
              size: 16,
              color: Color(0xFF1DB954),
            ),
          ],
        ],
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  const _MetricChip({required this.label, this.icon});

  final String label;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark
        ? GBTColors.darkTextPrimary
        : GBTColors.textPrimary;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: GBTSpacing.sm,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1B222A) : Colors.white,
        borderRadius: BorderRadius.circular(GBTSpacing.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: const Color(0xFF1DB954)),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: GBTTypography.labelSmall.copyWith(
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _MusicLinkRow extends StatelessWidget {
  const _MusicLinkRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.caption,
  });

  final IconData icon;
  final String label;
  final String? caption;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final subtitleColor = isDark
        ? GBTColors.darkTextSecondary
        : GBTColors.textSecondary;

    return Padding(
      padding: const EdgeInsets.only(bottom: GBTSpacing.xs),
      child: InkWell(
        borderRadius: BorderRadius.circular(GBTSpacing.radiusSm),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.symmetric(
            horizontal: GBTSpacing.sm,
            vertical: GBTSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1A2028) : Colors.white,
            borderRadius: BorderRadius.circular(GBTSpacing.radiusSm),
          ),
          child: Row(
            children: [
              Icon(icon, size: 18, color: const Color(0xFF1DB954)),
              const SizedBox(width: GBTSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: GBTTypography.bodySmall.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if ((caption ?? '').trim().isNotEmpty)
                      Text(
                        caption!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GBTTypography.labelSmall.copyWith(
                          color: subtitleColor,
                        ),
                      ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: subtitleColor),
            ],
          ),
        ),
      ),
    );
  }
}

class _LyricLineCard extends StatelessWidget {
  const _LyricLineCard({
    required this.line,
    required this.includeRomanized,
    required this.includeTranslated,
    required this.isDark,
  });

  final MusicLyricLine line;
  final bool includeRomanized;
  final bool includeTranslated;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final subtitleColor = isDark
        ? GBTColors.darkTextSecondary
        : GBTColors.textSecondary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: GBTSpacing.sm,
        vertical: GBTSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1B212A) : Colors.white,
        borderRadius: BorderRadius.circular(GBTSpacing.radiusSm),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            line.textOriginal,
            style: GBTTypography.bodyMedium.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          if (includeRomanized && (line.textRomanized ?? '').trim().isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                line.textRomanized!,
                style: GBTTypography.bodySmall.copyWith(color: subtitleColor),
              ),
            ),
          if (includeTranslated &&
              (line.textTranslated ?? '').trim().isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                line.textTranslated!,
                style: GBTTypography.bodySmall.copyWith(color: subtitleColor),
              ),
            ),
        ],
      ),
    );
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.badge,
    this.leading,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final String? badge;
  final String? leading;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final subtitleColor = isDark
        ? GBTColors.darkTextSecondary
        : GBTColors.textSecondary;

    final row = Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: const Color(0xFF1DB954).withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(GBTSpacing.radiusFull),
          ),
          alignment: Alignment.center,
          child: leading != null
              ? Text(
                  leading!,
                  style: GBTTypography.labelSmall.copyWith(
                    color: const Color(0xFF1DB954),
                    fontWeight: FontWeight.w700,
                  ),
                )
              : Icon(icon, size: 14, color: const Color(0xFF1DB954)),
        ),
        const SizedBox(width: GBTSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GBTTypography.bodySmall.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GBTTypography.labelSmall.copyWith(color: subtitleColor),
              ),
            ],
          ),
        ),
        if ((badge ?? '').trim().isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: GBTSpacing.xs,
              vertical: 3,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFF1DB954).withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(GBTSpacing.radiusFull),
            ),
            child: Text(
              badge!,
              style: GBTTypography.labelSmall.copyWith(
                color: const Color(0xFF1DB954),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
      ],
    );

    return InkWell(
      borderRadius: BorderRadius.circular(GBTSpacing.radiusSm),
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.symmetric(
          horizontal: GBTSpacing.sm,
          vertical: GBTSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A2028) : Colors.white,
          borderRadius: BorderRadius.circular(GBTSpacing.radiusSm),
        ),
        child: row,
      ),
    );
  }
}

class _CreditGroupCard extends StatelessWidget {
  const _CreditGroupCard({required this.group});

  final MusicCreditGroup group;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final subtitleColor = isDark
        ? GBTColors.darkTextSecondary
        : GBTColors.textSecondary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: GBTSpacing.sm,
        vertical: GBTSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2028) : Colors.white,
        borderRadius: BorderRadius.circular(GBTSpacing.radiusSm),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            group.role,
            style: GBTTypography.bodySmall.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Wrap(
            spacing: GBTSpacing.xs,
            runSpacing: GBTSpacing.xs,
            children: group.contributors
                .map((contributor) => _MetricChip(label: contributor.name))
                .toList(growable: false),
          ),
          if (group.contributors.any((item) => (item.type ?? '').isNotEmpty))
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                group.contributors
                    .where((item) => (item.type ?? '').isNotEmpty)
                    .map((item) => '${item.name} (${item.type})')
                    .join(' · '),
                style: GBTTypography.labelSmall.copyWith(color: subtitleColor),
              ),
            ),
        ],
      ),
    );
  }
}

class _InlineLoading extends StatelessWidget {
  const _InlineLoading();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: GBTSpacing.sm),
      child: Center(
        child: SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }
}

class _InlineError extends StatelessWidget {
  const _InlineError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Text(
      message,
      style: GBTTypography.bodySmall.copyWith(color: GBTColors.error),
    );
  }
}

class _EmptyHint extends StatelessWidget {
  const _EmptyHint({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Text(
      text,
      style: GBTTypography.bodySmall.copyWith(
        color: isDark ? GBTColors.darkTextSecondary : GBTColors.textSecondary,
      ),
    );
  }
}

class _ErrorPanel extends StatelessWidget {
  const _ErrorPanel({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return GBTErrorState(message: message, onRetry: onRetry);
  }
}

Future<void> _launchUrl(String rawUrl) async {
  final uri = Uri.tryParse(rawUrl);
  if (uri == null) return;
  await launchUrl(uri, mode: LaunchMode.externalApplication);
}

String _errorText(BuildContext context, Object? error) {
  if (error is Failure) {
    return error.userMessage;
  }
  return context.l10n(
    ko: '데이터를 불러오지 못했습니다.',
    en: 'Failed to load data.',
    ja: 'データの読み込みに失敗しました。',
  );
}

String _formatMs(int ms) {
  final totalSeconds = (ms / 1000).floor();
  final minutes = totalSeconds ~/ 60;
  final seconds = totalSeconds % 60;
  final minuteLabel = minutes.toString().padLeft(2, '0');
  final secondLabel = seconds.toString().padLeft(2, '0');
  return '$minuteLabel:$secondLabel';
}

String? _countryFromLocale(Locale locale) {
  final country = locale.countryCode?.trim();
  if (country == null || country.isEmpty) {
    return null;
  }
  return country.toUpperCase();
}
