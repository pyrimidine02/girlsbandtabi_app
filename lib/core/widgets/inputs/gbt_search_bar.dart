/// EN: GBT Search Bar component
/// KO: GBT 검색바 컴포넌트
library;

import 'package:flutter/material.dart';

import '../../theme/gbt_colors.dart';
import '../../theme/gbt_spacing.dart';
import '../../theme/gbt_typography.dart';

/// EN: GBT Search Bar widget
/// KO: GBT 검색바 위젯
class GBTSearchBar extends StatefulWidget {
  const GBTSearchBar({
    super.key,
    this.controller,
    this.hint = '검색',
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.onTap,
    this.autofocus = false,
    this.enabled = true,
    this.readOnly = false,
    this.focusNode,
    this.leading,
    this.trailing,
  });

  /// EN: Text editing controller
  /// KO: 텍스트 편집 컨트롤러
  final TextEditingController? controller;

  /// EN: Hint text
  /// KO: 힌트 텍스트
  final String hint;

  /// EN: Callback when text changes
  /// KO: 텍스트 변경 시 콜백
  final ValueChanged<String>? onChanged;

  /// EN: Callback when submitted
  /// KO: 제출 시 콜백
  final ValueChanged<String>? onSubmitted;

  /// EN: Callback when cleared
  /// KO: 지우기 시 콜백
  final VoidCallback? onClear;

  /// EN: Callback when tapped
  /// KO: 탭 시 콜백
  final VoidCallback? onTap;

  /// EN: Whether to autofocus
  /// KO: 자동 포커스 여부
  final bool autofocus;

  /// EN: Whether the search bar is enabled
  /// KO: 검색바 활성화 여부
  final bool enabled;

  /// EN: Whether the search bar is read-only
  /// KO: 검색바가 읽기 전용인지 여부
  final bool readOnly;

  /// EN: Focus node
  /// KO: 포커스 노드
  final FocusNode? focusNode;

  /// EN: Leading widget
  /// KO: 선행 위젯
  final Widget? leading;

  /// EN: Trailing widget
  /// KO: 후행 위젯
  final Widget? trailing;

  @override
  State<GBTSearchBar> createState() => _GBTSearchBarState();
}

class _GBTSearchBarState extends State<GBTSearchBar> {
  late TextEditingController _controller;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _hasText = _controller.text.isNotEmpty;
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    } else {
      _controller.removeListener(_onTextChanged);
    }
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = _controller.text.isNotEmpty;
    if (_hasText != hasText) {
      setState(() => _hasText = hasText);
    }
  }

  void _onClear() {
    _controller.clear();
    widget.onClear?.call();
    widget.onChanged?.call('');
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: widget.hint,
      textField: true,
      enabled: widget.enabled,
      child: Container(
        height: GBTSpacing.touchTarget,
        decoration: BoxDecoration(
          color: GBTColors.surfaceVariant,
          borderRadius: BorderRadius.circular(GBTSpacing.radiusFull),
        ),
        child: Row(
          children: [
            // EN: Leading icon or widget
            // KO: 선행 아이콘 또는 위젯
            Padding(
              padding: const EdgeInsets.only(left: GBTSpacing.md),
              child:
                  widget.leading ??
                  Icon(Icons.search, color: GBTColors.textTertiary, size: 20),
            ),

            // EN: Search input
            // KO: 검색 입력
            Expanded(
              child: TextField(
                controller: _controller,
                focusNode: widget.focusNode,
                autofocus: widget.autofocus,
                enabled: widget.enabled,
                readOnly: widget.readOnly,
                onChanged: widget.onChanged,
                onSubmitted: widget.onSubmitted,
                onTap: widget.onTap,
                style: GBTTypography.bodyMedium,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: widget.hint,
                  hintStyle: GBTTypography.bodyMedium.copyWith(
                    color: GBTColors.textTertiary,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: GBTSpacing.sm,
                  ),
                ),
              ),
            ),

            // EN: Clear button or trailing widget
            // KO: 지우기 버튼 또는 후행 위젯
            if (_hasText)
              IconButton(
                icon: Icon(
                  Icons.clear,
                  color: GBTColors.textTertiary,
                  size: 20,
                ),
                onPressed: _onClear,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
              )
            else if (widget.trailing != null)
              Padding(
                padding: const EdgeInsets.only(right: GBTSpacing.sm),
                child: widget.trailing,
              )
            else
              const SizedBox(width: GBTSpacing.md),
          ],
        ),
      ),
    );
  }
}

/// EN: Tappable search bar for navigation
/// KO: 네비게이션용 탭 가능한 검색바
class GBTSearchBarButton extends StatelessWidget {
  const GBTSearchBarButton({super.key, required this.onTap, this.hint = '검색'});

  final VoidCallback onTap;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: hint,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: GBTSpacing.touchTarget,
          padding: const EdgeInsets.symmetric(horizontal: GBTSpacing.md),
          decoration: BoxDecoration(
            color: GBTColors.surfaceVariant,
            borderRadius: BorderRadius.circular(GBTSpacing.radiusFull),
          ),
          child: Row(
            children: [
              Icon(Icons.search, color: GBTColors.textTertiary, size: 20),
              const SizedBox(width: GBTSpacing.sm),
              Text(
                hint,
                style: GBTTypography.bodyMedium.copyWith(
                  color: GBTColors.textTertiary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
