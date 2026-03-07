# ADR-20260307-user-profile-activity-resilience-and-settings-profile-link

## Status
Accepted (2026-03-07)

## Context
- 사용자 요청:
  - 설정 페이지에서 프로필 카드 상단 영역 탭 시 내 프로필로 이동.
  - 내 프로필의 팔로워/팔로잉 숫자 정확 표시.
  - 내 프로필의 작성글/작성댓글 목록이 한쪽 실패에도 최대한 표시.
- 기존 구현 이슈:
  - 설정 프로필 카드 상단은 탭 동작이 없어 진입 경로가 제한됨.
  - 프로필 카운트가 follow-status 응답 필드에만 의존해 `-`로 남는 케이스 존재.
  - 활동 로드에서 게시글 요청 실패 시 즉시 전체 오류 처리되어 댓글 탭 데이터도 노출되지 않음.

## Decision
1. 설정 프로필 카드 상단 클릭 동선 추가
   - 프로필 카드 상단(수정 버튼 위)을 탭하면 `/users/{me}`로 이동.

2. 프로필 카운트 표시 폴백 추가
   - 우선순위: `followStatus.targetFollowerCount/targetFollowingCount`
   - 폴백: `userFollowersProvider`/`userFollowingProvider` 목록 길이.

3. 사용자 활동 로드 부분 성공 허용
   - 작성글/작성댓글 요청을 병렬 실행.
   - 두 요청이 모두 실패할 때만 error 상태.
   - 한쪽 성공 시 성공한 데이터는 화면에 표시.

## Consequences
### Positive
- 설정→내프로필 이동 동선이 직관적이고 일관적.
- 카운트 표시 공백(`-`) 빈도가 줄어듦.
- 네트워크 불안정 시에도 활동 탭이 완전 차단되지 않고 부분 데이터 제공 가능.

### Trade-offs
- 카운트가 일시적으로 follow-status 값과 리스트 길이 기준이 다를 수 있음(동기화 시점 차이).

## Validation
- `flutter analyze lib/features/feed/presentation/pages/user_profile_page.dart lib/features/feed/application/user_activity_controller.dart lib/features/settings/presentation/pages/settings_page.dart`
