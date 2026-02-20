/// EN: Utilities for mapping place types to map marker styles.
/// KO: 장소 유형을 지도 마커 스타일로 매핑하는 유틸리티.
library;

import 'place_type_search.dart';

/// EN: Returns marker hue based on the first place type.
/// KO: 첫 번째 장소 유형을 기준으로 마커 hue를 반환합니다.
double placeMarkerHueFromFirstType(List<String> types) {
  if (types.isEmpty) {
    return 0.0;
  }

  final normalized = normalizePlaceSearchText(types.first);
  if (normalized.isEmpty) {
    return 0.0;
  }

  // EN: Use broad category buckets so API enum variations still map predictably.
  // KO: API enum 변형에도 안정적으로 대응하도록 넓은 카테고리로 매핑합니다.
  if (_containsAny(normalized, const ['station', 'subway', 'rail'])) {
    return 210.0; // azure
  }
  if (_containsAny(normalized, const ['live house', 'concert', 'music'])) {
    return 330.0; // rose
  }
  if (_containsAny(normalized, const ['cafe', 'restaurant', 'food'])) {
    return 30.0; // orange
  }
  if (_containsAny(normalized, const ['shop', 'store', 'goods'])) {
    return 270.0; // violet
  }
  if (_containsAny(normalized, const ['park', 'landmark', 'nature'])) {
    return 120.0; // green
  }
  if (_containsAny(normalized, const ['temple', 'shrine', 'relig'])) {
    return 60.0; // yellow
  }
  if (_containsAny(normalized, const ['school', 'studio', 'museum'])) {
    return 180.0; // cyan
  }

  return 0.0; // red(default)
}

bool _containsAny(String source, List<String> candidates) {
  for (final candidate in candidates) {
    if (source.contains(candidate)) {
      return true;
    }
  }
  return false;
}
