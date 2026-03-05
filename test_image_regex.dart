import 'dart:core';

void main() {
  final content = '''
이것은 테스트 게시글입니다.
방향제

![](https://abc.cloudfront.net/test.jpg)
''';

  final urls = extractImageUrls(content);
  print('Extracted: $urls');
}

List<String> extractImageUrls(String? content) {
  if (content == null || content.isEmpty) return const [];
  final urls = <String>{};

  final markdownImagePattern = RegExp(r'!\[[^\]]*\]\((https?://[^)\s]+)[^)]*\)');
  final mdMatches = markdownImagePattern.allMatches(content);
  for (final match in mdMatches) {
    final url = match.group(1);
    if (url != null && url.isNotEmpty) {
      urls.add(url);
    }
  }

  return urls.toList();
}
