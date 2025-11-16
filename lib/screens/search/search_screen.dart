import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../services/search_service.dart';
import '../../providers/content_filter_provider.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _svc = SearchService();
  final _ctrl = TextEditingController();
  Future<Map<String, dynamic>>? _future;

  void _doSearch() {
    final q = _ctrl.text.trim();
    if (q.isEmpty) return;
    final project = ref.read(selectedProjectProvider);
    final unit = ref.read(selectedBandProvider);
    setState(() {
      _future = _svc.search(q: q, projectId: project, unitIds: unit != null ? [unit] : null, types: const ['places','news','live','units']);
    });
  }

  String _displayType(String raw) {
    switch (raw) {
      case 'places':
        return '성지';
      case 'news':
        return '뉴스';
      case 'live':
        return '라이브';
      case 'units':
        return '유닛';
      default:
        return raw.toUpperCase();
    }
  }

  String? _subtitleFor(Map<String, dynamic> item, String type) {
    switch (type) {
      case 'places':
        return item['description']?.toString() ?? item['address']?.toString();
      case 'news':
        return item['summary']?.toString() ?? item['excerpt']?.toString();
      case 'live':
        final start = item['startTime'] ?? item['startAt'];
        if (start is String) return start;
        return null;
      case 'units':
        return item['displayName']?.toString();
      default:
        return null;
    }
  }

  void _openResult(BuildContext context, String type, Map<String, dynamic> item) {
    final id = item['id']?.toString();
    switch (type) {
      case 'places':
        if (id != null) {
          context.push('/places/$id');
        }
        return;
      case 'news':
        if (id != null) {
          context.push('/news/$id');
        }
        return;
      case 'live':
        if (id != null) {
          context.push('/live/$id');
        }
        return;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('아직 열 수 없는 결과입니다.')),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('검색')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _ctrl,
                    decoration: const InputDecoration(
                      hintText: '성지, 라이브, 뉴스, 유닛 검색',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.search),
                    ),
                    onSubmitted: (_) => _doSearch(),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(onPressed: _doSearch, child: const Text('검색')),
              ],
            ),
          ),
          Expanded(
            child: _future == null
                ? const Center(child: Text('검색어를 입력하세요.'))
                : FutureBuilder(
                    future: _future,
                    builder: (context, snap) {
                      if (snap.connectionState != ConnectionState.done) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snap.hasError) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '검색 중 오류가 발생했습니다.\n${snap.error}',
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 12),
                                FilledButton(
                                  onPressed: _doSearch,
                                  child: const Text('다시 시도'),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                      final raw = snap.data;
                      final data =
                          raw is Map<String, dynamic> ? raw : <String, dynamic>{};
                      final items =
                          (data['items'] as List<dynamic>? ?? const <dynamic>[]);
                      if (items.isEmpty) {
                        return const Center(child: Text('검색 결과가 없습니다.'));
                      }
                      return ListView.separated(
                        itemCount: items.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, i) {
                          final it = items[i] as Map<String, dynamic>;
                          final type = it['type']?.toString() ?? '';
                          final item = it['item'] as Map<String, dynamic>? ?? {};
                          final title = item['title']?.toString() ?? item['name']?.toString() ?? item['displayName']?.toString() ?? '';
                          final subtitle = _subtitleFor(item, type) ??
                              _displayType(type);
                          return ListTile(
                            leading: Icon(_iconForType(type)),
                            title: Text(title),
                            subtitle: Text(subtitle),
                            trailing:
                                const Icon(Icons.chevron_right_rounded, color: Colors.grey),
                            onTap: () => _openResult(context, type, item),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  IconData _iconForType(String t) {
    switch (t) {
      case 'places':
        return Icons.place_outlined;
      case 'news':
        return Icons.article_outlined;
      case 'live':
        return Icons.music_note_outlined;
      case 'units':
        return Icons.group_outlined;
      default:
        return Icons.search;
    }
  }
}
