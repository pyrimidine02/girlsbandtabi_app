# ADR-20260307-post-compose-timeline-like-redesign

## Status
Accepted (2026-03-07)

## Context
- 사용자 요청으로 게시글 작성/수정 화면을 레퍼런스 이미지와 유사한
  모바일 타임라인형 composer 구조로 변경할 필요가 있었다.
- 기존 화면은 섹션 카드 중심 구조로, 작성 흐름에서 입력 집중도와
  레퍼런스 대비 시각 리듬이 다소 달랐다.

## Decision
- `lib/features/feed/presentation/pages/post_create_page.dart`
  `lib/features/feed/presentation/pages/post_edit_page.dart` UI를
  타임라인형 composer로 리디자인한다.
- 주요 변경:
  - AppBar 액션을 `취소 / 임시 보관함 / 게시(수정)하기` 구조로 정렬
  - 본문을 카드 분할 대신 `아바타 + 제목 + 큰 본문 입력`의 인라인 입력 구조로 전환
  - 첨부 이미지는 가로 스트립 형태로 미리보기/삭제 제공
  - 하단에 공개 안내 문구 + 컴팩트 아이콘 툴바 배치
  - 프로젝트 선택은 기능 유지 관점에서 컴팩트 행으로 잔존
- 비즈니스 로직(임시저장/복구, 업로드, 제출, 유효성)은 유지한다.

## Consequences
- 입력 집중도가 높아지고 레퍼런스와 유사한 작성 경험을 제공한다.
- 기존 기능 회귀 리스크를 줄이기 위해 로직 계층 변경은 최소화했다.
- 실제 디바이스에서 키보드/안전영역/툴바 상호작용 QA가 필요하다.

## Verification
- `flutter analyze lib/features/feed/presentation/pages/post_create_page.dart lib/features/feed/presentation/pages/post_edit_page.dart`
