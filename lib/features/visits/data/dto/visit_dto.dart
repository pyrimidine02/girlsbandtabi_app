/// EN: Visit DTOs for user visit history and summary.
/// KO: 사용자 방문 기록 및 요약 DTO.
library;

class VisitEventDto {
  const VisitEventDto({
    required this.id,
    required this.placeId,
    required this.visitedAt,
  });

  final String id;
  final String placeId;
  final DateTime? visitedAt;

  factory VisitEventDto.fromJson(Map<String, dynamic> json) {
    return VisitEventDto(
      id: json['id'] as String? ?? '',
      placeId: json['placeId'] as String? ?? '',
      visitedAt: _dateTime(json['visitedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'placeId': placeId,
      'visitedAt': visitedAt?.toIso8601String(),
    };
  }
}

class VisitSummaryDto {
  const VisitSummaryDto({
    required this.placeId,
    required this.visitCount,
    required this.firstVisitedAt,
    required this.lastVisitedAt,
  });

  final String placeId;
  final int visitCount;
  final DateTime? firstVisitedAt;
  final DateTime? lastVisitedAt;

  factory VisitSummaryDto.fromJson(Map<String, dynamic> json) {
    return VisitSummaryDto(
      placeId: json['placeId'] as String? ?? '',
      visitCount: _int(json['visitCount']),
      firstVisitedAt: _dateTime(json['firstVisitedAt']),
      lastVisitedAt: _dateTime(json['lastVisitedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'placeId': placeId,
      'visitCount': visitCount,
      'firstVisitedAt': firstVisitedAt?.toIso8601String(),
      'lastVisitedAt': lastVisitedAt?.toIso8601String(),
    };
  }
}

int _int(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

DateTime? _dateTime(dynamic value) {
  if (value is String && value.isNotEmpty) {
    return DateTime.tryParse(value);
  }
  return null;
}
