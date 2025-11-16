import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/admin_service.dart';

class AdminUsersScreen extends ConsumerStatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  ConsumerState<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends ConsumerState<AdminUsersScreen> {
  final _admin = AdminService();
  bool _isLoading = false;
  String? _error;
  List<Map<String, dynamic>> _items = const [];
  final _queryCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _queryCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final res = await _admin.getAdminUsers(
        filters: {
          if (_queryCtrl.text.trim().isNotEmpty) 'q': _queryCtrl.text.trim(),
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

  Future<void> _updateRole(String userId, String role) async {
    await _admin.updateUserRole(userId: userId, role: role);
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('사용자 관리')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextField(
              controller: _queryCtrl,
              decoration: const InputDecoration(
                labelText: '검색어 (이메일/이름/ID)',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) => _load(),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: _load,
              child: const Text('검색'),
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
                child: Text('사용자가 없습니다.'),
              )
            else
              ..._items.map((item) {
                final userId = item['id']?.toString() ?? '';
                final email = item['email']?.toString() ?? '';
                final displayName = item['displayName']?.toString() ?? '';
                final role = item['role']?.toString() ?? 'USER';
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.person_outline),
                    title: Text(displayName.isEmpty ? email : displayName),
                    subtitle: Text('ID: $userId\n이메일: $email'),
                    trailing: DropdownButton<String>(
                      value: role,
                      items: const [
                        DropdownMenuItem(value: 'ADMIN', child: Text('ADMIN')),
                        DropdownMenuItem(value: 'USER', child: Text('USER')),
                      ],
                      onChanged: (value) {
                        if (value == null || value == role) return;
                        _updateRole(userId, value);
                      },
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}
