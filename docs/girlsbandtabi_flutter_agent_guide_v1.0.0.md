# Girls Band Tabi Flutter 앱 개발 에이전트 가이드 v1.0.0 📱

**프로젝트**: Girls Band Tabi / 걸즈밴드 인포 (성지 순례 & 라이브 정보 앱)  
**대상**: Flutter 기반 모바일 클라이언트를 개발하는 AI 에이전트  
**백엔드 상태**: Spring Boot 기반 REST API v1.3.0 완료  
**레퍼런스**: 
- 개발자 종합 가이드_v2025.11.13  
- API 문서_v2025.11.17  
- 걸즈밴드 인포 앱 디자인 레퍼런스 조사 (하단 5탭: 홈 / 장소 / 라이브 / 정보 / 설정)  
- 문서 작성 가이드_v1.0.0 (문서 구조/스타일)  

---

## 0. 에이전트 동작 모드

AI 에이전트는 이 문서 **하나만**을 기준으로 Flutter 앱을 단계적으로 설계·구현한다.

### 0.1 기본 원칙

1. **기획 우선**: 먼저 네비게이션 구조, 화면 목록, 상태/데이터 흐름을 설계한 뒤 코드 작성.
2. **단계적 구현**: 
   - 1단계: 프로젝트 스캐폴딩 & 공통 인프라(테마, 라우팅, HTTP 클라이언트, 인증 저장소)
   - 2단계: 인증 플로우
   - 3단계: 홈 탭
   - 4단계: 장소 탭
   - 5단계: 라이브 탭
   - 6단계: 정보(뉴스/커뮤니티) 탭
   - 7단계: 설정/마이페이지 탭
   - 8단계: QA, 리팩터링, 성능/에러 처리 정리
3. **반복 루프**: 각 단계마다
   - (a) 요구사항 요약  
   - (b) 화면/위젯 설계 (위계, 상태, 이벤트)  
   - (c) API 연동 설계 (요청/응답 모델, 에러 케이스)  
   - (d) 코드 제안 (Dart/Flutter)  
   - (e) 간단한 시나리오 테스트 플로우 설명  
4. **일관성**: 아래 정의된 네이밍, 모듈 구조, UX 패턴을 유지.

---

## 1. 앱 개요 및 전체 구조

### 1.1 앱 목적

- 일본/해외 걸즈밴드 관련 **성지(장소)**, **라이브 이벤트**, **뉴스/커뮤니티 정보**를 한곳에서 탐색하고,  
  현장에서 **방문 인증(체크인)** 및 **통계 시각화**를 제공하는 모바일 클라이언트.  
- 백엔드에서 제공하는 장소/라이브/방문기록/즐겨찾기/알림/커뮤니티 API와 통합.  

### 1.2 네비게이션 구조 (Bottom 5 Tabs)

하단 탭 5개를 사용한다:

1. **홈(Home)**  
2. **장소(Places)**  
3. **라이브(Live)**  
4. **정보(Info/Feed)** – 뉴스 + 커뮤니티 피드 통합  
5. **설정(Settings / My page)**  

---

## 2. 기술 스택 및 구조 가정

> Flutter 쪽은 기존 문서에 명시된 바 없으므로, 에이전트는 아래 기본 구성을 “권장 디폴트”로 사용한다.

### 2.1 Flutter/Dart 기본

- Flutter: 최신 stable (3.x 기준)
- Dart: null-safety 활용
- 패키지(권장):
  - `dio`: HTTP 클라이언트
  - `flutter_secure_storage`: JWT/리프레시 토큰 저장
  - `go_router` 또는 `auto_route`: 라우팅/딥링크
  - `riverpod` 또는 `flutter_bloc`: 상태 관리 (에이전트가 하나를 선택해 일관되게 사용)
  - `freezed` + `json_serializable`: 모델/DTO 생성
  - `intl`: 날짜/숫자 포맷

### 2.2 레이어/폴더 구조 (Clean-ish Feature 구조)

루트 `lib/` 에서 기능별+레이어별 구조:

- `core/`
  - `config/` – 상수, 환경설정 (BASE_URL, projectId 등)
  - `network/` – `Dio` 인스턴스, 인터셉터(JWT, 로깅, 에러 변환)
  - `theme/` – 라이트/다크 테마
  - `widgets/` – 공통 위젯 (AppBar, PrimaryButton, ErrorView 등)
  - `utils/` – 헬퍼 (날짜 포맷, pagination extractor)
- `features/`
  - `auth/` – 로그인/회원가입/토큰 관리
  - `home/`
  - `places/`
  - `live/`
  - `feed/` (정보 탭: 뉴스 + 커뮤니티)
  - `settings/` (마이페이지 포함)
  - `notifications/`
  - 각 기능 내부:
    - `data/` (API client, DTO)
    - `domain/` (엔티티, 리포지토리 인터페이스)
    - `presentation/` (screen/widget/state)

---

## 3. 백엔드 API와 Flutter 연동 개요

### 3.1 공통 설정

- **Base URL**: `http://localhost:8080` (로컬 개발 기준)  
- **OpenAPI**: `/api-docs` – 필요시 클라이언트 코드 자동 생성에 활용 가능.  
- **주요 API 그룹**: 인증(`/auth/**`), 핵심(`/api/**` – 장소, 업로드, 검색, 사용자), 모니터링(`/actuator/**`)  

### 3.2 주요 엔드포인트 매핑 (Flutter에서 사용할 것)

1. **인증**
   - `POST /api/v1/auth/register`
   - `POST /api/v1/auth/login`
   - `POST /api/v1/auth/refresh`
   - `POST /api/v1/auth/logout`  

2. **홈 요약**
   - `GET /api/v1/home/summary` – 추천 장소, 다가오는 라이브, 최신 뉴스 카드 제공  

3. **장소(Places)**
   - `GET /api/v1/projects/{projectId}/places`
   - `GET /api/v1/projects/{projectId}/places/{placeId}`
   - `GET /api/v1/projects/{projectId}/places/within-bounds`
   - `GET /api/v1/projects/{projectId}/places/nearby`
   - `POST/PUT/DELETE` – 관리자 전용, 앱 1차 버전에서는 조회 중심으로 사용  

4. **검색**
   - `GET /api/v1/search/places`
   - `GET /api/v1/search/units`  

5. **사용자/방문/즐겨찾기**
   - `GET /api/v1/users/me`
   - `PATCH /api/v1/users/me`
   - `GET /api/v1/users/me/visits`
   - `GET /api/v1/users/me/visits/summary`
   - `GET /api/v1/users/me/favorites`
   - `POST /api/v1/users/me/favorites`
   - `DELETE /api/v1/users/me/favorites`  

6. **알림**
   - `GET /api/v1/notifications`
   - `POST /api/v1/notifications/{id}/read`
   - `GET /api/v1/notifications/settings`
   - `PUT /api/v1/notifications/settings`  

7. **파일 업로드 (사진 등)**
   - `POST /api/v1/uploads/presigned-url`
   - `POST /api/v1/uploads/{uploadId}/confirm`
   - `GET /api/v1/uploads/my`
   - `DELETE /api/v1/uploads/{uploadId}`  

8. **커뮤니티/피드**
   - `POST /api/v1/projects/{projectCode}/posts`
   - `GET /api/v1/projects/{projectCode}/posts`
   - `GET /api/v1/projects/{projectCode}/posts/{postId}`
   - `POST /api/v1/projects/{projectCode}/posts/{postId}/comments`
   - `GET /api/v1/projects/{projectCode}/posts/{postId}/comments`  

---

## 4. 탭별 UX & 화면 설계 요약

각 탭의 UX는 “걸즈밴드 인포 앱 디자인 레퍼런스 조사”에 명시된 패턴을 따른다.  

### 4.1 홈 탭 (Home)

**역할**: 요약 피드 – 다가오는 라이브, 인기 장소, 최신 밴드/프로젝트 소식을 카드 형태로 한 화면에.  

#### 주요 화면

1. `HomeScreen`
   - 상단: 프로젝트 선택 드롭다운(예: Girls Band Cry, MyGO!!!!! 등 – 프로젝트 슬러그)
   - 섹션:
     - “다가오는 라이브 이벤트” – `trendingLiveEvents` 카드 리스트
     - “인기 장소” – `recommendedPlaces` 카드 리스트
     - “최신 소식” – `latestNews` 리스트 또는 카드
   - 데이터 소스: `GET /api/v1/home/summary?projectId=...&unitIds=...`  

#### UX 패턴

- 카드형 UI, 스크롤 가능한 컬럼 구조.  
- 각 카드 탭 시 상세 화면으로 이동:
  - 장소 상세 → Places feature
  - 라이브 상세 → Live feature
  - 뉴스/게시물 상세 → Feed feature

---

### 4.2 장소 탭 (Places)

**역할**: 지도 기반 성지 탐색 + 방문 인증 + 방문 통계.  

#### 주요 화면

1. `PlaceMapScreen`
   - 상단: 검색 바 (키워드 검색 → `/search/places`)
   - 본문: 지도 위에 마커 표시 (within-bounds/nearby API)
   - 하단: **바텀시트** 형태 리스트 (현재 지도 뷰에 포함된 장소 목록 카드)  

2. `PlaceListBottomSheet`
   - 장소 카드: 썸네일, 이름, 태그, 밴드/단체 정보, 방문자 수 등  
   - 스크롤/드래그로 전체 화면 확장.

3. `PlaceDetailScreen`
   - 상단: 큰 이미지/갤러리
   - 본문:
     - 장소명, 설명, 주소
     - 태그, 밴드/프로젝트 정보
     - 지도 스니펫
   - 하단 고정 CTA: **“방문 인증하기” 버튼** (Foursquare 체크인과 유사한 패턴)  

4. `PlaceStatsScreen` (PlaceDetail의 스와이프 탭)
   - 스와이프(또는 상단 탭)으로 “정보 / 통계” 전환
   - 통계:
     - 누적 방문자 수
     - 시간대/요일별 방문 그래프 (간단한 bar chart, line chart)
   - 데이터 소스:
     - `/users/me/visits/summary?placeId=...` 등 요약 API + 장소 자체 통계 API가 있다면 활용  

---

### 4.3 라이브 탭 (Live)

**역할**: 밴드 라이브/이벤트 일정 리스트 + 상세 + 공연 인증.  

#### 주요 화면

1. `LiveListScreen`
   - 카드 형태: 포스터 이미지, 제목, 날짜/시간, 장소
   - 필터: 밴드/유닛, 지역, 기간(다가오는/과거)

2. `LiveDetailScreen`
   - 정보: 일시, 장소(지도 링크), 출연 밴드, 설명
   - 하단 CTA: **“공연 인증하기”** 버튼 (Place와 동일한 인증 패턴)  
   - 스와이프 탭: 
     - “정보” 탭 – 공연 상세
     - “통계” 탭 – 해당 밴드의 누적 공연 수, 인증 수 등 (차트 시각화)  

> 라이브 관련 REST 엔드포인트는 API 문서의 “라이브/이벤트” 그룹을 참조하여 구현하고, 패턴은 장소/홈과 동일하게 구성한다.

---

### 4.4 정보 탭 (Info / Feed)

**역할**: 밴드/프로젝트 뉴스 + 커뮤니티 게시물 피드를 모은 정보 허브.

#### 주요 화면

1. `InfoFeedScreen`
   - 섹션:
     - “공지/뉴스” – 홈 요약 `latestNews` 또는 별도 뉴스 API
     - “커뮤니티” – `/projects/{projectCode}/posts` 리스트  
   - 카드: 프로필 아이콘, 닉네임, 제목/본문 일부, 좋아요/댓글 수

2. `PostDetailScreen`
   - 본문 전체, 이미지(업로드된 파일 URL), 댓글 목록
   - 댓글 작성: `POST /posts/{postId}/comments`  

3. `NewPostScreen`
   - 제목, 본문, 이미지 업로드 (R2 presigned URL 사용)  

---

### 4.5 설정 탭 (Settings / My Page)

**역할**: 계정 관리, 알림 설정, 언어 변경, 앱 정보, 마이페이지 요약 등.  

#### 주요 화면

1. `SettingsScreen`
   - 상단: 사용자 프로필 요약 (닉네임, 방문 횟수, 획득 배지 등) – 마이페이지 느낌  
   - 섹션 구성:
     - **계정(Account)**: 프로필 수정, 비밀번호/보안, 로그아웃
     - **알림(Notification)**: 푸시/이메일, 카테고리별 토글 – `/notifications/settings` 사용  
     - **앱 환경(App preferences)**: 언어, 테마(다크/라이트)
     - **기타(About)**: 버전 정보, 오픈소스 라이선스, 문의 링크

2. `ProfileEditScreen`
   - `/users/me` PATCH 연동, 저장 후 토스트 피드백.  

---

## 5. 인증 & 세션 관리 설계

### 5.1 토큰 구조 및 저장

- 백엔드는 Access/Refresh JWT 구조를 사용한다.  
- Flutter:
  - `ACCESS_TOKEN`, `REFRESH_TOKEN`을 `flutter_secure_storage`에 보관.
  - `Dio` 인터셉터에서 요청마다 Authorization 헤더 주입:
    - `Authorization: Bearer <access_token>`
  - 401/403 + 토큰 만료 응답 시:
    - `/auth/refresh` 호출로 토큰 재발급
    - 실패 시 → 강제 로그아웃 & 로그인 화면 이동

### 5.2 인증 플로우

1. **앱 시작**
   - secure storage에서 토큰 조회
   - 유효하면 `/users/me` 호출로 프로필 로드, 아니면 로그인 화면으로.

2. **회원가입 / 로그인**
   - `POST /auth/register`, `POST /auth/login`, `POST /auth/refresh`, `POST /auth/logout` 사용  
   - 응답의 토큰 쌍을 저장 후 홈 화면으로 이동.

3. **로그아웃**
   - `POST /auth/logout` 호출 후 토큰 삭제.

---

## 6. 데이터 모델링 (Flutter 측)

> API 문서의 응답 예제를 기반으로 Dart 모델을 설계한다.  

### 6.1 공통 응답 래퍼

```dart
class ApiResponse<T> {
  final bool success;
  final int statusCode;
  final T? data;
  final Pagination? pagination;
  final Metadata? metadata;
}
```

- `Pagination`, `Metadata` 구조는 API 문서의 예시와 동일한 필드 사용.  

### 6.2 핵심 엔티티 예시

- `Place`
  - id, name, types[], introText, description, latitude, longitude, address, tags[], primaryImage, images[], regionSummary, createdAt, updatedAt  
- `LiveEvent`
  - id, title, startTime, venue(placeId or name), posterUrl, tags[]
- `Visit`
  - visitedAt, placeId, liveEventId?, deviceInfo, locationAccuracy 등(백엔드 스펙에 맞춰 확정)
- `FavoriteItem`
  - entityType (PLACE/LIVE/etc.), entityId  
- `NotificationItem`
  - id, title, body, createdAt, read, category  

---

## 7. 에러 처리 & UX 피드백

### 7.1 에러 공통 처리

- API는 RFC7807 스타일 Problem Details를 사용.  
- Flutter:
  - 네트워크/서버 에러 → 상단 Snackbar 또는 Full-screen ErrorView
  - 인증 에러(401/403) → 로그인 재유도
  - Validation 에러 → 필드별 에러 메시지 매핑

### 7.2 설정/액션 피드백

- 설정 변경, 즐겨찾기 토글, 방문 인증 성공 등은 **토스트/스낵바**로 “성공/실패”를 즉시 알려준다.  

---

## 8. 개발 단계별 체크리스트 (에이전트용)

에이전트는 아래 순서대로 작업한다. 각 단계에서 **설계 → 코드 → 간단 테스트 플로우**를 함께 제시한다.

### 8.1 1단계 – 프로젝트 초기 설정

1. Flutter 프로젝트 생성 (`girlsbandtabi_app` 같은 이름)
2. 패키지 의존성 정의 (`pubspec.yaml`)
3. `core/theme`, `core/network`, `core/config` 기본 클래스 구현
4. `Dio` + JWT 인터셉터 골격 구현
5. 라우터 설정 (스플래시, 로그인, 메인 탭 레이아웃)

### 8.2 2단계 – 인증 기능

1. 로그인/회원가입 화면 UI 작성
2. `/auth/register`, `/auth/login`, `/auth/refresh`, `/auth/logout` 연동  
3. 토큰 저장/로드/리프레시 로직 구현
4. 앱 시작 시 자동 로그인 플로우 구현

### 8.3 3단계 – 홈 탭

1. 홈 요약 카드 레이아웃 설계 (섹션별 카드)
2. `GET /home/summary` 연동, 로딩/에러/성공 상태 관리  
3. 카드 클릭 시 상세 화면으로 라우팅 연결

### 8.4 4단계 – 장소 탭

1. 지도 + 바텀시트 UI 구현 패턴 적용  
2. `within-bounds`, `nearby`, `places` 리스트 연동
3. 장소 상세 + 방문 인증 + 통계 스와이프 탭 구현
4. `/users/me/visits`/`visits/summary`를 이용해 내 방문 기록/요약 표시  

### 8.5 5단계 – 라이브 탭

1. 라이브 목록 카드 UI, 필터/정렬 설계
2. 라이브 상세 + 공연 인증 + 통계 탭 구성
3. 홈/장소와 통합되는 라우팅 (홈에서 눌렀을 때 라이브 상세로)

### 8.6 6단계 – 정보(Feed) 탭

1. 뉴스/커뮤니티 통합 피드 UI 설계
2. 게시물 목록, 상세, 댓글 리스트/작성 연동  
3. 게시글 작성 + 이미지 업로드(presigned URL) 연동  

### 8.7 7단계 – 설정/마이페이지 탭

1. 프로필 요약/통계 카드 구현  
2. 프로필 수정, 알림 설정, 언어/테마 설정 화면 구현
3. 로그아웃, 계정 관련 액션 정리

### 8.8 8단계 – QA & 마감

1. 주요 플로우에 대해 “사용자 시나리오” 단위로 테스트:
   - 첫 로그인 → 홈 → 장소 → 방문 인증 → 통계 확인
   - 라이브 상세 → 공연 인증
   - 커뮤니티 글 작성 → 댓글
   - 설정 변경 → 알림/언어 반영
2. 에러/엣지 케이스 (네트워크 장애, 토큰 만료) 핸들링 점검
3. 코드 정리, 공통 위젯/스타일 정규화

---

## 9. 문서 스타일 (에이전트가 생성할 추가 문서 규칙)

추가로 에이전트가 README, 개발 노트 등을 생성할 때는 **문서작성가이드 v1.0.0**의 기본 구조를 따른다.  

- H1 제목 + 업데이트 날짜/버전/상태
- “📋 목차” 섹션
- “1. 개요 → 2. 주요 내용 → 결론” 구조
- 코드 블록/표/리스트는 Markdown 표준 스타일 유지

---

## 10. 요약

- 이 문서는 **Flutter 클라이언트 개발 에이전트**가 참고할 **단일 소스**로서:
  - 앱의 탭 구조 및 주요 화면
  - 각 기능에 매핑되는 REST API
  - 인증/세션 관리 방식
  - 상태 관리/폴더 구조 가이드
  - 단계별 구현 체크리스트  
  를 제공한다.
- 에이전트는 위 순서를 따라 기능을 하나씩 설계·구현하고, 각 단계마다 코드와 간단한 테스트 시나리오를 함께 제시한다.
