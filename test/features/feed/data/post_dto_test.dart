import 'package:flutter_test/flutter_test.dart';

import 'package:girlsbandtabi_app/features/feed/data/dto/post_dto.dart';

void main() {
  test('PostSummaryDto parses swagger keys', () {
    final json = {
      'id': 'post-1',
      'projectId': 'proj-1',
      'authorId': 'user-1',
      'title': '커뮤니티 글 제목',
      'createdAt': '2026-01-28T03:00:00Z',
    };

    final dto = PostSummaryDto.fromJson(json);
    expect(dto.id, 'post-1');
    expect(dto.projectId, 'proj-1');
    expect(dto.authorId, 'user-1');
    expect(dto.title, '커뮤니티 글 제목');
    expect(dto.createdAt, isNotNull);
  });

  test('PostDetailDto parses swagger keys', () {
    final json = {
      'id': 'post-2',
      'projectId': 'proj-2',
      'authorId': 'user-2',
      'title': '상세 글 제목',
      'content': '상세 글 내용',
      'createdAt': '2026-01-28T05:00:00Z',
      'updatedAt': '2026-01-28T06:00:00Z',
    };

    final dto = PostDetailDto.fromJson(json);
    expect(dto.id, 'post-2');
    expect(dto.projectId, 'proj-2');
    expect(dto.authorId, 'user-2');
    expect(dto.title, '상세 글 제목');
    expect(dto.content, '상세 글 내용');
    expect(dto.updatedAt, isNotNull);
  });
}
