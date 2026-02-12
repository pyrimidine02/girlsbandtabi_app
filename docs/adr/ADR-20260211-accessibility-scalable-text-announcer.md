# ADR-20260211: Accessibility Enhancements - Scalable Text and Screen Reader Announcer

**Status:** Accepted  
**Date:** 2026-02-11  
**Authors:** Claude Sonnet 4.5 (Accessibility Tester Agent)

## Context

The application needs to achieve WCAG 2.1 Level AA compliance for text scaling and screen reader support. Users with visual impairments require:

1. **Text Scaling**: Ability to scale text up to 200% without loss of content or functionality (WCAG 1.4.4)
2. **Screen Reader Announcements**: Dynamic content changes must be communicated to assistive technologies (WCAG 4.1.3)
3. **Localized Messages**: Error and success messages should respect user locale preferences

The existing `a11y_wrapper.dart` file provides basic accessibility utilities but lacks specific widgets for text scaling and screen reader announcements.

## Decision

We extended `/Users/sonhoyoung/Documents/code/girlsbandtabi_app/lib/core/accessibility/a11y_wrapper.dart` with two new components:

### 1. A11yScalableText Widget

A `StatelessWidget` that automatically scales text based on user's system accessibility settings:

**Key Features:**
- Reads text scale factor from `MediaQuery.textScaler`
- Clamps scale factor between 1.0 and 2.0 to prevent layout overflow
- Supports all standard Text widget properties (maxLines, overflow, textAlign, semanticLabel)
- Uses default font size of 14.0 when style is not provided
- Follows Google Code Style and Effective Dart conventions

**Usage:**
```dart
A11yScalableText(
  'Welcome to Girls Band Tabi',
  style: TextStyle(fontSize: 16.0),
  maxLines: 2,
  overflow: TextOverflow.ellipsis,
  semanticLabel: 'Welcome message',
)
```

### 2. A11yAnnouncer Utility Class

A static utility class for announcing messages to screen readers:

**Key Features:**
- `announce(context, message)`: General announcements
- `announceError(context, message)`: Error announcements with localized prefix
- `announceSuccess(context, message)`: Success announcements with localized prefix
- Automatically ignores empty messages
- Locale-aware prefixes (Korean: "오류:", "성공:" / English: "Error:", "Success:")
- Uses `SemanticsService.announce()` for platform-agnostic screen reader support

**Usage:**
```dart
// General announcement
A11yAnnouncer.announce(context, '새로운 메시지가 도착했습니다');

// Error announcement (automatically prefixed)
A11yAnnouncer.announceError(context, '네트워크 연결 실패');

// Success announcement (automatically prefixed)
A11yAnnouncer.announceSuccess(context, '저장 완료');
```

## Implementation Details

### Text Scaling Algorithm

```dart
final scaleFactor = A11yUtils.getTextScaleFactor(context);
final clampedScale = scaleFactor.clamp(1.0, 2.0);
final baseFontSize = style?.fontSize ?? 14.0;
final scaledFontSize = baseFontSize * clampedScale;
```

- Minimum: 1.0 (normal size)
- Maximum: 2.0 (200% zoom - WCAG AA requirement)
- Prevents layout overflow while maintaining readability

### Locale Detection

```dart
final locale = Localizations.localeOf(context);
final prefix = locale.languageCode == 'ko' ? '오류: ' : 'Error: ';
```

- Checks user's locale via `Localizations.localeOf(context)`
- Provides Korean and English prefixes
- Defaults to English for other locales

## Testing

Comprehensive test suite created at `/Users/sonhoyoung/Documents/code/girlsbandtabi_app/test/core/accessibility/a11y_wrapper_test.dart`:

### A11yScalableText Tests (9 tests)
- Renders text with default scale factor
- Applies text scale factor from MediaQuery
- Clamps scale factor to maximum 2.0
- Respects minimum scale factor of 1.0
- Uses default font size when style is null
- Applies text alignment correctly
- Respects maxLines property
- Respects overflow property
- Applies semantic label correctly

### A11yAnnouncer Tests (8 tests)
- Announce works with valid context and message
- Announce ignores empty messages
- AnnounceError works with Korean locale
- AnnounceError works with English locale
- AnnounceSuccess works with Korean locale
- AnnounceSuccess works with English locale
- AnnounceError ignores empty messages
- AnnounceSuccess ignores empty messages

### A11yUtils Tests (2 tests)
- GetTextScaleFactor returns correct value
- IsScreenReaderEnabled returns correct value

**All 19 tests passing**

## WCAG Compliance

This implementation addresses the following WCAG 2.1 Level AA criteria:

| Criterion | Description | How Addressed |
|-----------|-------------|---------------|
| 1.4.4 Resize text | Text can be resized up to 200% | A11yScalableText clamps to 2.0 max |
| 4.1.3 Status Messages | Status messages communicated to assistive tech | A11yAnnouncer uses SemanticsService |
| 3.3.1 Error Identification | Errors clearly identified | announceError with "Error:" prefix |
| 3.3.4 Error Prevention | Success feedback provided | announceSuccess with "Success:" prefix |

## Alternatives Considered

### 1. Using MediaQuery.textScaleFactor directly in each widget
**Rejected:** Inconsistent implementation across codebase, code duplication

### 2. Global text scale factor override
**Rejected:** Doesn't respect user's system preferences, accessibility violation

### 3. Using SnackBar/Dialog for all announcements
**Rejected:** Not accessible to screen reader users, visual-only

### 4. Single announcement method without locale awareness
**Rejected:** Poor UX for Korean users, English-only announcements

## Consequences

### Positive
- WCAG 2.1 Level AA compliance for text scaling
- Improved screen reader support across the application
- Consistent text scaling behavior
- Locale-aware announcements enhance UX
- Centralized accessibility utilities reduce code duplication
- Comprehensive test coverage ensures reliability

### Negative
- Developers must remember to use A11yScalableText instead of Text for dynamic content
- Maximum 2.0 scale factor may not be sufficient for users requiring >200% zoom (they can use OS-level zoom)
- Additional widget in render tree (minimal performance impact)

### Migration Path
- Existing Text widgets can remain unchanged
- Gradually migrate critical text (errors, headings, dynamic content) to A11yScalableText
- Use A11yAnnouncer for all dynamic content changes (form submissions, loading states, etc.)

## References

- [WCAG 2.1 Level AA](https://www.w3.org/WAI/WCAG21/quickref/?versions=2.1&levels=aa)
- [Flutter Accessibility Guide](https://docs.flutter.dev/development/accessibility-and-localization/accessibility)
- [Google Code Style Guide](https://google.github.io/styleguide/)
- [Effective Dart](https://dart.dev/guides/language/effective-dart)
- [Flutter SemanticsService](https://api.flutter.dev/flutter/semantics/SemanticsService-class.html)

## Related ADRs
- ADR-YYYYMMDD-accessibility-wrapper-initial (if exists)
- Future: ADR-YYYYMMDD-accessibility-color-contrast
- Future: ADR-YYYYMMDD-accessibility-keyboard-navigation

## Usage Examples

### Form Error Handling
```dart
onPressed: () async {
  try {
    await submitForm();
    A11yAnnouncer.announceSuccess(context, '등록 완료');
  } catch (e) {
    A11yAnnouncer.announceError(context, '등록 실패');
  }
}
```

### Dynamic Content Updates
```dart
ListView.builder(
  itemBuilder: (context, index) {
    return ListTile(
      title: A11yScalableText(
        items[index].title,
        style: TextStyle(fontSize: 16.0),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  },
)
```

### Loading State Announcements
```dart
if (state is Loading) {
  A11yAnnouncer.announce(context, '데이터 로딩 중');
  return CircularProgressIndicator();
}
```

## Compliance Checklist

- [x] WCAG 2.1 Level AA text scaling (1.4.4)
- [x] Screen reader announcements (4.1.3)
- [x] Error identification (3.3.1)
- [x] Success feedback (3.3.4)
- [x] Locale-aware messages
- [x] Comprehensive test coverage
- [x] Google Code Style compliance
- [x] EN/KO bilingual comments
- [x] Documentation in ADR
