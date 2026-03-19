/// EN: DTO for calendar event API responses.
/// KO: 캘린더 이벤트 API 응답의 DTO.
library;

import '../../domain/entities/calendar_event.dart';

/// EN: Data transfer object representing a raw calendar event from the API.
/// KO: API에서 수신한 원시 캘린더 이벤트를 나타내는 데이터 전송 객체.
class CalendarEventDto {
  const CalendarEventDto({
    required this.id,
    required this.title,
    required this.date,
    required this.type,
    this.description,
    this.imageUrl,
    this.projectId,
    this.projectCode,
    this.relatedEntityId,
    this.relatedEntityType,
    this.isRecurringAnnually = false,
  });

  /// EN: Constructs a [CalendarEventDto] from a JSON map.
  /// KO: JSON 맵에서 [CalendarEventDto]를 생성합니다.
  factory CalendarEventDto.fromJson(Map<String, dynamic> json) {
    return CalendarEventDto(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      date: DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime.now(),
      type: json['type'] as String?,
      description: json['description'] as String?,
      imageUrl:
          json['imageUrl'] as String? ?? json['image_url'] as String?,
      projectId:
          json['projectId'] as String? ?? json['project_id'] as String?,
      projectCode:
          json['projectCode'] as String? ?? json['project_code'] as String?,
      relatedEntityId: json['relatedEntityId'] as String? ??
          json['related_entity_id'] as String?,
      relatedEntityType: json['relatedEntityType'] as String? ??
          json['related_entity_type'] as String?,
      isRecurringAnnually: json['isRecurringAnnually'] as bool? ??
          json['is_recurring_annually'] as bool? ??
          false,
    );
  }

  final String id;
  final String title;
  final DateTime date;
  final String? type;
  final String? description;
  final String? imageUrl;
  final String? projectId;
  final String? projectCode;
  final String? relatedEntityId;
  final String? relatedEntityType;
  final bool isRecurringAnnually;

  /// EN: Maps this DTO to the domain [CalendarEvent] entity.
  /// KO: 이 DTO를 도메인 [CalendarEvent] 엔티티로 매핑합니다.
  CalendarEvent toEntity() => CalendarEvent(
        id: id,
        title: title,
        date: date,
        type: CalendarEventType.fromString(type),
        description: description,
        imageUrl: imageUrl,
        projectId: projectId,
        projectCode: projectCode,
        relatedEntityId: relatedEntityId,
        relatedEntityType: relatedEntityType,
        isRecurringAnnually: isRecurringAnnually,
      );
}
