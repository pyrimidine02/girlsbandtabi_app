# UXDNAS 59 Elements Implementation Plan

Source: [UXDNAS Guide](https://www.uxdnas.com/guide)  
Related audit: `docs/uxdnas-guide-59-audit.md`

## Reference-derived style methods (from UXDNAS posts/home patterns)
- Social feed hierarchy first:
  - author row -> content -> compact action row -> divider flow.
- Neutral surfaces + strong single accent:
  - light background as near-neutral (`#F9F9F9` family),
  - primary accent blue (`#0A66C2` family) for key actions/states.
- Search/input emphasis:
  - rounded pill search fields with subtle border,
  - low-noise container surfaces and clear focus contrast.
- Tabs/navigation emphasis:
  - segmented tab surface with selected-state elevation contrast,
  - fixed-height compact tabs for dense content apps.
- Loading methodology:
  - list-first screens use skeletons before spinner for perceived speed.

Specific referenced page:
- [UXDNAS Post 322](https://www.uxdnas.com/posts/322)
  - UI Type: Mobile app
  - Color references: `#F9F9F9`, `#0A66C2`

## Rules
- `Apply now`: Current IA/기능에서 바로 구현.
- `Backlog`: 현재 필요도는 낮지만 패턴 가이드만 유지.
- `N/A`: 현재 앱 IA와 충돌하거나 불필요.

| # | Element | How to implement in this app | Status |
|---|---|---|---|
| 1 | Accordion | FAQ/설정 상세에 `ExpansionTile` + divider rhythm 적용 | Backlog |
| 2 | Anatomy & size of chips | `Chip` 높이 32~36, selected/disabled 색상 토큰 고정 | Apply now |
| 3 | Anatomy & specs of text field | `GBTTextField`를 단일 표준 입력 컴포넌트로 강제 | Apply now |
| 4 | Badge | count/status는 `labelSmall` + pill radius + semantic label | Apply now |
| 5 | Bento menu | 대시보드 2x2/3x2 quick action grid로만 제한 사용 | Backlog |
| 6 | Breadcrumb | 모바일 미사용, 웹 전환 시 top breadcrumb 추가 | N/A |
| 7 | Button | 버튼 4종(Primary/Filled tonal/Outlined/Text)만 허용 | Apply now |
| 8 | Buttons analysis | destructive/secondary/primary 우선순위 규칙 문서화 | Apply now |
| 9 | Card | 카드보다 list-divider 우선, 카드는 정보 군집 시만 사용 | Apply now |
| 10 | Carousel | 이미지 다중 첨부에 page indicator + swipe semantics | Apply now |
| 11 | Checkbox | `ThemeData.checkboxTheme`만 사용, 커스텀 금지 | Apply now |
| 12 | Chips | 필터칩은 horizontal scroll + clear affordance | Apply now |
| 13 | Chip states | selected/hover/disabled 시각 상태 토큰 고정 | Apply now |
| 14 | Chips in design systems | compact/assist/filter 역할별 사용처 분리 | Apply now |
| 15 | Dropdown | long list는 bottom-sheet picker로 통일 | Apply now |
| 16 | Drawer | 태블릿 이상에서만 활성화, 모바일은 비활성 | Backlog |
| 17 | Dropdown styles | popup menu radius/border/shadow를 theme 강제 | Apply now |
| 18 | Doner menu | 제품 IA에 없음, 도입 금지 | N/A |
| 19 | Dividers | list 간 구분선 두께/색 단일화(`DividerTheme`) | Apply now |
| 20 | Empty data | `GBTEmptyState`로 메시지/CTA/아이콘 일관화 | Apply now |
| 21 | Form | 섹션 간격 16/24 rhythm + inline error 정책 유지 | Apply now |
| 22 | Floating action button | create action만 FAB 허용, 스크롤 반응형 표시 | Apply now |
| 23 | Hamburger menu | 현재 IA 비적합, 모바일에서는 미사용 | N/A |
| 24 | Icon | 기본 아이콘 사이즈/색은 `IconTheme` 기반 | Apply now |
| 25 | Icon metrics | 16/20/24/32 고정 단계 외 임의 크기 제한 | Apply now |
| 26 | Icon corner | 아이콘 컨테이너 radius를 토큰(`xs/sm/md`)로 제한 | Apply now |
| 27 | Icon stroke | action 아이콘은 outlined 계열 우선 사용 정책 적용 | Apply now |
| 28 | Icon types | navigation=outlined, active state=filled 매핑 규칙 | Apply now |
| 29 | Input field | 페이지별 raw `TextField` 대신 `GBTTextField/GBTSearchBar` | Apply now |
| 30 | Kebab menu | 컨텐츠 overflow 액션은 kebab 한 군데로 집약 | Apply now |
| 31 | Keyline shapes | 4/8/12/16/24 radius 스케일로만 shape 구성 | Apply now |
| 32 | Meatballs menu | comment/item row 보조 액션으로 제한 사용 | Apply now |
| 33 | Modal | destructive/action modal 템플릿 분리 및 재사용 | Apply now |
| 34 | Mobile grid system | 8pt spacing + page horizontal 16 기본 유지 | Apply now |
| 35 | Navigation types (tab bar) | 상단 탭은 `GBTSegmentedTabBar`로 통일 | Apply now |
| 36 | Onboarding | 도입 시 3-step max + skip/restore 정책 | Backlog |
| 37 | Pagination | list는 load-more + pull-to-refresh 병행 정책 | Apply now |
| 38 | Picker | 날짜/선택은 modal sheet picker 재사용 | Apply now |
| 39 | Progress bar | long task는 linear, blocking은 circular 룰 고정 | Apply now |
| 40 | Placeholder | 비어있는 비주얼은 neutral placeholder 컴포넌트 사용 | Apply now |
| 41 | Principles of chip design | 텍스트 길이, 밀도, 상태 대비 가이드 적용 | Apply now |
| 42 | Radio button | 단일 선택 폼은 radio + helper text 표준화 | Apply now |
| 43 | Splash | 네이티브 스플래시만 유지, 앱 내 중복 스플래시 금지 | N/A |
| 44 | Search field | 검색창은 `GBTSearchBar` 단일 컴포넌트로 통일 | Apply now |
| 45 | Slider controls | `SliderTheme` 정의 후 settings/필터에 도입 | Apply now |
| 46 | Stepper | 인증/업로드 다단계 생기면 stepper 컴포넌트 도입 | Backlog |
| 47 | Skeleton screen | `GBT*Skeleton` 프리셋을 list loading 기본값으로 사용 | Apply now |
| 48 | Tab bar | 모든 탭 UI를 segmented 변형으로 일관 유지 | Apply now |
| 49 | Popover style | context actions는 popover/popup menu 패턴 통일 | Apply now |
| 50 | Throbber | 짧은 로딩은 spinner, 길면 skeleton 우선 정책 | Apply now |
| 51 | Toast-pop up | transient feedback는 SnackBar만 사용 | Apply now |
| 52 | Toggle | bool 설정은 Switch + helper text 조합으로 통일 | Apply now |
| 53 | Text fields types | search/password/multiline/typeahead variants 분리 | Apply now |
| 54 | Text fields states | focused/error/disabled 상태 색상 토큰 강제 | Apply now |
| 55 | Text fields styles | field padding/radius/typography 표준 적용 | Apply now |
| 56 | Walkthroughs | 신규 기능 첫 진입 시 lightweight coach marks | Backlog |
| 57 | Web & mobile grids | 모바일 우선, 웹 대응 시 max-width container 도입 | Apply now |
| 58 | Web & mobile color | light/dark ColorScheme 단일 토큰 소스 유지 | Apply now |
| 59 | Web & mobile shadow | elevation 0/1/2/4/8 단계만 허용 | Apply now |

## Immediate execution order
1. Icon stroke/type policy: action icons를 outlined 우선으로 정리. ✅
2. Skeleton defaultization: 리스트 loading에서 spinner 대신 skeleton 우선. ✅
3. Slider theme activation: `ThemeData.sliderTheme` 추가 + 최초 적용 화면 1개 도입. ✅
