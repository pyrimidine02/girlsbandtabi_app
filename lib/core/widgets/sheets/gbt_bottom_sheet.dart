/// EN: GBT Bottom Sheet component
/// KO: GBT 바텀 시트 컴포넌트
library;

import 'package:flutter/material.dart';

import '../../theme/gbt_colors.dart';
import '../../theme/gbt_spacing.dart';
import '../../theme/gbt_typography.dart';

/// EN: Show a GBT styled modal bottom sheet
/// KO: GBT 스타일의 모달 바텀 시트 표시
Future<T?> showGBTBottomSheet<T>({
  required BuildContext context,
  required Widget child,
  String? title,
  bool isDismissible = true,
  bool enableDrag = true,
  bool isScrollControlled = false,
  double? maxHeight,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: isScrollControlled,
    isDismissible: isDismissible,
    enableDrag: enableDrag,
    backgroundColor: Colors.transparent,
    builder: (context) =>
        GBTBottomSheet(title: title, maxHeight: maxHeight, child: child),
  );
}

/// EN: GBT Bottom Sheet widget
/// KO: GBT 바텀 시트 위젯
class GBTBottomSheet extends StatelessWidget {
  const GBTBottomSheet({
    super.key,
    required this.child,
    this.title,
    this.maxHeight,
    this.onClose,
  });

  /// EN: Content of the bottom sheet
  /// KO: 바텀 시트의 콘텐츠
  final Widget child;

  /// EN: Optional title
  /// KO: 선택적 제목
  final String? title;

  /// EN: Maximum height of the sheet
  /// KO: 시트의 최대 높이
  final double? maxHeight;

  /// EN: Callback when close button is tapped
  /// KO: 닫기 버튼이 탭되었을 때 콜백
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    Widget content = Container(
      constraints: BoxConstraints(
        maxHeight: maxHeight ?? MediaQuery.of(context).size.height * 0.9,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(GBTSpacing.radiusLg),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // EN: Drag handle
          // KO: 드래그 핸들
          Container(
            margin: const EdgeInsets.only(top: GBTSpacing.sm),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: GBTColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // EN: Header
          // KO: 헤더
          if (title != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                GBTSpacing.md,
                GBTSpacing.md,
                GBTSpacing.sm,
                GBTSpacing.sm,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title!,
                      style: GBTTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: onClose ?? () => Navigator.of(context).pop(),
                    iconSize: 20,
                  ),
                ],
              ),
            ),

          // EN: Content
          // KO: 콘텐츠
          Flexible(child: child),
        ],
      ),
    );

    // EN: Add bottom padding for keyboard
    // KO: 키보드를 위한 하단 패딩 추가
    if (bottomPadding > 0) {
      content = Padding(
        padding: EdgeInsets.only(bottom: bottomPadding),
        child: content,
      );
    }

    return content;
  }
}

/// EN: GBT Action Sheet for showing a list of actions
/// KO: 액션 리스트를 표시하는 GBT 액션 시트
Future<T?> showGBTActionSheet<T>({
  required BuildContext context,
  required List<GBTActionSheetItem<T>> actions,
  String? title,
  String? cancelLabel,
}) {
  return showGBTBottomSheet<T>(
    context: context,
    title: title,
    child: SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ...actions.map((action) => _ActionItem<T>(action: action)),
          if (cancelLabel != null) ...[
            const Divider(height: 1),
            _CancelItem(label: cancelLabel),
          ],
        ],
      ),
    ),
  );
}

/// EN: Action sheet item data
/// KO: 액션 시트 아이템 데이터
class GBTActionSheetItem<T> {
  const GBTActionSheetItem({
    required this.label,
    this.icon,
    this.value,
    this.isDestructive = false,
    this.onTap,
  });

  final String label;
  final IconData? icon;
  final T? value;
  final bool isDestructive;
  final VoidCallback? onTap;
}

/// EN: Action item widget
/// KO: 액션 아이템 위젯
class _ActionItem<T> extends StatelessWidget {
  const _ActionItem({required this.action});

  final GBTActionSheetItem<T> action;

  @override
  Widget build(BuildContext context) {
    final color = action.isDestructive
        ? GBTColors.error
        : GBTColors.textPrimary;

    return ListTile(
      leading: action.icon != null ? Icon(action.icon, color: color) : null,
      title: Text(
        action.label,
        style: GBTTypography.bodyMedium.copyWith(color: color),
      ),
      onTap: () {
        action.onTap?.call();
        Navigator.of(context).pop(action.value);
      },
    );
  }
}

/// EN: Cancel item widget
/// KO: 취소 아이템 위젯
class _CancelItem extends StatelessWidget {
  const _CancelItem({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        label,
        style: GBTTypography.bodyMedium.copyWith(
          color: GBTColors.textSecondary,
        ),
        textAlign: TextAlign.center,
      ),
      onTap: () => Navigator.of(context).pop(),
    );
  }
}

/// EN: GBT Confirmation Sheet for showing confirmation dialog
/// KO: 확인 다이얼로그를 표시하는 GBT 확인 시트
Future<bool?> showGBTConfirmationSheet({
  required BuildContext context,
  required String title,
  required String message,
  String confirmLabel = '확인',
  String cancelLabel = '취소',
  bool isDestructive = false,
}) {
  return showGBTBottomSheet<bool>(
    context: context,
    child: SafeArea(
      child: Padding(
        padding: GBTSpacing.paddingPage,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: GBTSpacing.sm),
            Text(
              title,
              style: GBTTypography.titleMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: GBTSpacing.sm),
            Text(
              message,
              style: GBTTypography.bodyMedium.copyWith(
                color: GBTColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: GBTSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text(cancelLabel),
                  ),
                ),
                const SizedBox(width: GBTSpacing.md),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: isDestructive
                        ? ElevatedButton.styleFrom(
                            backgroundColor: GBTColors.error,
                          )
                        : null,
                    child: Text(confirmLabel),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
