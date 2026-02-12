# Accessibility Features - WCAG 2.1 Level AA Compliance

## Overview

This document describes the accessibility features implemented in the Girls Band Tabi application to achieve WCAG 2.1 Level AA compliance.

## Components

### 1. A11yScalableText Widget

A text widget that automatically scales based on user's system accessibility settings.

**File:** `/Users/sonhoyoung/Documents/code/girlsbandtabi_app/lib/core/accessibility/a11y_wrapper.dart`

**Features:**
- Automatic text scaling (1.0x - 2.0x)
- Layout overflow prevention
- Semantic label support
- Full Text widget API compatibility

**Usage:**
```dart
A11yScalableText(
  'Your text here',
  style: TextStyle(fontSize: 16.0),
  maxLines: 2,
  overflow: TextOverflow.ellipsis,
  semanticLabel: 'Alternative text for screen readers',
)
```

**WCAG Compliance:**
- ✓ 1.4.4 Resize text (Level AA)

### 2. A11yAnnouncer Utility Class

Static utility class for announcing messages to screen readers.

**Methods:**

#### announce(BuildContext, String)
General purpose announcements for screen readers.

```dart
A11yAnnouncer.announce(context, '새로운 메시지가 도착했습니다');
```

#### announceError(BuildContext, String)
Error announcements with locale-aware prefixes.

```dart
A11yAnnouncer.announceError(context, '네트워크 연결 실패');
// Korean: "오류: 네트워크 연결 실패"
// English: "Error: Network connection failed"
```

#### announceSuccess(BuildContext, String)
Success announcements with locale-aware prefixes.

```dart
A11yAnnouncer.announceSuccess(context, '저장 완료');
// Korean: "성공: 저장 완료"
// English: "Success: Save completed"
```

**WCAG Compliance:**
- ✓ 4.1.3 Status Messages (Level AA)
- ✓ 3.3.1 Error Identification (Level A)
- ✓ 3.3.4 Error Prevention (Level AA)

### 3. A11yUtils Utility Class

Helper methods for checking accessibility settings.

**Methods:**

```dart
// Check if screen reader is enabled
bool isScreenReaderEnabled = A11yUtils.isScreenReaderEnabled(context);

// Check if reduce motion is enabled
bool isReduceMotionEnabled = A11yUtils.isReduceMotionEnabled(context);

// Check if bold text is enabled
bool isBoldTextEnabled = A11yUtils.isBoldTextEnabled(context);

// Get current text scale factor
double textScaleFactor = A11yUtils.getTextScaleFactor(context);

// Check if high contrast mode is enabled
bool isHighContrastEnabled = A11yUtils.isHighContrastEnabled(context);
```

## Implementation Guidelines

### When to Use A11yScalableText

✓ **Use for:**
- Dynamic content that users need to read
- Error messages and important notifications
- List items and card content
- Form labels and instructions
- Headlines and body text

✗ **Don't use for:**
- Fixed UI elements (app bars, navigation)
- Decorative text
- Text in images (use semantic labels instead)

### When to Use A11yAnnouncer

✓ **Use for:**
- Form submission results
- Loading state changes
- Data refresh notifications
- Navigation context changes
- Dynamic content updates

✗ **Don't use for:**
- Static content
- Initial page load
- Navigation actions (already announced by framework)

## Testing

### Automated Tests

Location: `/Users/sonhoyoung/Documents/code/girlsbandtabi_app/test/core/accessibility/a11y_wrapper_test.dart`

Run tests:
```bash
flutter test test/core/accessibility/a11y_wrapper_test.dart
```

**Test Coverage:**
- A11yScalableText: 9 tests
- A11yAnnouncer: 8 tests
- A11yUtils: 2 tests
- Total: 19 tests (all passing)

### Manual Testing

#### iOS
1. Settings > Accessibility > Display & Text Size > Larger Text
2. Settings > Accessibility > VoiceOver
3. Test app with different text sizes (100% - 200%)
4. Test app with VoiceOver enabled

#### Android
1. Settings > Accessibility > Font size
2. Settings > Accessibility > TalkBack
3. Test app with different font sizes
4. Test app with TalkBack enabled

## Example Screen

See `/Users/sonhoyoung/Documents/code/girlsbandtabi_app/lib/core/accessibility/a11y_examples.dart` for comprehensive usage examples including:
- Basic scalable text
- Overflow handling
- Screen reader announcements
- Form error handling
- Accessibility status display

## WCAG 2.1 Level AA Compliance

| Criterion | Description | Status | Implementation |
|-----------|-------------|--------|----------------|
| 1.4.4 Resize text | Text can be resized up to 200% | ✓ Pass | A11yScalableText |
| 4.1.3 Status Messages | Status messages communicated | ✓ Pass | A11yAnnouncer |
| 3.3.1 Error Identification | Errors clearly identified | ✓ Pass | announceError |
| 3.3.4 Error Prevention | Success feedback provided | ✓ Pass | announceSuccess |

## Best Practices

### 1. Consistent Text Scaling
```dart
// Good: Uses A11yScalableText for dynamic content
A11yScalableText(
  place.name,
  style: TextStyle(fontSize: 18.0),
  maxLines: 2,
)

// Acceptable: Regular Text for fixed UI elements
Text('Settings', style: Theme.of(context).textTheme.titleLarge)
```

### 2. Meaningful Error Messages
```dart
// Good: Clear, actionable error message
A11yAnnouncer.announceError(context, '이메일 형식이 올바르지 않습니다');

// Bad: Vague error message
A11yAnnouncer.announceError(context, '오류');
```

### 3. Success Feedback
```dart
// Good: Confirms action completion
onSaved: () {
  A11yAnnouncer.announceSuccess(context, '장소가 저장되었습니다');
}

// Bad: Silent success (no feedback)
onSaved: () {
  // No announcement
}
```

### 4. Loading States
```dart
// Good: Announces loading state
setState(() => isLoading = true);
A11yAnnouncer.announce(context, '데이터 로딩 중');

// Bad: Visual-only loading indicator
setState(() => isLoading = true);
// No announcement
```

## Migration Guide

### Existing Text Widgets

For critical user-facing text, migrate to A11yScalableText:

```dart
// Before
Text(
  errorMessage,
  style: TextStyle(fontSize: 16.0, color: Colors.red),
)

// After
A11yScalableText(
  errorMessage,
  style: TextStyle(fontSize: 16.0, color: Colors.red),
  semanticLabel: 'Error: $errorMessage',
)
```

### Adding Screen Reader Support

For dynamic content changes:

```dart
// Before
void _onSubmit() async {
  final result = await submitForm();
  setState(() => _success = result);
}

// After
void _onSubmit() async {
  A11yAnnouncer.announce(context, '제출 중');
  final result = await submitForm();
  
  if (result) {
    A11yAnnouncer.announceSuccess(context, '제출 완료');
  } else {
    A11yAnnouncer.announceError(context, '제출 실패');
  }
  
  setState(() => _success = result);
}
```

## Resources

- [WCAG 2.1 Guidelines](https://www.w3.org/WAI/WCAG21/quickref/)
- [Flutter Accessibility](https://docs.flutter.dev/development/accessibility-and-localization/accessibility)
- [Material Design Accessibility](https://m3.material.io/foundations/accessible-design)
- [iOS Accessibility](https://developer.apple.com/accessibility/)
- [Android Accessibility](https://developer.android.com/guide/topics/ui/accessibility)

## Support

For questions or issues related to accessibility features:
1. Check this documentation
2. Review ADR-20260211-accessibility-scalable-text-announcer.md
3. Examine examples in a11y_examples.dart
4. Run automated tests for validation

## Future Enhancements

- [ ] Color contrast analyzer utility
- [ ] Focus management helpers
- [ ] Keyboard navigation utilities
- [ ] Touch target size validator
- [ ] Accessibility audit tool
- [ ] Automated WCAG compliance checker
