import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/admin_service.dart';

class AdminTokensScreen extends ConsumerStatefulWidget {
  const AdminTokensScreen({super.key});

  @override
  ConsumerState<AdminTokensScreen> createState() => _AdminTokensScreenState();
}

class _AdminTokensScreenState extends ConsumerState<AdminTokensScreen> {
  final _admin = AdminService();
  final _jtiController = TextEditingController();
  String? _message;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _jtiController.dispose();
    super.dispose();
  }

  Future<void> _revoke() async {
    final jti = _jtiController.text.trim();
    if (jti.isEmpty) {
      setState(() => _message = 'JTI를 입력하세요.');
      return;
    }
    setState(() {
      _isSubmitting = true;
      _message = null;
    });
    try {
      await _admin.revokeToken(jti);
      setState(() {
        _isSubmitting = false;
        _message = '토큰이 폐기되었습니다.';
      });
    } catch (e) {
      setState(() {
        _isSubmitting = false;
        _message = '실패: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('토큰 폐기')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Refresh Token JTI를 입력하면 해당 토큰을 폐기합니다.'),
            const SizedBox(height: 12),
            TextField(
              controller: _jtiController,
              decoration: const InputDecoration(
                labelText: 'JTI',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: _isSubmitting ? null : _revoke,
              child: const Text('폐기'),
            ),
            if (_message != null) ...[
              const SizedBox(height: 12),
              Text(_message!),
            ],
            if (_isSubmitting)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }
}
