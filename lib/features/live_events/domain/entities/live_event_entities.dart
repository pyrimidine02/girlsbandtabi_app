/// EN: Live event domain entities.
/// KO: 라이브 이벤트 도메인 엔티티.
library;

import 'package:intl/intl.dart';

import '../../data/dto/live_event_dto.dart';

class LiveEventSummary {
  const LiveEventSummary({
    required this.id,
    required this.title,
    required this.showStartTime,
    required this.status,
    required this.projectIds,
    required this.unitIds,
    this.bannerUrl,
  });

  final String id;
  final String title;
  final DateTime showStartTime;
  final String status;
  final List<String> projectIds;
  final List<String> unitIds;
  final String? bannerUrl;

  bool get isUpcoming {
    return showStartTime.isAfter(DateTime.now());
  }

  String get dateLabel {
    return DateFormat('M월 d일').format(showStartTime.toLocal());
  }

  String get dDayLabel {
    return _formatDDay(showStartTime);
  }

  String get statusLabel => status;

  String get metaLabel {
    return '프로젝트 ${projectIds.length} · 유닛 ${unitIds.length}';
  }

  factory LiveEventSummary.fromDto(LiveEventSummaryDto dto) {
    return LiveEventSummary(
      id: dto.id,
      title: dto.title,
      showStartTime: dto.showStartTime,
      status: dto.status,
      projectIds: dto.projectIds,
      unitIds: dto.unitIds,
      bannerUrl: dto.bannerUrl,
    );
  }
}

class LiveEventDetail {
  const LiveEventDetail({
    required this.id,
    required this.title,
    this.description,
    required this.showStartTime,
    this.doorsOpenTime,
    this.endTime,
    required this.status,
    required this.projectIds,
    required this.unitIds,
    this.bannerUrl,
    this.ticketUrl,
  });

  final String id;
  final String title;
  final String? description;
  final DateTime showStartTime;
  final DateTime? doorsOpenTime;
  final DateTime? endTime;
  final String status;
  final List<String> projectIds;
  final List<String> unitIds;
  final String? bannerUrl;
  final String? ticketUrl;

  String get metaLabel {
    return '프로젝트 ${projectIds.length} · 유닛 ${unitIds.length}';
  }

  String get dateLabel {
    return DateFormat('yyyy년 M월 d일').format(showStartTime.toLocal());
  }

  String get dDayLabel {
    return _formatDDay(showStartTime);
  }

  String get timeLabel {
    return DateFormat('HH:mm').format(showStartTime.toLocal());
  }

  String get doorTimeLabel {
    if (doorsOpenTime == null) return '미정';
    return DateFormat('HH:mm').format(doorsOpenTime!.toLocal());
  }

  factory LiveEventDetail.fromDto(LiveEventDetailDto dto) {
    return LiveEventDetail(
      id: dto.id,
      title: dto.title,
      description: dto.description,
      showStartTime: dto.showStartTime,
      doorsOpenTime: dto.doorsOpenTime,
      endTime: dto.endTime,
      status: dto.status,
      projectIds: dto.projectIds,
      unitIds: dto.unitIds,
      bannerUrl: dto.banner?.url,
      ticketUrl: dto.ticketUrl,
    );
  }
}

String _formatDDay(DateTime dateTime) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final localDateTime = dateTime.toLocal();
  final eventDate =
      DateTime(localDateTime.year, localDateTime.month, localDateTime.day);
  final diff = eventDate.difference(today).inDays;
  if (diff == 0) {
    return 'D-day';
  }
  if (diff > 0) {
    return 'D-$diff';
  }
  return 'D+${diff.abs()}';
}
