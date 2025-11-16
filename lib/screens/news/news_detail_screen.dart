import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/news_service.dart';
import '../../models/news_model.dart';
import '../../providers/content_filter_provider.dart';
import '../../core/constants/api_constants.dart';

class NewsDetailScreen extends ConsumerStatefulWidget {
  final String newsId;
  const NewsDetailScreen({super.key, required this.newsId});

  @override
  ConsumerState<NewsDetailScreen> createState() => _NewsDetailScreenState();
}

class _NewsDetailScreenState extends ConsumerState<NewsDetailScreen> {
  final _svc = NewsService();
  Future<News>? _future;
  late String _currentProjectId;

  @override
  void initState() {
    super.initState();
    final initialProject =
        ref.read(selectedProjectProvider) ?? ApiConstants.defaultProjectId;
    _currentProjectId = initialProject;
    _future = _svc.getNewsDetail(
      projectCode: _currentProjectId,
      newsId: widget.newsId,
    );
    ref.listen<String?>(selectedProjectProvider, (previous, next) {
      final target = next ?? ApiConstants.defaultProjectId;
      if (target == _currentProjectId) return;
      setState(() {
        _currentProjectId = target;
        _future = _svc.getNewsDetail(
          projectCode: _currentProjectId,
          newsId: widget.newsId,
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('뉴스 상세')),
      body: FutureBuilder<News>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return _DetailErrorView(
              message: '뉴스를 불러올 수 없습니다.',
              onRetry: () {
                setState(() {
                  _future = _svc.getNewsDetail(
                    projectCode: _currentProjectId,
                    newsId: widget.newsId,
                  );
                });
              },
            );
          }
          final n = snap.data;
          if (n == null) return const Center(child: Text('데이터가 없습니다.'));
          return Padding(
            padding: const EdgeInsets.all(16),
            child: ListView(
              children: [
                Text(n.title, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                Text(n.publishedAt?.toIso8601String().substring(0, 10) ?? '', style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 16),
                Text(n.body ?? '', style: Theme.of(context).textTheme.bodyLarge),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _DetailErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _DetailErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton(onPressed: onRetry, child: const Text('다시 시도')),
          ],
        ),
      ),
    );
  }
}
