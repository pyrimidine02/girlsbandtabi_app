/// EN: DTOs for music information APIs.
/// KO: 악곡 정보 API용 DTO.
library;

class MusicCursorPageDto<T> {
  const MusicCursorPageDto({
    required this.items,
    required this.hasNext,
    this.nextCursor,
  });

  final List<T> items;
  final String? nextCursor;
  final bool hasNext;

  factory MusicCursorPageDto.fromJson(
    dynamic json,
    T Function(Map<String, dynamic>) itemFromJson,
  ) {
    final map = _asMap(json);
    final list = _extractList(map ?? json, preferredKey: 'items');
    final items = list
        .whereType<Map<String, dynamic>>()
        .map(itemFromJson)
        .toList(growable: false);
    final nextCursor = map == null
        ? null
        : _stringOrNull(map['nextCursor'] ?? _asMap(map['cursor'])?['next']);
    final hasNext = map == null
        ? false
        : _bool(
            map['hasNext'] ?? _asMap(map['pagination'])?['hasNext'],
            fallback: items.isNotEmpty && nextCursor != null,
          );
    return MusicCursorPageDto(
      items: items,
      nextCursor: nextCursor,
      hasNext: hasNext,
    );
  }
}

class MusicAlbumSummaryDto {
  const MusicAlbumSummaryDto({
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

  factory MusicAlbumSummaryDto.fromJson(Map<String, dynamic> json) {
    return MusicAlbumSummaryDto(
      id: _string(json['id']),
      projectId: _string(
        json['projectId'] ?? json['projectCode'] ?? json['projectKey'],
      ),
      title: _string(json['title']),
      type: _string(json['type'], fallback: 'ALBUM'),
      coverUrl: _stringOrNull(json['coverUrl'] ?? json['thumbnailUrl']),
      releaseDate: _stringOrNull(json['releaseDate']),
      trackCount: _int(json['trackCount']),
      label: _stringOrNull(json['label']),
      catalogNo: _stringOrNull(json['catalogNo']),
    );
  }
}

class MusicAlbumTrackDto {
  const MusicAlbumTrackDto({
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

  factory MusicAlbumTrackDto.fromJson(Map<String, dynamic> json) {
    return MusicAlbumTrackDto(
      songId: _string(json['songId']),
      trackNo: _int(json['trackNo']),
      title: _string(json['title']),
      versionCode: _stringOrNull(json['versionCode']),
      durationMs: _intOrNull(json['durationMs']),
    );
  }
}

class MusicAlbumDetailDto extends MusicAlbumSummaryDto {
  const MusicAlbumDetailDto({
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

  final List<MusicAlbumTrackDto> tracks;

  factory MusicAlbumDetailDto.fromJson(Map<String, dynamic> json) {
    final tracks = _extractList(json, preferredKey: 'tracks')
        .whereType<Map<String, dynamic>>()
        .map(MusicAlbumTrackDto.fromJson)
        .toList(growable: false);
    return MusicAlbumDetailDto(
      id: _string(json['id']),
      projectId: _string(
        json['projectId'] ?? json['projectCode'] ?? json['projectKey'],
      ),
      title: _string(json['title']),
      type: _string(json['type'], fallback: 'ALBUM'),
      coverUrl: _stringOrNull(json['coverUrl'] ?? json['thumbnailUrl']),
      releaseDate: _stringOrNull(json['releaseDate']),
      trackCount: _int(json['trackCount'], fallback: tracks.length),
      label: _stringOrNull(json['label']),
      catalogNo: _stringOrNull(json['catalogNo']),
      tracks: tracks,
    );
  }
}

class MusicSongSummaryDto {
  const MusicSongSummaryDto({
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

  factory MusicSongSummaryDto.fromJson(Map<String, dynamic> json) {
    return MusicSongSummaryDto(
      id: _string(json['id']),
      projectId: _string(
        json['projectId'] ?? json['projectCode'] ?? json['projectKey'],
      ),
      title: _string(json['title']),
      titleJa: _stringOrNull(json['titleJa']),
      titleEn: _stringOrNull(json['titleEn']),
      durationMs: _intOrNull(json['durationMs']),
      bpm: _intOrNull(json['bpm']),
      primaryUnitId: _stringOrNull(json['primaryUnitId']),
      primaryUnitName: _stringOrNull(json['primaryUnitName']),
      albumId: _stringOrNull(json['albumId']),
      trackNo: _intOrNull(json['trackNo']),
      isTitleTrack: _boolOrNull(json['isTitleTrack']),
      defaultVersionCode: _stringOrNull(json['defaultVersionCode']),
    );
  }
}

class MusicSongDetailDto extends MusicSongSummaryDto {
  const MusicSongDetailDto({
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

  final List<MusicSongVersionInfoDto> versions;
  final String? previewUrl;

  factory MusicSongDetailDto.fromJson(Map<String, dynamic> json) {
    final versions = _extractList(json, preferredKey: 'versions')
        .whereType<Map<String, dynamic>>()
        .map(MusicSongVersionInfoDto.fromJson)
        .toList(growable: false);
    return MusicSongDetailDto(
      id: _string(json['id']),
      projectId: _string(
        json['projectId'] ?? json['projectCode'] ?? json['projectKey'],
      ),
      title: _string(json['title']),
      titleJa: _stringOrNull(json['titleJa']),
      titleEn: _stringOrNull(json['titleEn']),
      durationMs: _intOrNull(json['durationMs']),
      bpm: _intOrNull(json['bpm']),
      primaryUnitId: _stringOrNull(json['primaryUnitId']),
      primaryUnitName: _stringOrNull(json['primaryUnitName']),
      albumId: _stringOrNull(json['albumId']),
      trackNo: _intOrNull(json['trackNo']),
      isTitleTrack: _boolOrNull(json['isTitleTrack']),
      defaultVersionCode: _stringOrNull(json['defaultVersionCode']),
      versions: versions,
      previewUrl: _stringOrNull(
        json['previewUrl'] ?? _asMap(json['preview'])?['url'],
      ),
    );
  }
}

class MusicSongVersionInfoDto {
  const MusicSongVersionInfoDto({
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

  factory MusicSongVersionInfoDto.fromJson(Map<String, dynamic> json) {
    return MusicSongVersionInfoDto(
      versionCode: _string(json['versionCode']),
      durationMs: _intOrNull(json['durationMs']),
      bpm: _intOrNull(json['bpm']),
      key: _stringOrNull(json['key']),
      timeSignature: _stringOrNull(json['timeSignature']),
      isDefault: _bool(json['isDefault']),
      arrangementNote: _stringOrNull(json['arrangementNote']),
    );
  }
}

class MusicLyricLineDto {
  const MusicLyricLineDto({
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

  factory MusicLyricLineDto.fromJson(Map<String, dynamic> json) {
    return MusicLyricLineDto(
      lineId: _string(json['lineId']),
      order: _int(json['order']),
      startMs: _int(json['startMs']),
      endMs: _int(json['endMs']),
      section: _string(json['section'], fallback: 'VERSE'),
      textOriginal: _string(json['textOriginal']),
      textRomanized: _stringOrNull(json['textRomanized']),
      textTranslated: _stringOrNull(json['textTranslated']),
    );
  }
}

class MusicLyricsPayloadDto {
  const MusicLyricsPayloadDto({
    required this.songId,
    required this.version,
    required this.lines,
  });

  final String songId;
  final String version;
  final List<MusicLyricLineDto> lines;

  factory MusicLyricsPayloadDto.fromJson(dynamic json) {
    final map = _asMap(json) ?? const <String, dynamic>{};
    final primary = _extractList(map, preferredKey: 'lyrics');
    final fallback = primary.isEmpty
        ? _extractList(map, preferredKey: 'lines')
        : primary;
    final lines = fallback
        .whereType<Map<String, dynamic>>()
        .map(MusicLyricLineDto.fromJson)
        .toList(growable: false);
    return MusicLyricsPayloadDto(
      songId: _string(map['songId']),
      version: _string(map['version'], fallback: 'FULL'),
      lines: lines,
    );
  }
}

class MusicPartSegmentDto {
  const MusicPartSegmentDto({
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

  factory MusicPartSegmentDto.fromJson(Map<String, dynamic> json) {
    return MusicPartSegmentDto(
      segmentId: _string(json['segmentId']),
      startMs: _int(json['startMs']),
      endMs: _int(json['endMs']),
      memberId: _stringOrNull(json['memberId']),
      memberName: _stringOrNull(json['memberName']),
      unitId: _stringOrNull(json['unitId']),
      unitName: _stringOrNull(json['unitName']),
      partType: _stringOrNull(json['partType']),
      lyricLineId: _stringOrNull(json['lyricLineId']),
    );
  }
}

class MusicPartsPayloadDto {
  const MusicPartsPayloadDto({
    required this.songId,
    required this.version,
    required this.segments,
  });

  final String songId;
  final String version;
  final List<MusicPartSegmentDto> segments;

  factory MusicPartsPayloadDto.fromJson(dynamic json) {
    final map = _asMap(json) ?? const <String, dynamic>{};
    final primary = _extractList(map, preferredKey: 'parts');
    final fallback = primary.isEmpty
        ? _extractList(map, preferredKey: 'segments')
        : primary;
    final segments = fallback
        .whereType<Map<String, dynamic>>()
        .map(MusicPartSegmentDto.fromJson)
        .toList(growable: false);
    return MusicPartsPayloadDto(
      songId: _string(map['songId']),
      version: _string(map['version'], fallback: 'FULL'),
      segments: segments,
    );
  }
}

class MusicCallCueDto {
  const MusicCallCueDto({
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

  factory MusicCallCueDto.fromJson(Map<String, dynamic> json) {
    return MusicCallCueDto(
      cueId: _string(json['cueId']),
      startMs: _int(json['startMs']),
      endMs: _int(json['endMs']),
      cueType: _string(json['cueType']),
      cueText: _string(json['cueText']),
      intensity: _intOrNull(json['intensity']),
      target: _stringOrNull(json['target']),
      note: _stringOrNull(json['note']),
    );
  }
}

class MusicCallGuidePayloadDto {
  const MusicCallGuidePayloadDto({
    required this.songId,
    required this.version,
    required this.cues,
  });

  final String songId;
  final String version;
  final List<MusicCallCueDto> cues;

  factory MusicCallGuidePayloadDto.fromJson(dynamic json) {
    final map = _asMap(json) ?? const <String, dynamic>{};
    final primary = _extractList(map, preferredKey: 'callGuide');
    final fallback = primary.isEmpty
        ? _extractList(map, preferredKey: 'cues')
        : primary;
    final cues = fallback
        .whereType<Map<String, dynamic>>()
        .map(MusicCallCueDto.fromJson)
        .toList(growable: false);
    return MusicCallGuidePayloadDto(
      songId: _string(map['songId']),
      version: _string(map['version'], fallback: 'FULL'),
      cues: cues,
    );
  }
}

class MusicCreditContributorDto {
  const MusicCreditContributorDto({required this.name, this.id, this.type});

  final String? id;
  final String name;
  final String? type;

  factory MusicCreditContributorDto.fromJson(Map<String, dynamic> json) {
    return MusicCreditContributorDto(
      id: _stringOrNull(json['id']),
      name: _string(json['name']),
      type: _stringOrNull(json['type']),
    );
  }
}

class MusicCreditGroupDto {
  const MusicCreditGroupDto({required this.role, required this.contributors});

  final String role;
  final List<MusicCreditContributorDto> contributors;

  factory MusicCreditGroupDto.fromJson(Map<String, dynamic> json) {
    final contributors = _extractList(json, preferredKey: 'contributors')
        .whereType<Map<String, dynamic>>()
        .map(MusicCreditContributorDto.fromJson)
        .toList(growable: false);
    return MusicCreditGroupDto(
      role: _string(json['role']),
      contributors: contributors,
    );
  }
}

class MusicDifficultyDto {
  const MusicDifficultyDto({
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

  factory MusicDifficultyDto.fromJson(dynamic json) {
    final map = _asMap(json) ?? const <String, dynamic>{};
    final metrics = _asMap(map['metrics']) ?? const <String, dynamic>{};
    return MusicDifficultyDto(
      difficultyLevel: _string(
        map['difficultyLevel'],
        fallback: 'INTERMEDIATE',
      ),
      callIntensity: _int(map['callIntensity'], fallback: 3),
      cueDensityPerMin: _int(metrics['cueDensityPerMin']),
      vocalRangeScore: _int(metrics['vocalRangeScore']),
      tempoScore: _int(metrics['tempoScore']),
    );
  }
}

class MusicPreviewDto {
  const MusicPreviewDto({this.url, this.durationSec, this.waveformUrl});

  final String? url;
  final int? durationSec;
  final String? waveformUrl;

  factory MusicPreviewDto.fromJson(Map<String, dynamic> json) {
    return MusicPreviewDto(
      url: _stringOrNull(json['url']),
      durationSec: _intOrNull(json['durationSec']),
      waveformUrl: _stringOrNull(json['waveformUrl']),
    );
  }
}

class MusicStreamingLinkDto {
  const MusicStreamingLinkDto({
    required this.provider,
    required this.url,
    this.regionAvailability,
  });

  final String provider;
  final String url;
  final String? regionAvailability;

  factory MusicStreamingLinkDto.fromJson(Map<String, dynamic> json) {
    return MusicStreamingLinkDto(
      provider: _string(json['provider']),
      url: _string(json['url']),
      regionAvailability: _stringOrNull(json['regionAvailability']),
    );
  }
}

class MusicMediaLinksDto {
  const MusicMediaLinksDto({
    required this.preview,
    required this.streamingLinks,
  });

  final MusicPreviewDto preview;
  final List<MusicStreamingLinkDto> streamingLinks;

  factory MusicMediaLinksDto.fromJson(dynamic json) {
    final map = _asMap(json) ?? const <String, dynamic>{};
    final previewMap = _asMap(map['preview']) ?? const <String, dynamic>{};
    final links = _extractList(map, preferredKey: 'streamingLinks')
        .whereType<Map<String, dynamic>>()
        .map(MusicStreamingLinkDto.fromJson)
        .toList(growable: false);
    return MusicMediaLinksDto(
      preview: MusicPreviewDto.fromJson(previewMap),
      streamingLinks: links,
    );
  }
}

class MusicAvailabilityDto {
  const MusicAvailabilityDto({
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

  factory MusicAvailabilityDto.fromJson(dynamic json) {
    final map = _asMap(json) ?? const <String, dynamic>{};
    return MusicAvailabilityDto(
      isAvailableNow: _bool(map['isAvailableNow']),
      availableFrom: _dateTimeOrNull(map['availableFrom']),
      availableUntil: _dateTimeOrNull(map['availableUntil']),
      allowedCountries: _stringList(map['allowedCountries']),
      blockedCountries: _stringList(map['blockedCountries']),
      rightsPolicy: _string(map['rightsPolicy'], fallback: 'OK'),
    );
  }
}

class MusicSetlistItemDto {
  const MusicSetlistItemDto({
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

  factory MusicSetlistItemDto.fromJson(Map<String, dynamic> json) {
    return MusicSetlistItemDto(
      order: _int(json['order']),
      eventId: _string(json['eventId']),
      unitId: _stringOrNull(json['unitId']),
      unitName: _stringOrNull(json['unitName']),
      songId: _stringOrNull(json['songId']),
      songTitle: _stringOrNull(json['songTitle']),
      versionCode: _stringOrNull(json['versionCode']),
      segmentType: _string(json['segmentType'], fallback: 'SONG'),
      startAt: _dateTimeOrNull(json['startAt']),
      endAt: _dateTimeOrNull(json['endAt']),
      isEncore: _bool(json['isEncore']),
      source: _stringOrNull(json['source']),
    );
  }
}

class MusicUnitSetlistDto {
  const MusicUnitSetlistDto({
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

  factory MusicUnitSetlistDto.fromJson(Map<String, dynamic> json) {
    return MusicUnitSetlistDto(
      unitId: _string(json['unitId']),
      unitName: _stringOrNull(json['unitName']),
      performanceOrder: _intOrNull(json['performanceOrder']),
      rawSetlist: _stringOrNull(json['rawSetlist']),
      parsedSongs: _stringList(json['parsedSongs']),
    );
  }
}

class MusicLiveSetlistDto {
  const MusicLiveSetlistDto({
    required this.liveEventId,
    required this.eventStatus,
    required this.items,
    required this.unitSetlists,
  });

  final String liveEventId;
  final String eventStatus;
  final List<MusicSetlistItemDto> items;
  final List<MusicUnitSetlistDto> unitSetlists;

  factory MusicLiveSetlistDto.fromJson(dynamic json) {
    final map = _asMap(json) ?? const <String, dynamic>{};
    final items = _extractList(map, preferredKey: 'items')
        .whereType<Map<String, dynamic>>()
        .map(MusicSetlistItemDto.fromJson)
        .toList(growable: false);
    final unitSetlists = _extractList(map, preferredKey: 'unitSetlists')
        .whereType<Map<String, dynamic>>()
        .map(MusicUnitSetlistDto.fromJson)
        .toList(growable: false);
    return MusicLiveSetlistDto(
      liveEventId: _string(map['liveEventId'] ?? map['eventId']),
      eventStatus: _string(map['eventStatus'], fallback: 'SCHEDULED'),
      items: items,
      unitSetlists: unitSetlists,
    );
  }
}

class MusicSongLiveContextDto {
  const MusicSongLiveContextDto({
    this.song,
    this.lyrics,
    this.parts,
    this.callGuide,
    this.setlistContext,
  });

  final MusicSongDetailDto? song;
  final MusicLyricsPayloadDto? lyrics;
  final MusicPartsPayloadDto? parts;
  final MusicCallGuidePayloadDto? callGuide;
  final MusicLiveSetlistDto? setlistContext;

  factory MusicSongLiveContextDto.fromJson(dynamic json) {
    final map = _asMap(json) ?? const <String, dynamic>{};
    final songMap = _asMap(map['song']);
    final lyricsData = map['lyrics'];
    final partsData = map['parts'];
    final callGuideData = map['callGuide'];
    final setlistContextData = map['setlistContext'];
    return MusicSongLiveContextDto(
      song: songMap == null ? null : MusicSongDetailDto.fromJson(songMap),
      lyrics: lyricsData == null
          ? null
          : MusicLyricsPayloadDto.fromJson(lyricsData),
      parts: partsData == null
          ? null
          : MusicPartsPayloadDto.fromJson(partsData),
      callGuide: callGuideData == null
          ? null
          : MusicCallGuidePayloadDto.fromJson(callGuideData),
      setlistContext: setlistContextData == null
          ? null
          : MusicLiveSetlistDto.fromJson(setlistContextData),
    );
  }
}

Map<String, dynamic>? _asMap(dynamic value) {
  if (value is Map<String, dynamic>) {
    return value;
  }
  return null;
}

List<dynamic> _extractList(dynamic json, {String preferredKey = 'items'}) {
  if (json is List) {
    return json;
  }
  if (json is Map<String, dynamic>) {
    final direct = json[preferredKey];
    if (direct is List) {
      return direct;
    }
    for (final key in const ['items', 'content', 'results', 'data']) {
      final value = json[key];
      if (value is List) {
        return value;
      }
    }
  }
  return const [];
}

String _string(dynamic value, {String fallback = ''}) {
  if (value is String) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? fallback : trimmed;
  }
  return fallback;
}

String? _stringOrNull(dynamic value) {
  if (value is String) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
  return null;
}

int _int(dynamic value, {int fallback = 0}) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? fallback;
  return fallback;
}

int? _intOrNull(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}

bool _bool(dynamic value, {bool fallback = false}) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) {
    final normalized = value.trim().toLowerCase();
    if (normalized == 'true' || normalized == 'yes' || normalized == 'y') {
      return true;
    }
    if (normalized == 'false' || normalized == 'no' || normalized == 'n') {
      return false;
    }
  }
  return fallback;
}

bool? _boolOrNull(dynamic value) {
  if (value == null) return null;
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) {
    final normalized = value.trim().toLowerCase();
    if (normalized == 'true' || normalized == 'yes' || normalized == 'y') {
      return true;
    }
    if (normalized == 'false' || normalized == 'no' || normalized == 'n') {
      return false;
    }
  }
  return null;
}

DateTime? _dateTimeOrNull(dynamic value) {
  if (value is String) {
    return DateTime.tryParse(value);
  }
  return null;
}

List<String> _stringList(dynamic value) {
  if (value is List) {
    return value
        .map((item) => _stringOrNull(item))
        .whereType<String>()
        .toList(growable: false);
  }
  return const [];
}
