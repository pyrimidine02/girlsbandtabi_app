import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/notification_service.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  final _svc = NotificationService();
  Future<List<Map<String, dynamic>>>? _future;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    setState(() => _future = _svc.getNotifications(page: 0, size: 50));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('알림')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final items = snap.data ?? const <Map<String, dynamic>>[];
          if (items.isEmpty) return const Center(child: Text('데이터가 없습니다.'));
          return RefreshIndicator(
            onRefresh: () async => _reload(),
            child: ListView.separated(
              itemCount: items.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final n = items[i];
                final read = n['read'] == true;
                return ListTile(
                  leading: Icon(read ? Icons.mark_email_read_outlined : Icons.mark_email_unread_outlined),
                  title: Text(n['title']?.toString() ?? ''),
                  subtitle: Text(n['body']?.toString() ?? ''),
                  trailing: read
                      ? null
                      : TextButton(
                          onPressed: () async {
                            await _svc.markRead(n['id'].toString());
                            _reload();
                          },
                          child: const Text('읽음'),
                        ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

