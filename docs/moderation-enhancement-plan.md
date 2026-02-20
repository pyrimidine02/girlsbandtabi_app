# 커뮤니티 모더레이션 강화 구현 계획서

> 작성일: 2026-02-18
> 참고 문서: `docs/deep-research-report.md` (한국 커뮤니티 플랫폼 유저·글 관리 비교 보고서)

---

## 배경 및 목적

`docs/deep-research-report.md` 기반 한국 커뮤니티 플랫폼 비교 분석 보고서의 P0~P1 권고사항을 반영하여, 기존 신고/차단 기능을 강화합니다.

### 현재 상태 (As-Is)

| 기능 | 현재 구현 수준 |
|------|----------------|
| 신고 | `createReport()` → 성공/실패 snackbar (단순) |
| 차단 | `blockUser/unblockUser()` + `BlockStatus` 엔티티 + `BlockStatusController` |
| 중복 제출 방지 | `_isSubmitting` bool 플래그만 (쿨다운 없음) |
| 콘텐츠 상태 | 없음 (published/quarantined/deleted 구분 불가) |
| 제재 상태 | 없음 (경고/정지 단계 없음) |
| 이의제기 | 없음 |

### 목표 (To-Be)

- **P0**: 신고 레이트리밋 UX + 신고 확인 다이얼로그
- **P1**: 콘텐츠 상태 머신 + 유저 제재 상태 + 이의제기 플로우

---

## 검증 결과 요약 (코드베이스 대조)

코드베이스 실제 파일 대조를 통해 확인한 패턴:

| 항목 | 확인된 패턴 |
|------|-------------|
| 상태 관리 | `StateNotifierProvider` 기반 Riverpod (ChangeNotifier 미사용) |
| Result 패턴 | `is Success<T>` / `is Err<T>` 체크 패턴 (지배적 사용) |
| Repository 접근 | `await ref.read(xxxRepositoryProvider.future)` |
| GBTColors | `success`, `error`, `errorLight`, `warning`, `warningLight`, `warningDark` 모두 존재 |
| GBTSpacing | `paddingPage`, `paddingMd`, `iconSm`, `touchTarget` 모두 존재 |
| RadioGroup | Flutter 내장 위젯 (`package:flutter/material.dart` 임포트만으로 사용 가능) |

---

## Phase 1 (P0): 신고 레이트리밋 + UX 개선

### 1-1. ReportRateLimiter 서비스 신규 생성

**파일**: `lib/features/feed/application/report_rate_limiter.dart`

```dart
/// EN: Client-side rate limiter for community reports.
/// KO: 커뮤니티 신고 클라이언트 레이트리밋 서비스.
class ReportRateLimiter {
  // EN: Minimum interval between reports on the same target.
  // KO: 동일 대상에 대한 최소 신고 간격.
  static const Duration _cooldown = Duration(minutes: 5);

  final Map<String, DateTime> _lastReportAt = {};

  /// EN: Check if reporting the given target is allowed.
  /// KO: 해당 대상 신고가 허용되는지 확인합니다.
  bool canReport(String targetId) {
    final last = _lastReportAt[targetId];
    if (last == null) return true;
    return DateTime.now().difference(last) >= _cooldown;
  }

  /// EN: Returns remaining cooldown duration (zero if allowed).
  /// KO: 남은 쿨다운 시간을 반환합니다 (허용된 경우 zero).
  Duration remainingCooldown(String targetId) {
    final last = _lastReportAt[targetId];
    if (last == null) return Duration.zero;
    final elapsed = DateTime.now().difference(last);
    if (elapsed >= _cooldown) return Duration.zero;
    return _cooldown - elapsed;
  }

  /// EN: Record a report submission timestamp.
  /// KO: 신고 제출 타임스탬프를 기록합니다.
  void recordReport(String targetId) {
    _lastReportAt[targetId] = DateTime.now();
  }
}

/// EN: Global provider for the report rate limiter.
/// KO: 신고 레이트리밋 글로벌 프로바이더.
final reportRateLimiterProvider = Provider<ReportRateLimiter>(
  (_) => ReportRateLimiter(),
);
```

### 1-2. `_showReportFlow()` 수정

**수정 대상**: `lib/features/feed/presentation/pages/post_detail_page.dart` — `_showReportFlow()` 메서드 (383번째 줄)

변경 내용:
1. 메서드 상단에 `reportRateLimiterProvider`로 쿨다운 체크 추가
2. 바텀시트 후 API 호출 전 확인 다이얼로그 추가
3. 성공 시 `rateLimiter.recordReport(targetId)` 기록

```dart
Future<void> _showReportFlow(
  BuildContext context,
  CommunityReportTargetType targetType,
  String targetId,
) async {
  // EN: Check client-side rate limit before showing report sheet.
  // KO: 신고 시트 표시 전 클라이언트 레이트리밋 확인.
  final rateLimiter = ref.read(reportRateLimiterProvider);
  if (!rateLimiter.canReport(targetId)) {
    final minutes = rateLimiter.remainingCooldown(targetId).inMinutes + 1;
    if (!context.mounted) return;
    _showSnackBar(context, '${minutes}분 후 다시 신고할 수 있어요');
    return;
  }

  final payload = await showModalBottomSheet<_ReportPayload>(
    context: context,
    isScrollControlled: true,
    builder: (sheetContext) => _ReportSheet(),
  );
  if (payload == null) return;

  // EN: Show confirmation dialog before submitting.
  // KO: API 호출 전 확인 다이얼로그 표시.
  if (!context.mounted) return;
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('신고 접수'),
      content: Text(
        '${targetType.label}을(를) "${payload.reason.label}" 사유로 신고합니다.\n접수하시겠어요?',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: const Text('취소'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: const Text('신고 접수'),
        ),
      ],
    ),
  );
  if (confirmed != true) return;

  final repository = await ref.read(communityRepositoryProvider.future);
  final result = await repository.createReport(
    targetType: targetType,
    targetId: targetId,
    reason: payload.reason,
    description: payload.description,
  );

  if (result is Err<void> && context.mounted) {
    _showSnackBar(context, '신고를 접수하지 못했어요');
    return;
  }
  if (result is Success<void>) {
    rateLimiter.recordReport(targetId);
    if (context.mounted) {
      _showSnackBar(context, '신고가 접수되었어요. 검토 후 조치할게요');
    }
  }
}
```

---

## Phase 2 (P1): 콘텐츠 상태 머신

### 2-1. 도메인 엔티티 확장

**수정 대상**: `lib/features/feed/domain/entities/community_moderation.dart`

```dart
/// EN: Content moderation status for posts and comments.
/// KO: 게시글/댓글 콘텐츠 모더레이션 상태.
enum ContentModerationStatus { published, quarantined, deleted }

extension ContentModerationStatusX on ContentModerationStatus {
  String get apiValue {
    switch (this) {
      case ContentModerationStatus.published:   return 'PUBLISHED';
      case ContentModerationStatus.quarantined: return 'QUARANTINED';
      case ContentModerationStatus.deleted:     return 'DELETED';
    }
  }

  String get label {
    switch (this) {
      case ContentModerationStatus.published:   return '정상';
      case ContentModerationStatus.quarantined: return '검토 중';
      case ContentModerationStatus.deleted:     return '삭제됨';
    }
  }

  static ContentModerationStatus fromApiValue(String? v) {
    switch (v) {
      case 'QUARANTINED': return ContentModerationStatus.quarantined;
      case 'DELETED':     return ContentModerationStatus.deleted;
      default:            return ContentModerationStatus.published;
    }
  }
}
```

### 2-2. 엔티티 + DTO 확장

**`lib/features/feed/domain/entities/feed_entities.dart`**: `PostDetail`, `PostSummary`에 `final ContentModerationStatus? moderationStatus` 필드 추가, `fromDto()` 매핑 업데이트

**`lib/features/feed/data/dto/post_dto.dart`**: `PostDetailDto`, `PostSummaryDto`에 `final String? moderationStatus` 필드 추가

### 2-3. 격리 배너 UI

**수정 대상**: `lib/features/feed/presentation/pages/post_detail_page.dart` — `_PostDetailContent.build()` 내부

```dart
// EN: Show quarantine banner if content is under review.
// KO: 콘텐츠 검토 중인 경우 격리 배너를 표시합니다.
if (post.moderationStatus == ContentModerationStatus.quarantined)
  Container(
    width: double.infinity,
    padding: const EdgeInsets.all(GBTSpacing.md),
    color: GBTColors.warningLight,
    child: Row(
      children: [
        const Icon(Icons.info_outline,
                   color: GBTColors.warningDark, size: GBTSpacing.iconSm),
        const SizedBox(width: GBTSpacing.sm),
        Expanded(
          child: Text(
            '이 콘텐츠는 현재 검토 중입니다.',
            style: GBTTypography.bodySmall.copyWith(
              color: GBTColors.warningDark,
            ),
          ),
        ),
        // EN: Show appeal button only for the post's own author.
        // KO: 게시글 작성자에게만 이의제기 버튼 표시.
        if (isOwnPost)
          TextButton(
            onPressed: () => _showAppealFlow(
              context,
              CommunityReportTargetType.post,
              post.id,
            ),
            child: const Text('이의제기'),
          ),
      ],
    ),
  ),
```

---

## Phase 3 (P1): 유저 제재 상태

### 3-1. 제재 엔티티 추가

**수정 대상**: `lib/features/feed/domain/entities/community_moderation.dart`

```dart
/// EN: User sanction status levels.
/// KO: 유저 제재 상태 수준.
enum UserSanctionLevel { none, warning, muted, banned }

extension UserSanctionLevelX on UserSanctionLevel {
  String get apiValue {
    switch (this) {
      case UserSanctionLevel.none:    return 'NONE';
      case UserSanctionLevel.warning: return 'WARNING';
      case UserSanctionLevel.muted:   return 'MUTED';
      case UserSanctionLevel.banned:  return 'BANNED';
    }
  }

  String get label {
    switch (this) {
      case UserSanctionLevel.none:    return '정상';
      case UserSanctionLevel.warning: return '경고';
      case UserSanctionLevel.muted:   return '작성 제한';
      case UserSanctionLevel.banned:  return '이용 정지';
    }
  }

  static UserSanctionLevel fromApiValue(String? v) {
    switch (v) {
      case 'WARNING': return UserSanctionLevel.warning;
      case 'MUTED':   return UserSanctionLevel.muted;
      case 'BANNED':  return UserSanctionLevel.banned;
      default:        return UserSanctionLevel.none;
    }
  }
}

/// EN: User sanction state entity.
/// KO: 유저 제재 상태 엔티티.
class UserSanctionStatus {
  const UserSanctionStatus({
    required this.level,
    this.reason,
    this.expiresAt,
  });

  final UserSanctionLevel level;

  /// EN: Reason given for the sanction.
  /// KO: 제재 사유.
  final String? reason;

  /// EN: When the sanction expires (null = permanent or no sanction).
  /// KO: 제재 만료 시각 (null = 영구 또는 제재 없음).
  final DateTime? expiresAt;

  /// EN: Whether the user is restricted from posting.
  /// KO: 사용자가 게시글/댓글 작성이 제한된 상태인지.
  bool get isRestricted =>
      level == UserSanctionLevel.muted ||
      level == UserSanctionLevel.banned;
}
```

### 3-2. API 엔드포인트 추가

**수정 대상**: `lib/core/constants/api_constants.dart`

```dart
// EN: User sanction and community appeals endpoints.
// KO: 유저 제재 상태 및 커뮤니티 이의제기 엔드포인트.
static const String myActionableStatus = '$apiVersion/users/me/actionable-status';
static const String communityAppeals   = '$apiVersion/community/appeals';
```

### 3-3. Repository 인터페이스 확장

**수정 대상**: `lib/features/feed/domain/repositories/community_repository.dart`

```dart
/// EN: Get sanction status for the currently authenticated user.
/// KO: 현재 로그인 사용자의 제재 상태를 조회합니다.
Future<Result<UserSanctionStatus>> getMySanctionStatus();

/// EN: Submit a moderation appeal for a post or sanction.
/// KO: 게시글 또는 제재에 대한 이의제기를 제출합니다.
Future<Result<void>> submitAppeal({
  required CommunityReportTargetType targetType,
  required String targetId,
  required String reason,
});
```

### 3-4. 구현체 확장

**수정 대상**: `lib/features/feed/data/repositories/community_repository_impl.dart`

`getMySanctionStatus()` — 서버 미구현 시 graceful fallback:

```dart
@override
Future<Result<UserSanctionStatus>> getMySanctionStatus() async {
  try {
    final result = await _remoteDataSource.getMySanctionStatus();
    if (result is Success<UserSanctionStatusDto>) {
      final dto = result.data;
      return Result.success(UserSanctionStatus(
        level: UserSanctionLevelX.fromApiValue(dto.level),
        reason: dto.reason,
        expiresAt: dto.expiresAt != null
            ? DateTime.tryParse(dto.expiresAt!)
            : null,
      ));
    }
    if (result is Err<UserSanctionStatusDto>) {
      // EN: If endpoint is not yet deployed, default to no sanction.
      // KO: 엔드포인트 미배포 시 제재 없음을 기본값으로 반환합니다.
      return const Result.success(
        UserSanctionStatus(level: UserSanctionLevel.none),
      );
    }
    return const Result.success(
      UserSanctionStatus(level: UserSanctionLevel.none),
    );
  } catch (e, stackTrace) {
    return Result.failure(ErrorHandler.mapException(e, stackTrace));
  }
}
```

### 3-5. 제재 상태 사전 체크 — post_create_page.dart

**수정 대상**: `lib/features/feed/presentation/pages/post_create_page.dart` — `_submit()` 메서드 상단

```dart
// EN: Check user sanction status before allowing submission.
// KO: 제출 허용 전 사용자 제재 상태를 확인합니다.
final repository = await ref.read(communityRepositoryProvider.future);
final sanctionResult = await repository.getMySanctionStatus();
if (sanctionResult is Success<UserSanctionStatus>) {
  if (sanctionResult.data.isRestricted && mounted) {
    setState(() => _isSubmitting = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '현재 ${sanctionResult.data.level.label} 상태로 게시글을 작성할 수 없어요',
        ),
      ),
    );
    return;
  }
}
```

---

## Phase 4 (P1): 이의제기 플로우

### 4-1. 이의제기 제출 메서드 — post_detail_page.dart

```dart
Future<void> _showAppealFlow(
  BuildContext context,
  CommunityReportTargetType targetType,
  String targetId,
) async {
  final controller = TextEditingController();
  final reason = await showDialog<String>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('이의제기'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('이의제기 사유를 입력해주세요.'),
          const SizedBox(height: GBTSpacing.md),
          TextField(
            controller: controller,
            maxLines: 4,
            decoration: const InputDecoration(hintText: '사유를 입력하세요'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: const Text('취소'),
        ),
        FilledButton(
          onPressed: () {
            final text = controller.text.trim();
            if (text.isEmpty) return;
            Navigator.of(dialogContext).pop(text);
          },
          child: const Text('제출'),
        ),
      ],
    ),
  );
  controller.dispose();
  if (reason == null || !context.mounted) return;

  final repository = await ref.read(communityRepositoryProvider.future);
  final result = await repository.submitAppeal(
    targetType: targetType,
    targetId: targetId,
    reason: reason,
  );

  if (!context.mounted) return;
  if (result is Success<void>) {
    _showSnackBar(context, '이의제기가 접수되었어요');
  } else if (result is Err<void>) {
    _showSnackBar(context, '이의제기 접수에 실패했어요');
  }
}
```

---

## 구현 순서

```
Phase 1 (P0, 즉시 시작 가능)
│
├── 1. lib/features/feed/application/report_rate_limiter.dart 신규 생성
└── 2. lib/features/feed/presentation/pages/post_detail_page.dart
       _showReportFlow() 수정 (레이트리밋 + 확인 다이얼로그)

Phase 2 (P1, Phase 1 이후)
│
├── 3. lib/features/feed/domain/entities/community_moderation.dart
│      ContentModerationStatus enum 추가
├── 4. lib/features/feed/data/dto/post_dto.dart
│      moderationStatus 필드 추가
├── 5. lib/features/feed/domain/entities/feed_entities.dart
│      PostDetail, PostSummary에 moderationStatus 추가
└── 6. lib/features/feed/presentation/pages/post_detail_page.dart
       격리 배너 UI 추가

Phase 3 (P1, Phase 2 이후)
│
├── 7. lib/features/feed/domain/entities/community_moderation.dart
│      UserSanctionLevel, UserSanctionStatus 추가
├── 8. lib/core/constants/api_constants.dart
│      myActionableStatus, communityAppeals 엔드포인트 추가
├── 9. lib/features/feed/domain/repositories/community_repository.dart
│      getMySanctionStatus(), submitAppeal() 인터페이스 추가
├── 10. lib/features/feed/data/dto/community_moderation_dto.dart
│       UserSanctionStatusDto, AppealCreateRequestDto 추가
├── 11. lib/features/feed/data/datasources/community_remote_data_source.dart
│       getMySanctionStatus(), submitAppeal() 메서드 추가
├── 12. lib/features/feed/data/repositories/community_repository_impl.dart
│       신규 메서드 구현 (graceful fallback 포함)
└── 13. lib/features/feed/presentation/pages/post_create_page.dart
        _submit() 제재 상태 사전 체크 추가

Phase 4 (P1, Phase 3 이후)
│
└── 14. lib/features/feed/presentation/pages/post_detail_page.dart
        _showAppealFlow() 메서드 추가 (이의제기 다이얼로그)
```

---

## 파일 목록

### 신규 생성

| 파일 | 역할 |
|------|------|
| `lib/features/feed/application/report_rate_limiter.dart` | 신고 쿨다운 서비스 + Provider |

### 수정 대상

| 파일 | 변경 내용 |
|------|-----------|
| `lib/features/feed/domain/entities/community_moderation.dart` | `ContentModerationStatus`, `UserSanctionLevel`, `UserSanctionStatus` 추가 |
| `lib/features/feed/domain/repositories/community_repository.dart` | `getMySanctionStatus()`, `submitAppeal()` 추가 |
| `lib/features/feed/data/dto/post_dto.dart` | `moderationStatus` 필드 추가 |
| `lib/features/feed/data/dto/community_moderation_dto.dart` | `UserSanctionStatusDto`, `AppealCreateRequestDto` 추가 |
| `lib/features/feed/data/datasources/community_remote_data_source.dart` | `getMySanctionStatus()`, `submitAppeal()` 추가 |
| `lib/features/feed/data/repositories/community_repository_impl.dart` | 신규 메서드 구현 |
| `lib/core/constants/api_constants.dart` | 신규 엔드포인트 상수 추가 |
| `lib/features/feed/domain/entities/feed_entities.dart` | `moderationStatus` 필드 추가 |
| `lib/features/feed/presentation/pages/post_detail_page.dart` | 레이트리밋, 확인 다이얼로그, 격리 배너, 이의제기 플로우 |
| `lib/features/feed/presentation/pages/post_create_page.dart` | 제재 상태 사전 체크 |

---

## 테스트 방법

### 단위 테스트

**`test/features/feed/application/report_rate_limiter_test.dart`** (신규):
- `canReport()` — 첫 호출 시 true 반환
- `canReport()` — `recordReport()` 직후 false 반환
- `remainingCooldown()` — 5분 쿨다운 값 정상 반환

**`test/features/feed/data/repositories/community_repository_impl_test.dart`** (수정):
- `getMySanctionStatus()` — 서버 404 시 `UserSanctionLevel.none` 반환 확인
- `submitAppeal()` — 성공 시 `Result.success(null)` 반환 확인

### 위젯 테스트

- `_showReportFlow()` — 쿨다운 만료 전 snackbar("n분 후 다시 신고할 수 있어요") 표시
- `_showReportFlow()` — 확인 다이얼로그에서 취소 시 `createReport()` 미호출
- 격리 배너 표시 조건 — `moderationStatus == quarantined`일 때만 노출
- 이의제기 다이얼로그 — 사유 미입력 시 제출 버튼 무반응

### 인수 기준

1. 동일 targetId에 5분 이내 재신고 시 쿨다운 snackbar 표시
2. 신고 확인 다이얼로그에서 취소 시 API 미호출
3. muted/banned 유저의 게시글 작성 시도 → 차단 snackbar 표시
4. `quarantined` 게시글에 경고 배너 표시, 본인 게시글에는 이의제기 버튼 추가
5. 이의제기 사유 미입력 시 `제출` 버튼 무반응

---

## 서버 미구현 시 Fallback 정책

| 기능 | 서버 미구현 대응 |
|------|-----------------|
| `getMySanctionStatus()` | 404/네트워크 오류 시 `UserSanctionLevel.none` 반환 → 기존 동작 유지 |
| `submitAppeal()` | 404 응답 시 `Result.failure` 반환 + "이의제기 접수에 실패했어요" snackbar |
| `moderationStatus` DTO 파싱 | 필드 없으면 `null` → `ContentModerationStatus.published` 기본값 |
