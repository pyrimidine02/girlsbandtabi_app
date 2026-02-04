/// EN: Live event DTOs aligned with Swagger schema.
/// KO: Swagger 스키마에 맞춘 라이브 이벤트 DTO.
library;

import '../../../../core/models/image_meta_dto.dart';

class LiveEventSummaryDto {
  const LiveEventSummaryDto({
    required this.id,
    required this.title,
    required this.showStartTime,
    required this.status,
    required this.projectIds,
    required this.unitIds,
    this.doorsOpenTime,
    this.bannerUrl,
    this.bannerFilename,
    this.bannerSize,
    this.ticketUrl,
  });

  final String id;
  final String title;
  final DateTime showStartTime;
  final DateTime? doorsOpenTime;
  final String status;
  final String? bannerUrl;
  final String? bannerFilename;
  final int? bannerSize;
  final String? ticketUrl;
  final List<String> projectIds;
  final List<String> unitIds;

  factory LiveEventSummaryDto.fromJson(Map<String, dynamic> json) {
    return LiveEventSummaryDto(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      showStartTime: _dateTime(json['showStartTime']),
      doorsOpenTime: _dateTimeOrNull(json['doorsOpenTime']),
      status: json['status'] as String? ?? 'UNKNOWN',
      bannerUrl: json['bannerUrl'] as String?,
      bannerFilename: json['bannerFilename'] as String?,
      bannerSize: _intOrNull(json['bannerSize']),
      ticketUrl: json['ticketUrl'] as String?,
      projectIds: _stringList(json['projectIds']),
      unitIds: _stringList(json['unitIds']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'showStartTime': showStartTime.toIso8601String(),
      'doorsOpenTime': doorsOpenTime?.toIso8601String(),
      'status': status,
      'bannerUrl': bannerUrl,
      'bannerFilename': bannerFilename,
      'bannerSize': bannerSize,
      'ticketUrl': ticketUrl,
      'projectIds': projectIds,
      'unitIds': unitIds,
    };
  }
}

class LiveEventDetailDto {
  const LiveEventDetailDto({
    required this.id,
    required this.title,
    required this.showStartTime,
    required this.status,
    required this.projectIds,
    required this.unitIds,
    this.description,
    this.doorsOpenTime,
    this.endTime,
    this.banner,
    this.ticketUrl,
  });

  final String id;
  final String title;
  final String? description;
  final DateTime showStartTime;
  final DateTime? doorsOpenTime;
  final DateTime? endTime;
  final String status;
  final ImageMetaDto? banner;
  final String? ticketUrl;
  final List<String> projectIds;
  final List<String> unitIds;

  factory LiveEventDetailDto.fromJson(Map<String, dynamic> json) {
    return LiveEventDetailDto(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      showStartTime: _dateTime(json['showStartTime']),
      doorsOpenTime: _dateTimeOrNull(json['doorsOpenTime']),
      endTime: _dateTimeOrNull(json['endTime']),
      status: json['status'] as String? ?? 'UNKNOWN',
      banner: json['banner'] is Map<String, dynamic>
          ? ImageMetaDto.fromJson(json['banner'] as Map<String, dynamic>)
          : null,
      ticketUrl: json['ticketUrl'] as String?,
      projectIds: _stringList(json['projectIds']),
      unitIds: _stringList(json['unitIds']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'showStartTime': showStartTime.toIso8601String(),
      'doorsOpenTime': doorsOpenTime?.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'status': status,
      'banner': banner?.toJson(),
      'ticketUrl': ticketUrl,
      'projectIds': projectIds,
      'unitIds': unitIds,
    };
  }
}

DateTime _dateTime(dynamic value) {
  if (value is String) {
    return DateTime.tryParse(value) ?? DateTime.fromMillisecondsSinceEpoch(0);
  }
  return DateTime.fromMillisecondsSinceEpoch(0);
}

DateTime? _dateTimeOrNull(dynamic value) {
  if (value is String) {
    return DateTime.tryParse(value);
  }
  return null;
}

int? _intOrNull(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}

List<String> _stringList(dynamic value) {
  if (value is List) {
    return value.whereType<String>().toList();
  }
  return <String>[];
}
