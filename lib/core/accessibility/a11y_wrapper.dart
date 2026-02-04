/// EN: Accessibility wrapper and utilities
/// KO: 접근성 래퍼 및 유틸리티
library;

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

/// EN: Wrapper widget for enhanced accessibility support
/// KO: 향상된 접근성 지원을 위한 래퍼 위젯
class A11yWrapper extends StatelessWidget {
  const A11yWrapper({
    super.key,
    required this.child,
    required this.label,
    this.hint,
    this.isButton = false,
    this.isLink = false,
    this.isHeader = false,
    this.isImage = false,
    this.isLiveRegion = false,
    this.excludeSemantics = false,
    this.onTap,
    this.onLongPress,
  });

  /// EN: Child widget
  /// KO: 자식 위젯
  final Widget child;

  /// EN: Semantic label for screen readers
  /// KO: 스크린 리더용 시맨틱 라벨
  final String label;

  /// EN: Additional hint text
  /// KO: 추가 힌트 텍스트
  final String? hint;

  /// EN: Whether this represents a button
  /// KO: 버튼을 나타내는지 여부
  final bool isButton;

  /// EN: Whether this represents a link
  /// KO: 링크를 나타내는지 여부
  final bool isLink;

  /// EN: Whether this is a header
  /// KO: 헤더인지 여부
  final bool isHeader;

  /// EN: Whether this is an image
  /// KO: 이미지인지 여부
  final bool isImage;

  /// EN: Whether this is a live region (dynamic content)
  /// KO: 라이브 영역(동적 콘텐츠)인지 여부
  final bool isLiveRegion;

  /// EN: Whether to exclude child semantics
  /// KO: 자식 시맨틱스를 제외할지 여부
  final bool excludeSemantics;

  /// EN: Tap callback for accessibility actions
  /// KO: 접근성 액션을 위한 탭 콜백
  final VoidCallback? onTap;

  /// EN: Long press callback for accessibility actions
  /// KO: 접근성 액션을 위한 길게 누르기 콜백
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      hint: hint,
      button: isButton,
      link: isLink,
      header: isHeader,
      image: isImage,
      liveRegion: isLiveRegion,
      excludeSemantics: excludeSemantics,
      onTap: onTap,
      onLongPress: onLongPress,
      child: child,
    );
  }
}

/// EN: Semantic heading wrapper for proper heading hierarchy
/// KO: 적절한 제목 계층을 위한 시맨틱 헤딩 래퍼
class A11yHeading extends StatelessWidget {
  const A11yHeading({super.key, required this.child, required this.level});

  final Widget child;

  /// EN: Heading level (1-6)
  /// KO: 제목 레벨 (1-6)
  final int level;

  @override
  Widget build(BuildContext context) {
    return Semantics(header: true, child: child);
  }
}

/// EN: Skip to content link for keyboard navigation
/// KO: 키보드 네비게이션을 위한 콘텐츠로 건너뛰기 링크
class A11ySkipLink extends StatelessWidget {
  const A11ySkipLink({
    super.key,
    required this.targetKey,
    this.label = '본문으로 건너뛰기',
  });

  /// EN: Global key of the target to skip to
  /// KO: 건너뛸 대상의 글로벌 키
  final GlobalKey targetKey;

  /// EN: Label for the skip link
  /// KO: 건너뛰기 링크의 라벨
  final String label;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      link: true,
      label: label,
      child: Focus(
        child: Builder(
          builder: (context) {
            final hasFocus = Focus.of(context).hasFocus;
            if (!hasFocus) return const SizedBox.shrink();

            return Positioned(
              top: 0,
              left: 0,
              child: Material(
                child: InkWell(
                  onTap: () {
                    final target = targetKey.currentContext;
                    if (target != null) {
                      Scrollable.ensureVisible(target);
                      FocusScope.of(target).requestFocus(Focus.of(target));
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(label),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// EN: Announce a message to screen readers
/// KO: 스크린 리더에 메시지 알림
void announceToScreenReader(BuildContext context, String message) {
  SemanticsService.announce(message, TextDirection.ltr);
}

/// EN: Extension for common accessibility patterns
/// KO: 일반 접근성 패턴을 위한 확장
extension A11yExtensions on Widget {
  /// EN: Wrap with semantic label
  /// KO: 시맨틱 라벨로 래핑
  Widget withSemanticLabel(String label) {
    return Semantics(label: label, child: this);
  }

  /// EN: Mark as button for accessibility
  /// KO: 접근성을 위해 버튼으로 표시
  Widget asSemanticButton(String label, {VoidCallback? onTap}) {
    return Semantics(button: true, label: label, onTap: onTap, child: this);
  }

  /// EN: Mark as link for accessibility
  /// KO: 접근성을 위해 링크로 표시
  Widget asSemanticLink(String label) {
    return Semantics(link: true, label: label, child: this);
  }

  /// EN: Mark as image for accessibility
  /// KO: 접근성을 위해 이미지로 표시
  Widget asSemanticImage(String description) {
    return Semantics(image: true, label: description, child: this);
  }

  /// EN: Exclude from semantics tree
  /// KO: 시맨틱스 트리에서 제외
  Widget excludeFromSemantics() {
    return ExcludeSemantics(child: this);
  }

  /// EN: Merge child semantics
  /// KO: 자식 시맨틱스 병합
  Widget mergeSemantics() {
    return MergeSemantics(child: this);
  }
}

/// EN: Accessibility utilities
/// KO: 접근성 유틸리티
class A11yUtils {
  A11yUtils._();

  /// EN: Check if screen reader is enabled
  /// KO: 스크린 리더가 활성화되어 있는지 확인
  static bool isScreenReaderEnabled(BuildContext context) {
    return MediaQuery.of(context).accessibleNavigation;
  }

  /// EN: Check if reduce motion is enabled
  /// KO: 모션 감소가 활성화되어 있는지 확인
  static bool isReduceMotionEnabled(BuildContext context) {
    return MediaQuery.of(context).disableAnimations;
  }

  /// EN: Check if bold text is enabled
  /// KO: 굵은 텍스트가 활성화되어 있는지 확인
  static bool isBoldTextEnabled(BuildContext context) {
    return MediaQuery.of(context).boldText;
  }

  /// EN: Get current text scale factor
  /// KO: 현재 텍스트 스케일 팩터 반환
  static double getTextScaleFactor(BuildContext context) {
    return MediaQuery.of(context).textScaler.scale(1.0);
  }

  /// EN: Check if high contrast mode is enabled
  /// KO: 고대비 모드가 활성화되어 있는지 확인
  static bool isHighContrastEnabled(BuildContext context) {
    return MediaQuery.of(context).highContrast;
  }
}
