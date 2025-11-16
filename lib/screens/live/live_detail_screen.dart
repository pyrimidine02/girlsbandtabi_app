import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/live_event_service.dart';
import '../../models/live_event_model.dart';
import '../../providers/content_filter_provider.dart';
import 'package:geolocator/geolocator.dart';
import '../../core/constants/api_constants.dart';
import '../../services/verification_service.dart';

class LiveDetailScreen extends ConsumerStatefulWidget {
  final String liveEventId;
  const LiveDetailScreen({super.key, required this.liveEventId});

  @override
  ConsumerState<LiveDetailScreen> createState() => _LiveDetailScreenState();
}

class _LiveDetailScreenState extends ConsumerState<LiveDetailScreen> {
  final _svc = LiveEventService();
  Future<LiveEvent>? _future;
  late String _currentProjectId;

  @override
  void initState() {
    super.initState();
    final initialProject =
        ref.read(selectedProjectProvider) ?? ApiConstants.defaultProjectId;
    _currentProjectId = initialProject;
    _future = _svc.getLiveEventDetail(
      projectId: _currentProjectId,
      eventId: widget.liveEventId,
    );
    ref.listen<String?>(selectedProjectProvider, (previous, next) {
      final target = next ?? ApiConstants.defaultProjectId;
      if (target == _currentProjectId) return;
      setState(() {
        _currentProjectId = target;
        _future = _svc.getLiveEventDetail(
          projectId: _currentProjectId,
          eventId: widget.liveEventId,
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('라이브 상세')),
      body: FutureBuilder<LiveEvent>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return _DetailErrorView(
              message: '라이브 정보를 불러올 수 없습니다.',
              onRetry: () {
                setState(() {
                  _future = _svc.getLiveEventDetail(
                    projectId: _currentProjectId,
                    eventId: widget.liveEventId,
                  );
                });
              },
            );
          }
          final e = snap.data;
          if (e == null) return const Center(child: Text('데이터가 없습니다.'));
          return Padding(
            padding: const EdgeInsets.all(16),
            child: ListView(
              children: [
                Text(e.title, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                Text(e.startTime.toIso8601String().substring(0, 16), style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 16),
                Text(e.description ?? '', style: Theme.of(context).textTheme.bodyLarge),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () async {
                    try {
                      final perm = await Geolocator.requestPermission();
                      if (perm == LocationPermission.deniedForever || perm == LocationPermission.denied) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('위치 권한이 필요합니다.')));
                        return;
                      }
                      final pos = await Geolocator.getCurrentPosition();
                      final token = await VerificationService().buildLocationToken(
                        lat: pos.latitude,
                        lon: pos.longitude,
                        accuracyM: pos.accuracy,
                        altitude: pos.altitude,
                        heading: pos.heading,
                        speed: pos.speed,
                        eventId: e.id,
                      );
                      final res = await LiveEventService().verifyLiveEvent(
                        projectId: _currentProjectId,
                        eventId: e.id,
                        token: token,
                      );
                      if (!context.mounted) return;
                      final ok = res.result == 'RECORDED';
                      final message = ok ? '라이브 인증 기록됨' : (res.message ?? '인증 실패');
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
                    } catch (e) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('인증 실패: ${e.toString()}')),
                      );
                    }
                  },
                  child: const Text('이 라이브 인증하기'),
                ),
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
