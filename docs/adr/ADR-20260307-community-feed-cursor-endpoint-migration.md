# ADR-20260307-community-feed-cursor-endpoint-migration

## Status
Accepted (2026-03-07)

## Context
- 서버 커뮤니티 피드 계약이 다음으로 정리되었다.
  - `GET /api/v1/community/feed/recommended/cursor`
  - `GET /api/v1/community/feed/following/cursor`
- 기존 `GET /api/v1/community/feed/cursor`는 삭제되었고,
  프런트에서 더 이상 호출하면 안 된다.
- 추천 탭은 무한스크롤에서 커서(`nextCursor`)를 그대로 전달하는 계약을 따른다.

## Decision
- 앱 커뮤니티 피드 레이어를 아래와 같이 마이그레이션한다.
  - 삭제 경로 상수/호출 제거:
    - `/api/v1/community/feed/cursor`
  - 추천 탭 커서 호출 추가:
    - `/api/v1/community/feed/recommended/cursor`
  - 팔로잉 탭 legacy fallback 제거:
    - `404 -> /community/feed/cursor` 폴백 삭제
  - 추천 탭 로딩/더보기/백그라운드 동기화를 페이지 기반에서 커서 기반으로 전환
  - 추천/팔로잉 모드는 인증이 없으면 `AuthFailure(auth_required)`로 처리
  - API v3 endpoint catalog / contract test를 동일 경로로 동기화

## Alternatives
- 추천 탭을 페이지 기반(`/community/feed/recommended`)으로 유지:
  - 장점: 비로그인 접근이 가능
  - 단점: 무한스크롤 커서 계약과 불일치, 서버 기준 탭 동작과 분리됨
- 삭제 경로 fallback 유지:
  - 장점: 백엔드 미배포 구간 임시 대응
  - 단점: 삭제 계약 위반 호출이 계속 남아 회귀 리스크가 커짐

## Consequences
- 추천/팔로잉 탭의 커서 동작이 서버 계약과 일치한다.
- 삭제된 경로 호출로 인한 `400/404` 회귀 가능성이 줄어든다.
- 비로그인 상태에서 추천/팔로잉 접근 시 로그인 유도 UX가 필요하다.

## Verification
- `flutter analyze` (feed/controller/repository/constants/test 대상 파일) 통과
- `flutter test test/core/constants/api_endpoints_contract_test.dart` 통과
