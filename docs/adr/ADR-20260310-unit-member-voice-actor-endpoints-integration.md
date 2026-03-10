# ADR-20260310: Unit/Member/Voice-Actor Endpoints Integration

- Date: 2026-03-10
- Status: Accepted
- Scope:
  - `/Users/sonhoyoung/Documents/code/girlsbandtabi_app/lib/features/projects/**`
  - `/Users/sonhoyoung/Documents/code/girlsbandtabi_app/lib/features/feed/presentation/pages/info_page.dart`
  - `/Users/sonhoyoung/Documents/code/girlsbandtabi_app/lib/features/feed/presentation/pages/unit_detail_page.dart`
  - `/Users/sonhoyoung/Documents/code/girlsbandtabi_app/lib/features/feed/presentation/pages/member_detail_page.dart`
  - `/Users/sonhoyoung/Documents/code/girlsbandtabi_app/lib/features/feed/presentation/pages/voice_actor_detail_page.dart`
  - `/Users/sonhoyoung/Documents/code/girlsbandtabi_app/lib/features/feed/presentation/widgets/voice_actor_directory_tab.dart`
  - `/Users/sonhoyoung/Documents/code/girlsbandtabi_app/lib/features/places/**`
  - `/Users/sonhoyoung/Documents/code/girlsbandtabi_app/lib/core/constants/api_constants.dart`
  - `/Users/sonhoyoung/Documents/code/girlsbandtabi_app/lib/core/constants/api_v3_endpoints_catalog.dart`

## Context
- 백엔드 요청서 `FE-REQ-UNIT-MEMBER-VOICE-ACTOR-20260310` 기준으로
  유닛/멤버/성우 조회 계약이 확장되었습니다.
- 프런트는 기존 단일 성우명(`voiceActorName`) 중심 구현이었고,
  `voiceActors[]`/성우 독립 상세 API/크레딧 탭이 부족했습니다.
- 요청서 수용기준에는 `unitIdentifier`(slug/UUID) 혼용 대응과
  장소 후기 삭제 권한 노출 정책(작성자/모더레이터)도 포함됩니다.

## Decision
- v1.4.0 계약 기준으로 성우 조회는 프로젝트/유닛 레이어 경로로 통일합니다.
  - `GET /projects/{projectId}/units/voice-actors`
  - `GET /projects/{projectId}/units/voice-actors/{voiceActorId}`
  - `GET /projects/{projectId}/units/voice-actors/{voiceActorId}/members`
  - `GET /projects/{projectId}/units/voice-actors/{voiceActorId}/credits`
- 라우팅 및 Provider/캐시 키는 `projectId + voiceActorId` 조합을
  필수 키로 사용합니다.
- DTO/도메인/리포지토리/컨트롤러를 `voiceActors[]` 구조 중심으로 확장합니다.
- 정보(Info) 화면에 성우 디렉토리 탭을 추가하고,
  성우 상세 화면(담당 캐릭터/크레딧 탭)을 신설합니다.
- 유닛/멤버 상세 라우팅을 `unitIdentifier` 기준(슬러그/UUID 호환)으로 정렬합니다.
- 장소 후기 삭제 API(`DELETE /places/{placeId}/comments/{commentId}`)를
  places 계층에 추가하고, UI는 작성자/모더레이터에게만 삭제 메뉴를 노출합니다.

## Alternatives Considered
1. 성우 독립 화면 없이 멤버 카드 내 텍스트만 확장
   - Rejected: 백엔드가 제공하는 성우 검색/크레딧 가치가 노출되지 않습니다.
2. `unitIdentifier` 호환을 서버 폴백에만 의존
   - Rejected: 라우팅/깊은 링크 진입에서 프런트 경로 불일치가 남습니다.
3. 장소 후기 삭제 버튼을 전원 노출 후 서버 403에 의존
   - Rejected: 권한 없는 사용자에게 불필요한 실패 UX가 발생합니다.

## Consequences
- 정보 화면에서 성우 탐색/상세 시나리오가 독립적으로 동작합니다.
- 멤버 상세에서 다중 성우 역할(`roleType`)을 안정적으로 표현할 수 있습니다.
- `unitIdentifier` 혼용으로 프로젝트 데이터 이관/슬러그 변경 상황에서도
  화면 진입 안정성이 좋아집니다.
- 장소 후기 삭제는 권한 기반으로 노출되어 UX가 명확해집니다.

## Validation
- `flutter analyze`
- `flutter test test/core/constants/api_endpoints_contract_test.dart`
