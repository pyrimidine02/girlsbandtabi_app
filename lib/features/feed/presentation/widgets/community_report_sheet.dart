/// EN: Reusable report sheet for community moderation flows.
/// KO: 커뮤니티 모더레이션 흐름에서 재사용하는 신고 시트입니다.
library;

import 'package:flutter/material.dart';

import '../../../../core/theme/gbt_spacing.dart';
import '../../../../core/theme/gbt_typography.dart';
import '../../domain/entities/community_moderation.dart';

class CommunityReportPayload {
  const CommunityReportPayload({required this.reason, this.description});

  final CommunityReportReason reason;
  final String? description;
}

class CommunityReportSheet extends StatefulWidget {
  const CommunityReportSheet({super.key});

  @override
  State<CommunityReportSheet> createState() => _CommunityReportSheetState();
}

class _CommunityReportSheetState extends State<CommunityReportSheet> {
  late CommunityReportReason _selectedReason;
  final TextEditingController _descriptionController = TextEditingController();

  void _dismissKeyboard() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  @override
  void initState() {
    super.initState();
    _selectedReason = CommunityReportReason.spam;
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _dismissKeyboard,
      child: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.fromLTRB(
            GBTSpacing.md,
            GBTSpacing.md,
            GBTSpacing.md,
            bottomInset + GBTSpacing.md,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('신고하기', style: GBTTypography.titleSmall),
              const SizedBox(height: GBTSpacing.md),
              RadioGroup<CommunityReportReason>(
                groupValue: _selectedReason,
                onChanged: (value) {
                  if (value == null) return;
                  setState(() => _selectedReason = value);
                },
                child: Column(
                  children: CommunityReportReason.values
                      .map(
                        (reason) => RadioListTile<CommunityReportReason>(
                          value: reason,
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                          title: Text(reason.label),
                        ),
                      )
                      .toList(),
                ),
              ),
              const SizedBox(height: GBTSpacing.md),
              TextField(
                controller: _descriptionController,
                maxLines: 3,
                textInputAction: TextInputAction.done,
                onTapOutside: (_) => _dismissKeyboard(),
                onSubmitted: (_) => _dismissKeyboard(),
                decoration: const InputDecoration(
                  labelText: '추가 설명',
                  hintText: '필요한 설명을 남겨주세요 (선택)',
                ),
              ),
              const SizedBox(height: GBTSpacing.lg),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    final description = _descriptionController.text.trim();
                    Navigator.of(context).pop(
                      CommunityReportPayload(
                        reason: _selectedReason,
                        description: description.isEmpty ? null : description,
                      ),
                    );
                  },
                  child: const Text('신고 접수'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
