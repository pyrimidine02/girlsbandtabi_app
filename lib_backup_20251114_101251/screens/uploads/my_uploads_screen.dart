import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/upload_model.dart';
import '../../providers/upload_provider.dart';
import '../../services/upload_service.dart';

class MyUploadsScreen extends ConsumerStatefulWidget {
  const MyUploadsScreen({super.key});

  @override
  ConsumerState<MyUploadsScreen> createState() => _MyUploadsScreenState();
}

class _MyUploadsScreenState extends ConsumerState<MyUploadsScreen> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final notifier = ref.read(uploadsProvider.notifier);
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.maxScrollExtent - position.pixels < 200) {
      notifier.loadMore();
    }
  }

  Future<void> _refresh() async {
    await ref.read(uploadsProvider.notifier).loadInitial();
  }

  void _openCreateBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => const _CreateUploadSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(uploadsProvider);
    final notifier = ref.read(uploadsProvider.notifier);
    return Scaffold(
      appBar: AppBar(
        title: const Text('내 업로드'),
        actions: [
          IconButton(
            tooltip: '새 업로드 요청',
            onPressed: _openCreateBottomSheet,
            icon: const Icon(Icons.cloud_upload_outlined),
          ),
        ],
      ),
      body: Builder(
        builder: (context) {
          if (state.isLoading && state.items.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.error != null && state.items.isEmpty) {
            return _ErrorView(
              message: state.error!,
              onRetry: () => notifier.loadInitial(),
            );
          }

          if (state.items.isEmpty) {
            return const _EmptyView();
          }

          final itemCount = state.items.length + (state.isLoadingMore ? 1 : 0);
          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.separated(
              controller: _scrollController,
              itemCount: itemCount,
              separatorBuilder: (_, __) => const Divider(height: 1),
              padding: const EdgeInsets.only(bottom: 24),
              itemBuilder: (context, index) {
                if (index >= state.items.length) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                final item = state.items[index];
                return _UploadListTile(item: item);
              },
            ),
          );
        },
      ),
    );
  }
}

class _UploadListTile extends ConsumerWidget {
  const _UploadListTile({required this.item});

  final UploadItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(uploadsProvider.notifier);
    final service = ref.read(uploadServiceProvider);

    Future<void> confirm() async {
      try {
        await service.confirmUpload(item.uploadId);
        // Re-fetch current page to reflect confirmed state.
        await notifier.loadInitial();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('업로드 ${item.uploadId} 확인되었습니다.')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('확인 실패: $e')));
        }
      }
    }

    Future<void> remove() async {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('업로드 삭제'),
          content: Text('업로드 ${item.uploadId} 를 삭제할까요?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('취소'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('삭제'),
            ),
          ],
        ),
      );
      if (confirm != true) return;

      try {
        await service.deleteUpload(item.uploadId);
        notifier.removeById(item.uploadId);
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('업로드 ${item.uploadId} 삭제됨')));
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('삭제 실패: $e')));
        }
      }
    }

    final theme = Theme.of(context);
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.12),
        foregroundColor: theme.colorScheme.primary,
        child: const Icon(Icons.insert_drive_file_outlined),
      ),
      title: Text(item.filename ?? item.uploadId),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (item.contentType != null)
            Text(item.contentType!, style: theme.textTheme.bodySmall),
          if (item.size != null)
            Text('${item.size} bytes', style: theme.textTheme.bodySmall),
          if (item.status != null)
            Text('상태: ${item.status}', style: theme.textTheme.bodySmall),
          if (item.createdAt != null)
            Text('요청: ${item.createdAt}', style: theme.textTheme.bodySmall),
          if (item.expiresAt != null)
            Text('만료: ${item.expiresAt}', style: theme.textTheme.bodySmall),
          if (item.url != null)
            SelectableText(
              item.url!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
        ],
      ),
      trailing: PopupMenuButton<_UploadMenuAction>(
        onSelected: (value) {
          switch (value) {
            case _UploadMenuAction.confirm:
              confirm();
              break;
            case _UploadMenuAction.delete:
              remove();
              break;
          }
        },
        itemBuilder: (context) => [
          if (!item.isConfirmed)
            const PopupMenuItem(
              value: _UploadMenuAction.confirm,
              child: Text('업로드 완료 처리'),
            ),
          const PopupMenuItem(
            value: _UploadMenuAction.delete,
            child: Text('삭제'),
          ),
        ],
      ),
      onTap: item.url == null
          ? null
          : () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(item.filename ?? item.uploadId),
                  content: SelectableText(item.url!),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('닫기'),
                    ),
                  ],
                ),
              );
            },
    );
  }
}

enum _UploadMenuAction { confirm, delete }

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('업로드를 불러오지 못했습니다.\n$message', textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: const Text('다시 시도')),
          ],
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.cloud_upload_outlined, size: 48),
            SizedBox(height: 12),
            Text(
              '업로드 요청이 없습니다.\n오른쪽 위 버튼으로 새 업로드를 요청하세요.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _CreateUploadSheet extends ConsumerStatefulWidget {
  const _CreateUploadSheet();

  @override
  ConsumerState<_CreateUploadSheet> createState() => _CreateUploadSheetState();
}

class _CreateUploadSheetState extends ConsumerState<_CreateUploadSheet> {
  final _formKey = GlobalKey<FormState>();
  final _filenameController = TextEditingController();
  final _contentTypeController = TextEditingController(text: 'image/jpeg');
  final _sizeController = TextEditingController(text: '5242880');

  PresignedUpload? _result;
  bool _isLoading = false;

  UploadService get _service => ref.read(uploadServiceProvider);

  Future<void> _requestPresigned() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final parsedSize = int.parse(_sizeController.text.trim());
      final result = await _service.getPresignedUrl(
        filename: _filenameController.text.trim(),
        contentType: _contentTypeController.text.trim(),
        size: parsedSize,
      );
      setState(() {
        _result = result;
      });
      // 최신 목록 다시 로드
      await ref.read(uploadsProvider.notifier).loadInitial();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('요청 실패: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _confirmUpload() async {
    if (_result == null) return;
    setState(() => _isLoading = true);
    try {
      await _service.confirmUpload(_result!.uploadId);
      await ref.read(uploadsProvider.notifier).loadInitial();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('업로드 ${_result!.uploadId} 확인되었습니다.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('확인 실패: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '새 업로드 요청',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _filenameController,
                    decoration: const InputDecoration(labelText: '파일명'),
                    validator: (value) =>
                        value == null || value.isEmpty ? '파일명을 입력하세요.' : null,
                  ),
                  TextFormField(
                    controller: _contentTypeController,
                    decoration: const InputDecoration(
                      labelText: 'Content-Type',
                    ),
                    validator: (value) => value == null || value.isEmpty
                        ? 'Content-Type을 입력하세요.'
                        : null,
                  ),
                  TextFormField(
                    controller: _sizeController,
                    decoration: const InputDecoration(
                      labelText: '파일 크기 (byte)',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) return '크기를 입력하세요.';
                      return int.tryParse(value) == null ? '숫자를 입력하세요.' : null;
                    },
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _isLoading ? null : _requestPresigned,
                      icon: const Icon(Icons.vpn_key_outlined),
                      label: Text(
                        _result == null ? 'Presigned URL 요청' : '다시 요청',
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (_result != null) ...[
              const SizedBox(height: 16),
              Text(
                '응답 내용',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              _KeyValueTile(label: 'Upload ID', value: _result!.uploadId),
              _KeyValueTile(
                label: 'Upload URL',
                value: _result!.url,
                selectable: true,
              ),
              if (_result!.expiresAt != null)
                _KeyValueTile(
                  label: '만료 시각',
                  value: _result!.expiresAt.toString(),
                ),
              ExpansionTile(
                title: const Text('Fields'),
                children: _result!.fields.entries
                    .map(
                      (e) => _KeyValueTile(
                        label: e.key,
                        value: e.value.toString(),
                        selectable: true,
                      ),
                    )
                    .toList(),
              ),
              if (_result!.headers != null)
                ExpansionTile(
                  title: const Text('Headers'),
                  children: _result!.headers!.entries
                      .map(
                        (e) => _KeyValueTile(
                          label: e.key,
                          value: e.value.toString(),
                          selectable: true,
                        ),
                      )
                      .toList(),
                ),
              const SizedBox(height: 12),
              Text(
                '1) 위 Presigned URL과 Fields를 사용해 객체 스토리지에 파일을 업로드하세요.\n'
                '2) 업로드가 완료되면 "업로드 완료 처리" 버튼을 눌러 서버에 반영합니다.',
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _isLoading ? null : _confirmUpload,
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('업로드 완료 처리'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _KeyValueTile extends StatelessWidget {
  const _KeyValueTile({
    required this.label,
    required this.value,
    this.selectable = false,
  });

  final String label;
  final String value;
  final bool selectable;

  @override
  Widget build(BuildContext context) {
    final text = selectable ? SelectableText(value) : Text(value);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: text),
        ],
      ),
    );
  }
}
