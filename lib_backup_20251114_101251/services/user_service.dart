import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../models/place_model.dart';
import '../models/user_model.dart';
import '../models/visit_model.dart';

class UserService {
  UserService();

  final ApiClient _api = ApiClient.instance;

  Future<User> getCurrentUser() async {
    final envelope = await _api.get(ApiConstants.me);
    return User.fromJson(envelope.requireDataAsMap());
  }

  Future<User> updateCurrentUser({
    String? displayName,
    String? avatarUrl,
  }) async {
    final body = <String, dynamic>{
      if (displayName != null) 'displayName': displayName,
      if (avatarUrl != null) 'avatarUrl': avatarUrl,
    };
    final envelope = await _api.patch(
      ApiConstants.me,
      data: body,
    );
    return User.fromJson(envelope.requireDataAsMap());
  }

  Future<List<Visit>> getMyVisits({
    int page = 0,
    int size = 10,
    String? sort,
  }) async {
    final envelope = await _api.get(
      ApiConstants.myVisits,
      queryParameters: {
        'page': page,
        'size': size,
        if (sort != null) 'sort': sort,
      },
    );

    final raw = envelope.data;
    List<dynamic> items;
    if (raw is List) {
      items = raw;
    } else if (raw is Map<String, dynamic>) {
      items = (raw['items'] as List?) ??
          (raw['visits'] as List?) ??
          const <dynamic>[];
    } else {
      items = const <dynamic>[];
    }

    return items
        .whereType<Map<String, dynamic>>()
        .map(_mapVisit)
        .toList(growable: false);
  }

  Future<VisitSummary> getVisitSummary(String placeId) async {
    final envelope = await _api.get(
      ApiConstants.visitsSummary,
      queryParameters: {'placeId': placeId},
    );
    final data = envelope.requireDataAsMap();
    final firstVisit = data['firstVisitAt'] ?? data['firstVisit'];
    final lastVisit = data['lastVisitAt'] ?? data['lastVisit'];
    return VisitSummary(
      placeId: data['placeId']?.toString() ?? placeId,
      totalVisits: (data['totalVisits'] as num?)?.toInt() ?? 0,
      firstVisit:
          firstVisit != null ? DateTime.tryParse(firstVisit.toString()) : null,
      lastVisit: lastVisit != null ? DateTime.tryParse(lastVisit.toString()) : null,
      userVisits: (data['userVisits'] as num?)?.toInt() ?? 0,
      uniqueSubjects: (data['uniqueSubjects'] as num?)?.toInt(),
      avgAccuracyM: (data['avgAccuracyM'] as num?)?.toDouble(),
    );
  }

  Visit _mapVisit(Map<String, dynamic> json) {
    final placeJson = (json['place'] as Map<String, dynamic>?) ??
        (json['placeSummary'] as Map<String, dynamic>?) ??
        <String, dynamic>{};
    final created =
        json['visitDate'] ?? json['visitedAt'] ?? json['createdAt'];
    return Visit(
      id: json['id']?.toString() ?? json['visitId']?.toString() ?? '',
      userId: json['userId']?.toString() ??
          json['subjectId']?.toString() ??
          json['user']?['id']?.toString() ??
          '',
      place: _mapPlace(placeJson),
      visitDate: created != null
          ? DateTime.tryParse(created.toString()) ?? DateTime.now()
          : DateTime.now(),
      notes: json['notes'] as String?,
      status: json['status']?.toString(),
      distanceM: (json['distanceM'] as num?)?.toDouble() ??
          (json['distance'] as num?)?.toDouble(),
      accuracyM: (json['accuracyM'] as num?)?.toDouble() ??
          (json['accuracy'] as num?)?.toDouble(),
      verificationMethod: json['verificationMethod']?.toString() ??
          json['method']?.toString(),
      photoUrls: (json['photoUrls'] as List<dynamic>? ??
              json['photos'] as List<dynamic>? ??
              const <dynamic>[]) 
          .map((e) => e.toString())
          .toList(growable: false),
    );
  }

  Place _mapPlace(Map<String, dynamic> json) {
    final primaryImage = json['primaryImage'] as Map<String, dynamic>?;
    final images = (json['images'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .map((e) => e['url']?.toString())
        .whereType<String>()
        .toList(growable: false);
    final tags = (json['tags'] as List<dynamic>? ?? [])
        .map((e) => e.toString())
        .toList(growable: false);
    final imageUrl = primaryImage?['url']?.toString() ??
        json['thumbnailUrl']?.toString() ??
        json['imageUrl']?.toString() ??
        (images.isNotEmpty ? images.first : null);

    return Place(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Unknown place',
      description: json['description']?.toString() ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0,
      type: _mapPlaceType(json['type']?.toString()),
      address: json['address'] as String?,
      imageUrl: imageUrl,
      tags: tags,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
    );
  }

  PlaceType _mapPlaceType(String? raw) {
    if (raw == null) return PlaceType.other;
    final normalized = raw
        .replaceAll('-', '_')
        .replaceAll(' ', '_')
        .toLowerCase();
    switch (normalized) {
      case 'concert_venue':
      case 'livehouse':
      case 'live_house':
        return PlaceType.concertVenue;
      case 'cafe_collaboration':
      case 'collaboration_cafe':
      case 'cafe':
        return PlaceType.cafeCollaboration;
      case 'anime_location':
      case 'real_location':
      case 'seichi':
        return PlaceType.animeLocation;
      case 'character_shop':
      case 'shop':
        return PlaceType.characterShop;
      default:
        return PlaceType.other;
    }
  }
}
