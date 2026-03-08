# ADR-20260308: App-Wide Cache Policy Governance

- Date: 2026-03-08
- Status: Accepted
- Scope: `lib/core/cache/**`, all feature repositories using `CacheManager`

## Context

- 기능별 repository에서 `CachePolicy`/TTL/key 규칙이 분산되어 있으며,
  무효화 범위도 feature별 편차가 존재한다.
- 최근 커뮤니티 피드에서 후속 reaction 조회(좋아요/북마크) 오류 로그가
  반복되며, 캐시/재시도/soft-fail 기준의 표준화 필요성이 커졌다.
- 운영 단계에서 캐시 튜닝(정책/TTL)을 일관되게 수행하려면
  문서화된 전역 정책 + rollout 체크리스트가 필요하다.

## Decision

1. 전역 캐시 정책 문서를 기준점으로 채택한다.
   - `docs/architecture/MOBILE_APP_CACHE_POLICY_V1.0.0.md`
2. 읽기 경로를 프로필(`hot_timeline`, `warm_list`, `stable_catalog`,
   `detail_balanced`, `network_sensitive`) 중심으로 관리한다.
3. 캐시 키 네이밍을 `feature/resource/scope/variant` 세그먼트로 고정하고,
   mutation 성공 시 prefix 무효화를 표준으로 한다.
4. 반복 404/400은 기능별 soft-fail 가능 범위를 명시하고,
   짧은 네거티브 캐시 + 로그 샘플링을 도입한다(구현 단계).

## Alternatives Considered

1. 현행 유지(각 repository 자율 정책)
   - Rejected: 정책 드리프트와 무효화 누락 위험이 계속 증가.
2. 모든 read 경로를 `networkFirst`로 단일화
   - Rejected: 모바일 체감 성능/오프라인 복원력 저하.
3. 모든 read 경로를 `cacheFirst`로 단일화
   - Rejected: mutation 직후 stale 노출 리스크가 높음.

## Consequences

- 장점:
  - 정책/TTL/key 규칙을 한 곳에서 검토하고 단계적으로 적용 가능.
  - 장애 시 원인 추적(`policy`, `age`, `key_prefix`)이 쉬워짐.
  - 캐시 무효화 규칙이 기능 간 일관되어 회귀 위험이 감소.
- 비용:
  - 단기적으로 feature repository에 프로필/키 규칙 이관 작업 필요.
  - 관측 이벤트 추가 시 로그/분석 비용이 증가할 수 있음.

## Validation

- 문서 기준점 생성:
  - `docs/architecture/MOBILE_APP_CACHE_POLICY_V1.0.0.md`
- 실행 backlog 반영:
  - `TODO.md` 캐시 정책 구체 작업 항목 추가
- 변경 기록 반영:
  - `CHANGELOG.md`
