# 모바일 앱 전역 캐싱 정책 v1.0.0

- 작성일: 2026-03-08
- 적용 범위: Flutter 앱(`lib/**`)의 API/이미지/상태 캐시
- 목적: 화면 체감속도 개선 + 불필요한 네트워크 감소 + 일관된 무효화 규칙

## 1) 목표 지표

- 피드/목록 첫 페인트: 캐시 히트 시 300ms 이내
- 동일 화면 재진입 시 불필요한 중복 호출 최소화
- mutation 이후 stale 데이터 노출 윈도우 5초 이하
- 로그 노이즈(반복 404/400) 감축 및 장애 구간 식별 용이성 확보

## 2) 캐시 계층

1. L0 UI 상태 캐시: Riverpod 상태(화면 생명주기)
2. L1 요청 중복 방지: `CacheManager` 백그라운드 리프레시 dedupe
3. L2 영속 캐시: `LocalStorage(SharedPreferences)` + TTL
4. L3 이미지 캐시: `cached_network_image` 기본 디스크 캐시

원칙:

- 읽기 경로는 `CachePolicy` 기반으로 일관 적용
- 쓰기 경로는 성공 시 관련 prefix 무효화
- auth 전환(로그인/로그아웃) 시 auth-scope 캐시 초기화

## 3) 프로필 기반 캐시 정책

| 프로필 | 기본 Policy | TTL | 재검증 주기 | 적용 대상 |
|---|---|---:|---:|---|
| `hot_timeline` | `staleWhileRevalidate` | 1~5분 | 30~60초 | 추천/팔로잉 피드, 알림 목록 |
| `warm_list` | `staleWhileRevalidate` | 5~15분 | 2~5분 | 뉴스 목록, 트렌딩 목록, 검색 결과 |
| `stable_catalog` | `cacheFirst` | 30분~24시간 | 10~30분 | 프로젝트 목록, 지역/필터 옵션, 작성 topic/tag 옵션 |
| `detail_balanced` | `staleWhileRevalidate` | 5~15분 | 2~5분 | 게시글/장소/라이브 상세 |
| `network_sensitive` | `networkFirst` | 3~10분 | - | 권한/설정/민감 상태 |

현재 코드 기준 권장 매핑:

- `home_summary`: `warm_list` (TTL 10m)
- `projects_list`: `stable_catalog` (TTL 30m)
- `community_feed_recommended/following`: `hot_timeline` (TTL 3~5m)
- `post_detail/comments`: `detail_balanced` (TTL 3~5m)
- `post_compose_options(topic/tags)`: `stable_catalog` (TTL 5~30m)
- `notifications`: `hot_timeline` (TTL 1m)

## 4) 캐시 키 규칙

키 포맷:

`gbt_cache:<feature>:<resource>:<scope>:<variant>`

예시:

- `gbt_cache:feed:post_list:project:girls-band-cry:p0:s20`
- `gbt_cache:feed:post_detail:project:girls-band-cry:post:4450...`
- `gbt_cache:feed:post_comments:project:girls-band-cry:post:4450...:p0:s20`
- `gbt_cache:projects:list:global:p0:s20`
- `gbt_cache:settings:user_profile:user:2437...`

규칙:

- project scope 키는 UUID가 아니라 canonical `projectCode`를 우선 사용
- auth-scope 데이터는 `userId` segment 포함 권장
- 페이지/사이즈/정렬/커서는 키 segment에 명시
- prefix invalidation을 위해 feature/resource segment를 고정 유지

## 5) 무효화 규칙(Invalidation Matrix)

- 로그인/로그아웃/계정 전환:
  - `CacheManager.clearAll()` + auth 관련 provider reset
- 게시글 생성/수정/삭제 성공:
  - `feed:post_list:*`
  - `feed:post_trending:*`
  - 대상 `feed:post_detail:*`, `feed:post_comments:*`
  - 작성자 activity prefix
- 댓글/답글 생성/수정/삭제 성공:
  - 대상 `feed:post_comments:*`, `feed:post_detail:*`
  - 연관 목록 prefix(`post_list`, `post_trending`) 무효화
- 프로필/설정 변경 성공:
  - `settings:user_profile:*`
  - `users:profile:*`(존재 시)
- 알림 읽음/전체 읽음 성공:
  - `notifications:p0:s20` 우선 제거, 필요 시 paged prefix 제거

## 6) 404/400 대응과 네거티브 캐시

문제:

- 피드 카드 후속 조회(`like/bookmark`)에서 404가 반복되면 로그 노이즈와 UX 저하 발생

정책:

- `RESOURCE_NOT_FOUND`는 기능별로 soft-fail 허용 범위를 정의
  - 예: reaction status 조회 404 → `isLiked=false`, `isBookmarked=false`로 degrade 가능
- 동일 리소스 404는 짧은 네거티브 캐시(권장 30~60초) 적용
- 반복 에러 로깅은 샘플링/집계 기반으로 제한

## 7) 화면 동작 규칙

- cache hit:
  - 즉시 렌더링, 백그라운드 revalidate 가능
- stale hit:
  - 데이터 표시 + 필요 시 조용한 재검증
- network fail + cache hit:
  - 캐시 유지, 차단형 에러 대신 non-blocking 안내
- network fail + cache miss:
  - 표준 에러 상태 노출(재시도 액션 포함)

## 8) 관측성(Observability)

권장 이벤트:

- `cache_hit`
- `cache_miss`
- `cache_stale_hit`
- `cache_refresh_started/succeeded/failed`
- `cache_invalidation`(prefix, count)

권장 로그 필드:

- `feature`, `resource`, `policy`, `key_prefix`, `age_ms`, `ttl_ms`,
  `force_refresh`, `failure_code`

## 9) 단계별 적용 계획

1. 정책 문서 고정(본 문서 + ADR)
2. 캐시 키 레지스트리/프로필 상수 도입(`lib/core/cache/*`)
3. 피드/알림에 우선 적용(로그 노이즈 큰 구간)
4. 홈/장소/라이브/검색/설정으로 확장
5. 운영 로그 기반으로 TTL/정책 튜닝(분기 1회)

## 10) 비범위(Out of Scope)

- 서버 Redis/L2 캐시 정책 변경
- 오프라인 쓰기 큐(쓰기 지연 동기화)
- 이미지 CDN 캐시 제어 헤더 최적화
