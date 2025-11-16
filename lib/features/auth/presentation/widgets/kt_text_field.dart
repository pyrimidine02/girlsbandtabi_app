import 'package:flutter/material.dart';

import '../../../../core/theme/kt_colors.dart';
import '../../../../core/theme/kt_spacing.dart';
import '../../../../core/theme/kt_typography.dart';

/// EN: KT UXD design system text field widget
/// KO: KT UXD 디자인 시스템 텍스트 필드 위젯
class KTTextField extends StatefulWidget {
  /// EN: Creates a KT UXD text field
  /// KO: KT UXD 텍스트 필드 생성
  const KTTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.helperText,
    this.errorText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.autofocus = false,
    this.validator,
    this.onChanged,
    this.onFieldSubmitted,
    this.onTap,
    this.focusNode,
    this.fillColor,
    this.borderRadius,
  });

  /// EN: Text editing controller
  /// KO: 텍스트 편집 컨트롤러
  final TextEditingController? controller;

  /// EN: Field label text
  /// KO: 필드 라벨 텍스트
  final String? label;

  /// EN: Placeholder hint text
  /// KO: 자리 표시자 힌트 텍스트
  final String? hint;

  /// EN: Helper text below field
  /// KO: 필드 아래 도움말 텍스트
  final String? helperText;

  /// EN: Error text to display
  /// KO: 표시할 오류 텍스트
  final String? errorText;

  /// EN: Prefix icon
  /// KO: 접두사 아이콘
  final IconData? prefixIcon;

  /// EN: Suffix widget (usually icon or button)
  /// KO: 접미사 위젯 (보통 아이콘이나 버튼)
  final Widget? suffixIcon;

  /// EN: Whether to obscure text (for passwords)
  /// KO: 텍스트 숨김 여부 (비밀번호용)
  final bool obscureText;

  /// EN: Whether the field is enabled
  /// KO: 필드 활성화 여부
  final bool enabled;

  /// EN: Whether the field is read-only
  /// KO: 필드 읽기 전용 여부
  final bool readOnly;

  /// EN: Maximum number of lines
  /// KO: 최대 라인 수
  final int? maxLines;

  /// EN: Minimum number of lines
  /// KO: 최소 라인 수
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

  /// EN: Text capitalization
  /// KO: 텍스트 대소문자 변환
  final TextCapitalization textCapitalization;

  /// EN: Whether to autofocus
  /// KO: 자동 포커스 여부
  final bool autofocus;

  /// EN: Validation function
  /// KO: 검증 함수
  final String? Function(String?)? validator;

  /// EN: Callback when text changes
  /// KO: 텍스트 변경 시 콜백
  final void Function(String)? onChanged;

  /// EN: Callback when field is submitted
  /// KO: 필드 제출 시 콜백
  final void Function(String)? onFieldSubmitted;

  /// EN: Callback when field is tapped
  /// KO: 필드 탭 시 콜백
  final void Function()? onTap;

  /// EN: Focus node for controlling focus
  /// KO: 포커스 제어용 포커스 노드
  final FocusNode? focusNode;

  /// EN: Custom fill color
  /// KO: 사용자 정의 채움 색상
  final Color? fillColor;

  /// EN: Custom border radius
  /// KO: 사용자 정의 경계 반지름
  final BorderRadius? borderRadius;

  @override
  State<KTTextField> createState() => _KTTextFieldState();
}

class _KTTextFieldState extends State<KTTextField> {
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasError = widget.errorText != null;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: KTTypography.labelMedium.copyWith(
              color: hasError 
                  ? KTColors.error
                  : _isFocused 
                      ? KTColors.primaryText 
                      : KTColors.secondaryText,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: KTSpacing.xs),
        ],
        TextFormField(
          controller: widget.controller,
          focusNode: _focusNode,
          obscureText: widget.obscureText,
          enabled: widget.enabled,
          readOnly: widget.readOnly,
          maxLines: widget.maxLines,
          minLines: widget.minLines,
          maxLength: widget.maxLength,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          textCapitalization: widget.textCapitalization,
          autofocus: widget.autofocus,
          validator: widget.validator,
          onChanged: widget.onChanged,
          onFieldSubmitted: widget.onFieldSubmitted,
          onTap: widget.onTap,
          style: KTTypography.bodyMedium.copyWith(
            color: widget.enabled ? KTColors.primaryText : KTColors.secondaryText,
          ),
          decoration: _buildInputDecoration(hasError),
        ),
        if (widget.helperText != null || hasError) ...[
          const SizedBox(height: KTSpacing.xs),
          Text(
            widget.errorText ?? widget.helperText ?? '',
            style: KTTypography.labelSmall.copyWith(
              color: hasError ? KTColors.error : KTColors.secondaryText,
            ),
          ),
        ],
      ],
    );
  }

  /// EN: Build input decoration following KT UXD design
  /// KO: KT UXD 디자인을 따르는 입력 장식 구성
  InputDecoration _buildInputDecoration(bool hasError) {
    final borderRadius = widget.borderRadius ?? 
                       BorderRadius.circular(KTSpacing.borderRadiusSmall);
    
    final fillColor = widget.fillColor ?? 
                     (widget.enabled ? KTColors.inputFill : KTColors.surfaceAlternate);

    return InputDecoration(
      hintText: widget.hint,
      hintStyle: KTTypography.bodyMedium.copyWith(
        color: KTColors.placeholder,
      ),
      
      // EN: Prefix icon styling
      // KO: 접두사 아이콘 스타일링
      prefixIcon: widget.prefixIcon != null
          ? Icon(
              widget.prefixIcon,
              color: hasError 
                  ? KTColors.error
                  : _isFocused 
                      ? KTColors.primaryText 
                      : KTColors.secondaryText,
              size: 20,
            )
          : null,
      
      // EN: Suffix icon styling
      // KO: 접미사 아이콘 스타일링
      suffixIcon: widget.suffixIcon,
      
      // EN: Fill and background
      // KO: 채움 및 배경
      filled: true,
      fillColor: fillColor,
      
      // EN: Content padding
      // KO: 콘텐츠 패딩
      contentPadding: const EdgeInsets.symmetric(
        horizontal: KTSpacing.md,
        vertical: KTSpacing.md,
      ),
      
      // EN: Border styling
      // KO: 경계선 스타일링
      border: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: const BorderSide(
          color: KTColors.inputBorder,
          width: 1,
        ),
      ),
      
      enabledBorder: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: const BorderSide(
          color: KTColors.inputBorder,
          width: 1,
        ),
      ),
      
      focusedBorder: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: const BorderSide(
          color: KTColors.inputBorderFocused,
          width: 2,
        ),
      ),
      
      errorBorder: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: const BorderSide(
          color: KTColors.inputBorderError,
          width: 1,
        ),
      ),
      
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: const BorderSide(
          color: KTColors.inputBorderError,
          width: 2,
        ),
      ),
      
      disabledBorder: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: BorderSide(
          color: KTColors.borderColorLight,
          width: 1,
        ),
      ),
      
      // EN: Remove default error text (we handle it manually)
      // KO: 기본 오류 텍스트 제거 (수동으로 처리)
      errorStyle: const TextStyle(height: 0),
    );
  }
}