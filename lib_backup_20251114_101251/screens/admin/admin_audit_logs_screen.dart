import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/admin_service.dart';

class AdminAuditLogsScreen extends ConsumerStatefulWidget {
  const AdminAuditLogsScreen({super.key});

  @override
  ConsumerState<AdminAuditLogsScreen> createState() => _AdminAuditLogsScreenState();
}

class _AdminAuditLogsScreenState extends ConsumerState<AdminAuditLogsScreen> {
  final _admin = AdminService();
  final _eventCtrl = TextEditingController();
  final _actorCtrl = TextEditingController();
  bool _isLoading = false;
  String? _error;
  List<Map<String, dynamic>> _items = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _eventCtrl.dispose();
    _actorCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final res = await _admin.getAuditLogs(filters: {
        'page': 0,
        'size': 50,
        if (_eventCtrl.text.trim().isNotEmpty) 'eventType': _eventCtrl.text.trim(),
        if (_actorCtrl.text.trim().isNotEmpty) 'actorType': _actorCtrl.text.trim(),
      });
      final items = (res['items'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .toList();
      setState(() {
        _items = items;
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
    return Scaffold(
      appBar: AppBar(title: const Text('감사 로그')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _eventCtrl,
                    decoration: const InputDecoration(
                      labelText: '이벤트 타입',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _actorCtrl,
                    decoration: const InputDecoration(
                      labelText: '주체 타입',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: _load,
                  child: const Text('필터'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_error != null)
              Text('오류: $_error', style: const TextStyle(color: Colors.red)),
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_items.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text('로그가 없습니다.'),
              )
            else
              ..._items.map((log) {
                final type = log['eventType']?.toString() ?? '-';
                final actor = log['actor']?.toString() ?? '-';
                final target = log['target']?.toString() ?? '-';
                final created = log['createdAt']?.toString() ?? '-';
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.history),
                    title: Text(type),
                    subtitle: Text('Actor: $actor\nTarget: $target\nAt: $created'),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}
