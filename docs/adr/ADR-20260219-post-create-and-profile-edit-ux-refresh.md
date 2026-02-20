# ADR-20260219: Post Create & Profile Edit UX Refresh

- Date: 2026-02-19
- Status: Accepted
- Scope: `PostCreatePage`, `ProfileEditPage`

## Context

커뮤니티 글 작성 화면과 프로필 수정 화면이 기능은 동작하지만, 다음 문제가 있었다.

- 작성 진행 상태가 직관적으로 보이지 않아 입력 완료 기준이 불명확함.
- 이미지 첨부 UX가 약해(중복 선택/최대 개수 제어/미리보기) 실사용 피드백이 느림.
- 프로필 수정 시 "무엇이 변경되었는지"와 "저장 필요 여부"가 약하게 전달됨.
- 저장 전 이탈 시 데이터 손실 가능성이 높음.

## Decision

두 화면에 공통으로 "진행 상태 가시화 + 안전한 이탈 처리 + 입력/미디어 UX 개선"을 적용한다.

### Post Create

- 작성 가이드 카드(진행률 + 체크 칩) 추가.
- 프로젝트 컨텍스트 배지, 제목/내용 도움 문구 강화.
- 이미지 섹션을 썸네일 그리드로 개선하고 미리보기 다이얼로그 제공.
- 이미지 중복 선택 방지 및 최대 첨부 수(6장) 강제.
- 임시 작성 내용이 있을 때 이탈 확인 다이얼로그 표시.

### Profile Edit

- 섹션 카드 기반 레이아웃으로 정보 구조를 명확화.
- 변경 감지(dirty state) 기반 저장 버튼 활성화.
- 저장 대기 배지/배너로 반영 전 상태를 명시.
- pull-to-refresh + drag dismiss로 수정 중 재동기화/키보드 UX 개선.
- 저장 전 이탈 확인 다이얼로그 적용.

## Alternatives Considered

1. 기존 레이아웃 유지 + 텍스트 안내만 추가
- 장점: 구현 비용 최소
- 단점: 핵심 문제(가시성/실수 방지/미디어 사용성) 해결이 제한적

2. 하단 고정 저장 바(FAB/Bottom Bar)로 저장 액션 이동
- 장점: 저장 CTA 노출 극대화
- 단점: 키보드/좁은 화면에서 레이아웃 충돌 가능성이 커서 이번 범위에서는 제외

## Consequences

- UX 측면: 작성/수정 완료 기준이 명확해지고, 실수 이탈로 인한 손실이 줄어든다.
- 기술 측면: 상태 계산(dirty/completion) 로직이 증가했지만 화면 내부에 캡슐화되어 확장 여지가 크다.
- 테스트 측면: 새 상호작용(이탈 확인/중복 이미지/dirty save) 위젯 테스트가 추가로 필요하다.

## Validation

- `dart format` on touched files
- `flutter analyze lib/features/feed/presentation/pages/post_create_page.dart lib/features/settings/presentation/pages/profile_edit_page.dart`
