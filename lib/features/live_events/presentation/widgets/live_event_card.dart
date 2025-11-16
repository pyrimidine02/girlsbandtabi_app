import 'package:flutter/material.dart';

import '../../../../core/theme/kt_colors.dart';
import '../../domain/entities/live_event.dart';

/// EN: Card widget displaying live event information
/// KO: 라이브 이벤트 정보를 표시하는 카드 위젯
class LiveEventCard extends StatelessWidget {
  /// EN: Creates LiveEventCard with event data and callbacks
  /// KO: 이벤트 데이터와 콜백으로 LiveEventCard 생성
  const LiveEventCard({
    super.key,
    required this.event,
    this.onTap,
    this.onFavoriteToggle,
  });

  /// EN: Live event data to display
  /// KO: 표시할 라이브 이벤트 데이터
  final LiveEvent event;

  /// EN: Callback when card is tapped
  /// KO: 카드를 탭했을 때의 콜백
  final VoidCallback? onTap;

  /// EN: Callback when favorite button is tapped
  /// KO: 즐겨찾기 버튼을 탭했을 때의 콜백
  final VoidCallback? onFavoriteToggle;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // EN: Header with title and favorite button
              // KO: 제목과 즐겨찾기 버튼이 있는 헤더
              Row(
                children: [
                  Expanded(
                    child: Text(
                      event.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      event.isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: event.isFavorite ? Colors.red : Colors.grey,
                    ),
                    onPressed: onFavoriteToggle,
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // EN: Event description
              // KO: 이벤트 설명
              if (event.description.isNotEmpty)
                Text(
                  event.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),

              const SizedBox(height: 12),

              // EN: Event details row
              // KO: 이벤트 상세 정보 행
              Row(
                children: [
                  // EN: Date and time
                  // KO: 날짜 및 시간
                  Icon(
                    Icons.schedule,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${event.formattedDate} ${event.formattedTime}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),

                  const SizedBox(width: 16),

                  // EN: Venue information
                  // KO: 공연장 정보
                  if (event.hasVenue) ...[
                    Icon(
                      Icons.location_on,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        event.venue!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),

              const SizedBox(height: 12),

              // EN: Status badge and price
              // KO: 상태 배지 및 가격
              Row(
                children: [
                  // EN: Status badge
                  // KO: 상태 배지
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(event.status),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getStatusText(event.status),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  const Spacer(),

                  // EN: Price information
                  // KO: 가격 정보
                  if (event.price != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: KTColors.accent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        event.displayPrice,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),

              // EN: Tags if available
              // KO: 태그가 있으면 표시
              if (event.tags.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  children: event.tags.take(3).map((tag) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '#$tag',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey[700],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// EN: Get color for status badge
  /// KO: 상태 배지 색상 가져오기
  Color _getStatusColor(LiveEventStatus status) {
    switch (status) {
      case LiveEventStatus.scheduled:
        return Colors.blue;
      case LiveEventStatus.live:
        return Colors.green;
      case LiveEventStatus.completed:
        return Colors.grey;
      case LiveEventStatus.cancelled:
        return Colors.red;
    }
  }

  /// EN: Get text for status badge
  /// KO: 상태 배지 텍스트 가져오기
  String _getStatusText(LiveEventStatus status) {
    switch (status) {
      case LiveEventStatus.scheduled:
        return '예정';
      case LiveEventStatus.live:
        return '진행 중';
      case LiveEventStatus.completed:
        return '완료';
      case LiveEventStatus.cancelled:
        return '취소';
    }
  }
}
