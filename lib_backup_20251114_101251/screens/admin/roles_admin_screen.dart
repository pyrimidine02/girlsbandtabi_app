import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:girlsbandtabi_app/providers/project_role_provider.dart';

class RolesAdminScreen extends ConsumerStatefulWidget {
  const RolesAdminScreen({super.key});

  @override
  ConsumerState<RolesAdminScreen> createState() => _RolesAdminScreenState();
}

class _RolesAdminScreenState extends ConsumerState<RolesAdminScreen> {
  final _userIdCtrl = TextEditingController();
  String _role = 'MEMBER';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(projectRolesProvider.notifier).load();
    });
  }

  @override
  void dispose() {
    _userIdCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final rolesState = ref.watch(projectRolesProvider);
    final rolesNotifier = ref.read(projectRolesProvider.notifier);
    return Scaffold(
      appBar: AppBar(title: const Text('프로젝트 역할 관리')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '역할 부여/회수',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _userIdCtrl,
                    decoration: const InputDecoration(
                      labelText: '사용자 ID',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButton<String>(
                    value: _role,
                    items: const [
                      DropdownMenuItem(value: 'ADMIN', child: Text('ADMIN')),
                      DropdownMenuItem(
                        value: 'MODERATOR',
                        child: Text('MODERATOR'),
                      ),
                      DropdownMenuItem(value: 'MEMBER', child: Text('MEMBER')),
                    ],
                    onChanged: (v) => setState(() => _role = v ?? 'MEMBER'),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      FilledButton(
                        onPressed: () async {
                          if (_userIdCtrl.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('사용자 ID를 입력하세요.')),
                            );
                            return;
                          }
                          await rolesNotifier.grant(
                            userId: _userIdCtrl.text.trim(),
                            role: _role,
                          );
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('역할이 부여되었습니다.')),
                            );
                          }
                        },
                        child: const Text('부여'),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton(
                        onPressed: () async {
                          if (_userIdCtrl.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('사용자 ID를 입력하세요.')),
                            );
                            return;
                          }
                          await rolesNotifier.revoke(
                            userId: _userIdCtrl.text.trim(),
                            role: _role,
                          );
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('역할이 회수되었습니다.')),
                            );
                          }
                        },
                        child: const Text('회수'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('현재 역할 목록'),
                  const SizedBox(height: 8),
                  if (rolesState.isLoading)
                    const Center(child: CircularProgressIndicator())
                  else if (rolesState.error != null)
                    Center(child: Text('불러오기 실패: ${rolesState.error}'))
                  else if (rolesState.items.isEmpty)
                    const Text('역할 데이터가 없습니다.')
                  else
                    ...rolesState.items.map(
                      (role) => ListTile(
                        leading: const Icon(Icons.person_outline),
                        title: Text(role.userId),
                        subtitle: Text(role.role),
                        trailing: role.assignedAt == null
                            ? null
                            : Text(
                                role.assignedAt.toString(),
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
