/// EN: Place domain entities.
/// KO: 장소 도메인 엔티티.
library;

import '../../data/dto/place_dto.dart';
import '../../data/dto/place_stats_dto.dart';

class PlaceSummary {
  const PlaceSummary({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.imageUrl,
    this.distanceLabel,
    this.isVerified = false,
    this.isFavorite = false,
    this.rating,
    this.regionCode,
    this.regionName,
    this.regionPath,
  });

  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final String? imageUrl;
  final String? distanceLabel;
  final bool isVerified;
  final bool isFavorite;
  final double? rating;
  final String? regionCode;
  final String? regionName;
  final String? regionPath;

  factory PlaceSummary.fromDto(PlaceSummaryDto dto) {
    return PlaceSummary(
      id: dto.id,
      name: dto.name,
      address: dto.regionSummary?.primaryName ?? '',
      latitude: dto.latitude,
      longitude: dto.longitude,
      imageUrl: dto.thumbnailUrl,
      distanceLabel: null,
      isVerified: false,
      isFavorite: false,
      rating: null,
      regionCode: dto.regionSummary?.code,
      regionName: dto.regionSummary?.primaryName,
      regionPath: dto.regionSummary?.path,
    );
  }
}

class PlaceDetail {
  const PlaceDetail({
    required this.id,
    required this.name,
    required this.address,
    required this.types,
    this.description,
    this.heroImageUrl,
    this.imageUrls = const [],
    this.isVerified = false,
    this.isFavorite = false,
    this.rating,
    this.visitCount,
    this.favoriteCount,
    this.tags = const [],
  });

  final String id;
  final String name;
  final String address;
  final List<String> types;
  final String? description;
  final String? heroImageUrl;
  final List<String> imageUrls;
  final bool isVerified;
  final bool isFavorite;
  final double? rating;
  final int? visitCount;
  final int? favoriteCount;
  final List<String> tags;

  factory PlaceDetail.fromDto(PlaceDetailDto dto, {PlaceStatsDto? stats}) {
    final imageUrls = dto.images.map((image) => image.url).toList();
    final heroImageUrl =
        dto.primaryImage?.url ?? (imageUrls.isNotEmpty ? imageUrls.first : null);

    return PlaceDetail(
      id: dto.id,
      name: dto.name,
      address: dto.address ?? '',
      types: dto.types,
      description: dto.description,
      heroImageUrl: heroImageUrl,
      imageUrls: imageUrls,
      isVerified: false,
      isFavorite: false,
      rating: null,
      visitCount: stats?.visitCount,
      favoriteCount: stats?.favoriteCount,
      tags: dto.tags,
    );
  }
}
