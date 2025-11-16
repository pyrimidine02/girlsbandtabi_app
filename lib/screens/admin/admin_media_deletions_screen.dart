import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/admin_service.dart';

class AdminMediaDeletionsScreen extends ConsumerStatefulWidget {
  const AdminMediaDeletionsScreen({super.key});

  @override
  ConsumerState<AdminMediaDeletionsScreen> createState() => _AdminMediaDeletionsScreenState();
}

class _AdminMediaDeletionsScreenState extends ConsumerState<AdminMediaDeletionsScreen> {
  final _admin = AdminService();
  String _statusFilter = 'PENDING';
  bool _isLoading = false;
  String? _error;
  List<Map<String, dynamic>> _items = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final res = await _admin.getMediaDeletionRequests(
        filters: {
          if (_statusFilter != 'ALL') 'status': _statusFilter,
          'page': 0,
          'size': 50,
        },
      );
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

  Future<void> _approve(String id) async {
    await _admin.approveMediaDeletion(id);
    await _load();
  }

  Future<void> _reject(String id) async {
    await _admin.rejectMediaDeletion(id);
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('미디어 삭제 요청')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                const Text('상태 필터:'),
                const SizedBox(width: 12),
                DropdownButton<String>(
                  value: _statusFilter,
                  items: const [
                    DropdownMenuItem(value: 'ALL', child: Text('전체')),
                    DropdownMenuItem(value: 'PENDING', child: Text('PENDING')),
                    DropdownMenuItem(value: 'APPROVED', child: Text('APPROVED')),
                    DropdownMenuItem(value: 'REJECTED', child: Text('REJECTED')),
                  ],
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => _statusFilter = value);
                    _load();
                  },
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
                child: Text('요청이 없습니다.'),
              )
            else
              ..._items.map((item) {
                final id = item['id']?.toString() ?? '';
                final status = item['status']?.toString() ?? 'UNKNOWN';
                final reason = item['reason']?.toString() ?? '-';
                final created = item['createdAt']?.toString() ?? '-';
                final filename = item['filename']?.toString() ?? '-';
                return Card(
                  child: ListTile(
                    title: Text(filename),
                    subtitle: Text('ID: $id\n상태: $status\n사유: $reason\n요청일: $created'),
                    trailing: status == 'PENDING'
                        ? Wrap(
                            spacing: 8,
                            children: [
                              OutlinedButton(
                                onPressed: () => _reject(id),
                                child: const Text('거부'),
                              ),
                              FilledButton(
                                onPressed: () => _approve(id),
                                child: const Text('승인'),
                              ),
                            ],
                          )
                        : Text(status),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}
