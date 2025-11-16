import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/live_event.dart';

part 'live_event_model.freezed.dart';
part 'live_event_model.g.dart';

/// EN: Live event data model for JSON serialization
/// KO: JSON 직렬화를 위한 라이브 이벤트 데이터 모델
@freezed
class LiveEventModel with _$LiveEventModel {
  const factory LiveEventModel({
    required String id,
    required String title,
    required String description,
    @JsonKey(name: 'event_date') required DateTime eventDate,
    String? venue,
    String? address,
    double? latitude,
    double? longitude,
    @Default([]) List<LiveEventUnitModel> units,
    @Default([]) List<LiveEventBandModel> bands,
    @Default([]) List<LiveEventPhotoModel> photos,
    @JsonKey(name: 'ticket_url') String? ticketUrl,
    String? price,
    @Default(LiveEventStatus.scheduled) LiveEventStatus status,
    @Default([]) List<String> tags,
    @JsonKey(name: 'is_favorite') @Default(false) bool isFavorite,
    @JsonKey(name: 'attendee_count') @Default(0) int attendeeCount,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _LiveEventModel;

  factory LiveEventModel.fromJson(Map<String, dynamic> json) =>
      _$LiveEventModelFromJson(json);
}

/// EN: Live event unit data model for JSON serialization
/// KO: JSON 직렬화를 위한 라이브 이벤트 단체 데이터 모델
@freezed
class LiveEventUnitModel with _$LiveEventUnitModel {
  const factory LiveEventUnitModel({
    required String id,
    required String name,
    String? description,
    @JsonKey(name: 'avatar_url') String? avatarUrl,
  }) = _LiveEventUnitModel;

  factory LiveEventUnitModel.fromJson(Map<String, dynamic> json) =>
      _$LiveEventUnitModelFromJson(json);
}

/// EN: Live event band data model for JSON serialization
/// KO: JSON 직렬화를 위한 라이브 이벤트 밴드 데이터 모델
@freezed
class LiveEventBandModel with _$LiveEventBandModel {
  const factory LiveEventBandModel({
    required String id,
    required String name,
    String? description,
    @JsonKey(name: 'avatar_url') String? avatarUrl,
    @JsonKey(name: 'set_time') DateTime? setTime,
  }) = _LiveEventBandModel;

  factory LiveEventBandModel.fromJson(Map<String, dynamic> json) =>
      _$LiveEventBandModelFromJson(json);
}

/// EN: Live event photo data model for JSON serialization
/// KO: JSON 직렬화를 위한 라이브 이벤트 사진 데이터 모델
@freezed
class LiveEventPhotoModel with _$LiveEventPhotoModel {
  const factory LiveEventPhotoModel({
    required String id,
    required String url,
    String? caption,
    @JsonKey(name: 'uploaded_by') String? uploadedBy,
    @JsonKey(name: 'uploaded_at') DateTime? uploadedAt,
  }) = _LiveEventPhotoModel;

  factory LiveEventPhotoModel.fromJson(Map<String, dynamic> json) =>
      _$LiveEventPhotoModelFromJson(json);
}

/// EN: Extension to convert LiveEventModel to domain entity
/// KO: LiveEventModel을 도메인 엔티티로 변환하는 확장
extension LiveEventModelX on LiveEventModel {
  /// EN: Convert to domain entity
  /// KO: 도메인 엔티티로 변환
  LiveEvent toDomain() {
    return LiveEvent(
      id: id,
      title: title,
      description: description,
      eventDate: eventDate,
      venue: venue,
      address: address,
      latitude: latitude,
      longitude: longitude,
      units: units.map((unit) => unit.toDomain()).toList(),
      bands: bands.map((band) => band.toDomain()).toList(),
      photos: photos.map((photo) => photo.toDomain()).toList(),
      ticketUrl: ticketUrl,
      price: price,
      status: status,
      tags: tags,
      isFavorite: isFavorite,
      attendeeCount: attendeeCount,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

}

/// EN: Extension to convert domain live event to data model.
/// KO: 도메인 라이브 이벤트를 데이터 모델로 변환하는 확장입니다.
extension LiveEventDomainX on LiveEvent {
  LiveEventModel toModel() {
    return LiveEventModel(
      id: id,
      title: title,
      description: description,
      eventDate: eventDate,
      venue: venue,
      address: address,
      latitude: latitude,
      longitude: longitude,
      units: units.map((unit) => unit.toModel()).toList(),
      bands: bands.map((band) => band.toModel()).toList(),
      photos: photos.map((photo) => photo.toModel()).toList(),
      ticketUrl: ticketUrl,
      price: price,
      status: status,
      tags: tags,
      isFavorite: isFavorite,
      attendeeCount: attendeeCount,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

/// EN: Extension to convert LiveEventUnitModel to domain entity
/// KO: LiveEventUnitModel을 도메인 엔티티로 변환하는 확장
extension LiveEventUnitModelX on LiveEventUnitModel {
  /// EN: Convert to domain entity
  /// KO: 도메인 엔티티로 변환
  LiveEventUnit toDomain() {
    return LiveEventUnit(
      id: id,
      name: name,
      description: description,
      avatarUrl: avatarUrl,
    );
  }

}

extension LiveEventUnitDomainX on LiveEventUnit {
  LiveEventUnitModel toModel() {
    return LiveEventUnitModel(
      id: id,
      name: name,
      description: description,
      avatarUrl: avatarUrl,
    );
  }
}

/// EN: Extension to convert LiveEventBandModel to domain entity
/// KO: LiveEventBandModel을 도메인 엔티티로 변환하는 확장
extension LiveEventBandModelX on LiveEventBandModel {
  /// EN: Convert to domain entity
  /// KO: 도메인 엔티티로 변환
  LiveEventBand toDomain() {
    return LiveEventBand(
      id: id,
      name: name,
      description: description,
      avatarUrl: avatarUrl,
      setTime: setTime,
    );
  }

}

extension LiveEventBandDomainX on LiveEventBand {
  LiveEventBandModel toModel() {
    return LiveEventBandModel(
      id: id,
      name: name,
      description: description,
      avatarUrl: avatarUrl,
      setTime: setTime,
    );
  }
}

/// EN: Extension to convert LiveEventPhotoModel to domain entity
/// KO: LiveEventPhotoModel을 도메인 엔티티로 변환하는 확장
extension LiveEventPhotoModelX on LiveEventPhotoModel {
  /// EN: Convert to domain entity
  /// KO: 도메인 엔티티로 변환
  LiveEventPhoto toDomain() {
    return LiveEventPhoto(
      id: id,
      url: url,
      caption: caption,
      uploadedBy: uploadedBy,
      uploadedAt: uploadedAt,
    );
  }

}

extension LiveEventPhotoDomainX on LiveEventPhoto {
  LiveEventPhotoModel toModel() {
    return LiveEventPhotoModel(
      id: id,
      url: url,
      caption: caption,
      uploadedBy: uploadedBy,
      uploadedAt: uploadedAt,
    );
  }
}
