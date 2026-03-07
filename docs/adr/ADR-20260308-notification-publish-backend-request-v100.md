# ADR-20260308-notification-publish-backend-request-v100

## Status
Accepted

## Date
2026-03-08

## Context
- 앱의 알림 UX 품질은 서버 발행 품질(주제/문구/딥링크/멱등성)에 크게 좌우된다.
- 최근 원격 푸시 경로는 활성화되었지만, 백엔드 발행 기준이 문서로 통일되지 않아
  이벤트별 문구/키/라우팅 품질 편차가 발생할 수 있다.
- 클라이언트는 현재 카테고리 토글을 `LIVE_EVENT`, `FAVORITE`, `COMMENT`로
  운영하고 있으며, payload 키도 복수 별칭을 허용한다.

## Decision
1. 백엔드 전달용 알림 발행 요청서 v1.0.0 문서를 신규 작성한다.
   - 파일: `docs/api-spec/알림발행_백엔드요청서_v1.0.0.md`
2. 문서에 아래를 명시한다.
   - 앱 지원 카테고리
   - 푸시/SSE payload 키 계약(필수/권장)
   - 지원 딥링크 경로
   - 추천 발행 시나리오 및 문구 템플릿
   - 멱등성(`notificationId`) 및 알림함 정합성 규칙
3. 서버 확정 전까지 TODO에 후속 확인 항목을 유지한다.

## Alternatives Considered
1. 구두/채팅으로만 발행 가이드를 전달
   - 빠르지만 운영 중 계약 드리프트가 재발할 가능성이 높다.
2. 기존 푸시 연동 요청서에 단편 추가
   - 목적이 다른 문서(인프라 연동 vs 발행 품질 계약)가 혼재되어
     실무 체크포인트가 흐려진다.

## Consequences
### Positive
- 서버/클라이언트가 동일 기준으로 발행/파싱/라우팅을 맞출 수 있다.
- 운영 공지/댓글/라이브 리마인드 같은 고빈도 알림의 문구 품질을
  일관되게 관리할 수 있다.

### Trade-offs
- 서버 이벤트 스키마 확정 전에는 일부 `eventCode`가 변경될 수 있다.
- 카테고리 확장(예: COMMUNITY)이 필요해지면 문서 버전업이 필요하다.

## Scope
- `docs/api-spec/알림발행_백엔드요청서_v1.0.0.md`
- `CHANGELOG.md`
- `TODO.md`

## Validation
- 문서 내용이 현재 앱 수신/라우팅 구현과 충돌 없는지 코드 기준 확인:
  - `lib/core/notifications/remote_push_service.dart`
  - `lib/features/notifications/domain/entities/notification_navigation.dart`
  - `lib/features/settings/domain/entities/notification_settings.dart`
