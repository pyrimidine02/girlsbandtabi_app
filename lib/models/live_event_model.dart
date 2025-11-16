import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/live_event_provider.dart'; // Import LiveTab

class LiveEvent {
  final String id;
  final String title;
  final String? description;
  final DateTime startTime;
  final DateTime? endTime;
  final String status; // e.g., UPCOMING | ONGOING | COMPLETED
  final String? placeId;

  LiveEvent({
    required this.id,
    required this.title,
    this.description,
    required this.startTime,
    this.endTime,
    required this.status,
    this.placeId,
  });

  factory LiveEvent.fromJson(Map<String, dynamic> json) {
    return LiveEvent(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: json['endTime'] != null ? DateTime.tryParse(json['endTime'] as String) : null,
      status: json['status'] as String,
      placeId: json['placeId'] as String?,
    );
  }

  LiveTab get realtimeStatus {
    final now = DateTime.now();
    if (startTime.isAfter(now)) {
      return LiveTab.upcoming;
    } else if (endTime == null || endTime!.isAfter(now)) {
      return LiveTab.ongoing;
    } else {
      return LiveTab.past;
    }
  }
}

class PageResponseLiveEvent {
  final List<LiveEvent> items;
  final int page;
  final int size;
  final int total;
  final int? totalPages;
  final bool hasNext;
  final bool hasPrevious;

  const PageResponseLiveEvent({
    required this.items,
    required this.page,
    required this.size,
    required this.total,
    this.totalPages,
    this.hasNext = false,
    this.hasPrevious = false,
  });

  factory PageResponseLiveEvent.fromJson(Map<String, dynamic> json) {
    final list = (json['items'] as List<dynamic>? ??
            json['data'] as List<dynamic>? ??
            const <dynamic>[])
        .map((e) => LiveEvent.fromJson(e as Map<String, dynamic>))
        .toList();
    final pagination = json['pagination'] as Map<String, dynamic>?;
    return PageResponseLiveEvent(
      items: list,
      page: (pagination?['currentPage'] as num?)?.toInt() ??
          (json['page'] as num?)?.toInt() ?? 0,
      size: (pagination?['pageSize'] as num?)?.toInt() ??
          (json['size'] as num?)?.toInt() ?? list.length,
      total: (pagination?['totalItems'] as num?)?.toInt() ??
          (json['total'] as num?)?.toInt() ?? list.length,
      totalPages: (pagination?['totalPages'] as num?)?.toInt() ??
          (json['totalPages'] as num?)?.toInt(),
      hasNext: pagination?['hasNext'] as bool? ??
          (json['hasNext'] as bool?) ?? false,
      hasPrevious: pagination?['hasPrevious'] as bool? ??
          (json['hasPrevious'] as bool?) ?? false,
    );
  }
}