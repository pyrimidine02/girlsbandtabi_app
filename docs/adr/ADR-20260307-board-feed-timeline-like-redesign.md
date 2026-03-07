# ADR-20260307-board-feed-timeline-like-redesign

## Status
Accepted (2026-03-07)

## Context
- 사용자 요청은 피드 화면을 제공된 레퍼런스와 유사한 구조로 재배치하되,
  라이트/다크 색상 체계 자체는 기존 앱 토큰을 유지하는 것이었다.
- 기존 피드 화면은 상단 AppBar + 단순 탭 + 둥근 카드 중심 레이아웃으로,
  레퍼런스의 타임라인형 밀도(헤더/탭/토픽칩/플랫한 포스트 블록)와 차이가 있었다.

## Decision
- `lib/features/feed/presentation/pages/board_page.dart`의 피드(섹션 0)만
  구조적으로 리디자인한다.
- 색상은 신규 팔레트를 도입하지 않고 기존 `GBTColors` 토큰을 재사용한다.
- 주요 변경:
  - 섹션 0은 AppBar를 제거하고, 본문 상단에 커스텀 feed hero header 배치.
    - `피드` 타이틀 옆 보조 지표 텍스트는 제거.
  - 상단 모드 탭을 `추천/팔로잉/뉴스/콘텐츠`로 구성.
    - `추천 -> recommended`, `팔로잉 -> following`, `뉴스 -> latest`,
      `콘텐츠 -> project list`로 매핑.
  - 토픽칩(`전체 + 구독 프로젝트`) 추가.
    - 구독 프로젝트 칩 탭 시 프로젝트 선택 상태를 동기화하고 `콘텐츠` 탭으로 전환.
  - 포스트 렌더링을 카드형에서 타임라인형 블록으로 전환.
    - 강한 외곽 카드/빈 썸네일 슬롯 제거
    - 작성자 메타 텍스트를 한 단계 축소
    - 본문은 5줄 미리보기 기준으로 렌더링하고, 초과 시에만 `더보기` 노출
    - `더보기`는 게시글 상세 화면으로 라우팅
    - 트위터형 와이드 이미지 배치(라운드 경계) 적용
    - 액션행(좋아요/댓글/북마크) 동작은 유지

## Consequences
- 사용자 요청 레퍼런스와 유사한 정보 밀도의 피드 구조를 제공한다.
- 기존 반응(좋아요/북마크/댓글) 및 신고/차단/관리 액션 동작은 유지된다.
- 섹션 0 AppBar 제거로 safe-area/노치 영역 시각 QA가 필요하다.

## Verification
- `flutter analyze lib/features/feed/presentation/pages/board_page.dart`
