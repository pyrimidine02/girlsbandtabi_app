/// EN: Place region filter entities.
/// KO: 장소 지역 필터 엔티티.
library;

import '../../data/dto/place_region_filter_dto.dart';

class RegionOption {
  const RegionOption({
    required this.code,
    required this.name,
    required this.level,
    required this.placeCount,
    required this.hasChildren,
    required this.displayOrder,
    this.parentCode,
  });

  final String code;
  final String name;
  final int level;
  final int placeCount;
  final bool hasChildren;
  final String? parentCode;
  final int displayOrder;

  factory RegionOption.fromDto(RegionOptionDto dto) {
    return RegionOption(
      code: dto.code,
      name: dto.name,
      level: dto.level,
      placeCount: dto.placeCount,
      hasChildren: dto.hasChildren,
      parentCode: dto.parentCode,
      displayOrder: dto.displayOrder,
    );
  }
}

class RegionFilterOptions {
  const RegionFilterOptions({
    required this.countries,
    required this.popularRegions,
    required this.totalRegions,
    required this.totalPlaces,
    required this.lastUpdated,
  });

  final List<RegionOption> countries;
  final List<RegionOption> popularRegions;
  final int totalRegions;
  final int totalPlaces;
  final String lastUpdated;

  factory RegionFilterOptions.fromDto(RegionFilterOptionsDto dto) {
    return RegionFilterOptions(
      countries: dto.countries.map(RegionOption.fromDto).toList(),
      popularRegions: dto.popularRegions.map(RegionOption.fromDto).toList(),
      totalRegions: dto.totalRegions,
      totalPlaces: dto.totalPlaces,
      lastUpdated: dto.lastUpdated,
    );
  }
}

class Coordinate {
  const Coordinate({required this.latitude, required this.longitude});

  final double latitude;
  final double longitude;

  factory Coordinate.fromDto(CoordinateDto dto) {
    return Coordinate(latitude: dto.latitude, longitude: dto.longitude);
  }
}

class RegionMapBounds {
  const RegionMapBounds({
    required this.northEast,
    required this.southWest,
    required this.center,
    required this.zoom,
  });

  final Coordinate northEast;
  final Coordinate southWest;
  final Coordinate center;
  final int zoom;

  factory RegionMapBounds.fromDto(RegionMapBoundsDto dto) {
    return RegionMapBounds(
      northEast: Coordinate.fromDto(dto.northEast),
      southWest: Coordinate.fromDto(dto.southWest),
      center: Coordinate.fromDto(dto.center),
      zoom: dto.zoom,
    );
  }
}
