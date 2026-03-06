# ADR-20260307-community-following-feed-cursor-endpoint-split

## Status
Accepted (2026-03-07)

## Context
- 모바일 게시판의 `추천`/`팔로잉` 탭이 모두 동일 API
  (`GET /api/v1/community/feed/cursor`)를 사용하고 있었다.
- 이 구조에서는 `팔로잉` 탭이 서버의 팔로잉 전용 read path를 사용하지 못해
  탭 의미와 실제 데이터 소스가 불일치할 수 있다.

## Decision
- `팔로잉` 탭 전용 API를 분리 적용한다.
  - `팔로잉`: `GET /api/v1/community/feed/following/cursor`
  - `추천`: 기존 `GET /api/v1/community/feed/cursor` 유지
- 앱 계층 변경 범위:
  - API 상수 추가 (`communityFollowingFeedCursor`)
  - feed remote data source/repository 인터페이스/구현에
    following 전용 cursor 메서드 추가
  - board controller의 `CommunityFeedMode.following` 분기만
    following 전용 메서드를 호출하도록 변경
  - API catalog/contract test에 새 경로 추가

## Consequences
- 탭 의미와 서버 read path가 일치해 팔로잉 탭 동작의 예측 가능성이 높아진다.
- 추천/팔로잉 분리가 명확해져 향후 랭킹/개인화 정책 변경 시 영향 범위를
  독립적으로 관리할 수 있다.

## Verification
- `dart analyze` (변경 파일 대상) 통과
- `flutter test test/core/constants/api_endpoints_contract_test.dart` 통과
