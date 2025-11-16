import 'package:equatable/equatable.dart';

/// EN: Live event entity representing event data in domain layer  
/// KO: 도메인 계층에서 라이브 이벤트 데이터를 나타내는 엔티티
class LiveEvent extends Equatable {
  /// EN: Creates a new LiveEvent instance
  /// KO: 새로운 LiveEvent 인스턴스 생성
  const LiveEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.eventDate,
    this.venue,
    this.address,
    this.latitude,
    this.longitude,
    this.units = const [],
    this.bands = const [],
    this.photos = const [],
    this.ticketUrl,
    this.price,
    this.status = LiveEventStatus.scheduled,
    this.tags = const [],
    this.isFavorite = false,
    this.attendeeCount = 0,
    this.createdAt,
    this.updatedAt,
  });

  /// EN: Unique identifier for the live event
  /// KO: 라이브 이벤트의 고유 식별자
  final String id;

  /// EN: Event title
  /// KO: 이벤트 제목
  final String title;

  /// EN: Event description
  /// KO: 이벤트 설명
  final String description;

  /// EN: Event date and time
  /// KO: 이벤트 날짜 및 시간
  final DateTime eventDate;

  /// EN: Venue name
  /// KO: 공연장 이름
  final String? venue;

  /// EN: Venue address
  /// KO: 공연장 주소
  final String? address;

  /// EN: Venue latitude coordinate
  /// KO: 공연장 위도 좌표
  final double? latitude;

  /// EN: Venue longitude coordinate
  /// KO: 공연장 경도 좌표
  final double? longitude;

  /// EN: Units associated with the event
  /// KO: 이벤트와 연관된 단체들
  final List<LiveEventUnit> units;

  /// EN: Bands performing at the event
  /// KO: 이벤트에서 공연하는 밴드들
  final List<LiveEventBand> bands;

  /// EN: Event photos
  /// KO: 이벤트 사진들
  final List<LiveEventPhoto> photos;

  /// EN: Ticket purchase URL
  /// KO: 티켓 구매 URL
  final String? ticketUrl;

  /// EN: Event ticket price
  /// KO: 이벤트 티켓 가격
  final String? price;

  /// EN: Event status
  /// KO: 이벤트 상태
  final LiveEventStatus status;

  /// EN: Tags associated with the event
  /// KO: 이벤트와 연관된 태그들
  final List<String> tags;

  /// EN: Whether the event is marked as favorite by current user
  /// KO: 현재 사용자가 즐겨찾기로 표시했는지 여부
  final bool isFavorite;

  /// EN: Number of attendees
  /// KO: 참석자 수
  final int attendeeCount;

  /// EN: When the event was created
  /// KO: 이벤트 생성 시간
  final DateTime? createdAt;

  /// EN: When the event was last updated
  /// KO: 이벤트 마지막 업데이트 시간
  final DateTime? updatedAt;

  /// EN: Creates a copy of this live event with updated fields
  /// KO: 업데이트된 필드로 이 라이브 이벤트의 복사본 생성
  LiveEvent copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? eventDate,
    String? venue,
    String? address,
    double? latitude,
    double? longitude,
    List<LiveEventUnit>? units,
    List<LiveEventBand>? bands,
    List<LiveEventPhoto>? photos,
    String? ticketUrl,
    String? price,
    LiveEventStatus? status,
    List<String>? tags,
    bool? isFavorite,
    int? attendeeCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return LiveEvent(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      eventDate: eventDate ?? this.eventDate,
      venue: venue ?? this.venue,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      units: units ?? this.units,
      bands: bands ?? this.bands,
      photos: photos ?? this.photos,
      ticketUrl: ticketUrl ?? this.ticketUrl,
      price: price ?? this.price,
      status: status ?? this.status,
      tags: tags ?? this.tags,
      isFavorite: isFavorite ?? this.isFavorite,
      attendeeCount: attendeeCount ?? this.attendeeCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// EN: Get main photo URL for display
  /// KO: 표시용 메인 사진 URL 가져오기
  String? get mainPhotoUrl => photos.isNotEmpty ? photos.first.url : null;

  /// EN: Get formatted event date
  /// KO: 형식화된 이벤트 날짜 가져오기
  String get formattedDate {
    final now = DateTime.now();
    final difference = eventDate.difference(now);

    if (difference.inDays > 0) {
      return '${difference.inDays}일 후';
    } else if (difference.inDays == 0) {
      return '오늘';
    } else if (difference.inDays == -1) {
      return '어제';
    } else {
      return '${difference.inDays.abs()}일 전';
    }
  }

  /// EN: Get formatted event time
  /// KO: 형식화된 이벤트 시간 가져오기
  String get formattedTime {
    final hour = eventDate.hour.toString().padLeft(2, '0');
    final minute = eventDate.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  /// EN: Get display price text
  /// KO: 표시용 가격 텍스트 가져오기
  String get displayPrice => price ?? '가격 미정';

  /// EN: Get tags as display string
  /// KO: 표시용 태그 문자열 가져오기
  String get displayTags => tags.isNotEmpty ? tags.join(', ') : '';

  /// EN: Check if event has photos
  /// KO: 이벤트에 사진이 있는지 확인
  bool get hasPhotos => photos.isNotEmpty;

  /// EN: Check if event has venue information
  /// KO: 이벤트에 공연장 정보가 있는지 확인
  bool get hasVenue => venue != null && venue!.isNotEmpty;

  /// EN: Check if event has location coordinates
  /// KO: 이벤트에 위치 좌표가 있는지 확인
  bool get hasLocation => latitude != null && longitude != null;

  /// EN: Check if event is upcoming
  /// KO: 이벤트가 예정된 것인지 확인
  bool get isUpcoming {
    final now = DateTime.now();
    return eventDate.isAfter(now) && status == LiveEventStatus.scheduled;
  }

  /// EN: Check if event is currently happening
  /// KO: 이벤트가 현재 진행 중인지 확인
  bool get isLive {
    final now = DateTime.now();
    final eventEnd = eventDate.add(const Duration(hours: 3)); // EN: Assume 3-hour duration / KO: 3시간 지속 가정
    return now.isAfter(eventDate) && now.isBefore(eventEnd) && status == LiveEventStatus.live;
  }

  /// EN: Check if event has ended
  /// KO: 이벤트가 종료되었는지 확인
  bool get hasEnded {
    final now = DateTime.now();
    final eventEnd = eventDate.add(const Duration(hours: 3));
    return now.isAfter(eventEnd) || status == LiveEventStatus.cancelled;
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        eventDate,
        venue,
        address,
        latitude,
        longitude,
        units,
        bands,
        photos,
        ticketUrl,
        price,
        status,
        tags,
        isFavorite,
        attendeeCount,
        createdAt,
        updatedAt,
      ];

  @override
  String toString() {
    return 'LiveEvent(id: $id, title: $title, eventDate: $eventDate, status: $status)';
  }
}

/// EN: Live event status enumeration
/// KO: 라이브 이벤트 상태 열거형
enum LiveEventStatus {
  scheduled, // EN: Scheduled for future / KO: 예정됨
  live,      // EN: Currently happening / KO: 현재 진행 중
  completed, // EN: Successfully completed / KO: 성공적으로 완료됨
  cancelled, // EN: Cancelled or postponed / KO: 취소 또는 연기됨
}

/// EN: Unit/band associated with a live event
/// KO: 라이브 이벤트와 연관된 단체/밴드
class LiveEventUnit extends Equatable {
  const LiveEventUnit({
    required this.id,
    required this.name,
    this.description,
    this.avatarUrl,
  });

  final String id;
  final String name;
  final String? description;
  final String? avatarUrl;

  @override
  List<Object?> get props => [id, name, description, avatarUrl];
}

/// EN: Band performing at a live event
/// KO: 라이브 이벤트에서 공연하는 밴드
class LiveEventBand extends Equatable {
  const LiveEventBand({
    required this.id,
    required this.name,
    this.description,
    this.avatarUrl,
    this.setTime,
  });

  final String id;
  final String name;
  final String? description;
  final String? avatarUrl;
  final DateTime? setTime;

  @override
  List<Object?> get props => [id, name, description, avatarUrl, setTime];
}

/// EN: Photo of a live event
/// KO: 라이브 이벤트의 사진
class LiveEventPhoto extends Equatable {
  const LiveEventPhoto({
    required this.id,
    required this.url,
    this.caption,
    this.uploadedBy,
    this.uploadedAt,
  });

  final String id;
  final String url;
  final String? caption;
  final String? uploadedBy;
  final DateTime? uploadedAt;

  @override
  List<Object?> get props => [id, url, caption, uploadedBy, uploadedAt];
}

/// EN: Venue information for live events
/// KO: 라이브 이벤트를 위한 공연장 정보
class EventVenue extends Equatable {
  /// EN: Creates a new EventVenue instance
  /// KO: 새로운 EventVenue 인스턴스 생성
  const EventVenue({
    required this.name,
    this.address,
    this.latitude,
    this.longitude,
    this.website,
    this.phoneNumber,
  });

  /// EN: Name of the venue
  /// KO: 공연장 이름
  final String name;

  /// EN: Address of the venue
  /// KO: 공연장 주소
  final String? address;

  /// EN: Latitude coordinate
  /// KO: 위도 좌표
  final double? latitude;

  /// EN: Longitude coordinate
  /// KO: 경도 좌표
  final double? longitude;

  /// EN: Website URL
  /// KO: 웹사이트 URL
  final String? website;

  /// EN: Contact phone number
  /// KO: 연락처 전화번호
  final String? phoneNumber;

  @override
  List<Object?> get props => [name, address, latitude, longitude, website, phoneNumber];
}

