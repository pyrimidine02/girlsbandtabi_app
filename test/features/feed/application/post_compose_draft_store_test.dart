import 'package:flutter_test/flutter_test.dart';
import 'package:girlsbandtabi_app/features/feed/application/post_compose_draft_store.dart';

void main() {
  group('PostComposeDraft', () {
    test('fromJson restores valid payload', () {
      final draft = PostComposeDraft.fromJson({
        'title': '제목',
        'content': '내용',
        'imagePaths': ['/tmp/a.jpg', '/tmp/b.webp'],
        'savedAt': '2026-03-05T15:40:00.000Z',
        'projectCode': 'girls-band-cry',
      });

      expect(draft, isNotNull);
      expect(draft!.title, '제목');
      expect(draft.content, '내용');
      expect(draft.imagePaths, ['/tmp/a.jpg', '/tmp/b.webp']);
      expect(draft.projectCode, 'girls-band-cry');
      expect(draft.isEmpty, isFalse);
    });

    test('fromJson returns null when savedAt is invalid', () {
      final draft = PostComposeDraft.fromJson({
        'title': '제목',
        'content': '내용',
        'imagePaths': ['/tmp/a.jpg'],
        'savedAt': 'invalid-datetime',
      });

      expect(draft, isNull);
    });

    test('toJson keeps fields needed for roundtrip', () {
      final original = PostComposeDraft(
        title: '제목',
        content: '내용',
        imagePaths: const ['/tmp/a.jpg'],
        savedAt: DateTime.parse('2026-03-05T15:40:00.000Z'),
        projectCode: 'girls-band-cry',
      );

      final restored = PostComposeDraft.fromJson(original.toJson());

      expect(restored, isNotNull);
      expect(restored!.title, original.title);
      expect(restored.content, original.content);
      expect(restored.imagePaths, original.imagePaths);
      expect(restored.projectCode, original.projectCode);
      expect(
        restored.savedAt.toUtc().toIso8601String(),
        original.savedAt.toUtc().toIso8601String(),
      );
    });
  });
}
