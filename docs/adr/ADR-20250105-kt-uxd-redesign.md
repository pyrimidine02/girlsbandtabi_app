# ADR-20250105: KT UXD v1.1 전면 리디자인 로드맵

## 배경 / Context
- Girls Band Tabi 앱은 기존 임시 테마와 컴포넌트에 의존하며, 최신 KT UXD 디자인 시스템(v1.1)과 일치하지 않습니다.
- UX 문서(Seamless Flow, Foundations, Components, AI Agent 등)을 그대로 적용하려면 토큰, 위젯, 화면, 관리자/AI 영역까지 모두 재구축해야 합니다.
- 한 번에 전부 교체할 경우 개발/QA 비용이 폭증하므로 단계적 로드맵과 작업 상태 추적이 필요합니다.

## 결정 / Decision
- KT UXD 문서를 기준으로 **5단계 단계별 리디자인 플랜**을 수립하고, 단계별 산출물과 상태를 관리한다.
- Stage 1부터 순차적으로 진행하며, 각 단계 착수 전 세부 범위·테스트를 확정한다.

## 단계별 범위 / Implementation Plan
| 단계 | 범위 | 주요 산출물 | 상태 |
| --- | --- | --- | --- |
| Stage 1 · Foundations | 색상/타이포/모션/쉐도우 토큰 정비, Pretendard/Nunito 폰트, ThemeData 재정의 | 신규 palette, Typography, Design Tokens, Theme 연결 | 완료 |
| Stage 2 · Components | KT UXD 16개 컴포넌트 + AI Agent 전용 컴포넌트 구현, 기존 Flow 위젯 대체 | Buttons, Navigation, Forms, Prompt/Process 위젯 | 진행 중 |
| Stage 3 · Core Screens | 홈, 라이브, Places, Info, All/즐겨찾기 리디자인 + 회귀 테스트 | 신 UI 배포 | 미착수 |
| Stage 4 · Admin & Etc | 관리자 대시보드/설정/법무 등 보조 화면 일괄 적용 | Admin 모듈 UI, 설정/법무 화면 | 미착수 |
| Stage 5 · AI & QA | AI 프롬프트 UX, 접근성/다크 모드/국제화 최종 점검 | AI 전용 플로우, QA 리포트 | 미착수 |

## Stage 1 체크리스트
- [x] 색상 팔레트 및 브랜드 컬러 토큰 정리 (KTColors)
- [x] 타이포그래피/폰트 패밀리 정의 (Pretendard + Nunito Sans)
- [x] Design Tokens/ThemeData가 새 토큰을 소비하도록 연결
- [ ] Pretendard/Nunito 실제 폰트 자산 번들링 (후속 작업 · 우선순위 낮음)

## Stage 2 체크리스트 (컴포넌트)
- [x] 버튼 시스템 (Primary/Secondary/Tonal/Outline/Ghost/Destructive)
- [x] 아이콘 버튼 변형
- [x] 입력 필드(Text Field) 토큰화
- [x] 체크박스/라디오/슬라이더 등 Form Controls
- [x] 드롭다운, 리스트/디바이더, 통합 바텀시트/툴팁/배너
- [x] 검색(Search) 컴포넌트
- [x] Popup/Dialog 패턴 전면 적용
- [x] AI Prompt / Process Indicator 컴포넌트

Stage 1은 현재 **테마/토큰 리팩토링**에 집중하고, 폰트 에셋 배포·컴포넌트 리디자인은 후속 단계에서 처리한다. 각 단계 완료 시 CHANGELOG와 추가 ADR로 추적한다.

**2025-01-05 Stage 2 보강 사항**
- EN: Added `lib/widgets/common/kt_ai_components.dart` to host `KTAINavigationBar`, `KTAIPromptField`, and `KTAIProcessIndicator`, covering the AI Agent checklist items.
- KO: AI Agent 체크리스트를 충족하기 위해 `lib/widgets/common/kt_ai_components.dart`에 `KTAINavigationBar`, `KTAIPromptField`, `KTAIProcessIndicator`를 구현했습니다.
- EN: Created `KTDialog` + `KTPopupMenu` inside `lib/widgets/common/kt_feedback.dart` so popup/dialog patterns now share tokens/actions across screens.
- KO: 팝업/다이얼로그 패턴을 화면 전반에서 재사용할 수 있도록 `lib/widgets/common/kt_feedback.dart`에 `KTDialog`, `KTPopupMenu`를 추가했습니다.
