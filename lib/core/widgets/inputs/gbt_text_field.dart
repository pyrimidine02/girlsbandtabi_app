/// EN: GBT Text Field component with validation support
/// KO: 유효성 검사를 지원하는 GBT 텍스트 필드 컴포넌트
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/gbt_colors.dart';
import '../../theme/gbt_spacing.dart';
import '../../theme/gbt_typography.dart';

/// EN: GBT Text Field widget
/// KO: GBT 텍스트 필드 위젯
class GBTTextField extends StatefulWidget {
  const GBTTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.helperText,
    this.errorText,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixTap,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.keyboardType,
    this.textInputAction,
    this.inputFormatters,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.focusNode,
    this.semanticLabel,
  });

  /// EN: Text editing controller
  /// KO: 텍스트 편집 컨트롤러
  final TextEditingController? controller;

  /// EN: Label text displayed above input
  /// KO: 입력 위에 표시되는 라벨 텍스트
  final String? label;

  /// EN: Hint text displayed when empty
  /// KO: 빈 상태일 때 표시되는 힌트 텍스트
  final String? hint;

  /// EN: Helper text displayed below input
  /// KO: 입력 아래에 표시되는 도움 텍스트
  final String? helperText;

  /// EN: Error text for validation
  /// KO: 유효성 검사용 오류 텍스트
  final String? errorText;

  /// EN: Icon displayed at start of input
  /// KO: 입력 시작에 표시되는 아이콘
  final IconData? prefixIcon;

  /// EN: Icon displayed at end of input
  /// KO: 입력 끝에 표시되는 아이콘
  final IconData? suffixIcon;

  /// EN: Callback when suffix icon is tapped
  /// KO: 접미 아이콘이 탭되었을 때 콜백
  final VoidCallback? onSuffixTap;

  /// EN: Whether to obscure text (for passwords)
  /// KO: 텍스트를 숨길지 여부 (비밀번호용)
  final bool obscureText;

  /// EN: Whether the field is enabled
  /// KO: 필드 활성화 여부
  final bool enabled;

  /// EN: Whether the field is read-only
  /// KO: 필드가 읽기 전용인지 여부
  final bool readOnly;

  /// EN: Whether to autofocus
  /// KO: 자동 포커스 여부
  final bool autofocus;

  /// EN: Maximum lines for multiline input
  /// KO: 여러 줄 입력을 위한 최대 줄 수
  final int maxLines;

  /// EN: Minimum lines for multiline input
  /// KO: 여러 줄 입력을 위한 최소 줄 수
  final int? minLines;

  /// EN: Maximum character length
  /// KO: 최대 문자 길이
  final int? maxLength;

  /// EN: Keyboard type
  /// KO: 키보드 타입
  final TextInputType? keyboardType;

  /// EN: Text input action
  /// KO: 텍스트 입력 액션
  final TextInputAction? textInputAction;

  /// EN: Input formatters
  /// KO: 입력 포매터
  final List<TextInputFormatter>? inputFormatters;

  /// EN: Validator function
  /// KO: 유효성 검사 함수
  final String? Function(String?)? validator;

  /// EN: Callback when text changes
  /// KO: 텍스트 변경 시 콜백
  final ValueChanged<String>? onChanged;

  /// EN: Callback when submitted
  /// KO: 제출 시 콜백
  final ValueChanged<String>? onSubmitted;

  /// EN: Callback when tapped
  /// KO: 탭 시 콜백
  final VoidCallback? onTap;

  /// EN: Focus node
  /// KO: 포커스 노드
  final FocusNode? focusNode;

  /// EN: Semantic label for accessibility
  /// KO: 접근성을 위한 시맨틱 라벨
  final String? semanticLabel;

  @override
  State<GBTTextField> createState() => _GBTTextFieldState();
}

class _GBTTextFieldState extends State<GBTTextField> {
  bool _isObscured = true;

  @override
  void initState() {
    super.initState();
    _isObscured = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    final hasError = widget.errorText != null;

    return Semantics(
      label: widget.semanticLabel ?? widget.label,
      textField: true,
      enabled: widget.enabled,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // EN: Label
          // KO: 라벨
          if (widget.label != null) ...[
            Text(
              widget.label!,
              style: GBTTypography.labelMedium.copyWith(
                color: hasError ? GBTColors.error : GBTColors.textSecondary,
              ),
            ),
            const SizedBox(height: GBTSpacing.xs),
          ],

          // EN: Text field
          // KO: 텍스트 필드
          TextFormField(
            controller: widget.controller,
            focusNode: widget.focusNode,
            obscureText: widget.obscureText && _isObscured,
            enabled: widget.enabled,
            readOnly: widget.readOnly,
            autofocus: widget.autofocus,
            maxLines: widget.obscureText ? 1 : widget.maxLines,
            minLines: widget.minLines,
            maxLength: widget.maxLength,
            keyboardType: widget.keyboardType,
            textInputAction: widget.textInputAction,
            inputFormatters: widget.inputFormatters,
            validator: widget.validator,
            onChanged: widget.onChanged,
            onFieldSubmitted: widget.onSubmitted,
            onTap: widget.onTap,
            style: GBTTypography.bodyMedium,
            decoration: InputDecoration(
              hintText: widget.hint,
              errorText: widget.errorText,
              prefixIcon: widget.prefixIcon != null
                  ? Icon(widget.prefixIcon, size: 20)
                  : null,
              suffixIcon: _buildSuffixIcon(),
            ),
          ),

          // EN: Helper text
          // KO: 도움 텍스트
          if (widget.helperText != null && !hasError) ...[
            const SizedBox(height: GBTSpacing.xs),
            Text(
              widget.helperText!,
              style: GBTTypography.bodySmall.copyWith(
                color: GBTColors.textTertiary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// EN: Build suffix icon widget
  /// KO: 접미 아이콘 위젯 빌드
  Widget? _buildSuffixIcon() {
    if (widget.obscureText) {
      return IconButton(
        icon: Icon(
          _isObscured ? Icons.visibility_off : Icons.visibility,
          size: 20,
        ),
        onPressed: () {
          setState(() => _isObscured = !_isObscured);
        },
      );
    }

    if (widget.suffixIcon != null) {
      return IconButton(
        icon: Icon(widget.suffixIcon, size: 20),
        onPressed: widget.onSuffixTap,
      );
    }

    return null;
  }
}

/// EN: Password text field with visibility toggle
/// KO: 가시성 토글이 있는 비밀번호 텍스트 필드
class GBTPasswordField extends StatelessWidget {
  const GBTPasswordField({
    super.key,
    this.controller,
    this.label = '비밀번호',
    this.hint = '비밀번호를 입력하세요',
    this.errorText,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.textInputAction,
  });

  final TextEditingController? controller;
  final String label;
  final String hint;
  final String? errorText;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final TextInputAction? textInputAction;

  @override
  Widget build(BuildContext context) {
    return GBTTextField(
      controller: controller,
      label: label,
      hint: hint,
      errorText: errorText,
      obscureText: true,
      prefixIcon: Icons.lock_outline,
      validator: validator,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      textInputAction: textInputAction,
      semanticLabel: label,
    );
  }
}

/// EN: Email text field with validation
/// KO: 유효성 검사가 있는 이메일 텍스트 필드
class GBTEmailField extends StatelessWidget {
  const GBTEmailField({
    super.key,
    this.controller,
    this.label = '이메일',
    this.hint = '이메일을 입력하세요',
    this.errorText,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.textInputAction,
  });

  final TextEditingController? controller;
  final String label;
  final String hint;
  final String? errorText;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final TextInputAction? textInputAction;

  @override
  Widget build(BuildContext context) {
    return GBTTextField(
      controller: controller,
      label: label,
      hint: hint,
      errorText: errorText,
      prefixIcon: Icons.email_outlined,
      keyboardType: TextInputType.emailAddress,
      validator: validator,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      textInputAction: textInputAction,
      semanticLabel: label,
    );
  }
}
