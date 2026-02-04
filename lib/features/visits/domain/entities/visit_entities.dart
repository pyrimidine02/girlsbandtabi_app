/// EN: User visit domain entities.
/// KO: 사용자 방문 도메인 엔티티.
library;

import 'package:intl/intl.dart';

import '../../data/dto/visit_dto.dart';

class VisitEvent {
  const VisitEvent({
    required this.id,
    required this.placeId,
    required this.visitedAt,
  });

  final String id;
  final String placeId;
  final DateTime? visitedAt;

  factory VisitEvent.fromDto(VisitEventDto dto) {
    return VisitEvent(
      id: dto.id,
      placeId: dto.placeId,
      visitedAt: dto.visitedAt,
    );
  }

  String get visitedAtLabel {
    if (visitedAt == null) return '';
    return DateFormat('yyyy.MM.dd HH:mm').format(visitedAt!.toLocal());
  }
}

class VisitSummary {
  const VisitSummary({
    required this.placeId,
    required this.visitCount,
    required this.firstVisitedAt,
    required this.lastVisitedAt,
  });

  final String placeId;
  final int visitCount;
  final DateTime? firstVisitedAt;
  final DateTime? lastVisitedAt;

  factory VisitSummary.fromDto(VisitSummaryDto dto) {
    return VisitSummary(
      placeId: dto.placeId,
      visitCount: dto.visitCount,
      firstVisitedAt: dto.firstVisitedAt,
      lastVisitedAt: dto.lastVisitedAt,
    );
  }

  String get firstVisitedLabel {
    if (firstVisitedAt == null) return '';
    return DateFormat('yyyy.MM.dd').format(firstVisitedAt!.toLocal());
  }

  String get lastVisitedLabel {
    if (lastVisitedAt == null) return '';
    return DateFormat('yyyy.MM.dd').format(lastVisitedAt!.toLocal());
  }
}
