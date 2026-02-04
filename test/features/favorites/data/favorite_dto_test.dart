import 'package:flutter_test/flutter_test.dart';

import 'package:girlsbandtabi_app/features/favorites/data/dto/favorite_dto.dart';

void main() {
  test('FavoriteItemDto parses swagger keys', () {
    final json = {
      'entityId': 'place-1',
      'entityType': 'PLACE',
      'title': '도쿄돔',
      'thumbnailUrl': 'https://example.com/place.png',
    };

    final dto = FavoriteItemDto.fromJson(json);
    expect(dto.entityId, 'place-1');
    expect(dto.entityType, 'PLACE');
    expect(dto.title, '도쿄돔');
    expect(dto.thumbnailUrl, 'https://example.com/place.png');
  });
}
