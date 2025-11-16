import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/content_filter_provider.dart';
import '../../services/admin_service.dart';

class AdminAnalyticsScreen extends ConsumerStatefulWidget {
  const AdminAnalyticsScreen({super.key});

  @override
  ConsumerState<AdminAnalyticsScreen> createState() => _AdminAnalyticsScreenState();
}

class _AdminAnalyticsScreenState extends ConsumerState<AdminAnalyticsScreen> {
  final _admin = AdminService();
  Map<String, dynamic>? _visitsByPlace;
  Map<String, dynamic>? _timeseries;
  bool _isLoading = false;
  String _interval = 'DAILY';
  String? _error;
  ProviderSubscription<String?>? _projectSub;

  @override
  void initState() {
    super.initState();
    _projectSub = ref.listenManual<String?>(selectedProjectProvider,
        (previous, next) {
      _load();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _projectSub?.close();
    super.dispose();
  }

  Future<void> _load() async {
    final project = ref.read(selectedProjectProvider);
    if (project == null || project.isEmpty) {
      setState(() {
        _visitsByPlace = null;
        _timeseries = null;
        _error = '프로젝트를 먼저 선택하세요.';
      });
      return;
    }
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final places = await _admin.getAnalyticsVisitsByPlace(
        filters: {
          'projectId': project,
          'page': 0,
          'size': 50,
        },
      );
      final series = await _admin.getAnalyticsVisitsTimeseries(
        filters: {
          'projectId': project,
          'interval': _interval,
        },
      );
      setState(() {
        _visitsByPlace = places;
        _timeseries = series;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final project = ref.watch(selectedProjectProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('방문 통계')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (project == null)
              const Padding(
                padding: EdgeInsets.all(12),
                child: Text('프로젝트를 먼저 선택하세요.'),
              ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  '오류: $_error',
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            if (project != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            '장소별 방문 집계',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const Spacer(),
                          IconButton(
                            onPressed: _isLoading ? null : _load,
                            icon: const Icon(Icons.refresh),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (_isLoading)
                        const Center(child: CircularProgressIndicator())
                      else if ((_visitsByPlace?['items'] as List?)?.isEmpty ?? true)
                        const Text('데이터가 없습니다.')
                      else
                        ...(_visitsByPlace!['items'] as List<dynamic>)
                            .whereType<Map<String, dynamic>>()
                            .map(
                          (item) {
                            final placeName = item['placeName']?.toString() ??
                                item['placeId']?.toString() ??
                                '알 수 없음';
                            final total = item['totalVisits']?.toString() ?? '-';
                            final unique = item['uniqueUsers']?.toString() ?? '-';
                            return ListTile(
                              leading: const Icon(Icons.place_outlined),
                              title: Text(placeName),
                              subtitle: Text('총 방문: $total • 유저: $unique'),
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 16),
            if (project != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            '방문 추세',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const Spacer(),
                          DropdownButton<String>(
                            value: _interval,
                            items: const [
                              DropdownMenuItem(value: 'DAILY', child: Text('일간')),
                              DropdownMenuItem(value: 'WEEKLY', child: Text('주간')),
                              DropdownMenuItem(value: 'MONTHLY', child: Text('월간')),
                            ],
                            onChanged: (value) {
                              if (value == null) return;
                              setState(() => _interval = value);
                              _load();
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (_isLoading)
                        const Center(child: CircularProgressIndicator())
                      else if ((_timeseries?['points'] as List?)?.isEmpty ?? true)
                        const Text('데이터가 없습니다.')
                      else
                        Column(
                          children: (_timeseries!['points'] as List<dynamic>)
                              .whereType<Map<String, dynamic>>()
                              .map(
                            (point) {
                              final bucket = point['bucket']?.toString() ?? '-';
                              final count = point['count']?.toString() ?? '0';
                              return ListTile(
                                leading: const Icon(Icons.timeline_outlined),
                                title: Text(bucket),
                                trailing: Text(count),
                              );
                            },
                          ).toList(),
                        ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
