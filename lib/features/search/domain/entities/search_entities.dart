/// EN: Search domain entities for unified search.
/// KO: 통합 검색 도메인 엔티티.
library;

import 'package:intl/intl.dart';

import '../../data/dto/search_item_dto.dart';

enum SearchItemType { place, liveEvent, news, post, unit, project, unknown }

class SearchItem {
  const SearchItem({
    required this.id,
    required this.title,
    required this.type,
    this.subtitle,
    this.imageUrl,
    this.category,
    this.publishedAt,
  });

  final String id;
  final String title;
  final SearchItemType type;
  final String? subtitle;
  final String? imageUrl;
  final String? category;
  final DateTime? publishedAt;

  String get dateLabel {
    if (publishedAt == null) return '';
    return DateFormat('yyyy.MM.dd').format(publishedAt!.toLocal());
  }

  factory SearchItem.fromDto(SearchItemDto dto) {
    final item = dto.item;
    final id = _string(item, ['id', 'itemId', 'targetId']) ?? '';
    final title = _string(item, ['title', 'name', 'headline']) ?? '검색 결과';
    final subtitle = _string(item, ['subtitle', 'summary', 'description']);
    final imageUrl = _string(item, ['imageUrl', 'thumbnailUrl', 'image']);
    final category =
        _string(item, ['category', 'tag', 'group']) ?? dto.type;
    final publishedAt = _dateTime(item, ['publishedAt', 'createdAt', 'date']);

    return SearchItem(
      id: id,
      title: title,
      type: _mapType(dto.type),
      subtitle: subtitle,
      imageUrl: imageUrl,
      category: category,
      publishedAt: publishedAt,
    );
  }
}

SearchItemType _mapType(String? raw) {
  final value = raw?.toLowerCase() ?? '';
  if (value.contains('place') || value.contains('location')) {
    return SearchItemType.place;
  }
  if (value.contains('live') || value.contains('event')) {
    return SearchItemType.liveEvent;
  }
  if (value.contains('news') || value.contains('article')) {
    return SearchItemType.news;
  }
  if (value.contains('post') || value.contains('community')) {
    return SearchItemType.post;
  }
  if (value.contains('unit') || value.contains('band')) {
    return SearchItemType.unit;
  }
  if (value.contains('project')) {
    return SearchItemType.project;
  }
  return SearchItemType.unknown;
}

String? _string(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value is String && value.isNotEmpty) return value;
  }
  return null;
}

DateTime? _dateTime(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value is String) {
      final parsed = DateTime.tryParse(value);
      if (parsed != null) return parsed;
    }
  }
  return null;
}
