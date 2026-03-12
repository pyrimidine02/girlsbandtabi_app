/// EN: Domain entities for music information and live setlist features.
/// KO: 악곡 정보 및 라이브 세트리스트 기능의 도메인 엔티티입니다.
library;

import '../../data/dto/music_dto.dart';

class MusicCursorPage<T> {
  const MusicCursorPage({
    required this.items,
    required this.hasNext,
    this.nextCursor,
  });

  final List<T> items;
  final String? nextCursor;
  final bool hasNext;
}

class MusicAlbumSummary {
  const MusicAlbumSummary({
    required this.id,
    required this.projectId,
    required this.title,
    required this.type,
    this.coverUrl,
    this.releaseDate,
    this.trackCount = 0,
    this.label,
    this.catalogNo,
  });

  final String id;
  final String projectId;
  final String title;
  final String type;
  final String? coverUrl;
  final String? releaseDate;
  final int trackCount;
  final String? label;
  final String? catalogNo;

  factory MusicAlbumSummary.fromDto(MusicAlbumSummaryDto dto) {
    return MusicAlbumSummary(
      id: dto.id,
      projectId: dto.projectId,
      title: dto.title,
      type: dto.type,
      coverUrl: dto.coverUrl,
      releaseDate: dto.releaseDate,
      trackCount: dto.trackCount,
      label: dto.label,
      catalogNo: dto.catalogNo,
    );
  }
}

class MusicAlbumTrack {
  const MusicAlbumTrack({
    required this.songId,
    required this.trackNo,
    required this.title,
    this.versionCode,
    this.durationMs,
  });

  final String songId;
  final int trackNo;
  final String title;
  final String? versionCode;
  final int? durationMs;

  factory MusicAlbumTrack.fromDto(MusicAlbumTrackDto dto) {
    return MusicAlbumTrack(
      songId: dto.songId,
      trackNo: dto.trackNo,
      title: dto.title,
      versionCode: dto.versionCode,
      durationMs: dto.durationMs,
    );
  }
}

class MusicAlbumDetail extends MusicAlbumSummary {
  const MusicAlbumDetail({
    required super.id,
    required super.projectId,
    required super.title,
    required super.type,
    super.coverUrl,
    super.releaseDate,
    super.trackCount,
    super.label,
    super.catalogNo,
    this.tracks = const [],
  });

  final List<MusicAlbumTrack> tracks;

  factory MusicAlbumDetail.fromDto(MusicAlbumDetailDto dto) {
    return MusicAlbumDetail(
      id: dto.id,
      projectId: dto.projectId,
      title: dto.title,
      type: dto.type,
      coverUrl: dto.coverUrl,
      releaseDate: dto.releaseDate,
      trackCount: dto.trackCount,
      label: dto.label,
      catalogNo: dto.catalogNo,
      tracks: dto.tracks.map(MusicAlbumTrack.fromDto).toList(growable: false),
    );
  }
}

class MusicSongSummary {
  const MusicSongSummary({
    required this.id,
    required this.projectId,
    required this.title,
    this.titleJa,
    this.titleEn,
    this.durationMs,
    this.bpm,
    this.primaryUnitId,
    this.primaryUnitName,
    this.albumId,
    this.trackNo,
    this.isTitleTrack,
    this.defaultVersionCode,
  });

  final String id;
  final String projectId;
  final String title;
  final String? titleJa;
  final String? titleEn;
  final int? durationMs;
  final int? bpm;
  final String? primaryUnitId;
  final String? primaryUnitName;
  final String? albumId;
  final int? trackNo;
  final bool? isTitleTrack;
  final String? defaultVersionCode;

  factory MusicSongSummary.fromDto(MusicSongSummaryDto dto) {
    return MusicSongSummary(
      id: dto.id,
      projectId: dto.projectId,
      title: dto.title,
      titleJa: dto.titleJa,
      titleEn: dto.titleEn,
      durationMs: dto.durationMs,
      bpm: dto.bpm,
      primaryUnitId: dto.primaryUnitId,
      primaryUnitName: dto.primaryUnitName,
      albumId: dto.albumId,
      trackNo: dto.trackNo,
      isTitleTrack: dto.isTitleTrack,
      defaultVersionCode: dto.defaultVersionCode,
    );
  }
}

class MusicSongVersionInfo {
  const MusicSongVersionInfo({
    required this.versionCode,
    this.durationMs,
    this.bpm,
    this.key,
    this.timeSignature,
    this.isDefault = false,
    this.arrangementNote,
  });

  final String versionCode;
  final int? durationMs;
  final int? bpm;
  final String? key;
  final String? timeSignature;
  final bool isDefault;
  final String? arrangementNote;

  factory MusicSongVersionInfo.fromDto(MusicSongVersionInfoDto dto) {
    return MusicSongVersionInfo(
      versionCode: dto.versionCode,
      durationMs: dto.durationMs,
      bpm: dto.bpm,
      key: dto.key,
      timeSignature: dto.timeSignature,
      isDefault: dto.isDefault,
      arrangementNote: dto.arrangementNote,
    );
  }
}

class MusicSongDetail extends MusicSongSummary {
  const MusicSongDetail({
    required super.id,
    required super.projectId,
    required super.title,
    super.titleJa,
    super.titleEn,
    super.durationMs,
    super.bpm,
    super.primaryUnitId,
    super.primaryUnitName,
    super.albumId,
    super.trackNo,
    super.isTitleTrack,
    super.defaultVersionCode,
    this.versions = const [],
    this.previewUrl,
  });

  final List<MusicSongVersionInfo> versions;
  final String? previewUrl;

  factory MusicSongDetail.fromDto(MusicSongDetailDto dto) {
    return MusicSongDetail(
      id: dto.id,
      projectId: dto.projectId,
      title: dto.title,
      titleJa: dto.titleJa,
      titleEn: dto.titleEn,
      durationMs: dto.durationMs,
      bpm: dto.bpm,
      primaryUnitId: dto.primaryUnitId,
      primaryUnitName: dto.primaryUnitName,
      albumId: dto.albumId,
      trackNo: dto.trackNo,
      isTitleTrack: dto.isTitleTrack,
      defaultVersionCode: dto.defaultVersionCode,
      versions: dto.versions
          .map(MusicSongVersionInfo.fromDto)
          .toList(growable: false),
      previewUrl: dto.previewUrl,
    );
  }
}

class MusicLyricLine {
  const MusicLyricLine({
    required this.lineId,
    required this.order,
    required this.startMs,
    required this.endMs,
    required this.section,
    required this.textOriginal,
    this.textRomanized,
    this.textTranslated,
  });

  final String lineId;
  final int order;
  final int startMs;
  final int endMs;
  final String section;
  final String textOriginal;
  final String? textRomanized;
  final String? textTranslated;

  factory MusicLyricLine.fromDto(MusicLyricLineDto dto) {
    return MusicLyricLine(
      lineId: dto.lineId,
      order: dto.order,
      startMs: dto.startMs,
      endMs: dto.endMs,
      section: dto.section,
      textOriginal: dto.textOriginal,
      textRomanized: dto.textRomanized,
      textTranslated: dto.textTranslated,
    );
  }
}

class MusicLyricsPayload {
  const MusicLyricsPayload({
    required this.songId,
    required this.version,
    required this.lines,
  });

  final String songId;
  final String version;
  final List<MusicLyricLine> lines;

  factory MusicLyricsPayload.fromDto(MusicLyricsPayloadDto dto) {
    return MusicLyricsPayload(
      songId: dto.songId,
      version: dto.version,
      lines: dto.lines.map(MusicLyricLine.fromDto).toList(growable: false),
    );
  }
}

class MusicPartSegment {
  const MusicPartSegment({
    required this.segmentId,
    required this.startMs,
    required this.endMs,
    this.memberId,
    this.memberName,
    this.unitId,
    this.unitName,
    this.partType,
    this.lyricLineId,
  });

  final String segmentId;
  final int startMs;
  final int endMs;
  final String? memberId;
  final String? memberName;
  final String? unitId;
  final String? unitName;
  final String? partType;
  final String? lyricLineId;

  factory MusicPartSegment.fromDto(MusicPartSegmentDto dto) {
    return MusicPartSegment(
      segmentId: dto.segmentId,
      startMs: dto.startMs,
      endMs: dto.endMs,
      memberId: dto.memberId,
      memberName: dto.memberName,
      unitId: dto.unitId,
      unitName: dto.unitName,
      partType: dto.partType,
      lyricLineId: dto.lyricLineId,
    );
  }
}

class MusicPartsPayload {
  const MusicPartsPayload({
    required this.songId,
    required this.version,
    required this.segments,
  });

  final String songId;
  final String version;
  final List<MusicPartSegment> segments;

  factory MusicPartsPayload.fromDto(MusicPartsPayloadDto dto) {
    return MusicPartsPayload(
      songId: dto.songId,
      version: dto.version,
      segments: dto.segments
          .map(MusicPartSegment.fromDto)
          .toList(growable: false),
    );
  }
}

class MusicCallCue {
  const MusicCallCue({
    required this.cueId,
    required this.startMs,
    required this.endMs,
    required this.cueType,
    required this.cueText,
    this.intensity,
    this.target,
    this.note,
  });

  final String cueId;
  final int startMs;
  final int endMs;
  final String cueType;
  final String cueText;
  final int? intensity;
  final String? target;
  final String? note;

  factory MusicCallCue.fromDto(MusicCallCueDto dto) {
    return MusicCallCue(
      cueId: dto.cueId,
      startMs: dto.startMs,
      endMs: dto.endMs,
      cueType: dto.cueType,
      cueText: dto.cueText,
      intensity: dto.intensity,
      target: dto.target,
      note: dto.note,
    );
  }
}

class MusicCallGuidePayload {
  const MusicCallGuidePayload({
    required this.songId,
    required this.version,
    required this.cues,
  });

  final String songId;
  final String version;
  final List<MusicCallCue> cues;

  factory MusicCallGuidePayload.fromDto(MusicCallGuidePayloadDto dto) {
    return MusicCallGuidePayload(
      songId: dto.songId,
      version: dto.version,
      cues: dto.cues.map(MusicCallCue.fromDto).toList(growable: false),
    );
  }
}

class MusicCreditContributor {
  const MusicCreditContributor({required this.name, this.id, this.type});

  final String? id;
  final String name;
  final String? type;

  factory MusicCreditContributor.fromDto(MusicCreditContributorDto dto) {
    return MusicCreditContributor(id: dto.id, name: dto.name, type: dto.type);
  }
}

class MusicCreditGroup {
  const MusicCreditGroup({required this.role, required this.contributors});

  final String role;
  final List<MusicCreditContributor> contributors;

  factory MusicCreditGroup.fromDto(MusicCreditGroupDto dto) {
    return MusicCreditGroup(
      role: dto.role,
      contributors: dto.contributors
          .map(MusicCreditContributor.fromDto)
          .toList(growable: false),
    );
  }
}

class MusicDifficulty {
  const MusicDifficulty({
    required this.difficultyLevel,
    required this.callIntensity,
    required this.cueDensityPerMin,
    required this.vocalRangeScore,
    required this.tempoScore,
  });

  final String difficultyLevel;
  final int callIntensity;
  final int cueDensityPerMin;
  final int vocalRangeScore;
  final int tempoScore;

  factory MusicDifficulty.fromDto(MusicDifficultyDto dto) {
    return MusicDifficulty(
      difficultyLevel: dto.difficultyLevel,
      callIntensity: dto.callIntensity,
      cueDensityPerMin: dto.cueDensityPerMin,
      vocalRangeScore: dto.vocalRangeScore,
      tempoScore: dto.tempoScore,
    );
  }
}

class MusicPreview {
  const MusicPreview({this.url, this.durationSec, this.waveformUrl});

  final String? url;
  final int? durationSec;
  final String? waveformUrl;

  factory MusicPreview.fromDto(MusicPreviewDto dto) {
    return MusicPreview(
      url: dto.url,
      durationSec: dto.durationSec,
      waveformUrl: dto.waveformUrl,
    );
  }
}

class MusicStreamingLink {
  const MusicStreamingLink({
    required this.provider,
    required this.url,
    this.regionAvailability,
  });

  final String provider;
  final String url;
  final String? regionAvailability;

  factory MusicStreamingLink.fromDto(MusicStreamingLinkDto dto) {
    return MusicStreamingLink(
      provider: dto.provider,
      url: dto.url,
      regionAvailability: dto.regionAvailability,
    );
  }
}

class MusicMediaLinks {
  const MusicMediaLinks({required this.preview, required this.streamingLinks});

  final MusicPreview preview;
  final List<MusicStreamingLink> streamingLinks;

  factory MusicMediaLinks.fromDto(MusicMediaLinksDto dto) {
    return MusicMediaLinks(
      preview: MusicPreview.fromDto(dto.preview),
      streamingLinks: dto.streamingLinks
          .map(MusicStreamingLink.fromDto)
          .toList(growable: false),
    );
  }
}

class MusicAvailability {
  const MusicAvailability({
    required this.isAvailableNow,
    this.availableFrom,
    this.availableUntil,
    required this.allowedCountries,
    required this.blockedCountries,
    required this.rightsPolicy,
  });

  final bool isAvailableNow;
  final DateTime? availableFrom;
  final DateTime? availableUntil;
  final List<String> allowedCountries;
  final List<String> blockedCountries;
  final String rightsPolicy;

  factory MusicAvailability.fromDto(MusicAvailabilityDto dto) {
    return MusicAvailability(
      isAvailableNow: dto.isAvailableNow,
      availableFrom: dto.availableFrom,
      availableUntil: dto.availableUntil,
      allowedCountries: dto.allowedCountries,
      blockedCountries: dto.blockedCountries,
      rightsPolicy: dto.rightsPolicy,
    );
  }
}

class MusicSetlistItem {
  const MusicSetlistItem({
    required this.order,
    required this.eventId,
    this.unitId,
    this.unitName,
    this.songId,
    this.songTitle,
    this.versionCode,
    required this.segmentType,
    this.startAt,
    this.endAt,
    required this.isEncore,
    this.source,
  });

  final int order;
  final String eventId;
  final String? unitId;
  final String? unitName;
  final String? songId;
  final String? songTitle;
  final String? versionCode;
  final String segmentType;
  final DateTime? startAt;
  final DateTime? endAt;
  final bool isEncore;
  final String? source;

  bool get hasSongLink => (songId ?? '').trim().isNotEmpty;

  factory MusicSetlistItem.fromDto(MusicSetlistItemDto dto) {
    return MusicSetlistItem(
      order: dto.order,
      eventId: dto.eventId,
      unitId: dto.unitId,
      unitName: dto.unitName,
      songId: dto.songId,
      songTitle: dto.songTitle,
      versionCode: dto.versionCode,
      segmentType: dto.segmentType,
      startAt: dto.startAt,
      endAt: dto.endAt,
      isEncore: dto.isEncore,
      source: dto.source,
    );
  }
}

class MusicUnitSetlist {
  const MusicUnitSetlist({
    required this.unitId,
    this.unitName,
    this.performanceOrder,
    this.rawSetlist,
    required this.parsedSongs,
  });

  final String unitId;
  final String? unitName;
  final int? performanceOrder;
  final String? rawSetlist;
  final List<String> parsedSongs;

  factory MusicUnitSetlist.fromDto(MusicUnitSetlistDto dto) {
    return MusicUnitSetlist(
      unitId: dto.unitId,
      unitName: dto.unitName,
      performanceOrder: dto.performanceOrder,
      rawSetlist: dto.rawSetlist,
      parsedSongs: dto.parsedSongs,
    );
  }
}

class MusicLiveSetlist {
  const MusicLiveSetlist({
    required this.liveEventId,
    required this.eventStatus,
    required this.items,
    required this.unitSetlists,
  });

  final String liveEventId;
  final String eventStatus;
  final List<MusicSetlistItem> items;
  final List<MusicUnitSetlist> unitSetlists;

  bool get isCompleted => eventStatus.toUpperCase() == 'COMPLETED';

  factory MusicLiveSetlist.fromDto(MusicLiveSetlistDto dto) {
    return MusicLiveSetlist(
      liveEventId: dto.liveEventId,
      eventStatus: dto.eventStatus,
      items: dto.items.map(MusicSetlistItem.fromDto).toList(growable: false),
      unitSetlists: dto.unitSetlists
          .map(MusicUnitSetlist.fromDto)
          .toList(growable: false),
    );
  }
}

class MusicSongLiveContext {
  const MusicSongLiveContext({
    this.song,
    this.lyrics,
    this.parts,
    this.callGuide,
    this.setlistContext,
  });

  final MusicSongDetail? song;
  final MusicLyricsPayload? lyrics;
  final MusicPartsPayload? parts;
  final MusicCallGuidePayload? callGuide;
  final MusicLiveSetlist? setlistContext;

  factory MusicSongLiveContext.fromDto(MusicSongLiveContextDto dto) {
    return MusicSongLiveContext(
      song: dto.song == null ? null : MusicSongDetail.fromDto(dto.song!),
      lyrics: dto.lyrics == null
          ? null
          : MusicLyricsPayload.fromDto(dto.lyrics!),
      parts: dto.parts == null ? null : MusicPartsPayload.fromDto(dto.parts!),
      callGuide: dto.callGuide == null
          ? null
          : MusicCallGuidePayload.fromDto(dto.callGuide!),
      setlistContext: dto.setlistContext == null
          ? null
          : MusicLiveSetlist.fromDto(dto.setlistContext!),
    );
  }
}
