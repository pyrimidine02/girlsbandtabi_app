import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/admin_service.dart';

class AdminExportsScreen extends ConsumerStatefulWidget {
  const AdminExportsScreen({super.key});

  @override
  ConsumerState<AdminExportsScreen> createState() => _AdminExportsScreenState();
}

class _AdminExportsScreenState extends ConsumerState<AdminExportsScreen> {
  final _admin = AdminService();
  final _statusIdCtrl = TextEditingController();
  String _selectedType = 'uploads';
  bool _isWorking = false;
  String? _resultMessage;
  Map<String, dynamic>? _lastStatus;

  @override
  void dispose() {
    _statusIdCtrl.dispose();
    super.dispose();
  }

  Future<void> _createExport() async {
    setState(() {
      _isWorking = true;
      _resultMessage = null;
    });
    try {
      final res = await _admin.createExport({'type': _selectedType});
      setState(() {
        _isWorking = false;
        _resultMessage = '내보내기 생성됨: ${res['id'] ?? res}';
        if (res['id'] != null) {
          _statusIdCtrl.text = res['id'].toString();
        }
      });
    } catch (e) {
      setState(() {
        _isWorking = false;
        _resultMessage = '실패: $e';
      });
    }
  }

  Future<void> _fetchStatus() async {
    final id = _statusIdCtrl.text.trim();
    if (id.isEmpty) return;
    setState(() {
      _isWorking = true;
      _resultMessage = null;
    });
    try {
      final res = await _admin.getExport(id);
      setState(() {
        _isWorking = false;
        _lastStatus = res;
        _resultMessage = '상태 조회 완료';
      });
    } catch (e) {
      setState(() {
        _isWorking = false;
        _resultMessage = '상태 조회 실패: $e';
      });
    }
  }

  Future<void> _download() async {
    final id = _statusIdCtrl.text.trim();
    if (id.isEmpty) return;
    setState(() {
      _isWorking = true;
      _resultMessage = null;
    });
    try {
      final bytes = await _admin.downloadExport(id);
      setState(() {
        _isWorking = false;
        _resultMessage = '다운로드 완료 (${bytes.length} bytes)';
      });
    } catch (e) {
      setState(() {
        _isWorking = false;
        _resultMessage = '다운로드 실패: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('내보내기 관리')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '내보내기 생성',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 12),
                  DropdownButton<String>(
                    value: _selectedType,
                    items: const [
                      DropdownMenuItem(value: 'uploads', child: Text('업로드')),
                      DropdownMenuItem(value: 'audit_logs', child: Text('감사 로그')),
                      DropdownMenuItem(value: 'live_events', child: Text('라이브 이벤트')),
                      DropdownMenuItem(value: 'visit_events', child: Text('방문 이벤트')),
                    ],
                    onChanged: _isWorking
                        ? null
                        : (value) => setState(() => _selectedType = value ?? 'uploads'),
                  ),
                  const SizedBox(height: 8),
                  FilledButton(
                    onPressed: _isWorking ? null : _createExport,
                    child: const Text('생성'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '상태 조회 / 다운로드',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _statusIdCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Export ID',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      FilledButton(
                        onPressed: _isWorking ? null : _fetchStatus,
                        child: const Text('상태 조회'),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton(
                        onPressed: _isWorking ? null : _download,
                        child: const Text('다운로드'),
                      ),
                    ],
                  ),
                  if (_lastStatus != null) ...[
                    const SizedBox(height: 12),
                    Text('최근 상태:'),
                    Text(_lastStatus.toString()),
                  ],
                ],
              ),
            ),
          ),
          if (_resultMessage != null) ...[
            const SizedBox(height: 12),
            Text(_resultMessage!),
          ],
          if (_isWorking)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
