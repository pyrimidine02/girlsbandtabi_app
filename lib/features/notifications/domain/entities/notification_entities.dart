/// EN: Notification domain entities.
/// KO: 알림 도메인 엔티티.
library;

import 'package:intl/intl.dart';

import '../../data/dto/notification_dto.dart';

class NotificationItem {
  const NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.createdAt,
    required this.isRead,
  });

  final String id;
  final String title;
  final String body;
  final DateTime createdAt;
  final bool isRead;

  String get dateLabel {
    return DateFormat('yyyy.MM.dd').format(createdAt.toLocal());
  }

  factory NotificationItem.fromDto(NotificationItemDto dto) {
    return NotificationItem(
      id: dto.id,
      title: dto.title,
      body: dto.body,
      createdAt: dto.createdAt,
      isRead: dto.isRead,
    );
  }
}
